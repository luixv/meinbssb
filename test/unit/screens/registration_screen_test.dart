import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:meinbssb/screens/registration_screen.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/core/email_service.dart';
import 'package:meinbssb/services/core/config_service.dart';

import 'registration_screen_test.mocks.dart';

@GenerateMocks([AuthService, EmailService, ConfigService, EmailSender])
void main() {
  late MockAuthService mockAuthService;
  late MockEmailService mockEmailService;
  late MockConfigService mockConfigService;
  late MockEmailSender mockEmailSender;

  setUp(() {
    mockAuthService = MockAuthService();
    mockEmailService = MockEmailService();
    mockConfigService = MockConfigService();
    mockEmailSender = MockEmailSender();

    when(mockConfigService.getString('logoName', 'appTheme'))
        .thenReturn('assets/images/myBSSB-logo.png');
  });

  Future<void> pumpRegistrationScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ConfigService>.value(value: mockConfigService),
          Provider<AuthService>.value(value: mockAuthService),
          Provider<EmailService>.value(value: mockEmailService),
          Provider<EmailSender>.value(value: mockEmailSender),
        ],
        child: MaterialApp(
          home: Scaffold(
            // Wrap RegistrationScreen with a Scaffold
            body: RegistrationScreen(
              authService: mockAuthService,
              emailService: mockEmailService,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Text Field are present', (WidgetTester tester) async {
    await pumpRegistrationScreen(tester);

    expect(find.byKey(const Key('firstNameField')), findsOneWidget);
    expect(find.byKey(const Key('lastNameField')), findsOneWidget);
    expect(find.byKey(const Key('passNumberField')), findsOneWidget);
    expect(find.byKey(const Key('emailField')), findsOneWidget);
  });

  group('Pure Validation Tests', () {
    test('Pass number validation - accepts 8 digits', () {
      final state = RegistrationScreenState();
      expect(state.validatePassNumber('12345678'), isTrue);
    });

    test('Pass number validation - rejects non-8-digit inputs', () {
      final state = RegistrationScreenState();
      expect(state.validatePassNumber('1234'), isFalse); // Too short
      expect(state.validatePassNumber('123456789'), isFalse); // Too long
      expect(state.validatePassNumber('abcdefgh'), isFalse); // Non-digits
      expect(state.validatePassNumber(''), isFalse); // Empty
    });

    test('Zip code validation', () {
      final state = RegistrationScreenState();
      expect(state.validateZipCode('12345'), isTrue);
      expect(state.validateZipCode('123'), isFalse);
    });

    test('Zip code validation - rejects non-5-digit inputs', () {
      final state = RegistrationScreenState();
      expect(state.validateZipCode('123'), isFalse); // Too short
      expect(state.validateZipCode('123456'), isFalse); // Too long
      expect(state.validateZipCode('abcde'), isFalse); // Non-digits
      expect(state.validateZipCode(''), isFalse); // Empty
    });

    test('Email validation - accepts valid emails', () {
      final state = RegistrationScreenState();
      expect(state.validateEmail('test@example.com'), isTrue);
    });

    test('Email validation - rejects invalid emails', () {
      final state = RegistrationScreenState();
      expect(state.validateEmail('plainstring'), isFalse);
      expect(state.validateEmail('missing@'), isFalse);
      expect(state.validateEmail('@domain.com'), isFalse);
      expect(state.validateEmail('mein@@domain.com'), isFalse);
    });

    test('Email validation', () {
      final state = RegistrationScreenState();
      expect(state.validateEmail('test@test.com'), isTrue);
      expect(state.validateEmail('invalid'), isFalse);
    });
  });
}
