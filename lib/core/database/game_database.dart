import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

class GameDatabase {
  static final GameDatabase instance = GameDatabase._init();
  static Database? _database;

  GameDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('games.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationSupportDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE games (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        source TEXT NOT NULL,
        install_path TEXT NOT NULL,
        size_bytes INTEGER NOT NULL,
        icon_path TEXT
      )
    ''');
  }

  Future<void> insertGames(List<Game> games) async {
    final db = await database;
    final batch = db.batch();
    
    // Clear existing data? Or upsert?
    // Strategy: Clear all and re-insert is simplest for caching "current state"
    // But if we want to preserve things, upsert is better.
    // Given this is a cache of "what's installed", clearing and refilling matches "refresh".
    // But we might want to just upsert to keep data if refresh fails?
    // Let's use INSERT OR REPLACE.
    
    for (final game in games) {
      batch.insert(
        'games',
        _gameToMap(game),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }
  
  Future<void> deleteGame(String id) async {
    final db = await database;
    await db.delete(
      'games',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearGames() async {
    final db = await database;
    await db.delete('games');
  }

  Future<List<Game>> getAllGames() async {
    final db = await database;
    final maps = await db.query('games');

    return maps.map(_mapToGame).toList();
  }
  
  Map<String, dynamic> _gameToMap(Game game) {
    return {
      'id': game.id,
      'title': game.title,
      'source': game.source.name,
      'install_path': game.installPath,
      'size_bytes': game.sizeBytes,
      'icon_path': game.iconPath,
    };
  }
  
  Game _mapToGame(Map<String, dynamic> map) {
    return Game(
      id: map['id'] as String,
      title: map['title'] as String,
      source: GameSource.values.firstWhere(
        (e) => e.name == map['source'],
        orElse: () => GameSource.steam,
      ),
      installPath: map['install_path'] as String,
      sizeBytes: map['size_bytes'] as int,
      iconPath: map['icon_path'] as String?,
    );
  }
}
