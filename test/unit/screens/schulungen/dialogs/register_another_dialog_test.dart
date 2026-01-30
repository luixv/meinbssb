import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/schulungen/dialogs/register_another_dialog.dart';
import 'package:meinbssb/models/schulungstermin_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

void main() {
  group('RegisterAnotherDialog', () {
    late Schulungstermin schulungsTermin;
    late List<RegisteredPersonUi> registeredPersons;

    setUp(() {
      schulungsTermin = Schulungstermin(
        schulungsterminId: 1,
        schulungsartId: 1,
        schulungsTeilnehmerId: 1,
        datum: DateTime(2024, 1, 1),
        bemerkung: 'Bemerkung',
        kosten: 10.0,
        ort: 'Ort',
        lehrgangsleiter: 'Leiter',
        verpflegungskosten: 5.0,
        uebernachtungskosten: 0.0,
        lehrmaterialkosten: 0.0,
        lehrgangsinhalt: 'Inhalt',
        maxTeilnehmer: 10,
        webVeroeffentlichenAm: '',
        anmeldungenGesperrt: false,
        status: 0,
        datumBis: '',
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
        webGruppe: 0,
        veranstaltungsBezirk: 0,
        fuerVerlaengerungen: false,
        fuerVuelVerlaengerungen: false,
        anmeldeErlaubt: 1,
        verbandsInternPasswort: '',
        bezeichnung: 'Test Schulung',
        angemeldeteTeilnehmer: 1,
      );
      registeredPersons = [
        RegisteredPersonUi('Max', 'Mustermann', '12345'),
        RegisteredPersonUi('Erika', 'Musterfrau', '67890'),
      ];
    });

    Finder findTextInRichText(String text) {
      return find.byWidgetPredicate((widget) {
        if (widget is RichText) {
          final span = widget.text;
          if (span is TextSpan) {
            final plainText = span.toPlainText();
            return plainText.contains(text);
          }
        }
        if (widget is Text) {
          return widget.data?.contains(text) ?? false;
        }
        return false;
      });
    }

    Widget buildDialog({List<RegisteredPersonUi>? persons}) {
      return ChangeNotifierProvider<FontSizeProvider>(
        create: (_) => FontSizeProvider(),
        child: MaterialApp(
          home: Builder(
            builder:
                (context) => RegisterAnotherDialog(
                  schulungsTermin: schulungsTermin,
                  registeredPersons: persons ?? registeredPersons,
                ),
          ),
        ),
      );
    }

    testWidgets('shows registered persons', (WidgetTester tester) async {
      await tester.pumpWidget(buildDialog());
      expect(findTextInRichText('Max Mustermann'), findsOneWidget);
      expect(findTextInRichText('Erika Musterfrau'), findsOneWidget);
      expect(findTextInRichText('12345'), findsOneWidget);
      expect(findTextInRichText('67890'), findsOneWidget);
    });

    testWidgets('shows dialog title and content', (WidgetTester tester) async {
      await tester.pumpWidget(buildDialog());
      expect(find.text('Bereits angemeldete Personen'), findsOneWidget);
      expect(
        findTextInRichText('Sie sind angemeldet für die Schulung'),
        findsOneWidget,
      );
      expect(findTextInRichText('Test Schulung.'), findsOneWidget);
      expect(
        findTextInRichText(
          'Möchten Sie noch eine weitere Person für diese Schulung anmelden?',
        ),
        findsWidgets,
      );
    });

    testWidgets('shows no persons if list is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildDialog(persons: []));
      expect(findTextInRichText('Max Mustermann'), findsNothing);
      expect(findTextInRichText('Erika Musterfrau'), findsNothing);
    });

    testWidgets('tapping Nein returns goHome', (WidgetTester tester) async {
      String? result;
      await tester.pumpWidget(
        ChangeNotifierProvider<FontSizeProvider>(
          create: (_) => FontSizeProvider(),
          child: MaterialApp(
            home: Builder(
              builder:
                  (context) => Builder(
                    builder:
                        (context2) => ElevatedButton(
                          onPressed: () async {
                            result = await RegisterAnotherDialog.show(
                              context2,
                              schulungsTermin: schulungsTermin,
                              registeredPersons: registeredPersons,
                            );
                          },
                          child: const Text('Open Dialog'),
                        ),
                  ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Nein'));
      await tester.pumpAndSettle();
      expect(result, 'goHome');
    });

    testWidgets('tapping Ja returns registerAnother', (
      WidgetTester tester,
    ) async {
      String? result;
      await tester.pumpWidget(
        ChangeNotifierProvider<FontSizeProvider>(
          create: (_) => FontSizeProvider(),
          child: MaterialApp(
            home: Builder(
              builder:
                  (context) => Builder(
                    builder:
                        (context2) => ElevatedButton(
                          onPressed: () async {
                            result = await RegisterAnotherDialog.show(
                              context2,
                              schulungsTermin: schulungsTermin,
                              registeredPersons: registeredPersons,
                            );
                          },
                          child: const Text('Open Dialog'),
                        ),
                  ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Ja'));
      await tester.pumpAndSettle();
      expect(result, 'registerAnother');
    });
  });
}
