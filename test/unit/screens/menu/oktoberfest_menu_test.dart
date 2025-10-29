import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/menu/oktoberfest_menu.dart';
import 'package:meinbssb/models/user_data.dart';

void main() {
  group('OktoberfestScreen', () {
    final userData = const UserData(
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

    Widget buildTestWidget() {
      return MaterialApp(
        home: OktoberfestScreen(
          userData: userData,
          isLoggedIn: true,
          onLogout: () {},
        ),
      );
    }

    testWidgets('shows menu items', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Oktoberfest'), findsOneWidget);
      expect(find.text('Meine Ergebnisse'), findsOneWidget);
      expect(find.text('Meine Gewinne'), findsOneWidget);
    });

    testWidgets('tapping Meine Ergebnisse navigates', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Meine Ergebnisse'));
      await tester.pumpAndSettle();
      // Should navigate to OktoberfestResultsScreen, but we just check navigation occurred
      expect(find.byType(OktoberfestScreen), findsNothing);
    });

    testWidgets('tapping Meine Gewinne navigates', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Meine Gewinne'));
      await tester.pumpAndSettle();
      // Should navigate to OktoberfestGewinnScreen, but we just check navigation occurred
      expect(find.byType(OktoberfestScreen), findsNothing);
    });
  });
}
