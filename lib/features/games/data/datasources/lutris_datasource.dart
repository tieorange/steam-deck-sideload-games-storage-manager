import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:game_size_manager/features/games/data/models/lutris_game_dto.dart';

import 'package:game_size_manager/core/error/failures.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/platform/platform_service.dart';
import 'package:game_size_manager/features/games/data/datasources/game_datasource.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// Data source for Lutris games
class LutrisDatasource implements GameDatasource {
  LutrisDatasource({PlatformService? platformService, LoggerService? logger})
    : _platform = platformService ?? PlatformService.instance,
      _logger = logger ?? LoggerService.instance;

  final PlatformService _platform;
  final LoggerService _logger;

  /// Get all installed Lutris games from pga.db
  @override
  Future<Result<List<Game>>> getGames() async {
    _logger.info('============ LUTRIS DETECTION ============', tag: 'Lutris');
    final dbPath = _platform.lutrisDbPath;
    _logger.info('Lutris DB path: $dbPath', tag: 'Lutris');

    if (dbPath == null) {
      _logger.info('Lutris not installed', tag: 'Lutris');
      return const Right([]);
    }

    try {
      // sqflite initialized in main.dart

      final db = await openDatabase(dbPath, readOnly: true);

      // Query installed games
      final results = await db.rawQuery('''
        SELECT id, name, slug, directory 
        FROM games 
        WHERE installed = 1 AND directory IS NOT NULL AND directory != ''
      ''');

      final games = <Game>[];

      _logger.debug('Query returned ${results.length} rows', tag: 'Lutris');

      for (final row in results) {
        try {
          var dto = LutrisGameDto.fromMap(row);

          // Try to find actual game path from YAML config
          final configPath = _findGameConfigFile(dto.slug);
          if (configPath != null) {
            final yamlContent = await File(configPath).readAsString();
            final gamePath = _extractGamePathFromYaml(yamlContent);
            if (gamePath != null) {
              _logger.debug('Found game path from YAML for ${dto.slug}: $gamePath', tag: 'Lutris');
              dto = dto.copyWith(gamePath: gamePath);
            } else {
              _logger.debug('Could not extract game path from YAML for ${dto.slug}', tag: 'Lutris');
            }
          } else {
            _logger.debug('No config file found for ${dto.slug}', tag: 'Lutris');
          }

          if ((dto.gamePath != null && dto.gamePath!.isNotEmpty) ||
              (dto.directory != null && dto.directory!.isNotEmpty)) {
            final gamePathToLog = dto.gamePath ?? dto.directory;
            _logger.debug(
              'Found Lutris game: ${dto.name} (${dto.slug}) at $gamePathToLog',
              tag: 'Lutris',
            );
            games.add(dto.toEntity());
          } else {
            _logger.warning(
              'Skipping Lutris game ${dto.name}: directory/gamePath is empty/null',
              tag: 'Lutris',
            );
          }
        } catch (e) {
          _logger.warning('Error processing Lutris game row: $e', tag: 'Lutris');
        }
      }

      await db.close();

      _logger.info('Found ${games.length} Lutris games', tag: 'Lutris');
      return Right(games);
    } catch (e, s) {
      _logger.error('Failed to read Lutris database', error: e, stackTrace: s, tag: 'Lutris');
      return Left(DatabaseFailure('Failed to read Lutris database: $e', s));
    }
  }

  /// Find the YAML config file for a given game slug
  String? _findGameConfigFile(String slug) {
    try {
      final configPath = _platform.lutrisGamesConfigPath;
      if (configPath == null) return null;

      final dir = Directory(configPath);
      if (!dir.existsSync()) return null;

      // Lutris config files are usually named <slug>-<timestamp>.yml or <slug>.yml
      final files = dir.listSync();

      for (final entity in files) {
        if (entity is File) {
          final filename = p.basename(entity.path);
          // Check for exact match or starts with slug-
          // We want to avoid partial matches (e.g. slug="foo" matching "foobar.yml")
          if (filename == '$slug.yml' || filename.startsWith('$slug-')) {
            return entity.path;
          }
        }
      }
    } catch (e) {
      _logger.warning('Error finding config for $slug: $e', tag: 'Lutris');
    }
    return null;
  }

  /// Parse YAML content to extract the executable path's directory
  String? _extractGamePathFromYaml(String yamlContent) {
    try {
      final yaml = loadYaml(yamlContent);
      if (yaml is YamlMap) {
        // Look for game: -> exe:
        final gameSection = yaml['game'];
        if (gameSection is YamlMap) {
          final exePath = gameSection['exe'] as String?;
          if (exePath != null && exePath.isNotEmpty) {
            // The executables are usually inside the game directory
            // So we take the directory of the executable
            return p.dirname(exePath);
          }
        }
      }
    } catch (e) {
      _logger.warning('Error parsing YAML: $e', tag: 'Lutris');
    }
    return null;
  }
}
