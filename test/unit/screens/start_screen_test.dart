import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/screens/start_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/schulungstermin_data.dart';
import 'dart:typed_data';

import '../helpers/test_helper.dart';
import 'package:meinbssb/widgets/scaled_text.dart';

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

  // Helper function to create test Schulungstermin
  Schulungstermin createTestSchulung({
    int id = 1,
    String bezeichnung = 'Test Training',
    DateTime? datum,
    int teilnehmerId = 12345,
  }) {
    return Schulungstermin(
      schulungsterminId: id,
      schulungsartId: 1,
      schulungsTeilnehmerId: teilnehmerId,
      datum: datum ?? DateTime.parse('2023-01-15T00:00:00.000'),
      bemerkung: 'Test Bemerkung',
      kosten: 100.0,
      ort: 'Test Location',
      lehrgangsleiter: 'Test Leiter',
      verpflegungskosten: 10.0,
      uebernachtungskosten: 20.0,
      lehrmaterialkosten: 5.0,
      lehrgangsinhalt: 'Test Grundlagen',
      maxTeilnehmer: 20,
      webVeroeffentlichenAm: '2023-01-01',
      anmeldungenGesperrt: false,
      status: 1,
      datumBis: '2023-01-16',
      lehrgangsinhaltHtml: '<p>Test HTML Content</p>',
      lehrgangsleiter2: '',
      lehrgangsleiter3: '',
      lehrgangsleiter4: '',
      lehrgangsleiterTel: '123456789',
      lehrgangsleiter2Tel: '',
      lehrgangsleiter3Tel: '',
      lehrgangsleiter4Tel: '',
      lehrgangsleiterMail: 'test@example.com',
      lehrgangsleiter2Mail: '',
      lehrgangsleiter3Mail: '',
      lehrgangsleiter4Mail: '',
      anmeldeStopp: '2023-01-10',
      abmeldeStopp: '2023-01-12',
      geloescht: false,
      stornoGrund: '',
      webGruppe: 1,
      veranstaltungsBezirk: 1,
      fuerVerlaengerungen: false,
      fuerVuelVerlaengerungen: false,
      anmeldeErlaubt: 1,
      verbandsInternPasswort: '',
      bezeichnung: bezeichnung,
      angemeldeteTeilnehmer: 10,
    );
  }

  Schulungstermin createTestSchulungWithContent({
    int id = 1,
    String bezeichnung = 'Test Training',
    DateTime? datum,
    int teilnehmerId = 12345,
    String? lehrgangsinhalt,
    String? lehrgangsinhaltHtml,
  }) {
    return Schulungstermin(
      schulungsterminId: id,
      schulungsartId: 1,
      schulungsTeilnehmerId: teilnehmerId,
      datum: datum ?? DateTime.parse('2023-01-15T00:00:00.000'),
      bemerkung: 'Test Bemerkung',
      kosten: 100.0,
      ort: 'Test Location',
      lehrgangsleiter: 'Test Leiter',
      verpflegungskosten: 10.0,
      uebernachtungskosten: 20.0,
      lehrmaterialkosten: 5.0,
      lehrgangsinhalt: lehrgangsinhalt ?? 'Test Grundlagen',
      maxTeilnehmer: 20,
      webVeroeffentlichenAm: '2023-01-01',
      anmeldungenGesperrt: false,
      status: 1,
      datumBis: '2023-01-16',
      lehrgangsinhaltHtml: lehrgangsinhaltHtml ?? '<p>Test HTML Content</p>',
      lehrgangsleiter2: '',
      lehrgangsleiter3: '',
      lehrgangsleiter4: '',
      lehrgangsleiterTel: '123456789',
      lehrgangsleiter2Tel: '',
      lehrgangsleiter3Tel: '',
      lehrgangsleiter4Tel: '',
      lehrgangsleiterMail: 'test@example.com',
      lehrgangsleiter2Mail: '',
      lehrgangsleiter3Mail: '',
      lehrgangsleiter4Mail: '',
      anmeldeStopp: '2023-01-10',
      abmeldeStopp: '2023-01-12',
      geloescht: false,
      stornoGrund: '',
      webGruppe: 1,
      veranstaltungsBezirk: 1,
      fuerVerlaengerungen: false,
      fuerVuelVerlaengerungen: false,
      anmeldeErlaubt: 1,
      verbandsInternPasswort: '',
      bezeichnung: bezeichnung,
      angemeldeteTeilnehmer: 10,
    );
  }

  Widget createStartScreen({UserData? user, bool isLoggedIn = true}) {
    return TestHelper.createTestApp(
      home: StartScreen(
        user ?? userData,
        isLoggedIn: isLoggedIn,
        onLogout: () {},
      ),
    );
  }

  // Existing tests
  testWidgets('StartScreen displays loading spinner while fetching data', (
    WidgetTester tester,
  ) async {
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

  testWidgets('StartScreen displays no Schulungen found message when no data', (
    WidgetTester tester,
  ) async {
    when(
      TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
    ).thenAnswer((_) async => []);

    await tester.pumpWidget(createStartScreen());

    // Esperamos que se muestre el texto de 'Keine Schulungen gefunden.'
    await tester.pumpAndSettle();
    expect(find.text('Keine Schulungen gefunden.'), findsOneWidget);
  });

  testWidgets('StartScreen displays list of Schulungen when data is present', (
    WidgetTester tester,
  ) async {
    when(
      TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
    ).thenAnswer(
      (_) async => [
        Schulungstermin(
          schulungsterminId: 1,
          schulungsartId: 1,
          schulungsTeilnehmerId: 12345,
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
          fuerVuelVerlaengerungen: false,
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

  // NEW COMPREHENSIVE TESTS

  group('User Information Display', () {
    testWidgets('displays user name and pass number correctly', (tester) async {
      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      expect(find.text('Lukas Schürz'), findsOneWidget);
      expect(find.text('40100709'), findsOneWidget);
      expect(find.text('Feuerschützen Kühbach'), findsOneWidget);
    });

    testWidgets('displays correct labels for user information', (tester) async {
      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      expect(find.text('Schützenpassnummer'), findsOneWidget);
      expect(find.text('Erstverein'), findsOneWidget);
    });

    testWidgets('handles user with empty names gracefully', (tester) async {
      const emptyUser = UserData(
        personId: 1,
        webLoginId: 1,
        passnummer: '123',
        vereinNr: 1,
        namen: '',
        vorname: '',
        titel: '',
        geburtsdatum: null,
        geschlecht: 1,
        vereinName: 'Test Verein',
        passdatenId: 1,
        mitgliedschaftId: 1,
        strasse: '',
        plz: '',
        ort: '',
        isOnline: false,
      );

      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createStartScreen(user: emptyUser));
      await tester.pumpAndSettle();

      expect(find.text(' '), findsOneWidget); // Empty name displays as space
      expect(find.text('123'), findsOneWidget);
    });
  });

  group('Profile Picture Functionality', () {
    testWidgets('displays default person icon when no profile picture', (
      tester,
    ) async {
      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => []);
      when(
        TestHelper.mockApiService.getProfilePhoto(any),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });

  group('Schulungen List Display', () {
    testWidgets('displays multiple Schulungen correctly', (tester) async {
      final schulungen = [
        createTestSchulung(id: 1, bezeichnung: 'Training A'),
        createTestSchulung(id: 2, bezeichnung: 'Training B'),
        createTestSchulung(id: 3, bezeichnung: 'Training C'),
      ];

      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => schulungen);

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      expect(find.text('Training A'), findsOneWidget);
      expect(find.text('Training B'), findsOneWidget);
      expect(find.text('Training C'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(3));
    });

    testWidgets('displays formatted date correctly', (tester) async {
      final schulung = createTestSchulung(datum: DateTime(2024, 12, 25));

      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => [schulung]);

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      expect(find.text('25.12.2024'), findsOneWidget);
    });

    testWidgets('displays action buttons for each Schulung', (tester) async {
      final schulung = createTestSchulung();

      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => [schulung]);

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.description), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('handles empty Schulung fields gracefully', (tester) async {
      final schulung = Schulungstermin(
        schulungsterminId: 1,
        schulungsartId: 1,
        schulungsTeilnehmerId: 12345,
        datum: DateTime.now(),
        bemerkung: '',
        kosten: 0.0,
        ort: '',
        lehrgangsleiter: '',
        verpflegungskosten: 0.0,
        uebernachtungskosten: 0.0,
        lehrmaterialkosten: 0.0,
        lehrgangsinhalt: '',
        maxTeilnehmer: 0,
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
        geloescht: false,
        stornoGrund: '',
        webGruppe: 1,
        veranstaltungsBezirk: 1,
        fuerVerlaengerungen: false,
        fuerVuelVerlaengerungen: false,
        anmeldeErlaubt: 1,
        verbandsInternPasswort: '',
        bezeichnung: '',
        angemeldeteTeilnehmer: 0,
      );

      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => [schulung]);

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Details Dialog Functionality', () {
    testWidgets('displays details dialog with HTML content', (tester) async {
      final schulung = createTestSchulung();

      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => [schulung]);
      when(
        TestHelper.mockApiService.fetchSchulungstermin(any),
      ).thenAnswer((_) async => schulung);

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.description));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('closes details dialog when close button tapped', (
      tester,
    ) async {
      final schulung = createTestSchulung();

      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => [schulung]);
      when(
        TestHelper.mockApiService.fetchSchulungstermin(any),
      ).thenAnswer((_) async => schulung);

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.description));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('shows error when details fetch fails', (tester) async {
      final schulung = createTestSchulung();

      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => [schulung]);
      when(
        TestHelper.mockApiService.fetchSchulungstermin(any),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.description));
      await tester.pumpAndSettle();

      expect(find.text('Fehler'), findsOneWidget);
      expect(
        find.text('Details konnten nicht geladen werden.'),
        findsOneWidget,
      );
    });
  });

  group('Deletion Functionality', () {
    testWidgets('cancels deletion when cancel button pressed', (tester) async {
      final schulung = createTestSchulung();

      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => [schulung]);

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();

      expect(find.text('Test Training'), findsOneWidget);
      verifyNever(TestHelper.mockApiService.unregisterFromSchulung(any));
    });

    testWidgets('shows error message when deletion fails', (tester) async {
      final schulung = createTestSchulung();

      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => [schulung]);
      when(
        TestHelper.mockApiService.unregisterFromSchulung(any),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Only tap 'Abmelden' if present
      final abmeldenFinder = find.text('Abmelden');
      if (abmeldenFinder.evaluate().isNotEmpty) {
        await tester.tap(abmeldenFinder);
        await tester.pumpAndSettle();
      }

      // Wait for SnackBar to appear and check for error text in ScaledText
      await tester.pumpAndSettle();
      final snackBars = tester.widgetList<SnackBar>(find.byType(SnackBar));
      for (final snackBar in snackBars) {
        // Print the runtime type and content for debugging
        // ignore: avoid_print
        print(
          'SnackBar content: \\${snackBar.content.runtimeType} - \\${snackBar.content}',
        );
        if (snackBar.content is ScaledText) {
          // ignore: avoid_print
          print('ScaledText: \\${(snackBar.content as ScaledText).text}');
        }
      }
      expect(
        snackBars.any(
          (snackBar) =>
              snackBar.content is ScaledText &&
              (snackBar.content as ScaledText).text ==
                  'Fehler beim Abmelden von der Schulung.',
        ),
        isTrue,
      );
    });

    testWidgets('handles deletion exception gracefully', (tester) async {
      final schulung = createTestSchulung();

      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => [schulung]);
      when(
        TestHelper.mockApiService.unregisterFromSchulung(any),
      ).thenThrow(Exception('Network error'));

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Only tap 'Abmelden' if present
      final abmeldenFinder = find.text('Abmelden');
      if (abmeldenFinder.evaluate().isNotEmpty) {
        await tester.tap(abmeldenFinder);
        await tester.pumpAndSettle();
      }

      // Wait for SnackBar to appear and check for error text in ScaledText
      await tester.pumpAndSettle();
      final snackBars = tester.widgetList<SnackBar>(find.byType(SnackBar));
      for (final snackBar in snackBars) {
        // Print the runtime type and content for debugging
        // ignore: avoid_print
        print(
          'SnackBar content: \\${snackBar.content.runtimeType} - \\${snackBar.content}',
        );
        if (snackBar.content is ScaledText) {
          // ignore: avoid_print
          print('ScaledText: \\${(snackBar.content as ScaledText).text}');
        }
      }
      expect(
        snackBars.any(
          (snackBar) =>
              snackBar.content is ScaledText &&
              (snackBar.content as ScaledText).text.contains('Error:'),
        ),
        isTrue,
      );
    });
  });

  group('Error Handling', () {
    testWidgets('handles API error gracefully', (tester) async {
      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenThrow(Exception('API Error'));

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      expect(find.text('Keine Schulungen gefunden.'), findsOneWidget);
    });

    testWidgets('handles network timeout gracefully', (tester) async {
      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenThrow(Exception('Network timeout'));

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      expect(find.text('Keine Schulungen gefunden.'), findsOneWidget);
    });

    testWidgets('handles null user gracefully', (tester) async {
      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createStartScreen(user: null));
      await tester.pumpAndSettle();

      expect(find.text('Keine Schulungen gefunden.'), findsOneWidget);
    });
  });

  group('Widget State Management', () {
    testWidgets('maintains state during rebuild', (tester) async {
      final schulung = createTestSchulung();

      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => [schulung]);

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      expect(find.text('Test Training'), findsOneWidget);

      // Rebuild widget
      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      expect(find.text('Test Training'), findsOneWidget);
    });
  });

  group('UI Layout and Responsiveness', () {
    testWidgets('displays section headers correctly', (tester) async {
      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      expect(find.text('Angemeldete Schulungen:'), findsOneWidget);
    });

    testWidgets('handles large number of Schulungen', (tester) async {
      final manySchulungen = List.generate(
        50,
        (index) => createTestSchulung(
          id: index + 1,
          bezeichnung: 'Training ${index + 1}',
        ),
      );

      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => manySchulungen);

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(50));
      expect(find.text('Training 1'), findsOneWidget);
      expect(find.text('Training 50'), findsOneWidget);
    });
  });

  group('Date Formatting', () {
    testWidgets('formats different date formats correctly', (tester) async {
      final schulungen = [
        createTestSchulung(id: 1, datum: DateTime(2024, 1, 1)),
        createTestSchulung(id: 2, datum: DateTime(2024, 12, 31)),
        createTestSchulung(id: 3, datum: DateTime(2024, 6, 15)),
      ];

      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => schulungen);

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      expect(find.text('01.01.2024'), findsOneWidget);
      expect(find.text('31.12.2024'), findsOneWidget);
      expect(find.text('15.06.2024'), findsOneWidget);
    });

    testWidgets('handles leap year dates', (tester) async {
      final schulung = createTestSchulung(datum: DateTime(2024, 2, 29));

      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => [schulung]);

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      expect(find.text('29.02.2024'), findsOneWidget);
    });
  });

  group('Profile Picture Advanced Scenarios', () {
    testWidgets('handles profile picture loading failure gracefully', (
      tester,
    ) async {
      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => []);
      when(
        TestHelper.mockApiService.getProfilePhoto(any),
      ).thenThrow(Exception('Profile photo service unavailable'));

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      // Should fallback to default icon
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('displays corrupted image as default icon', (tester) async {
      final corruptedBytes = Uint8List.fromList([
        0x00,
        0x01,
        0x02,
      ]); // Invalid image data

      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => []);
      when(
        TestHelper.mockApiService.getProfilePhoto(any),
      ).thenAnswer((_) async => corruptedBytes);

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      // Should show image widget which will error and fallback
      expect(find.byType(ClipOval), findsOneWidget);
    });
  });

  group('Advanced Schulung Operations', () {
    testWidgets(
      'does not show delete option for invalid schulung participant ID',
      (tester) async {
        final invalidSchulung = createTestSchulung(teilnehmerId: 0);

        when(
          TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
        ).thenAnswer((_) async => [invalidSchulung]);

        await tester.pumpWidget(createStartScreen());
        await tester.pumpAndSettle();

        // Should still show the delete button, but tapping it should do nothing
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);

        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pump();

        // No confirmation dialog should appear
        expect(find.text('Schulung abmelden'), findsNothing);
      },
    );

    testWidgets('handles schulung with negative participant ID', (
      tester,
    ) async {
      final negativeIdSchulung = createTestSchulung(teilnehmerId: -1);

      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => [negativeIdSchulung]);

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      // Should not show confirmation dialog for negative ID
      expect(find.text('Schulung abmelden'), findsNothing);
    });
  });

  group('Details Dialog Advanced Tests', () {
    testWidgets('shows details with both HTML and plain text content', (
      tester,
    ) async {
      final schulungWithBothContent = createTestSchulungWithContent(
        lehrgangsinhalt: 'Plain text fallback',
        lehrgangsinhaltHtml: '<h1>HTML Title</h1><p>HTML content</p>',
      );

      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => [schulungWithBothContent]);
      when(
        TestHelper.mockApiService.fetchSchulungstermin(any),
      ).thenAnswer((_) async => schulungWithBothContent);

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.description));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      // Fix: Check for specific HTML content instead of Html widget type
      expect(find.textContaining('HTML Title'), findsOneWidget);
    });

    testWidgets('handles details dialog with extremely long content', (
      tester,
    ) async {
      final longContentSchulung = createTestSchulungWithContent(
        lehrgangsinhalt: 'Very long content. ' * 500, // Very long text
      );

      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => [longContentSchulung]);
      when(
        TestHelper.mockApiService.fetchSchulungstermin(any),
      ).thenAnswer((_) async => longContentSchulung);

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.description));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('State Management Edge Cases', () {
    testWidgets('handles rapid successive API calls', (tester) async {
      int callCount = 0;
      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async {
        callCount++;
        await Future.delayed(const Duration(milliseconds: 100));
        return callCount == 1 ? [] : [createTestSchulung()];
      });

      await tester.pumpWidget(createStartScreen());

      // Trigger multiple rapid rebuilds
      for (int i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('maintains loading state consistency', (tester) async {
      bool shouldDelay = true;
      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async {
        if (shouldDelay) {
          await Future.delayed(const Duration(milliseconds: 200));
          shouldDelay = false;
        }
        return [createTestSchulung()];
      });

      await tester.pumpWidget(createStartScreen());

      // Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));

      // Should still be loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Should no longer be loading
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Test Training'), findsOneWidget);
    });
  });

  group('Complex User Data Scenarios', () {
    testWidgets('displays user with special characters correctly', (
      tester,
    ) async {
      // Fix: Remove const keyword
      final specialCharUser = UserData(
        personId: 123,
        webLoginId: 456,
        passnummer: 'P-123/456',
        vereinNr: 401051,
        namen: 'Müller-Schmidt',
        vorname: 'José-María',
        titel: 'Dr.',
        geburtsdatum: null,
        geschlecht: 1,
        vereinName: 'SV "Edelweiß" München & Umgebung',
        passdatenId: 789,
        mitgliedschaftId: 101,
        strasse: 'Straße 123',
        plz: '80331',
        ort: 'München',
        isOnline: true,
      );

      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createStartScreen(user: specialCharUser));
      await tester.pumpAndSettle();

      expect(find.textContaining('José-María Müller-Schmidt'), findsOneWidget);
      expect(find.textContaining('P-123/456'), findsOneWidget);
      expect(
        find.textContaining('SV "Edelweiß" München & Umgebung'),
        findsOneWidget,
      );
    });

    testWidgets('handles user with extremely long names', (tester) async {
      // Fix: Remove const keyword
      final longNameUser = UserData(
        personId: 123,
        webLoginId: 456,
        passnummer: '123456',
        vereinNr: 401051,
        namen:
            'Sehr-Langer-Nachname-Der-Definitiv-Zu-Lang-Für-Normal-Display-Ist',
        vorname: 'Extrem-Langer-Vorname-Der-Auch-Viel-Zu-Lang-Ist',
        titel: '',
        geburtsdatum: null,
        geschlecht: 1,
        vereinName:
            'Extrem Langer Vereinsname Der Definitiv Zu Lang Für Normale Anzeige Ist',
        passdatenId: 789,
        mitgliedschaftId: 101,
        strasse: '',
        plz: '',
        ort: '',
        isOnline: false,
      );

      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createStartScreen(user: longNameUser));
      await tester.pumpAndSettle();

      // Should display without errors
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Extrem-Langer-Vorname'), findsOneWidget);
    });
  });

  group('Accessibility and Responsiveness', () {
    testWidgets('handles different screen orientations', (tester) async {
      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => [createTestSchulung()]);

      // Portrait mode
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      expect(find.text('Test Training'), findsOneWidget);

      // Landscape mode
      tester.binding.window.physicalSizeTestValue = const Size(800, 400);
      await tester.pump();

      expect(find.text('Test Training'), findsOneWidget);

      // Reset
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    testWidgets('handles tap events on different widget areas', (tester) async {
      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => [createTestSchulung()]);

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      // Test tapping on different areas of the list tile
      final listTile = find.byType(ListTile);
      expect(listTile, findsOneWidget);

      // Tap on the leading icon area (should not trigger navigation)
      await tester.tapAt(tester.getTopLeft(listTile));
      await tester.pump();

      // Tap on the trailing area (action buttons)
      await tester.tapAt(tester.getTopRight(listTile));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('Performance and Memory Management', () {
    testWidgets('handles multiple simultaneous async operations', (
      tester,
    ) async {
      int profilePhotoCallCount = 0;
      int schulungenCallCount = 0;

      when(TestHelper.mockApiService.getProfilePhoto(any)).thenAnswer((
        _,
      ) async {
        profilePhotoCallCount++;
        await Future.delayed(const Duration(milliseconds: 100));
        return null;
      });

      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async {
        schulungenCallCount++;
        await Future.delayed(const Duration(milliseconds: 200));
        return [createTestSchulung()];
      });

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      // Both operations should have been called
      expect(profilePhotoCallCount, greaterThan(0));
      expect(schulungenCallCount, equals(1));
    });

    testWidgets('handles memory pressure scenarios', (tester) async {
      // Simulate memory pressure by creating large datasets
      final largeSchulungenList = List.generate(
        1000,
        (i) => createTestSchulung(id: i, bezeichnung: 'Large Dataset Item $i'),
      );

      when(
        TestHelper.mockApiService.fetchAngemeldeteSchulungen(any, any),
      ).thenAnswer((_) async => largeSchulungenList);

      await tester.pumpWidget(createStartScreen());
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(1000));
      expect(tester.takeException(), isNull);
    });
  });
}
