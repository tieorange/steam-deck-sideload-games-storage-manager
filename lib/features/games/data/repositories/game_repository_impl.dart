import 'dart:io';

import 'package:dartz/dartz.dart';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/database/game_database.dart';
import 'package:game_size_manager/core/error/failures.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/services/disk_size_service.dart';
import 'package:game_size_manager/features/games/data/datasources/heroic_datasource.dart';
import 'package:game_size_manager/features/games/data/datasources/lutris_datasource.dart';
import 'package:game_size_manager/features/games/data/datasources/ogi_datasource.dart';
import 'package:game_size_manager/features/games/data/datasources/steam_datasource.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
import 'package:game_size_manager/features/games/domain/repositories/game_repository.dart';

/// Real implementation of GameRepository with SQLite Caching
class GameRepositoryImpl implements GameRepository {
  GameRepositoryImpl({
    required HeroicDatasource heroicDatasource,
    required OgiDatasource ogiDatasource,
    required LutrisDatasource lutrisDatasource,
    required SteamDatasource steamDatasource,
    required DiskSizeService diskSizeService,
    required GameDatabase gameDatabase,
    LoggerService? logger,
  }) : _heroic = heroicDatasource,
       _ogi = ogiDatasource,
       _lutris = lutrisDatasource,
       _steam = steamDatasource,
       _diskSize = diskSizeService,
       _database = gameDatabase,
       _logger = logger ?? LoggerService.instance;

  final HeroicDatasource _heroic;
  final OgiDatasource _ogi;
  final LutrisDatasource _lutris;
  final SteamDatasource _steam;
  final DiskSizeService _diskSize;
  final GameDatabase _database;
  final LoggerService _logger;

  @override
  Future<Result<List<Game>>> getGames() async {
    try {
      final cachedGames = await _database.getAllGames();
      if (cachedGames.isNotEmpty) {
        _logger.info('Loaded ${cachedGames.length} games from cache', tag: 'GameRepo');
        return Right(cachedGames);
      }
    } catch (e, s) {
      _logger.error('Failed to load from cache', error: e, stackTrace: s, tag: 'GameRepo');
      // Fallback to refresh if cache fails
    }

    return refreshGames();
  }

  @override
  Future<Result<List<Game>>> getGamesBySource(GameSource source) async {
    final result = await getGames();
    return result.map((games) => games.where((g) => g.source == source).toList());
  }

  @override
  Future<Result<List<Game>>> refreshGames() async {
    _logger.info('Refreshing games from all sources', tag: 'GameRepo');

    final allGames = <Game>[];

    // Gather games from all sources
    final heroicResult = await _heroic.getAllGames();
    heroicResult.fold(
      (f) => _logger.warning('Heroic error: ${f.message}', tag: 'GameRepo'),
      (games) => allGames.addAll(games),
    );

    final ogiResult = await _ogi.getGames();
    ogiResult.fold(
      (f) => _logger.warning('OGI error: ${f.message}', tag: 'GameRepo'),
      (games) => allGames.addAll(games),
    );

    final lutrisResult = await _lutris.getGames();
    lutrisResult.fold(
      (f) => _logger.warning('Lutris error: ${f.message}', tag: 'GameRepo'),
      (games) => allGames.addAll(games),
    );

    final steamResult = await _steam.getGames();
    steamResult.fold(
      (f) => _logger.warning('Steam error: ${f.message}', tag: 'GameRepo'),
      (games) => allGames.addAll(games),
    );

    _logger.info('Found ${allGames.length} total games', tag: 'GameRepo');

    // Calculate sizes for games that don't have them (Lutris, GOG, etc.)
    final gamesNeedingSize = allGames.where((g) => g.sizeBytes == 0).toList();
    if (gamesNeedingSize.isNotEmpty) {
      _logger.info('Calculating sizes for ${gamesNeedingSize.length} games...', tag: 'GameRepo');

      // Calculate sizes in parallel for better performance
      final sizeResults = await Future.wait(
        gamesNeedingSize.map((game) async {
          try {
            final size = await _diskSize.calculateDirectorySize(game.installPath);
            return MapEntry(game.id, size);
          } catch (e) {
            _logger.warning('Failed to calculate size for ${game.title}: $e', tag: 'GameRepo');
            return MapEntry(game.id, 0);
          }
        }),
      );

      // Update games with calculated sizes
      final sizeMap = Map.fromEntries(sizeResults);
      for (var i = 0; i < allGames.length; i++) {
        final game = allGames[i];
        if (sizeMap.containsKey(game.id) && sizeMap[game.id]! > 0) {
          allGames[i] = game.copyWith(sizeBytes: sizeMap[game.id]!);
        }
      }

      _logger.info('Size calculation complete', tag: 'GameRepo');
    }

    _logger.info('Caching ${allGames.length} games...', tag: 'GameRepo');

    try {
      // Clear old cache and insert new
      // Alternatively, we could just upsert, but we want to remove uninstalled games too.
      // So clear + insert is safer for "refresh".
      // Sync cache: replace all games to ensure stale entries are removed
      // First, preserve calculated sizes if not available in fresh data
      final cachedGames = await _database.getAllGames();
      final cachedMap = {for (var g in cachedGames) g.id: g};

      final mergedGames = allGames.map((game) {
        if (game.sizeBytes == 0 && cachedMap.containsKey(game.id)) {
          final cached = cachedMap[game.id]!;
          if (cached.sizeBytes > 0) {
            return game.copyWith(sizeBytes: cached.sizeBytes);
          }
        }
        return game;
      }).toList();

      // Perform full sync inside a transaction (if supported) or just clear and insert
      // Clearing first is safer to remove ghosts
      await _database.clearGames();
      await _database.insertGames(mergedGames);

      return Right(mergedGames);
    } catch (e, s) {
      _logger.error('Failed to cache games', error: e, stackTrace: s, tag: 'GameRepo');
      // Return games anyway, just without caching persistence working
      return Right(allGames);
    }
  }

  @override
  Future<Result<Game>> calculateGameSize(Game game) async {
    // Some sources already provide size (Epic, Steam)
    if (game.sizeBytes > 0) {
      return Right(game);
    }

    try {
      final size = await _diskSize.calculateDirectorySize(game.installPath);
      final updatedGame = game.copyWith(sizeBytes: size);

      // Update cache
      await _database.insertGames([updatedGame]);

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
        // Delete the game directory
        await dir.delete(recursive: true);
      } else {
        _logger.warning(
          'Directory not found, removing from DB anyway: ${game.installPath}',
          tag: 'GameRepo',
        );
      }

      // Remove from cache
      await _database.deleteGame(game.id);

      _logger.info('Successfully uninstalled: ${game.title}', tag: 'GameRepo');
      return const Right(null);
    } catch (e, s) {
      _logger.error('Failed to uninstall: ${game.title}', error: e, stackTrace: s, tag: 'GameRepo');
      return Left(UninstallFailure('Failed to uninstall ${game.title}: $e', s));
    }
  }
}
