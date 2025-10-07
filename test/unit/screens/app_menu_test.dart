import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:meinbssb/screens/app_menu.dart';
import 'package:meinbssb/screens/registration_screen.dart';
import 'package:meinbssb/screens/password_reset_screen.dart';

import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import 'package:meinbssb/models/user_data.dart';

// Clean helper user
UserData buildTestUser() => const UserData(
  personId: 1,
  webLoginId: 111,
  passnummer: 'P123',
  vereinNr: 99,
  namen: 'Mustermann',
  vorname: 'Max',
  vereinName: 'Testverein',
  passdatenId: 11,
  mitgliedschaftId: 22,
  telefon: '',
);

void _noop() {}

Finder findScaledText(String text) =>
    find.byWidgetPredicate((w) => w is ScaledText && w.text == text);

// Replace the current _FakeApiService and (optionally) remove the explicit Provider<ConfigService>
// if you like. This implementation guarantees a non-null ConfigService for LogoWidget etc.

class _FakeConfigService implements ConfigService {
  @override
  String? getString(String key, [String? section]) {
    if (key.toLowerCase().contains('logo')) {
      return 'assets/images/myBSSB-logo.png';
    }
    return null;
  }

  @override
  noSuchMethod(Invocation invocation) => null;
}

class _FakeApiService implements ApiService {
  _FakeApiService() : _config = _FakeConfigService();
  final ConfigService _config;
  @override
  ConfigService get configService => _config;
  @override
  noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('AppMenu', () {
    testWidgets('shows menu icon and opens endDrawer', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ApiService>.value(value: _FakeApiService()),
            ChangeNotifierProvider(create: (_) => FontSizeProvider()),
          ],
          child: MaterialApp(
            home: Scaffold(
              endDrawer: const Drawer(child: Text('Drawer')),
              body: Builder(
                builder:
                    (context) => AppMenu(
                      context: context,
                      userData: null,
                      isLoggedIn: false,
                      onLogout: () {},
                    ),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.menu), findsOneWidget);
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(find.text('Drawer'), findsOneWidget);
    });
  });

  group('AppDrawer (logged out)', () {
    testWidgets('shows logged-out menu items', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => FontSizeProvider()),
            Provider<ApiService>.value(value: _FakeApiService()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              drawer: AppDrawer(
                userData: null,
                isLoggedIn: false,
                onLogout: _noop,
              ),
            ),
          ),
        ),
      );

      final scaffoldState = tester.firstState<ScaffoldState>(
        find.byType(Scaffold),
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(findScaledText('Anmelden'), findsOneWidget);
      expect(findScaledText('Registrieren'), findsOneWidget);
      expect(findScaledText('Passwort zurücksetzen'), findsOneWidget);
      expect(findScaledText('Abmelden'), findsNothing);
      expect(findScaledText('Home'), findsNothing);
    });

    testWidgets('tapping Anmelden navigates to /login', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => FontSizeProvider()),
            Provider<ApiService>.value(value: _FakeApiService()),
          ],
          child: MaterialApp(
            routes: {
              '/login':
                  (_) =>
                      const Scaffold(body: Center(child: Text('LOGIN_ROUTE'))),
            },
            home: const Scaffold(
              drawer: AppDrawer(
                userData: null,
                isLoggedIn: false,
                onLogout: _noop,
              ),
            ),
          ),
        ),
      );

      final scaffoldState = tester.firstState<ScaffoldState>(
        find.byType(Scaffold),
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Anmelden'));
      await tester.pumpAndSettle();

      expect(find.text('LOGIN_ROUTE'), findsOneWidget);
    });

    testWidgets('tapping Registrieren pushes RegistrationScreen', (
      tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => FontSizeProvider()),
            Provider<ApiService>.value(value: _FakeApiService()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              drawer: AppDrawer(
                userData: null,
                isLoggedIn: false,
                onLogout: _noop,
              ),
            ),
          ),
        ),
      );

      final scaffoldState = tester.firstState<ScaffoldState>(
        find.byType(Scaffold),
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Registrieren'));
      await tester.pumpAndSettle();

      expect(find.byType(RegistrationScreen), findsOneWidget);
    });

    testWidgets('tapping Passwort zurücksetzen pushes PasswordResetScreen', (
      tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => FontSizeProvider()),
            Provider<ApiService>.value(value: _FakeApiService()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              drawer: AppDrawer(
                userData: null,
                isLoggedIn: false,
                onLogout: _noop,
              ),
            ),
          ),
        ),
      );

      final scaffoldState = tester.firstState<ScaffoldState>(
        find.byType(Scaffold),
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Passwort zurücksetzen'));
      await tester.pumpAndSettle();

      expect(find.byType(PasswordResetScreen), findsOneWidget);
    });
  });

  group('AppDrawer (logged in)', () {
    testWidgets('shows logged-in items, hides auth items', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => FontSizeProvider()),
            Provider<ApiService>.value(value: _FakeApiService()),
          ],
          child: MaterialApp(
            routes: {
              '/home': (_) => const Scaffold(body: Text('HOME')),
              '/profile': (_) => const Scaffold(body: Text('PROFILE')),
            },
            home: Scaffold(
              drawer: AppDrawer(
                userData: buildTestUser(),
                isLoggedIn: true,
                onLogout: () {},
              ),
            ),
          ),
        ),
      );

      final scaffoldState = tester.firstState<ScaffoldState>(
        find.byType(Scaffold),
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      Future<void> ensureVisible(String label) async {
        final finder = find.text(label);
        if (finder.evaluate().isEmpty) {
          await tester.scrollUntilVisible(
            finder,
            150,
            scrollable: find.descendant(
              of: find.byType(Drawer),
              matching: find.byType(Scrollable),
            ),
          );
          await tester.pumpAndSettle();
        }
        expect(finder, findsOneWidget, reason: 'Missing $label');
      }

      // Adjust this list if actual labels differ (e.g. 'Hilfe' -> 'Hilfe / FAQ')
      final expectedLoggedIn = [
        'Home',
        'Profil',
        'Aus- und Weiterbildung',
        'Schützenausweis',
        'Startrechte',
        'Oktoberfest',
        'Impressum',
        'Einstellungen',
        'Hilfe',
        'Abmelden',
      ];

      for (final label in expectedLoggedIn) {
        await ensureVisible(label);
      }

      for (final auth in [
        'Anmelden',
        'Registrieren',
        'Passwort zurücksetzen',
      ]) {
        expect(find.text(auth), findsNothing);
      }
    });

    testWidgets('tapping Abmelden calls callback once', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => FontSizeProvider()),
            Provider<ApiService>.value(value: _FakeApiService()),
          ],
          child: MaterialApp(
            home: Scaffold(
              drawer: AppDrawer(
                userData: buildTestUser(),
                isLoggedIn: true,
                onLogout: () => calls++,
              ),
            ),
          ),
        ),
      );

      final scaffoldState = tester.firstState<ScaffoldState>(
        find.byType(Scaffold),
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Ensure the Abmelden entry is actually built (may be off-screen in a scrollable ListView)
      final abmeldenFinder = find.text('Abmelden');
      if (abmeldenFinder.evaluate().isEmpty) {
        // Scroll until visible (adjust scrollable finder if your Drawer uses a different widget)
        await tester.scrollUntilVisible(
          abmeldenFinder,
          200,
          scrollable: find.descendant(
            of: find.byType(Drawer),
            matching: find.byType(Scrollable),
          ),
        );
        await tester.pumpAndSettle();
      }

      expect(
        abmeldenFinder,
        findsOneWidget,
        reason: 'Abmelden not found in drawer',
      );

      await tester.tap(abmeldenFinder);
      await tester.pumpAndSettle();

      expect(calls, 1);
    });
  });
}
