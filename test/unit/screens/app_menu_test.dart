import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart' as intl;

import 'package:meinbssb/screens/menu/app_menu.dart';
import 'package:meinbssb/screens/registration_screen.dart';
import 'package:meinbssb/screens/password/password_reset_screen.dart';

import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import 'package:meinbssb/models/user_data.dart';

// ---------- Helpers / Fakes ----------

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

void noop() {}

Finder scaledText(String text) =>
    find.byWidgetPredicate((w) => w is ScaledText && w.text == text);

class FakeConfigService implements ConfigService {
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

class FakeApiService implements ApiService {
  FakeApiService() : _config = FakeConfigService();
  final ConfigService _config;
  @override
  ConfigService get configService => _config;
  @override
  noSuchMethod(Invocation invocation) => null;
}

class TestNavObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushed = [];
  final List<Route<dynamic>> replaced = [];
  @override
  void didPush(Route route, Route<dynamic>? previousRoute) {
    pushed.add(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) replaced.add(newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

Future<void> openDrawer(WidgetTester tester) async {
  final scaffold = tester.firstState<ScaffoldState>(find.byType(Scaffold));
  scaffold.openDrawer();
  await tester.pumpAndSettle();
}

Future<void> ensureVisible(WidgetTester tester, String label) async {
  final finder = find.text(label);
  // Always attempt to bring into view (previous version only checked presence).
  if (finder.evaluate().isEmpty) {
    // Scroll until it appears if not in the tree yet (unlikely, but keep fallback).
    final scrollable = find.descendant(
      of: find.byType(Drawer),
      matching: find.byType(Scrollable),
    );
    if (scrollable.evaluate().isNotEmpty) {
      await tester.scrollUntilVisible(finder, 120, scrollable: scrollable);
    }
  } else {
    // Use built-in ensureVisible to handle partially off-screen widgets.
    try {
      await tester.ensureVisible(finder);
    } catch (_) {
      // Fallback manual scroll if ensureVisible fails (e.g. multiple scrollables).
      final scrollable = find.descendant(
        of: find.byType(Drawer),
        matching: find.byType(Scrollable),
      );
      if (scrollable.evaluate().isNotEmpty) {
        await tester.scrollUntilVisible(finder, 150, scrollable: scrollable);
      }
    }
  }
  await tester.pumpAndSettle();
  expect(finder, findsOneWidget);
}

Widget baseLoggedOut() => MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => FontSizeProvider()),
    Provider<ApiService>.value(value: FakeApiService()),
  ],
  child: MaterialApp(
    home: Scaffold(
      drawer: AppDrawer(userData: null, isLoggedIn: false, onLogout: noop),
    ),
    routes: {
      '/login': (_) => const Scaffold(body: Center(child: Text('LOGIN_ROUTE'))),
    },
  ),
);

Widget baseLoggedIn({UserData? user, TestNavObserver? observer}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FontSizeProvider()),
        Provider<ApiService>.value(value: FakeApiService()),
      ],
      child: MaterialApp(
        navigatorObservers: observer == null ? [] : [observer],
        routes: {
          '/home': (_) => const Scaffold(body: Text('HOME_ROUTE_BODY')),
          '/profile': (_) => const Scaffold(body: Text('PROFILE_ROUTE_BODY')),
        },
        home: Scaffold(
          drawer: AppDrawer(
            userData: user ?? buildTestUser(),
            isLoggedIn: true,
            onLogout: () {},
          ),
          body: const Text('ROOT_BODY'),
        ),
      ),
    );

// Fake navigator for delegate tests
class FakeDrawerNavigator implements DrawerNavigator {
  bool homeCalled = false;
  bool profileCalled = false;
  bool trainingCalled = false;
  bool schutzAusweisCalled = false;
  bool oktoberfestCalled = false;
  bool impressumCalled = false;
  bool settingsCalled = false;
  bool helpCalled = false;
  bool logoutCalled = false;

  void _close(BuildContext c) {
    if (Navigator.of(c).canPop()) Navigator.of(c).pop();
  }

  @override
  void home(BuildContext context) {
    homeCalled = true;
    _close(context);
  }

  @override
  void profile(BuildContext context) {
    profileCalled = true;
    _close(context);
  }

  @override
  void training(BuildContext context) {
    trainingCalled = true;
    _close(context);
  }

