import 'package:flutter/material.dart';

import 'package:game_size_manager/core/theme/game_colors.dart';

/// Get color based on usage percentage
/// Uses centralized GameColors for consistency
Color getColorForUsage(double percent) {
  return GameColors.forStoragePercent(percent);
}
