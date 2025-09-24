import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/registration_fail_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

void main() {
  late UserData userData;

  setUp(() {
    userData = const UserData(
      personId: 1,
      webLoginId: 1,
      passnummer: '123456',
      vereinNr: 1,
      namen: 'Mustermann',
      vorname: 'Max',
      titel: null,
      geburtsdatum: null,
      geschlecht: null,
      vereinName: 'Testverein',
      strasse: null,
      plz: null,
      ort: null,
      land: '',
      nationalitaet: '',
      passStatus: 0,
      passdatenId: 1,
      eintrittVerein: null,
      austrittVerein: null,
      mitgliedschaftId: 1,
      telefon: '',
      erstLandesverbandId: 0,
      produktionsDatum: null,
      erstVereinId: 0,
      digitalerPass: 0,
      isOnline: false,
      disziplin: null,
    );
  });

  Widget buildTestWidget({required String message, UserData? userData}) {
    return ChangeNotifierProvider<FontSizeProvider>(
      create: (_) => FontSizeProvider(),
      child: MaterialApp(
        routes: {
          '/login': (context) => const Scaffold(body: Text('Login Screen')),
        },
        home: RegistrationFailScreen(
          message: message,
          userData: userData,
        ),
      ),
    );
  }

  testWidgets('shows error icon and message', (tester) async {
    await tester
        .pumpWidget(buildTestWidget(message: 'Fehlertext', userData: userData));
    expect(find.byIcon(Icons.error), findsOneWidget);
    expect(find.text('Fehlertext'), findsOneWidget);
    expect(find.text('Registrierung fehlgeschlagen'), findsOneWidget);
  });

  testWidgets('FAB navigates to login screen', (tester) async {
    await tester
        .pumpWidget(buildTestWidget(message: 'Fehlertext', userData: userData));
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Login Screen'), findsOneWidget);
  });
}
