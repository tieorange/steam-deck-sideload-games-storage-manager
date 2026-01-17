import 'package:game_size_manager/core/constants.dart';

/// Extension to format bytes into human-readable sizes
extension SizeFormatter on int {
  /// Format bytes to human-readable string (e.g., "1.2 GB")
  String toHumanReadableSize() {
    if (this <= 0) return '0 B';
    
    int unitIndex = 0;
    double size = toDouble();
    
    while (size >= 1024 && unitIndex < AppConstants.sizeUnits.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    
    // Show 1 decimal for GB+, no decimals for smaller
    if (unitIndex >= 3) {
      return '${size.toStringAsFixed(1)} ${AppConstants.sizeUnits[unitIndex]}';
    } else {
      return '${size.toStringAsFixed(0)} ${AppConstants.sizeUnits[unitIndex]}';
    }
  }
  
  /// Format bytes to compact size (e.g., "1.2G")
  String toCompactSize() {
    if (this <= 0) return '0B';
    
    int unitIndex = 0;
    double size = toDouble();
    
    while (size >= 1024 && unitIndex < AppConstants.sizeUnits.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    
    final unitChar = AppConstants.sizeUnits[unitIndex][0];
    return '${size.toStringAsFixed(1)}$unitChar';
  }
}

/// Extension for nullable int sizes
extension NullableSizeFormatter on int? {
  String toHumanReadableSizeOrUnknown() {
    if (this == null) return 'Unknown';
    return this!.toHumanReadableSize();
  }
}
