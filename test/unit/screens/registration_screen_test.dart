import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:meinbssb/screens/registration_screen.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/core/email_service.dart';
import '../helpers/test_helper.dart';

@GenerateMocks([AuthService, EmailService])
void main() {
  setUp(() {
    TestHelper.setupMocks();
  });

  Widget createRegistrationScreen() {
    return TestHelper.createTestApp(
      home: RegistrationScreen(
        authService: TestHelper.mockAuthService,
        emailService: TestHelper.mockEmailService,
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
      expect(find.text('Postleitzahl'), findsOneWidget);
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
}
