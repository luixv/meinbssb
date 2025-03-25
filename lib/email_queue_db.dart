import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class EmailQueueDB {
  static const _dbName = 'email_queue.db';
  static const _dbVersion = 1;
  static const _tableName = 'emails';

  // Singleton pattern
  static final EmailQueueDB _instance = EmailQueueDB._internal();
  factory EmailQueueDB() => _instance;
  EmailQueueDB._internal();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipient TEXT NOT NULL,
        subject TEXT NOT NULL,
        body TEXT,
        status TEXT CHECK(status IN ('pending', 'sent', 'failed')) DEFAULT 'pending',
        created_at TEXT NOT NULL,
        retries INTEGER DEFAULT 0
      )
    ''');
  }

  // Add email to queue
  Future<int> addEmail({
    required String recipient,
    required String subject,
    String? body,
  }) async {
    final db = await database;
    return db.insert(_tableName, {
      'recipient': recipient,
      'subject': subject,
      'body': body,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Get pending emails
  Future<List<Map<String, dynamic>>> getPendingEmails() async {
    final db = await database;
    return db.query(
      _tableName,
      where: 'status = ?',
      whereArgs: ['pending'],
    );
  }

  // Update email status
  Future<void> updateStatus(int id, String status) async {
    final db = await database;
    await db.update(
      _tableName,
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Monitor queue stats
  Future<Map<String, dynamic>> getQueueStats() async {
    final db = await database;
    final pending = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName WHERE status = "pending"')
    ) ?? 0;
    
    final failed = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName WHERE status = "failed"')
    ) ?? 0;

    return {
      'pending': pending,
      'failed': failed,
      'total': pending + failed,
    };
  }

  Future<void> incrementRetryCount(int id) async {
  final db = await database;
  await db.rawUpdate(
    'UPDATE $_tableName SET retries = retries + 1 WHERE id = ?',
    [id],
  );
}

// Add max retries check
Future<List<Map<String, dynamic>>> getEmailsForRetry() async {
  final db = await database;
  return db.query(
    _tableName,
    where: 'status = ? AND retries < ?',
    whereArgs: ['pending', 3], // Max 3 retries
  );
}

}