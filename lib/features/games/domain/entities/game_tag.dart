import 'package:flutter/material.dart';

/// User-defined tags for categorizing games
enum GameTag {
  playing('Playing', Icons.play_circle_outline, Color(0xFF4CAF50)),
  completed('Completed', Icons.check_circle_outline, Color(0xFF2196F3)),
  backlog('Backlog', Icons.queue_outlined, Color(0xFFFF9800)),
  favorite('Favorite', Icons.star_outline, Color(0xFFFFD700)),
  canDelete('Can Delete', Icons.delete_outline, Color(0xFFF44336));

  const GameTag(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}
