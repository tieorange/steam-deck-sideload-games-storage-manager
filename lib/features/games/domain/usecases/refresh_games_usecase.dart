import 'package:game_size_manager/core/error/failures.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
import 'package:game_size_manager/features/games/domain/repositories/game_repository.dart';

class RefreshGamesUsecase {
  RefreshGamesUsecase(this._repository);

  final GameRepository _repository;

  Future<Result<List<Game>>> call({void Function(String message, double progress)? onProgress}) =>
      _repository.refreshGames(onProgress: onProgress);
}
