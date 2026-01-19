import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/extensions/size_formatter.dart';
import 'package:game_size_manager/core/theme/steam_deck_constants.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
import 'package:game_size_manager/features/games/presentation/cubit/games_cubit.dart';
import 'package:game_size_manager/features/games/presentation/cubit/games_state.dart';
import 'package:game_size_manager/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:game_size_manager/features/settings/presentation/cubit/settings_state.dart';
import 'package:go_router/go_router.dart';
import 'package:game_size_manager/core/router/app_router.dart';
import 'package:game_size_manager/features/games/presentation/widgets/game_list_item.dart';
import 'package:game_size_manager/features/games/presentation/widgets/game_grid_item.dart';
import 'package:game_size_manager/features/games/presentation/widgets/source_filter_chips.dart';
import 'package:game_size_manager/features/games/presentation/widgets/uninstall_confirm_dialog.dart';

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

  // Collapsible header logic
  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();
    context.read<GamesCubit>().loadGames();
    // Ensure settings are loaded
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          final viewMode = settingsState.maybeWhen(
            loaded: (s) => s.defaultViewMode,
            orElse: () => 'list',
          );

          return BlocBuilder<GamesCubit, GamesState>(
            builder: (context, state) {
              return state.when(
                initial: () => const SizedBox.shrink(),
                loading: () => _buildLoadingState(theme),
                error: (message) => _buildErrorState(context, message, theme),
                loaded: (games, filter, sortDesc, _) =>
                    _buildLoadedState(context, games, filter, sortDesc, theme, viewMode),
              );
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
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

  Widget _buildErrorState(BuildContext context, String message, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.read<GamesCubit>().loadGames(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(
    BuildContext context,
    List<Game> allGames,
    GameSource? filter,
    bool sortDesc,
    ThemeData theme,
    String viewMode,
  ) {
    final cubit = context.read<GamesCubit>();
    final displayedGames = cubit.state.displayedGames;
    final totalSize = displayedGames.totalSizeBytes;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Compact App Bar with Filters
        SliverAppBar(
          floating: true,
          pinned: true,
          elevation: _isHeaderCollapsed ? 2 : 0,
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: theme.colorScheme.surfaceTint,
          toolbarHeight: 56,
          title: _isSearching
              ? TextField(
                  controller: _searchController,
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
                    // Collapsed stats pill
                    if (_isHeaderCollapsed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${displayedGames.length} • ${totalSize.toHumanReadableSize()}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
          actions: [
            if (_isSearching)
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                  });
                  cubit.setSearchQuery('');
                },
              )
            else ...[
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () => setState(() => _isSearching = true),
              ),
              IconButton(
                icon: Icon(viewMode == 'grid' ? Icons.view_list_rounded : Icons.grid_view_rounded),
                onPressed: () => _toggleViewMode(context, viewMode),
                tooltip: 'Switch View',
              ),
              IconButton(
                icon: Icon(sortDesc ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded),
                onPressed: () => cubit.toggleSortOrder(),
                tooltip: 'Sort by Size',
              ),
            ],
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(SteamDeckConstants.compactFilterHeight + 8),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SourceFilterChips(
                allGames: allGames,
                selectedSource: filter,
                onSourceSelected: (s) => cubit.setFilter(s),
              ),
            ),
          ),
        ),

        // Stats bar (scrolls away)
        SliverToBoxAdapter(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isHeaderCollapsed ? 0.0 : 1.0,
            child: _isHeaderCollapsed
                ? const SizedBox.shrink()
                : Container(
                    height: SteamDeckConstants.compactStatsBarHeight,
                    padding: const EdgeInsets.symmetric(horizontal: SteamDeckConstants.pagePadding),
                    child: Row(
                      children: [
                        Text(
                          '${displayedGames.length} games',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('•'),
                        ),
                        Text(
                          totalSize.toHumanReadableSize(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        // Selection hint
                        Text(
                          'Sort: ${sortDesc ? "Largest" : "Smallest"}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),

        // Games List/Grid
        if (displayedGames.isEmpty)
          const SliverFillRemaining(child: Center(child: Text('No games found')))
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              SteamDeckConstants.pagePadding,
              8,
              SteamDeckConstants.pagePadding,
              100, // Bottom padding for nav/selection bar
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
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return BlocBuilder<GamesCubit, GamesState>(
      builder: (context, state) {
        if (!state.hasSelection) return const SizedBox.shrink();

        final theme = Theme.of(context);
        final selectedCount = state.selectedGames.length;

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
                        state.selectedSizeBytes.toHumanReadableSize(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.read<GamesCubit>().deselectAll(),
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => _showUninstallConfirmation(context),
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
      },
    );
  }

  Future<void> _showUninstallConfirmation(BuildContext context) async {
    final cubit = context.read<GamesCubit>();
    final selectedGames = cubit.state.selectedGames;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => UninstallConfirmDialog(games: selectedGames),
    );

    if (confirmed == true) {
      cubit.uninstallSelected();
    }
  }
}
