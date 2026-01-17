import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

part 'games_state.freezed.dart';

/// State for the Games feature
@freezed
class GamesState with _$GamesState {
  const GamesState._();
  
  /// Initial state, no data loaded yet
  const factory GamesState.initial() = GamesInitial;
  
  /// Loading games from sources
  const factory GamesState.loading() = GamesLoading;
  
  /// Games loaded successfully
  const factory GamesState.loaded({
    required List<Game> games,
    @Default(null) GameSource? filterSource,
    @Default(true) bool sortDescending,
  }) = GamesLoaded;
  
  /// Error state
  const factory GamesState.error(String message) = GamesError;
  
  /// Get displayed games (filtered and sorted)
  List<Game> get displayedGames => maybeWhen(
    loaded: (games, filter, sortDesc) {
      var result = games.filterBySource(filter);
      result = result.sortedBySize();
      if (!sortDesc) {
        result = result.reversed.toList();
      }
      return result;
    },
    orElse: () => [],
  );
  
  /// Get selected games
  List<Game> get selectedGames => maybeWhen(
    loaded: (games, _, __) => games.selectedGames,
    orElse: () => [],
  );
  
  /// Are any games selected?
  bool get hasSelection => selectedGames.isNotEmpty;
  
  /// Total size of selected games
  int get selectedSizeBytes => selectedGames.totalSizeBytes;
}
