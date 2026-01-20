import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/platform/platform_service.dart';

/// Service to find local game artwork (icons, covers, banners)
/// Logs warnings for missing art (sent to Sentry as breadcrumbs)
class GameArtService {
  GameArtService({PlatformService? platform, LoggerService? logger})
    : _platform = platform ?? PlatformService.instance,
      _logger = logger ?? LoggerService.instance;

  final PlatformService _platform;
  final LoggerService _logger;

  static final GameArtService instance = GameArtService();

  static const _tag = 'GameArt';

  /// Find best available art for Steam game
  /// Priority: Custom Art (userdata/grid) -> Official Cover -> Official Banner -> Icon
  String? getSteamArtPath(String appId) {
    // 1. Check Custom Art (userdata/<id>/config/grid)
    // Steam Deck users often use SteamGridDB which puts art here
    final userDataPath = _platform.steamUserDataPath;
    if (Directory(userDataPath).existsSync()) {
      try {
        final userDirs = Directory(userDataPath).listSync().whereType<Directory>();
        for (final userDir in userDirs) {
          final gridPath = '${userDir.path}/config/grid';
          if (Directory(gridPath).existsSync()) {
            // Check for custom cover (usually [appId]p.png or [appId]p.jpg)
            final customCoverPng = '$gridPath/${appId}p.png';
            if (File(customCoverPng).existsSync()) {
              _logger.debug(
                'Found Steam custom cover (PNG) for $appId: $customCoverPng',
                tag: _tag,
              );
              return customCoverPng;
            }
            final customCoverJpg = '$gridPath/${appId}p.jpg';
            if (File(customCoverJpg).existsSync()) {
              _logger.debug(
                'Found Steam custom cover (JPG) for $appId: $customCoverJpg',
                tag: _tag,
              );
              return customCoverJpg;
            }

            // Check for custom banner/hero (usually [appId]_hero.png)
            final customHeroPng = '$gridPath/${appId}_hero.png';
            if (File(customHeroPng).existsSync()) {
              _logger.debug('Found Steam custom hero for $appId: $customHeroPng', tag: _tag);
              return customHeroPng;
            }
          }
        }
      } catch (e) {
        _logger.warning('Failed to scan Steam userdata for custom art: $e', tag: _tag);
      }
    }

    // 2. Check Official Library Cache (subdirectory per appId)
    final cachePath = _platform.steamLibraryCachePath;

    if (!Directory(cachePath).existsSync()) {
      _logger.warning('Steam library cache directory not found: $cachePath', tag: _tag);
      return null;
    }

    // Steam uses subdirectory per appId: librarycache/[appId]/library_600x900.jpg
    final appCachePath = '$cachePath/$appId';

    if (!Directory(appCachePath).existsSync()) {
      _logger.debug('Steam app cache not found for $appId', tag: _tag);
      return null;
    }

    // Check for vertical cover (best for details page)
    final coverPath = '$appCachePath/library_600x900.jpg';
    if (File(coverPath).existsSync()) {
      _logger.debug('Found Steam cover art for $appId: $coverPath', tag: _tag);
      return coverPath;
    }

    // Check for header/hero banner
    final heroPath = '$appCachePath/library_hero.jpg';
    if (File(heroPath).existsSync()) {
      _logger.debug('Found Steam hero art for $appId: $heroPath', tag: _tag);
      return heroPath;
    }

    // Check for logo
    final logoPath = '$appCachePath/logo.png';
    if (File(logoPath).existsSync()) {
      _logger.debug('Found Steam logo for $appId: $logoPath', tag: _tag);
      return logoPath;
    }

    _logger.warning(
      'No art found for Steam game $appId. Checked userdata/grid and library cache.',
      tag: _tag,
    );
    return null;
  }

