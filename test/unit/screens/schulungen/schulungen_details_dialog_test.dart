import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:meinbssb/screens/schulungen/schulungen_details_dialog.dart';
import 'package:meinbssb/models/schulungstermin_data.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

import 'schulungen_details_dialog_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  // Initialize Flutter bindings first to avoid zone mismatch
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize German locale data for date formatting
  setUpAll(() async {
    await initializeDateFormatting('de_DE', null);
  });

  group('SchulungenDetailsDialog', () {
    late MockApiService mockApiService;
    late Schulungstermin testTermin;
    late Schulungstermin testOriginalTermin;

    setUp(() {
      mockApiService = MockApiService();
      testTermin = Schulungstermin(
        schulungsterminId: 123,
        schulungsartId: 1,
        schulungsTeilnehmerId: 1,
        bemerkung: 'Test bemerkung',
        kosten: 50.0,
        lehrgangsleiter: 'Hans Müller',
        verpflegungskosten: 10.0,
        uebernachtungskosten: 20.0,
        lehrmaterialkosten: 5.0,
        lehrgangsinhalt: 'Test Lehrgangsinhalt',
        maxTeilnehmer: 20,
        webVeroeffentlichenAm: '2024-01-01',
        status: 1,
        datum: DateTime(2024, 6, 15),
        datumBis: '2024-06-15',
        lehrgangsinhaltHtml: '<p>HTML Lehrgangsinhalt</p>',
        lehrgangsleiter2: '',
        lehrgangsleiter3: '',
        lehrgangsleiter4: '',
        lehrgangsleiterTel: '0123456789',
        lehrgangsleiter2Tel: '',
        lehrgangsleiter3Tel: '',
        lehrgangsleiter4Tel: '',
        lehrgangsleiterMail: 'hans@example.com',
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
        fuerVuelVerlaengerungen: false,
        anmeldeErlaubt: 1,
        verbandsInternPasswort: '',
        bezeichnung: 'Test Schulung',
        angemeldeteTeilnehmer: 5,
        anmeldungenGesperrt: false,
        ort: 'München',
      );

      testOriginalTermin = Schulungstermin(
        schulungsterminId: 124,
        schulungsartId: 1,
        schulungsTeilnehmerId: 1,
        bemerkung: 'Original bemerkung',
        kosten: 50.0,
        lehrgangsleiter: 'Hans Müller',
        verpflegungskosten: 10.0,
        uebernachtungskosten: 20.0,
        lehrmaterialkosten: 5.0,
        lehrgangsinhalt: 'Original Lehrgangsinhalt',
        maxTeilnehmer: 20,
        webVeroeffentlichenAm: '2024-01-01',
        status: 1,
        datum: DateTime(2024, 6, 15),
        datumBis: '2024-06-15',
        lehrgangsinhaltHtml: '<p>Original HTML Lehrgangsinhalt</p>',
        lehrgangsleiter2: '',
        lehrgangsleiter3: '',
        lehrgangsleiter4: '',
        lehrgangsleiterTel: '0123456789',
        lehrgangsleiter2Tel: '',
        lehrgangsleiter3Tel: '',
        lehrgangsleiter4Tel: '',
        lehrgangsleiterMail: 'hans@example.com',
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
        fuerVuelVerlaengerungen: false,
        anmeldeErlaubt: 1,
        verbandsInternPasswort: '',
        bezeichnung: 'Original Schulung Titel',
        angemeldeteTeilnehmer: 5,
        anmeldungenGesperrt: false,
        ort: 'München',
      );
    });

    group('canNotBeBooked', () {
      testWidgets('returns true when anmeldungenGesperrt is true',
          (tester) async {
        final terminWithBlockedRegistration = Schulungstermin(
          schulungsterminId: 123,
          schulungsartId: 1,
          schulungsTeilnehmerId: 1,
          bemerkung: 'Test bemerkung',
          kosten: 50.0,
          lehrgangsleiter: 'Hans Müller',
          verpflegungskosten: 10.0,
          uebernachtungskosten: 20.0,
          lehrmaterialkosten: 5.0,
          lehrgangsinhalt: 'Test Lehrgangsinhalt',
          maxTeilnehmer: 20,
          webVeroeffentlichenAm: '2024-01-01',
          status: 1,
          datum: DateTime(2024, 6, 15),
          datumBis: '2024-06-15',
          lehrgangsinhaltHtml: '<p>HTML Lehrgangsinhalt</p>',
          lehrgangsleiter2: '',
          lehrgangsleiter3: '',
          lehrgangsleiter4: '',
          lehrgangsleiterTel: '0123456789',
          lehrgangsleiter2Tel: '',
          lehrgangsleiter3Tel: '',
          lehrgangsleiter4Tel: '',
          lehrgangsleiterMail: 'hans@example.com',
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
          fuerVuelVerlaengerungen: false,
          anmeldeErlaubt: 1,
          verbandsInternPasswort: '',
          bezeichnung: 'Test Schulung',
          angemeldeteTeilnehmer: 5,
          anmeldungenGesperrt: true, // This is the key difference
          ort: 'München',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Provider<ApiService>.value(
              value: mockApiService,
              child: Builder(
                builder: (context) {
                  return FutureBuilder<bool>(
                    future: SchulungenDetailsDialog.canNotBeBooked(
                      terminWithBlockedRegistration,
                      456,
                      context,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        expect(snapshot.data, isTrue);
                      }
                      return Container();
                    },
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
      });

      testWidgets(
          'returns false when anmeldungenGesperrt is false and personId is 0',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Provider<ApiService>.value(
              value: mockApiService,
              child: Builder(
                builder: (context) {
                  return FutureBuilder<bool>(
                    future: SchulungenDetailsDialog.canNotBeBooked(
                      testTermin,
                      0,
                      context,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        expect(snapshot.data, isFalse);
                      }
                      return Container();
                    },
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
      });

      testWidgets('returns true when person is already registered',
          (tester) async {
        when(mockApiService.isRegisterForThisSchulung(456, 123))
            .thenAnswer((_) async => true);

        await tester.pumpWidget(
          MaterialApp(
            home: Provider<ApiService>.value(
              value: mockApiService,
              child: Builder(
                builder: (context) {
                  return FutureBuilder<bool>(
                    future: SchulungenDetailsDialog.canNotBeBooked(
                      testTermin,
                      456,
                      context,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        expect(snapshot.data, isTrue);
                      }
                      return Container();
                    },
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        verify(mockApiService.isRegisterForThisSchulung(456, 123)).called(1);
      });

      testWidgets('returns false when person is not registered',
          (tester) async {
        when(mockApiService.isRegisterForThisSchulung(456, 123))
            .thenAnswer((_) async => false);

        await tester.pumpWidget(
          MaterialApp(
            home: Provider<ApiService>.value(
              value: mockApiService,
              child: Builder(
                builder: (context) {
                  return FutureBuilder<bool>(
                    future: SchulungenDetailsDialog.canNotBeBooked(
                      testTermin,
                      456,
                      context,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        expect(snapshot.data, isFalse);
                      }
                      return Container();
                    },
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        verify(mockApiService.isRegisterForThisSchulung(456, 123)).called(1);
      });

      testWidgets('returns false when API throws exception', (tester) async {
        when(mockApiService.isRegisterForThisSchulung(456, 123))
            .thenThrow(Exception('API Error'));

        await tester.pumpWidget(
          MaterialApp(
            home: Provider<ApiService>.value(
              value: mockApiService,
              child: Builder(
                builder: (context) {
                  return FutureBuilder<bool>(
                    future: SchulungenDetailsDialog.canNotBeBooked(
                      testTermin,
                      456,
                      context,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        expect(
                          snapshot.data,
                          isFalse,
                        ); // Should allow booking on error
                      }
                      return Container();
                    },
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        verify(mockApiService.isRegisterForThisSchulung(456, 123)).called(1);
      });

      testWidgets('skips API call when personId is negative', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Provider<ApiService>.value(
              value: mockApiService,
              child: Builder(
                builder: (context) {
                  return FutureBuilder<bool>(
                    future: SchulungenDetailsDialog.canNotBeBooked(
                      testTermin,
                      -1,
                      context,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        expect(snapshot.data, isFalse);
                      }
                      return Container();
                    },
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        verifyNever(mockApiService.isRegisterForThisSchulung(any, any));
      });
    });

    group('show dialog', () {
      testWidgets('displays dialog with correct title', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Provider<ApiService>.value(
              value: mockApiService,
              child: Provider<FontSizeProvider>(
                create: (_) => FontSizeProvider(),
                child: Scaffold(
                  body: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        onPressed: () {
                          SchulungenDetailsDialog.show(
                            context,
                            testTermin,
                            testOriginalTermin,
                            lehrgangsleiterMail: 'hans@example.com',
                            lehrgangsleiterTel: '0123456789',
                            onBookingPressed: () {},
                            isUserLoggedIn: true,
                            personId: 456,
                          );
                        },
                        child: const Text('Show Dialog'),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );

        // Tap the button to show dialog
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Verify dialog is displayed with correct title
        expect(find.text('Test Schulung'), findsOneWidget);
      });

      testWidgets('displays original title when termin title is empty',
          (tester) async {
        final terminWithEmptyTitle = Schulungstermin(
          schulungsterminId: 123,
          schulungsartId: 1,
          schulungsTeilnehmerId: 1,
          bemerkung: 'Test bemerkung',
          kosten: 50.0,
          lehrgangsleiter: 'Hans Müller',
          verpflegungskosten: 10.0,
          uebernachtungskosten: 20.0,
          lehrmaterialkosten: 5.0,
          lehrgangsinhalt: 'Test Lehrgangsinhalt',
          maxTeilnehmer: 20,
          webVeroeffentlichenAm: '2024-01-01',
          status: 1,
          datum: DateTime(2024, 6, 15),
          datumBis: '2024-06-15',
          lehrgangsinhaltHtml: '<p>HTML Lehrgangsinhalt</p>',
          lehrgangsleiter2: '',
          lehrgangsleiter3: '',
          lehrgangsleiter4: '',
          lehrgangsleiterTel: '0123456789',
          lehrgangsleiter2Tel: '',
          lehrgangsleiter3Tel: '',
          lehrgangsleiter4Tel: '',
          lehrgangsleiterMail: 'hans@example.com',
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
          fuerVuelVerlaengerungen: false,
          anmeldeErlaubt: 1,
          verbandsInternPasswort: '',
          bezeichnung: '', // Empty title
          angemeldeteTeilnehmer: 5,
          anmeldungenGesperrt: false,
          ort: 'München',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Provider<ApiService>.value(
              value: mockApiService,
              child: Provider<FontSizeProvider>(
                create: (_) => FontSizeProvider(),
                child: Scaffold(
                  body: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        onPressed: () {
                          SchulungenDetailsDialog.show(
                            context,
                            terminWithEmptyTitle,
                            testOriginalTermin,
                            lehrgangsleiterMail: 'hans@example.com',
                            lehrgangsleiterTel: '0123456789',
                            onBookingPressed: () {},
                            isUserLoggedIn: true,
                            personId: 456,
                          );
                        },
                        child: const Text('Show Dialog'),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Original Schulung Titel'), findsOneWidget);
      });

      testWidgets('displays available places correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Provider<ApiService>.value(
              value: mockApiService,
              child: Provider<FontSizeProvider>(
                create: (_) => FontSizeProvider(),
                child: Scaffold(
                  body: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        onPressed: () {
                          SchulungenDetailsDialog.show(
                            context,
                            testTermin,
                            testOriginalTermin,
                            lehrgangsleiterMail: 'hans@example.com',
                            lehrgangsleiterTel: '0123456789',
                            onBookingPressed: () {},
                            isUserLoggedIn: true,
                            personId: 456,
                          );
                        },
                        child: const Text('Show Dialog'),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Check if available places text is displayed (20 max - 5 registered = 15 free)
        expect(
          find.textContaining('Es sind noch 15 von 20 Plätzen frei'),
          findsOneWidget,
        );
      });

      testWidgets('displays course information correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Provider<ApiService>.value(
              value: mockApiService,
              child: Provider<FontSizeProvider>(
                create: (_) => FontSizeProvider(),
                child: Scaffold(
                  body: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        onPressed: () {
                          SchulungenDetailsDialog.show(
                            context,
                            testTermin,
                            testOriginalTermin,
                            lehrgangsleiterMail: 'hans@example.com',
                            lehrgangsleiterTel: '0123456789',
                            onBookingPressed: () {},
                            isUserLoggedIn: true,
                            personId: 456,
                          );
                        },
                        child: const Text('Show Dialog'),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Check location
        expect(find.text('München'), findsOneWidget);
        // Check cost
        expect(find.text('50.00 €'), findsOneWidget);
        // Check instructor email
        expect(find.text('hans@example.com'), findsOneWidget);
        // Check instructor phone
        expect(find.text('0123456789'), findsOneWidget);
      });

      testWidgets('booking button is disabled when registration blocked',
          (tester) async {
        final terminWithBlockedReg = Schulungstermin(
          schulungsterminId: 123,
          schulungsartId: 1,
          schulungsTeilnehmerId: 1,
          bemerkung: 'Test bemerkung',
          kosten: 50.0,
          lehrgangsleiter: 'Hans Müller',
          verpflegungskosten: 10.0,
          uebernachtungskosten: 20.0,
          lehrmaterialkosten: 5.0,
          lehrgangsinhalt: 'Test Lehrgangsinhalt',
          maxTeilnehmer: 20,
          webVeroeffentlichenAm: '2024-01-01',
          status: 1,
          datum: DateTime(2024, 6, 15),
          datumBis: '2024-06-15',
          lehrgangsinhaltHtml: '<p>HTML Lehrgangsinhalt</p>',
          lehrgangsleiter2: '',
          lehrgangsleiter3: '',
          lehrgangsleiter4: '',
          lehrgangsleiterTel: '0123456789',
          lehrgangsleiter2Tel: '',
          lehrgangsleiter3Tel: '',
          lehrgangsleiter4Tel: '',
          lehrgangsleiterMail: 'hans@example.com',
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
          fuerVuelVerlaengerungen: false,
          anmeldeErlaubt: 1,
          verbandsInternPasswort: '',
          bezeichnung: 'Test Schulung',
          angemeldeteTeilnehmer: 5,
          anmeldungenGesperrt: true, // Registration blocked
          ort: 'München',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Provider<ApiService>.value(
              value: mockApiService,
              child: Provider<FontSizeProvider>(
                create: (_) => FontSizeProvider(),
                child: Scaffold(
                  body: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        onPressed: () {
                          SchulungenDetailsDialog.show(
                            context,
                            terminWithBlockedReg,
                            testOriginalTermin,
                            lehrgangsleiterMail: 'hans@example.com',
                            lehrgangsleiterTel: '0123456789',
                            onBookingPressed: () {},
                            isUserLoggedIn: true,
                            personId: 456,
                          );
                        },
                        child: const Text('Show Dialog'),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Find the booking FAB and verify it's disabled
        final bookingFab = find.byType(FloatingActionButton).last;
        expect(bookingFab, findsOneWidget);

        final fabWidget = tester.widget<FloatingActionButton>(bookingFab);
        expect(
          fabWidget.onPressed,
          isNull,
        ); // Disabled button has null onPressed
        expect(
          fabWidget.backgroundColor,
          equals(UIConstants.cancelButtonBackground),
        );
      });

      testWidgets('booking button is enabled when booking allowed',
          (tester) async {
        // Create a termin that doesn't trigger async logic (personId = 0)
        final terminForNonLoggedInUser = Schulungstermin(
          schulungsterminId: 123,
          schulungsartId: 1,
          schulungsTeilnehmerId: 1,
          bemerkung: 'Test bemerkung',
          kosten: 50.0,
          lehrgangsleiter: 'Hans Müller',
          verpflegungskosten: 10.0,
          uebernachtungskosten: 20.0,
          lehrmaterialkosten: 5.0,
          lehrgangsinhalt: 'Test Lehrgangsinhalt',
          maxTeilnehmer: 20,
          webVeroeffentlichenAm: '2024-01-01',
          status: 1,
          datum: DateTime(2024, 6, 15),
          datumBis: '2024-06-15',
          lehrgangsinhaltHtml: '<p>HTML Lehrgangsinhalt</p>',
          lehrgangsleiter2: '',
          lehrgangsleiter3: '',
          lehrgangsleiter4: '',
          lehrgangsleiterTel: '0123456789',
          lehrgangsleiter2Tel: '',
          lehrgangsleiter3Tel: '',
          lehrgangsleiter4Tel: '',
          lehrgangsleiterMail: 'hans@example.com',
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
          fuerVuelVerlaengerungen: false,
          anmeldeErlaubt: 1,
          verbandsInternPasswort: '',
          bezeichnung: 'Test Schulung',
          angemeldeteTeilnehmer: 5,
          anmeldungenGesperrt: false,
          ort: 'München',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Provider<ApiService>.value(
              value: mockApiService,
              child: Provider<FontSizeProvider>(
                create: (_) => FontSizeProvider(),
                child: Scaffold(
                  body: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        onPressed: () {
                          SchulungenDetailsDialog.show(
                            context,
                            terminForNonLoggedInUser,
                            testOriginalTermin,
                            lehrgangsleiterMail: 'hans@example.com',
                            lehrgangsleiterTel: '0123456789',
                            onBookingPressed: () {},
                            isUserLoggedIn: true,
                            personId: 0, // 0 means no async call
                          );
                        },
                        child: const Text('Show Dialog'),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Find the booking FAB and verify it's enabled
        final bookingFabs = find.byType(FloatingActionButton);
        expect(
          bookingFabs,
          findsNWidgets(2),
        ); // Should find both close and booking FABs

        final bookingFab = bookingFabs.last;
        final fabWidget = tester.widget<FloatingActionButton>(bookingFab);

        expect(
          fabWidget.onPressed,
          isNotNull,
          reason: 'Booking button should be enabled when booking is allowed',
        );
        expect(fabWidget.backgroundColor, equals(UIConstants.defaultAppColor));
      });

      testWidgets('calls onBookingPressed when booking button tapped',
          (tester) async {
        bool bookingPressed = false;

        // Use personId 0 to avoid async issues
        await tester.pumpWidget(
          MaterialApp(
            home: Provider<ApiService>.value(
              value: mockApiService,
              child: Provider<FontSizeProvider>(
                create: (_) => FontSizeProvider(),
                child: Scaffold(
                  body: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        onPressed: () {
                          SchulungenDetailsDialog.show(
                            context,
                            testTermin,
                            testOriginalTermin,
                            lehrgangsleiterMail: 'hans@example.com',
                            lehrgangsleiterTel: '0123456789',
                            onBookingPressed: () {
                              bookingPressed = true;
                            },
                            isUserLoggedIn: true,
                            personId: 0, // Use 0 to avoid async calls
                          );
                        },
                        child: const Text('Show Dialog'),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Find the booking button and verify it's enabled
        final bookingFabs = find.byType(FloatingActionButton);
        final bookingFab = bookingFabs.last;
        final fabWidget = tester.widget<FloatingActionButton>(bookingFab);

        expect(
          fabWidget.onPressed,
          isNotNull,
          reason: 'Button should be enabled before tapping',
        );

        // Tap the booking button
        await tester.tap(bookingFab);
        await tester.pumpAndSettle();

        expect(bookingPressed, isTrue);
      });

      testWidgets('closes dialog when close button tapped', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Provider<ApiService>.value(
              value: mockApiService,
              child: Provider<FontSizeProvider>(
                create: (_) => FontSizeProvider(),
                child: Scaffold(
                  body: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        onPressed: () {
                          SchulungenDetailsDialog.show(
                            context,
                            testTermin,
                            testOriginalTermin,
                            lehrgangsleiterMail: 'hans@example.com',
                            lehrgangsleiterTel: '0123456789',
                            onBookingPressed: () {},
                            isUserLoggedIn: true,
                            personId: 456,
                          );
                        },
                        child: const Text('Show Dialog'),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Verify dialog is open
        expect(find.text('Test Schulung'), findsOneWidget);

        // Tap the close button (first FAB)
        final closeFab = find.byType(FloatingActionButton).first;
        await tester.tap(closeFab);
        await tester.pumpAndSettle();

        // Verify dialog is closed
        expect(find.text('Test Schulung'), findsNothing);
      });
    });
  });
}
