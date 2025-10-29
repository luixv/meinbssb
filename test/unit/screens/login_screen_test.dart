import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:meinbssb/screens/login_screen.dart';
import 'package:meinbssb/screens/password/password_reset_screen.dart';
import 'package:meinbssb/screens/registration/registration_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

@GenerateMocks([ApiService, ConfigService])
import 'login_screen_test.mocks.dart';

// Secure storage channel mock (in‑memory)
const MethodChannel secureStorageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);
final Map<String, String> secureStorageMemory = {};

late MockApiService mockApiService;
late MockConfigService mockConfigService;

UserData buildUserData() => UserData(
  personId: 10,
  webLoginId: 99,
  passnummer: 'ABC12345',
  vereinNr: 1,
  namen: 'Doe',
  vorname: 'John',
  vereinName: 'Testverein',
  passdatenId: 7,
  mitgliedschaftId: 3,
  geburtsdatum: DateTime(1990, 1, 1),
);

Widget createApp({required Widget child}) {
  return MultiProvider(
    providers: [
      Provider<ApiService>.value(value: mockApiService),
      ChangeNotifierProvider(create: (_) => FontSizeProvider()),
    ],
    child: MaterialApp(
      routes: {
        '/home': (_) => const Placeholder(),
        '/help': (_) => const Scaffold(body: Text('Hilfe (FAQ)')),
      },
      home: child,
    ),
  );
}

