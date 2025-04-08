// Project: Mein BSSB
// Filename: database_service.dart
// Author: Luis Mandel / NTT DATA

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart' as sqflite_ffi_web; // Import with prefix for web
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import with prefix for desktop

class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    return _database!;
  }

Future<Database> _initializeDatabase() async {
  String path;
  DatabaseFactory databaseFactoryImpl;

  if (kIsWeb) {
    // ✅ No need to call any init function on web
    databaseFactoryImpl = sqflite_ffi_web.databaseFactoryFfiWeb;
    path = 'mein_bssb.db';
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    // ✅ Desktop platforms need init
    sqfliteFfiInit();
    databaseFactoryImpl = databaseFactoryFfi;
    final documentsDirectory = await getApplicationDocumentsDirectory();
    path = join(documentsDirectory.path, 'mein_bssb.db');
  } else {
    // ✅ Mobile: Android/iOS
    databaseFactoryImpl = databaseFactory;
    final documentsDirectory = await getApplicationDocumentsDirectory();
    path = join(documentsDirectory.path, 'mein_bssb.db');
  }

  return await databaseFactoryImpl.openDatabase(
    path,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS schuetzenausweis (
            personId INTEGER PRIMARY KEY,
            imageData BLOB,
            timestamp INTEGER
          )
        ''');
        await db.execute('PRAGMA journal_mode=WAL;');
      },
    ),
  );
}


  Future<Uint8List?> getCachedSchuetzenausweis(
    int personId,
    Duration validity,
  ) async {
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

  Future<void> cacheSchuetzenausweis(
    int personId,
    Uint8List imageData,
    int timestamp,
  ) async {
    final db = await database;
    await db.insert('schuetzenausweis', {
      'personId': personId,
      'imageData': imageData,
      'timestamp': timestamp,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}