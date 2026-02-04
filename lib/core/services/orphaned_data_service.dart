import 'dart:io';

import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/platform/platform_service.dart';
import 'package:game_size_manager/core/services/disk_size_service.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
import 'package:game_size_manager/core/constants.dart';

/// Represents orphaned data that can be cleaned up
class OrphanedData {
  final String path;
  final String label;
  final OrphanedDataType type;
  final int sizeBytes;

  const OrphanedData({
    required this.path,
    required this.label,
    required this.type,
    required this.sizeBytes,
  });
}

enum OrphanedDataType {
  compatData('Compat Data (Proton Prefix)'),
  shaderCache('Shader Cache');

  const OrphanedDataType(this.label);
  final String label;
}

/// Service for detecting orphaned game data (shader caches, compat data)
/// that belongs to games no longer installed.
class OrphanedDataService {
  final PlatformService _platform;
  final DiskSizeService _diskSize;
  final LoggerService _logger;

  OrphanedDataService({
    PlatformService? platform,
    DiskSizeService? diskSize,
    LoggerService? logger,
  }) : _platform = platform ?? PlatformService.instance,
       _diskSize = diskSize ?? DiskSizeService.instance,
       _logger = logger ?? LoggerService.instance;

  /// Scan for orphaned compat data and shader caches.
  /// [installedGames] is the list of currently installed games.
  Future<List<OrphanedData>> scan(List<Game> installedGames) async {
    final orphaned = <OrphanedData>[];

    // Get set of installed Steam app IDs
    final installedAppIds = installedGames
        .where((g) => g.source == GameSource.steam)
        .map((g) => g.id.replaceAll('steam_', ''))
        .toSet();

    _logger.info(
      'Scanning for orphaned data. ${installedAppIds.length} Steam games installed.',
      tag: 'OrphanedData',
    );

    // Scan compatdata directories
    final compatDataBase = '${_platform.homeDir}/.local/share/Steam/steamapps/compatdata';
    orphaned.addAll(await _scanDirectory(
      compatDataBase,
      installedAppIds,
      OrphanedDataType.compatData,
    ));

    // Scan shadercache directories
    final shaderCacheBase = '${_platform.homeDir}/.local/share/Steam/steamapps/shadercache';
    orphaned.addAll(await _scanDirectory(
      shaderCacheBase,
      installedAppIds,
      OrphanedDataType.shaderCache,
    ));

    // Sort by size descending
    orphaned.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));

    _logger.info(
      'Found ${orphaned.length} orphaned entries',
      tag: 'OrphanedData',
    );

    return orphaned;
  }

  Future<List<OrphanedData>> _scanDirectory(
    String basePath,
    Set<String> installedAppIds,
    OrphanedDataType type,
  ) async {
    final results = <OrphanedData>[];
    final baseDir = Directory(basePath);

    if (!await baseDir.exists()) return results;

    try {
      await for (final entity in baseDir.list()) {
        if (entity is Directory) {
          final dirName = entity.path.split('/').last;
          // Skip non-numeric directories and small system entries (like 0)
          if (int.tryParse(dirName) == null || dirName == '0') continue;

          if (!installedAppIds.contains(dirName)) {
            final size = await _diskSize.calculateDirectorySize(entity.path);
            if (size > 0) {
              results.add(OrphanedData(
                path: entity.path,
                label: 'AppID $dirName',
                type: type,
                sizeBytes: size,
              ));
            }
          }
        }
      }
    } catch (e) {
      _logger.warning('Failed to scan $basePath: $e', tag: 'OrphanedData');
    }

    return results;
  }

  /// Delete orphaned data entries
  Future<int> cleanup(List<OrphanedData> items) async {
    int freedBytes = 0;

    for (final item in items) {
      try {
        final dir = Directory(item.path);
        if (await dir.exists()) {
          await dir.delete(recursive: true);
          freedBytes += item.sizeBytes;
          _logger.info('Deleted orphaned: ${item.path}', tag: 'OrphanedData');
        }
      } catch (e) {
        _logger.warning('Failed to delete ${item.path}: $e', tag: 'OrphanedData');
      }
    }

    return freedBytes;
  }
}
