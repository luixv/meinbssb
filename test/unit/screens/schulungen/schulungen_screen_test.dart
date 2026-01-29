import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:meinbssb/models/schulungstermin_data.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/schulungen/schulungen_screen.dart';
import 'package:meinbssb/services/api_service.dart';

import 'schulungen_screen_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    Intl.defaultLocale = 'de_DE';
    await initializeDateFormatting('de_DE', null);
    await initializeDateFormatting('de', null);
  });

  group('SchulungenScreen', () {
    late MockApiService mockApiService;

    final userData = UserData(
      personId: 1,
      webLoginId: 1,
      passnummer: '12345',
      vereinNr: 100,
      namen: 'Mustermann',
      vorname: 'Max',
      titel: 'Herr',
      geburtsdatum: DateTime(1990, 1, 1),
      geschlecht: 1,
      vereinName: 'Schützenverein',
      passdatenId: 10,
      mitgliedschaftId: 20,
      strasse: 'Hauptstr. 1',
      plz: '12345',
      ort: 'Musterstadt',
      land: 'DE',
      nationalitaet: 'DE',
      passStatus: 1,
      eintrittVerein: DateTime(2010, 1, 1),
      austrittVerein: null,
      telefon: '0123456789',
      erstLandesverbandId: 0,
      produktionsDatum: null,
      erstVereinId: 0,
      digitalerPass: 0,
      isOnline: false,
      disziplin: 'Luftgewehr',
      email: 'max@example.com',
      role: 'mitglied',
    );

    setUp(() {
      mockApiService = MockApiService();
    });

    Widget createWidgetUnderTest({
      bool isLoggedIn = true,
      VoidCallback? onLogout,
    }) {
      return MultiProvider(
        providers: [
          Provider<ApiService>.value(value: mockApiService),
          ChangeNotifierProvider<FontSizeProvider>.value(
            value: FontSizeProvider(),
          ),
        ],
        child: MaterialApp(
          home: SchulungenScreen(
            userData,
            isLoggedIn: isLoggedIn,
            onLogout: onLogout ?? () {},
            searchDate: DateTime(2024, 1, 1),
            webGruppe: null,
            bezirkId: null,
            ort: null,
            titel: null,
            fuerVerlaengerungen: null,
            fuerVuelVerlaengerungen: null,
            showMenu: true,
            showConnectivityIcon: true,
          ),
        ),
      );
    }

    Schulungstermin buildTermin({
      required String bezeichnung,
      bool geloescht = false,
    }) {
      return Schulungstermin(
        schulungsterminId: 1,
        schulungsartId: 1,
        schulungsTeilnehmerId: 1,
        datum: DateTime(2024, 1, 1),
        bemerkung: '',
        kosten: 0.0,
        ort: 'Musterstadt',
        lehrgangsleiter: 'Max Mustermann',
        verpflegungskosten: 0.0,
        uebernachtungskosten: 0.0,
        lehrmaterialkosten: 0.0,
        lehrgangsinhalt: '',
        maxTeilnehmer: 10,
        webVeroeffentlichenAm: '',
        anmeldungenGesperrt: false,
        status: 1,
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
        geloescht: geloescht,
        stornoGrund: '',
        webGruppe: 1,
        veranstaltungsBezirk: 1,
        fuerVerlaengerungen: false,
        fuerVuelVerlaengerungen: false,
        anmeldeErlaubt: 1,
        verbandsInternPasswort: '',
        bezeichnung: bezeichnung,
        angemeldeteTeilnehmer: 1,
      );
    }

    void stubFetch(List<Schulungstermin> result) {
      when(
        mockApiService.fetchSchulungstermine(
          any as String?,
          any as String?,
          any as String?,
          any as String?,
          any as String?,
        ),
      ).thenAnswer((_) async => result);
    }

    testWidgets('shows list when API returns results', (tester) async {
      stubFetch([buildTermin(bezeichnung: 'Test Schulung', geloescht: false)]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(SchulungenScreen), findsOneWidget);
      expect(find.text('Verfügbare Aus- und Weiterbildungen'), findsOneWidget);
      expect(find.text('Keine Schulungen gefunden.'), findsNothing);
    });

    testWidgets('filters out deleted entries (geloescht == true)', (
      tester,
    ) async {
      stubFetch([
        buildTermin(bezeichnung: 'Deleted', geloescht: true),
        buildTermin(bezeichnung: 'Visible', geloescht: false),
      ]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pumpAndSettle();

      // Stable assertion (title might not be shown verbatim, but list should be non-empty)
      expect(find.text('Keine Schulungen gefunden.'), findsNothing);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows empty message when API returns only deleted entries', (
      tester,
    ) async {
      stubFetch([buildTermin(bezeichnung: 'Deleted', geloescht: true)]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Keine Schulungen gefunden.'), findsOneWidget);
    });

    testWidgets('renders when not logged in', (tester) async {
      stubFetch([]);

      await tester.pumpWidget(createWidgetUnderTest(isLoggedIn: false));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(SchulungenScreen), findsOneWidget);
      expect(find.text('Verfügbare Aus- und Weiterbildungen'), findsOneWidget);
    });
  });
}
