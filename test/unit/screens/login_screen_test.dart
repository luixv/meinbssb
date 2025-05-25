import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

import 'package:meinbssb/screens/login_screen.dart';
// Import the actual LogoWidget
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/email_service.dart';
import 'package:meinbssb/services/config_service.dart';

// Generate mocks
@GenerateMocks([AuthService, ApiService, EmailService, ConfigService])
import 'login_screen_test.mocks.dart';

// Create a simple mock LogoWidget
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
  late void Function(Map<String, dynamic>) onLoginSuccessCallback;

  setUp(() {
    mockAuthService = MockAuthService();
    mockApiService = MockApiService();
    mockEmailService = MockEmailService();
    mockConfigService = MockConfigService();
    onLoginSuccessCallback = (userData) {};

    // Setup default mock behaviors for ApiService
    when(mockApiService.fetchSchuetzenausweis(any))
        .thenAnswer((_) async => Uint8List(0));
    when(mockApiService.fetchPassdaten(any))
        .thenAnswer((_) async => {'name': 'Test User'});
    when(mockConfigService.getString('logoName', 'appTheme'))
        .thenReturn('irrelevant_logo_name'); // The name doesn't matter now
  });

  Widget createLoginScreen({
    MockApiService? apiService,
    MockConfigService? configService,
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
        ],
        child: Builder(
          // Use Builder to get a context within MultiProvider
          builder: (context) {
            // Replace LogoWidget with MockLogoWidget directly in the build method for testing
            return LoginScreen(
              onLoginSuccess: onLoginSuccessCallback,
              logoWidget: const MockLogoWidget(), // Provide the mock
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
      expect(
        find.byType(MockLogoWidget),
        findsOneWidget,
      ); // Now we expect the mock
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
      await tester.pump();

      final updatedField =
          tester.widget<TextField>(find.byKey(const Key('passwordField')));
      expect(updatedField.obscureText, isFalse);
    });

    testWidgets('shows loading indicator during login',
        (WidgetTester tester) async {
      // Delay the login response to test loading state
      when(mockAuthService.login(any, any)).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        return {'ResultType': 1, 'PersonID': 123};
      });

      await tester.pumpWidget(createLoginScreen());
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump(); // Show loading state

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle(); // Complete login
    });

    testWidgets('calls authService with correct credentials',
        (WidgetTester tester) async {
      when(mockAuthService.login(any, any))
          .thenAnswer((_) async => {'ResultType': 1, 'PersonID': 123});

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

      verify(mockAuthService.login('test@example.com', 'password123'))
          .called(1);
    });

    testWidgets('shows error on invalid login', (WidgetTester tester) async {
      when(mockAuthService.login(any, any)).thenAnswer(
        (_) async => {'ResultType': 0, 'ResultMessage': 'Invalid credentials'},
      );

      await tester.pumpWidget(createLoginScreen());
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('successful login calls callback and navigates',
        (WidgetTester tester) async {
      var loginSuccessCalled = false;

      when(mockAuthService.login(any, any))
          .thenAnswer((_) async => {'ResultType': 1, 'PersonID': 123});

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              Provider<AuthService>(create: (_) => mockAuthService),
              Provider<ApiService>(create: (_) => mockApiService),
              Provider<EmailService>(create: (_) => mockEmailService),
              Provider<ConfigService>(create: (_) => mockConfigService),
            ],
            child: Builder(
              builder: (context) {
                return LoginScreen(
                  onLoginSuccess: (userData) {
                    loginSuccessCalled = true;
                    expect(userData['PERSONID'], 123);
                  },
                  logoWidget: const MockLogoWidget(), // Provide the mock
                );
              },
            ),
          ),
          routes: {
            '/home': (context) => const Placeholder(),
          },
        ),
      );

      Finder loginButton = find.byKey(const Key('loginButton'));

      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(loginSuccessCalled, isTrue);
      Finder placeholder = find.byType(Placeholder);
      expect(placeholder, findsOneWidget);
    });
  });
}
