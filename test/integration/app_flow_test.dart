import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/app.dart';
import 'package:meinbssb/screens/login_screen.dart';
import 'package:meinbssb/screens/start_screen.dart';
import 'package:meinbssb/services/network_service.dart';
import 'package:meinbssb/main.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/config_service.dart';
import 'package:meinbssb/services/http_client.dart';
import 'package:meinbssb/services/cache_service.dart';

// Generate the mock
class MockNetworkService extends Mock implements NetworkService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Flow Integration Tests', () {
    debugPrint('Test 1 started!\n\n');
    late ConfigService configService;
    setUpAll(() async {
      // Initialize the app's service providers
      await AppInitializer.init();
      // Load ConfigService
      configService = await ConfigService.load(
        'config/app_config.json',
      ); // Load config
    });

    setUp(() {});

    testWidgets('Access the Passwort vergessen?', (tester) async {
      debugPrint('Test 2 started!\n\n');

      // Build our app and trigger a frame
      await tester.pumpWidget(
        Provider<NetworkService>(
          create: (context) => NetworkService(configService: configService),
          child: const MyAppWrapper(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify we're on the login screen
      expect(find.byType(LoginScreen), findsOneWidget);

      // Tap the "Passwort vergessen?" link.  Find the RichText by text.
      await tester.tap(find.text('Passwort vergessen?'));
      await tester.pumpAndSettle();

      // Verify that the new page is present by checking for the key
      expect(find.byKey(const Key('passwordResetTitle')), findsOneWidget);
      // Back to login
      await tester.tap(
        find.byType(PopupMenuButton<String>),
      ); // Open the PopupMenuButton
      await tester.pumpAndSettle();
      await tester.tap(
        find.text('Zurück zum Login'),
      ); // Corrected text to match the menu
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Access the help page', (tester) async {
      debugPrint('Test 3 started!\n\n');
      // Build our app and trigger a frame
      await tester.pumpWidget(
        Provider<NetworkService>(
          create: (context) => NetworkService(configService: configService),
          child: const MyAppWrapper(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify we're on the login screen
      expect(find.byType(LoginScreen), findsOneWidget);

      // Tap the "Hilfe" link.  Find the RichText by text.
      await tester.tap(find.text('Hilfe'));
      await tester.pumpAndSettle();

      // Verify that the new page contains the text "FAQ"
      expect(find.text('FAQ'), findsOneWidget);

      // Back to login
      await tester.tap(
        find.byType(PopupMenuButton<String>),
      ); // Open the PopupMenuButton
      await tester.pumpAndSettle();
      await tester.tap(
        find.text('Zurück zum Login'),
      ); // Corrected text to match the menu
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Access the Registration page', (tester) async {
      debugPrint('Test 4 started!\n\n');

      // Build our app and trigger a frame
      await tester.pumpWidget(
        Provider<NetworkService>(
          create: (context) => NetworkService(configService: configService),
          child: const MyAppWrapper(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify we're on the login screen
      expect(find.byType(LoginScreen), findsOneWidget);

      // Tap the "Hilfe" link.  Find the RichText by text.
      await tester.tap(find.text('Registrieren'));
      await tester.pumpAndSettle();

      // Verify that the new page contains the text "FAQ"
      expect(find.text('Hier Registrieren'), findsOneWidget);

      // Back to login
      await tester.tap(
        find.byType(PopupMenuButton<String>),
      ); // Open the PopupMenuButton
      await tester.pumpAndSettle();
      await tester.tap(
        find.text('Zurück zum Login'),
      ); // Corrected text to match the menu
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Complete user flow from login to accessing data', (
      tester,
    ) async {
      // Build our app and trigger a frame
      debugPrint('Test 5 started!\n\n');

      await tester.pumpWidget(
        Provider<NetworkService>(
          create: (context) => NetworkService(configService: configService),
          child: const MyAppWrapper(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify we're on the login screen
      expect(find.byType(LoginScreen), findsOneWidget);

      // Enter login credentials
      await tester.enterText(
        find.byKey(const Key('usernameField')),
        'kostas@rizoudis1.de',
      );
      await tester.enterText(find.byKey(const Key('passwordField')), 'a');

      // Tap the login button
      await tester.tap(find.byKey(const Key('loginButton')));
      debugPrint('Login button found!\n\n');

      await tester.pumpAndSettle();

      // Verify we're on the start screen after successful login
      expect(find.byType(StartScreen), findsOneWidget);
      debugPrint('Login done!\n\n');

      // Verify user data is displayed
      expect(find.text('Lukas Schürz'), findsOneWidget);
      expect(find.text('40100709'), findsOneWidget);
      debugPrint('User found!\n\n');

      // Test accessing Schuetzenausweis
      // Access Schuetzenausweis
      await tester.tap(find.byIcon(Icons.menu)); // Open the PopupMenuButton
      await tester.pumpAndSettle();
      debugPrint('Menu icon found!\n\n');

      await tester.tap(
        find.text('Digitaler Schützenausweis'),
      ); // Tap the menu item
      await tester.pumpAndSettle();
      find.byKey(const Key('schuetzenausweis'));

      debugPrint('Image found!\n\n');
/*
      // Access Zweitmitgliedschaften
      await tester.tap(find.byIcon(Icons.menu)); // Open the PopupMenuButton
      await tester.pumpAndSettle();
      await tester.tap(find.text('Zweitmitgliedschaften')); // Tap the menu item
      await tester.pumpAndSettle();
      expect(find.text('Zweitmitgliedschaften'), findsOneWidget);
*/
      // Access Impressum
      await tester.tap(find.byIcon(Icons.menu)); // Open the PopupMenuButton
      await tester.pumpAndSettle();
      await tester.tap(find.text('Impressum')); // Tap the menu item
      debugPrint('Impressum menu  found!\n\n');
      await tester.pumpAndSettle();
      expect(
        find.text('Impressum').first,
        findsOneWidget,
      );
      debugPrint('Impressum found!\n\n');

      // Access Kontaktdaten
      await tester.tap(find.byIcon(Icons.menu)); // Open the PopupMenuButton
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kontaktdaten')); // Tap the menu item
      debugPrint('Kontaktdaten menu found!\n\n');
      await tester.pumpAndSettle();
      expect(
        find.text('Kontaktdaten').first,
        findsOneWidget,
      );
      debugPrint('Kontaktdaten found!\n\n');

      // Access Stammdaten
      await tester.tap(find.byIcon(Icons.menu)); // Open the PopupMenuButton
      await tester.pumpAndSettle();
      await tester.tap(find.text('Persönliche Daten')); // Tap the menu item
      debugPrint('Persönliche Daten menu found!\n\n');
      await tester.pumpAndSettle();
      expect(
        find.text('Persönliche Daten').first,
        findsOneWidget,
      );
      debugPrint('Persönliche Daten found!\n\n');

      // Access Zahlungsart
      await tester.tap(find.byIcon(Icons.menu)); // Open the PopupMenuButton
      await tester.pumpAndSettle();
      await tester.tap(find.text('Zahlungsart')); // Tap the menu item
      debugPrint('Zahlungsart!\n\n');
      await tester.pumpAndSettle();
      expect(
        find.text('Bankdaten').first,
        findsOneWidget,
      );
      debugPrint('Zahlungsart!\n\n');

      // Test logout
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Abmelden'));
      await tester.pumpAndSettle();
      debugPrint('Abmelden found!\n\n');
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Error handling during login', (tester) async {
      debugPrint('Test 6 started!\n\n');

      // Build our app and trigger a frame
      await tester.pumpWidget(
        Provider<NetworkService>(
          create: (context) => NetworkService(configService: configService),
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

      // Verify either the online or offline error message is displayed
      final onlineErrorFinder =
          //find.text('Benutzername oder Passwort ist falsch');
          find.text('MyBSSB Login nicht vorhanden');
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

// Consider implementing environment-specific configuration
class AppConfig {
  static const String apiUrl = String.fromEnvironment('API_URL');
  static const bool isDebug = bool.fromEnvironment('DEBUG');
}

// Consider implementing a custom exception class
class AppException implements Exception {
  AppException(this.message, {this.code});
  final String message;
  final int? code;
}

// Consider implementing a base service class
abstract class BaseService {
  BaseService(this.httpClient, this.cacheService);
  final HttpClient httpClient;
  final CacheService cacheService;

  // Common methods can be implemented here
}

// Consider adding test utilities
class TestHelper {
  static Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    // Implementation
  }
}
