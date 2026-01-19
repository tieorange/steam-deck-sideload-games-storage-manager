import 'package:game_size_manager/core/error/failures.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// Abstract interface for game data sources
abstract class GameDatasource {
  /// Get all installed games from this source
  Future<Result<List<Game>>> getGames();
}
