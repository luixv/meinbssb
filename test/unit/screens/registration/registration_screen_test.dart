import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:meinbssb/screens/registration/registration_screen.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/core/email_service.dart';
import '../../helpers/test_helper.dart';

@GenerateMocks([AuthService, EmailService])
void main() {
  setUp(() {
    TestHelper.setupMocks();
  });

  Widget createRegistrationScreen() {
    return TestHelper.createTestApp(
      home: RegistrationScreen(
        apiService: TestHelper.mockApiService,
      ),
    );
  }

  group('RegistrationScreen', () {
    testWidgets('renders registration form', (WidgetTester tester) async {
      await tester.pumpWidget(createRegistrationScreen());
      await tester.pumpAndSettle();

      // Check for form fields
      expect(find.byType(TextField), findsWidgets);

      // Check for required fields
      expect(find.text('Vorname'), findsOneWidget);
      expect(find.text('Nachname'), findsOneWidget);
      expect(find.text('Schützenausweisnummer'), findsOneWidget);
      expect(find.text('E-Mail'), findsOneWidget);
    });

    testWidgets('renders privacy checkbox', (WidgetTester tester) async {
      await tester.pumpWidget(createRegistrationScreen());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('privacyCheckbox')), findsOneWidget);
    });

    testWidgets('can enter text in fields', (WidgetTester tester) async {
      await tester.pumpWidget(createRegistrationScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Test');
      await tester.pumpAndSettle();

      expect(find.text('Test'), findsOneWidget);
    });
  });

  group('Email Validation', () {
    testWidgets('accepts .bayern TLD', (WidgetTester tester) async {
      await tester.pumpWidget(createRegistrationScreen());
      await tester.pumpAndSettle();

      // Find the email field (4th TextField)
      final emailFields = find.byType(TextField);
      await tester.enterText(emailFields.at(2), 'test@example.bayern');
      await tester.pumpAndSettle();

      // Should not show email error for .bayern domain
      expect(
        find.text('Bitte geben Sie eine gültige E-Mail Adresse ein.'),
        findsNothing,
      );
    });

    testWidgets('accepts standard TLDs like .com and .de',
        (WidgetTester tester) async {
      await tester.pumpWidget(createRegistrationScreen());
      await tester.pumpAndSettle();

      final emailFields = find.byType(TextField);

      // Test .com
      await tester.enterText(emailFields.at(2), 'test@example.com');
      await tester.pumpAndSettle();
      expect(
        find.text('Bitte geben Sie eine gültige E-Mail Adresse ein.'),
        findsNothing,
      );

      // Test .de
      await tester.enterText(emailFields.at(2), 'test@example.de');
      await tester.pumpAndSettle();
      expect(
        find.text('Bitte geben Sie eine gültige E-Mail Adresse ein.'),
        findsNothing,
      );
    });

    testWidgets('accepts long TLDs like .photography',
        (WidgetTester tester) async {
      await tester.pumpWidget(createRegistrationScreen());
      await tester.pumpAndSettle();

      final emailFields = find.byType(TextField);
      await tester.enterText(emailFields.at(2), 'test@example.photography');
      await tester.pumpAndSettle();

      expect(
        find.text('Bitte geben Sie eine gültige E-Mail Adresse ein.'),
        findsNothing,
      );
    });
  });

  group('Existing Account Check', () {
    testWidgets(
        'does not show existing account warning on form when entering pass number',
        (WidgetTester tester) async {
      await tester.pumpWidget(createRegistrationScreen());
      await tester.pumpAndSettle();

      // Enter pass number
      final passNumberField = find.byType(TextField).at(3);
      await tester.enterText(passNumberField, '12345678');
      await tester.pumpAndSettle();

      // The existing account warning should not be displayed on the form
      // (it was removed - now shown via RegistrationFailScreen during registration)
      expect(
        find.text(
          'Sie haben bereits einen gültigen MeinBSSB Account.\nBitte melden Sie sich mit den bekannten Daten an.\nSollten Sie ihr Passwort vergessen haben, führen Sie eine Passwortrücksetzung durch.\nSollten Sie ihre Account e-Mail Adresse vergessen, oder sonstige Fragen haben, wenden Sie sich bitte an webportal@bssb.bayern',
        ),
        findsNothing,
      );
    });
  });
}
