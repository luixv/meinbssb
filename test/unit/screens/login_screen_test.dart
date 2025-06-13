// Project: Mein BSSB
// Filename: login_screen_test.dart
// Author: Luis Mandel / NTT DATA

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:meinbssb/screens/login_screen.dart';
import 'package:meinbssb/screens/password_reset_screen.dart';
import 'package:meinbssb/screens/registration_screen.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/services/core/email_service.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/core/cache_service.dart';

import 'login_screen_test.mocks.dart';

@GenerateMocks(
  [],
  customMocks: [
    MockSpec<AuthService>(as: #MockAuthService),
    MockSpec<ApiService>(as: #MockApiService),
    MockSpec<ConfigService>(as: #MockConfigService),
    MockSpec<EmailService>(as: #MockEmailService),
    MockSpec<CacheService>(as: #MockCacheService),
  ],
)
void main() {
  late MockAuthService mockAuthService;
  late MockApiService mockApiService;
  late MockConfigService mockConfigService;
  late MockEmailService mockEmailService;
  late MockCacheService mockCacheService;

  setUp(() {
    mockAuthService = MockAuthService();
    mockApiService = MockApiService();
    mockConfigService = MockConfigService();
    mockEmailService = MockEmailService();
    mockCacheService = MockCacheService();

    when(mockConfigService.getString('logoName', 'appTheme'))
        .thenReturn('assets/images/myBSSB-logo.png');
    when(mockAuthService.login(any, any)).thenAnswer(
      (_) async => {
        'ResultType': 1,
        'PersonID': 439287,
        'WebLoginID': 13901,
      },
    );
    when(mockApiService.fetchPassdaten(any)).thenAnswer(
      (_) async => const UserData(
        personId: 439287,
        webLoginId: 13901,
        passnummer: '40100709',
        vereinNr: 401051,
        namen: 'Schürz',
        vorname: 'Lukas',
        vereinName: 'Feuerschützen Kühbach',
        passdatenId: 2000009155,
        mitgliedschaftId: 439287,
        strasse: 'Aichacher Strasse 21',
        plz: '86574',
        ort: 'Alsmoos',
      ),
    );
    when(mockApiService.fetchSchuetzenausweis(any))
        .thenAnswer((_) async => Uint8List(0));
  });

  Widget createLoginScreen({
    AuthService? authService,
    ApiService? apiService,
    CacheService? cacheService,
    ConfigService? configService,
    Function? onLoginSuccess,
  }) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => authService ?? mockAuthService,
        ),
        Provider<ApiService>(
          create: (_) => apiService ?? mockApiService,
        ),
        Provider<CacheService>(
          create: (_) => cacheService ?? mockCacheService,
        ),
        Provider<ConfigService>(
          create: (_) => configService ?? mockConfigService,
        ),
      ],
      child: MaterialApp(
        home: LoginScreen(onLoginSuccess: (_) {}),
        routes: {
          '/home': (context) => const Placeholder(),
          '/login': (context) => LoginScreen(onLoginSuccess: (_) {}),
          '/password-reset': (context) => PasswordResetScreen(
                authService: mockAuthService,
                userData: null,
                isLoggedIn: false,
                onLogout: () {},
              ),
          '/help': (context) => const Scaffold(body: Text('Hilfe')),
          '/register': (context) => RegistrationScreen(
                authService: mockAuthService,
                emailService: mockEmailService,
              ),
        },
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('renders the title', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      expect(find.text('Hier anmelden'), findsOneWidget);
    });

    testWidgets('renders email and password text fields and login button',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      expect(find.byKey(const Key('usernameField')), findsOneWidget);
      expect(find.byKey(const Key('passwordField')), findsOneWidget);
      expect(find.byKey(const Key('loginButton')), findsOneWidget);
    });

    testWidgets('toggles password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      final passwordField =
          tester.widget<TextField>(find.byKey(const Key('passwordField')));
      expect(passwordField.obscureText, isTrue);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump(); // Rebuild the widget after tap

      final updatedField =
          tester.widget<TextField>(find.byKey(const Key('passwordField')));
      expect(updatedField.obscureText, isFalse);
    });

    testWidgets('shows loading indicator during login',
        (WidgetTester tester) async {
      // Delay the login response to test loading state
      when(mockAuthService.login(any, any)).thenAnswer((_) async {
        await Future.delayed(
          const Duration(seconds: 1),
        ); // Simulate network delay
        return {'ResultType': 1, 'PersonID': 123, 'WebLoginID': 456};
      });

      await tester.pumpWidget(createLoginScreen());
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump(); // Trigger a frame to show the loading indicator

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle(); // Wait for login and navigation to complete
    });

    testWidgets(
        'calls authService with correct credentials and handles UserData',
        (WidgetTester tester) async {
      when(mockAuthService.login(any, any)).thenAnswer(
        (_) async => {'ResultType': 1, 'PersonID': 123, 'WebLoginID': 456},
      );

      await tester.pumpWidget(createLoginScreen());

      await tester.enterText(
        find.byKey(const Key('usernameField')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      verify(mockAuthService.login('test@example.com', 'password123'))
          .called(1);
    });

    testWidgets('shows error on invalid login', (WidgetTester tester) async {
      when(mockAuthService.login(any, any)).thenAnswer(
        (_) async => {'ResultType': 0, 'ResultMessage': 'Invalid credentials'},
      );

      await tester.pumpWidget(createLoginScreen());
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle(); // Wait for error message to appear

      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('LoginScreen successful login calls callback and navigates',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      await tester.enterText(
        find.byKey(const Key('usernameField')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password',
      );

      final loginButton = find.byKey(const Key('loginButton'));
      await tester.tap(loginButton);
      await tester.pump(); // First pump to start the async operation
      await tester
          .pumpAndSettle(); // Wait for all animations and async operations to complete

      expect(find.byType(Placeholder), findsOneWidget);
    });

    testWidgets('login screen shows error on failed login',
        (WidgetTester tester) async {
      when(mockAuthService.login(any, any)).thenAnswer(
        (_) async => {
          'ResultType': 0,
          'ResultMessage': 'Invalid credentials',
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              Provider<AuthService>(create: (_) => mockAuthService),
              Provider<ApiService>(create: (_) => mockApiService),
              Provider<EmailService>(create: (_) => mockEmailService),
              Provider<ConfigService>(create: (_) => mockConfigService),
              Provider<CacheService>(create: (_) => mockCacheService),
            ],
            child: LoginScreen(onLoginSuccess: (_) {}),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('usernameField')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password',
      );
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('handles login failure', (WidgetTester tester) async {
      when(mockAuthService.login(any, any)).thenAnswer(
        (_) async => {'ResultType': 0, 'ResultMessage': 'Invalid credentials'},
      );

      await tester.pumpWidget(createLoginScreen());

      await tester.enterText(
        find.byKey(const Key('usernameField')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('handles network error', (WidgetTester tester) async {
      when(mockAuthService.login(any, any))
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(createLoginScreen());

      await tester.enterText(
        find.byKey(const Key('usernameField')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      expect(
        find.text('Error: Exception: Network error'),
        findsOneWidget,
      );
    });

    testWidgets('navigates to password reset screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      await tester.tap(find.text('Passwort vergessen?'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('passwordResetTitle')), findsOneWidget);
    });
  });
}
