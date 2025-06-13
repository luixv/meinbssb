import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/screens/start_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'start_screen_test.mocks.dart';
import 'package:meinbssb/models/schulung.dart';
import 'package:meinbssb/models/user_data.dart';

// Mock ConfigService para Provider
class MockConfigService extends Mock implements ConfigService {}

@GenerateMocks(
  [ApiService],
  customMocks: [MockSpec<ApiService>(as: #CustomMockApiService)],
)
void main() {
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

  testWidgets('StartScreen displays loading spinner while fetching data',
      (WidgetTester tester) async {
    final mockApiService = CustomMockApiService();

    when(
      mockApiService.fetchAngemeldeteSchulungen(any, any),
    ).thenAnswer(
      (_) async => Future.delayed(const Duration(seconds: 1), () => []),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Provider<ConfigService>(
          create: (_) => MockConfigService(),
          child: Provider<ApiService>(
            create: (_) => mockApiService,
            child: StartScreen(userData, isLoggedIn: true, onLogout: () {}),
          ),
        ),
      ),
    );

    // Mientras espera el resultado, debe mostrar CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    // Luego de cargarse los datos, ya no debe mostrar el spinner
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('StartScreen displays no Schulungen found message when no data',
      (WidgetTester tester) async {
    final mockApiService = CustomMockApiService();

    when(
      mockApiService.fetchAngemeldeteSchulungen(any, any),
    ).thenAnswer((_) async => []);

    await tester.pumpWidget(
      MaterialApp(
        home: Provider<ConfigService>(
          create: (_) => MockConfigService(),
          child: Provider<ApiService>(
            create: (_) => mockApiService,
            child: StartScreen(userData, isLoggedIn: true, onLogout: () {}),
          ),
        ),
      ),
    );

    // Esperamos que se muestre el texto de 'Keine Schulungen gefunden.'
    await tester.pumpAndSettle();
    expect(find.text('Keine Schulungen gefunden.'), findsOneWidget);
  });

  testWidgets('StartScreen displays list of Schulungen when data is present',
      (WidgetTester tester) async {
    final mockApiService = CustomMockApiService();

    when(
      mockApiService.fetchAngemeldeteSchulungen(any, any),
    ).thenAnswer(
      (_) async => [
        const Schulung(
          id: 1,
          bezeichnung: 'Training 1',
          datum: '2023-01-15',
          ausgestelltAm: '2023-01-01',
          teilnehmerId: 1,
          schulungsartId: 1,
          schulungsartBezeichnung: 'Basic',
          schulungsartKurzbezeichnung: 'BSC',
          schulungsartBeschreibung: 'Basic Training Course',
          maxTeilnehmer: 20,
          anzahlTeilnehmer: 10,
          ort: 'Location 1',
          uhrzeit: '09:00',
          dauer: '8 Stunden',
          preis: '100€',
          zielgruppe: 'Anfänger',
          voraussetzungen: 'Keine',
          inhalt: 'Grundlagen',
          abschluss: 'Zertifikat',
          anmerkungen: 'Bitte mitbringen: Schreibzeug',
          isOnline: false,
          link: '',
          status: 'Aktiv',
          gueltigBis: '2023-12-31',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Provider<ConfigService>(
          create: (_) => MockConfigService(),
          child: Provider<ApiService>(
            create: (_) => mockApiService,
            child: StartScreen(userData, isLoggedIn: true, onLogout: () {}),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verificamos que los nombres de las Schulungen estén en pantalla
    expect(find.text('Training 1'), findsOneWidget);

    // También que el texto de 'Keine Schulungen gefunden.' no está
    expect(find.text('Keine Schulungen gefunden.'), findsNothing);
  });
}
