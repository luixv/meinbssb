import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/screens/schulungen/schulungen_register_person_dialog.dart';
import 'package:meinbssb/models/schulungstermin_data.dart';
import 'package:meinbssb/models/bank_data.dart';
import 'package:meinbssb/models/schulungstermine_zusatzfelder_data.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

class StubApiService extends Mock implements ApiService {
  List<SchulungstermineZusatzfelder> currentZusatzfelder =
      <SchulungstermineZusatzfelder>[];

  @override
  Future<List<SchulungstermineZusatzfelder>> fetchSchulungstermineZusatzfelder(
    int schulungsTerminId,
  ) async {
    return currentZusatzfelder;
  }
}

void main() {
  late StubApiService mockApiService;
  // Mutable data source for zusatzfelder to avoid re-stubbing during tests
  List<SchulungstermineZusatzfelder> currentZusatzfelder =
      <SchulungstermineZusatzfelder>[];

  setUp(() {
    mockApiService = StubApiService();
    currentZusatzfelder = <SchulungstermineZusatzfelder>[];
    mockApiService.currentZusatzfelder = currentZusatzfelder;
  });

  Widget buildDialog() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FontSizeProvider>(
          create: (_) => FontSizeProvider(),
        ),
        // add other providers if needed
      ],
      child: MaterialApp(
        home: Scaffold(
          body: RegisterPersonFormDialog(
            schulungsTermin: Schulungstermin(
              schulungsterminId: 1,
              schulungsartId: 1,
              schulungsTeilnehmerId: 0,
              datum: DateTime.now(),
              bemerkung: '',
              kosten: 0,
              ort: 'Ort',
              lehrgangsleiter: '',
              verpflegungskosten: 0,
              uebernachtungskosten: 0,
              lehrmaterialkosten: 0,
              lehrgangsinhalt: '',
              maxTeilnehmer: 0,
              webVeroeffentlichenAm: DateTime.now().toIso8601String(),
              anmeldungenGesperrt: false,
              status: 0,
              datumBis: DateTime.now().toIso8601String(),
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
              anmeldeErlaubt: 0,
              verbandsInternPasswort: '',
              bezeichnung: 'Test',
              angemeldeteTeilnehmer: 0,
            ),
            bankData: const BankData(
              id: 1,
              webloginId: 1,
              kontoinhaber: '',
              iban: '',
              bic: '',
            ),
            apiService: mockApiService,
          ),
        ),
      ),
    );
  }

  testWidgets('shows all static fields and disables OK button initially',
      (tester) async {
    await tester.pumpWidget(buildDialog());
    expect(find.text('Vorname'), findsOneWidget);
    expect(find.text('Nachname'), findsOneWidget);
    expect(find.text('Passnummer'), findsOneWidget);
    expect(find.text('E-Mail'), findsOneWidget);
    expect(find.text('Telefonnummer'), findsOneWidget);

    final fabFinder = find.byKey(const ValueKey('okFab'));
    final fab = tester.widget<FloatingActionButton>(fabFinder);
    expect(fab.onPressed, isNull);
  });

  testWidgets(
      'enables OK button when all static fields are filled and no zusatzfelder',
      (tester) async {
    await tester.pumpWidget(buildDialog());
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Vorname'),
      'Max',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nachname'),
      'Mustermann',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Passnummer'),
      '123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-Mail'),
      'max@test.de',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Telefonnummer'),
      '123456',
    );
    await tester.pumpAndSettle();

    final fabFinder = find.byKey(const ValueKey('okFab'));
    final fab = tester.widget<FloatingActionButton>(fabFinder);
    expect(fab.onPressed, isNotNull);
  });

  testWidgets('shows zusatzfelder fields and disables OK until all are filled',
      (tester) async {
    final zusatzfelder = [
      const SchulungstermineZusatzfelder(
        schulungstermineFeldId: 1,
        schulungsterminId: 1,
        feldbezeichnung: 'Feld A',
      ),
      const SchulungstermineZusatzfelder(
        schulungstermineFeldId: 2,
        schulungsterminId: 1,
        feldbezeichnung: 'Feld B',
      ),
    ];
    currentZusatzfelder = zusatzfelder;
    mockApiService.currentZusatzfelder = currentZusatzfelder;

    await tester.pumpWidget(buildDialog());
    await tester.pumpAndSettle();

    expect(find.text('Feld A'), findsOneWidget);
    expect(find.text('Feld B'), findsOneWidget);

    // Fill static fields
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Vorname'),
      'Max',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nachname'),
      'Mustermann',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Passnummer'),
      '123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-Mail'),
      'max@test.de',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Telefonnummer'),
      '123456',
    );
    await tester.pumpAndSettle();

    // OK still disabled because zusatzfelder are empty
    final fabFinder = find.byKey(const ValueKey('okFab'));
    var fab = tester.widget<FloatingActionButton>(fabFinder);
    expect(fab.onPressed, isNull);

    // Fill zusatzfelder
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Feld A'),
      'foo',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Feld B'),
      'bar',
    );
    await tester.pumpAndSettle();

    fab = tester.widget<FloatingActionButton>(fabFinder);
    expect(fab.onPressed, isNotNull);
  });

  testWidgets('shows validation error if email is invalid', (tester) async {
    await tester.pumpWidget(buildDialog());
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Vorname'),
      'Max',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nachname'),
      'Mustermann',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Passnummer'),
      '123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-Mail'),
      'invalid',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Telefonnummer'),
      '123456',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Ungültige E-Mail-Adresse'), findsOneWidget);
  });
}
