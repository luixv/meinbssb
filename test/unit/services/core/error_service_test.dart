import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/exceptions/api_exception.dart';
import 'package:meinbssb/exceptions/authentication_exception.dart';
import 'package:meinbssb/exceptions/network_exception.dart';
import 'package:meinbssb/exceptions/validation_exception.dart';
import 'package:meinbssb/services/core/error_service.dart';
import 'package:meinbssb/exceptions/base_exception.dart';

// If the real exception constructors differ, adjust parameters accordingly.

class DummyBaseException extends BaseException {
  DummyBaseException(String msg) : super(message: msg);
}

void main() {
  group('ErrorService', () {
    group('handleValidationError', () {
      test('should return formatted validation error message', () {
        const field = 'email';
        const message = 'email: Email is required';

        final result = ErrorService.handleValidationError(field, message);

        expect(result, equals('email: Email is required'));
      });

      test('should handle empty field name', () {
        const field = '';
        const message = 'Field is required';

        final result = ErrorService.handleValidationError(field, message);

        expect(result, equals('Field is required'));
      });
    });

    group('handleNetworkError', () {
      test('should handle NetworkException', () {
        final error = NetworkException(message: 'No internet connection');

        final result = ErrorService.handleNetworkError(error);

        expect(result, equals('No internet connection'));
      });

      test('should handle SocketException', () {
        const error = 'SocketException: Benutzername oder Passwort ist falsch';

        final result = ErrorService.handleNetworkError(error);

        expect(
          result,
          equals(
            'Keine Internetverbindung verfügbar. Bitte überprüfen Sie Ihre Verbindung.',
          ),
        );
      });

      test('should handle TimeoutException', () {
        const error = 'TimeoutException: Connection timed out';

        final result = ErrorService.handleNetworkError(error);

        expect(
          result,
          equals(
            'Die Anfrage hat zu lange gedauert. Bitte versuchen Sie es später erneut.',
          ),
        );
      });

      test('should handle Connection refused', () {
        const error = 'Connection refused';

        final result = ErrorService.handleNetworkError(error);

        expect(
          result,
          equals(
            'Verbindung zum Server nicht möglich. Bitte versuchen Sie es später erneut.',
          ),
        );
      });

      test('should handle unknown network error', () {
        const error = 'Unknown network error';

        final result = ErrorService.handleNetworkError(error);

        expect(
          result,
          equals(
            'Ein Netzwerkfehler ist aufgetreten. Bitte überprüfen Sie Ihre Internetverbindung und versuchen Sie es später erneut.',
          ),
        );
      });
    });

    group('handleException', () {
      test('should handle ApiException', () {
        final error = ApiException(
          message: 'Server Error',
          statusCode: 500,
          response: {'ResultMessage': 'Server Error'},
        );

        final result = ErrorService.handleException(error);

        expect(result, equals('Server Error'));
      });

      test('should handle AuthenticationException', () {
        final error = AuthenticationException(
          message: 'Invalid credentials',
          code: 'AUTH_001',
        );

        final result = ErrorService.handleException(error);

        expect(result, equals('Invalid credentials'));
      });

      test('should handle ValidationException', () {
        final error = ValidationException(
          message: 'Invalid email format',
          field: 'email',
          errors: {'email': 'Invalid email format'},
        );

        final result = ErrorService.handleException(error);

        expect(result, equals('Invalid email format'));
      });

      test('should handle unknown exception', () {
        final error = Exception('Unknown error');

        final result = ErrorService.handleException(error);

        expect(
          result,
          equals(
            'Ein unerwarteter Fehler ist aufgetreten. Bitte versuchen Sie es später erneut.',
          ),
        );
      });
    });

    group('formatApiError', () {
      test('should format API error with ResultMessage', () {
        final response = {
          'ResultMessage': 'Invalid request',
          'ResultCode': 'ERR_001',
        };

        final result = ErrorService.formatApiError(response);

        expect(result, equals('Invalid request'));
      });

      test('should handle missing ResultMessage', () {
        final response = {'ResultCode': 'ERR_001'};

        final result = ErrorService.formatApiError(response);

        expect(result, equals('Ein unbekannter Fehler ist aufgetreten.'));
      });

      test('should handle null ResultMessage', () {
        final response = {'ResultMessage': null, 'ResultCode': 'ERR_001'};

        final result = ErrorService.formatApiError(response);

        expect(result, equals('Ein unbekannter Fehler ist aufgetreten.'));
      });
    });

    group('SnackBar Messages', () {
      testWidgets('should show error snackbar', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder:
                    (context) => ElevatedButton(
                      onPressed:
                          () => ErrorService.showErrorSnackBar(
                            context,
                            'Test error message',
                          ),
                      child: const Text('Show Error'),
                    ),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(find.text('Test error message'), findsOneWidget);
      });

      testWidgets('should show success snackbar', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder:
                    (context) => ElevatedButton(
                      onPressed:
                          () => ErrorService.showSuccessSnackBar(
                            context,
                            'Test success message',
                          ),
                      child: const Text('Show Success'),
                    ),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(find.text('Test success message'), findsOneWidget);
      });
    });
  });

  group('ErrorService.handleException private branches', () {
    test('ApiException with response uses formatted ResultMessage', () {
      final ex = ApiException(
        message: 'Fallback message',
        response: {'ResultMessage': 'API sagt Fehler A'},
      );
      final msg = ErrorService.handleException(ex);
      expect(msg, 'API sagt Fehler A');
    });

    test('ApiException without response returns its message', () {
      final ex = ApiException(message: 'Nur Nachricht');
      final msg = ErrorService.handleException(ex);
      expect(msg, 'Nur Nachricht');
    });

    test('NetworkException returns its message', () {
      final ex = NetworkException(message: 'Netzwerk down');
      final msg = ErrorService.handleException(ex);
      expect(msg, 'Netzwerk down');
    });

    test('AuthenticationException returns its message', () {
      final ex = AuthenticationException(message: 'Nicht authentifiziert');
      final msg = ErrorService.handleException(ex);
      expect(msg, 'Nicht authentifiziert');
    });

    test('ValidationException with errors map returns first error value', () {
      final ex = ValidationException(
        message: 'Ignored main message',
        field: 'email',
        errors: {'email': 'Ungültige E-Mail', 'pass': 'Zu kurz'},
      );
      final msg = ErrorService.handleException(ex);
      expect(msg, 'Ungültige E-Mail');
    });

    test('ValidationException without errors returns field: message', () {
      final ex = ValidationException(message: 'Pflichtfeld', field: 'vorname');
      final msg = ErrorService.handleException(ex);
      expect(msg, 'vorname: Pflichtfeld');
    });

    test('BaseException path returns its message', () {
      final ex = DummyBaseException('Basisfehler');
      final msg = ErrorService.handleException(ex);
      expect(msg, 'Basisfehler');
    });

    test('Unknown error returns generic fallback', () {
      final msg = ErrorService.handleException(Exception('Etwas'));
      expect(
        msg,
        'Ein unerwarteter Fehler ist aufgetreten. Bitte versuchen Sie es später erneut.',
      );
    });
  });

  group('ErrorService.formatApiError', () {
    test('Returns ResultMessage when present', () {
      final msg = ErrorService.formatApiError({
        'ResultMessage': 'Spezielle Meldung',
      });
      expect(msg, 'Spezielle Meldung');
    });

    test('Returns default when ResultMessage missing', () {
      final msg = ErrorService.formatApiError({'other': 'x'});
      expect(msg, 'Ein unbekannter Fehler ist aufgetreten.');
    });
  });

  group('ErrorService.handleNetworkError', () {
    test('NetworkException returns its message', () {
      final msg = ErrorService.handleNetworkError(
        NetworkException(message: 'Timeout Server'),
      );
      expect(msg, 'Timeout Server');
    });

    test('SocketException text returns connectivity message', () {
      final msg = ErrorService.handleNetworkError('SocketException: no route');
      expect(
        msg,
        'Keine Internetverbindung verfügbar. Bitte überprüfen Sie Ihre Verbindung.',
      );
    });

    test('TimeoutException text returns timeout message', () {
      final msg = ErrorService.handleNetworkError('TimeoutException after 30s');
      expect(
        msg,
        'Die Anfrage hat zu lange gedauert. Bitte versuchen Sie es später erneut.',
      );
    });

    test('Connection refused text returns server unreachable message', () {
      final msg = ErrorService.handleNetworkError(
        'OS Error: Connection refused (111)',
      );
      expect(
        msg,
        'Verbindung zum Server nicht möglich. Bitte versuchen Sie es später erneut.',
      );
    });

    test('Other text returns generic network message', () {
      final msg = ErrorService.handleNetworkError('Unbekannt');
      expect(
        msg,
        'Ein Netzwerkfehler ist aufgetreten. Bitte überprüfen Sie Ihre Internetverbindung und versuchen Sie es später erneut.',
      );
    });
  });
}
