import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:meinbssb/screens/password/reset_password_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import '../../helpers/test_helper.dart';

@GenerateMocks([ApiService])
void main() {
  setUp(() {
    TestHelper.setupMocks();
  });

  Widget createResetPasswordScreen() {
    return TestHelper.createTestApp(
      home: ResetPasswordScreen(
        apiService: TestHelper.mockApiService,
        token: 'test-token-123',
        personId: '12345',
      ),
    );
  }

  group('ResetPasswordScreen', () {
    testWidgets('renders reset password form', (WidgetTester tester) async {
      // Mock the API call to return valid token
      when(TestHelper.mockApiService
              .getUserByPasswordResetVerificationToken(any))
          .thenAnswer((_) async => {
                'person_id': '12345',
                'is_used': false,
                'created_at': DateTime.now().toIso8601String(),
              });

      await tester.pumpWidget(createResetPasswordScreen());
      await tester.pumpAndSettle();

      expect(find.text('Passwort zurücksetzen'), findsAtLeastNWidgets(1));
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('validates required fields', (WidgetTester tester) async {
      // Mock the API call to return valid token
      when(TestHelper.mockApiService
              .getUserByPasswordResetVerificationToken(any))
          .thenAnswer((_) async => {
                'person_id': '12345',
                'is_used': false,
                'created_at': DateTime.now().toIso8601String(),
              });

      await tester.pumpWidget(createResetPasswordScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.lock_reset));
      await tester.pumpAndSettle();

      expect(
        find.text('Bitte Passwort eingeben'),
        findsOneWidget,
      );
    });

    testWidgets('validates password strength requirements',
        (WidgetTester tester) async {
      // Mock the API call to return valid token
      when(TestHelper.mockApiService
              .getUserByPasswordResetVerificationToken(any))
          .thenAnswer((_) async => {
                'person_id': '12345',
                'is_used': false,
                'created_at': DateTime.now().toIso8601String(),
              });

      await tester.pumpWidget(createResetPasswordScreen());
      await tester.pumpAndSettle();

      // Enter a weak password
      await tester.enterText(find.byType(TextFormField).at(0), 'weak');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.lock_reset));
      await tester.pumpAndSettle();

      expect(
        find.text('Mindestens 8 Zeichen'),
        findsOneWidget,
      );
    });

    testWidgets('validates password with umlauts', (WidgetTester tester) async {
      // Mock the API call to return valid token
      when(TestHelper.mockApiService
              .getUserByPasswordResetVerificationToken(any))
          .thenAnswer((_) async => {
                'person_id': '12345',
                'is_used': false,
                'created_at': DateTime.now().toIso8601String(),
              });

      await tester.pumpWidget(createResetPasswordScreen());
      await tester.pumpAndSettle();

      // Test with uppercase umlauts
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'ÄÖÜpass123!',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.lock_reset));
      await tester.pumpAndSettle();

      // Should not show validation error for umlauts
      expect(find.text('Mind. 1 Großbuchstabe'), findsNothing);
    });

    testWidgets('validates password with lowercase umlauts',
        (WidgetTester tester) async {
      // Mock the API call to return valid token
      when(TestHelper.mockApiService
              .getUserByPasswordResetVerificationToken(any))
          .thenAnswer((_) async => {
                'person_id': '12345',
                'is_used': false,
                'created_at': DateTime.now().toIso8601String(),
              });

      await tester.pumpWidget(createResetPasswordScreen());
      await tester.pumpAndSettle();

      // Test with lowercase umlauts
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Testäöü123!',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.lock_reset));
      await tester.pumpAndSettle();

      // Should not show validation error for umlauts
      expect(find.text('Mind. 1 Kleinbuchstabe'), findsNothing);
    });

    testWidgets('rejects invalid special characters (€)',
        (WidgetTester tester) async {
      // Mock the API call to return valid token
      when(TestHelper.mockApiService
              .getUserByPasswordResetVerificationToken(any))
          .thenAnswer((_) async => {
                'person_id': '12345',
                'is_used': false,
                'created_at': DateTime.now().toIso8601String(),
              });

      await tester.pumpWidget(createResetPasswordScreen());
      await tester.pumpAndSettle();

      // Test with invalid special character (€) - password must have an allowed
      // special character first to pass the "has special character" check,
      // then the invalid character check will catch the €
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'TestPass123!€',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.lock_reset));
      await tester.pumpAndSettle();

      // Should show error for invalid characters
      expect(find.text('Nur erlaubte Zeichen verwenden'), findsOneWidget);
    });

    testWidgets('rejects previously allowed but now disallowed special characters (@, ^, _, |, \\, ", \', <, >, /)',
        (WidgetTester tester) async {
      // Test disallowed special characters: @ ^ _ | \ " ' < > /
      final disallowedChars = ['@', '^', '_', '|', '\\\\', '"', "'", '<', '>', '/'];
      
      for (final char in disallowedChars) {
        // Mock the API call to return valid token
        when(TestHelper.mockApiService
                .getUserByPasswordResetVerificationToken(any))
            .thenAnswer((_) async => {
                  'person_id': '12345',
                  'is_used': false,
                  'created_at': DateTime.now().toIso8601String(),
                });

        await tester.pumpWidget(createResetPasswordScreen());
        await tester.pumpAndSettle();

        // Test with disallowed special character - password must have an allowed
        // special character first to pass the "has special character" check
        await tester.enterText(
          find.byType(TextFormField).at(0),
          'TestPass123!$char',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.lock_reset));
        await tester.pumpAndSettle();

        // Should show error for invalid characters
        expect(find.text('Nur erlaubte Zeichen verwenden'), findsOneWidget,
            reason: 'Character $char should be rejected');
        
        // Reset for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('rejects invalid letters', (WidgetTester tester) async {
      // Mock the API call to return valid token
      when(TestHelper.mockApiService
              .getUserByPasswordResetVerificationToken(any))
          .thenAnswer((_) async => {
                'person_id': '12345',
                'is_used': false,
                'created_at': DateTime.now().toIso8601String(),
              });

      await tester.pumpWidget(createResetPasswordScreen());
      await tester.pumpAndSettle();

      // Test with invalid letter (é)
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'TestéPass123!',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.lock_reset));
      await tester.pumpAndSettle();

      // Should show error for invalid characters
      expect(find.text('Nur erlaubte Zeichen verwenden'), findsOneWidget);
    });

    testWidgets('accepts all allowed special characters',
        (WidgetTester tester) async {
      // Mock the API call to return valid token
      when(TestHelper.mockApiService
              .getUserByPasswordResetVerificationToken(any))
          .thenAnswer((_) async => {
                'person_id': '12345',
                'is_used': false,
                'created_at': DateTime.now().toIso8601String(),
              });

      await tester.pumpWidget(createResetPasswordScreen());
      await tester.pumpAndSettle();

      // Test with allowed special characters
      const allowedSpecialChars = [
        '!',
        '#',
        '\$',
        '%',
        '&',
        '*',
        '(',
        ')',
        '-',
        '+',
        '=',
        '{',
        '}',
        '[',
        ']',
        ':',
        ';',
        ',',
        '.',
        '?',
      ];

      for (final char in allowedSpecialChars) {
        await tester.enterText(
          find.byType(TextFormField).at(0),
          'TestPass123$char',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.lock_reset));
        await tester.pumpAndSettle();

        // Should not show error for invalid characters
        expect(find.text('Nur erlaubte Zeichen verwenden'), findsNothing);

        // Clear the field for next test
        await tester.enterText(find.byType(TextFormField).at(0), '');
        await tester.pumpAndSettle();
      }
    });

    testWidgets('validates password confirmation match',
        (WidgetTester tester) async {
      // Mock the API call to return valid token
      when(TestHelper.mockApiService
              .getUserByPasswordResetVerificationToken(any))
          .thenAnswer((_) async => {
                'person_id': '12345',
                'is_used': false,
                'created_at': DateTime.now().toIso8601String(),
              });

      await tester.pumpWidget(createResetPasswordScreen());
      await tester.pumpAndSettle();

      // Enter different passwords
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'ValidPass123!',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'DifferentPass123!',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.lock_reset));
      await tester.pumpAndSettle();

      expect(
        find.text('Passwörter stimmen nicht überein'),
        findsOneWidget,
      );
    });
  });
}
