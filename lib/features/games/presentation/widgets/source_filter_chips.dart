import 'package:flutter/material.dart';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/theme/steam_deck_constants.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// Horizontal filter chips for game sources with animations
class SourceFilterChips extends StatelessWidget {
  const SourceFilterChips({
    super.key,
    required this.allGames,
    required this.selectedSource,
    required this.onSourceSelected,
  });

  final List<Game> allGames;
  final GameSource? selectedSource;
  final ValueChanged<GameSource?> onSourceSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Count games per source
    final counts = <GameSource?, int>{null: allGames.length};
    for (final source in GameSource.values) {
      counts[source] = allGames.where((g) => g.source == source).length;
    }

    return Container(
      height: SteamDeckConstants.compactFilterHeight,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: SteamDeckConstants.compactPadding),
        children: [
          _buildChip(context, null, 'All', counts[null]!, null, colorScheme.primary),
          const SizedBox(width: 8),
          for (final source in GameSource.values) ...[
            if (counts[source]! > 0) ...[
              _buildChip(
                context,
                source,
                source.displayName,
                counts[source]!,
                _getSourceIcon(source),
                _getSourceColor(source),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    GameSource? source,
    String label,
    int count,
    IconData? icon,
    Color color,
  ) {
    final isSelected = selectedSource == source;
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Material(
        color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => onSourceSelected(source),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 18,
                    color: isSelected ? color : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isSelected ? color : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.3)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? color
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getSourceIcon(GameSource source) {
    switch (source) {
      case GameSource.heroic:
        return Icons.storefront_rounded;
      case GameSource.ogi:
        return Icons.apps_rounded;
      case GameSource.lutris:
        return Icons.sports_esports_rounded;
      case GameSource.steam:
        return Icons.gamepad_rounded;
    }
  }

  Color _getSourceColor(GameSource source) {
    switch (source) {
      case GameSource.heroic:
        return const Color(0xFFE91E63);
      case GameSource.ogi:
        return const Color(0xFF9C27B0);
      case GameSource.lutris:
        return const Color(0xFFFF9800);
      case GameSource.steam:
        return const Color(0xFF2196F3);
    }
  }
}
