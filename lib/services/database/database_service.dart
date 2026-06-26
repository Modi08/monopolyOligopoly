import 'package:flutter/rendering.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models.dart';

class DatabaseService {
  // 1. Create the Singleton instance
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

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
      onCreate: _createDB,
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
        propertiesVoterShares $textType,
        position $intType,
        inJail $intType,
        jailTurns $intType,
        activeLoans $textType,
        playerTurn $intType,
        isCurrentPlayer $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE properties (
        id $idType,
        name $textType,
        type $intType,
        color $intType,
        price $intType,
        rent $textType,
        houseCost $intType,
        houses $intType,
        ownershipShares $textType,
        voterShares $textType,
        valuation $intType
      )
    ''');
  }

  // --- Player Operations ---

  Future<int> insertPlayer(Player player) async {
    final db = await instance.database;
    debugPrint("${player.toMap(isDatabase: true)["propertiesOwnershipShares"].runtimeType}");
    return await db.insert(
      'players',
      player.toMap(isDatabase: true),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Player?> getPlayer(int id) async {
    final db = await instance.database;

    final maps = await db.query('players', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      debugPrint(maps.first.toString());
      return Player.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<dynamic> getParamofPlayer(int id, String param) async {
    final db = await instance.database;

    final maps = await db.query('players', where: 'id = ?', whereArgs: [id]);

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

Future<int> updatePlayerParam(int playerId, String key, dynamic value) async {
    final db = await instance.database;
    
    return await db.update(
      'players', 
      {key: value},
      where: 'id = ?',
      whereArgs: [playerId],
    );
  }

  Future<int> deletePlayer(int id) async {
    final db = await instance.database;
    return await db.delete('players', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllPLayers() async {
    final db = await instance.database;
    await db.delete('players');
  }

  // --- Properties Operations ---

  Future<int> insertProperty(Property property) async {
    final db = await instance.database;
    return await db.insert(
      'properties',
      property.toMap(isDatabase: true),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Property?> getProperty(int id) async {
    final db = await instance.database;

    final maps = await db.query('properties', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Property.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<dynamic> getParamofProperty(int id, String param) async {
    final db = await instance.database;

    final maps = await db.query('properties', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return maps.first[param];
    } else {
      return null;
    }
  }

  Future<List<Property>> getAllProperties() async {
    final db = await instance.database;
    final maps = await db.query('properties'); // Returns a List of Maps

    return maps.map((json) => Property.fromMap(json)).toList();
  }

  Future<int> updateProperty(Property property) async {
    final db = await instance.database;
    return await db.update(
      'properties',
      property.toMap(),
      where: 'id = ?',
      whereArgs: [property.id],
    );
  }

  Future<int> updatePropertyParam(int propertyId, String key, dynamic value) async {
    final db = await instance.database;
    
    return await db.update(
      'properties', 
      {key: value},
      where: 'id = ?',
      whereArgs: [propertyId],
    );
  }

  Future<int> deleteProperty(int id) async {
    final db = await instance.database;
    return await db.delete('properties', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllProperties() async {
    final db = await instance.database;
    await db.delete('properties');
  }

  // --- General Operations ---

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
