import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
import 'package:game_size_manager/features/games/domain/entities/game_tag.dart';
import 'package:game_size_manager/features/games/domain/entities/sort_option.dart';
import 'package:game_size_manager/features/games/presentation/cubit/refresh_state.dart';

part 'games_state.freezed.dart';

/// State for the Games feature
@freezed
class GamesState with _$GamesState {
  const GamesState._();

  /// Initial state, no data loaded yet
  const factory GamesState.initial() = GamesInitial;

  /// Loading games from sources
  const factory GamesState.loading({@Default(null) RefreshProgressState? progress}) = GamesLoading;

  /// Games loaded successfully
  const factory GamesState.loaded({
    required List<Game> games,
    @Default(null) GameSource? filterSource,
    @Default(true) bool sortDescending,
    @Default(null) String? searchQuery,
    @Default(null) RefreshProgressState? refreshProgress,
    @Default(SortOption.size) SortOption sortOption,
    @Default(null) GameTag? filterTag,
    @Default(null) DateTime? lastRefresh,
  }) = GamesLoaded;

  /// Error state
  const factory GamesState.error(String message) = GamesError;

  /// Get displayed games (filtered and sorted)
  List<Game> get displayedGames => maybeWhen(
    loaded: (games, filter, sortDesc, searchQuery, _, sortOption, filterTag, __) {
      var result = games.filterBySource(filter);

      // Apply tag filter
      if (filterTag != null) {
        result = result.filterByTag(filterTag);
      }

      // Apply search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        result = result.where((g) => g.title.toLowerCase().contains(query)).toList();
      }

      result = result.sortedBy(sortOption);
      if (!sortDesc) {
        result = result.reversed.toList();
      }
      return result;
    },
    orElse: () => [],
  );

  /// Get selected games
  List<Game> get selectedGames =>
      maybeWhen(loaded: (games, _, __, ___, ____, _____, ______, _______) => games.selectedGames, orElse: () => []);

  /// Are any games selected?
  bool get hasSelection => selectedGames.isNotEmpty;

  /// Total size of selected games
  int get selectedSizeBytes => selectedGames.totalSizeBytes;
}
