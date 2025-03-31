import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

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
        await db.execute('PRAGMA journal_mode=WAL;');
      },
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
