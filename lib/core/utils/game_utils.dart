import 'dart:io';
import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class GameUtils {
  static const _steamCompatDataPath = '.local/share/Steam/steamapps/compatdata';
  static const _steamShaderCachePath = '.local/share/Steam/steamapps/shadercache';

  /// Extract Steam AppID from game ID
  static String? getSteamAppId(Game game) {
    if (game.source != GameSource.steam) return null;
    return game.id.replaceAll('steam_', '');
  }

  /// Get ProtonDB URL for Steam games
  static String? getProtonDbUrl(Game game) {
    final appId = getSteamAppId(game);
    if (appId == null) return null;
    return 'https://www.protondb.com/app/$appId';
  }

  /// Get Steam Store URL
  static String? getSteamStoreUrl(Game game) {
    final appId = getSteamAppId(game);
    if (appId == null) return null;
    return 'https://store.steampowered.com/app/$appId';
  }

  /// Get PCGamingWiki URL
  static String getPcGamingWikiUrl(Game game) {
    final query = Uri.encodeComponent(game.title);
    return 'https://www.pcgamingwiki.com/w/index.php?search=$query';
  }

  /// Get CompatData path for Steam games
  static String? getCompatDataPath(Game game) {
    final appId = getSteamAppId(game);
    if (appId == null) return null;

    final home = Platform.environment['HOME'];
    if (home == null) return null;

    return '$home/$_steamCompatDataPath/$appId';
  }

  /// Get ShaderCache path for Steam games
  static String? getShaderCachePath(Game game) {
    final appId = getSteamAppId(game);
    if (appId == null) return null;

    final home = Platform.environment['HOME'];
    if (home == null) return null;

    return '$home/$_steamShaderCachePath/$appId';
  }

  /// Open URL in browser
  static Future<void> launchUrlString(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Open directory in file manager (Dolphin)
  static Future<void> openFileExplorer(String path) async {
    final dir = Directory(path);
    if (!dir.existsSync()) return;

    // Use xdg-open on Linux (Steam Deck)
    if (Platform.isLinux) {
      await Process.run('xdg-open', [path]);
    } else if (Platform.isMacOS) {
      await Process.run('open', [path]);
    } else if (Platform.isWindows) {
      await Process.run('explorer', [path]);
    }
  }

  /// Get directory size in bytes
  static Future<int> getDirectorySize(String path) async {
    final dir = Directory(path);
    if (!dir.existsSync()) return 0;

    try {
      // Use du -sb on Linux for fast size calculation
      if (Platform.isLinux) {
        final result = await Process.run('du', ['-sb', path]);
        if (result.exitCode == 0) {
          // Output format: "123456\t/path/to/dir"
          final output = (result.stdout as String).trim();
          final sizeStr = output.split(RegExp(r'\s+')).first;
          return int.tryParse(sizeStr) ?? 0;
        }
      }

      // Fallback for other platforms (recurisve walk)
      int totalSize = 0;
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}
