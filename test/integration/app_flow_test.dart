import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/app.dart';
import 'package:meinbssb/screens/login_screen.dart';
import 'package:meinbssb/screens/start_screen.dart';
import 'package:meinbssb/services/network_service.dart';
import 'package:meinbssb/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Flow Integration Tests', () {
    late NetworkService networkService;

    setUpAll(() async {
      // Initialize the app's service providers
      await AppInitializer.init();

      // Initialize a mock NetworkService for offline testing
      networkService = MockNetworkService();
    });

    testWidgets('Complete user flow from login to accessing data', (
      tester,
    ) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const MyAppWrapper());

      // Verify we're on the login screen
      expect(find.byType(LoginScreen), findsOneWidget);

      // Enter login credentials
      await tester.enterText(
        find.byKey(
          const Key('usernameField'),
        ), // Name field at the login screen
        'luis@mandel.pro',
      );
      await tester.enterText(
        find.byKey(
          const Key('passwordField'),
        ), // Password field at the login screen
        'a',
      );

      // Tap the login button
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      // Verify we're on the start screen after successful login
      expect(find.byType(StartScreen), findsOneWidget);

      // Verify user data is displayed (adjust these expectations based on your StartScreen)
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('ABC123'), findsOneWidget);

      // Test accessing Schuetzenausweis (adjust keys based on your StartScreen)
      await tester.tap(find.byKey(const Key('schuetzenausweisButton')));
      await tester.pumpAndSettle();

      // Verify Schuetzenausweis is displayed (adjust finder based on your UI)
      expect(find.byType(Image), findsOneWidget);

      // Test accessing Zweitmitgliedschaften (adjust keys based on your StartScreen)
      await tester.tap(find.byKey(const Key('zweitmitgliedschaftenButton')));
      await tester.pumpAndSettle();

      // Verify Zweitmitgliedschaften screen is displayed (adjust finder based on your UI)
      expect(find.text('Zweitmitgliedschaften'), findsOneWidget);

      // Test logout (adjust key based on your UI)
      await tester.tap(find.byKey(const Key('logoutButton')));
      await tester.pumpAndSettle();

      // Verify we're back on the login screen
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Error handling during login', (tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const MyAppWrapper());

      // Verify we're on the login screen
      expect(find.byType(LoginScreen), findsOneWidget);

      // Enter invalid credentials
      await tester.enterText(
        find.byKey(const Key('usernameField')), // Changed to 'usernameField'
        'invalid@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')), // Correct key
        'wrongpassword',
      );

      // Tap the login button
      await tester.tap(
        find.byKey(const Key('loginButton')), // Correct key
      );
      await tester.pumpAndSettle();

      // Verify error message is displayed
      expect(
        find.text(
          'Invalid credentials',
        ), // You might need to adjust this based on the actual error message
        findsOneWidget,
      );
    });

    testWidgets('Offline mode functionality', (tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const MyAppWrapper());

      // Verify we're on the login screen (assuming it's the starting point)
      expect(find.byType(LoginScreen), findsOneWidget);

      // Simulate offline mode
      when(networkService.hasInternet()).thenAnswer((_) async => false);

      // Attempt login
      await tester.enterText(
        find.byKey(const Key('usernameField')), // The username field
        'luis@mandel.pro',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')), // The password field
        'a',
      );
      await tester.tap(
        find.byKey(const Key('loginButton')), // Correct key
      );
      await tester.pumpAndSettle();

      // Verify offline mode message or behavior
      expect(
        find.text(
          'Offline mode',
        ), // You might need to adjust this based on the actual message
        findsOneWidget,
      );
      // You might also want to check if cached data is displayed if that's your offline behavior.
      // expect(find.text('Cached Data'), findsOneWidget);
    });
  });
}

// Create a mock class for NetworkService
class MockNetworkService extends Mock implements NetworkService {}
