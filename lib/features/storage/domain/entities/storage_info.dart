import 'package:freezed_annotation/freezed_annotation.dart';

part 'storage_info.freezed.dart';
part 'storage_info.g.dart';

/// Storage information for a drive/partition
@freezed
class StorageInfo with _$StorageInfo {
  const factory StorageInfo({
    /// Path to the storage location
    required String path,
    
    /// Used space in bytes
    required int usedBytes,
    
    /// Total space in bytes
    required int totalBytes,
    
    /// Label (e.g., "Internal SSD", "SD Card")
    String? label,
  }) = _StorageInfo;
  
  factory StorageInfo.fromJson(Map<String, dynamic> json) => 
    _$StorageInfoFromJson(json);
}

/// Extension methods for StorageInfo
extension StorageInfoExtensions on StorageInfo {
  /// Free space in bytes
  int get freeBytes => totalBytes - usedBytes;
  
  /// Usage percentage (0-100)
  double get usagePercent => 
    totalBytes > 0 ? (usedBytes / totalBytes) * 100 : 0;
  
  /// Whether storage is in warning state (>70%)
  bool get isWarning => usagePercent >= 70 && usagePercent < 90;
  
  /// Whether storage is in critical state (>90%)
  bool get isCritical => usagePercent >= 90;
}
