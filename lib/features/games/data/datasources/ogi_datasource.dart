import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/error/failures.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/platform/platform_service.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// Data source for OpenGameInstaller (OGI)
class OgiDatasource {
  OgiDatasource({PlatformService? platformService, LoggerService? logger})
    : _platform = platformService ?? PlatformService.instance,
      _logger = logger ?? LoggerService.instance;

  final PlatformService _platform;
  final LoggerService _logger;

  /// Get all installed OGI games
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

            final name = json['name'] as String? ?? 'Unknown';
            final appId = json['appID'] as String? ?? entity.path;
            final installLocation = json['installLocation'] as String?;

            if (installLocation != null && installLocation.isNotEmpty) {
              _logger.debug('Found OGI game: $name at $installLocation', tag: 'OGI');
              games.add(
                Game(
                  id: 'ogi_$appId',
                  title: name,
                  source: GameSource.ogi,
                  installPath: installLocation,
                  sizeBytes: 0, // Needs calculation
                  iconPath: json['titleImage'] as String?,
                ),
              );
            } else {
              _logger.debug('Skipping OGI game $name: installLocation is empty/null', tag: 'OGI');
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
