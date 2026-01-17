
import 'package:game_size_manager/core/error/failures.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
import 'package:game_size_manager/features/games/domain/repositories/game_repository.dart';

class UninstallGameUsecase {
  UninstallGameUsecase(this._repository);

  final GameRepository _repository;

  Future<Result<void>> call(Game game) => _repository.uninstallGame(game);
}
