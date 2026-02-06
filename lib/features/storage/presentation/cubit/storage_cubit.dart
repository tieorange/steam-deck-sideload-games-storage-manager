import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_size_manager/core/services/disk_size_service.dart';
import 'package:game_size_manager/core/platform/platform_service.dart';
import 'package:game_size_manager/features/storage/presentation/cubit/storage_state.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';

class StorageCubit extends Cubit<StorageState> {
  StorageCubit(this._diskSizeService, this._platformService) : super(const StorageState.initial());

  final DiskSizeService _diskSizeService;
  final PlatformService _platformService;

  Future<void> loadStorageInfo() async {
    LoggerService.instance.info('Loading storage info...', tag: 'StorageCubit');
    emit(const StorageState.loading());

    try {
      final drives = <StorageDrive>[];
      final warnings = <String>[];
      int totalBytes = 0;
      int usedBytes = 0;

      // Check Home/Root
      final homePath = _platformService.homePath;
      final homeUsage = await _diskSizeService.getDiskUsage(homePath);

      if (homeUsage != null) {
        final (used, total) = homeUsage;
        drives.add(
          StorageDrive(
            path: homePath,
            label: 'Internal Storage',
            totalBytes: total,
            usedBytes: used,
            isRemovable: false,
          ),
        );
        totalBytes += total;
        usedBytes += used;
      } else {
        warnings.add('Failed to read internal storage info');
        LoggerService.instance.warning(
          'Failed to get disk usage for home path: $homePath',
          tag: 'StorageCubit',
        );
      }

      // Check Removable Drives
      final removablePaths = await _platformService.getRemovableDrives();

      for (final path in removablePaths) {
        final usage = await _diskSizeService.getDiskUsage(path);

        if (usage != null) {
          final (used, total) = usage;
          // Extract label from path (e.g. /run/media/deck/SDCard -> SDCard)
          final label = path.split(Platform.pathSeparator).last;

          drives.add(
            StorageDrive(
              path: path,
              label: label.isEmpty ? 'External Drive' : label,
              totalBytes: total,
              usedBytes: used,
              isRemovable: true,
            ),
          );

          // Should default behavior add external storage to total stats?
          // Usually yes for "Total System Storage" if they are used for games.
          // totalBytes += total;
          // usedBytes += used;
        } else {
          final label = path.split(Platform.pathSeparator).last;
          warnings.add('Failed to read external drive: $label');
          LoggerService.instance.warning(
            'Failed to get disk usage for removable path: $path',
            tag: 'StorageCubit',
          );
        }
      }

      LoggerService.instance.info(
        'Storage loaded: ${drives.length} drives (Internal + ${drives.length - 1} external)'
        '${warnings.isNotEmpty ? ', ${warnings.length} warning(s)' : ''}',
        tag: 'StorageCubit',
      );

      emit(
        StorageState.loaded(
          totalBytes: totalBytes,
          usedBytes: usedBytes,
          freeBytes: totalBytes - usedBytes,
          drives: drives,
          warnings: warnings,
        ),
      );
    } catch (e, stack) {
      LoggerService.instance.error(
        'Failed to load storage info',
        error: e,
        stackTrace: stack,
        tag: 'StorageCubit',
      );
      emit(StorageState.error(e.toString()));
    }
  }
}
