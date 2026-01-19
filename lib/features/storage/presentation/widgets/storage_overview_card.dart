import 'package:flutter/material.dart';

import 'package:game_size_manager/core/extensions/size_formatter.dart';
import 'package:game_size_manager/core/widgets/animated_card.dart';
import 'package:game_size_manager/features/storage/presentation/utils/storage_utils.dart';

/// Overview card showing total storage usage with progress bar
class StorageOverviewCard extends StatelessWidget {
  const StorageOverviewCard({
    super.key,
    required this.controller,
    required this.totalBytes,
    required this.usedBytes,
    required this.freeBytes,
  });

  final AnimationController controller;
  final int totalBytes;
  final int usedBytes;
  final int freeBytes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = totalBytes > 0 ? (usedBytes / totalBytes).clamp(0.0, 1.0) : 0.0;

    return AnimatedCard(
      controller: controller,
      delay: 0.0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Used',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      usedBytes.toHumanReadableSize(),
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.pie_chart_rounded, size: 32, color: theme.colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 12,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: getColorForUsage(percent),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(percent * 100).toStringAsFixed(1)}% Used',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: getColorForUsage(percent),
                  ),
                ),
                Text(
                  '${freeBytes.toHumanReadableSize()} Free',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
