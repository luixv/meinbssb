import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/exceptions/api_exception.dart';

void main() {
  group('ApiException', () {
    test('should store and return all fields', () {
      final exception = ApiException(
        message: 'API error',
        statusCode: 404,
        response: {'ResultMessage': 'API error', 'ResultCode': '404'},
        code: '404',
        originalError: ArgumentError('bad arg'),
        stackTrace: StackTrace.current,
      );
      expect(exception.message, 'API error');
      expect(exception.statusCode, 404);
      expect(exception.response, isA<Map<String, dynamic>>());
      expect(exception.code, '404');
      expect(exception.originalError, isA<ArgumentError>());
      expect(exception.stackTrace, isNotNull);
    });

    test('fromResponse factory sets message and code from response', () {
      final response = {
        'ResultMessage': 'Not found',
        'ResultCode': '404',
        'extra': 'value',
      };
      final exception = ApiException.fromResponse(response);
      expect(exception.message, 'Not found');
      expect(exception.code, '404');
      expect(exception.response, response);
      expect(exception.statusCode, isNull);
    });

    test('fromResponse uses default message if missing', () {
      final response = {'ResultCode': '500'};
      final exception = ApiException.fromResponse(response);
      expect(exception.message, 'An unexpected API error occurred');
      expect(exception.code, '500');
      expect(exception.response, response);
    });

    test('fromResponse uses null code if missing', () {
      final response = {'ResultMessage': 'Error occurred'};
      final exception = ApiException.fromResponse(response);
      expect(exception.message, 'Error occurred');
      expect(exception.code, isNull);
      expect(exception.response, response);
    });

    test('toString includes message and code', () {
      final exception = ApiException(message: 'Oops', code: 'X123');
      final str = exception.toString();
      expect(str, contains('ApiException: Oops'));
      expect(str, contains('Code: X123'));
    });
  });
}
