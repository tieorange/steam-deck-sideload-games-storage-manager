import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'package:game_size_manager/features/games/data/models/heroic_game_dto.dart'; // Add DTO import

import 'package:game_size_manager/core/services/game_art_service.dart';

import 'package:game_size_manager/core/error/failures.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/platform/platform_service.dart';
import 'package:game_size_manager/features/games/data/datasources/game_datasource.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// Data source for Heroic Games Launcher (Epic + GOG)
class HeroicDatasource implements GameDatasource {
  HeroicDatasource({
    PlatformService? platformService,
    LoggerService? logger,
    GameArtService? artService,
  }) : _platform = platformService ?? PlatformService.instance,
       _logger = logger ?? LoggerService.instance,
       _artService = artService ?? GameArtService.instance;

  final PlatformService _platform;
  final LoggerService _logger;
  final GameArtService _artService;

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
      // 1. Parse installed games
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      // 2. Parse library metadata to get art URLs (Heroic uses hashed URLs for filenames)
      final artUrls = await _getEpicArtUrls();
      _logger.debug('Loaded ${artUrls.length} art URLs from legendary_library.json', tag: 'Heroic');

      final games = <Game>[];

      for (final entry in json.entries) {
        final gameData = entry.value as Map<String, dynamic>;

        try {
          var dto = EpicGameDto.fromJson(gameData, entry.key);

          // Use the art URL if available to find the cached image
          final availableArtUrl = await _resolveBestArtUrl(dto.appName, artUrls);
          if (availableArtUrl != null) {
            // Pass the resolved URL to GameArtService so it can look up the file
            final iconPath = _artService.getHeroicArtPath(dto.appName, artUrl: availableArtUrl);
            if (iconPath != null) {
              dto = dto.copyWith(iconPath: iconPath);
            }
          }

          if (dto.installPath != null) {
            _logger.debug(
              'Found Epic game: ${dto.title ?? dto.appName} at ${dto.installPath}',
              tag: 'Heroic',
            );
            games.add(dto.toEntity());
          } else {
            _logger.debug('Skipping Epic game ${dto.title}: install_path is null', tag: 'Heroic');
          }
        } catch (e) {
          _logger.warning('Failed to parse Epic game entry: ${entry.key}', tag: 'Heroic');
        }
      }

      _logger.info('Found ${games.length} Epic games', tag: 'Heroic');
      return Right(games);
    } catch (e, s) {
      _logger.error('Failed to parse installed.json', error: e, stackTrace: s, tag: 'Heroic');
      return Left(ParseFailure('Failed to parse Epic games: $e', s));
    }
  }

  /// Checks the Heroic image cache to see which art URL (square, cover, box) is actually cached.
  /// Returns the URL that corresponds to an existing file, or the best candidate if none found.
  Future<String?> _resolveBestArtUrl(String appName, Map<String, List<String>> artMap) async {
    final urls = artMap[appName];
    if (urls == null || urls.isEmpty) return null;

    final cachePath = _platform.heroicImagesCachePath;
    if (cachePath == null) return urls.first; // No cache path, just return the first one

    // Check each URL to see if its hash exists in the cache
    for (final url in urls) {
      if (url.isEmpty) continue;

      try {
        // Heroic hashes the full URL with SHA256
        final hash = sha256.convert(utf8.encode(url)).toString();
        final file = File(p.join(cachePath, hash));

        if (file.existsSync()) {
          //_logger.debug('Found cached art for $appName: $url (hash: $hash)', tag: 'Heroic');
          return url;
        }
      } catch (e) {
        // Ignore hashing errors
      }
    }

    // If no cached file found, return the first one (usually art_square) as fallback
    return urls.first;
  }

  /// Reads legendary_library.json to get a map of appName -> List of candidate art URLs
  /// We return a list so we can check multiple options (square, cover, box)
  Future<Map<String, List<String>>> _getEpicArtUrls() async {
    try {
      final libPath = _platform.legendaryLibraryPath;
      if (libPath == null) return {};

      final file = File(libPath);
      if (!file.existsSync()) {
        _logger.warning('Legendary library cache not found at $libPath', tag: 'Heroic');
        return {};
      }

      final content = await file.readAsString();
      final json = jsonDecode(content);

      final artMap = <String, List<String>>{};
      List<dynamic> libraryList = [];

      // Heroic stores data in a 'library' key, but let's be robust
      if (json is Map<String, dynamic>) {
        if (json.containsKey('library') && json['library'] is List) {
          libraryList = json['library'] as List;
        }
      } else if (json is List) {
        libraryList = json;
      }

      for (final item in libraryList) {
        if (item is Map<String, dynamic>) {
          final appName = item['app_name'] as String?;
          if (appName == null) continue;

          final candidates = <String>[];

          // Prioritize square art as it looks best in grid
          if (item['art_square'] is String) candidates.add(item['art_square'] as String);
          if (item['art_cover'] is String) candidates.add(item['art_cover'] as String);
          if (item['box_art'] is String) candidates.add(item['box_art'] as String);

          if (candidates.isNotEmpty) {
            artMap[appName] = candidates;
          }
        }
      }

      return artMap;
    } catch (e) {
      _logger.warning('Failed to parse Legendary library for art URLs: $e', tag: 'Heroic');
      return {};
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

        try {
          var dto = GogGameDto.fromJson(gameData);

          final iconPath = _artService.getHeroicArtPath(dto.appName);
          if (iconPath != null) {
            dto = dto.copyWith(iconPath: iconPath);
          }

          if (dto.isInstalled) {
            if (dto.installPath != null && dto.installPath!.isNotEmpty) {
              _logger.debug(
                'Found GOG game: ${dto.title ?? dto.appName} at ${dto.installPath}',
                tag: 'Heroic',
              );
              games.add(dto.toEntity());
            } else {
              _logger.debug(
                'Skipping installed GOG game ${dto.title}: path is empty',
                tag: 'Heroic',
              );
            }
          }
        } catch (e) {
          _logger.warning('Failed to parse GOG game entry', tag: 'Heroic');
        }
      }

      _logger.info('Found ${games.length} GOG games', tag: 'Heroic');
      return Right(games);
    } catch (e, s) {
      _logger.error('Failed to parse GOG library', error: e, stackTrace: s, tag: 'Heroic');
      return Left(ParseFailure('Failed to parse GOG games: $e', s));
    }
  }

  @override
  Future<Result<List<Game>>> getGames() async {
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
