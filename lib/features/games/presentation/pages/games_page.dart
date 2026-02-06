import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/extensions/size_formatter.dart';
import 'package:game_size_manager/core/router/app_router.dart';
import 'package:game_size_manager/core/theme/steam_deck_constants.dart';
import 'package:game_size_manager/core/widgets/empty_state.dart';
import 'package:game_size_manager/core/widgets/skeleton_loading.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
import 'package:game_size_manager/features/games/domain/entities/game_tag.dart';
import 'package:game_size_manager/features/games/domain/entities/sort_option.dart';
import 'package:game_size_manager/features/games/presentation/cubit/games_cubit.dart';
import 'package:game_size_manager/features/games/presentation/cubit/games_state.dart';
import 'package:game_size_manager/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:game_size_manager/features/settings/presentation/cubit/settings_state.dart';
import 'package:game_size_manager/features/games/presentation/widgets/error_state.dart';
import 'package:game_size_manager/features/games/presentation/widgets/game_grid_item.dart';
import 'package:game_size_manager/features/games/presentation/widgets/game_list_item.dart';
import 'package:game_size_manager/features/games/presentation/widgets/selection_bar.dart';
import 'package:game_size_manager/features/games/presentation/widgets/source_filter_chips.dart';
import 'package:game_size_manager/features/games/presentation/widgets/stats_bar.dart';
import 'package:game_size_manager/features/games/presentation/widgets/uninstall_confirm_dialog.dart';
import 'package:game_size_manager/features/games/presentation/widgets/refresh_progress_overlay.dart';

/// Main games page showing list of all games sorted by size
class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;
  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();
    // Auto-refresh on start (only if not already loaded)
    final gamesCubit = context.read<GamesCubit>();
    gamesCubit.state.maybeWhen(initial: () => gamesCubit.refreshGames(), orElse: () {});
    context.read<SettingsCubit>().loadSettings();

    _searchController.addListener(() {
      context.read<GamesCubit>().setSearchQuery(_searchController.text);
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final isCollapsed = _scrollController.offset > 40;
    if (isCollapsed != _isHeaderCollapsed) {
      setState(() => _isHeaderCollapsed = isCollapsed);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleViewMode(BuildContext context, String currentMode) {
    final newMode = currentMode == 'grid' ? 'list' : 'grid';
    context.read<SettingsCubit>().setViewMode(newMode);
  }

  Future<void> _showUninstallConfirmation(BuildContext context) async {
    final cubit = context.read<GamesCubit>();
    final selectedGames = cubit.state.selectedGames;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => UninstallConfirmDialog(games: selectedGames),
    );

    if (confirmed == true) {
      if (!context.mounted) return;

      final freedBytes = await cubit.uninstallSelected();

      if (!context.mounted) return;

      if (freedBytes > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Freed up ${freedBytes.toHumanReadableSize()}!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.primary,
            margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
            dismissDirection: DismissDirection.up,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settingsState) {
              final viewMode = settingsState.maybeWhen(
                loaded: (s) => s.defaultViewMode,
                orElse: () => 'list',
              );

              return BlocBuilder<GamesCubit, GamesState>(
                builder: (context, state) {
                  return state.when(
                    initial: () => const SizedBox.shrink(),
                    loading: (progress) => progress != null
                        ? const SizedBox.shrink()
                        : const GamesPageSkeleton(),
                    error: (message) => GamesErrorState(
                      message: message,
                      onRetry: () => context.read<GamesCubit>().loadGames(),
                    ),
                    loaded: (games, filter, sortDesc, _, __, sortOption, filterTag, lastRefresh) =>
                        _GamesContent(
                      allGames: games,
                      filter: filter,
                      sortDesc: sortDesc,
                      viewMode: viewMode,
                      sortOption: sortOption,
                      filterTag: filterTag,
                      lastRefresh: lastRefresh,
                      searchController: _searchController,
                      scrollController: _scrollController,
                      isSearching: _isSearching,
                      isHeaderCollapsed: _isHeaderCollapsed,
                      onSearchToggle: () => setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) {
                          _searchController.clear();
                          context.read<GamesCubit>().setSearchQuery('');
                        }
                      }),
                      onViewModeToggle: () => _toggleViewMode(context, viewMode),
                    ),
                  );
                },
              );
            },
          ),
          const RefreshProgressOverlay(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return BlocBuilder<GamesCubit, GamesState>(
      builder: (context, state) {
        if (!state.hasSelection) return const SizedBox.shrink();

        return SelectionBar(
          selectedCount: state.selectedGames.length,
          selectedSizeBytes: state.selectedSizeBytes,
          onClear: () => context.read<GamesCubit>().deselectAll(),
          onUninstall: () => _showUninstallConfirmation(context),
        );
      },
    );
  }
}

/// Format a DateTime as a relative "time ago" string.
String _formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'Updated just now';
  } else if (difference.inMinutes < 60) {
    return 'Updated ${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return 'Updated ${difference.inHours}h ago';
  } else {
    return 'Updated ${difference.inDays}d ago';
  }
}

/// Main content area for the games page
class _GamesContent extends StatelessWidget {
  const _GamesContent({
    required this.allGames,
    required this.filter,
    required this.sortDesc,
    required this.viewMode,
    required this.sortOption,
    required this.filterTag,
    required this.lastRefresh,
    required this.searchController,
    required this.scrollController,
    required this.isSearching,
    required this.isHeaderCollapsed,
    required this.onSearchToggle,
    required this.onViewModeToggle,
  });

