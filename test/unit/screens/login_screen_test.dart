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
import 'package:meinbssb/services/email_service.dart';
import 'package:meinbssb/services/config_service.dart';
import 'package:meinbssb/services/cache_service.dart'; // <--- NEW: Import CacheService

// Generate mocks for all services your test setup uses
@GenerateMocks([
  AuthService,
  ApiService,
  EmailService,
  ConfigService,
  CacheService,
]) // <--- MODIFIED: Added CacheService
import 'login_screen_test.mocks.dart';

// Create a simple mock LogoWidget to replace the actual one during tests
class MockLogoWidget extends StatelessWidget {
  const MockLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 100, height: 50); // A simple placeholder
  }
}

void main() {
  late MockAuthService mockAuthService;
  late MockApiService mockApiService;
  late MockEmailService mockEmailService;
  late MockConfigService mockConfigService;
  late MockCacheService
      mockCacheService; // <--- NEW: Mock CacheService instance
  late void Function(Map<String, dynamic>) onLoginSuccessCallback;

  setUp(() {
    mockAuthService = MockAuthService();
    mockApiService = MockApiService();
    mockEmailService = MockEmailService();
    mockConfigService = MockConfigService();
    mockCacheService = MockCacheService(); // <--- NEW: Initialize CacheService
    onLoginSuccessCallback = (userData) {};

    // Setup default mock behaviors for ApiService
    when(mockApiService.fetchSchuetzenausweis(any))
        .thenAnswer((_) async => Uint8List(0));

    // --- MODIFIED MOCKING FOR fetchPassdaten ---
    // This mock now returns the single Map<String, dynamic> that your ApiService.fetchPassdaten
    // method is expected to return AFTER it has processed the List response from the backend.
    when(mockApiService.fetchPassdaten(any)).thenAnswer(
      (_) async => {
        'PASSNUMMER': '40100709',
        'VEREINNR': 401051,
        'NAMEN': 'Schürz',
        'VORNAME': 'Lukas',
        'TITEL': '',
        'GEBURTSDATUM': '1955-07-16T00:00:00.000+02:00',
        'GESCHLECHT': 1,
        'EINTRITTBSSB': '2001-11-01T00:00:00.000+01:00',
        'VEREINNAME': 'Feuerschützen Kühbach',
        'STRASSE': 'Aichacher Strasse 21',
        'PLZ': '86574',
        'ORT': 'Alsmoos',
        'LAND': '',
        'NATIONALITAET': 'GRC',
        'PASSSTATUS': 1,
        'PASSDATENID': 2000009155,
        'EINTRITTVEREIN': '2008-03-07T00:00:00.000+01:00',
        'AUSTRITTVEREIN': '',
        'MITGLIEDSCHAFTID': 439287,
        'TELEFON': '08232-9978250',
        'PERSONID': 439287,
        'ERSTLANDESVERBANDID': 0,
        'PRODUKTIONSDATUM': '2023-06-20T00:00:00.000+02:00',
        'ERSTVEREINID': 1511,
        'DIGITALERPASS': 0,
      },
    );
    // -------------------------------------------

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

    testWidgets('calls authService with correct credentials',
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
      await tester
          .pumpAndSettle(); // Wait for all async ops to complete before verifying

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
                    // --- REFINED ASSERTIONS FOR userData ---
                    // userData will be the combined map from fetchPassdaten + PERSONID + WEBLOGINID
                    expect(userData['PERSONID'], 123);
                    expect(userData['WEBLOGINID'], 456);
                    expect(
                      userData['VORNAME'],
                      'Lukas',
                    ); // Check a field from the mocked passdaten
                    expect(userData['NAMEN'], 'Schürz');
                    expect(userData['PASSNUMMER'], '40100709');
                    // Add more specific asserts if needed based on the completeUserData structure
                    // -------------------------------------
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
  });
}
