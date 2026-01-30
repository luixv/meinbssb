import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:provider/provider.dart';
import 'package:meinbssb/screens/schulungen/dialogs/login_dialog.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

import 'package:mockito/annotations.dart';
import 'login_dialog_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  group('LoginDialog', () {
    late MockApiService mockApiService;
    late bool loginSuccessCalled;
    late UserData? loginUserData;

    setUp(() {
      mockApiService = MockApiService();
      loginSuccessCalled = false;
      loginUserData = null;
    });

    Widget buildDialog() {
      return ChangeNotifierProvider<FontSizeProvider>(
        create: (_) => FontSizeProvider(),
        child: Provider<ApiService>.value(
          value: mockApiService,
          child: MaterialApp(
            home: Builder(
              builder:
                  (context) => LoginDialog(
                    onLoginSuccess: (user) {
                      loginSuccessCalled = true;
                      loginUserData = user;
                    },
                  ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(buildDialog());
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('E-Mail'), findsOneWidget);
      expect(find.text('Passwort'), findsOneWidget);
    });

    testWidgets('shows error on failed login', (tester) async {
      when(mockApiService.login(any, any)).thenAnswer(
        (_) async => {
          'ResultType': 0,
          'ResultMessage': 'Login fehlgeschlagen.',
        },
      );
      await tester.pumpWidget(buildDialog());
      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'wrongpassword');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.text('Login fehlgeschlagen.'), findsOneWidget);
      expect(loginSuccessCalled, isFalse);
    });

    testWidgets('calls onLoginSuccess on successful login', (tester) async {
      final userData = UserData(
        personId: 1,
        webLoginId: 2,
        passnummer: '123',
        vereinNr: 1,
        namen: 'Max',
        vorname: 'Mustermann',
        vereinName: '',
        passdatenId: 1,
        mitgliedschaftId: 1,
        email: 'test@example.com',
        geburtsdatum: DateTime(2000, 1, 1),
        geschlecht: 1,
        telefon: '',
        strasse: '',
        plz: '',
        ort: '',
        land: '',
      );
      when(mockApiService.login(any, any)).thenAnswer(
        (_) async => {'ResultType': 1, 'PersonID': 1, 'WebLoginID': 2},
      );
      when(mockApiService.fetchPassdaten(1)).thenAnswer((_) async => userData);
      await tester.pumpWidget(buildDialog());
      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      expect(loginSuccessCalled, isTrue);
      expect(loginUserData, isNotNull);
      expect(loginUserData!.personId, 1);
    });

    testWidgets('shows/hides password when icon tapped', (tester) async {
      await tester.pumpWidget(buildDialog());
      final passwordField = find.byType(TextField).at(1);
      expect(tester.widget<TextField>(passwordField).obscureText, isTrue);
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();
      expect(tester.widget<TextField>(passwordField).obscureText, isFalse);
    });
  });
}
