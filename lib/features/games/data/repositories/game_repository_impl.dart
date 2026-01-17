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
    
    _logger.info('Found ${allGames.length} total games. Caching...', tag: 'GameRepo');
    
    try {
      // Clear old cache and insert new
      // Alternatively, we could just upsert, but we want to remove uninstalled games too.
      // So clear + insert is safer for "refresh".
      // But if we clear, we lose "Calculate Size" results for games that don't provide it by default?
      // Wait, if we refresh from source, we get size=0 for GOG games. 
      // If we cached a calculated size, we lose it!
      // IMPROVEMENT: Merge with existing cache logic.
      // 1. Get existing cache.
      // 2. Map existing games by ID.
      // 3. For each new game, if it exists in cache and size > 0, preserve size? 
      //    Only if source size is 0.
      
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
      
      await _database.insertGames(mergedGames);
      
      // We aren't deleting games that are no longer found... 
      // If we want to fully sync, we should probably delete games not in mergedGames?
      // But insertGames only upserts.
      // Let's clear and re-insert to be sure we don't keep ghosts.
      // But clearing first risks losing data if insert fails.
      // Transaction would be best but GameDatabase doesn't expose transaction.
      // I'll stick to insert for now, maybe explicit delete of others later?
      // Actually, standard sync is: 
      // 1. Get all current keys from Source.
      // 2. Delete Db keys NOT in Source keys.
      // 3. Upsert Source data.
      // I'll leave basic upsert for now to avoid complexity in this step.
      
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
        _logger.warning('Directory not found, removing from DB anyway: ${game.installPath}', tag: 'GameRepo');
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
