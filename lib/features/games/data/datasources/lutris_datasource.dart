import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:game_size_manager/features/games/data/models/lutris_game_dto.dart';

import 'package:game_size_manager/core/error/failures.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/platform/platform_service.dart';
import 'package:game_size_manager/features/games/data/datasources/game_datasource.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// Data source for Lutris games
class LutrisDatasource implements GameDatasource {
  LutrisDatasource({PlatformService? platformService, LoggerService? logger})
    : _platform = platformService ?? PlatformService.instance,
      _logger = logger ?? LoggerService.instance;

  final PlatformService _platform;
  final LoggerService _logger;

  /// Get all installed Lutris games from pga.db
  @override
  Future<Result<List<Game>>> getGames() async {
    _logger.info('============ LUTRIS DETECTION ============', tag: 'Lutris');
    final dbPath = _platform.lutrisDbPath;
    _logger.info('Lutris DB path: $dbPath', tag: 'Lutris');

    if (dbPath == null) {
      _logger.info('Lutris not installed', tag: 'Lutris');
      return const Right([]);
    }

    try {
      // sqflite initialized in main.dart

      final db = await openDatabase(dbPath, readOnly: true);

      // Query installed games
      final results = await db.rawQuery('''
        SELECT id, name, slug, directory 
        FROM games 
        WHERE installed = 1 AND directory IS NOT NULL AND directory != ''
      ''');

      final games = <Game>[];

      _logger.debug('Query returned ${results.length} rows', tag: 'Lutris');

      for (final row in results) {
        try {
          final dto = LutrisGameDto.fromMap(row);
          if (dto.directory != null && dto.directory!.isNotEmpty) {
            _logger.debug(
              'Found Lutris game: ${dto.name} (${dto.slug}) at ${dto.directory}',
              tag: 'Lutris',
            );
            games.add(dto.toEntity());
          } else {
            _logger.warning(
              'Skipping Lutris game ${dto.name}: directory is empty/null',
              tag: 'Lutris',
            );
          }
        } catch (e) {
          // Skip
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