  @override
  void schuetzenausweis(BuildContext context) {
    schutzAusweisCalled = true;
    _close(context);
  }

  @override
  void oktoberfest(BuildContext context) {
    oktoberfestCalled = true;
    _close(context);
  }

  @override
  void impressum(BuildContext context) {
    impressumCalled = true;
    _close(context);
  }

  @override
  void settings(BuildContext context) {
    settingsCalled = true;
    _close(context);
  }

  @override
  void help(BuildContext context) {
    helpCalled = true;
    _close(context);
  }

  @override
  void logout(BuildContext context, VoidCallback onLogout) {
    logoutCalled = true;
    onLogout();
    _close(context);
  }
}

Widget loggedInWithNavigator(
  FakeDrawerNavigator nav, {
  VoidCallback? onLogout,
}) => MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => FontSizeProvider()),
    Provider<ApiService>.value(value: FakeApiService()),
  ],
  child: MaterialApp(
    routes: {
      '/home': (_) => const Scaffold(body: Text('HOME_ROUTE_BODY')),
      '/profile': (_) => const Scaffold(body: Text('PROFILE_ROUTE_BODY')),
    },
    home: Scaffold(
      drawer: AppDrawer(
        userData: buildTestUser(),
        isLoggedIn: true,
        onLogout: onLogout ?? noop,
        navigator: nav,
      ),
      body: const Text('ROOT'),
    ),
  ),
);

