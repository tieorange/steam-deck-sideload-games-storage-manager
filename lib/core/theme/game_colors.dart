import 'package:flutter/material.dart';
import 'package:game_size_manager/core/constants.dart';

/// Centralized color definitions for game sources and size indicators.
/// Eliminates duplicated _getSourceColor() / _getSizeColor() across widgets.
class GameColors {
  GameColors._();

  // Source colors
  static const steam = Color(0xFF1B2838);
  static const heroic = Color(0xFF7B2D8B);
  static const lutris = Color(0xFFFF6600);
  static const ogi = Color(0xFF2E7D32);

  /// Get color for a game source
  static Color forSource(GameSource source) {
    switch (source) {
      case GameSource.steam:
        return steam;
      case GameSource.heroic:
        return heroic;
      case GameSource.lutris:
        return lutris;
      case GameSource.ogi:
        return ogi;
    }
  }

  /// Get icon for a game source
  static IconData iconForSource(GameSource source) {
    switch (source) {
      case GameSource.steam:
        return Icons.cloud_outlined;
      case GameSource.heroic:
        return Icons.shield_outlined;
      case GameSource.lutris:
        return Icons.sports_esports_outlined;
      case GameSource.ogi:
        return Icons.download_outlined;
    }
  }

  /// Get display name for a game source
  static String nameForSource(GameSource source) {
    switch (source) {
      case GameSource.steam:
        return 'Steam';
      case GameSource.heroic:
        return 'Heroic';
      case GameSource.lutris:
        return 'Lutris';
      case GameSource.ogi:
        return 'OGI';
    }
  }

  /// Get color based on size in bytes (for size indicators)
  static Color forSize(int sizeBytes) {
    final gb = sizeBytes / (1024 * 1024 * 1024);
    if (gb >= 30) return Colors.red;
    if (gb >= 10) return Colors.orange;
    return Colors.green;
  }

  /// Get color for storage usage percentage
  static Color forStoragePercent(double percent) {
    if (percent >= AppConstants.storageCriticalThreshold) return Colors.red;
    if (percent >= AppConstants.storageWarningThreshold) return Colors.orange;
    return Colors.green;
  }
}
