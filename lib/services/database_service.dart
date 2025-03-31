import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
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
          CREATE TABLE IF NOT EXISTS schuetzenausweis (
            personId INTEGER PRIMARY KEY,
            imageData BLOB,
            timestamp INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS schulungen (
            personId INTEGER PRIMARY KEY, 
            abDatum INTEGER, // Store as INTEGER (Unix timestamp)
            schulungenData TEXT,
            timestamp INTEGER
          )
        ''');
        await db.execute('PRAGMA journal_mode=WAL;');
      },
    );
  }
  
  Future<List<Map<String, dynamic>>> getCachedSchulungen(int personId, DateTime abDatum, Duration validity) async {
  final db = await database;
  final now = DateTime.now().millisecondsSinceEpoch;
  final abDatumTimestamp = abDatum.millisecondsSinceEpoch;
  final validityTimestamp = now - validity.inMilliseconds;

  final query = 'SELECT * FROM schulungen WHERE personId = ? AND abDatum < ? AND timestamp > ?';
  final whereArgs = [personId, abDatumTimestamp, validityTimestamp];

  debugPrint('Executing SQL Query: $query');
  debugPrint('Where Args: $whereArgs');

  final result = await db.rawQuery(query, whereArgs);

  debugPrint('Query Result: $result');

  return result;
}


Future<void> cacheSchulungen(int personId, DateTime abDatum, String schulungenData, int timestamp) async {
  final db = await database;
  final abDatumTimestamp = abDatum.millisecondsSinceEpoch;

  final rowsUpdated = await db.update(
    'schulungen',
    {
      'abDatum': abDatumTimestamp,
      'schulungenData': schulungenData,
      'timestamp': timestamp,
    },
    where: 'personId = ?',
    whereArgs: [personId],
  );

  if (rowsUpdated == 0) {
    // No record was updated, so insert a new one
    await db.insert(
      'schulungen',
      {
        'personId': personId,
        'abDatum': abDatumTimestamp,
        'schulungenData': schulungenData,
        'timestamp': timestamp,
      },
    );
  }
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


}
