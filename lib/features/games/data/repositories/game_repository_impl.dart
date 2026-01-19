import 'dart:io';

import 'package:dartz/dartz.dart';

import 'package:game_size_manager/features/games/data/datasources/heroic_datasource.dart';
import 'package:game_size_manager/features/games/data/datasources/lutris_datasource.dart';
import 'package:game_size_manager/features/games/data/datasources/ogi_datasource.dart';
import 'package:game_size_manager/features/games/data/datasources/steam_datasource.dart';
import 'package:game_size_manager/features/games/data/datasources/game_local_datasource.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
import 'package:game_size_manager/features/games/domain/repositories/game_repository.dart';
import 'package:game_size_manager/core/error/failures.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/services/disk_size_service.dart';
import 'package:game_size_manager/core/constants.dart';

/// Real implementation of GameRepository with SQLite Caching
class GameRepositoryImpl implements GameRepository {
  final HeroicDatasource _heroic;
  final OgiDatasource _ogi;
  final LutrisDatasource _lutris;
  final SteamDatasource _steam;
  final DiskSizeService _diskSizeService;
  final GameLocalDatasource _localDatasource;
  final LoggerService _logger;

  GameRepositoryImpl({
    required HeroicDatasource heroicDatasource,
    required OgiDatasource ogiDatasource,
    required LutrisDatasource lutrisDatasource,
    required SteamDatasource steamDatasource,
    required DiskSizeService diskSizeService,
    required GameLocalDatasource localDatasource,
    LoggerService? logger,
  }) : _heroic = heroicDatasource,
       _ogi = ogiDatasource,
       _lutris = lutrisDatasource,
       _steam = steamDatasource,
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
  Future<Result<List<Game>>> refreshGames() async {
    _logger.info('Refreshing all games...', tag: 'GameRepo');
    final allGames = <Game>[];

    // 1. Fetch from all sources in parallel
    final results = await Future.wait([
      _heroic.getGames(),
      _ogi.getGames(),
      _lutris.getGames(),
      _steam.getGames(),
    ]);

    // 2. Process results
    for (final result in results) {
      result.fold(
        (failure) => _logger.warning('Datasource failure: ${failure.runtimeType}', tag: 'GameRepo'),
        (games) => allGames.addAll(games),
      );
    }

    _logger.info('Found ${allGames.length} games total from sources.', tag: 'GameRepo');

    // 3. Calculate sizes for games that need it
    // Some sources (like OGI or Lutris) might not provide size.
    try {
      final sizedGames = await Future.wait(
        allGames.map((game) async {
          if (game.sizeBytes == 0 && game.installPath.isNotEmpty) {
            try {
              // Basic size calculation if not provided
              // This might be slow for many games, so user might see "calculating..." or initially 0
              // Ideally this should be backgrounded.
              // For now, check if directory exists first
              final dir = Directory(game.installPath);
              if (await dir.exists()) {
                final size = await _diskSizeService.calculateDirectorySize(game.installPath);
                return game.copyWith(sizeBytes: size);
              }
            } catch (e) {
              _logger.warning('Failed to calculate size for ${game.title}: $e', tag: 'GameRepo');
            }
          }
          return game;
        }),
      );

      // Cache games
      // We clear cache then insert to ensure deleted games are removed
      await _localDatasource.clearCache();
      await _localDatasource.cacheGames(sizedGames);

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
  }

  @override
  Future<Result<Game>> calculateGameSize(Game game) async {
    try {
      final size = await _diskSizeService.calculateDirectorySize(game.installPath);
      // Update cache with new size
      final updatedGame = game.copyWith(sizeBytes: size);
      await _localDatasource.cacheGames([updatedGame]); // Upsert
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
