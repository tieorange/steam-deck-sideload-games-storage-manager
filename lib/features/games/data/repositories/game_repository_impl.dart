import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:steam_deck_games_detector/steam_deck_games_detector.dart' as pkg;

import 'package:game_size_manager/features/games/data/datasources/game_local_datasource.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
import 'package:game_size_manager/features/games/domain/repositories/game_repository.dart';
import 'package:game_size_manager/core/error/failures.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/services/disk_size_service.dart';
import 'package:game_size_manager/core/constants.dart';

/// Real implementation of GameRepository with SQLite Caching
class GameRepositoryImpl implements GameRepository {
  final pkg.SteamDeckGamesDetector _detector;
  final DiskSizeService _diskSizeService;
  final GameLocalDatasource _localDatasource;
  final LoggerService _logger;

  GameRepositoryImpl({
    required pkg.SteamDeckGamesDetector detector,
    required DiskSizeService diskSizeService,
    required GameLocalDatasource localDatasource,
    LoggerService? logger,
  }) : _detector = detector,

       _diskSizeService = diskSizeService,
       _localDatasource = localDatasource,
       _logger = logger ?? LoggerService.instance;

  @override
  Future<Result<List<Game>>> getGames() async {
    try {
      // First try to load from database
      final cachedResult = await _localDatasource.getCachedGames();

      return cachedResult.fold(
        (failure) {
          _logger.warning('Failed to load from cache, refreshing...', tag: 'GameRepo');
          return refreshGames();
        },
        (games) {
          if (games.isEmpty) {
            _logger.info('Cache empty, refreshing...', tag: 'GameRepo');
            return refreshGames();
          }
          _logger.info('Loaded ${games.length} games from cache', tag: 'GameRepo');
          return Right(games);
        },
      );
    } catch (e, s) {
      _logger.error(
        'Unexpected error loading games from cache',
        error: e,
        stackTrace: s,
        tag: 'GameRepo',
      );
      return refreshGames();
    }
  }

  @override
  Future<Result<List<Game>>> getGamesBySource(GameSource source) async {
    final result = await getGames();
    return result.map((games) => games.where((g) => g.source == source).toList());
  }

  @override
  Future<Result<List<Game>>> refreshGames({
    void Function(String message, double progress)? onProgress,
  }) async {
    _logger.info('Refreshing all games via SteamDeckGamesDetector...', tag: 'GameRepo');

    onProgress?.call('Scanning games...', 0.3);

    // 1. Fetch from SteamDeckGamesDetector
    final result = await _detector.getAllGames();

    return result.fold(
      (failure) {
        _logger.error('Detector failed: $failure', tag: 'GameRepo');
        // Map package failure to app failure
        // Assuming we have a similar structure or just wrap it
        return Left(UnexpectedFailure(failure.message, failure.stackTrace));
      },
      (pkgGames) async {
        _logger.info('Found ${pkgGames.length} games from detector.', tag: 'GameRepo');

        onProgress?.call('Processing results...', 0.5);

        // Convert to App Entities
        final allGames = pkgGames.map((g) => Game.fromPackage(g)).toList();

        // 3. Calculate sizes for games that need it
        onProgress?.call('Calculating sizes...', 0.6);
        try {
          final sizedGames = await Future.wait(
            allGames.map((game) async {
              var updatedGame = game;

              // Storage location is already detected by package!
              // But if size is 0, we try to calc it.

              if (updatedGame.sizeBytes == 0 && updatedGame.installPath.isNotEmpty) {
                try {
                  final dir = Directory(updatedGame.installPath);
                  if (await dir.exists()) {
                    final size = await _diskSizeService.calculateDirectorySize(
                      updatedGame.installPath,
                    );
                    updatedGame = updatedGame.copyWith(sizeBytes: size);
                  }
                } catch (e) {
                  _logger.warning(
                    'Failed to calculate size for ${updatedGame.title}: $e',
                    tag: 'GameRepo',
                  );
                }
              }
              return updatedGame;
            }),
          );

          onProgress?.call('Caching games...', 0.9);

          // Cache games
          await _localDatasource.clearCache();
          await _localDatasource.cacheGames(sizedGames);

          onProgress?.call('Complete!', 1.0);

          return Right(sizedGames);
        } catch (e, s) {
          _logger.error(
            'Failed processing games during refresh',
            error: e,
            stackTrace: s,
            tag: 'GameRepo',
          );
          return Left(UnexpectedFailure(e.toString(), s));
        }
      },
    );
  }

  @override
  Future<Result<Game>> calculateGameSize(Game game) async {
    try {
      final size = await _diskSizeService.calculateDirectorySize(game.installPath);
      // Update cache with new size
      final updatedGame = game.copyWith(sizeBytes: size);

      // Upsert requires list
      await _localDatasource.cacheGames([updatedGame]);
      return Right(updatedGame);
    } catch (e, s) {
      return Left(FileSystemFailure('Failed to calculate size: $e', s));
    }
  }

  @override
  Future<Result<void>> uninstallGame(Game game) async {
    _logger.info('Uninstalling: ${game.title}', tag: 'GameRepo');

    try {
      final dir = Directory(game.installPath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      } else {
        _logger.warning('Directory not found: ${game.installPath}', tag: 'GameRepo');
      }

      // Remove from cache
      await _localDatasource.deleteGames([game.id]);

      return const Right(null);
    } catch (e, s) {
      _logger.error('Failed to uninstall ${game.title}', error: e, stackTrace: s, tag: 'GameRepo');
      return Left(UninstallFailure('Failed to uninstall: $e', s));
    }
  }
}
