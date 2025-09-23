import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/schulungen/schulungen_list_item.dart';
import 'package:meinbssb/models/schulungstermin_data.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:provider/provider.dart';

void main() {
  group('SchulungenListItem', () {
    late Schulungstermin schulungsTermin;
    late bool detailsPressed;

    setUp(() {
      schulungsTermin = Schulungstermin(
        schulungsterminId: 1,
        schulungsartId: 1,
        schulungsTeilnehmerId: 1,
        bemerkung: '',
        kosten: 0.0,
        lehrgangsleiter: '',
        verpflegungskosten: 0.0,
        uebernachtungskosten: 0.0,
        lehrmaterialkosten: 0.0,
        lehrgangsinhalt: '',
        maxTeilnehmer: 10,
        webVeroeffentlichenAm: '2025-01-01',
        status: 0,
        datum: DateTime(2025, 9, 23),
        datumBis: '2025-09-23',
        lehrgangsinhaltHtml: '',
        lehrgangsleiter2: '',
        lehrgangsleiter3: '',
        lehrgangsleiter4: '',
        lehrgangsleiterTel: '',
        lehrgangsleiter2Tel: '',
        lehrgangsleiter3Tel: '',
        lehrgangsleiter4Tel: '',
        lehrgangsleiterMail: '',
        lehrgangsleiter2Mail: '',
        lehrgangsleiter3Mail: '',
        lehrgangsleiter4Mail: '',
        anmeldeStopp: '',
        abmeldeStopp: '',
        geloescht: false,
        stornoGrund: '',
        webGruppe: 2, // 2 = Sport
        veranstaltungsBezirk: 0,
        fuerVerlaengerungen: false,
        fuerVuelVerlaengerungen: false,
        anmeldeErlaubt: 1,
        verbandsInternPasswort: '',
        angemeldeteTeilnehmer: 0,
        ort: 'Musterort',
        bezeichnung: 'Test Schulung',
        anmeldungenGesperrt: false,
      );
      detailsPressed = false;
    });

    Widget buildTestWidget({required Schulungstermin termin}) {
      return ChangeNotifierProvider<FontSizeProvider>(
        create: (_) => FontSizeProvider(),
        child: MaterialApp(
          home: Scaffold(
            body: SchulungenListItem(
              schulungsTermin: termin,
              index: 0,
              onDetailsPressed: () {
                detailsPressed = true;
              },
            ),
          ),
        ),
      );
    }

    testWidgets('displays formatted date, group, location, and title',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(termin: schulungsTermin));

      expect(find.text('23.09.2025'), findsOneWidget);
      expect(find.text('Sport'), findsOneWidget);
      expect(find.text('Musterort'), findsOneWidget);
      expect(find.text('Test Schulung'), findsOneWidget);
    });

    testWidgets('calls onDetailsPressed when FAB is tapped', (tester) async {
      await tester.pumpWidget(buildTestWidget(termin: schulungsTermin));
      await tester.tap(find.byType(FloatingActionButton));
      expect(detailsPressed, isTrue);
    });

    testWidgets('uses correct FAB color for Sport', (tester) async {
      await tester.pumpWidget(buildTestWidget(termin: schulungsTermin));
      final fab = tester
          .widget<FloatingActionButton>(find.byType(FloatingActionButton));
      expect(fab.backgroundColor, UIConstants.sportColor);
    });

    testWidgets('uses correct FAB color for Jugend', (tester) async {
      schulungsTermin = Schulungstermin(
        schulungsterminId: 1,
        schulungsartId: 1,
        schulungsTeilnehmerId: 1,
        bemerkung: '',
        kosten: 0.0,
        lehrgangsleiter: '',
        verpflegungskosten: 0.0,
        uebernachtungskosten: 0.0,
        lehrmaterialkosten: 0.0,
        lehrgangsinhalt: '',
        maxTeilnehmer: 10,
        webVeroeffentlichenAm: '2025-01-01',
        status: 0,
        datum: DateTime(2025, 9, 23),
        datumBis: '2025-09-23',
        lehrgangsinhaltHtml: '',
        lehrgangsleiter2: '',
        lehrgangsleiter3: '',
        lehrgangsleiter4: '',
        lehrgangsleiterTel: '',
        lehrgangsleiter2Tel: '',
        lehrgangsleiter3Tel: '',
        lehrgangsleiter4Tel: '',
        lehrgangsleiterMail: '',
        lehrgangsleiter2Mail: '',
        lehrgangsleiter3Mail: '',
        lehrgangsleiter4Mail: '',
        anmeldeStopp: '',
        abmeldeStopp: '',
        geloescht: false,
        stornoGrund: '',
        webGruppe: 1, // 1 = Jugend
        veranstaltungsBezirk: 0,
        fuerVerlaengerungen: false,
        fuerVuelVerlaengerungen: false,
        anmeldeErlaubt: 1,
        verbandsInternPasswort: '',
        angemeldeteTeilnehmer: 0,
        ort: 'Musterort',
        bezeichnung: 'Test Schulung',
        anmeldungenGesperrt: false,
      );
      await tester.pumpWidget(buildTestWidget(termin: schulungsTermin));
      final fab = tester
          .widget<FloatingActionButton>(find.byType(FloatingActionButton));
      expect(fab.backgroundColor, UIConstants.jugendColor);
    });

    testWidgets('uses correct FAB color for other group', (tester) async {
      schulungsTermin = Schulungstermin(
        schulungsterminId: 1,
        schulungsartId: 1,
        schulungsTeilnehmerId: 1,
        bemerkung: '',
        kosten: 0.0,
        lehrgangsleiter: '',
        verpflegungskosten: 0.0,
        uebernachtungskosten: 0.0,
        lehrmaterialkosten: 0.0,
        lehrgangsinhalt: '',
        maxTeilnehmer: 10,
        webVeroeffentlichenAm: '2025-01-01',
        status: 0,
        datum: DateTime(2025, 9, 23),
        datumBis: '2025-09-23',
        lehrgangsinhaltHtml: '',
        lehrgangsleiter2: '',
        lehrgangsleiter3: '',
        lehrgangsleiter4: '',
        lehrgangsleiterTel: '',
        lehrgangsleiter2Tel: '',
        lehrgangsleiter3Tel: '',
        lehrgangsleiter4Tel: '',
        lehrgangsleiterMail: '',
        lehrgangsleiter2Mail: '',
        lehrgangsleiter3Mail: '',
        lehrgangsleiter4Mail: '',
        anmeldeStopp: '',
        abmeldeStopp: '',
        geloescht: false,
        stornoGrund: '',
        webGruppe: 99, // 99 = Sonstiges (not mapped in webGruppeMap)
        veranstaltungsBezirk: 0,
        fuerVerlaengerungen: false,
        fuerVuelVerlaengerungen: false,
        anmeldeErlaubt: 1,
        verbandsInternPasswort: '',
        angemeldeteTeilnehmer: 0,
        ort: 'Musterort',
        bezeichnung: 'Test Schulung',
        anmeldungenGesperrt: false,
      );
      await tester.pumpWidget(buildTestWidget(termin: schulungsTermin));
      final fab = tester
          .widget<FloatingActionButton>(find.byType(FloatingActionButton));
      expect(fab.backgroundColor, UIConstants.schulungenNormalColor);
    });

    testWidgets('uses gesperrt color if anmeldungenGesperrt is true',
        (tester) async {
      schulungsTermin = Schulungstermin(
        schulungsterminId: 1,
        schulungsartId: 1,
        schulungsTeilnehmerId: 1,
        bemerkung: '',
        kosten: 0.0,
        lehrgangsleiter: '',
        verpflegungskosten: 0.0,
        uebernachtungskosten: 0.0,
        lehrmaterialkosten: 0.0,
        lehrgangsinhalt: '',
        maxTeilnehmer: 10,
        webVeroeffentlichenAm: '2025-01-01',
        status: 0,
        datum: DateTime(2025, 9, 23),
        datumBis: '2025-09-23',
        lehrgangsinhaltHtml: '',
        lehrgangsleiter2: '',
        lehrgangsleiter3: '',
        lehrgangsleiter4: '',
        lehrgangsleiterTel: '',
        lehrgangsleiter2Tel: '',
        lehrgangsleiter3Tel: '',
        lehrgangsleiter4Tel: '',
        lehrgangsleiterMail: '',
        lehrgangsleiter2Mail: '',
        lehrgangsleiter3Mail: '',
        lehrgangsleiter4Mail: '',
        anmeldeStopp: '',
        abmeldeStopp: '',
        geloescht: false,
        stornoGrund: '',
        webGruppe: 1,
        veranstaltungsBezirk: 0,
        fuerVerlaengerungen: false,
        fuerVuelVerlaengerungen: false,
        anmeldeErlaubt: 1,
        verbandsInternPasswort: '',
        angemeldeteTeilnehmer: 0,
        ort: 'Musterort',
        bezeichnung: 'Test Schulung',
        anmeldungenGesperrt: true, // <--- set to true here
      );
      await tester.pumpWidget(buildTestWidget(termin: schulungsTermin));
      final fab = tester
          .widget<FloatingActionButton>(find.byType(FloatingActionButton));
      expect(fab.backgroundColor, UIConstants.schulungenGesperrtColor);
    });
  });
}
