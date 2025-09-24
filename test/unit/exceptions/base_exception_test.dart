import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/exceptions/base_exception.dart';

void main() {
  group('BaseException', () {
    test('should store and return message', () {
      final exception = BaseException(message: 'Test error');
      expect(exception.message, 'Test error');
      expect(exception.code, isNull);
      expect(exception.originalError, isNull);
      expect(exception.stackTrace, isNull);
    });

    test('should store all fields', () {
      final stack = StackTrace.current;
      final exception = BaseException(
        message: 'Something went wrong',
        code: 'E001',
        originalError: ArgumentError('bad arg'),
        stackTrace: stack,
      );
      expect(exception.message, 'Something went wrong');
      expect(exception.code, 'E001');
      expect(exception.originalError, isA<ArgumentError>());
      expect(exception.stackTrace, stack);
    });

    test('toString includes message and code', () {
      final exception = BaseException(message: 'Oops', code: 'X123');
      final str = exception.toString();
      expect(str, contains('BaseException: Oops'));
      expect(str, contains('Code: X123'));
    });

    test('toString includes originalError and stackTrace if present', () {
      final stack = StackTrace.current;
      final exception = BaseException(
        message: 'Fail',
        originalError: Exception('inner'),
        stackTrace: stack,
      );
      final str = exception.toString();
      expect(str, contains('Original Error: Exception: inner'));
      expect(str, contains('Stack Trace:'));
    });

    test('toString omits code, originalError, and stackTrace if not present',
        () {
      final exception = BaseException(message: 'Simple');
      final str = exception.toString();
      expect(str, isNot(contains('Code:')));
      expect(str, isNot(contains('Original Error:')));
      expect(str, isNot(contains('Stack Trace:')));
    });
  });
}
