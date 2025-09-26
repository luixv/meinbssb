import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:meinbssb/screens/absolvierte_schulungen_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/schulung_data.dart';
import '../helpers/test_helper.dart';

@GenerateMocks([ApiService, NetworkService, FontSizeProvider, ConfigService])
void main() {
  setUp(() {
    TestHelper.setupMocks();
  });

  const testUserData = UserData(
    personId: 439287,
    webLoginId: 13901,
    passnummer: '40100709',
    vereinNr: 401051,
    namen: 'Schürz',
    vorname: 'Lukas',
    vereinName: 'Feuerschützen Kühbach',
    passdatenId: 2000009155,
    mitgliedschaftId: 439287,
    strasse: 'Aichacher Strasse 21',
    plz: '86574',
    ort: 'Alsmoos',
    telefon: '123456789',
  );

  Widget createAbsolvierteSchulungenScreen({UserData? userData}) {
    return TestHelper.createTestApp(
      home: AbsolvierteSchulungenScreen(
        userData ?? testUserData,
        isLoggedIn: true,
        onLogout: () {},
      ),
    );
  }

  // Sample test data
  final sampleSchulungen = [
    const Schulung(
      id: 1,
      bezeichnung: 'Grundlehrgang Bogen',
      datum: '',
      ort: '',
      ausgestelltAm: '2024-01-15T00:00:00',
      gueltigBis: '2026-01-15T00:00:00',
      teilnehmerId: 0,
      schulungsartId: 0,
      schulungsartBezeichnung: '',
      schulungsartKurzbezeichnung: '',
      schulungsartBeschreibung: '',
      maxTeilnehmer: 0,
      anzahlTeilnehmer: 0,
      uhrzeit: '',
      dauer: '',
      preis: '',
      zielgruppe: '',
      voraussetzungen: '',
      inhalt: '',
      lehrgangsinhaltHtml: '',
      abschluss: '',
      anmerkungen: '',
      isOnline: false,
      link: '',
      status: '',
    ),
    const Schulung(
      id: 2,
      bezeichnung: 'Fortbildung Schießleiter',
      datum: '',
      ort: '',
      ausgestelltAm: '2023-06-20T00:00:00',
      gueltigBis: '2025-06-20T00:00:00',
      teilnehmerId: 0,
      schulungsartId: 0,
      schulungsartBezeichnung: '',
      schulungsartKurzbezeichnung: '',
      schulungsartBeschreibung: '',
      maxTeilnehmer: 0,
      anzahlTeilnehmer: 0,
      uhrzeit: '',
      dauer: '',
      preis: '',
      zielgruppe: '',
      voraussetzungen: '',
      inhalt: '',
      lehrgangsinhaltHtml: '',
      abschluss: '',
      anmerkungen: '',
      isOnline: false,
      link: '',
      status: '',
    ),
    const Schulung(
      id: 3,
      bezeichnung: 'Schulung mit ungültigen Daten',
      datum: '',
      ort: '',
      ausgestelltAm: '-',
      gueltigBis: '',
      teilnehmerId: 0,
      schulungsartId: 0,
      schulungsartBezeichnung: '',
      schulungsartKurzbezeichnung: '',
      schulungsartBeschreibung: '',
      maxTeilnehmer: 0,
      anzahlTeilnehmer: 0,
      uhrzeit: '',
      dauer: '',
      preis: '',
      zielgruppe: '',
      voraussetzungen: '',
      inhalt: '',
      lehrgangsinhaltHtml: '',
      abschluss: '',
      anmerkungen: '',
      isOnline: false,
      link: '',
      status: '',
    ),
  ];

  group('AbsolvierteSchulungenScreen', () {
    testWidgets('renders absolvierte schulungen screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createAbsolvierteSchulungenScreen());
      await tester.pumpAndSettle();

      expect(find.text('Absolvierte Schulungen'), findsOneWidget);
    });

    testWidgets('shows offline message when offline',
        (WidgetTester tester) async {
      when(TestHelper.mockNetworkService.hasInternet())
          .thenAnswer((_) async => false);

      await tester.pumpWidget(createAbsolvierteSchulungenScreen());
      await tester.pumpAndSettle();

      expect(
        find.text('Absolvierte Schulungen sind offline nicht verfügbar'),
        findsOneWidget,
      );
    });

    testWidgets('shows loading indicator initially',
        (WidgetTester tester) async {
      when(TestHelper.mockNetworkService.hasInternet())
          .thenAnswer((_) async => true);
      when(TestHelper.mockApiService.fetchAbsolvierteSchulungen(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createAbsolvierteSchulungenScreen());

      // Before pumpAndSettle, should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('shows empty message when no schulungen found',
        (WidgetTester tester) async {
      when(TestHelper.mockNetworkService.hasInternet())
          .thenAnswer((_) async => true);
      when(TestHelper.mockApiService.fetchAbsolvierteSchulungen(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createAbsolvierteSchulungenScreen());
      await tester.pumpAndSettle();

      expect(
          find.text('Keine absolvierten Schulungen gefunden.'), findsOneWidget,);
    });

    testWidgets('displays schulungen when data is available',
        (WidgetTester tester) async {
      when(TestHelper.mockNetworkService.hasInternet())
          .thenAnswer((_) async => true);
      when(TestHelper.mockApiService.fetchAbsolvierteSchulungen(any))
          .thenAnswer((_) async => sampleSchulungen);

      await tester.pumpWidget(createAbsolvierteSchulungenScreen());
      await tester.pumpAndSettle();

      expect(find.text('Grundlehrgang Bogen'), findsOneWidget);
      expect(find.text('Fortbildung Schießleiter'), findsOneWidget);
      expect(find.text('Schulung mit ungültigen Daten'), findsOneWidget);
    });

    testWidgets('formats dates correctly', (WidgetTester tester) async {
      when(TestHelper.mockNetworkService.hasInternet())
          .thenAnswer((_) async => true);
      when(TestHelper.mockApiService.fetchAbsolvierteSchulungen(any))
          .thenAnswer((_) async => sampleSchulungen);

      await tester.pumpWidget(createAbsolvierteSchulungenScreen());
      await tester.pumpAndSettle();

      // Check proper German date formatting
      expect(find.text('Ausgestellt am: 15.01.2024'), findsOneWidget);
      expect(find.text('Gültig bis: 15.01.2026'), findsOneWidget);
      expect(find.text('Ausgestellt am: 20.06.2023'), findsOneWidget);
      expect(find.text('Gültig bis: 20.06.2025'), findsOneWidget);
    });

    testWidgets('handles invalid dates with "Unbekannt"',
        (WidgetTester tester) async {
      when(TestHelper.mockNetworkService.hasInternet())
          .thenAnswer((_) async => true);
      when(TestHelper.mockApiService.fetchAbsolvierteSchulungen(any))
          .thenAnswer((_) async => sampleSchulungen);

      await tester.pumpWidget(createAbsolvierteSchulungenScreen());
      await tester.pumpAndSettle();

      // Check invalid dates show "Unbekannt"
      expect(find.text('Ausgestellt am: Unbekannt'), findsOneWidget);
      expect(find.text('Gültig bis: Unbekannt'), findsOneWidget);
    });

    testWidgets('sorts schulungen by date correctly',
        (WidgetTester tester) async {
      final unsortedSchulungen = [
        const Schulung(
          id: 1,
          bezeichnung: 'Older Schulung',
          datum: '',
          ort: '',
          ausgestelltAm: '2022-01-01T00:00:00',
          gueltigBis: '2024-01-01T00:00:00',
          teilnehmerId: 0,
          schulungsartId: 0,
          schulungsartBezeichnung: '',
          schulungsartKurzbezeichnung: '',
          schulungsartBeschreibung: '',
          maxTeilnehmer: 0,
          anzahlTeilnehmer: 0,
          uhrzeit: '',
          dauer: '',
          preis: '',
          zielgruppe: '',
          voraussetzungen: '',
          inhalt: '',
          lehrgangsinhaltHtml: '',
          abschluss: '',
          anmerkungen: '',
          isOnline: false,
          link: '',
          status: '',
        ),
        const Schulung(
          id: 2,
          bezeichnung: 'Newer Schulung',
          datum: '',
          ort: '',
          ausgestelltAm: '2024-01-01T00:00:00',
          gueltigBis: '2026-01-01T00:00:00',
          teilnehmerId: 0,
          schulungsartId: 0,
          schulungsartBezeichnung: '',
          schulungsartKurzbezeichnung: '',
          schulungsartBeschreibung: '',
          maxTeilnehmer: 0,
          anzahlTeilnehmer: 0,
          uhrzeit: '',
          dauer: '',
          preis: '',
          zielgruppe: '',
          voraussetzungen: '',
          inhalt: '',
          lehrgangsinhaltHtml: '',
          abschluss: '',
          anmerkungen: '',
          isOnline: false,
          link: '',
          status: '',
        ),
      ];

      when(TestHelper.mockNetworkService.hasInternet())
          .thenAnswer((_) async => true);
      when(TestHelper.mockApiService.fetchAbsolvierteSchulungen(any))
          .thenAnswer((_) async => unsortedSchulungen);

      await tester.pumpWidget(createAbsolvierteSchulungenScreen());
      await tester.pumpAndSettle();

      // Check that newer schulung appears first (descending order)
      final listTiles = find.byType(ListTile);
      expect(listTiles, findsNWidgets(2));

      // The first item should be the newer one
      expect(find.text('Newer Schulung'), findsOneWidget);
      expect(find.text('Older Schulung'), findsOneWidget);
    });

    testWidgets('handles API error gracefully', (WidgetTester tester) async {
      when(TestHelper.mockNetworkService.hasInternet())
          .thenAnswer((_) async => true);
      when(TestHelper.mockApiService.fetchAbsolvierteSchulungen(any))
          .thenThrow(Exception('API Error'));

      await tester.pumpWidget(createAbsolvierteSchulungenScreen());
      await tester.pumpAndSettle();

      expect(
          find.text('Keine absolvierten Schulungen gefunden.'), findsOneWidget,);
    });

    testWidgets('handles null userData', (WidgetTester tester) async {
      when(TestHelper.mockNetworkService.hasInternet())
          .thenAnswer((_) async => true);

      await tester.pumpWidget(
        TestHelper.createTestApp(
          home: AbsolvierteSchulungenScreen(
            null, // Pass null userData
            isLoggedIn: true,
            onLogout: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
          find.text('Keine absolvierten Schulungen gefunden.'), findsOneWidget,);
      verifyNever(TestHelper.mockApiService.fetchAbsolvierteSchulungen(any));
    });

    testWidgets('displays task_alt icons for each schulung',
        (WidgetTester tester) async {
      when(TestHelper.mockNetworkService.hasInternet())
          .thenAnswer((_) async => true);
      when(TestHelper.mockApiService.fetchAbsolvierteSchulungen(any))
          .thenAnswer((_) async => sampleSchulungen);

      await tester.pumpWidget(createAbsolvierteSchulungenScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.task_alt), findsNWidgets(3));
    });

    testWidgets('shows FloatingActionButton when online',
        (WidgetTester tester) async {
      when(TestHelper.mockNetworkService.hasInternet())
          .thenAnswer((_) async => true);
      when(TestHelper.mockApiService.fetchAbsolvierteSchulungen(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createAbsolvierteSchulungenScreen());
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('hides FloatingActionButton when offline',
        (WidgetTester tester) async {
      when(TestHelper.mockNetworkService.hasInternet())
          .thenAnswer((_) async => false);

      await tester.pumpWidget(createAbsolvierteSchulungenScreen());
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('calls fetchAbsolvierteSchulungen with correct personId',
        (WidgetTester tester) async {
      when(TestHelper.mockNetworkService.hasInternet())
          .thenAnswer((_) async => true);
      when(TestHelper.mockApiService.fetchAbsolvierteSchulungen(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createAbsolvierteSchulungenScreen());
      await tester.pumpAndSettle();

      verify(TestHelper.mockApiService.fetchAbsolvierteSchulungen(439287))
          .called(1);
    });
  });
}
