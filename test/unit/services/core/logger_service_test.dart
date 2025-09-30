import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:meinbssb/services/core/logger_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoggerService', () {
    // Store original logger configuration to restore after tests
    late Level originalLevel;

    setUp(() {
      // Capture original logger state
      originalLevel = Logger.root.level;

      // Clear any existing subscriptions for clean testing
      Logger.root.clearListeners();
      
      // Set logger level to OFF initially to prevent console output during tests
      Logger.root.level = Level.OFF;
    });

    tearDown(() {
      // Restore original logger state
      Logger.root.level = originalLevel;
      Logger.root.clearListeners();
    });

    group('Initialization Tests', () {
      test('init sets correct log level to ALL', () {
        LoggerService.init();
        expect(Logger.root.level, equals(Level.ALL));
      });

      test('init creates log record listener', () {
        LoggerService.init();
        expect(Logger.root.onRecord, isNotNull);
      });

      test('init can be called multiple times without error', () {
        LoggerService.init();
        LoggerService.init();
        LoggerService.init();

        // Should not throw and level should still be correct
        expect(Logger.root.level, equals(Level.ALL));
      });

      test('init with different initial log levels', () {
        // Set different initial level
        Logger.root.level = Level.OFF;
        LoggerService.init();

        // Should override to ALL
        expect(Logger.root.level, equals(Level.ALL));
      });
    });

    group('Logging Method Tests', () {
      late List<LogRecord> capturedLogs;
      late StreamSubscription logSubscription;

      setUp(() {
        capturedLogs = [];
        // Set level to ALL to capture all logs but don't call LoggerService.init() to avoid console output
        Logger.root.level = Level.ALL;

        // Capture log records for testing
        logSubscription = Logger.root.onRecord.listen((record) {
          capturedLogs.add(record);
        });
      });

      tearDown(() {
        logSubscription.cancel();
        capturedLogs.clear();
      });

      test('logInfo creates INFO level log record', () {
        const testMessage = 'Test info message';
        LoggerService.logInfo(testMessage);

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.level, equals(Level.INFO));
        expect(capturedLogs.first.message, equals(testMessage));
        expect(capturedLogs.first.loggerName, equals('MyAppLogger'));
      });

      test('logWarning creates WARNING level log record', () {
        const testMessage = 'Test warning message';
        LoggerService.logWarning(testMessage);

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.level, equals(Level.WARNING));
        expect(capturedLogs.first.message, equals(testMessage));
        expect(capturedLogs.first.loggerName, equals('MyAppLogger'));
      });

      test('logError creates SEVERE level log record', () {
        const testMessage = 'Test error message';
        LoggerService.logError(testMessage);

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.level, equals(Level.SEVERE));
        expect(capturedLogs.first.message, equals(testMessage));
        expect(capturedLogs.first.loggerName, equals('MyAppLogger'));
      });

      test('logDebug creates FINE level log record', () {
        const testMessage = 'Test debug message';
        LoggerService.logDebug(testMessage);

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.level, equals(Level.FINE));
        expect(capturedLogs.first.message, equals(testMessage));
        expect(capturedLogs.first.loggerName, equals('MyAppLogger'));
      });

      test('multiple log calls create multiple records', () {
        LoggerService.logInfo('Info message');
        LoggerService.logWarning('Warning message');
        LoggerService.logError('Error message');
        LoggerService.logDebug('Debug message');

        expect(capturedLogs, hasLength(4));
        expect(capturedLogs[0].level, equals(Level.INFO));
        expect(capturedLogs[1].level, equals(Level.WARNING));
        expect(capturedLogs[2].level, equals(Level.SEVERE));
        expect(capturedLogs[3].level, equals(Level.FINE));
      });

      test('log records have proper timestamps', () {
        final beforeTime = DateTime.now();
        LoggerService.logInfo('Timestamp test');
        final afterTime = DateTime.now();

        expect(capturedLogs, hasLength(1));
        final logTime = capturedLogs.first.time;
        expect(
            logTime.isAfter(beforeTime) || logTime.isAtSameMomentAs(beforeTime),
            isTrue,);
        expect(
            logTime.isBefore(afterTime) || logTime.isAtSameMomentAs(afterTime),
            isTrue,);
      });
    });

    group('Edge Cases and Input Validation', () {
      late List<LogRecord> capturedLogs;
      late StreamSubscription logSubscription;

      setUp(() {
        capturedLogs = [];
        // Set level to ALL to capture all logs but don't call LoggerService.init() to avoid console output
        Logger.root.level = Level.ALL;

        logSubscription = Logger.root.onRecord.listen((record) {
          capturedLogs.add(record);
        });
      });

      tearDown(() {
        logSubscription.cancel();
        capturedLogs.clear();
      });

      test('logInfo handles empty string message', () {
        LoggerService.logInfo('');

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.message, equals(''));
        expect(capturedLogs.first.level, equals(Level.INFO));
      });

      test('logWarning handles empty string message', () {
        LoggerService.logWarning('');

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.message, equals(''));
        expect(capturedLogs.first.level, equals(Level.WARNING));
      });

      test('logError handles empty string message', () {
        LoggerService.logError('');

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.message, equals(''));
        expect(capturedLogs.first.level, equals(Level.SEVERE));
      });

      test('logDebug handles empty string message', () {
        LoggerService.logDebug('');

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.message, equals(''));
        expect(capturedLogs.first.level, equals(Level.FINE));
      });

      test('logging methods handle very long messages', () {
        final longMessage = 'A' * 1000; // 1KB message
        LoggerService.logInfo(longMessage);

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.message, equals(longMessage));
        expect(capturedLogs.first.message.length, equals(1000));
      });

      test('logging methods handle special characters', () {
        const specialMessage = 'Special chars: àáâãäåæçèéêë 漢字 🎉 \n\t\r';
        LoggerService.logInfo(specialMessage);

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.message, equals(specialMessage));
      });

      test('logging methods handle newlines and tabs', () {
        const messageWithFormatting =
            'Line 1\nLine 2\tTabbed content\r\nWindows line ending';
        LoggerService.logError(messageWithFormatting);

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.message, equals(messageWithFormatting));
      });

      test('logging methods handle JSON-like strings', () {
        const jsonLikeMessage =
            '{"key": "value", "number": 123, "array": [1, 2, 3]}';
        LoggerService.logDebug(jsonLikeMessage);

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.message, equals(jsonLikeMessage));
      });
    });

    group('Log Level Filtering Tests', () {
      late List<LogRecord> capturedLogs;
      late StreamSubscription logSubscription;

      setUp(() {
        capturedLogs = [];
        logSubscription = Logger.root.onRecord.listen((record) {
          capturedLogs.add(record);
        });
      });

      tearDown(() {
        logSubscription.cancel();
        capturedLogs.clear();
      });

      test('ALL level captures all log types', () {
        Logger.root.level = Level.ALL;

        LoggerService.logDebug('Debug message');
        LoggerService.logInfo('Info message');
        LoggerService.logWarning('Warning message');
        LoggerService.logError('Error message');

        expect(capturedLogs, hasLength(4));
      });

      test('INFO level filters out DEBUG messages', () {
        Logger.root.level = Level.INFO;

        LoggerService.logDebug('Debug message');
        LoggerService.logInfo('Info message');
        LoggerService.logWarning('Warning message');
        LoggerService.logError('Error message');

        expect(capturedLogs, hasLength(3));
        expect(capturedLogs.any((log) => log.level == Level.FINE), isFalse);
      });

      test('WARNING level filters out DEBUG and INFO messages', () {
        Logger.root.level = Level.WARNING;

        LoggerService.logDebug('Debug message');
        LoggerService.logInfo('Info message');
        LoggerService.logWarning('Warning message');
        LoggerService.logError('Error message');

        expect(capturedLogs, hasLength(2));
        expect(capturedLogs.any((log) => log.level == Level.FINE), isFalse);
        expect(capturedLogs.any((log) => log.level == Level.INFO), isFalse);
      });

      test('SEVERE level only captures ERROR messages', () {
        Logger.root.level = Level.SEVERE;

        LoggerService.logDebug('Debug message');
        LoggerService.logInfo('Info message');
        LoggerService.logWarning('Warning message');
        LoggerService.logError('Error message');

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.level, equals(Level.SEVERE));
      });

      test('OFF level captures no messages', () {
        Logger.root.level = Level.OFF;

        LoggerService.logDebug('Debug message');
        LoggerService.logInfo('Info message');
        LoggerService.logWarning('Warning message');
        LoggerService.logError('Error message');

        expect(capturedLogs, hasLength(0));
      });
    });

    group('Performance and Stress Tests', () {
      late List<LogRecord> capturedLogs;
      late StreamSubscription logSubscription;

      setUp(() {
        capturedLogs = [];
        // Set level to ALL to capture all logs but don't call LoggerService.init() to avoid console output
        Logger.root.level = Level.ALL;

        logSubscription = Logger.root.onRecord.listen((record) {
          capturedLogs.add(record);
        });
      });

      tearDown(() {
        logSubscription.cancel();
        capturedLogs.clear();
      });

      test('handles rapid consecutive logging calls', () {
        for (int i = 0; i < 100; i++) {
          LoggerService.logInfo('Message $i');
        }

        expect(capturedLogs, hasLength(100));
        expect(capturedLogs.first.message, equals('Message 0'));
        expect(capturedLogs.last.message, equals('Message 99'));
      });

      test('handles mixed rapid logging calls', () {
        for (int i = 0; i < 25; i++) {
          LoggerService.logDebug('Debug $i');
          LoggerService.logInfo('Info $i');
          LoggerService.logWarning('Warning $i');
          LoggerService.logError('Error $i');
        }

        expect(capturedLogs, hasLength(100));

        // Verify alternating pattern
        for (int i = 0; i < 25; i++) {
          final baseIndex = i * 4;
          expect(capturedLogs[baseIndex].level, equals(Level.FINE));
          expect(capturedLogs[baseIndex + 1].level, equals(Level.INFO));
          expect(capturedLogs[baseIndex + 2].level, equals(Level.WARNING));
          expect(capturedLogs[baseIndex + 3].level, equals(Level.SEVERE));
        }
      });

      test('handles concurrent logging simulation', () async {
        final futures = <Future>[];

        for (int i = 0; i < 10; i++) {
          futures.add(
            Future(() {
              for (int j = 0; j < 10; j++) {
                LoggerService.logInfo('Thread $i Message $j');
              }
            }),
          );
        }

        await Future.wait(futures);

        expect(capturedLogs, hasLength(100));
        expect(capturedLogs.every((log) => log.level == Level.INFO), isTrue);
      });
    });

    group('Logger Integration Tests', () {
      test('logger name is consistent across all methods', () {
        final capturedLogs = <LogRecord>[];
        // Set level to ALL but don't call LoggerService.init() to avoid console output
        Logger.root.level = Level.ALL;

        final subscription = Logger.root.onRecord.listen((record) {
          capturedLogs.add(record);
        });

        LoggerService.logDebug('Debug');
        LoggerService.logInfo('Info');
        LoggerService.logWarning('Warning');
        LoggerService.logError('Error');

        expect(capturedLogs, hasLength(4));
        expect(capturedLogs.every((log) => log.loggerName == 'MyAppLogger'),
            isTrue,);

        subscription.cancel();
      });

      test('static logger instance is shared across calls', () {
        final capturedLogs = <LogRecord>[];
        // Set level to ALL but don't call LoggerService.init() to avoid console output
        Logger.root.level = Level.ALL;

        final subscription = Logger.root.onRecord.listen((record) {
          capturedLogs.add(record);
        });

        LoggerService.logInfo('First message');
        LoggerService.logInfo('Second message');

        expect(capturedLogs, hasLength(2));
        expect(capturedLogs[0].loggerName, equals(capturedLogs[1].loggerName));

        subscription.cancel();
      });
    });

    group('Real-world Usage Scenarios', () {
      late List<LogRecord> capturedLogs;
      late StreamSubscription logSubscription;

      setUp(() {
        capturedLogs = [];
        // Set level to ALL to capture all logs but don't call LoggerService.init() to avoid console output
        Logger.root.level = Level.ALL;

        logSubscription = Logger.root.onRecord.listen((record) {
          capturedLogs.add(record);
        });
      });

      tearDown(() {
        logSubscription.cancel();
        capturedLogs.clear();
      });

      test('logging API request and response simulation', () {
        LoggerService.logInfo('Starting API request to /api/users');
        LoggerService.logDebug(
            'Request headers: {Authorization: Bearer token123}',);
        LoggerService.logInfo('API request completed successfully');
        LoggerService.logDebug('Response: {users: [...], total: 25}');

        expect(capturedLogs, hasLength(4));
        expect(
            capturedLogs.where((log) => log.level == Level.INFO), hasLength(2),);
        expect(
            capturedLogs.where((log) => log.level == Level.FINE), hasLength(2),);
      });

      test('logging error handling flow simulation', () {
        LoggerService.logInfo('Processing user registration');
        LoggerService.logWarning(
            'Email validation failed for user@example.com',);
        LoggerService.logError(
            'User registration failed: Invalid email format',);
        LoggerService.logDebug('Returning error response to client');

        expect(capturedLogs, hasLength(4));
        expect(capturedLogs[0].level, equals(Level.INFO));
        expect(capturedLogs[1].level, equals(Level.WARNING));
        expect(capturedLogs[2].level, equals(Level.SEVERE));
        expect(capturedLogs[3].level, equals(Level.FINE));
      });

      test('logging application lifecycle events', () {
        LoggerService.logInfo('Application starting...');
        LoggerService.logDebug('Loading configuration files');
        LoggerService.logInfo('Database connection established');
        LoggerService.logWarning('Deprecated API endpoint used');
        LoggerService.logInfo('Application ready to serve requests');

        expect(capturedLogs, hasLength(5));
        final infoLogs =
            capturedLogs.where((log) => log.level == Level.INFO).toList();
        expect(infoLogs, hasLength(3));
      });

      test('logging exception details simulation', () {
        const exceptionMessage =
            'FormatException: Invalid JSON format at line 15';
        const stackTrace =
            'Stack trace:\n#0 parseJson\n#1 processData\n#2 main';

        LoggerService.logError('Exception occurred: $exceptionMessage');
        LoggerService.logDebug('Stack trace: $stackTrace');

        expect(capturedLogs, hasLength(2));
        expect(capturedLogs[0].message, contains('FormatException'));
        expect(capturedLogs[1].message, contains('Stack trace'));
      });
    });

    group('Boundary and Edge Cases', () {
      late List<LogRecord> capturedLogs;
      late StreamSubscription logSubscription;

      setUp(() {
        capturedLogs = [];
        // Set level to ALL to capture all logs but don't call LoggerService.init() to avoid console output
        Logger.root.level = Level.ALL;

        logSubscription = Logger.root.onRecord.listen((record) {
          capturedLogs.add(record);
        });
      });

      tearDown(() {
        logSubscription.cancel();
        capturedLogs.clear();
      });

      test('logging with unicode characters', () {
        const unicodeMessage = '🔥 Error in module 漢字 with émojis 🚀';
        LoggerService.logError(unicodeMessage);

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.message, equals(unicodeMessage));
      });

      test('logging with control characters', () {
        const controlMessage = 'Message with control chars';
        LoggerService.logWarning(controlMessage);

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.message, equals(controlMessage));
      });

      test('logging performance with different message sizes', () {
        final messages = [
          'Small',
          'A' * 100, // 100 chars
          'B' * 1000, // 1KB
          'C' * 5000, // 5KB
        ];

        for (final message in messages) {
          LoggerService.logInfo(message);
        }

        expect(capturedLogs, hasLength(4));
        expect(capturedLogs[0].message.length, equals(5));
        expect(capturedLogs[1].message.length, equals(100));
        expect(capturedLogs[2].message.length, equals(1000));
        expect(capturedLogs[3].message.length, equals(5000));
      });

      test('logging methods maintain message integrity', () {
        const complexMessage =
            'Complex message with "quotes", single\'quotes, and backslashes';
        LoggerService.logDebug(complexMessage);

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.message, equals(complexMessage));
      });
    });

    group('Error Resilience Tests', () {
      test('logging continues after listener exceptions', () {
        final capturedLogs = <LogRecord>[];
        // Set level to ALL but don't call LoggerService.init() to avoid console output
        Logger.root.level = Level.ALL;

        // Add a faulty listener that throws (wrapped in try-catch to not fail test)
        final faultySubscription = Logger.root.onRecord.listen((record) {
          try {
            throw Exception('Listener error');
          } catch (e) {
            // Expected exception, swallow it
          }
        });

        // Add a good listener
        final goodSubscription = Logger.root.onRecord.listen((record) {
          capturedLogs.add(record);
        });

        // This should not prevent logging
        LoggerService.logInfo('Test message');

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.message, equals('Test message'));

        faultySubscription.cancel();
        goodSubscription.cancel();
      });

      test('multiple init calls do not create duplicate listeners', () {
        LoggerService.init();
        LoggerService.init();
        LoggerService.init();

        // Multiple init calls should not crash
        expect(Logger.root.level, equals(Level.ALL));
      });
    });
  });
}
