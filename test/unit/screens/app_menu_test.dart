import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/app_menu.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/registration_screen.dart';
import 'package:meinbssb/screens/password_reset_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/core/email_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/widgets/scaled_text.dart';

void main() {
  group('AppMenu', () {
    testWidgets('shows menu icon and triggers openEndDrawer', (tester) async {
      final scaffoldKey = GlobalKey<ScaffoldState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            key: scaffoldKey,
            endDrawer: const Drawer(
              child: Text('Drawer'),
            ),
            body: Builder(
              builder: (context) => AppMenu(
                context: context,
                userData: null,
                isLoggedIn: false,
                onLogout: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.menu), findsOneWidget);

      // Tap the menu icon
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Drawer should be open
      expect(find.text('Drawer'), findsOneWidget);
    });
  });

  group('AppDrawer', () {
    testWidgets('shows logged-out menu items', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<FontSizeProvider>(
          create: (_) => FontSizeProvider(),
          child: MaterialApp(
            home: Scaffold(
              drawer: AppDrawer(
                userData: null,
                isLoggedIn: false,
                onLogout: () {},
              ),
            ),
          ),
        ),
      );

      // Open the drawer
      ScaffoldState state = tester.firstState(find.byType(Scaffold));
      state.openDrawer();
      await tester.pumpAndSettle();

      expect(findScaledText('Anmelden'), findsOneWidget);
      expect(findScaledText('Registrieren'), findsOneWidget);
      expect(findScaledText('Passwort zurücksetzen'), findsOneWidget);
      expect(findScaledText('Abmelden'), findsNothing);
      expect(findScaledText('Home'), findsNothing);
    });

    // Navigation tests to other feature screens are intentionally omitted here
    // because those screens require multiple providers/services. We cover menu
    // visibility and basic actions (logout and login route) which are stable.

    testWidgets('logged out: tapping Anmelden goes to /login route',
        (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<FontSizeProvider>(
          create: (_) => FontSizeProvider(),
          child: MaterialApp(
            routes: {
              '/login': (context) =>
                  const Placeholder(key: ValueKey('loginScreen')),
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

      final scaffoldState =
          tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Anmelden'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('loginScreen')), findsOneWidget);
    });

    testWidgets('logged out: tapping Registrieren pushes RegistrationScreen',
        (tester) async {
      // Minimal fake services for providers
      final fakeAuthService = _FakeAuthService();
      final fakeEmailService = _FakeEmailService();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FontSizeProvider>(
              create: (_) => FontSizeProvider(),
            ),
            Provider<AuthService>.value(value: fakeAuthService),
            Provider<EmailService>.value(value: fakeEmailService),
            Provider<ConfigService>.value(value: _FakeConfigService()),
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

      final scaffoldState =
          tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Registrieren'));
      await tester.pumpAndSettle();

      expect(find.byType(RegistrationScreen), findsOneWidget);
    });

    testWidgets(
        'logged out: tapping Passwort zurücksetzen pushes PasswordResetScreen',
        (tester) async {
      // Minimal fake ApiService for provider
      final fakeApiService = _FakeApiService();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FontSizeProvider>(
              create: (_) => FontSizeProvider(),
            ),
            Provider<ApiService>.value(value: fakeApiService),
            Provider<ConfigService>.value(value: _FakeConfigService()),
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

      final scaffoldState =
          tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Passwort zurücksetzen'));
      await tester.pumpAndSettle();

      expect(find.byType(PasswordResetScreen), findsOneWidget);
    });
  });
}

// Helpers
void _noop() {}

class _FakeAuthService implements AuthService {
  @override
  noSuchMethod(Invocation invocation) => null;
}

class _FakeEmailService implements EmailService {
  @override
  noSuchMethod(Invocation invocation) => null;
}

class _FakeApiService implements ApiService {
  @override
  noSuchMethod(Invocation invocation) => null;
}

class _FakeConfigService implements ConfigService {
  @override
  noSuchMethod(Invocation invocation) => null;
}

Finder findScaledText(String text) => find.byWidgetPredicate(
      (widget) => widget is ScaledText && widget.text == text,
    );
