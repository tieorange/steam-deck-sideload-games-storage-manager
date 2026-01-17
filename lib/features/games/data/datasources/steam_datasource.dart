import 'dart:io';

import 'package:dartz/dartz.dart';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/error/failures.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/platform/platform_service.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// Data source for Steam games
class SteamDatasource {
  SteamDatasource({
    PlatformService? platformService,
    LoggerService? logger,
  }) : _platform = platformService ?? PlatformService.instance,
       _logger = logger ?? LoggerService.instance;
  
  final PlatformService _platform;
  final LoggerService _logger;
  
  /// Get all installed Steam games from appmanifest files
  Future<Result<List<Game>>> getGames() async {
    if (!_platform.isSteamInstalled) {
      _logger.info('Steam not installed', tag: 'Steam');
      return const Right([]);
    }
    
    try {
      final games = <Game>[];
      final libraryPaths = _platform.allSteamLibraryPaths;
      
      for (final libraryPath in libraryPaths) {
        final dir = Directory(libraryPath);
        if (!dir.existsSync()) continue;
        
        await for (final entity in dir.list()) {
          if (entity is File && entity.path.contains('appmanifest_') && entity.path.endsWith('.acf')) {
            try {
              final game = await _parseAppManifest(entity);
              if (game != null) {
                games.add(game);
              }
            } catch (e) {
              _logger.warning('Failed to parse: ${entity.path}', tag: 'Steam');
            }
          }
        }
      }
      
      _logger.info('Found ${games.length} Steam games', tag: 'Steam');
      return Right(games);
      
    } catch (e, s) {
      _logger.error('Failed to read Steam library', error: e, stackTrace: s, tag: 'Steam');
      return Left(FileSystemFailure('Failed to read Steam library: $e', s));
    }
  }
  
  /// Parse a single appmanifest_*.acf file
  Future<Game?> _parseAppManifest(File file) async {
    final content = await file.readAsString();
    
    // Simple VDF parsing for the fields we need
    final appId = _extractVdfValue(content, 'appid');
    final name = _extractVdfValue(content, 'name');
    final installDir = _extractVdfValue(content, 'installdir');
    final sizeOnDisk = _extractVdfValue(content, 'SizeOnDisk');
    
    if (appId == null || name == null || installDir == null) {
      return null;
    }
    
    // Get full install path
    final steamappsDir = file.parent.path;
    final commonDir = '$steamappsDir/common/$installDir';
    
    // Parse size (Steam provides this in bytes as a string)
    final sizeBytes = int.tryParse(sizeOnDisk ?? '0') ?? 0;
    
    return Game(
      id: 'steam_$appId',
      title: name,
      source: GameSource.steam,
      installPath: commonDir,
      sizeBytes: sizeBytes,
    );
  }
  
  /// Extract a value from VDF format content
  /// VDF format example: "name"  "Elden Ring"
  String? _extractVdfValue(String content, String key) {
    // Match both tab and space as separators
    final regex = RegExp('"$key"\\s+"([^"]*)"', caseSensitive: false);
    final match = regex.firstMatch(content);
    return match?.group(1);
  }
}
