import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/platform/platform_service.dart';
import 'package:game_size_manager/core/services/disk_size_service.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
import 'package:game_size_manager/core/constants.dart';

/// Represents orphaned data that can be cleaned up
class OrphanedData {
  final String path;
  final String appId;
  final String gameName;
  final OrphanedDataType type;
  final int sizeBytes;
  final bool isNonSteamShortcut;
  final String libraryPath;
  final bool isSymlink;

  const OrphanedData({
    required this.path,
    required this.appId,
    required this.gameName,
    required this.type,
    required this.sizeBytes,
    required this.isNonSteamShortcut,
    required this.libraryPath,
    this.isSymlink = false,
  });

  /// Display label combining game name and type info
  String get label {
    if (gameName.isNotEmpty) return gameName;
    if (isNonSteamShortcut) return 'Non-Steam Shortcut ($appId)';
    return 'AppID $appId';
  }

  /// Whether this is compatdata (contains save files that may be lost)
  bool get hasSaveDataRisk => type == OrphanedDataType.compatData;
}

enum OrphanedDataType {
  compatData('Proton Prefix (compatdata)'),
  shaderCache('Shader Cache');

  const OrphanedDataType(this.label);
  final String label;
}

/// Result of a cleanup operation
class CleanupResult {
  final int freedBytes;
  final int successCount;
  final int failureCount;
  final List<String> errors;

  const CleanupResult({
    required this.freedBytes,
    required this.successCount,
    required this.failureCount,
    required this.errors,
  });
}

/// Service for detecting orphaned game data (shader caches, compat data)
/// that belongs to games no longer installed.
///
/// Scans all Steam library folders (internal + SD card) for compatdata and
/// shadercache directories that don't correspond to any installed game.
/// Resolves game names from appmanifest files when possible.
class OrphanedDataService {
  final PlatformService _platform;
  final DiskSizeService _diskSize;
  final LoggerService _logger;

  /// Cache of appId -> game name resolved from manifests
  final Map<String, String> _nameCache = {};

  OrphanedDataService({
    PlatformService? platform,
    DiskSizeService? diskSize,
    LoggerService? logger,
  }) : _platform = platform ?? PlatformService.instance,
       _diskSize = diskSize ?? DiskSizeService.instance,
       _logger = logger ?? LoggerService.instance;

