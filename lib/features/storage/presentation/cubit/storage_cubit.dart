import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_size_manager/core/services/disk_size_service.dart';
import 'package:game_size_manager/core/platform/platform_service.dart';
import 'package:game_size_manager/features/storage/presentation/cubit/storage_state.dart';

class StorageCubit extends Cubit<StorageState> {
  StorageCubit(
    this._diskSizeService,
    this._platformService,
  ) : super(const StorageState.initial());

  final DiskSizeService _diskSizeService;
  final PlatformService _platformService;

  Future<void> loadStorageInfo() async {
    emit(const StorageState.loading());

    try {
      final drives = <StorageDrive>[];
      int totalBytes = 0;
      int usedBytes = 0;

      // Check Home/Root
      final homePath = _platformService.homePath;
      final homeUsage = await _diskSizeService.getDiskUsage(homePath);
      
      if (homeUsage != null) {
        final (used, total) = homeUsage;
        drives.add(StorageDrive(
          path: homePath, 
          label: 'Internal Storage', 
          totalBytes: total, 
          usedBytes: used, 
          isRemovable: false,
        ));
        totalBytes += total;
        usedBytes += used;
      }

      // Check SD Card (Common mount point on Deck)
      // Note: This is a simplification. Real implementation would list mounts.
      final sdCardPath = '/run/media/mmcblk0p1'; 
      final sdUsage = await _diskSizeService.getDiskUsage(sdCardPath);

      if (sdUsage != null) {
        final (used, total) = sdUsage;
        drives.add(StorageDrive(
          path: sdCardPath, 
          label: 'SD Card', 
          totalBytes: total, 
          usedBytes: used, 
          isRemovable: true,
        ));
      }

      emit(StorageState.loaded(
        totalBytes: totalBytes,
        usedBytes: usedBytes,
        freeBytes: totalBytes - usedBytes,
        drives: drives,
      ));
    } catch (e) {
      emit(StorageState.error(e.toString()));
    }
  }
}
