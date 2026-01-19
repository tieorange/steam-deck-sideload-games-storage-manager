import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:game_size_manager/features/games/data/models/ogi_game_dto.dart';

import 'package:game_size_manager/core/error/failures.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/platform/platform_service.dart';
import 'package:game_size_manager/features/games/data/datasources/game_datasource.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// Data source for OpenGameInstaller (OGI)
class OgiDatasource implements GameDatasource {
  OgiDatasource({PlatformService? platformService, LoggerService? logger})
    : _platform = platformService ?? PlatformService.instance,
      _logger = logger ?? LoggerService.instance;

  final PlatformService _platform;
  final LoggerService _logger;

  /// Get all installed OGI games
  @override
  Future<Result<List<Game>>> getGames() async {
    final libraryPath = _platform.ogiLibraryPath;
    final libraryDir = Directory(libraryPath);

    if (!libraryDir.existsSync()) {
      _logger.info('OGI not installed', tag: 'OGI');
      return const Right([]);
    }

    try {
      final games = <Game>[];

      await for (final entity in libraryDir.list()) {
        if (entity is File && entity.path.endsWith('.json')) {
          _logger.debug('Processing OGI file: ${entity.path}', tag: 'OGI');
          try {
            final content = await entity.readAsString();
            final json = jsonDecode(content) as Map<String, dynamic>;

            final dto = OgiGameDto.fromJson(json, entity.path);

            if (dto.installLocation != null && dto.installLocation!.isNotEmpty) {
              _logger.debug('Found OGI game: ${dto.name} at ${dto.installLocation}', tag: 'OGI');
              games.add(dto.toEntity());
            } else {
              _logger.debug(
                'Skipping OGI game ${dto.name}: installLocation is empty/null',
                tag: 'OGI',
              );
            }
          } catch (e) {
            _logger.warning('Failed to parse OGI game: ${entity.path} ($e)', tag: 'OGI');
          }
        }
      }

      _logger.info('Found ${games.length} OGI games', tag: 'OGI');
      return Right(games);
    } catch (e, s) {
      _logger.error('Failed to read OGI library', error: e, stackTrace: s, tag: 'OGI');
      return Left(FileSystemFailure('Failed to read OGI library: $e', s));
    }
  }
}