  final List<Game> allGames;
  final GameSource? filter;
  final bool sortDesc;
  final String viewMode;
  final SortOption sortOption;
  final GameTag? filterTag;
  final DateTime? lastRefresh;
  final TextEditingController searchController;
  final ScrollController scrollController;
  final bool isSearching;
  final bool isHeaderCollapsed;
  final VoidCallback onSearchToggle;
  final VoidCallback onViewModeToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<GamesCubit>();
    final displayedGames = cubit.state.displayedGames;
    final totalSize = displayedGames.totalSizeBytes;

    return RefreshIndicator(
      onRefresh: () => cubit.refreshGames(),
      edgeOffset: kToolbarHeight + SteamDeckConstants.compactFilterHeight + 8,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // App Bar with Filters
          SliverAppBar(
            floating: true,
            pinned: true,
            elevation: isHeaderCollapsed ? 2 : 0,
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: theme.colorScheme.surfaceTint,
            toolbarHeight: 56,
            title: isSearching
                ? TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: InputBorder.none,
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Text('Games', style: theme.textTheme.titleLarge),
                      const SizedBox(width: 12),
                      if (isHeaderCollapsed)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${displayedGames.length} \u2022 ${totalSize.toHumanReadableSize()}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
            actions: [
              if (isSearching)
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: onSearchToggle)
              else ...[
                IconButton(icon: const Icon(Icons.search_rounded), onPressed: onSearchToggle),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => cubit.refreshGames(),
                  tooltip: 'Refresh Library',
                ),
                IconButton(
                  icon: Icon(viewMode == 'grid' ? Icons.view_list_rounded : Icons.grid_view_rounded),
                  onPressed: onViewModeToggle,
                  tooltip: 'Switch View',
                ),
                // Sort option picker
                PopupMenuButton<SortOption>(
                  icon: const Icon(Icons.sort_rounded),
                  tooltip: 'Sort by',
                  onSelected: (option) => cubit.setSortOption(option),
                  itemBuilder: (context) => SortOption.values
                      .map(
                        (option) => PopupMenuItem<SortOption>(
                          value: option,
                          child: Row(
                            children: [
                              Icon(
                                _sortOptionIcon(option),
                                size: 20,
                                color: option == sortOption
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                option.label,
                                style: TextStyle(
                                  fontWeight:
                                      option == sortOption ? FontWeight.bold : FontWeight.normal,
                                  color: option == sortOption
                                      ? theme.colorScheme.primary
                                      : null,
                                ),
                              ),
                              const Spacer(),
                              if (option == sortOption)
                                Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
                IconButton(
                  icon: Icon(sortDesc ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded),
                  onPressed: () => cubit.toggleSortOrder(),
                  tooltip: sortDesc ? 'Largest first' : 'Smallest first',
                ),
              ],
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(
                SteamDeckConstants.compactFilterHeight + SteamDeckConstants.compactFilterHeight + 16,
              ),
              child: Column(
                children: [
                  // Source filter chips
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SourceFilterChips(
                      allGames: allGames,
                      selectedSource: filter,
                      onSourceSelected: (s) => cubit.setFilter(s),
                    ),
                  ),
                  // Tag filter chips
                  SizedBox(
                    height: SteamDeckConstants.compactFilterHeight,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: SteamDeckConstants.compactPadding,
                      ),
                      children: [
                        _buildTagChip(context, null, 'All Tags', Icons.label_outline, theme),
                        const SizedBox(width: 8),
                        for (final tag in GameTag.values) ...[
                          _buildTagChip(context, tag, tag.label, tag.icon, theme),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Stats bar with last refresh indicator
          SliverToBoxAdapter(
            child: Column(
              children: [
                StatsBar(
                  gameCount: displayedGames.length,
                  totalSizeBytes: totalSize,
                  sortDescending: sortDesc,
                  isCollapsed: isHeaderCollapsed,
                ),
                if (lastRefresh != null && !isHeaderCollapsed)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SteamDeckConstants.pagePadding,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _formatTimeAgo(lastRefresh!),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Games List/Grid
          if (displayedGames.isEmpty)
            SliverFillRemaining(
              child: EmptyState(
                icon: Icons.sports_esports_outlined,
                title: 'No games found',
                description: filter != null || filterTag != null
                    ? 'Try adjusting your filters or search query.'
                    : 'Refresh to scan for installed games.',
                actionLabel: 'Refresh',
                onAction: () => cubit.refreshGames(),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                SteamDeckConstants.pagePadding,
                8,
                SteamDeckConstants.pagePadding,
                100,
              ),
              sliver: viewMode == 'list'
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final game = displayedGames[index];
                        return GameListItem(
                          game: game,
                          index: index,
                          onTap: () => context.pushNamed(AppRoutes.gameDetailsName, extra: game),
                          onSelect: () => cubit.toggleGameSelection(game.id),
                        );
                      }, childCount: displayedGames.length),
                    )
                  : SliverGrid(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        mainAxisExtent: 90,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final game = displayedGames[index];
                        return GameGridItem(
                          game: game,
                          index: index,
                          onTap: () => context.pushNamed(AppRoutes.gameDetailsName, extra: game),
                          onSelect: () => cubit.toggleGameSelection(game.id),
                        );
                      }, childCount: displayedGames.length),
                    ),
            ),
        ],
      ),
    );
  }

  /// Build a tag filter chip
  Widget _buildTagChip(
    BuildContext context,
    GameTag? tag,
    String label,
    IconData icon,
    ThemeData theme,
  ) {
    final isSelected = filterTag == tag;
    final color = tag?.color ?? theme.colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Material(
        color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => context.read<GamesCubit>().setTagFilter(tag),
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
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? color : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isSelected ? color : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get the icon for a sort option
  static IconData _sortOptionIcon(SortOption option) {
    switch (option) {
      case SortOption.size:
        return Icons.storage_rounded;
      case SortOption.name:
        return Icons.sort_by_alpha_rounded;
      case SortOption.source:
        return Icons.source_rounded;
    }
  }
}
