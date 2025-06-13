// Project: Mein BSSB
// Filename: login_screen_test.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

import 'package:meinbssb/screens/login_screen.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/email_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/models/user_data.dart';

@GenerateMocks([
  AuthService,
  ApiService,
  EmailService,
  ConfigService,
  CacheService,
])
import 'login_screen_test.mocks.dart';

class MockLogoWidget extends StatelessWidget {
  const MockLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

void main() {
  late MockAuthService mockAuthService;
  late MockApiService mockApiService;
  late MockEmailService mockEmailService;
  late MockConfigService mockConfigService;
  late MockCacheService mockCacheService;
  late void Function(UserData) onLoginSuccessCallback;

  setUp(() {
    mockAuthService = MockAuthService();
    mockApiService = MockApiService();
    mockEmailService = MockEmailService();
    mockConfigService = MockConfigService();
    mockCacheService = MockCacheService();
    onLoginSuccessCallback = (userData) {};

    // Setup default mock behaviors for ApiService
    when(mockApiService.fetchSchuetzenausweis(any))
        .thenAnswer((_) async => Uint8List(0));

    when(mockApiService.fetchPassdaten(any)).thenAnswer(
      (_) async => UserData(
        personId: 439287,
        webLoginId: 13901,
        passnummer: '40100709',
        vereinNr: 401051,
        namen: 'Schürz',
        vorname: 'Lukas',
        titel: '',
        geburtsdatum: DateTime.parse('1955-07-16T00:00:00.000+02:00'),
        geschlecht: 1,
        vereinName: 'Feuerschützen Kühbach',
        passdatenId: 2000009155,
        mitgliedschaftId: 439287,
        strasse: 'Aichacher Strasse 21',
        plz: '86574',
        ort: 'Alsmoos',
        isOnline: false,
      ),
    );

    when(mockConfigService.getString('logoName', 'appTheme'))
        .thenReturn('irrelevant_logo_name');

    when(mockCacheService.getString('authToken'))
        .thenAnswer((_) async => 'dummy_auth_token');
  });

  // Helper function to create the LoginScreen widget tree for tests
  Widget createLoginScreen({
    MockApiService? apiService,
    MockConfigService? configService,
    MockCacheService? cacheService, // <--- NEW: Parameter for CacheService
  }) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<AuthService>(create: (_) => mockAuthService),
          Provider<ApiService>(create: (_) => apiService ?? mockApiService),
          Provider<EmailService>(create: (_) => mockEmailService),
          Provider<ConfigService>(
            create: (_) => configService ?? mockConfigService,
          ),
          Provider<CacheService>(
            // <--- NEW: Provide MockCacheService
            create: (_) => cacheService ?? mockCacheService,
          ),
        ],
        child: Builder(
          builder: (context) {
            return LoginScreen(
              onLoginSuccess: onLoginSuccessCallback,
              logoWidget: const MockLogoWidget(), // Provide the mock logo
            );
          },
        ),
      ),
      routes: {
        '/home': (context) => const Placeholder(),
        '/login': (context) =>
            LoginScreen(onLoginSuccess: onLoginSuccessCallback),
      },
    );
  }

  group('LoginScreen', () {
    testWidgets('renders the placeholder logo and title',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      expect(find.byType(MockLogoWidget), findsOneWidget);
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

      bool loginSuccessCalled = false;
      onLoginSuccessCallback = (userData) {
        loginSuccessCalled = true;
        expect(userData.personId, 439287);
        expect(userData.webLoginId, 13901);
        expect(userData.vorname, 'Lukas');
        expect(userData.namen, 'Schürz');
        expect(userData.passnummer, '40100709');
      };

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
      expect(loginSuccessCalled, isTrue);
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

    testWidgets('successful login calls callback and navigates',
        (WidgetTester tester) async {
      var loginSuccessCalled = false;

      // Mock the login service to return success
      when(mockAuthService.login(any, any)).thenAnswer(
        (_) async => {'ResultType': 1, 'PersonID': 123, 'WebLoginID': 456},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              Provider<AuthService>(create: (_) => mockAuthService),
              Provider<ApiService>(create: (_) => mockApiService),
              Provider<EmailService>(create: (_) => mockEmailService),
              Provider<ConfigService>(create: (_) => mockConfigService),
              Provider<CacheService>(
                create: (_) => mockCacheService,
              ), // <--- NEW: Provide MockCacheService
            ],
            child: Builder(
              builder: (context) {
                return LoginScreen(
                  onLoginSuccess: (userData) {
                    loginSuccessCalled = true;
                    expect(userData.personId, 123);
                    expect(userData.webLoginId, 456);
                    expect(userData.vorname, 'Lukas');
                    expect(userData.namen, 'Schürz');
                    expect(userData.passnummer, '40100709');
                  },
                  logoWidget: const MockLogoWidget(),
                );
              },
            ),
          ),
          routes: {
            '/home': (context) =>
                const Placeholder(), // Target route for successful login
          },
        ),
      );

      Finder loginButton = find.byKey(const Key('loginButton'));

      // Simulate entering text (important to ensure _handleLogin is called correctly)
      await tester.enterText(
        find.byKey(const Key('usernameField')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password',
      );

      await tester.tap(loginButton);
      await tester
          .pumpAndSettle(); // Wait for all async operations to complete, including navigation

      expect(loginSuccessCalled, isTrue);
      // Verify navigation to '/home' by checking for the Placeholder widget
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
            child: LoginScreen(
              onLoginSuccess: (_) {},
              logoWidget: const MockLogoWidget(),
            ),
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

    testWidgets('login screen navigates on successful login',
        (WidgetTester tester) async {
      bool loginSuccessCalled = false;

      when(mockAuthService.login(any, any)).thenAnswer(
        (_) async => {
          'ResultType': 1,
          'PersonID': 123,
          'WebLoginID': 456,
        },
      );

      const testUserData = UserData(
        personId: 439287,
        webLoginId: 13901,
        passnummer: '40100709',
        vereinNr: 401051,
        namen: 'Schürz',
        vorname: 'Lukas',
        titel: '',
        geburtsdatum: null,
        geschlecht: 1,
        vereinName: 'Feuerschützen Kühbach',
        passdatenId: 2000009155,
        mitgliedschaftId: 439287,
        strasse: 'Aichacher Strasse 21',
        plz: '86574',
        ort: 'Alsmoos',
        isOnline: false,
      );

      when(mockApiService.fetchPassdaten(any)).thenAnswer(
        (_) async => testUserData,
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
            child: Builder(
              builder: (context) {
                return LoginScreen(
                  onLoginSuccess: (userData) {
                    loginSuccessCalled = true;
                    expect(userData.personId, 439287);
                    expect(userData.webLoginId, 13901);
                    expect(userData.vorname, 'Lukas');
                    expect(userData.namen, 'Schürz');
                    expect(userData.passnummer, '40100709');
                  },
                  logoWidget: const MockLogoWidget(),
                );
              },
            ),
          ),
          routes: {
            '/home': (context) => const Placeholder(),
          },
        ),
      );

      await tester.enterText(
        find.byKey(const Key('usernameField')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password',
      );
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      expect(loginSuccessCalled, isTrue);
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
        find.text(
            'Netzwerkfehler oder Server nicht erreichbar: Exception: Network error',),
        findsOneWidget,
      );
    });

    testWidgets('navigates to password reset screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      await tester.tap(find.byKey(const Key('forgotPasswordButton')));
      await tester.pumpAndSettle();

      expect(find.text('Passwort zurücksetzen'), findsOneWidget);
    });

    testWidgets('navigates to help screen', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      await tester.tap(find.byKey(const Key('helpButton')));
      await tester.pumpAndSettle();

      expect(find.text('Hilfe'), findsOneWidget);
    });

    testWidgets('navigates to registration screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      await tester.tap(find.byKey(const Key('registerButton')));
      await tester.pumpAndSettle();

      expect(find.text('Registrierung'), findsOneWidget);
    });
  });
}
