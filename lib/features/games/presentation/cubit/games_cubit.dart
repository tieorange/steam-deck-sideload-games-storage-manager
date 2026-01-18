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
      loaded: (_, filter, sortDesc, query) => (filter, sortDesc, query),
      orElse: () => (null, true, null),
    );

    emit(const GamesState.loading());

    final result = await _refreshGames();

    result.fold(
      (failure) => emit(GamesState.error(failure.message)),
      (games) => emit(
        GamesState.loaded(
          games: games,
          filterSource: currentFilters.$1,
          sortDescending: currentFilters.$2,
          searchQuery: currentFilters.$3,
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
          loaded: (games, filter, sortDesc, query) {
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
      loaded: (games, filter, sortDesc, _) {
        emit(
          GamesState.loaded(
            games: games,
            filterSource: filter,
            sortDescending: sortDesc,
            searchQuery: query,
          ),
        );
      },
      orElse: () {},
    );
  }

  /// Filter games by source
  void setFilter(GameSource? source) {
    state.maybeWhen(
      loaded: (games, _, sortDesc, query) {
        emit(
          GamesState.loaded(
            games: games,
            filterSource: source,
            sortDescending: sortDesc,
            searchQuery: query,
          ),
        );
      },
      orElse: () {},
    );
  }

  /// Toggle sort order
  void toggleSortOrder() {
    state.maybeWhen(
      loaded: (games, filter, sortDesc, query) {
        emit(
          GamesState.loaded(
            games: games,
            filterSource: filter,
            sortDescending: !sortDesc,
            searchQuery: query,
          ),
        );
      },
      orElse: () {},
    );
  }

  /// Toggle selection of a game
  void toggleGameSelection(String gameId) {
    state.maybeWhen(
      loaded: (games, filter, sortDesc, query) {
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
          ),
        );
      },
      orElse: () {},
    );
  }

  /// Select all visible games
  void selectAll() {
    state.maybeWhen(
      loaded: (games, filter, sortDesc, query) {
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
          ),
        );
      },
      orElse: () {},
    );
  }

  /// Deselect all games
  void deselectAll() {
    state.maybeWhen(
      loaded: (games, filter, sortDesc, query) {
        final updatedGames = games.map((game) => game.copyWith(isSelected: false)).toList();

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
  }

  /// Uninstall selected games
  Future<void> uninstallSelected() async {
    final selectedGames = state.selectedGames;
    if (selectedGames.isEmpty) return;

    _logger.info('Uninstalling ${selectedGames.length} games', tag: 'GamesCubit');

    for (final game in selectedGames) {
      await _performUninstall(game);
    }

    // Refresh the list
    await refreshGames();
  }

  /// Uninstall a single game
  Future<void> uninstallGame(Game game) async {
    _logger.info('Uninstalling single game: ${game.title}', tag: 'GamesCubit');
    await _performUninstall(game);
    await refreshGames();
  }

  Future<void> _performUninstall(Game game) async {
    final result = await _uninstallGame(game);
    result.fold(
      (failure) {
        _logger.error('Failed to uninstall ${game.title}: ${failure.message}', tag: 'GamesCubit');
      },
      (_) {
        _logger.info('Uninstalled: ${game.title}', tag: 'GamesCubit');
      },
    );
  }
}
