import 'package:flutter/material.dart';

/// Get color based on usage percentage
Color getColorForUsage(double percent) {
  if (percent > 0.9) return Colors.red;
  if (percent > 0.7) return Colors.orange;
  return Colors.blue;
}
