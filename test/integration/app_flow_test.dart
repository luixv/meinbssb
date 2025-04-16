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
        find.byKey(const Key('usernameField')),
        'luis@mandel.pro',
      );
      await tester.enterText(find.byKey(const Key('passwordField')), 'a');

      // Tap the login button
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      // Verify we're on the start screen after successful login
      expect(find.byType(StartScreen), findsOneWidget);

      // Verify user data is displayed
      expect(find.text('Luis Mandel'), findsOneWidget);
      expect(find.text('41299999'), findsOneWidget);

      // Test accessing Schuetzenausweis
      await tester.tap(find.byKey(const Key('schuetzenausweisButton')));
      await tester.pumpAndSettle();

      // Verify Schuetzenausweis is displayed
      expect(find.byType(Image), findsOneWidget);

      // Test accessing Zweitmitgliedschaften
      // Access Schuetzenausweis
      await tester.tap(find.byIcon(Icons.menu)); // Open the PopupMenuButton
      await tester.pumpAndSettle();
      await tester.tap(
        find.text('Digitaler Schützenausweis'),
      ); // Tap the menu item
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);

      // Access Zweitmitgliedschaften
      await tester.tap(find.byIcon(Icons.menu)); // Open the PopupMenuButton
      await tester.pumpAndSettle();
      await tester.tap(find.text('Zweitmitgliedschaften')); // Tap the menu item
      await tester.pumpAndSettle();
      expect(find.text('Zweitmitgliedschaften'), findsOneWidget);

      // Test logout
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Abmelden'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Error handling during login', (tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const MyAppWrapper());

      // Verify we're on the login screen
      expect(find.byType(LoginScreen), findsOneWidget);

      // Enter invalid credentials
      await tester.enterText(
        find.byKey(const Key('usernameField')),
        'invalid@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'wrongpassword',
      );

      // Tap the login button
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      // Verify error message is displayed
      expect(
        find.text(
          'Benutzername oder Passwort ist falsch', // Corrected error message
        ),
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
        find.byKey(const Key('usernameField')),
        'luis@mandel.pro',
      );
      await tester.enterText(find.byKey(const Key('passwordField')), 'a');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      // Verify offline mode message or behavior
      expect(
        find.text(
          'Offline mode', // You might need to adjust this based on the actual message
        ),
        findsOneWidget,
      );
      // You might also want to check if cached data is displayed if that's your offline behavior.
      // expect(find.text('Cached Data'), findsOneWidget);
    });
  });
}

// Create a mock class for NetworkService
class MockNetworkService extends Mock implements NetworkService {}
