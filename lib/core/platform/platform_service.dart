import 'dart:io';

import 'package:game_size_manager/core/logging/logger_service.dart';

/// Platform service for detecting launchers and file paths
/// Handles both Flatpak and standard installation paths
class PlatformService {
  PlatformService._();
  static final PlatformService instance = PlatformService._();

  final _logger = LoggerService.instance;

  /// Home directory
  String get homeDir => Platform.environment['HOME'] ?? '/home/deck';
  String get homePath => homeDir; // Alias for consistency

  // ============================================
  // Heroic Games Launcher Paths
  // ============================================

  String get heroicFlatpakPath => '$homeDir/.var/app/com.heroicgameslauncher.hgl/config';

  String get heroicStandardPath => '$homeDir/.config/heroic';

  /// Returns Heroic config path (Flatpak first, then standard)
  String? get heroicConfigPath {
    _logger.info('============ HEROIC PATH DETECTION ============', tag: 'Platform');
    _logger.info('homeDir: $homeDir', tag: 'Platform');

    // Flatpak: check ~/.var/app/com.heroicgameslauncher.hgl/config/heroic
    final flatpakHeroicConfig = '$homeDir/.var/app/com.heroicgameslauncher.hgl/config/heroic';
    _logger.info('Checking Flatpak path: $flatpakHeroicConfig', tag: 'Platform');
    final flatpakExists = Directory(flatpakHeroicConfig).existsSync();
    _logger.info('Flatpak path exists: $flatpakExists', tag: 'Platform');

    if (flatpakExists) {
      _logger.info('✓ Found Heroic Flatpak config at: $flatpakHeroicConfig', tag: 'Platform');
      return flatpakHeroicConfig;
    }

    _logger.info('Checking standard path: $heroicStandardPath', tag: 'Platform');
    final standardExists = Directory(heroicStandardPath).existsSync();
    _logger.info('Standard path exists: $standardExists', tag: 'Platform');

    if (standardExists) {
      _logger.info('✓ Found Heroic standard config at: $heroicStandardPath', tag: 'Platform');
      return heroicStandardPath;
    }

    _logger.warning('✗ Heroic not found in either location', tag: 'Platform');
    return null;
  }

  /// Path to Legendary's installed.json (Epic games)
  String? get legendaryInstalledJsonPath {
    _logger.info('============ LEGENDARY PATH DETECTION ============', tag: 'Platform');
    final heroicPath = heroicConfigPath;

    if (heroicPath == null) {
      _logger.warning('Heroic config path is null, cannot find legendary', tag: 'Platform');
      return null;
    }

    _logger.info('Using heroicPath: $heroicPath', tag: 'Platform');

    // Try multiple possible paths for installed.json
    // Heroic Flatpak uses a nested structure: config/heroic/legendaryConfig/legendary/
    final possiblePaths = [
      '$heroicPath/legendaryConfig/legendary/installed.json', // Flatpak new structure
      '$homeDir/.var/app/com.heroicgameslauncher.hgl/config/legendary/installed.json', // Flatpak alternative
      '$homeDir/.config/legendary/installed.json', // Standalone legendary
    ];

    _logger.info('Checking ${possiblePaths.length} possible paths...', tag: 'Platform');
    for (final path in possiblePaths) {
      _logger.info('Checking: $path', tag: 'Platform');
      final exists = File(path).existsSync();
      _logger.info('  Exists: $exists', tag: 'Platform');

      if (exists) {
        _logger.info('✓ Found Legendary installed.json at: $path', tag: 'Platform');
        return path;
      }
    }

    _logger.warning('✗ Legendary installed.json not found in any location', tag: 'Platform');
    return null; // Return null if not found - will treat as no Epic games installed
  }

  /// Path to GOG library cache
  String? get gogLibraryCachePath {
    final heroicPath = heroicConfigPath;
    if (heroicPath == null) return null;
    return '$heroicPath/store_cache/gog_library.json';
  }

