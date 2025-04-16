import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/app.dart';
import 'package:meinbssb/screens/login_screen.dart';
import 'package:meinbssb/screens/start_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:meinbssb/services/config_service.dart';
import 'package:meinbssb/services/http_client.dart';
import 'package:meinbssb/services/network_service.dart';
import 'package:meinbssb/services/image_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Flow Integration Tests', () {
    late SharedPreferences prefs;
    late ApiService apiService;
    late CacheService cacheService;
    late NetworkService networkService;
    late HttpClient httpClient;
    late ImageService imageService;

    setUpAll(() async {
      // Initialize services
      prefs = await SharedPreferences.getInstance();
      final configService = await ConfigService.load('assets/config.json');

      httpClient = HttpClient(
        baseUrl: 'http://localhost:3000',
        serverTimeout: 30,
      );

      cacheService = CacheService(prefs: prefs, configService: configService);

      networkService = NetworkService(configService: configService);

      imageService = ImageService();

      apiService = ApiService(
        httpClient: httpClient,
        cacheService: cacheService,
        networkService: networkService,
        imageService: imageService,
        baseIp: 'localhost',
        port: '3000',
        serverTimeout: 30,
      );
    });

    testWidgets('Complete user flow from login to accessing data', (
      tester,
    ) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ApiService>.value(value: apiService),
            Provider<CacheService>.value(value: cacheService),
            Provider<NetworkService>.value(value: networkService),
          ],
          child: const MyAppWrapper(),
        ),
      );

      // Verify we're on the login screen
      expect(find.byType(LoginScreen), findsOneWidget);

      // Enter login credentials
      await tester.enterText(
        find.byKey(const Key('emailField')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password123',
      );

      // Tap the login button
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      // Verify we're on the start screen after successful login
      expect(find.byType(StartScreen), findsOneWidget);

      // Verify user data is displayed
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('ABC123'), findsOneWidget);

      // Test accessing Schuetzenausweis
      await tester.tap(find.byKey(const Key('schuetzenausweisButton')));
      await tester.pumpAndSettle();

      // Verify Schuetzenausweis is displayed
      expect(find.byType(Image), findsOneWidget);

      // Test accessing Zweitmitgliedschaften
      await tester.tap(find.byKey(const Key('zweitmitgliedschaftenButton')));
      await tester.pumpAndSettle();

      // Verify Zweitmitgliedschaften screen is displayed
      expect(find.text('Zweitmitgliedschaften'), findsOneWidget);

      // Test logout
      await tester.tap(find.byKey(const Key('logoutButton')));
      await tester.pumpAndSettle();

      // Verify we're back on the login screen
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Error handling during login', (tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ApiService>.value(value: apiService),
            Provider<CacheService>.value(value: cacheService),
            Provider<NetworkService>.value(value: networkService),
          ],
          child: const MyAppWrapper(),
        ),
      );

      // Enter invalid credentials
      await tester.enterText(
        find.byKey(const Key('emailField')),
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
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('Offline mode functionality', (tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ApiService>.value(value: apiService),
            Provider<CacheService>.value(value: cacheService),
            Provider<NetworkService>.value(value: networkService),
          ],
          child: const MyAppWrapper(),
        ),
      );

      // Simulate offline mode
      when(networkService.hasInternet()).thenAnswer((_) async => false);

      // Enter credentials
      await tester.enterText(
        find.byKey(const Key('emailField')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password123',
      );

      // Tap the login button
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      // Verify offline mode message is displayed
      expect(find.text('Offline mode'), findsOneWidget);

      // Verify cached data is displayed
      expect(find.text('Cached Data'), findsOneWidget);
    });
  });
}
