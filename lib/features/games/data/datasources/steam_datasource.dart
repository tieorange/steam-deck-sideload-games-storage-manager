import 'dart:io';

import 'package:dartz/dartz.dart';

import 'package:game_size_manager/features/games/data/models/steam_game_dto.dart';

import 'package:game_size_manager/core/error/failures.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/platform/platform_service.dart';
import 'package:game_size_manager/features/games/data/datasources/game_datasource.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// Data source for Steam games
class SteamDatasource implements GameDatasource {
  SteamDatasource({PlatformService? platformService, LoggerService? logger})
    : _platform = platformService ?? PlatformService.instance,
      _logger = logger ?? LoggerService.instance;

  final PlatformService _platform;
  final LoggerService _logger;

  /// Get all installed Steam games from appmanifest files
  @override
  Future<Result<List<Game>>> getGames() async {
    if (!_platform.isSteamInstalled) {
      _logger.info('Steam not installed', tag: 'Steam');
      return const Right([]);
    }

    try {
      final games = <Game>[];
      final libraryPaths = _platform.allSteamLibraryPaths;
      _logger.info('Checking ${libraryPaths.length} Steam library folders', tag: 'Steam');

      for (final libraryPath in libraryPaths) {
        final dir = Directory(libraryPath);
        if (!dir.existsSync()) {
          _logger.warning('Steam library path not found: $libraryPath', tag: 'Steam');
          continue;
        }

        _logger.debug('Scanning Steam library: $libraryPath', tag: 'Steam');

        await for (final entity in dir.list()) {
          if (entity is File &&
              entity.path.contains('appmanifest_') &&
              entity.path.endsWith('.acf')) {
            try {
              final game = await _parseAppManifest(entity);
              if (game != null) {
                _logger.debug('Found Steam game: ${game.title} (ID: ${game.id})', tag: 'Steam');
                games.add(game);
              }
            } catch (e) {
              _logger.warning('Failed to parse (exception): ${entity.path}', tag: 'Steam');
            }
          }
        }
      }

      _logger.info('Found ${games.length} Steam games', tag: 'Steam');
      return Right(games);
    } catch (e, s) {
      _logger.error('Failed to read Steam library', error: e, stackTrace: s, tag: 'Steam');
      return Left(FileSystemFailure('Failed to read Steam library: $e', s));
    }
  }

  // ... existing methods

  /// Get Launch Options from localconfig.vdf
  Future<String?> _getLaunchOptions(String appId) async {
    try {
      final userdataDir = Directory(_platform.steamUserDataPath);
      if (!userdataDir.existsSync()) return null;

      // Iterate through all user directories (usually only one active user)
      final users = userdataDir.listSync().whereType<Directory>();
      if (users.isEmpty) return null;

      // Use the last modified one as heuristic for active user
      // Or just check all of them until we find the app config
      for (final userDir in users) {
        final localConfig = File('${userDir.path}/config/localconfig.vdf');
        if (localConfig.existsSync()) {
          final content = await localConfig.readAsString();
          // Complex regex to find nested structure:
          // "Software" -> "Valve" -> "Steam" -> "apps" -> "APPID" -> "LaunchOptions"
          // We'll try a simpler regex first targeting the specific app section
          // because full VDF parsing is heavy.

          // Pattern: "appid" { ... "LaunchOptions" "FLAGS" ... }
          // This is risky with Regex. Safer: find the app block start, then search forward for LaunchOptions

          final appBlockIndex = content.indexOf('"$appId"');
          if (appBlockIndex != -1) {
            // Limit search scope to avoid false positives (next 500 chars)
            final searchScope = content.substring(
              appBlockIndex,
              (appBlockIndex + 1000 < content.length) ? appBlockIndex + 1000 : content.length,
            );

            final match = RegExp(r'"LaunchOptions"\s+"([^"]*)"').firstMatch(searchScope);
            if (match != null) {
              return match.group(1);
            }
          }
        }
      }
    } catch (e) {
      _logger.warning('Failed to parse launch options for $appId: $e', tag: 'Steam');
    }
    return null;
  }

  /// Get Proton Version from CompatData
  Future<String?> _getProtonVersion(String appId) async {
    try {
      // Check compatdata folder for 'version' file (created by some Proton versions)
      final compatPath = '${_platform.steamAppsPath}/compatdata/$appId';
      final versionFile = File('$compatPath/version');

      if (versionFile.existsSync()) {
        final version = await versionFile.readAsString();
        return version.trim();
      }

      // Check config.vdf mapping if version file doesn't exist
      // This is complex, skipping for now to prioritize 'version' file which covers most cases
    } catch (e) {
      // ignore
    }
    return null;
  }

  /// Parse a single appmanifest_*.acf file
  Future<Game?> _parseAppManifest(File file) async {
    final content = await file.readAsString();

    // Simple VDF parsing for the fields we need
    final appId = _extractVdfValue(content, SteamGameDto.keyAppId);
    final name = _extractVdfValue(content, SteamGameDto.keyName);
    final installDir = _extractVdfValue(content, SteamGameDto.keyInstallDir);
    final sizeOnDisk = _extractVdfValue(content, SteamGameDto.keySizeOnDisk);

    if (appId == null || name == null || installDir == null) {
      return null;
    }

    try {
      final dto = SteamGameDto.fromVdfValues(appId, name, installDir, sizeOnDisk);

      // Get extra metadata
      final launchOptions = await _getLaunchOptions(appId);
      final protonVersion = await _getProtonVersion(appId);

      // Get full install path
      final steamappsDir = file.parent.path;

      return dto.toEntity(
        steamAppsPath: steamappsDir,
        launchOptions: launchOptions,
        protonVersion: protonVersion,
      );
    } catch (e) {
      return null;
    }
  }

  /// Extract a value from VDF format content
  /// VDF format example: "name"  "Elden Ring"
  String? _extractVdfValue(String content, String key) {
    // Match both tab and space as separators
    final regex = RegExp('"$key"\\s+"([^"]*)"', caseSensitive: false);
    final match = regex.firstMatch(content);
    return match?.group(1);
  }
}
