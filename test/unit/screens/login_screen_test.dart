// Project: Mein BSSB
// Filename: login_screen_test.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'package:meinbssb/screens/login_screen.dart';
import 'package:meinbssb/screens/password_reset_screen.dart';
import 'package:meinbssb/screens/registration_screen.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/email_service.dart';
import 'package:meinbssb/widgets/scaled_text.dart';

import '../helpers/test_helper.dart';

@GenerateMocks([AuthService, ApiService, EmailService])
void main() {
  setUp(() {
    TestHelper.setupMocks();
  });

  Widget createLoginScreen() {
    return TestHelper.createTestApp(
      home: LoginScreen(onLoginSuccess: (_) {}),
      routes: {
        '/home': (context) => const Placeholder(),
        '/login': (context) => LoginScreen(onLoginSuccess: (_) {}),
        '/password-reset': (context) => PasswordResetScreen(
              apiService: TestHelper.mockApiService,
              userData: null,
              isLoggedIn: false,
              onLogout: () {},
            ),
        '/help': (context) => const Scaffold(body: Text('Hilfe')),
        '/register': (context) => RegistrationScreen(
              authService: TestHelper.mockAuthService,
              emailService: TestHelper.mockEmailService,
            ),
      },
    );
  }

  group('LoginScreen', () {
    testWidgets('renders the title', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      expect(find.text('Anmeldung'), findsOneWidget);
    });

    testWidgets('renders email and password fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('usernameField')), findsOneWidget);
      expect(find.byKey(const Key('passwordField')), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Passwort'), findsOneWidget);
    });

    testWidgets('renders login button', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('loginButton')), findsOneWidget);
    });

    testWidgets('renders forgot password and help buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('forgotPasswordButton')), findsOneWidget);
      expect(find.byKey(const Key('helpButton')), findsOneWidget);
    });

    testWidgets('renders register button', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('registerButton')), findsOneWidget);
    });

    testWidgets('renders remember me checkbox', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      expect(find.text('Angemeldet bleiben'), findsOneWidget);
    });

    testWidgets('password visibility toggle works',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      final passwordField =
          tester.widget<TextField>(find.byKey(const Key('passwordField')));
      expect(passwordField.obscureText, isTrue);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump(); // Rebuild the widget after tap

      final updatedField =
          tester.widget<TextField>(find.byKey(const Key('passwordField')));
      expect(updatedField.obscureText, isFalse);
    });

    testWidgets('can enter text in fields', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('usernameField')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password123',
      );
      await tester.pumpAndSettle();

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('minimal login screen provider test',
        (WidgetTester tester) async {
      TestHelper.setupMocks();
      await tester.pumpWidget(
        TestHelper.createTestApp(
          home: LoginScreen(onLoginSuccess: (_) {}),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(ScaledText), findsWidgets); // Should find at least one
    });
  });
}
