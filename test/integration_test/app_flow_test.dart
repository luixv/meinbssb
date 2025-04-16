import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/app.dart';
import 'package:meinbssb/screens/login_screen.dart';
import 'package:meinbssb/screens/start_screen.dart';
import 'package:meinbssb/services/network_service.dart';
import 'package:meinbssb/main.dart';

@GenerateMocks([NetworkService])
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Flow Integration Tests', () {
    late MockNetworkService networkService;

    setUpAll(() async {
      // Initialize the app's service providers
      await AppInitializer.init();

      // Initialize a mock NetworkService and set default behavior
      networkService = MockNetworkService();
      when(
        networkService.hasInternet(),
      ).thenAnswer((_) async => true); // Default to online
    });

    testWidgets('Complete user flow from login to accessing data', (
      tester,
    ) async {
      // Wrap the app with Provider to inject the mock
      await tester.pumpWidget(
        Provider<NetworkService>.value(
          value: networkService,
          child: const MyAppWrapper(), // Use your main app widget
        ),
      );
      await tester.pumpAndSettle();

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

      // Verify user data is displayed (adjust these expectations based on your StartScreen)
      expect(find.text('Luis Mandel'), findsOneWidget);
      expect(find.text('41299999'), findsOneWidget);

      // Access Schuetzenausweis
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Digitaler Schützenausweis'));
      await tester.pumpAndSettle();
      expect(
        find.byType(Image),
        findsOneWidget,
      ); // Or whatever verifies the content

      // Access Zweitmitgliedschaften
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Zweitmitgliedschaften'));
      await tester.pumpAndSettle();
      expect(
        find.text('Zweitmitgliedschaften'),
        findsOneWidget,
      ); // Or a more specific finder

      // Test logout
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Abmelden'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Error handling during login', (tester) async {
      // Wrap with Provider
      await tester.pumpWidget(
        Provider<NetworkService>.value(
          value: networkService,
          child: const MyAppWrapper(),
        ),
      );
      await tester.pumpAndSettle();

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

      // Verify error message
      expect(
        find.text('Benutzername oder Passwort ist falsch'),
        findsOneWidget,
      );
    });

    testWidgets('Offline mode functionality', (tester) async {
      // Wrap with Provider
      await tester.pumpWidget(
        Provider<NetworkService>.value(
          value: networkService,
          child: const MyAppWrapper(),
        ),
      );
      await tester.pumpAndSettle();

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

      // Verify offline message
      expect(
        find.text(
          'Offline mode',
        ), // Adjust based on your actual offline message
        findsOneWidget,
      );
    });
  });
}

// Create a mock class for NetworkService
class MockNetworkService extends Mock implements NetworkService {}
