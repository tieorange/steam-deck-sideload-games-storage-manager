import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
import 'package:game_size_manager/features/games/domain/usecases/calculate_game_size_usecase.dart';
import 'package:game_size_manager/features/games/domain/usecases/get_all_games_usecase.dart';
import 'package:game_size_manager/features/games/domain/usecases/refresh_games_usecase.dart';
import 'package:game_size_manager/features/games/domain/usecases/search_games_usecase.dart';
import 'package:game_size_manager/features/games/domain/usecases/uninstall_game_usecase.dart';
import 'package:game_size_manager/features/games/presentation/cubit/games_state.dart';
import 'package:game_size_manager/features/games/presentation/cubit/refresh_state.dart';
import 'package:game_size_manager/core/constants/fun_phrases.dart';

/// Cubit for managing the games list
class GamesCubit extends Cubit<GamesState> {
  GamesCubit({
    required GetAllGamesUsecase getAllGames,
    required RefreshGamesUsecase refreshGames,
    required UninstallGameUsecase uninstallGame,
    required CalculateGameSizeUsecase calculateGameSize,
    required SearchGamesUsecase searchGames,
  }) : _getAllGames = getAllGames,
       _refreshGames = refreshGames,
       _uninstallGame = uninstallGame,
       _calculateGameSize = calculateGameSize,
       _searchGames = searchGames,
       super(const GamesState.initial());

  final GetAllGamesUsecase _getAllGames;
  final RefreshGamesUsecase _refreshGames;
  final UninstallGameUsecase _uninstallGame;
  final CalculateGameSizeUsecase _calculateGameSize;
  final SearchGamesUsecase _searchGames;
  final _logger = LoggerService.instance;

  /// Load all games from configured sources
  Future<void> loadGames() async {
    emit(const GamesState.loading());

    final result = await _getAllGames();

    result.fold(
      (failure) {
        _logger.error('Failed to load games: ${failure.message}', tag: 'GamesCubit');
        emit(GamesState.error(failure.message));
      },
      (games) {
        _logger.info('Loaded ${games.length} games', tag: 'GamesCubit');
        emit(GamesState.loaded(games: games));
      },
    );
  }

  /// Refresh games from sources
  Future<void> refreshGames() async {
    // Keep current filter while refreshing
    final currentFilters = state.maybeWhen(
      loaded: (_, filter, sortDesc, query, __) => (filter, sortDesc, query),
      orElse: () => (null, true, null),
    );

    final funPhrase = FunPhrases.getRandom();
    final startTime = DateTime.now();

    void updateProgress(String phase, double progress) {
      // Calculate estimated time remaining
      // Very rough estimate based on progress
      Duration? eta;
      if (progress > 0) {
        final elapsed = DateTime.now().difference(startTime);
        final totalEst = Duration(milliseconds: (elapsed.inMilliseconds / progress).round());
        eta = totalEst - elapsed;
        if (eta.isNegative) eta = Duration.zero;
      }

      final progressState = RefreshProgressState(
        currentPhase: phase,
        progressPercent: progress,
        funPhrase: funPhrase,
        estimatedTimeRemaining: eta,
      );

      state.maybeWhen(
        loaded: (games, filter, sortDesc, query, _) {
          emit(
            GamesState.loaded(
              games: games,
              filterSource: filter,
              sortDescending: sortDesc,
              searchQuery: query,
              refreshProgress: progressState,
            ),
          );
        },
        orElse: () {
          emit(GamesState.loading(progress: progressState));
        },
      );
    }

    // Initial loading state
    updateProgress('Starting...', 0.0);

    final result = await _refreshGames(onProgress: updateProgress);

    result.fold(
      (failure) => emit(GamesState.error(failure.message)),
      (games) => emit(
        GamesState.loaded(
          games: games,
          filterSource: currentFilters.$1,
          sortDescending: currentFilters.$2,
          searchQuery: currentFilters.$3,
          refreshProgress: null, // Clear progress
        ),
      ),
    );
  }

  /// Calculate size for a specific game
  Future<void> calculateSize(Game game) async {
    final result = await _calculateGameSize(game);

    result.fold(
      (failure) {
        _logger.warning(
          'Failed to calculate size for ${game.title}: ${failure.message}',
          tag: 'GamesCubit',
        );
        // We don't necessarily need to emit an error state here, just log it
      },
      (updatedGame) {
        // Update the game in the list
        state.maybeWhen(
          loaded: (games, filter, sortDesc, query, _) {
            final updatedGames = games
                .map((g) => g.id == updatedGame.id ? updatedGame : g)
                .toList();
            emit(
              GamesState.loaded(
                games: updatedGames,
                filterSource: filter,
                sortDescending: sortDesc,
                searchQuery: query,
              ),
            );
          },
          orElse: () {},
        );
      },
    );
  }

