// email_queue_db.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

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
    if (_database != null) {
      debugPrint("Database already initialized.");
      return _database!;
    }
    debugPrint("Initializing database...");
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _dbName);
    debugPrint("Database path: $path");
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    debugPrint("Creating EmailQueue table...");
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
    debugPrint("EmailQueue table created.");
  }

  // Add email to queue
  Future<int> addEmail({
    required String recipient,
    required String subject,
    String? body,
  }) async {
    final db = await database;
    debugPrint("Adding email: recipient=$recipient, subject=$subject");
    final result = await db.insert(_tableName, {
      'recipient': recipient,
      'subject': subject,
      'body': body,
      'created_at': DateTime.now().toIso8601String(),
    });
    debugPrint("Email added with result: $result");
    return result;
  }

  // Get pending emails
  Future<List<Map<String, dynamic>>> getPendingEmails() async {
    final db = await database;
    debugPrint("Getting pending emails...");
    final result = await db.query(
      _tableName,
      where: 'status = ? AND retries < 3',
      whereArgs: ['pending'],
    );
    debugPrint("Pending emails: $result");
    return result;
  }

  // Update email status
  Future<void> updateStatus(int id, String status) async {
    final db = await database;
    debugPrint("Updating status: id=$id, status=$status");
    await db.update(
      _tableName,
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
    debugPrint("Status updated.");
  }

  // Increment retry count
  Future<void> incrementRetry(int id) async {
    final db = await database;
    debugPrint("Incrementing retry: id=$id");
    await db.rawUpdate(
      'UPDATE $_tableName SET retries = retries + 1 WHERE id = ?',
      [id],
    );
    debugPrint("Retry incremented.");
  }

  // Get queue stats
  Future<Map<String, dynamic>> getQueueStats() async {
    final db = await database;
    debugPrint("Getting queue stats...");
    final pending = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName WHERE status = "pending"')
    ) ?? 0;
    final failed = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName WHERE status = "failed"')
    ) ?? 0;
    final result = {
      'pending': pending,
      'failed': failed,
      'total': pending + failed,
    };
    debugPrint("Queue stats: $result");
    return result;
  }

  Future<List<Map<String, dynamic>>> getAllEmails() async {
    final db = await database;
    debugPrint("Getting all emails...");
    final result = await db.query(_tableName);
    debugPrint("All emails: $result");
    return result;
  }
}