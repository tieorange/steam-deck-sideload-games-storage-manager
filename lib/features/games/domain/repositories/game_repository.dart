import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/error/failures.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// Repository interface for game operations
abstract class GameRepository {
  /// Get all games from all sources
  Future<Result<List<Game>>> getGames();

  /// Get games from a specific source
  Future<Result<List<Game>>> getGamesBySource(GameSource source);

  /// Calculate size for a specific game (updates the game's sizeBytes)
  Future<Result<Game>> calculateGameSize(Game game);

  /// Uninstall a game
  Future<Result<void>> uninstallGame(Game game);

  /// Refresh game data (force re-read from sources)
  Future<Result<List<Game>>> refreshGames({
    void Function(String message, double progress)? onProgress,
  });
}
