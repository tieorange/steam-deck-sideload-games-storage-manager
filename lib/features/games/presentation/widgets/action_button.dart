import 'package:flutter/material.dart';

/// A compact action button used in game details page for ProtonDB, Files, Wiki, Store actions
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.useSurfaceColor = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool useSurfaceColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: useSurfaceColor ? color : color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: useSurfaceColor
                  ? theme.colorScheme.outline.withValues(alpha: 0.1)
                  : color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: useSurfaceColor ? theme.colorScheme.onSurface : color),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: useSurfaceColor ? theme.colorScheme.onSurface : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
