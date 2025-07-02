import 'package:postgres_pool/postgres_pool.dart';
import 'config_service.dart';
import 'logger_service.dart';

class DatabaseService {
  DatabaseService({required this.configService});

  final ConfigService configService;
  PgPool? _pool;

  Future<PgPool> get pool async {
    if (_pool == null) {
      await _connect();
    }
    return _pool!;
  }

  Future<void> _connect() async {
    try {
      _pool = PgPool(
        PgEndpoint(
          host: configService.getString('dbHost', 'database') ?? 'localhost',
          port: configService.getInt('dbPort', 'database') ?? 5432,
          database: configService.getString('dbName', 'database') ?? 'devdb',
          username: configService.getString('dbUsername', 'database') ?? 'devuser',
          password: configService.getString('dbPassword', 'database') ?? 'devpass',
        ),
        settings: PgPoolSettings(
          maxConnectionAge: Duration(hours: 1),
          maxConnectionCount: 10,
        ),
      );

      // Test the connection
      final conn = await _pool!.connect();
      try {
        await conn.execute('SELECT 1');
        LoggerService.logInfo('Successfully connected to PostgreSQL database');
      } finally {
        await conn.close();
      }
    } catch (e) {
      LoggerService.logError('Failed to connect to PostgreSQL database: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    if (_pool != null) {
      await _pool!.close();
    }
  }

  // Example query method
  Future<List<Map<String, dynamic>>> query(
    String sql, [
    Map<String, dynamic>? parameters,
  ]) async {
    final pool = await this.pool;
    final conn = await pool.connect();
    
    try {
      final results = await conn.execute(
        sql,
        parameters: parameters?.values.toList(),
      );

      return results.map((row) => row.toMap()).toList();
    } finally {
      await conn.close();
    }
  }

  // Example transaction method
  Future<T> transaction<T>(Future<T> Function(PooledConnection) operation) async {
    final pool = await this.pool;
    final conn = await pool.connect();
    
    try {
      return await conn.transaction((ctx) async {
        return await operation(ctx);
      });
    } finally {
      await conn.close();
    }
  }
} 