import 'package:dartz/dartz.dart';
import 'package:steam_deck_games_detector/steam_deck_games_detector.dart' as pkg;

import 'package:game_size_manager/core/error/failures.dart';
import 'package:game_size_manager/core/services/game_source_service.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// Steam Deck (Linux) implementation of GameSourceService.
/// Wraps the external steam_deck_games_detector package.
class SteamDeckGameSource implements GameSourceService {
  final pkg.SteamDeckGamesDetector _detector;

  SteamDeckGameSource(this._detector);

  @override
  Future<Result<List<Game>>> getGames() async {
    final result = await _detector.getAllGames();
    return result.fold(
      (failure) => Left(_mapFailure(failure)),
      (pkgGames) => Right(pkgGames.map((g) => Game.fromPackage(g)).toList()),
    );
  }

  @override
  bool get supportsUninstall => true;

  @override
  Future<Result<void>> uninstallGame(String gameId) async {
    // Steam Deck uninstall is handled by GameRepositoryImpl directly
    // using launcher-specific scripts (e.g., Heroic's uninstall command)
    return Left(UnexpectedFailure('Use GameRepository.uninstallGame instead', StackTrace.current));
  }

  Failure _mapFailure(pkg.Failure failure) {
    if (failure is pkg.LauncherNotFoundFailure) {
      return LauncherNotFoundFailure(failure.message, failure.stackTrace);
    } else if (failure is pkg.FileSystemFailure) {
      return FileSystemFailure(failure.message, failure.stackTrace);
    } else if (failure is pkg.DatabaseFailure) {
      return DatabaseFailure(failure.message, failure.stackTrace);
    } else if (failure is pkg.ParseFailure) {
      return ParseFailure(failure.message, failure.stackTrace);
    }
    return UnexpectedFailure(failure.message, failure.stackTrace);
  }
}
