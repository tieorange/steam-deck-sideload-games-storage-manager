import 'package:freezed_annotation/freezed_annotation.dart';

part 'storage_state.freezed.dart';

@freezed
class StorageState with _$StorageState {
  const factory StorageState.initial() = _Initial;
  const factory StorageState.loading() = _Loading;
  const factory StorageState.loaded({
    required int totalBytes,
    required int usedBytes,
    required int freeBytes,
    required List<StorageDrive> drives,
  }) = _Loaded;
  const factory StorageState.error(String message) = _Error;
}

@freezed
class StorageDrive with _$StorageDrive {
  const factory StorageDrive({
    required String path,
    required String label,
    required int totalBytes,
    required int usedBytes,
    required bool isRemovable,
  }) = _StorageDrive;
}
