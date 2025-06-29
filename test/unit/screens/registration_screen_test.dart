import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:meinbssb/screens/registration_screen.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/core/email_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/services/core/font_size_provider.dart';

import 'registration_screen_test.mocks.dart';

@GenerateMocks([
  AuthService,
  EmailService,
  ConfigService,
  EmailSender,
  NetworkService,
  FontSizeProvider,
])
void main() {
  late MockAuthService mockAuthService;
  late MockEmailService mockEmailService;
  late MockConfigService mockConfigService;
  late MockEmailSender mockEmailSender;
  late MockNetworkService mockNetworkService;
  late MockFontSizeProvider mockFontSizeProvider;

  setUp(() {
    mockAuthService = MockAuthService();
    mockEmailService = MockEmailService();
    mockConfigService = MockConfigService();
    mockEmailSender = MockEmailSender();
    mockNetworkService = MockNetworkService();
    mockFontSizeProvider = MockFontSizeProvider();

    when(mockConfigService.getString('logoName', 'appTheme'))
        .thenReturn('assets/images/myBSSB-logo.png');
    when(mockNetworkService.hasInternet()).thenAnswer((_) async => true);
    when(mockFontSizeProvider.scaleFactor).thenReturn(1.0);
  });

  Future<void> pumpRegistrationScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ConfigService>.value(value: mockConfigService),
          Provider<AuthService>.value(value: mockAuthService),
          Provider<EmailService>.value(value: mockEmailService),
          Provider<EmailSender>.value(value: mockEmailSender),
          Provider<NetworkService>.value(value: mockNetworkService),
          ChangeNotifierProvider<FontSizeProvider>.value(
            value: mockFontSizeProvider,
          ),
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
    await tester.pumpAndSettle(); // Wait for FutureBuilder to complete

    // Look for text fields by their label text instead of keys
    expect(find.text('Vorname'), findsOneWidget);
    expect(find.text('Nachname'), findsOneWidget);
    expect(find.text('Schützenausweisnummer'), findsOneWidget);
    expect(find.text('E-Mail'), findsOneWidget);
  });

  testWidgets('Shows offline message when offline',
      (WidgetTester tester) async {
    // Mock offline state
    when(mockNetworkService.hasInternet()).thenAnswer((_) async => false);

    await pumpRegistrationScreen(tester);
    await tester.pumpAndSettle(); // Wait for FutureBuilder to complete

    expect(
      find.text('Registrierung ist offline nicht verfügbar'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Bitte stellen Sie sicher, dass Sie mit dem Internet verbunden sind, um sich zu registrieren.',
      ),
      findsOneWidget,
    );
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

  group('RegistrationScreen', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ConfigService>.value(value: mockConfigService),
            Provider<NetworkService>.value(value: mockNetworkService),
            ChangeNotifierProvider<FontSizeProvider>.value(
              value: mockFontSizeProvider,
            ),
          ],
          child: MaterialApp(
            home: RegistrationScreen(
              authService: mockAuthService,
              emailService: mockEmailService,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Registrierung'), findsWidgets);
      expect(find.text('Vorname'), findsOneWidget);
      expect(find.text('Nachname'), findsOneWidget);
      expect(find.text('E-Mail'), findsOneWidget);
      expect(find.byKey(const Key('registerButton')), findsOneWidget);
    });
  });
}
