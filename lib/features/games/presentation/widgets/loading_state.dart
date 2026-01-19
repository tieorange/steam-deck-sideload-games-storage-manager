import 'package:flutter/material.dart';

/// Loading state widget with spinner and message
class GamesLoadingState extends StatelessWidget {
  const GamesLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(strokeWidth: 3, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading library...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
