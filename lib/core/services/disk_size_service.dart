import 'dart:io';

import 'package:game_size_manager/core/logging/logger_service.dart';

/// Service for calculating directory sizes
class DiskSizeService {
  DiskSizeService._();
  static final DiskSizeService instance = DiskSizeService._();

  final _logger = LoggerService.instance;

  /// Calculate total size of a directory recursively
  /// Returns size in bytes
  Future<int> calculateDirectorySize(String path) async {
    final dir = Directory(path);
    if (!dir.existsSync()) {
      _logger.warning('Directory does not exist: $path', tag: 'DiskSize');
      return 0;
    }

    int totalSize = 0;

    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            totalSize += await entity.length();
          } catch (e) {
            // Log skipped files (permissions, etc.)
            _logger.debug('Skipped file (permission denied): ${entity.path}', tag: 'DiskSize');
          }
        }
      }
    } catch (e, s) {
      _logger.error('Error calculating size for: $path', error: e, stackTrace: s);
    }

    return totalSize;
  }

  /// Calculate sizes for multiple directories in parallel
  Future<Map<String, int>> calculateMultipleDirectorySizes(List<String> paths) async {
    final results = await Future.wait(
      paths.map((path) async {
        final size = await calculateDirectorySize(path);
        return MapEntry(path, size);
      }),
    );
    return Map.fromEntries(results);
  }

  /// Get disk usage info for a path
  /// Returns (usedBytes, totalBytes)
  Future<(int, int)?> getDiskUsage(String path) async {
    try {
      // On Linux, we can use 'df' command
      if (Platform.isLinux) {
        final result = await Process.run('df', ['-B1', path]);
        if (result.exitCode == 0) {
          final lines = (result.stdout as String).split('\n');
          if (lines.length >= 2) {
            final parts = lines[1].split(RegExp(r'\s+'));
            if (parts.length >= 4) {
              final total = int.tryParse(parts[1]) ?? 0;
              final used = int.tryParse(parts[2]) ?? 0;
              return (used, total);
            }
          }
        }
      }

      // Fallback for macOS - use -k for kilobytes
      if (Platform.isMacOS) {
        final result = await Process.run('df', ['-k', path]);
        if (result.exitCode == 0) {
          final lines = (result.stdout as String).trim().split('\n');
          if (lines.length >= 2) {
            final parts = lines[1].split(RegExp(r'\s+'));
            if (parts.length >= 4) {
              // macOS df -k output columns: Filesystem 1024-blocks Used Avail ...
              final totalKb = int.tryParse(parts[1]) ?? 0;
              final usedKb = int.tryParse(parts[2]) ?? 0;
              return (usedKb * 1024, totalKb * 1024);
            }
          }
        }
      }
    } catch (e, s) {
      _logger.error('Error getting disk usage', error: e, stackTrace: s);
    }

    return null;
  }
}
