import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// Conditional import for Platform (only used for non-web platforms)
import 'dart:io' show Platform;

class ImageService {
  static Database? _database;

  // Singleton pattern for accessing the database
  static Future<Database> get database async {
    if (_database != null) return _database!; // Return existing instance
    _database = await _initializeDatabase(); // Initialize if null
    return _database!;
  }

  // Initialize the database based on the platform
  static Future<Database> _initializeDatabase() async {
  String dbPath;
  DatabaseFactory dbFactory;

  if (kIsWeb) {
    dbFactory = databaseFactoryFfiWeb;
    dbPath = 'mein_bssb.db'; // Virtual path for Web
  } else if (Platform.isAndroid) {
    dbFactory = databaseFactory;
    final documentsDirectory = await getApplicationDocumentsDirectory();
    dbPath = join(documentsDirectory.path, 'mein_bssb_android.db');
  } else if (Platform.isIOS) {
    dbFactory = databaseFactory;
    final documentsDirectory = await getApplicationDocumentsDirectory();
    dbPath = join(documentsDirectory.path, 'mein_bssb_ios.db');
  } else if (Platform.isMacOS) {
    dbFactory = databaseFactoryFfi;
    final documentsDirectory = await getApplicationDocumentsDirectory();
    dbPath = join(documentsDirectory.path, 'mein_bssb_mac.db');
  } else if (Platform.isWindows) {
    sqfliteFfiInit();
    dbFactory = databaseFactoryFfi;
    final documentsDirectory = await getApplicationDocumentsDirectory();
    dbPath = join(documentsDirectory.path, 'mein_bssb_win.db');
  } else if (Platform.isLinux) {
    sqfliteFfiInit();
    dbFactory = databaseFactoryFfi;
    final documentsDirectory = await getApplicationDocumentsDirectory();
    dbPath = join(documentsDirectory.path, 'mein_bssb_linux.db');
  } else {
    throw UnsupportedError("Unsupported platform");
  }
 // Open the database without PRAGMA
  final db = await dbFactory.openDatabase(dbPath, options: OpenDatabaseOptions(
    version: 1,
    onCreate: (Database db, int version) async {
      await db.execute('''CREATE TABLE IF NOT EXISTS schuetzenausweis (
        personId INTEGER PRIMARY KEY,
        imageData BLOB,
        timestamp INTEGER
      )''');
    },
  ));

  // After the database is open, execute the PRAGMA command
  await db.execute('PRAGMA journal_mode=DELETE;');

  return db;
}
  // Cache a Schuetzenausweis entry
  Future<void> cacheSchuetzenausweis(
    int personId,
    Uint8List imageData,
    int timestamp,
  ) async {
    final db = await database; // Get the database instance
    await db.insert('schuetzenausweis', {
      'personId': personId,
      'imageData': imageData,
      'timestamp': timestamp,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Retrieve a cached Schuetzenausweis entry if it's valid
  Future<Uint8List?> getCachedSchuetzenausweis(
    int personId,
    Duration validity,
  ) async {
    final db = await database; // Get the database instance
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
}
