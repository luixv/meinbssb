import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/app.dart';
import 'package:meinbssb/screens/login_screen.dart';
import 'package:meinbssb/screens/start_screen.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/main.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/api_service.dart' hide NetworkException;
import 'package:shared_preferences/shared_preferences.dart';

// Generate mocks for services that will be overridden
class MockNetworkService extends Mock implements NetworkService {}

class MockApiService extends Mock implements ApiService {} // Mock ApiService

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Flow Integration Tests', () {
    // These late initializations will now get their values from AppInitializer
    late NetworkService networkService; // Declare networkService

    setUpAll(() async {
      // Initialize mock for SharedPreferences to avoid MissingPluginException
      SharedPreferences.setMockInitialValues({});

      // Initialize the app's service providers.
      // This will set the static variables in AppInitializer.
      await AppInitializer.init();
      // Assign the initialized services from AppInitializer's static getters
      networkService = AppInitializer.networkService;
    });

    setUp(() {});

    testWidgets('\n\n\nTEST_1. Access the Passwort vergessen?\n\n\n', (
      tester,
    ) async {
      await tester.pumpWidget(
        Provider<NetworkService>(
          create: (context) => networkService,
          child:
              const MyAppWrapper(), // MyAppWrapper provides the actual ApiService
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.tap(find.text('Passwort vergessen?'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.byKey(const Key('passwordResetTitle')), findsOneWidget);

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(find.text('Zurück zum Login'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('\n\n\nTEST_2. Access the help page\n\n\n', (tester) async {
      await tester.pumpWidget(
        Provider<NetworkService>(
          create: (context) => networkService, // Use the real networkService
          child: const MyAppWrapper(),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.tap(find.text('Hilfe'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('Hilfe'), findsOneWidget);

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(find.text('Zurück zum Login'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('\n\n\nTEST_3. Access the Registration page\n\n\n', (
      tester,
    ) async {
      await tester.pumpWidget(
        Provider<NetworkService>(
          create: (context) => networkService, // Use the real networkService
          child: const MyAppWrapper(),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.tap(find.text('Registrieren'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('Hier Registrieren'), findsOneWidget);

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(find.text('Zurück zum Login'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets(
      '\n\n\nTEST_4. Complete user flow from login to accessing data\n\n\n',
      (tester) async {
        await tester.pumpWidget(
          Provider<NetworkService>(
            create: (context) => networkService, // Use the real networkService
            child: const MyAppWrapper(), // Use the real services for basic flow
          ),
        );
        await tester.pumpAndSettle(const Duration(seconds: 1)); // Initial pump

        // Login
        await tester.enterText(
          find.byKey(const Key('usernameField')),
          'kostas@rizoudis1.de',
        );
        await tester.enterText(find.byKey(const Key('passwordField')), 'a');
        await tester.tap(find.byKey(const Key('loginButton')));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(find.byType(StartScreen), findsOneWidget);

        // Verify user data is displayed
        expect(find.text('Kostas Rizoudis'), findsOneWidget);
        expect(find.text('40100709'), findsOneWidget);

        // Access Absolvierte Schulungen
        debugPrint('Test 4 Access Absolvierte Schulungen!\n\n\n');
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await tester.tap(find.text('Absolvierte Schulungen'));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(find.text('Absolvierte Schulungen').first, findsOneWidget);

        // Access Schützenausweis
        debugPrint('Test 4 Access Schützenausweis!\n\n\n');
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await tester.tap(find.text('Schützenausweis'));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(find.text('Schützenausweis').first, findsOneWidget);

        // Access Persönliche Daten (Stammdaten)
        debugPrint('Test 4 Access Persönliche Daten!\n\n\n');
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await tester.tap(find.text('Persönliche Daten'));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(find.text('Persönliche Daten').first, findsOneWidget);

        // Access Kontaktdaten
        debugPrint('Test 4 Access Kontaktdaten!\n\n\n');
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await tester.tap(find.text('Kontaktdaten'));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(find.text('Kontaktdaten').first, findsOneWidget);

        // Access Zahlungsart (Bankdaten)
        debugPrint('Test 4 Access Zahlungsart (Bankdaten)!\n\n\n');
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await tester.tap(find.text('Zahlungsart'));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(find.text('Zahlungsart').first, findsOneWidget);

        // Access Impressum
        debugPrint('Test 4 Access Zahlungsart (Bankdaten)!\n\n\n');
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await tester.tap(find.text('Impressum'));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(find.text('Impressum').first, findsOneWidget);

        // Test logout
        debugPrint('Test 4 Access Abmelden!\n\n\n');
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await tester.tap(find.text('Abmelden'));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(find.byType(LoginScreen), findsOneWidget);
      },
    );

    testWidgets('\n\n\nTEST_5. Error handling during login\n\n\n', (
      tester,
    ) async {
      await tester.pumpWidget(
        Provider<NetworkService>(
          create: (context) => networkService, // Use the real networkService
          child: const MyAppWrapper(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.enterText(
        find.byKey(const Key('usernameField')),
        'invalid@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'wrongpassword',
      );
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final onlineErrorFinder = find.text('MyBSSB Login nicht vorhanden');
      final offlineErrorFinder = find.text(
        'Offline-Anmeldung fehlgeschlagen: Kein Cache oder falsches Passwort.',
      );

      expect(
        tester.widgetList(onlineErrorFinder).isNotEmpty ||
            tester.widgetList(offlineErrorFinder).isNotEmpty,
        isTrue,
      );
    });
  });
}
