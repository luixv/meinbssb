import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:meinbssb/screens/password/change_password_screen.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/models/user_data.dart';
import '../../helpers/test_helper.dart';

@GenerateMocks([FontSizeProvider])
void main() {
  setUp(() {
    TestHelper.setupMocks();
  });

  Widget createChangePasswordScreen({UserData? userData}) {
    return TestHelper.createTestApp(
      home: ChangePasswordScreen(
        userData: userData,
        isLoggedIn: true,
        onLogout: () {},
      ),
    );
  }

  group('ChangePasswordScreen', () {
    testWidgets('renders change password form', (WidgetTester tester) async {
      await tester.pumpWidget(createChangePasswordScreen());
      await tester.pumpAndSettle();

      expect(find.text('Neues Passwort erstellen'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('validates required fields', (WidgetTester tester) async {
      await tester.pumpWidget(createChangePasswordScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      expect(
        find.text('Bitte geben Sie Ihr aktuelles Passwort ein'),
        findsOneWidget,
      );
      expect(
        find.text('Bitte Passwort eingeben'),
        findsOneWidget,
      );
    });

    testWidgets('validates password strength requirements',
        (WidgetTester tester) async {
      await tester.pumpWidget(createChangePasswordScreen());
      await tester.pumpAndSettle();

      // Enter a weak password
      await tester.enterText(find.byType(TextFormField).at(1), 'weak');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      expect(
        find.text('Mindestens 8 Zeichen'),
        findsOneWidget,
      );
    });

    testWidgets('validates password confirmation match',
        (WidgetTester tester) async {
      await tester.pumpWidget(createChangePasswordScreen());
      await tester.pumpAndSettle();

      // Enter different passwords
      await tester.enterText(find.byType(TextFormField).at(1), 'ValidPass123!');
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'DifferentPass123!',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      expect(
        find.text('Die Passwörter stimmen nicht überein'),
        findsOneWidget,
      );
    });

    testWidgets('toggles password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(createChangePasswordScreen());
      await tester.pumpAndSettle();

      // Find the first visibility toggle button
      final visibilityButton = find.byIcon(Icons.visibility).first;
      expect(visibilityButton, findsOneWidget);

      // Tap to toggle visibility
      await tester.tap(visibilityButton);
      await tester.pumpAndSettle();

      // Should now show visibility_off icon
      expect(find.byIcon(Icons.visibility_off).first, findsOneWidget);
    });

    testWidgets('shows password strength indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(createChangePasswordScreen());
      await tester.pumpAndSettle();

      // Enter a password to trigger strength calculation
      await tester.enterText(find.byType(TextFormField).at(1), 'TestPass123!');
      await tester.pumpAndSettle();

      // Should show strength indicator
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Stark'), findsOneWidget);
    });

    testWidgets('successfully changes password with valid data',
        (WidgetTester tester) async {
      const userData = UserData(
        personId: 12345,
        webLoginId: 67890,
        passnummer: '123456',
        vereinNr: 1,
        namen: 'Test',
        vorname: 'User',
        vereinName: 'Test Club',
        passdatenId: 1,
        mitgliedschaftId: 1,
        strasse: 'Test Street',
        plz: '12345',
        ort: 'Test City',
        telefon: '123456789',
      );

      await tester.pumpWidget(createChangePasswordScreen(userData: userData));
      await tester.pumpAndSettle();

      // Fill in all required fields
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'currentPassword',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'NewPass123!');
      await tester.enterText(find.byType(TextFormField).at(2), 'NewPass123!');
      await tester.pumpAndSettle();

      // Tap save button
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // Verify that the API service methods were called
      verify(TestHelper.mockApiService.login(any, any)).called(1);
      // Verify cache service was called to get username
      verify(TestHelper.mockApiService.cacheService).called(1);
      verify(TestHelper.mockCacheService.getString('username')).called(1);
      // changePassword is only called if login is successful (ResultType == 1)
      verify(TestHelper.mockApiService.myBSSBPasswortAendern(any, any))
          .called(1);
    });

    testWidgets('handles API error gracefully', (WidgetTester tester) async {
      const userData = UserData(
        personId: 12345,
        webLoginId: 67890,
        passnummer: '123456',
        vereinNr: 1,
        namen: 'Test',
        vorname: 'User',
        vereinName: 'Test Club',
        passdatenId: 1,
        mitgliedschaftId: 1,
        strasse: 'Test Street',
        plz: '12345',
        ort: 'Test City',
        telefon: '123456789',
      );

      // Mock API to return error
      when(TestHelper.mockApiService.login(any, any)).thenAnswer(
        (_) async => {'ResultType': 0, 'ResultMessage': 'Invalid credentials'},
      );

      await tester.pumpWidget(createChangePasswordScreen(userData: userData));
      await tester.pumpAndSettle();

      // Fill in all required fields
      await tester.enterText(find.byType(TextFormField).at(0), 'wrongPassword');
      await tester.enterText(find.byType(TextFormField).at(1), 'NewPass123!');
      await tester.enterText(find.byType(TextFormField).at(2), 'NewPass123!');
      await tester.pumpAndSettle();

      // Tap save button
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // Should show error snackbar for incorrect password
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('validates password with umlauts', (WidgetTester tester) async {
      await tester.pumpWidget(createChangePasswordScreen());
      await tester.pumpAndSettle();

      // Test with uppercase umlauts
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'ÄÖÜpass123!',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // Should not show validation error for umlauts
      expect(find.text('Mind. 1 Großbuchstabe'), findsNothing);
    });

    testWidgets('validates password with lowercase umlauts',
        (WidgetTester tester) async {
      await tester.pumpWidget(createChangePasswordScreen());
      await tester.pumpAndSettle();

      // Test with lowercase umlauts
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Testäöü123!',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // Should not show validation error for umlauts
      expect(find.text('Mind. 1 Kleinbuchstabe'), findsNothing);
    });

    testWidgets('rejects invalid special characters (€)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createChangePasswordScreen());
      await tester.pumpAndSettle();

      // Test with invalid special character (€) - password must have an allowed
      // special character first to pass the "has special character" check,
      // then the invalid character check will catch the €
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'TestPass123!€',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // Should show error for invalid characters
      expect(find.text('Bitte nur erlaubte Zeichen verwenden'), findsOneWidget);
    });

    testWidgets('rejects previously allowed but now disallowed special characters (@, ^, _, |, \\, ", \', <, >, /)',
        (WidgetTester tester) async {
      // Test disallowed special characters: @ ^ _ | \ " ' < > /
      final disallowedChars = ['@', '^', '_', '|', '\\\\', '"', "'", '<', '>', '/'];
      
      for (final char in disallowedChars) {
        await tester.pumpWidget(createChangePasswordScreen());
        await tester.pumpAndSettle();

        // Test with disallowed special character - password must have an allowed
        // special character first to pass the "has special character" check
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'TestPass123!$char',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.save));
        await tester.pumpAndSettle();

        // Should show error for invalid characters
        expect(find.text('Bitte nur erlaubte Zeichen verwenden'), findsOneWidget,
            reason: 'Character $char should be rejected');
        
        // Reset for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('rejects invalid letters', (WidgetTester tester) async {
      await tester.pumpWidget(createChangePasswordScreen());
      await tester.pumpAndSettle();

      // Test with invalid letter (é)
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'TestéPass123!',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // Should show error for invalid characters
      expect(find.text('Bitte nur erlaubte Zeichen verwenden'), findsOneWidget);
    });

    testWidgets('accepts all allowed special characters',
        (WidgetTester tester) async {
      await tester.pumpWidget(createChangePasswordScreen());
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
          find.byType(TextFormField).at(1),
          'TestPass123$char',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.save));
        await tester.pumpAndSettle();

        // Should not show error for invalid characters
        expect(find.text('Bitte nur erlaubte Zeichen verwenden'), findsNothing);

        // Clear the field for next test
        await tester.enterText(find.byType(TextFormField).at(1), '');
        await tester.pumpAndSettle();
      }
    });
  });
}
