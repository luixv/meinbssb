import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/exceptions/validation_exception.dart';

void main() {
  group('ValidationException', () {
    test('should store and return all fields', () {
      final exception = ValidationException(
        message: 'Invalid value',
        field: 'email',
        errors: {'email': 'Invalid value'},
        code: 'VAL001',
        originalError: ArgumentError('bad arg'),
        stackTrace: StackTrace.current,
      );
      expect(exception.message, 'Invalid value');
      expect(exception.field, 'email');
      expect(exception.errors, isA<Map<String, String>>());
      expect(exception.code, 'VAL001');
      expect(exception.originalError, isA<ArgumentError>());
      expect(exception.stackTrace, isNotNull);
    });

    test('fromErrors factory sets message and field from first error', () {
      final errors = {
        'username': 'Username required',
        'email': 'Invalid email',
      };
      final exception = ValidationException.fromErrors(errors);
      expect(exception.message, 'Username required');
      expect(exception.field, 'username');
      expect(exception.errors, errors);
    });

    test('toString includes message', () {
      final exception = ValidationException(
        message: 'Too short',
        field: 'password',
      );
      final str = exception.toString();
      expect(str, contains('Too short'));
    });
  });
}
