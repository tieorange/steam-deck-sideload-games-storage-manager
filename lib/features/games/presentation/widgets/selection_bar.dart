import 'package:flutter/material.dart';
import 'package:game_size_manager/core/extensions/size_formatter.dart';

/// Selection bar at the bottom showing selected game count, total size, and actions
class SelectionBar extends StatelessWidget {
  const SelectionBar({
    super.key,
    required this.selectedCount,
    required this.selectedSizeBytes,
    required this.onClear,
    required this.onUninstall,
  });

  final int selectedCount;
  final int selectedSizeBytes;
  final VoidCallback onClear;
  final VoidCallback onUninstall;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$selectedCount',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    selectedSizeBytes.toHumanReadableSize(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: onClear, child: const Text('Clear')),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: onUninstall,
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              label: const Text('Uninstall'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
