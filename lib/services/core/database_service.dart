import 'package:postgres/postgres.dart';
import 'config_service.dart';
import 'logger_service.dart';

class DatabaseService {
  DatabaseService({required this.configService});

  final ConfigService configService;
  PostgreSQLConnection? _connection;

  Future<PostgreSQLConnection> get connection async {
    if (_connection == null || _connection!.isClosed) {
      await _connect();
    }
    return _connection!;
  }

  Future<void> _connect() async {
    try {
      _connection = PostgreSQLConnection(
        configService.getString('dbHost', 'database') ?? 'localhost',
        configService.getInt('dbPort', 'database') ?? 5432,
        configService.getString('dbName', 'database') ?? 'devdb',
        username: configService.getString('dbUsername', 'database') ?? 'devuser',
        password: configService.getString('dbPassword', 'database') ?? 'devpass',
      );

      await _connection!.open();
      
      // Test the connection
      await _connection!.query('SELECT 1');
      LoggerService.logInfo('Successfully connected to PostgreSQL database');
    } catch (e) {
      LoggerService.logError('Failed to connect to PostgreSQL database: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    if (_connection != null && !_connection!.isClosed) {
      await _connection!.close();
    }
  }

  // Example query method
  Future<List<Map<String, dynamic>>> query(
    String sql, [
    Map<String, dynamic>? parameters,
  ]) async {
    final conn = await connection;
    
    try {
      final results = await conn.mappedResultsQuery(
        sql,
        substitutionValues: parameters,
      );

      return results.map((row) => row.values.first).toList();
    } catch (e) {
      LoggerService.logError('Error executing query: $e');
      rethrow;
    }
  }

  // Example transaction method
  Future<T> transaction<T>(Future<T> Function(PostgreSQLExecutionContext) operation) async {
    final conn = await connection;
    
    try {
      return await conn.transaction((ctx) async {
        return await operation(ctx);
      });
    } catch (e) {
      LoggerService.logError('Error executing transaction: $e');
      rethrow;
    }
  }
} 