// ---------- Tests ----------

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await intl.initializeDateFormatting('de');
  });

  group('AppMenu icon', () {
    testWidgets('opens endDrawer', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ApiService>.value(value: FakeApiService()),
            ChangeNotifierProvider(create: (_) => FontSizeProvider()),
          ],
          child: MaterialApp(
            home: Scaffold(
              endDrawer: const Drawer(child: Text('DRAWER_CONTENT')),
              body: Builder(
                builder:
                    (ctx) => AppMenu(
                      context: ctx,
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
      expect(find.text('DRAWER_CONTENT'), findsOneWidget);
    });
  });

  group('Drawer logged out', () {
    testWidgets('shows expected items', (tester) async {
      await tester.pumpWidget(baseLoggedOut());
      await openDrawer(tester);
      expect(scaledText('Anmelden'), findsOneWidget);
      expect(scaledText('Registrieren'), findsOneWidget);
      expect(scaledText('Passwort zurücksetzen'), findsOneWidget);
      expect(scaledText('Abmelden'), findsNothing);
      expect(scaledText('Home'), findsNothing);
    });

    testWidgets('Anmelden navigates to /login', (tester) async {
      await tester.pumpWidget(baseLoggedOut());
      await openDrawer(tester);
      await tester.tap(find.text('Anmelden'));
      await tester.pumpAndSettle();
      expect(find.text('LOGIN_ROUTE'), findsOneWidget);
    });

    testWidgets('Registrieren pushes RegistrationScreen', (tester) async {
      await tester.pumpWidget(baseLoggedOut());
      await openDrawer(tester);
      await tester.tap(find.text('Registrieren'));
      await tester.pumpAndSettle();
      expect(find.byType(RegistrationScreen), findsOneWidget);
    });

    testWidgets('Passwort zurücksetzen pushes PasswordResetScreen', (
      tester,
    ) async {
      await tester.pumpWidget(baseLoggedOut());
      await openDrawer(tester);
      await tester.tap(find.text('Passwort zurücksetzen'));
      await tester.pumpAndSettle();
      expect(find.byType(PasswordResetScreen), findsOneWidget);
    });
  });

  group('Drawer logged in basic', () {
    testWidgets('shows all logged-in labels and hides auth labels', (
      tester,
    ) async {
      await tester.pumpWidget(baseLoggedIn());
      await openDrawer(tester);
      final labels = [
        'Home',
        'Profil',
        'Aus- und Weiterbildung',
        'Schützenausweis',
        'Oktoberfest',
        'Impressum',
        'Einstellungen',
        'Hilfe (FAQ)',
        'Abmelden',
      ];
      for (final l in labels) {
        await ensureVisible(tester, l);
        expect(find.text(l), findsOneWidget);
      }
      for (final auth in [
        'Anmelden',
        'Registrieren',
        'Passwort zurücksetzen',
      ]) {
        expect(find.text(auth), findsNothing);
      }
    });

    testWidgets('Abmelden triggers callback', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => FontSizeProvider()),
            Provider<ApiService>.value(value: FakeApiService()),
          ],
          child: MaterialApp(
            home: Scaffold(
              drawer: AppDrawer(
                userData: buildTestUser(),
                isLoggedIn: true,
                onLogout: () => calls++,
              ),
              body: const Text('ROOT'),
            ),
          ),
        ),
      );
      await openDrawer(tester);
      await ensureVisible(tester, 'Abmelden');
      await tester.tap(find.text('Abmelden'));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(find.byType(Drawer), findsNothing);
    });
  });

  group('Drawer logged in navigation', () {
    testWidgets('Home replaces body', (tester) async {
      final observer = TestNavObserver();
      await tester.pumpWidget(baseLoggedIn(observer: observer));
      await openDrawer(tester);
      await ensureVisible(tester, 'Home');
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('HOME_ROUTE_BODY'), findsOneWidget);
      expect(
        observer.pushed.isNotEmpty || observer.replaced.isNotEmpty,
        isTrue,
      );
    });

    testWidgets('Profil pushes profile route', (tester) async {
      final observer = TestNavObserver();
      await tester.pumpWidget(baseLoggedIn(observer: observer));
      await openDrawer(tester);
      await ensureVisible(tester, 'Profil');
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('PROFILE_ROUTE_BODY'), findsOneWidget);
      expect(observer.pushed.length, greaterThanOrEqualTo(1));
    });
  });

  group('Drawer logged in onTap delegates', () {
    Future<FakeDrawerNavigator> pumpAndOpen(WidgetTester tester) async {
      final nav = FakeDrawerNavigator();
      await tester.pumpWidget(loggedInWithNavigator(nav, onLogout: () {}));
      await openDrawer(tester);
      return nav;
    }

    testWidgets('Home triggers navigator.home', (tester) async {
      final nav = await pumpAndOpen(tester);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(nav.homeCalled, isTrue);
    });

    testWidgets('Profil triggers navigator.profile', (tester) async {
      final nav = await pumpAndOpen(tester);
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(nav.profileCalled, isTrue);
    });

    testWidgets('Aus- und Weiterbildung triggers navigator.training', (
      tester,
    ) async {
      final nav = await pumpAndOpen(tester);
      await ensureVisible(tester, 'Aus- und Weiterbildung');
      await tester.tap(find.text('Aus- und Weiterbildung'));
      await tester.pumpAndSettle();
      expect(nav.trainingCalled, isTrue);
    });

    testWidgets('Schützenausweis opens Ausweis menu screen', (tester) async {
      await tester.pumpWidget(baseLoggedIn());
      await openDrawer(tester);
      await ensureVisible(tester, 'Schützenausweis');
      await tester.tap(find.text('Schützenausweis'));
      await tester.pumpAndSettle();
      // Check for the Ausweis menu header text
      expect(find.text('Ausweis'), findsOneWidget);
    });

    testWidgets('Oktoberfest triggers navigator.oktoberfest', (tester) async {
      final nav = await pumpAndOpen(tester);
      await ensureVisible(tester, 'Oktoberfest');
      await tester.tap(find.text('Oktoberfest'));
      await tester.pumpAndSettle();
      expect(nav.oktoberfestCalled, isTrue);
    });

    testWidgets('Impressum triggers navigator.impressum', (tester) async {
      final nav = await pumpAndOpen(tester);
      await ensureVisible(tester, 'Impressum');
      await tester.tap(find.text('Impressum'));
      await tester.pumpAndSettle();
      expect(nav.impressumCalled, isTrue);
    });

    testWidgets('Hilfe triggers navigator.help', (tester) async {
      final nav = await pumpAndOpen(tester);
      await ensureVisible(tester, 'Hilfe (FAQ)');
      await tester.tap(find.text('Hilfe (FAQ)'));
      await tester.pumpAndSettle();
      expect(nav.helpCalled, isTrue);
    });

    testWidgets('Abmelden triggers navigator.logout and callback', (
      tester,
    ) async {
      var logoutCalls = 0;
      final nav = FakeDrawerNavigator();
      await tester.pumpWidget(
        loggedInWithNavigator(nav, onLogout: () => logoutCalls++),
      );
      await openDrawer(tester);
      await ensureVisible(tester, 'Abmelden');
      await tester.tap(find.text('Abmelden'));
      await tester.pumpAndSettle();
      expect(nav.logoutCalled, isTrue);
      expect(logoutCalls, 1);
    });

    testWidgets('Einstellungen triggers navigator.settings', (tester) async {
      final nav = await pumpAndOpen(tester);
      await ensureVisible(tester, 'Einstellungen');
      await tester.tap(find.text('Einstellungen'));
      await tester.pumpAndSettle();
      expect(nav.settingsCalled, isTrue);
      // Optional: ensure others not touched
      expect(nav.homeCalled, isFalse);
      expect(nav.profileCalled, isFalse);
      expect(nav.trainingCalled, isFalse);
    });
  });

  group('RealDrawerNavigator direct methods', () {
    // Lightweight placeholder builders to avoid heavy screen dependencies.
    WidgetBuilder placeholder(String key) =>
        (_) => Scaffold(body: Center(child: Text(key)));

    Future<void> pumpAndInvoke(
      WidgetTester tester,
      void Function(BuildContext, RealDrawerNavigator) call,
    ) async {
      final nav = RealDrawerNavigator(
        userData: buildTestUser(),
        isLoggedIn: true,
        onLogout: () {},
        schulungenBuilder: placeholder('SCHULUNGEN'),
        schuetzenausweisBuilder: placeholder('AUSWEIS'),
        startingRightsBuilder: placeholder('STARTRECHTE'),
        oktoberfestBuilder: placeholder('OKTOBERFEST'),
        impressumBuilder: placeholder('IMPRESSUM'),
        settingsBuilder: placeholder('SETTINGS'),
        helpBuilder: placeholder('HELP'),
      );

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/home':
                (_) => const Scaffold(body: Center(child: Text('HOME_PAGE'))),
            '/profile':
                (_) =>
                    const Scaffold(body: Center(child: Text('PROFILE_PAGE'))),
          },
          home: Builder(
            builder: (ctx) {
              // Defer call until after first frame.
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => call(ctx, nav),
              );
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('home() navigates to /home via replacement', (tester) async {
      await pumpAndInvoke(tester, (ctx, nav) => nav.home(ctx));
      expect(find.text('HOME_PAGE'), findsOneWidget);
    });

    testWidgets('profile() pushes /profile', (tester) async {
      await pumpAndInvoke(tester, (ctx, nav) => nav.profile(ctx));
      expect(find.text('PROFILE_PAGE'), findsOneWidget);
    });

    testWidgets('training() pushes Schulungen placeholder', (tester) async {
      await pumpAndInvoke(tester, (ctx, nav) => nav.training(ctx));
      expect(find.text('SCHULUNGEN'), findsOneWidget);
    });

    testWidgets('schuetzenausweis() pushes Ausweis placeholder', (
      tester,
    ) async {
      await pumpAndInvoke(tester, (ctx, nav) => nav.schuetzenausweis(ctx));
      expect(find.text('AUSWEIS'), findsOneWidget);
    });

    testWidgets('oktoberfest() pushes Oktoberfest placeholder', (tester) async {
      await pumpAndInvoke(tester, (ctx, nav) => nav.oktoberfest(ctx));
      expect(find.text('OKTOBERFEST'), findsOneWidget);
    });

    testWidgets('impressum() pushes Impressum placeholder', (tester) async {
      await pumpAndInvoke(tester, (ctx, nav) => nav.impressum(ctx));
      expect(find.text('IMPRESSUM'), findsOneWidget);
    });

    testWidgets('settings() pushes Settings placeholder', (tester) async {
      await pumpAndInvoke(tester, (ctx, nav) => nav.settings(ctx));
      expect(find.text('SETTINGS'), findsOneWidget);
    });

    testWidgets('help() pushes Help placeholder', (tester) async {
      await pumpAndInvoke(tester, (ctx, nav) => nav.help(ctx));
      expect(find.text('HELP'), findsOneWidget);
    });

    testWidgets('logout() invokes callback (no navigation)', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) {
              final nav = RealDrawerNavigator(
                userData: buildTestUser(),
                isLoggedIn: true,
                onLogout: () => calls++,
              );
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => nav.logout(ctx, () => calls++),
              );
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(calls, 1); // only the passed callback
    });
  });
}
