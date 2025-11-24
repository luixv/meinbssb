import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/privacy_screen.dart';
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

  Widget buildTestWidget() {
    return ChangeNotifierProvider<FontSizeProvider>(
      create: (_) => FontSizeProvider(),
      child: MaterialApp(
        home: PrivacyScreen(
          userData: userData,
          isLoggedIn: true,
          onLogout: () {},
        ),
      ),
    );
  }

  testWidgets('shows Datenschutz title and section headers', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    expect(find.text('Datenschutz'), findsOneWidget);
    expect(find.text('Datenschutzerklärung'), findsOneWidget);
    expect(find.text('Verantwortlicher und Datenschutzbeauftragter'),
        findsOneWidget,);
    expect(find.text('Hosting'), findsOneWidget);
    expect(find.text('Welche Daten werden erfasst und wie?'), findsOneWidget);
    expect(find.text('Wofür werden erhobene Daten genutzt?'), findsOneWidget);
    expect(find.text('Speicherdauer und Datenlöschung'), findsOneWidget);
    expect(find.text('Datensicherheit'), findsOneWidget);
    expect(find.text('Rechte der betroffenen Person'), findsOneWidget);
    expect(find.text('Widerspruchsrecht'), findsOneWidget);
    expect(find.text('SSL- bzw. TLS-Verschlüsselung'), findsOneWidget);
  });

  testWidgets('shows close FAB', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });
}
