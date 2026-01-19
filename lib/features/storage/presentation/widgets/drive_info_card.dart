import 'package:flutter/material.dart';

import 'package:game_size_manager/core/extensions/size_formatter.dart';
import 'package:game_size_manager/features/storage/presentation/cubit/storage_state.dart';
import 'package:game_size_manager/features/storage/presentation/utils/storage_utils.dart';

/// Card showing information about a single storage drive
class DriveInfoCard extends StatelessWidget {
  const DriveInfoCard({super.key, required this.drive});

  final StorageDrive drive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = drive.totalBytes > 0
        ? (drive.usedBytes / drive.totalBytes).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                drive.isRemovable ? Icons.sd_card_rounded : Icons.storage_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drive.label,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      drive.path,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (drive.isRemovable)
                IconButton(
                  icon: const Icon(Icons.drive_file_move_rounded),
                  onPressed: () => _showMoveGamesDialog(context),
                  tooltip: 'Move Games to this Drive',
                ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: getColorForUsage(percent),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                drive.usedBytes.toHumanReadableSize(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                drive.totalBytes.toHumanReadableSize(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMoveGamesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move Games'),
        content: const Text(
          'Moving games to SD Card will be available in a future update.\n\n'
          'This feature will safely move game files and create symbolic links.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ],
      ),
    );
  }
}
