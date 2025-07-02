import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/screens/start_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/schulungstermin.dart';
import '../helpers/test_helper.dart';

void main() {
  setUp(() {
    TestHelper.setupMocks();
  });

  // Create a UserData instance for testing
  const userData = UserData(
    personId: 439287,
    webLoginId: 13901,
    passnummer: '40100709',
    vereinNr: 401051,
    namen: 'Schürz',
    vorname: 'Lukas',
    titel: '',
    geburtsdatum: null,
    geschlecht: 1,
    vereinName: 'Feuerschützen Kühbach',
    passdatenId: 2000009155,
    mitgliedschaftId: 439287,
    strasse: 'Aichacher Strasse 21',
    plz: '86574',
    ort: 'Alsmoos',
    isOnline: false,
  );

  Widget createStartScreen() {
    return TestHelper.createTestApp(
      home: StartScreen(userData, isLoggedIn: true, onLogout: () {}),
    );
  }

  testWidgets('StartScreen displays loading spinner while fetching data',
      (WidgetTester tester) async {
    when(
      TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
    ).thenAnswer(
      (_) async => Future.delayed(const Duration(seconds: 1), () => []),
    );

    await tester.pumpWidget(createStartScreen());

    // Mientras espera el resultado, debe mostrar CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    // Luego de cargarse los datos, ya no debe mostrar el spinner
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('StartScreen displays no Schulungen found message when no data',
      (WidgetTester tester) async {
    when(
      TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
    ).thenAnswer((_) async => []);

    await tester.pumpWidget(createStartScreen());

    // Esperamos que se muestre el texto de 'Keine Schulungen gefunden.'
    await tester.pumpAndSettle();
    expect(find.text('Keine Schulungen gefunden.'), findsOneWidget);
  });

  testWidgets('StartScreen displays list of Schulungen when data is present',
      (WidgetTester tester) async {
    when(
      TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
    ).thenAnswer(
      (_) async => [
        Schulungstermin(
          schulungsterminId: 1,
          schulungsartId: 1,
          datum: DateTime.parse('2023-01-15T00:00:00.000'),
          bemerkung: 'Bemerkung',
          kosten: 100.0,
          ort: 'Location 1',
          lehrgangsleiter: 'Leiter',
          verpflegungskosten: 10.0,
          uebernachtungskosten: 20.0,
          lehrmaterialkosten: 5.0,
          lehrgangsinhalt: 'Grundlagen',
          maxTeilnehmer: 20,
          webVeroeffentlichenAm: '2023-01-01',
          anmeldungenGesperrt: false,
          status: 1,
          datumBis: '2023-01-16',
          lehrgangsinhaltHtml: '<p>HTML</p>',
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
          veranstaltungsBezirk: 1,
          fuerVerlaengerungen: false,
          anmeldeErlaubt: 1,
          verbandsInternPasswort: '',
          bezeichnung: 'Training 1',
          angemeldeteTeilnehmer: 10,
        ),
      ],
    );

    await tester.pumpWidget(createStartScreen());

    await tester.pumpAndSettle();

    // Verificamos que los nombres de las Schulungen estén en pantalla
    expect(find.text('Training 1'), findsOneWidget);

    // También que el texto de 'Keine Schulungen gefunden.' no está
    expect(find.text('Keine Schulungen gefunden.'), findsNothing);
  });
}