  /// Find best available art for Heroic game (Epic/GOG)
  /// Can be called with appName (legacy) or with artUrl from library metadata
  String? getHeroicArtPath(String appName, {String? artUrl}) {
    final cachePath = _platform.heroicImagesCachePath;

    if (cachePath == null) {
      _logger.warning('Heroic images cache path not found', tag: _tag);
      return null;
    }

    final cacheDir = Directory(cachePath);
    if (!cacheDir.existsSync()) {
      _logger.warning('Heroic images cache directory not found: $cachePath', tag: _tag);
      return null;
    }

    // If we have an art URL, compute SHA256 hash (matching Heroic's caching algorithm)
    if (artUrl != null && artUrl.isNotEmpty && artUrl.startsWith('http')) {
      final artPath = getHeroicArtPathFromUrl(artUrl);
      if (artPath != null) {
        return artPath;
      }
    }

    // Try exact match by appName (legacy fallback)
    for (final ext in ['jpg', 'png', 'webp']) {
      final path = '$cachePath/$appName.$ext';
      if (File(path).existsSync()) {
        _logger.debug('Found Heroic art for $appName: $path', tag: _tag);
        return path;
      }
    }

    // Try scanning directory for files containing appName (case-insensitive)
    try {
      final lowerAppName = appName.toLowerCase();
      final files = cacheDir.listSync().whereType<File>().toList();

      for (final file in files) {
        final filename = file.path.split('/').last.toLowerCase();
        if (filename.contains(lowerAppName)) {
          _logger.debug('Found Heroic art (scan match) for $appName: ${file.path}', tag: _tag);
          return file.path;
        }
      }

      // Log summary for debugging
      _logger.warning(
        'No art found for Heroic game $appName. Cache has ${files.length} files.',
        tag: _tag,
      );
    } catch (e) {
      _logger.warning('Failed to scan Heroic cache for $appName: $e', tag: _tag);
    }

    return null;
  }

  /// Find cached art using a known art URL
  /// Heroic caches images using SHA256 hash of the URL as filename
  String? getHeroicArtPathFromUrl(String artUrl) {
    final cachePath = _platform.heroicImagesCachePath;
    if (cachePath == null) return null;

    try {
      // Heroic uses SHA256 hash of the URL as the cache filename
      final bytes = utf8.encode(artUrl);
      final digest = sha256.convert(bytes);
      final hashFilename = digest.toString();

      final cachedPath = '$cachePath/$hashFilename';
      if (File(cachedPath).existsSync()) {
        _logger.debug('Found Heroic art from URL hash: $cachedPath', tag: _tag);
        return cachedPath;
      }

      _logger.debug('Heroic art cache miss for URL: $artUrl (hash: $hashFilename)', tag: _tag);
    } catch (e) {
      _logger.warning('Failed to compute hash for Heroic art URL: $e', tag: _tag);
    }

    return null;
  }

  /// Find best available art for Lutris game
  /// Priority: Coverart -> Banner
  String? getLutrisArtPath(String slug) {
    if (slug.isEmpty) {
      _logger.warning('Cannot get Lutris art: empty slug provided', tag: _tag);
      return null;
    }

    // Check Cover Art (Vertical)
    final coverDir = _platform.lutrisCoverartPath;
    if (coverDir != null) {
      final coverPath = '$coverDir/$slug.jpg';
      if (File(coverPath).existsSync()) {
        _logger.debug('Found Lutris cover art for $slug: $coverPath', tag: _tag);
        return coverPath;
      }
    }

    // Check Banners (Horizontal)
    final bannerDir = _platform.lutrisBannersPath;
    if (bannerDir != null) {
      final bannerPath = '$bannerDir/$slug.jpg';
      if (File(bannerPath).existsSync()) {
        _logger.debug('Found Lutris banner for $slug: $bannerPath', tag: _tag);
        return bannerPath;
      }
    }

    _logger.warning(
      'No art found for Lutris game $slug. Coverart dir: $coverDir, Banners dir: $bannerDir',
      tag: _tag,
    );
    return null;
  }
}
