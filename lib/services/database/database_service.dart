import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models.dart';

class DatabaseServicePlayer {
  // 1. Create the Singleton instance
  static final DatabaseServicePlayer instance = DatabaseServicePlayer._init();
  static Database? _database;

  DatabaseServicePlayer._init();

  // 2. Open the database (or create it if it doesn't exist)
  Future<Database> get database async {
    if (_database != null) return _database!;

    //await deleteDatabase(path);
    

    _database = await _initDB('oligarch_db.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB, // Called only the very first time the app runs
    );
  }

  // 3. Create the Tables
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE players (
        id $idType,
        username $textType,
        cash $intType,
        netWorth $intType,
        propertiesOwnershipShares $textType,
        propertiesVotershare $textType,
        position $intType,
        inJail $intType,
        jailTurns $intType,
        activeLoans $textType,
        playerTurn $intType,
        isCurrentPlayer $textType
      )
    ''');
  }

  // --- CRUD OPERATIONS ---

  // CREATE: Insert a new player
  Future<int> insertPlayer(Player player) async {
    final db = await instance.database;
    return await db.insert(
      'players',
      player.toMap(isDatabase: true),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Player?> getPlayer(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      'players',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Player.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<dynamic> getParamofPlayer(int id, String param) async {
    final db = await instance.database;

    final maps = await db.query(
      'players',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return maps.first[param];
    } else {
      return null;
    }
  }

  Future<List<Player>> getAllPlayers() async {
    final db = await instance.database;
    final maps = await db.query('players'); // Returns a List of Maps

    return maps.map((json) => Player.fromMap(json)).toList();
  }

  Future<int> updatePlayer(Player player) async {
    final db = await instance.database;
    return await db.update(
      'players',
      player.toMap(),
      where: 'id = ?',
      whereArgs: [player.id], // Prevents SQL injection
    );
  }

  Future<int> deletePlayer(int id) async {
    final db = await instance.database;
    return await db.delete('players', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> clearAllPLayers() async {
    final db = await instance.database;
    await db.delete('players');
  }
}
