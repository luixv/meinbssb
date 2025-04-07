import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/services/error_service.dart';

void main() {
  group('ErrorService', () {
    test('formatApiError returns ResultMessage when available', () {
      final response = {'ResultType': 0, 'ResultMessage': 'Test error message'};

      expect(
        ErrorService.formatApiError(response),
        equals('Test error message'),
      );
    });

    test(
      'formatApiError returns default message when ResultMessage is missing',
      () {
        final response = {'ResultType': 0};

        expect(
          ErrorService.formatApiError(response),
          equals('Ein unbekannter Fehler ist aufgetreten.'),
        );
      },
    );

    test(
      'formatApiError returns default message when ResultMessage is null',
      () {
        final response = {'ResultType': 0, 'ResultMessage': null};

        expect(
          ErrorService.formatApiError(response),
          equals('Ein unbekannter Fehler ist aufgetreten.'),
        );
      },
    );

    test('handleNetworkError returns appropriate message', () {
      final error = Exception('Connection refused');

      expect(
        ErrorService.handleNetworkError(error),
        contains('Netzwerkfehler'),
      );
    });

    test('handleValidationError formats field and message correctly', () {
      expect(
        ErrorService.handleValidationError('Email', 'Invalid format'),
        equals('Email: Invalid format'),
      );
    });

    test('handleGeneralError includes error message', () {
      final error = Exception('Test error');

      expect(ErrorService.handleGeneralError(error), contains('Test error'));
    });
  });
}