  /// Set search query
  void setSearchQuery(String query) {
    state.maybeWhen(
      loaded: (games, filter, sortDesc, _, __) {
        emit(
          GamesState.loaded(
            games: games,
            filterSource: filter,
            sortDescending: sortDesc,
            searchQuery: query,
            refreshProgress: null,
          ),
        );
      },
      orElse: () {},
    );
  }

  /// Filter games by source
  void setFilter(GameSource? source) {
    state.maybeWhen(
      loaded: (games, _, sortDesc, query, __) {
        emit(
          GamesState.loaded(
            games: games,
            filterSource: source,
            sortDescending: sortDesc,
            searchQuery: query,
            refreshProgress: null,
          ),
        );
      },
      orElse: () {},
    );
  }

  /// Toggle sort order
  void toggleSortOrder() {
    state.maybeWhen(
      loaded: (games, filter, sortDesc, query, __) {
        emit(
          GamesState.loaded(
            games: games,
            filterSource: filter,
            sortDescending: !sortDesc,
            searchQuery: query,
            refreshProgress: null,
          ),
        );
      },
      orElse: () {},
    );
  }

  /// Toggle selection of a game
  void toggleGameSelection(String gameId) {
    state.maybeWhen(
      loaded: (games, filter, sortDesc, query, __) {
        final updatedGames = games.map((game) {
          if (game.id == gameId) {
            return game.toggleSelected();
          }
          return game;
        }).toList();

        emit(
          GamesState.loaded(
            games: updatedGames,
            filterSource: filter,
            sortDescending: sortDesc,
            searchQuery: query,
            refreshProgress: null,
          ),
        );
      },
      orElse: () {},
    );
  }

  /// Select all visible games
  void selectAll() {
    state.maybeWhen(
      loaded: (games, filter, sortDesc, query, __) {
        // Use the usecase logic or displayedGames logic to determine what is "visible"
        // Since logic is in State's displayedGames, we can rely on that if we had access to it,
        // but here we are in the Cubit.
        // Replicating visibility logic: source filter + search query

        // Filter by source
        var visible = games.filterBySource(filter);
        // Filter by search
        if (query != null && query.isNotEmpty) {
          visible = _searchGames(visible, query);
        }

        final visibleIds = visible.map((g) => g.id).toSet();

        final updatedGames = games.map((game) {
          if (visibleIds.contains(game.id)) {
            return game.copyWith(isSelected: true);
          }
          return game;
        }).toList();

        emit(
          GamesState.loaded(
            games: updatedGames,
            filterSource: filter,
            sortDescending: sortDesc,
            searchQuery: query,
            refreshProgress: null,
          ),
        );
      },
      orElse: () {},
    );
  }

  /// Deselect all games
  void deselectAll() {
    state.maybeWhen(
      loaded: (games, filter, sortDesc, query, __) {
        final updatedGames = games.map((game) => game.copyWith(isSelected: false)).toList();

        emit(
          GamesState.loaded(
            games: updatedGames,
            filterSource: filter,
            sortDescending: sortDesc,
            searchQuery: query,
            refreshProgress: null,
          ),
        );
      },
      orElse: () {},
    );
  }

  /// Uninstall selected games and return total bytes freed
  Future<int> uninstallSelected() async {
    final selectedGames = state.selectedGames;
    if (selectedGames.isEmpty) return 0;

    _logger.info('Uninstalling ${selectedGames.length} games', tag: 'GamesCubit');

    int totalFreedBytes = 0;

    for (final game in selectedGames) {
      if (await _performUninstall(game)) {
        totalFreedBytes += game.sizeBytes;
      }
    }

    // Refresh the list
    await refreshGames();
    return totalFreedBytes;
  }

  /// Uninstall a single game (returns bytes freed)
  Future<int> uninstallGame(Game game) async {
    _logger.info('Uninstalling single game: ${game.title}', tag: 'GamesCubit');
    final success = await _performUninstall(game);
    await refreshGames();
    return success ? game.sizeBytes : 0;
  }

  Future<bool> _performUninstall(Game game) async {
    final result = await _uninstallGame(game);
    return result.fold(
      (failure) {
        _logger.error('Failed to uninstall ${game.title}: ${failure.message}', tag: 'GamesCubit');
        return false;
      },
      (_) {
        _logger.info('Uninstalled: ${game.title}', tag: 'GamesCubit');
        return true;
      },
    );
  }
}
