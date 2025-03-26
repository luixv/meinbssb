import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';

class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'mein_bssb.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
            CREATE TABLE IF NOT EXISTS passdaten (
            personId INTEGER PRIMARY KEY,
            passdatenData TEXT,
            timestamp INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS cache (
            key TEXT PRIMARY KEY,
            value TEXT,
            timestamp INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS user (
            email TEXT PRIMARY KEY,
            password TEXT,
            userData TEXT,
            timestamp INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS schuetzenausweis (
            personId INTEGER PRIMARY KEY,
            imageData BLOB,
            timestamp INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS schulungen (
            personId INTEGER,
            abDatum TEXT,
            schulungenData TEXT,
            timestamp INTEGER,
            PRIMARY KEY (personId, abDatum)
          )
        ''');
      },
    );
  }

  Future<Map<String, dynamic>?> getCachedPassdaten(int personId, Duration validity) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final result = await db.query(
      'passdaten',
      where: 'personId = ? AND timestamp > ?',
      whereArgs: [personId, now - validity.inMilliseconds],
    );

    if (result.isNotEmpty) {
      return jsonDecode(result.first['passdatenData'] as String) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> cachePassdaten(int personId, Map<String, dynamic> passdatenData, int timestamp) async {
    final db = await database;
    await db.insert(
      'passdaten',
      {
        'personId': personId,
        'passdatenData': jsonEncode(passdatenData),
        'timestamp': timestamp,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<Map<String, dynamic>>> getCachedSchulungen(int personId, String abDatum, Duration validity) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final result = await db.query(
      'schulungen',
      where: 'personId = ? AND abDatum = ? AND timestamp > ?',
      whereArgs: [personId, abDatum, now - validity.inMilliseconds],
    );
    return result;
  }

  Future<void> cacheSchulungen(int personId, String abDatum, String schulungenData, int timestamp) async {
    final db = await database;
    await db.insert(
      'schulungen',
      {
        'personId': personId,
        'abDatum': abDatum,
        'schulungenData': schulungenData,
        'timestamp': timestamp,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Uint8List?> getCachedSchuetzenausweis(int personId, Duration validity) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final result = await db.query(
      'schuetzenausweis',
      where: 'personId = ? AND timestamp > ?',
      whereArgs: [personId, now - validity.inMilliseconds],
    );

    if (result.isNotEmpty) {
      return result.first['imageData'] as Uint8List?;
    }
    return null;
  }

  Future<void> cacheSchuetzenausweis(int personId, Uint8List imageData, int timestamp) async {
    final db = await database;
    await db.insert(
      'schuetzenausweis',
      {
        'personId': personId,
        'imageData': imageData,
        'timestamp': timestamp,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

Future<Map<String, dynamic>?> getCachedUser(String email) async {
  try {
    final db = await database;
    final result = await db.query(
      'user',
      where: 'email = ?',
      whereArgs: [email],
    );

    debugPrint('Query result for cached user: $result'); // Inspect query result

    if (result.isNotEmpty) {
      final userData = result.first['userData'] as String?;
      final password = result.first['password'] as String?; //Retrieve password
      if (userData != null) {
        final decodedUserData = jsonDecode(userData) as Map<String, dynamic>;
        decodedUserData['password'] = password; // Add password to the decoded user data
        debugPrint('Decoded user data: $decodedUserData'); // Inspect decoded data
        return decodedUserData;
      }
    }
    return null;
  } catch (e) {
    debugPrint('Error getting cached user: $e');
    return null;
  }
}

  Future<void> cacheUser(String email, String password, Map<String, dynamic> userData, int timestamp) async {
  final db = await database;
  await db.insert(
    'user',
    {
      'email': email,
      'password': password, // Store password in the password field
      'userData': jsonEncode(userData),
      'timestamp': timestamp,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}
}
