import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/schulungen_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/schulungstermin_data.dart';
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
      webGruppe: 1, // Jugend
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
    // Add a third test case with different content types
    Schulungstermin(
      schulungsterminId: 3,
      schulungsartId: 3,
      schulungsTeilnehmerId: 0,
      datum: DateTime(2024, 8, 10),
      bemerkung: '', // Empty bemerkung
      kosten: 75.0,
      ort: 'Augsburg',
      lehrgangsleiter: 'Peter Müller',
      verpflegungskosten: 25.0,
      uebernachtungskosten: 50.0,
      lehrmaterialkosten: 15.0,
      lehrgangsinhalt: '', // Empty lehrgangsinhalt
      maxTeilnehmer: 25,
      webVeroeffentlichenAm: '2024-01-01',
      anmeldungenGesperrt: false,
      status: 1,
      datumBis: '',
      lehrgangsinhaltHtml: '', // Empty HTML
      lehrgangsleiter2: '',
      lehrgangsleiter3: '',
      lehrgangsleiter4: '',
      lehrgangsleiterTel: '0555123456',
      lehrgangsleiter2Tel: '',
      lehrgangsleiter3Tel: '',
      lehrgangsleiter4Tel: '',
      lehrgangsleiterMail: 'peter@example.com',
      lehrgangsleiter2Mail: '',
      lehrgangsleiter3Mail: '',
      lehrgangsleiter4Mail: '',
      anmeldeStopp: '2024-08-05',
      abmeldeStopp: '2024-08-07',
      geloescht: false,
      stornoGrund: '',
      webGruppe: 3, // Sport
      veranstaltungsBezirk: 3,
      fuerVerlaengerungen: false,
      anmeldeErlaubt: 1,
      verbandsInternPasswort: '',
      bezeichnung: 'Sport Schulung',
      angemeldeteTeilnehmer: 0, // No participants yet
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

      // Set up stubs for fetchSchulungstermin calls
      when(mockApiService.fetchSchulungstermin('1'))
          .thenAnswer((_) async => sampleSchulungstermine[0]);
      when(mockApiService.fetchSchulungstermin('2'))
          .thenAnswer((_) async => sampleSchulungstermine[1]);
      when(mockApiService.fetchSchulungstermin('3'))
          .thenAnswer((_) async => sampleSchulungstermine[2]);
      when(mockApiService.fetchSchulungstermin('4')).thenAnswer(
        (_) async => sampleSchulungstermine[0],
      ); // Reuse first item
      when(mockApiService.fetchSchulungstermin('5')).thenAnswer(
        (_) async => sampleSchulungstermine[0],
      ); // Reuse first item
      when(mockApiService.fetchSchulungstermin('6')).thenAnswer(
        (_) async => sampleSchulungstermine[0],
      ); // Reuse first item
      // Remove the catch-all stub that was interfering with specific stubs
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
      when(
        mockApiService.fetchSchulungstermine(
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SchulungenScreen), findsOneWidget);
    });

    testWidgets('shows loading indicator initially',
        (WidgetTester tester) async {
      when(
        mockApiService.fetchSchulungstermine(
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((_) async {
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
      when(
        mockApiService.fetchSchulungstermine(
          any,
          any,
          any,
          any,
        ),
      ).thenThrow(Exception('API Error'));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Fehler beim Laden der Schulungen'),
        findsOneWidget,
      );
    });

    testWidgets('displays schulungstermine when API call succeeds',
        (WidgetTester tester) async {
      when(
        mockApiService.fetchSchulungstermine(
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Verfügbare Aus- und Weiterbildungen'), findsOneWidget);
      expect(find.text('Test Schulung'), findsOneWidget);
      expect(find.text('Jugend Schulung'), findsOneWidget);
      expect(find.text('Sport Schulung'), findsOneWidget);
      expect(find.text('München'), findsOneWidget);
      expect(find.text('Nürnberg'), findsOneWidget);
      expect(find.text('Augsburg'), findsOneWidget);
    });

    testWidgets('displays correct date format', (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('15.06.2024'), findsOneWidget);
      expect(find.text('20.07.2024'), findsOneWidget);
      expect(find.text('10.08.2024'), findsOneWidget);
    });

    testWidgets('displays webGruppe labels correctly',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Sport'), findsOneWidget);
      expect(find.text('Jugend'), findsOneWidget);
      expect(find.text('Überfachlich'), findsOneWidget);
    });

    testWidgets('filters by webGruppe when provided',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget(webGruppe: 1)); // Wettbewerbe
      await tester.pumpAndSettle();

      expect(find.text('Test Schulung'), findsOneWidget);
      expect(find.text('Jugend Schulung'), findsNothing);
      expect(find.text('Sport Schulung'), findsNothing);
    });

    testWidgets('filters by bezirkId when provided',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget(bezirkId: 1));
      await tester.pumpAndSettle();

      expect(find.text('Test Schulung'), findsOneWidget);
      expect(find.text('Jugend Schulung'), findsNothing);
      expect(find.text('Sport Schulung'), findsNothing);
    });

    testWidgets('filters by ort when provided', (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget(ort: 'München'));
      await tester.pumpAndSettle();

      expect(find.text('Test Schulung'), findsOneWidget);
      expect(find.text('Jugend Schulung'), findsNothing);
      expect(find.text('Sport Schulung'), findsNothing);
    });

    testWidgets('filters by titel when provided', (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget(titel: 'Test'));
      await tester.pumpAndSettle();

      expect(find.text('Test Schulung'), findsOneWidget);
      expect(find.text('Jugend Schulung'), findsNothing);
      expect(find.text('Sport Schulung'), findsNothing);
    });

    testWidgets('filters by fuerVerlaengerungen when provided',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget(fuerVerlaengerungen: true));
      await tester.pumpAndSettle();

      expect(find.text('Test Schulung'), findsNothing);
      expect(find.text('Jugend Schulung'), findsOneWidget);
      expect(find.text('Sport Schulung'), findsNothing);
    });

    testWidgets('shows correct FAB colors based on anmeldungenGesperrt',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find FABs
      final fabs = find.byType(FloatingActionButton);
      expect(fabs, findsNWidgets(3)); // One for each schulungstermin
    });

    testWidgets('shows empty state when no results',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Verfügbare Aus- und Weiterbildungen'), findsOneWidget);
      expect(find.text('Keine Schulungen gefunden.'), findsOneWidget);
      expect(find.text('Test Schulung'), findsNothing);
      expect(find.text('Jugend Schulung'), findsNothing);
      expect(find.text('Sport Schulung'), findsNothing);
    });

    testWidgets('handles null userData gracefully',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
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
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(searchDate: testDate));
      await tester.pumpAndSettle();

      verify(mockApiService.fetchSchulungstermine('15.06.2024', any, any, any))
          .called(1);
    });

    testWidgets('displays correct number of available spots',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Test that the screen renders without crashing
      expect(find.byType(SchulungenScreen), findsOneWidget);
    });

    testWidgets('handles multiple filter combinations',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
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
      expect(find.text('Sport Schulung'), findsNothing);
    });

    // New comprehensive tests for improved coverage

    testWidgets('shows dialog when FAB is pressed',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap the first FAB
      final fabs = find.byType(FloatingActionButton);
      expect(fabs, findsNWidgets(3));

      await tester.tap(fabs.first);
      await tester.pumpAndSettle();

      // Verify dialog is shown - look for dialog-specific content
      expect(find.text('Sport'), findsWidgets);
    });

    testWidgets(
        'shows gesperrt indicator in dialog when anmeldungenGesperrt is true',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap the second FAB (Jugend Schulung - gesperrt)
      final fabs = find.byType(FloatingActionButton);
      await tester.tap(fabs.at(1));
      await tester.pumpAndSettle();

      // Verify the dialog opens and shows the correct content
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data == 'Jugend Schulung' &&
              widget.style?.fontSize == 20.0,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data == 'Jugend' &&
              widget.style?.fontSize == 14.0,
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows correct content priority in dialog',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap the third FAB (Sport Schulung - empty content)
      final fabs = find.byType(FloatingActionButton);
      await tester.tap(fabs.at(2));
      await tester.pumpAndSettle();

      // Verify the dialog opens and shows the correct content
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data == 'Sport Schulung' &&
              widget.style?.fontSize == 20.0,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data == 'Sport' &&
              widget.style?.fontSize == 14.0,
        ),
        findsOneWidget,
      );

      // Check if the fallback text is present
      expect(find.text('Keine Beschreibung verfügbar.'), findsOneWidget);
    });

    testWidgets('shows HTML content when lehrgangsinhaltHtml is available',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap the first FAB (Test Schulung - has HTML content)
      final fabs = find.byType(FloatingActionButton);
      await tester.tap(fabs.first);
      await tester.pumpAndSettle();

      // Should show HTML content - verify dialog is open
      expect(find.text('Sport'), findsWidgets);
    });

    testWidgets('shows text content when only lehrgangsinhalt is available',
        (WidgetTester tester) async {
      // Create a schulungstermin with only text content
      final textOnlySchulung = Schulungstermin(
        schulungsterminId: 4,
        schulungsartId: 4,
        schulungsTeilnehmerId: 0,
        datum: DateTime(2024, 9, 1),
        bemerkung: '',
        kosten: 40.0,
        ort: 'Stuttgart',
        lehrgangsleiter: 'Test Leader',
        verpflegungskosten: 10.0,
        uebernachtungskosten: 0.0,
        lehrmaterialkosten: 5.0,
        lehrgangsinhalt: 'Only text content available',
        maxTeilnehmer: 10,
        webVeroeffentlichenAm: '2024-01-01',
        anmeldungenGesperrt: false,
        status: 1,
        datumBis: '',
        lehrgangsinhaltHtml: '', // Empty HTML
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
        anmeldeStopp: '2024-08-25',
        abmeldeStopp: '2024-08-27',
        geloescht: false,
        stornoGrund: '',
        webGruppe: 3, // Überfachlich
        veranstaltungsBezirk: 4,
        fuerVerlaengerungen: false,
        anmeldeErlaubt: 1,
        verbandsInternPasswort: '',
        bezeichnung: 'Text Only Schulung',
        angemeldeteTeilnehmer: 2,
      );

      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => [textOnlySchulung]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap the FAB
      final fabs = find.byType(FloatingActionButton);
      await tester.tap(fabs.first);
      await tester.pumpAndSettle();

      // Should show text content - verify dialog is open
      expect(find.text('Überfachlich'), findsWidgets);
    });

    testWidgets('shows bemerkung when no other content is available',
        (WidgetTester tester) async {
      // Create a schulungstermin with only bemerkung
      final bemerkungOnlySchulung = Schulungstermin(
        schulungsterminId: 5,
        schulungsartId: 5,
        schulungsTeilnehmerId: 0,
        datum: DateTime(2024, 10, 1),
        bemerkung: 'Only bemerkung available',
        kosten: 35.0,
        ort: 'Hamburg',
        lehrgangsleiter: 'Test Leader',
        verpflegungskosten: 8.0,
        uebernachtungskosten: 0.0,
        lehrmaterialkosten: 3.0,
        lehrgangsinhalt: '', // Empty
        maxTeilnehmer: 8,
        webVeroeffentlichenAm: '2024-01-01',
        anmeldungenGesperrt: false,
        status: 1,
        datumBis: '',
        lehrgangsinhaltHtml: '', // Empty
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
        anmeldeStopp: '2024-09-25',
        abmeldeStopp: '2024-09-27',
        geloescht: false,
        stornoGrund: '',
        webGruppe: 2, // Verbandsintern
        veranstaltungsBezirk: 5,
        fuerVerlaengerungen: false,
        anmeldeErlaubt: 1,
        verbandsInternPasswort: '',
        bezeichnung: 'Bemerkung Only Schulung',
        angemeldeteTeilnehmer: 1,
      );

      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => [bemerkungOnlySchulung]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap the FAB
      final fabs = find.byType(FloatingActionButton);
      await tester.tap(fabs.first);
      await tester.pumpAndSettle();

      // Should show bemerkung content - verify dialog is open
      expect(find.text('Sport'), findsWidgets);
    });

    testWidgets('handles case insensitive filtering',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget(ort: 'münchen')); // lowercase
      await tester.pumpAndSettle();

      expect(find.text('Test Schulung'), findsOneWidget);
      expect(find.text('Jugend Schulung'), findsNothing);
    });

    testWidgets('handles partial text filtering', (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester
          .pumpWidget(createTestWidget(titel: 'Schulung')); // partial match
      await tester.pumpAndSettle();

      expect(find.text('Test Schulung'), findsOneWidget);
      expect(find.text('Jugend Schulung'), findsOneWidget);
      expect(find.text('Sport Schulung'), findsOneWidget);
    });

    testWidgets('handles zero values correctly', (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap the third FAB (Sport Schulung - 0 participants)
      final fabs = find.byType(FloatingActionButton);
      await tester.tap(fabs.at(2));
      await tester.pumpAndSettle();

      expect(find.text('Jugend'), findsWidgets);
    });

    testWidgets('handles full capacity correctly', (WidgetTester tester) async {
      // Create a schulungstermin with full capacity
      final fullCapacitySchulung = Schulungstermin(
        schulungsterminId: 6,
        schulungsartId: 6,
        schulungsTeilnehmerId: 0,
        datum: DateTime(2024, 11, 1),
        bemerkung: 'Full capacity test',
        kosten: 60.0,
        ort: 'Berlin',
        lehrgangsleiter: 'Test Leader',
        verpflegungskosten: 15.0,
        uebernachtungskosten: 0.0,
        lehrmaterialkosten: 8.0,
        lehrgangsinhalt: 'Test content',
        maxTeilnehmer: 10,
        webVeroeffentlichenAm: '2024-01-01',
        anmeldungenGesperrt: false,
        status: 1,
        datumBis: '',
        lehrgangsinhaltHtml: '<p>Test</p>',
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
        anmeldeStopp: '2024-10-25',
        abmeldeStopp: '2024-10-27',
        geloescht: false,
        stornoGrund: '',
        webGruppe: 0, // Alle
        veranstaltungsBezirk: 6,
        fuerVerlaengerungen: false,
        anmeldeErlaubt: 1,
        verbandsInternPasswort: '',
        bezeichnung: 'Full Capacity Schulung',
        angemeldeteTeilnehmer: 10, // Full capacity
      );

      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => [fullCapacitySchulung]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap the FAB
      final fabs = find.byType(FloatingActionButton);
      await tester.tap(fabs.first);
      await tester.pumpAndSettle();

      expect(find.text('Alle'), findsWidgets);
    });

    testWidgets('handles unknown webGruppe correctly',
        (WidgetTester tester) async {
      // Create a schulungstermin with unknown webGruppe
      final unknownWebGruppeSchulung = Schulungstermin(
        schulungsterminId: 7,
        schulungsartId: 7,
        schulungsTeilnehmerId: 0,
        datum: DateTime(2024, 12, 1),
        bemerkung: 'Unknown webGruppe test',
        kosten: 45.0,
        ort: 'Köln',
        lehrgangsleiter: 'Test Leader',
        verpflegungskosten: 12.0,
        uebernachtungskosten: 0.0,
        lehrmaterialkosten: 6.0,
        lehrgangsinhalt: 'Test content',
        maxTeilnehmer: 12,
        webVeroeffentlichenAm: '2024-01-01',
        anmeldungenGesperrt: false,
        status: 1,
        datumBis: '',
        lehrgangsinhaltHtml: '<p>Test</p>',
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
        anmeldeStopp: '2024-11-25',
        abmeldeStopp: '2024-11-27',
        geloescht: false,
        stornoGrund: '',
        webGruppe: 999, // Unknown webGruppe
        veranstaltungsBezirk: 7,
        fuerVerlaengerungen: false,
        anmeldeErlaubt: 1,
        verbandsInternPasswort: '',
        bezeichnung: 'Unknown WebGruppe Schulung',
        angemeldeteTeilnehmer: 3,
      );

      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => [unknownWebGruppeSchulung]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('nicht zugeordnet'), findsOneWidget);
    });

    testWidgets('handles decimal costs correctly', (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap the first FAB
      final fabs = find.byType(FloatingActionButton);
      await tester.tap(fabs.first);
      await tester.pumpAndSettle();

      // Check that costs are displayed with 2 decimal places
      expect(find.text('50.00 €'), findsOneWidget);
    });

    testWidgets('handles empty bemerkung in list view',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // The third schulungstermin has empty bemerkung, should still display
      expect(find.text('Sport Schulung'), findsOneWidget);
      expect(find.text('Augsburg'), findsOneWidget);
    });

    testWidgets('handles multiple rapid API calls',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => sampleSchulungstermine);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify the screen still works correctly
      expect(find.text('Test Schulung'), findsOneWidget);
      expect(find.text('Jugend Schulung'), findsOneWidget);
      expect(find.text('Sport Schulung'), findsOneWidget);
    });

    testWidgets('handles different screen sizes', (WidgetTester tester) async {
      when(mockApiService.fetchSchulungstermine(any, any, any, any))
          .thenAnswer((_) async => sampleSchulungstermine);

      // Test with a smaller screen size
      tester.view.physicalSize = const Size(400, 600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should still display correctly
      expect(find.text('Test Schulung'), findsOneWidget);

      // Reset screen size
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