Widget createLoginScreen({Key? key, Function(UserData)? onSuccess}) {
  return createApp(
    child: LoginScreen(
      key: key,
      onLoginSuccess: onSuccess ?? (_) {},
      // Use real LogoWidget path via configService stub (no need to override)
    ),
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    secureStorageChannel.setMockMethodCallHandler((call) async {
      switch (call.method) {
        case 'read':
          return secureStorageMemory[call.arguments['key']];
        case 'write':
          secureStorageMemory[call.arguments['key']] =
              call.arguments['value'] ?? '';
          return true;
        case 'delete':
          secureStorageMemory.remove(call.arguments['key']);
          return true;
        case 'deleteAll':
          secureStorageMemory.clear();
          return true;
        case 'readAll':
          return secureStorageMemory;
        default:
          return '';
      }
    });
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockApiService = MockApiService();
    mockConfigService = MockConfigService();

    when(mockApiService.configService).thenReturn(mockConfigService);

    // Generic stub: any logo / image related key returns a valid existing asset (avoid empty string -> asset load error).
    when(mockConfigService.getString(any, any)).thenAnswer((invocation) {
      final key = invocation.positionalArguments[0] as String;
      // Provide same known asset for all image / logo related keys
      if (key.toLowerCase().contains('logo') ||
          key.toLowerCase().contains('image')) {
        return 'assets/images/myBSSB-logo.png';
      }
      // Fallback: return provided default value to minimize side effects
      return invocation.positionalArguments[1];
    });
  });

  group('LoginScreen - Basic UI', () {
    testWidgets('renders static elements', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();
      expect(find.text('Anmeldung'), findsOneWidget);
      expect(find.byKey(const Key('usernameField')), findsOneWidget);
      expect(find.byKey(const Key('passwordField')), findsOneWidget);
      expect(find.byKey(const Key('loginButton')), findsOneWidget);
      expect(find.text('Angemeldet bleiben'), findsOneWidget);
    });

    testWidgets('password visibility toggles twice', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();
      TextField pwd = tester.widget(find.byKey(const Key('passwordField')));
      expect(pwd.obscureText, isTrue);
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();
      pwd = tester.widget(find.byKey(const Key('passwordField')));
      expect(pwd.obscureText, isFalse);
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();
      pwd = tester.widget(find.byKey(const Key('passwordField')));
      expect(pwd.obscureText, isTrue);
    });

    testWidgets('initially no error message is shown', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();
      expect(find.textContaining('Fehler'), findsNothing);
    });
  });

  group('LoginScreen - Successful Flow', () {
    testWidgets('login success but fetchPassdaten null shows error', (
      tester,
    ) async {
      when(mockApiService.login(any, any)).thenAnswer(
        (_) async => {
          'ResultType': 1,
          'PersonID': 10,
          'WebLoginID': 77,
          'ResultMessage': 'OK',
        },
      );
      when(mockApiService.fetchPassdaten(10)).thenAnswer((_) async => null);

      await tester.pumpWidget(createLoginScreen());
      await tester.enterText(find.byKey(const Key('usernameField')), 'x@x.de');
      await tester.enterText(find.byKey(const Key('passwordField')), 'pw');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      expect(find.text('Fehler beim Laden der Passdaten.'), findsOneWidget);
      verify(mockApiService.fetchPassdaten(10)).called(1);
    });
  });

  group('LoginScreen - Error Handling', () {
    testWidgets('failed login shows backend message', (tester) async {
      when(mockApiService.login(any, any)).thenAnswer(
        (_) async => {'ResultType': 0, 'ResultMessage': 'Backend Fehler'},
      );
      await tester.pumpWidget(createLoginScreen());
      await tester.enterText(find.byKey(const Key('usernameField')), 'a');
      await tester.enterText(find.byKey(const Key('passwordField')), 'b');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();
      expect(find.text('Backend Fehler'), findsOneWidget);
    });

    testWidgets('exception during login is caught', (tester) async {
      when(mockApiService.login(any, any)).thenThrow(Exception('Crash'));
      await tester.pumpWidget(createLoginScreen());
      await tester.enterText(find.byKey(const Key('usernameField')), 'e');
      await tester.enterText(find.byKey(const Key('passwordField')), 'f');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Error: Exception: Crash'), findsOneWidget);
    });

    testWidgets('error message replaced on new attempt', (tester) async {
      when(
        mockApiService.login('bad@test.de', any),
      ).thenAnswer((_) async => {'ResultType': 0, 'ResultMessage': 'Bad'});
      when(mockApiService.login('good@test.de', any)).thenAnswer(
        (_) async => {
          'ResultType': 1,
          'PersonID': 10,
          'WebLoginID': 88,
          'ResultMessage': 'OK',
        },
      );
      when(
        mockApiService.fetchPassdaten(10),
      ).thenAnswer((_) async => buildUserData());
      when(
        mockApiService.fetchSchuetzenausweis(10),
      ).thenAnswer((_) async => Uint8List(0));

      await tester.pumpWidget(createLoginScreen());
      await tester.enterText(
        find.byKey(const Key('usernameField')),
        'bad@test.de',
      );
      await tester.enterText(find.byKey(const Key('passwordField')), 'pw');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();
      expect(find.text('Bad'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('usernameField')),
        'good@test.de',
      );
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();
      expect(find.text('Bad'), findsNothing);
      expect(find.byType(Placeholder), findsOneWidget);
    });
  });

  group('LoginScreen - Loading & Button State', () {
    testWidgets('button disabled while loading prevents double login', (
      tester,
    ) async {
      final completer = Completer<Map<String, dynamic>>();
      when(mockApiService.login(any, any)).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createLoginScreen());
      await tester.enterText(find.byKey(const Key('usernameField')), 'x');
      await tester.enterText(find.byKey(const Key('passwordField')), 'y');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('loginButton')));
      verify(mockApiService.login(any, any)).called(1);

      completer.complete({'ResultType': 0, 'ResultMessage': 'Fail'});
      await tester.pumpAndSettle();
    });

    testWidgets('onSubmitted triggers login once', (tester) async {
      when(
        mockApiService.login(any, any),
      ).thenAnswer((_) async => {'ResultType': 0, 'ResultMessage': 'Nope'});
      await tester.pumpWidget(createLoginScreen());
      await tester.enterText(find.byKey(const Key('usernameField')), 'z');
      await tester.enterText(find.byKey(const Key('passwordField')), 'z');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      verify(mockApiService.login('z', 'z')).called(1);
      expect(find.text('Nope'), findsOneWidget);
    });
  });

  group('LoginScreen - Navigation', () {
    testWidgets('register button opens registration screen', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.tap(find.byKey(const Key('registerButton')));
      await tester.pumpAndSettle();
      expect(find.byType(RegistrationScreen), findsOneWidget);
    });

    testWidgets('forgot password opens reset screen', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.tap(find.byKey(const Key('forgotPasswordButton')));
      await tester.pumpAndSettle();
      expect(find.byType(PasswordResetScreen), findsOneWidget);
    });

    testWidgets('help button navigates to help', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.tap(find.byKey(const Key('helpButton')));
      await tester.pumpAndSettle();
      expect(find.text('Hilfe (FAQ)'), findsOneWidget);
    });
  });

  group('LoginScreen - Remember Me / Secure Storage', () {
    testWidgets('initialization pre-fills email & password when stored', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'rememberMe': true,
        'savedEmail': 'prefill@test.de',
      });
      secureStorageMemory['saved_password_remember_me'] = 'pwInit';

      await tester.pumpWidget(createLoginScreen());
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(find.text('prefill@test.de'), findsOneWidget);
      expect(find.text('pwInit'), findsOneWidget);
    });

    testWidgets(
      'successful login with remember me OFF does not persist credentials',
      (tester) async {
        when(mockApiService.login(any, any)).thenAnswer(
          (_) async => {
            'ResultType': 1,
            'PersonID': 10,
            'WebLoginID': 66,
            'ResultMessage': 'OK',
          },
        );
        when(
          mockApiService.fetchPassdaten(10),
        ).thenAnswer((_) async => buildUserData());
        when(
          mockApiService.fetchSchuetzenausweis(10),
        ).thenAnswer((_) async => Uint8List(0));

        await tester.pumpWidget(createLoginScreen());
        await tester.enterText(
          find.byKey(const Key('usernameField')),
          'noremember@test.de',
        );
        await tester.enterText(find.byKey(const Key('passwordField')), 'pw123');
        await tester.tap(find.byKey(const Key('loginButton')));
        await tester.pumpAndSettle();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('rememberMe'), isFalse);
        expect(prefs.getString('savedEmail'), isNull);
        expect(secureStorageMemory['saved_password_remember_me'], isNull);
      },
    );
  });

  group('LoginScreen - Additional Coverage', () {
    testWidgets('error cleared when new login starts', (tester) async {
      when(
        mockApiService.login(any, any),
      ).thenAnswer((_) async => {'ResultType': 0, 'ResultMessage': 'Fail'});

      await tester.pumpWidget(createLoginScreen());
      await tester.enterText(find.byKey(const Key('usernameField')), 'a');
      await tester.enterText(find.byKey(const Key('passwordField')), 'b');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();
      expect(find.text('Fail'), findsOneWidget);

      when(mockApiService.login('a', 'b')).thenAnswer(
        (_) async => {
          'ResultType': 1,
          'PersonID': 10,
          'WebLoginID': 91,
          'ResultMessage': 'OK',
        },
      );
      when(
        mockApiService.fetchPassdaten(10),
      ).thenAnswer((_) async => buildUserData());
      when(
        mockApiService.fetchSchuetzenausweis(10),
      ).thenAnswer((_) async => Uint8List(0));

      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump(); // loading
      expect(find.text('Fail'), findsNothing);
    });

    testWidgets('rapid password toggle stable', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.visibility_off).first);
        await tester.pump();
        await tester.tap(find.byIcon(Icons.visibility).first);
        await tester.pump();
      }
      TextField pwd = tester.widget(find.byKey(const Key('passwordField')));
      expect(pwd.obscureText, isTrue);
    });

    testWidgets('tapping checkbox widget itself toggles remember state', (
      tester,
    ) async {
      await tester.pumpWidget(createLoginScreen());
      final cbFinder = find.byType(Checkbox);
      Checkbox cb = tester.widget(cbFinder);
      expect(cb.value, isFalse);
      await tester.tap(cbFinder);
      await tester.pump();
      cb = tester.widget(cbFinder);
      expect(cb.value, isTrue);
    });
  });
}
