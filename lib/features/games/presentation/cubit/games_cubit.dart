import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
import 'package:game_size_manager/features/games/domain/repositories/game_repository.dart';
import 'package:game_size_manager/features/games/presentation/cubit/games_state.dart';

/// Cubit for managing the games list
class GamesCubit extends Cubit<GamesState> {
  GamesCubit(this._repository) : super(const GamesState.initial());
  
  final GameRepository _repository;
  final _logger = LoggerService.instance;
  
  /// Load all games from configured sources
  Future<void> loadGames() async {
    emit(const GamesState.loading());
    
    final result = await _repository.getGames();
    
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
    final currentFilter = state.maybeWhen(
      loaded: (_, filter, sortDesc) => (filter, sortDesc),
      orElse: () => (null, true),
    );
    
    emit(const GamesState.loading());
    
    final result = await _repository.refreshGames();
    
    result.fold(
      (failure) => emit(GamesState.error(failure.message)),
      (games) => emit(GamesState.loaded(
        games: games,
        filterSource: currentFilter.$1,
        sortDescending: currentFilter.$2,
      )),
    );
  }
  
  /// Filter games by source
  void setFilter(GameSource? source) {
    state.maybeWhen(
      loaded: (games, _, sortDesc) {
        emit(GamesState.loaded(
          games: games,
          filterSource: source,
          sortDescending: sortDesc,
        ));
      },
      orElse: () {},
    );
  }
  
  /// Toggle sort order
  void toggleSortOrder() {
    state.maybeWhen(
      loaded: (games, filter, sortDesc) {
        emit(GamesState.loaded(
          games: games,
          filterSource: filter,
          sortDescending: !sortDesc,
        ));
      },
      orElse: () {},
    );
  }
  
  /// Toggle selection of a game
  void toggleGameSelection(String gameId) {
    state.maybeWhen(
      loaded: (games, filter, sortDesc) {
        final updatedGames = games.map((game) {
          if (game.id == gameId) {
            return game.toggleSelected();
          }
          return game;
        }).toList();
        
        emit(GamesState.loaded(
          games: updatedGames,
          filterSource: filter,
          sortDescending: sortDesc,
        ));
      },
      orElse: () {},
    );
  }
  
  /// Select all visible games
  void selectAll() {
    state.maybeWhen(
      loaded: (games, filter, sortDesc) {
        final visibleIds = games.filterBySource(filter).map((g) => g.id).toSet();
        final updatedGames = games.map((game) {
          if (visibleIds.contains(game.id)) {
            return game.copyWith(isSelected: true);
          }
          return game;
        }).toList();
        
        emit(GamesState.loaded(
          games: updatedGames,
          filterSource: filter,
          sortDescending: sortDesc,
        ));
      },
      orElse: () {},
    );
  }
  
  /// Deselect all games
  void deselectAll() {
    state.maybeWhen(
      loaded: (games, filter, sortDesc) {
        final updatedGames = games.map((game) => game.copyWith(isSelected: false)).toList();
        
        emit(GamesState.loaded(
          games: updatedGames,
          filterSource: filter,
          sortDescending: sortDesc,
        ));
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
      final result = await _repository.uninstallGame(game);
      result.fold(
        (failure) {
          _logger.error('Failed to uninstall ${game.title}: ${failure.message}', tag: 'GamesCubit');
        },
        (_) {
          _logger.info('Uninstalled: ${game.title}', tag: 'GamesCubit');
        },
      );
    }
    
    // Refresh the list
    await refreshGames();
  }
}
