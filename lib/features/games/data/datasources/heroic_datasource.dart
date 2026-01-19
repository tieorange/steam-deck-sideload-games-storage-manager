import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/error/failures.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/platform/platform_service.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// Data source for Heroic Games Launcher (Epic + GOG)
class HeroicDatasource {
  HeroicDatasource({PlatformService? platformService, LoggerService? logger})
    : _platform = platformService ?? PlatformService.instance,
      _logger = logger ?? LoggerService.instance;

  final PlatformService _platform;
  final LoggerService _logger;

  /// Get all installed Epic games from Legendary's installed.json
  Future<Result<List<Game>>> getEpicGames() async {
    final jsonPath = _platform.legendaryInstalledJsonPath;

    if (jsonPath == null) {
      return const Left(LauncherNotFoundFailure('Heroic/Legendary not installed'));
    }

    final file = File(jsonPath);
    if (!file.existsSync()) {
      _logger.info('No Epic games installed (installed.json not found)', tag: 'Heroic');
      return const Right([]);
    }

    try {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      final games = <Game>[];

      for (final entry in json.entries) {
        final gameData = entry.value as Map<String, dynamic>;

        final appName = gameData['app_name'] as String? ?? entry.key;
        final title = gameData['title'] as String? ?? appName;
        final installPath = gameData['install_path'] as String?;
        final installSize = gameData['install_size'] as int? ?? 0;

        if (installPath != null) {
          _logger.debug('Found Epic game: $title ($appName) at $installPath', tag: 'Heroic');
          games.add(
            Game(
              id: 'heroic_epic_$appName',
              title: title,
              source: GameSource.heroic,
              installPath: installPath,
              sizeBytes: installSize, // Legendary provides size directly!
            ),
          );
        } else {
          _logger.debug('Skipping Epic game $title: install_path is null', tag: 'Heroic');
        }
      }

      _logger.info('Found ${games.length} Epic games', tag: 'Heroic');
      return Right(games);
    } catch (e, s) {
      _logger.error('Failed to parse installed.json', error: e, stackTrace: s, tag: 'Heroic');
      return Left(ParseFailure('Failed to parse Epic games: $e', s));
    }
  }

  /// Get all installed GOG games
  Future<Result<List<Game>>> getGogGames() async {
    final cachePath = _platform.gogLibraryCachePath;

    if (cachePath == null) {
      _logger.debug('GOG cache path is null (Heroic likely not configured)', tag: 'Heroic');
      return const Right([]); // GOG is optional
    }

    final file = File(cachePath);
    if (!file.existsSync()) {
      _logger.info('No GOG library cache found at $cachePath', tag: 'Heroic');
      return const Right([]);
    }

    try {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      final games = <Game>[];
      final library = json['library'] as List<dynamic>? ?? [];

      _logger.debug('GOG library has ${library.length} entries', tag: 'Heroic');

      for (final item in library) {
        final gameData = item as Map<String, dynamic>;
        final isInstalled = gameData['is_installed'] as bool? ?? false;

        if (isInstalled) {
          final appName = gameData['app_name'] as String? ?? '';
          final title = gameData['title'] as String? ?? appName;
          final installPath = gameData['install_path'] as String?;

          if (installPath != null && installPath.isNotEmpty) {
            _logger.debug('Found GOG game: $title at $installPath', tag: 'Heroic');
            games.add(
              Game(
                id: 'heroic_gog_$appName',
                title: title,
                source: GameSource.heroic,
                installPath: installPath,
                sizeBytes: 0, // GOG doesn't provide size, needs calculation
              ),
            );
          } else {
            _logger.debug('Skipping installed GOG game $title: path is empty', tag: 'Heroic');
          }
        }
      }

      _logger.info('Found ${games.length} GOG games', tag: 'Heroic');
      return Right(games);
    } catch (e, s) {
      _logger.error('Failed to parse GOG library', error: e, stackTrace: s, tag: 'Heroic');
      return Left(ParseFailure('Failed to parse GOG games: $e', s));
    }
  }

  /// Get all Heroic games (Epic + GOG combined)
  Future<Result<List<Game>>> getAllGames() async {
    final epicResult = await getEpicGames();
    final gogResult = await getGogGames();

    // Combine results, returning any errors
    return epicResult.fold(
      (failure) => Left(failure),
      (epicGames) => gogResult.fold(
        (failure) => Right(epicGames), // Still return Epic games if GOG fails
        (gogGames) => Right([...epicGames, ...gogGames]),
      ),
    );
  }
}