  /// Scan for orphaned compat data and shader caches across all Steam
  /// library folders. [installedGames] is the list of currently known games.
  ///
  /// The scan checks all library paths from libraryfolders.vdf, which
  /// includes SD card and any other configured library folders.
  Future<List<OrphanedData>> scan(List<Game> installedGames) async {
    final orphaned = <OrphanedData>[];

    // Build set of ALL known installed app IDs across all sources.
    // Steam games use numeric IDs; non-Steam shortcuts also create
    // compatdata/shadercache with their own numeric IDs.
    final installedSteamAppIds = <String>{};
    for (final game in installedGames) {
      if (game.source == GameSource.steam) {
        installedSteamAppIds.add(game.id.replaceAll('steam_', ''));
      }
    }

    // Pre-populate name cache from appmanifest files
    await _buildNameCache();

    final libraryPaths = _platform.allSteamLibraryPaths;

    _logger.info(
      'Scanning for orphaned data. '
      '${installedSteamAppIds.length} Steam games installed, '
      '${libraryPaths.length} library path(s) to scan.',
      tag: 'OrphanedData',
    );

    // Also collect IDs of games that have appmanifest files (definitively installed)
    final manifestAppIds = await _getInstalledAppIdsFromManifests(libraryPaths);
    final allInstalledIds = {...installedSteamAppIds, ...manifestAppIds};

    // Scan each library path
    for (final libPath in libraryPaths) {
      final compatDataBase = '$libPath/compatdata';
      final shaderCacheBase = '$libPath/shadercache';

      orphaned.addAll(await _scanDirectory(
        compatDataBase,
        allInstalledIds,
        OrphanedDataType.compatData,
        libPath,
      ));

      orphaned.addAll(await _scanDirectory(
        shaderCacheBase,
        allInstalledIds,
        OrphanedDataType.shaderCache,
        libPath,
      ));
    }

    // Sort by size descending
    orphaned.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));

    final totalSize = orphaned.fold<int>(0, (sum, e) => sum + e.sizeBytes);
    _logger.info(
      'Found ${orphaned.length} orphaned entries '
      '(${(totalSize / 1024 / 1024).toStringAsFixed(1)} MB)',
      tag: 'OrphanedData',
    );

    return orphaned;
  }

  /// Scan a single directory (compatdata or shadercache) for orphaned entries.
  Future<List<OrphanedData>> _scanDirectory(
    String basePath,
    Set<String> installedAppIds,
    OrphanedDataType type,
    String libraryPath,
  ) async {
    final results = <OrphanedData>[];
    final baseDir = Directory(basePath);

    if (!await baseDir.exists()) return results;

    try {
      final entries = <Directory>[];
      await for (final entity in baseDir.list()) {
        if (entity is Directory) {
          final dirName = path.basename(entity.path);
          // Skip non-numeric directories and system entry '0'
          if (int.tryParse(dirName) == null || dirName == '0') continue;

          if (!installedAppIds.contains(dirName)) {
            entries.add(entity);
          }
        }
      }

      // Calculate sizes in parallel batches of 8 for performance
      const batchSize = 8;
      for (var i = 0; i < entries.length; i += batchSize) {
        final batch = entries.skip(i).take(batchSize);
        final futures = batch.map((dir) async {
          final dirName = path.basename(dir.path);
          final isSymlink = await FileSystemEntity.isLink(dir.path);
          final isNonSteam = dirName.length > 10;
          final size = isSymlink
              ? 0
              : await _diskSize.calculateDirectorySize(dir.path);

          // Skip empty dirs and symlinks (managed by CryoUtilities etc.)
          if (size <= 0 && !isSymlink) return null;

          return OrphanedData(
            path: dir.path,
            appId: dirName,
            gameName: _nameCache[dirName] ?? '',
            type: type,
            sizeBytes: size,
            isNonSteamShortcut: isNonSteam,
            libraryPath: libraryPath,
            isSymlink: isSymlink,
          );
        });

        final results_ = await Future.wait(futures);
        results.addAll(results_.whereType<OrphanedData>());
      }
    } catch (e) {
      _logger.warning('Failed to scan $basePath: $e', tag: 'OrphanedData');
    }

    return results;
  }

  /// Get app IDs that have appmanifest files (definitively installed via Steam).
  Future<Set<String>> _getInstalledAppIdsFromManifests(
    List<String> libraryPaths,
  ) async {
    final ids = <String>{};
    final manifestRegex = RegExp(r'appmanifest_(\d+)\.acf');

    for (final libPath in libraryPaths) {
      final dir = Directory(libPath);
      if (!await dir.exists()) continue;

      try {
        await for (final entity in dir.list()) {
          if (entity is File) {
            final match = manifestRegex.firstMatch(path.basename(entity.path));
            if (match != null) {
              ids.add(match.group(1)!);
            }
          }
        }
      } catch (e) {
        _logger.warning(
          'Failed to list manifests in $libPath: $e',
          tag: 'OrphanedData',
        );
      }
    }

    return ids;
  }

  /// Build a cache of appId -> game name from appmanifest_*.acf files.
  /// These files contain a "name" field with the game title.
  Future<void> _buildNameCache() async {
    _nameCache.clear();
    final manifestRegex = RegExp(r'appmanifest_(\d+)\.acf');
    final nameRegex = RegExp(r'"name"\s+"([^"]+)"');

    for (final libPath in _platform.allSteamLibraryPaths) {
      final dir = Directory(libPath);
      if (!await dir.exists()) continue;

      try {
        await for (final entity in dir.list()) {
          if (entity is File) {
            final fileName = path.basename(entity.path);
            final match = manifestRegex.firstMatch(fileName);
            if (match != null) {
              final appId = match.group(1)!;
              try {
                final content = await entity.readAsString();
                final nameMatch = nameRegex.firstMatch(content);
                if (nameMatch != null) {
                  _nameCache[appId] = nameMatch.group(1)!;
                }
              } catch (_) {
                // Skip unreadable manifests
              }
            }
          }
        }
      } catch (e) {
        _logger.warning(
          'Failed to read manifests in $libPath: $e',
          tag: 'OrphanedData',
        );
      }
    }

    _logger.info(
      'Resolved ${_nameCache.length} game names from manifests',
      tag: 'OrphanedData',
    );
  }

  /// Delete selected orphaned data entries.
  /// Returns a [CleanupResult] with details about what was freed.
  Future<CleanupResult> cleanup(List<OrphanedData> items) async {
    int freedBytes = 0;
    int successCount = 0;
    int failureCount = 0;
    final errors = <String>[];

    for (final item in items) {
      try {
        final dir = Directory(item.path);
        if (await dir.exists()) {
          await dir.delete(recursive: true);
          freedBytes += item.sizeBytes;
          successCount++;
          _logger.info(
            'Deleted orphaned ${item.type.label}: ${item.label} '
            '(${item.path})',
            tag: 'OrphanedData',
          );
        }
      } catch (e) {
        failureCount++;
        errors.add('${item.label}: $e');
        _logger.warning(
          'Failed to delete ${item.path}: $e',
          tag: 'OrphanedData',
        );
      }
    }

    return CleanupResult(
      freedBytes: freedBytes,
      successCount: successCount,
      failureCount: failureCount,
      errors: errors,
    );
  }
}