  bool get isHeroicInstalled => heroicConfigPath != null;

  // ============================================
  // OpenGameInstaller (OGI) Paths
  // ============================================

  String get ogiLibraryPath => '$homeDir/.local/share/OpenGameInstaller/library';

  bool get isOgiInstalled => Directory(ogiLibraryPath).existsSync();

  // ============================================
  // Lutris Paths
  // ============================================

  String get lutrisFlatpakDbPath => '$homeDir/.var/app/net.lutris.Lutris/data/lutris/pga.db';

  String get lutrisStandardDbPath => '$homeDir/.local/share/lutris/pga.db';

  /// Returns Lutris database path (Flatpak first, then standard)
  String? get lutrisDbPath {
    if (File(lutrisFlatpakDbPath).existsSync()) {
      return lutrisFlatpakDbPath;
    }
    if (File(lutrisStandardDbPath).existsSync()) {
      return lutrisStandardDbPath;
    }
    return null;
  }

  bool get isLutrisInstalled => lutrisDbPath != null;

  // ============================================
  // Steam Paths
  // ============================================

  String get steamAppsPath => '$homeDir/.local/share/Steam/steamapps';

  String get steamUserDataPath => '$homeDir/.local/share/Steam/userdata';

  String get libraryFoldersVdfPath => '$steamAppsPath/libraryfolders.vdf';

  bool get isSteamInstalled => Directory(steamAppsPath).existsSync();

  /// Get all Steam library paths (parses libraryfolders.vdf)
  List<String> get allSteamLibraryPaths {
    final paths = <String>[steamAppsPath];

    try {
      final vdfFile = File(libraryFoldersVdfPath);
      if (!vdfFile.existsSync()) return paths;

      final content = vdfFile.readAsStringSync();
      // Simple regex to find "path" entries in VDF
      final pathRegex = RegExp(r'"path"\s+"([^"]+)"');
      for (final match in pathRegex.allMatches(content)) {
        final path = match.group(1);
        if (path != null) {
          final steamappsPath = '$path/steamapps';
          if (Directory(steamappsPath).existsSync() && !paths.contains(steamappsPath)) {
            paths.add(steamappsPath);
          }
        }
      }
    } catch (e, s) {
      _logger.error('Failed to parse libraryfolders.vdf', error: e, stackTrace: s);
    }

    return paths;
  }

  // ============================================
  // Utility Methods
  // ============================================

  /// Check if running on Steam Deck (heuristic)
  bool get isSteamDeck {
    // Steam Deck typically has 'deck' as the username
    return homeDir.endsWith('/deck') || Platform.environment['SteamDeck'] == '1';
  }

  /// Check if running on macOS (for development with mock data)
  bool get isMacOS => Platform.isMacOS;

  /// Check if running on Linux
  bool get isLinux => Platform.isLinux;

  /// Should use mock data (macOS development mode)
  bool get shouldUseMockData {
    if (!isMacOS) return false;

    // Allow real testing if test directory exists
    final testDir = Directory('$homeDir/GameSizeTest');
    return !testDir.existsSync();
  }

  /// Log platform info for debugging
  void logPlatformInfo() {
    _logger.info('Platform: ${Platform.operatingSystem}', tag: 'Platform');
    _logger.info('Home: $homeDir', tag: 'Platform');
    _logger.info('Heroic installed: $isHeroicInstalled', tag: 'Platform');
    _logger.info('OGI installed: $isOgiInstalled', tag: 'Platform');
    _logger.info('Lutris installed: $isLutrisInstalled', tag: 'Platform');
    _logger.info('Steam installed: $isSteamInstalled', tag: 'Platform');
    _logger.info('Steam Deck: $isSteamDeck', tag: 'Platform');
    _logger.info('Using mock data: $shouldUseMockData', tag: 'Platform');
  }
}
