import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/exceptions/api_exception.dart';
import 'package:meinbssb/exceptions/authentication_exception.dart';
import 'package:meinbssb/exceptions/network_exception.dart';
import 'package:meinbssb/exceptions/validation_exception.dart';
import 'package:meinbssb/services/error_service.dart';

void main() {
  group('ErrorService', () {
    late TestWidgetsFlutterBinding binding;

    setUp(() {
      binding = TestWidgetsFlutterBinding.ensureInitialized();
    });

    group('handleValidationError', () {
      test('should return formatted validation error message', () {
        const field = 'email';
        const message = 'Email is required';
        
        final result = ErrorService.handleValidationError(field, message);
        
        expect(result, equals('email: Email is required'));
      });

      test('should handle empty field name', () {
        const field = '';
        const message = 'Field is required';
        
        final result = ErrorService.handleValidationError(field, message);
        
        expect(result, equals(': Field is required'));
      });
    });

    group('handleNetworkError', () {
      test('should handle NetworkException', () {
        final error = NetworkException(message: 'No internet connection');
        
        final result = ErrorService.handleNetworkError(error);
        
        expect(result, equals('No internet connection'));
      });

      test('should handle SocketException', () {
        final error = 'SocketException: Failed host lookup';
        
        final result = ErrorService.handleNetworkError(error);
        
        expect(result, equals('Keine Internetverbindung verfügbar. Bitte überprüfen Sie Ihre Verbindung.'));
      });

      test('should handle TimeoutException', () {
        final error = 'TimeoutException: Connection timed out';
        
        final result = ErrorService.handleNetworkError(error);
        
        expect(result, equals('Die Anfrage hat zu lange gedauert. Bitte versuchen Sie es später erneut.'));
      });

      test('should handle Connection refused', () {
        final error = 'Connection refused';
        
        final result = ErrorService.handleNetworkError(error);
        
        expect(result, equals('Verbindung zum Server nicht möglich. Bitte versuchen Sie es später erneut.'));
      });

      test('should handle unknown network error', () {
        final error = 'Unknown network error';
        
        final result = ErrorService.handleNetworkError(error);
        
        expect(result, equals('Ein Netzwerkfehler ist aufgetreten. Bitte überprüfen Sie Ihre Internetverbindung und versuchen Sie es später erneut.'));
      });
    });

    group('handleException', () {
      test('should handle ApiException', () {
        final error = ApiException(
          message: 'API Error',
          statusCode: 500,
          response: {'ResultMessage': 'Server error'},
        );
        
        final result = ErrorService.handleException(error);
        
        expect(result, equals('Server error'));
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
          message: 'Invalid input',
          field: 'email',
          errors: {'email': 'Invalid email format'},
        );
        
        final result = ErrorService.handleException(error);
        
        expect(result, equals('Invalid email format'));
      });

      test('should handle unknown exception', () {
        final error = Exception('Unknown error');
        
        final result = ErrorService.handleException(error);
        
        expect(result, equals('Ein unerwarteter Fehler ist aufgetreten. Bitte versuchen Sie es später erneut.'));
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
        final response = {
          'ResultCode': 'ERR_001',
        };
        
        final result = ErrorService.formatApiError(response);
        
        expect(result, equals('Ein unbekannter Fehler ist aufgetreten.'));
      });

      test('should handle null ResultMessage', () {
        final response = {
          'ResultMessage': null,
          'ResultCode': 'ERR_001',
        };
        
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
                builder: (context) => ElevatedButton(
                  onPressed: () => ErrorService.showErrorSnackBar(
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
                builder: (context) => ElevatedButton(
                  onPressed: () => ErrorService.showSuccessSnackBar(
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
} 