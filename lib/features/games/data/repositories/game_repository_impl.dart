import 'dart:io';

import 'package:dartz/dartz.dart';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/error/failures.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/services/disk_size_service.dart';
import 'package:game_size_manager/features/games/data/datasources/heroic_datasource.dart';
import 'package:game_size_manager/features/games/data/datasources/lutris_datasource.dart';
import 'package:game_size_manager/features/games/data/datasources/ogi_datasource.dart';
import 'package:game_size_manager/features/games/data/datasources/steam_datasource.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
import 'package:game_size_manager/features/games/domain/repositories/game_repository.dart';

/// Real implementation of GameRepository
/// Reads from all configured launcher sources
class GameRepositoryImpl implements GameRepository {
  GameRepositoryImpl({
    HeroicDatasource? heroicDatasource,
    OgiDatasource? ogiDatasource,
    LutrisDatasource? lutrisDatasource,
    SteamDatasource? steamDatasource,
    DiskSizeService? diskSizeService,
    LoggerService? logger,
  }) : _heroic = heroicDatasource ?? HeroicDatasource(),
       _ogi = ogiDatasource ?? OgiDatasource(),
       _lutris = lutrisDatasource ?? LutrisDatasource(),
       _steam = steamDatasource ?? SteamDatasource(),
       _diskSize = diskSizeService ?? DiskSizeService.instance,
       _logger = logger ?? LoggerService.instance;
  
  final HeroicDatasource _heroic;
  final OgiDatasource _ogi;
  final LutrisDatasource _lutris;
  final SteamDatasource _steam;
  final DiskSizeService _diskSize;
  final LoggerService _logger;
  
  // Cache for performance
  List<Game>? _cachedGames;
  
  @override
  Future<Result<List<Game>>> getGames() async {
    if (_cachedGames != null) {
      return Right(_cachedGames!);
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
    
    _cachedGames = allGames;
    return Right(allGames);
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
      if (_cachedGames != null) {
        final index = _cachedGames!.indexWhere((g) => g.id == game.id);
        if (index >= 0) {
          _cachedGames![index] = updatedGame;
        }
      }
      
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
      
      if (!dir.existsSync()) {
        return Left(FileSystemFailure('Install directory not found: ${game.installPath}'));
      }
      
      // Delete the game directory
      await dir.delete(recursive: true);
      
      // Remove from cache
      _cachedGames?.removeWhere((g) => g.id == game.id);
      
      _logger.info('Successfully uninstalled: ${game.title}', tag: 'GameRepo');
      return const Right(null);
      
    } catch (e, s) {
      _logger.error('Failed to uninstall: ${game.title}', error: e, stackTrace: s, tag: 'GameRepo');
      return Left(UninstallFailure('Failed to uninstall ${game.title}: $e', s));
    }
  }
}
