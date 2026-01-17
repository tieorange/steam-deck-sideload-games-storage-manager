import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/error/failures.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/platform/platform_service.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// Data source for Lutris games
class LutrisDatasource {
  LutrisDatasource({
    PlatformService? platformService,
    LoggerService? logger,
  }) : _platform = platformService ?? PlatformService.instance,
       _logger = logger ?? LoggerService.instance;
  
  final PlatformService _platform;
  final LoggerService _logger;
  
  /// Initialize sqflite FFI for desktop
  void _initSqflite() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  /// Get all installed Lutris games from pga.db
  Future<Result<List<Game>>> getGames() async {
    final dbPath = _platform.lutrisDbPath;
    
    if (dbPath == null) {
      _logger.info('Lutris not installed', tag: 'Lutris');
      return const Right([]);
    }
    
    try {
      _initSqflite();
      
      final db = await openDatabase(dbPath, readOnly: true);
      
      // Query installed games
      final results = await db.rawQuery('''
        SELECT id, name, slug, directory 
        FROM games 
        WHERE installed = 1 AND directory IS NOT NULL AND directory != ''
      ''');
      
      final games = <Game>[];
      
      for (final row in results) {
        final id = row['id']?.toString() ?? '';
        final name = row['name'] as String? ?? 'Unknown';
        final slug = row['slug'] as String? ?? id;
        final directory = row['directory'] as String?;
        
        if (directory != null && directory.isNotEmpty) {
          games.add(Game(
            id: 'lutris_$slug',
            title: name,
            source: GameSource.lutris,
            installPath: directory,
            sizeBytes: 0, // Needs calculation
          ));
        }
      }
      
      await db.close();
      
      _logger.info('Found ${games.length} Lutris games', tag: 'Lutris');
      return Right(games);
      
    } catch (e, s) {
      _logger.error('Failed to read Lutris database', error: e, stackTrace: s, tag: 'Lutris');
      return Left(DatabaseFailure('Failed to read Lutris database: $e', s));
    }
  }
}
