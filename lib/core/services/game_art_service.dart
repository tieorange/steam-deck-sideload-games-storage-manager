import 'dart:io';

import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/platform/platform_service.dart';

/// Service to find local game artwork (icons, covers, banners)
class GameArtService {
  GameArtService({PlatformService? platform, LoggerService? logger})
    : _platform = platform ?? PlatformService.instance;
  // _logger = logger ?? LoggerService.instance;

  final PlatformService _platform;
  // final LoggerService _logger; // Logger not currently used but available for future debugging

  static final GameArtService instance = GameArtService();

  /// Find best available art for Steam game
  /// Priority: library_600x900 (Cover) -> header (Banner) -> icon
  String? getSteamArtPath(String appId) {
    final cachePath = _platform.steamLibraryCachePath;
    if (!Directory(cachePath).existsSync()) return null;

    // Check for vertical cover (best for details page)
    final coverPath = '$cachePath/${appId}_library_600x900.jpg';
    if (File(coverPath).existsSync()) return coverPath;

    // Check for header/banner
    final headerPath = '$cachePath/${appId}_header.jpg';
    if (File(headerPath).existsSync()) return headerPath;

    // Check for icon
    final iconPath = '$cachePath/${appId}_icon.jpg';
    if (File(iconPath).existsSync()) return iconPath;

    return null;
  }

  /// Find best available art for Heroic game (Epic/GOG)
  String? getHeroicArtPath(String appName) {
    final cachePath = _platform.heroicImagesCachePath;
    if (cachePath == null) return null;

    // Heroic typically stores images as {appName}.jpg or {appName}.png

    // Try .jpg
    final jpgPath = '$cachePath/$appName.jpg';
    if (File(jpgPath).existsSync()) return jpgPath;

    // Try .png
    final pngPath = '$cachePath/$appName.png';
    if (File(pngPath).existsSync()) return pngPath;

    // Try with original casing if appName was manipulated (Heroic usually uses internal app_name)

    return null;
  }

  /// Find best available art for Lutris game
  /// Priority: Coverart -> Banner
  String? getLutrisArtPath(String slug) {
    if (slug.isEmpty) return null;

    // Check Cover Art (Vertical)
    final coverDir = _platform.lutrisCoverartPath;
    if (coverDir != null) {
      final coverPath = '$coverDir/$slug.jpg';
      if (File(coverPath).existsSync()) return coverPath;
    }

    // Check Banners (Horizontal)
    final bannerDir = _platform.lutrisBannersPath;
    if (bannerDir != null) {
      final bannerPath = '$bannerDir/$slug.jpg';
      if (File(bannerPath).existsSync()) return bannerPath;
    }

    return null;
  }
}
