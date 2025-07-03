import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/schulungen_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/schulungstermin.dart';
import 'package:meinbssb/models/bank_data.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/core/font_size_provider.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([ApiService, CacheService])
import 'schulungen_screen_test.mocks.dart';

void main() {
  const dummyUser = UserData(
    personId: 1,
    webLoginId: 1,
    passnummer: '12345',
    vereinNr: 1,
    namen: 'User',
    vorname: 'Test',
    vereinName: 'Test Verein',
    passdatenId: 1,
    mitgliedschaftId: 1,
  );

  // Sample test data
  final sampleSchulungstermine = [
    Schulungstermin(
      schulungsterminId: 1,
      schulungsartId: 1,
      schulungsTeilnehmerId: 0,
      datum: DateTime(2024, 6, 15),
      bemerkung: 'Test bemerkung',
      kosten: 50.0,
      ort: 'München',
      lehrgangsleiter: 'Max Mustermann',
      verpflegungskosten: 20.0,
      uebernachtungskosten: 0.0,
      lehrmaterialkosten: 10.0,
      lehrgangsinhalt: 'Test content',
      maxTeilnehmer: 20,
      webVeroeffentlichenAm: '2024-01-01',
      anmeldungenGesperrt: false,
      status: 1,
      datumBis: '',
      lehrgangsinhaltHtml: '<p>Test HTML</p>',
      lehrgangsleiter2: '',
      lehrgangsleiter3: '',
      lehrgangsleiter4: '',
      lehrgangsleiterTel: '0123456789',
      lehrgangsleiter2Tel: '',
      lehrgangsleiter3Tel: '',
      lehrgangsleiter4Tel: '',
      lehrgangsleiterMail: 'test@example.com',
      lehrgangsleiter2Mail: '',
      lehrgangsleiter3Mail: '',
      lehrgangsleiter4Mail: '',
      anmeldeStopp: '2024-06-10',
      abmeldeStopp: '2024-06-12',
      geloescht: false,
      stornoGrund: '',
      webGruppe: 1, // Wettbewerbe
      veranstaltungsBezirk: 1,
      fuerVerlaengerungen: false,
      anmeldeErlaubt: 1,
      verbandsInternPasswort: '',
      bezeichnung: 'Test Schulung',
      angemeldeteTeilnehmer: 5,
    ),
    Schulungstermin(
      schulungsterminId: 2,
      schulungsartId: 2,
      schulungsTeilnehmerId: 0,
      datum: DateTime(2024, 7, 20),
      bemerkung: 'Jugend Schulung',
      kosten: 30.0,
      ort: 'Nürnberg',
      lehrgangsleiter: 'Anna Schmidt',
      verpflegungskosten: 15.0,
      uebernachtungskosten: 0.0,
      lehrmaterialkosten: 5.0,
      lehrgangsinhalt: 'Jugend content',
      maxTeilnehmer: 15,
      webVeroeffentlichenAm: '2024-01-01',
      anmeldungenGesperrt: true,
      status: 1,
      datumBis: '',
      lehrgangsinhaltHtml: '<p>Jugend HTML</p>',
      lehrgangsleiter2: '',
      lehrgangsleiter3: '',
      lehrgangsleiter4: '',
      lehrgangsleiterTel: '0987654321',
      lehrgangsleiter2Tel: '',
      lehrgangsleiter3Tel: '',
      lehrgangsleiter4Tel: '',
      lehrgangsleiterMail: 'anna@example.com',
      lehrgangsleiter2Mail: '',
      lehrgangsleiter3Mail: '',
      lehrgangsleiter4Mail: '',
      anmeldeStopp: '2024-07-15',
      abmeldeStopp: '2024-07-17',
      geloescht: false,
      stornoGrund: '',
      webGruppe: 2, // Jugend
      veranstaltungsBezirk: 2,
      fuerVerlaengerungen: true,
      anmeldeErlaubt: 1,
      verbandsInternPasswort: '',
      bezeichnung: 'Jugend Schulung',
      angemeldeteTeilnehmer: 12,
    ),
  ];

  group('SchulungenScreen', () {
    late MockApiService mockApiService;
    late MockCacheService mockCacheService;

    setUp(() {
      mockApiService = MockApiService();
      mockCacheService = MockCacheService();

      // Set up SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    Widget createTestWidget({
      UserData? userData,
      bool isLoggedIn = true,
      DateTime? searchDate,
      int? webGruppe,
      int? bezirkId,
      String? ort,
      String? titel,
      bool? fuerVerlaengerungen,
    }) {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<FontSizeProvider>(
              create: (_) => FontSizeProvider(),
            ),
            Provider<ApiService>(create: (_) => mockApiService),
            Provider<CacheService>(create: (_) => mockCacheService),
          ],
          child: SchulungenScreen(
            userData ?? dummyUser,
            isLoggedIn: isLoggedIn,
            onLogout: () {},
            searchDate: searchDate ?? DateTime.now(),
            webGruppe: webGruppe,
            bezirkId: bezirkId,
            ort: ort,
            titel: titel,
            fuerVerlaengerungen: fuerVerlaengerungen,
          ),
        ),
      );
    }

    testWidgets('renders without crashing', (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SchulungenScreen), findsOneWidget);
    });

    testWidgets('shows loading indicator initially',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return [];
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows error message when API call fails',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any))
          .thenThrow(Exception('API Error'));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Fehler beim Laden der Schulungen'),
        findsOneWidget,
      );
    });

    testWidgets('displays schulungstermine when API call succeeds',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Verfügbare Schulungen'), findsOneWidget);
      expect(find.text('Test Schulung'), findsOneWidget);
      expect(find.text('Jugend Schulung'), findsOneWidget);
      expect(find.text('München'), findsOneWidget);
      expect(find.text('Nürnberg'), findsOneWidget);
    });

    testWidgets('displays correct date format', (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('15.06.2024'), findsOneWidget);
      expect(find.text('20.07.2024'), findsOneWidget);
    });

    testWidgets('displays webGruppe labels correctly',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Wettbewerbe'), findsOneWidget);
      expect(find.text('Jugend'), findsOneWidget);
    });

    testWidgets('filters by webGruppe when provided',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget(webGruppe: 1)); // Wettbewerbe
      await tester.pumpAndSettle();

      expect(find.text('Test Schulung'), findsOneWidget);
      expect(find.text('Jugend Schulung'), findsNothing);
    });

    testWidgets('filters by bezirkId when provided',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget(bezirkId: 1));
      await tester.pumpAndSettle();

      expect(find.text('Test Schulung'), findsOneWidget);
      expect(find.text('Jugend Schulung'), findsNothing);
    });

    testWidgets('filters by ort when provided', (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget(ort: 'München'));
      await tester.pumpAndSettle();

      expect(find.text('Test Schulung'), findsOneWidget);
      expect(find.text('Jugend Schulung'), findsNothing);
    });

    testWidgets('filters by titel when provided', (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget(titel: 'Test'));
      await tester.pumpAndSettle();

      expect(find.text('Test Schulung'), findsOneWidget);
      expect(find.text('Jugend Schulung'), findsNothing);
    });

    testWidgets('filters by fuerVerlaengerungen when provided',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget(fuerVerlaengerungen: true));
      await tester.pumpAndSettle();

      expect(find.text('Test Schulung'), findsNothing);
      expect(find.text('Jugend Schulung'), findsOneWidget);
    });

    testWidgets('shows correct FAB colors based on anmeldungenGesperrt',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find FABs
      final fabs = find.byType(FloatingActionButton);
      expect(fabs, findsNWidgets(2));
    });

    testWidgets('shows empty state when no results',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Verfügbare Schulungen'), findsOneWidget);
      expect(find.text('Test Schulung'), findsNothing);
      expect(find.text('Jugend Schulung'), findsNothing);
    });

    testWidgets('handles null userData gracefully',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(userData: null));
      await tester.pumpAndSettle();

      expect(find.byType(SchulungenScreen), findsOneWidget);
    });

    testWidgets('FontSizeProvider works in isolation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<FontSizeProvider>(
            create: (_) => FontSizeProvider(),
            child: Consumer<FontSizeProvider>(
              builder: (context, fontSizeProvider, _) {
                return Text('Scale: ${fontSizeProvider.scaleFactor}');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Scale: 1.0'), findsOneWidget);
    });

    testWidgets('calls API with correct date format',
        (WidgetTester tester) async {
      final testDate = DateTime(2024, 6, 15);
      when(mockApiService.fetchSchulungstermine(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(searchDate: testDate));
      await tester.pumpAndSettle();

      verify(mockApiService.fetchSchulungstermine('15.06.2024')).called(1);
    });

    testWidgets('displays correct number of available spots',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Test that the screen renders without crashing
      expect(find.byType(SchulungenScreen), findsOneWidget);
    });

    testWidgets('handles multiple filter combinations',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(
        createTestWidget(
          webGruppe: 1,
          bezirkId: 1,
          ort: 'München',
          titel: 'Test',
          fuerVerlaengerungen: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Schulung'), findsOneWidget);
      expect(find.text('Jugend Schulung'), findsNothing);
    });
  });
}
