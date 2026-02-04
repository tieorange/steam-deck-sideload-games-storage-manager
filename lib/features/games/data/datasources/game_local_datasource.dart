import 'package:dartz/dartz.dart';
import 'package:game_size_manager/core/database/game_database.dart';
import 'package:game_size_manager/core/error/failures.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// Interface for local game storage (cache)
abstract class GameLocalDatasource {
  /// Get all cached games
  Future<Result<List<Game>>> getCachedGames();

  /// Cache a list of games (replacing existing ones or upserting)
  Future<Result<void>> cacheGames(List<Game> games);

  /// Clear all cached games
  Future<Result<void>> clearCache();

  /// Delete specific games by ID
  Future<Result<void>> deleteGames(List<String> gameIds);
}

/// Implementation of GameLocalDatasource using SQLite
class GameLocalDatasourceImpl implements GameLocalDatasource {
  final GameDatabase _database;

  GameLocalDatasourceImpl(this._database);

  @override
  Future<Result<List<Game>>> getCachedGames() async {
    try {
      final games = await _database.getAllGames();
      return Right(games);
    } catch (e, s) {
      return Left(DatabaseFailure('Failed to load cached games: $e', s));
    }
  }

  @override
  Future<Result<void>> cacheGames(List<Game> games) async {
    try {
      if (games.isEmpty) return const Right(null);
      await _database.insertGames(games);
      return const Right(null);
    } catch (e, s) {
      return Left(DatabaseFailure('Failed to cache games: $e', s));
    }
  }

  @override
  Future<Result<void>> clearCache() async {
    try {
      await _database.clearGames();
      return const Right(null);
    } catch (e, s) {
      return Left(DatabaseFailure('Failed to clear game cache: $e', s));
    }
  }

  @override
  Future<Result<void>> deleteGames(List<String> gameIds) async {
    try {
      if (gameIds.isEmpty) return const Right(null);
      await _database.deleteGamesBatch(gameIds);
      return const Right(null);
    } catch (e, s) {
      return Left(DatabaseFailure('Failed to delete games from cache: $e', s));
    }
  }
}
