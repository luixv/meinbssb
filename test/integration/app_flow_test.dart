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

// Generate mocks for services that will be overridden
class MockNetworkService extends Mock implements NetworkService {}

class MockApiService extends Mock implements ApiService {} // Mock ApiService

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Flow Integration Tests', () {
    // These late initializations will now get their values from AppInitializer
    late NetworkService networkService; // Declare networkService

    setUpAll(() async {
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

      await tester.tap(find.text('Hilfe (FAQ)'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('FAQ'), findsOneWidget);

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

    /*
    group('BankDataScreen', () {
      final Map<String, dynamic> testUserData = {
        'PERSONID': 123,
        'WEBLOGINID': 456,
        'VORNAME': 'Test',
        'NAMEN': 'User',
      };

      final Map<String, dynamic> existingBankData = {
        'KONTOINHABER': 'John Doe',
        'IBAN': 'DE12345678901234567890',
        'BIC': 'DABAIE2DXXX',
        'ONLINE': true,
      };

      testWidgets(
          '\n\n\nTEST_6. should load existing bank data and display in read-only mode\n\n\n',
          (tester) async {
        await tester
            .pumpWidget(buildAppWithMockApiService(tester, mockApiService));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Simulate login
        await tester.enterText(
          find.byKey(const Key('usernameField')),
          'kostas@rizoudis1.de',
        );
        await tester.enterText(find.byKey(const Key('passwordField')), 'a');
        await tester.tap(find.byKey(const Key('loginButton')));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Mock fetchBankdaten to return existing data
        when(mockApiService.fetchBankdaten(testUserData['WEBLOGINID']))
            .thenAnswer((_) async => existingBankData);

        // Navigate to BankDataScreen
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await tester.tap(find.text('Zahlungsart'));
        await tester.pumpAndSettle(
          const Duration(seconds: 1),
        ); // Wait for data to load and setState

        expect(find.byType(BankDataScreen), findsOneWidget);
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('DE12345678901234567890'), findsOneWidget);
        expect(find.text('DABAIE2DXXX'), findsOneWidget);

        // Verify that fields are read-only
        // Use `find.widgetWithText` and then `tester.widget` to access the TextFormField
        expect(
          tester.widget<TextFormField>(
            find.widgetWithText(TextFormField, 'Kontoinhaber'),
          ),
          isTrue,
        );
        expect(
          tester.widget<TextFormField>(
            find.widgetWithText(TextFormField, 'IBAN'),
          ),
          isTrue,
        );
        expect(
          tester.widget<TextFormField>(
            find.widgetWithText(TextFormField, 'BIC'),
          ),
          isTrue,
        );

        // Verify edit FAB is visible and delete FAB is visible (since data exists and not in edit mode)
        expect(find.byIcon(Icons.edit), findsOneWidget);
        expect(find.byIcon(Icons.delete_forever), findsOneWidget);
      });

      testWidgets(
          '\n\n\nTEST_7. should switch to edit mode and hide delete FAB on edit button tap\n\n\n',
          (tester) async {
        await tester
            .pumpWidget(buildAppWithMockApiService(tester, mockApiService));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Simulate login
        await tester.enterText(
          find.byKey(const Key('usernameField')),
          'kostas@rizoudis1.de',
        );
        await tester.enterText(find.byKey(const Key('passwordField')), 'a');
        await tester.tap(find.byKey(const Key('loginButton')));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Mock fetchBankdaten to return existing data
        when(mockApiService.fetchBankdaten(testUserData['WEBLOGINID']))
            .thenAnswer((_) async => existingBankData);

        // Navigate to BankDataScreen
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await tester.tap(find.text('Zahlungsart'));
        await tester
            .pumpAndSettle(const Duration(seconds: 1)); // Wait for data to load

        // Tap the edit FAB
        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Verify fields are now editable
        expect(
          tester.widget<TextFormField>(
            find.widgetWithText(TextFormField, 'Kontoinhaber'),
          ),
          isFalse,
        );
        expect(
          tester.widget<TextFormField>(
            find.widgetWithText(TextFormField, 'IBAN'),
          ),
          isFalse,
        );
        expect(
          tester.widget<TextFormField>(
            find.widgetWithText(TextFormField, 'BIC'),
          ),
          isFalse,
        );

        // Verify FAB changes to save icon
        expect(find.byIcon(Icons.save), findsOneWidget);
        expect(find.byIcon(Icons.edit), findsNothing);

        // Verify delete FAB is hidden in edit mode
        expect(find.byIcon(Icons.delete_forever), findsNothing);
      });

      testWidgets(
          '\n\n\nTEST_8. should show empty form and edit mode if no bank data is found on load\n\n\n',
          (tester) async {
        await tester
            .pumpWidget(buildAppWithMockApiService(tester, mockApiService));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Simulate login
        await tester.enterText(
          find.byKey(const Key('usernameField')),
          'kostas@rizoudis1.de',
        );
        await tester.enterText(find.byKey(const Key('passwordField')), 'a');
        await tester.tap(find.byKey(const Key('loginButton')));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Mock fetchBankdaten to return empty data (simulating no bank data existing)
        when(mockApiService.fetchBankdaten(testUserData['WEBLOGINID']))
            .thenAnswer(
          (_) async => {
            'ONLINE': true,
          },
        ); // Simulate successful online API call with no data

        // Navigate to BankDataScreen
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle(
          const Duration(seconds: 1),
        ); // Wait for data to load and setState

        expect(find.byType(BankDataScreen), findsOneWidget);
        expect(
          find.widgetWithText(TextFormField, 'Kontoinhaber'),
          findsOneWidget,
        );
        expect(
          tester
              .widget<TextFormField>(
                find.widgetWithText(TextFormField, 'Kontoinhaber'),
              )
              .controller!
              .text,
          isEmpty,
        );

        // Verify that fields are editable (because no data was found)
        expect(
          tester.widget<TextFormField>(
            find.widgetWithText(TextFormField, 'Kontoinhaber'),
          ),
          isFalse,
        );
        expect(
          tester.widget<TextFormField>(
            find.widgetWithText(TextFormField, 'IBAN'),
          ),
          isFalse,
        );
        expect(
          tester.widget<TextFormField>(
            find.widgetWithText(TextFormField, 'BIC'),
          ),
          isFalse,
        );

        // Verify FAB is save icon and delete FAB is hidden
        expect(find.byIcon(Icons.save), findsOneWidget);
        expect(find.byIcon(Icons.edit), findsNothing);
        expect(find.byIcon(Icons.delete_forever), findsNothing);
      });

      testWidgets(
          '\n\n\nTEST_9. should handle bank data deletion correctly (show empty form on return)\n\n\n',
          (tester) async {
        await tester
            .pumpWidget(buildAppWithMockApiService(tester, mockApiService));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Simulate login
        await tester.enterText(
          find.byKey(const Key('usernameField')),
          'kostas@rizoudis1.de',
        );
        await tester.enterText(find.byKey(const Key('passwordField')), 'a');
        await tester.tap(find.byKey(const Key('loginButton')));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 1. Load with existing data
        when(mockApiService.fetchBankdaten(testUserData['WEBLOGINID']))
            .thenAnswer((_) async => existingBankData);
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await tester.tap(find.text('Zahlungsart'));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(find.text('John Doe'), findsOneWidget); // Verify data is loaded

        // 2. Tap delete FAB
        expect(
          find.byIcon(Icons.delete_forever),
          findsOneWidget,
        ); // Ensure delete FAB is visible
        await tester.tap(find.byIcon(Icons.delete_forever));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 3. Verify confirmation dialog
        expect(find.text('Bankdaten löschen'), findsOneWidget);
        expect(
          find.textContaining('Sind Sie sicher, dass Sie Ihre Bankdaten'),
          findsOneWidget,
        );

        // 4. Mock deleteBankdaten success
        when(mockApiService.deleteBankdaten(testUserData['WEBLOGINID']))
            .thenAnswer((_) async => true);

        // 5. Tap 'Löschen' button in dialog
        await tester.tap(find.text('Löschen'));
        await tester.pumpAndSettle(
          const Duration(seconds: 1),
        ); // Wait for deletion and navigation

        // 6. Verify BankDataResultScreen (success)
        expect(find.byType(BankDataResultScreen), findsOneWidget);
        expect(find.text('Operation erfolgreich!'), findsOneWidget);

        // 7. Navigate back to StartScreen
        await tester.tap(
          find.byIcon(Icons.home),
        ); // Assuming back button or home button
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(find.byType(StartScreen), findsOneWidget);

        // 8. Navigate back to BankDataScreen
        // IMPORTANT: Re-mock fetchBankdaten to return empty data this time
        when(mockApiService.fetchBankdaten(testUserData['WEBLOGINID']))
            .thenAnswer(
          (_) async => {'ONLINE': true},
        ); // Simulating no data found but online
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await tester.tap(find.text('Zahlungsart'));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 9. Verify empty form is displayed and in edit mode
        expect(find.byType(BankDataScreen), findsOneWidget);
        expect(
          find.text('Kontoinhaber'),
          findsOneWidget,
        ); // Label should be present
        expect(
          tester
              .widget<TextFormField>(
                find.widgetWithText(TextFormField, 'Kontoinhaber'),
              )
              .controller!
              .text,
          isEmpty,
        );
        expect(
          tester.widget<TextFormField>(
            find.widgetWithText(TextFormField, 'Kontoinhaber'),
          ),
          isFalse,
        ); // Should be editable
        expect(
          find.byIcon(Icons.save),
          findsOneWidget,
        ); // FAB should be save icon
        expect(
          find.byIcon(Icons.delete_forever),
          findsNothing,
        ); // Delete FAB should be hidden
      });

      testWidgets(
          '\n\n\nTEST_10. should display offline message if initial fetch fails due to network\n\n\n',
          (tester) async {
        await tester
            .pumpWidget(buildAppWithMockApiService(tester, mockApiService));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Simulate login
        await tester.enterText(
          find.byKey(const Key('usernameField')),
          'kostas@rizoudis1.de',
        );
        await tester.enterText(find.byKey(const Key('passwordField')), 'a');
        await tester.tap(find.byKey(const Key('loginButton')));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Mock fetchBankdaten to throw a NetworkException
        when(mockApiService.fetchBankdaten(testUserData['WEBLOGINID']))
            .thenThrow(NetworkException());

        // Navigate to BankDataScreen
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await tester.tap(find.text('Zahlungsart'));
        await tester.pumpAndSettle(
          const Duration(
            seconds: 1,
          ),
        ); // Wait for error to propagate and setState

        expect(find.byType(BankDataScreen), findsOneWidget);
        expect(find.text('Internet ist nicht zu Verfügung.'), findsOneWidget);
        expect(find.byIcon(Icons.cloud_off), findsOneWidget);

        // Verify FABs are hidden when offline
        expect(find.byIcon(Icons.edit), findsNothing);
        expect(find.byIcon(Icons.save), findsNothing);
        expect(find.byIcon(Icons.delete_forever), findsNothing);
      });
    });
    */
  });
}
