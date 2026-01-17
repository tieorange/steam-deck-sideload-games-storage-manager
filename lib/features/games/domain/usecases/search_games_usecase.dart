import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

class SearchGamesUsecase {
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
