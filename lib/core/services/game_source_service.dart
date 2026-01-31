import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
import 'package:game_size_manager/core/error/failures.dart';

/// Abstract interface for fetching games from platform-specific sources.
///
/// On Linux/Steam Deck, this wraps SteamDeckGamesDetector.
/// On Android/Quest, this uses MethodChannels to query installed apps.
abstract class GameSourceService {
  /// Retrieve all detected games/apps for this platform.
  Future<Result<List<Game>>> getGames();

  /// Whether this platform supports uninstalling apps directly.
  bool get supportsUninstall;

  /// Uninstall a game/app. Returns success or failure.
  /// On Android, this launches the system uninstall dialog.
  Future<Result<void>> uninstallGame(String gameId);
}
