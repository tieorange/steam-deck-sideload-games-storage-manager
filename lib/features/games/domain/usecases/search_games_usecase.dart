import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// Pure synchronous filter for searching games by title.
/// Named 'Filter' instead of 'UseCase' to clarify it's not an async domain operation.
class SearchGamesFilter {
  /// Filter games by search query (case-insensitive title match)
  List<Game> call(List<Game> games, String query) {
    if (query.isEmpty) {
      return games;
    }

    final lowercaseQuery = query.toLowerCase();
    return games.where((game) {
      return game.title.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}

/// Deprecated: Use [SearchGamesFilter] instead
@Deprecated('Use SearchGamesFilter instead - renamed for clarity')
typedef SearchGamesUsecase = SearchGamesFilter;
