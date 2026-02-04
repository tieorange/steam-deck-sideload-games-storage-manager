import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
import 'package:game_size_manager/features/games/domain/entities/game_tag.dart';

class GameDatabase {
  static final GameDatabase instance = GameDatabase._init();
  static Database? _database;

  GameDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('games.db');
    return _database!;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationSupportDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
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
        icon_path TEXT,
        storage_location TEXT NOT NULL DEFAULT 'internal',
        tag TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE cache_metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE storage_snapshots (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        total_bytes INTEGER NOT NULL,
        used_bytes INTEGER NOT NULL,
        free_bytes INTEGER NOT NULL,
        game_count INTEGER NOT NULL,
        games_total_size INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE games ADD COLUMN storage_location TEXT NOT NULL DEFAULT \'internal\'');
      await db.execute('ALTER TABLE games ADD COLUMN tag TEXT');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS cache_metadata (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS storage_snapshots (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp TEXT NOT NULL,
          total_bytes INTEGER NOT NULL,
          used_bytes INTEGER NOT NULL,
          free_bytes INTEGER NOT NULL,
          game_count INTEGER NOT NULL,
          games_total_size INTEGER NOT NULL
        )
      ''');
    }
  }

  // ============================================
  // Games CRUD
  // ============================================

  Future<void> insertGames(List<Game> games) async {
    final db = await database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final game in games) {
        batch.insert('games', _gameToMap(game), conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> deleteGame(String id) async {
    final db = await database;
    await db.delete('games', where: 'id = ?', whereArgs: [id]);
  }

  /// Batch delete games by IDs using a single query
  Future<void> deleteGamesBatch(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.delete('games', where: 'id IN ($placeholders)', whereArgs: ids);
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

  // ============================================
  // Game Tags
  // ============================================

  Future<void> updateGameTag(String gameId, GameTag? tag) async {
    final db = await database;
    await db.update(
      'games',
      {'tag': tag?.name},
      where: 'id = ?',
      whereArgs: [gameId],
    );
  }

  // ============================================
  // Cache Metadata (TTL)
  // ============================================

  Future<void> setMetadata(String key, String value) async {
    final db = await database;
    await db.insert(
      'cache_metadata',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getMetadata(String key) async {
    final db = await database;
    final result = await db.query(
      'cache_metadata',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isEmpty) return null;
    return result.first['value'] as String?;
  }

  /// Get the last refresh timestamp
  Future<DateTime?> getLastRefreshTime() async {
    final value = await getMetadata('last_refresh');
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  /// Set the last refresh timestamp to now
  Future<void> updateLastRefreshTime() async {
    await setMetadata('last_refresh', DateTime.now().toIso8601String());
  }

  // ============================================
  // Storage Snapshots (Timeline)
  // ============================================

  Future<void> insertStorageSnapshot({
    required int totalBytes,
    required int usedBytes,
    required int freeBytes,
    required int gameCount,
    required int gamesTotalSize,
  }) async {
    final db = await database;
    await db.insert('storage_snapshots', {
      'timestamp': DateTime.now().toIso8601String(),
      'total_bytes': totalBytes,
      'used_bytes': usedBytes,
      'free_bytes': freeBytes,
      'game_count': gameCount,
      'games_total_size': gamesTotalSize,
    });
  }

  Future<List<Map<String, dynamic>>> getStorageSnapshots({int limit = 30}) async {
    final db = await database;
    return db.query(
      'storage_snapshots',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
  }

  // ============================================
  // Mapping
  // ============================================

  Map<String, dynamic> _gameToMap(Game game) {
    return {
      'id': game.id,
      'title': game.title,
      'source': game.source.name,
      'install_path': game.installPath,
      'size_bytes': game.sizeBytes,
      'icon_path': game.iconPath,
      'storage_location': game.storageLocation.name,
      'tag': game.tag?.name,
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
      storageLocation: StorageLocation.values.firstWhere(
        (e) => e.name == (map['storage_location'] as String? ?? 'internal'),
        orElse: () => StorageLocation.internal,
      ),
      tag: _parseTag(map['tag'] as String?),
    );
  }

  GameTag? _parseTag(String? tagName) {
    if (tagName == null) return null;
    return GameTag.values.where((t) => t.name == tagName).firstOrNull;
  }
}
