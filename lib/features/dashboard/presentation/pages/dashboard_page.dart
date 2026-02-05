import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/extensions/size_formatter.dart';
import 'package:game_size_manager/core/theme/game_colors.dart';
import 'package:game_size_manager/core/theme/steam_deck_constants.dart';
import 'package:game_size_manager/core/widgets/skeleton_loading.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
import 'package:game_size_manager/features/games/presentation/cubit/games_cubit.dart';
import 'package:game_size_manager/features/games/presentation/cubit/games_state.dart';

import 'package:game_size_manager/core/widgets/animated_card.dart';

/// Dashboard page showing storage overview and top games with animations
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<GamesCubit>().refreshGames(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocBuilder<GamesCubit, GamesState>(
        builder: (context, state) {
          return state.when(
            initial: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<GamesCubit>().loadGames();
              });
              return const Center(child: CircularProgressIndicator());
            },
            loading: (_) => const DashboardCardSkeleton(),
            error: (message) => Center(child: Text('Error: $message')),
            loaded: (games, _, __, ___, ____, _____, ______, _______) => _buildDashboard(context, games),
          );
        },
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, List<Game> games) {
    final theme = Theme.of(context);
    final totalSize = games.totalSizeBytes;
    final sortedGames = games.sortedBySize();
    final top5 = sortedGames.take(5).toList();

    return RefreshIndicator(
      onRefresh: () => context.read<GamesCubit>().refreshGames(),
      child: ListView(
        padding: const EdgeInsets.all(SteamDeckConstants.pagePadding),
        children: [
          // Storage Overview Card with animation
          AnimatedCard(
            controller: _controller,
            delay: 0.0,
            child: _buildStorageCard(theme, games, totalSize),
          ),

          const SizedBox(height: SteamDeckConstants.sectionGap),

          // Source Breakdown with animation
          AnimatedCard(
            controller: _controller,
            delay: 0.1,
            child: _buildSourceBreakdown(context, games, totalSize, theme),
          ),

          const SizedBox(height: SteamDeckConstants.sectionGap),

          // Top 5 header
          AnimatedCard(
            controller: _controller,
            delay: 0.2,
            child: Row(
              children: [
                Icon(Icons.leaderboard_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Top 5 Largest Games', style: theme.textTheme.titleMedium),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Top 5 games
          for (int i = 0; i < top5.length; i++)
            AnimatedCard(
              controller: _controller,
              delay: 0.3 + (i * 0.05),
              child: _buildGameCard(context, top5[i], i + 1, theme),
            ),
        ],
      ),
    );
  }

  Widget _buildStorageCard(ThemeData theme, List<Game> games, int totalSize) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.2),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.folder_open_rounded, color: theme.colorScheme.primary, size: 32),
              ),
              const SizedBox(width: 16),
              Text('Total Games Storage', style: theme.textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            totalSize.toHumanReadableSize(),
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatChip(theme, Icons.games_rounded, '${games.length} games'),
              const SizedBox(width: 12),
              _buildStatChip(
                theme,
                Icons.source_rounded,
                '${games.map((g) => g.source).toSet().length} sources',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(ThemeData theme, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
          const SizedBox(width: 6),
          Text(text, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }

  Widget _buildSourceBreakdown(
    BuildContext context,
    List<Game> games,
    int totalSize,
    ThemeData theme,
  ) {
    final breakdown = _getSourceBreakdown(games);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_rounded, color: theme.colorScheme.secondary),
              const SizedBox(width: 8),
              Text('Storage by Source', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 20),
          for (final source in breakdown) ...[
            _buildSourceRow(context, source.$1, source.$2, source.$3, source.$4, totalSize, theme),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  List<(String, int, int, Color)> _getSourceBreakdown(List<Game> games) {
    final breakdown = <(String, int, int, Color)>[];

    for (final source in games.map((g) => g.source).toSet()) {
      final sourceGames = games.where((g) => g.source == source).toList();
      breakdown.add((
        source.displayName,
        sourceGames.length,
        sourceGames.totalSizeBytes,
        GameColors.forSource(source),
      ));
    }

    breakdown.sort((a, b) => b.$3.compareTo(a.$3));
    return breakdown;
  }

  Widget _buildSourceRow(
    BuildContext context,
    String name,
    int count,
    int size,
    Color color,
    int total,
    ThemeData theme,
  ) {
    final percent = total > 0 ? (size / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
            ),
            const SizedBox(width: 8),
            Text('$name ($count)', style: theme.textTheme.bodyMedium),
            const Spacer(),
            Text(
              size.toHumanReadableSize(),
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              '${(percent * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildGameCard(BuildContext context, Game game, int rank, ThemeData theme) {
    final color = GameColors.forSource(game.source);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.3),
                theme.colorScheme.primary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        title: Text(
          game.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                game.source.displayName,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Text(
          game.sizeBytes.toHumanReadableSize(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: GameColors.forSize(game.sizeBytes),
          ),
        ),
      ),
    );
  }

}
