import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:steam_deck_games_detector/steam_deck_games_detector.dart' as pkg;

import 'package:game_size_manager/features/games/data/datasources/game_local_datasource.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
import 'package:game_size_manager/features/games/domain/repositories/game_repository.dart';
import 'package:game_size_manager/core/error/failures.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/services/disk_size_service.dart';
import 'package:game_size_manager/core/database/game_database.dart';
import 'package:game_size_manager/core/constants.dart';

/// Real implementation of GameRepository with SQLite Caching
class GameRepositoryImpl implements GameRepository {
  final pkg.SteamDeckGamesDetector _detector;
  final DiskSizeService _diskSizeService;
  final GameLocalDatasource _localDatasource;
  final LoggerService _logger;

  /// Concurrent refresh protection
  Completer<Result<List<Game>>>? _refreshCompleter;

  /// Cache TTL - auto-refresh if older than this
  static const _cacheTtl = Duration(hours: 1);

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
        (games) async {
          if (games.isEmpty) {
            _logger.info('Cache empty, refreshing...', tag: 'GameRepo');
            return refreshGames();
          }

          // Check cache staleness
          final lastRefresh = await GameDatabase.instance.getLastRefreshTime();
          if (lastRefresh != null) {
            final age = DateTime.now().difference(lastRefresh);
            if (age > _cacheTtl) {
              _logger.info('Cache is stale (${age.inMinutes}m old), refreshing...', tag: 'GameRepo');
              return refreshGames();
            }
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
    // Concurrent refresh protection: if already refreshing, wait for the result
    if (_refreshCompleter != null) {
      _logger.info('Refresh already in progress, waiting...', tag: 'GameRepo');
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<Result<List<Game>>>();

    try {
      final result = await _doRefresh(onProgress);
      _refreshCompleter!.complete(result);
      return result;
    } catch (e, s) {
      final failure = Left<Failure, List<Game>>(UnexpectedFailure('Refresh failed: $e', s));
      _refreshCompleter!.complete(failure);
      return failure;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<Result<List<Game>>> _doRefresh(
    void Function(String message, double progress)? onProgress,
  ) async {
    _logger.info('Refreshing all games via SteamDeckGamesDetector...', tag: 'GameRepo');

    onProgress?.call('Scanning games...', 0.3);

    // 1. Fetch from SteamDeckGamesDetector
    final result = await _detector.getAllGames();

    return result.fold(
      (failure) {
        _logger.error('Detector failed: $failure', tag: 'GameRepo');
        return Left(_mapFailure(failure));
      },
      (pkgGames) async {
        _logger.info('Found ${pkgGames.length} games from detector.', tag: 'GameRepo');

        onProgress?.call('Processing results...', 0.5);

        // Convert to App Entities
        final allGames = pkgGames.map((g) => Game.fromPackage(g)).toList();

        // Preserve existing tags from cache
        final cachedResult = await _localDatasource.getCachedGames();
        final tagMap = <String, dynamic>{};
        cachedResult.fold((_) {}, (cached) {
          for (final g in cached) {
            if (g.tag != null) tagMap[g.id] = g.tag;
          }
        });

        // 3. Calculate sizes with throttling (max 4 concurrent)
        onProgress?.call('Calculating sizes...', 0.6);

        final List<Game> sizedGames = [];
        const maxConcurrent = 4;

        for (var i = 0; i < allGames.length; i += maxConcurrent) {
          final chunk = allGames.skip(i).take(maxConcurrent);
          final results = await Future.wait(
            chunk.map((game) async {
              try {
                var updatedGame = game;
                // Restore tag from cache
                if (tagMap.containsKey(game.id)) {
                  updatedGame = updatedGame.copyWith(tag: tagMap[game.id]);
                }

                if (updatedGame.sizeBytes == 0 && updatedGame.installPath.isNotEmpty) {
                  final dir = Directory(updatedGame.installPath);
                  if (await dir.exists()) {
                    final size = await _diskSizeService.calculateDirectorySize(
                      updatedGame.installPath,
                    );
                    updatedGame = updatedGame.copyWith(sizeBytes: size);
                  }
                }
                return updatedGame;
              } catch (e) {
                _logger.warning('Failed to process/size game ${game.title}: $e', tag: 'GameRepo');
                return game;
              }
            }),
          );
          sizedGames.addAll(results);

          // Update progress
          final progress = 0.6 + (i / allGames.length) * 0.25;
          onProgress?.call('Calculating sizes (${sizedGames.length}/${allGames.length})...', progress);
        }

        onProgress?.call('Caching games...', 0.9);

        // Cache games
        try {
          await _localDatasource.clearCache();
          await _localDatasource.cacheGames(sizedGames);
          await GameDatabase.instance.updateLastRefreshTime();
        } catch (e) {
          _logger.error('Failed to cache games: $e', tag: 'GameRepo');
        }

        onProgress?.call('Complete!', 1.0);

        return Right(sizedGames);
      },
    );
  }

  @override
  Future<Result<Game>> calculateGameSize(Game game) async {
    try {
      final size = await _diskSizeService.calculateDirectorySize(game.installPath);
      final updatedGame = game.copyWith(sizeBytes: size);
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
      return Left(UninstallFailure('Failed to uninstall: $e', s));
    }
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
