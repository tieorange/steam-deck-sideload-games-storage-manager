import 'package:flutter/material.dart';
import 'package:game_size_manager/core/extensions/size_formatter.dart';
import 'package:game_size_manager/core/theme/steam_deck_constants.dart';

/// Stats bar showing game count, total size, and sort order
class StatsBar extends StatelessWidget {
  const StatsBar({
    super.key,
    required this.gameCount,
    required this.totalSizeBytes,
    required this.sortDescending,
    required this.isCollapsed,
  });

  final int gameCount;
  final int totalSizeBytes;
  final bool sortDescending;
  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isCollapsed ? 0.0 : 1.0,
      child: isCollapsed
          ? const SizedBox.shrink()
          : Container(
              height: SteamDeckConstants.compactStatsBarHeight,
              padding: const EdgeInsets.symmetric(horizontal: SteamDeckConstants.pagePadding),
              child: Row(
                children: [
                  Text(
                    '$gameCount games',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('•')),
                  Text(
                    totalSizeBytes.toHumanReadableSize(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Sort: ${sortDescending ? "Largest" : "Smallest"}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
