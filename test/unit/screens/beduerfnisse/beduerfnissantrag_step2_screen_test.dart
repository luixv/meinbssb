import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnissantrag_step2_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_status_data.dart';
import 'package:meinbssb/models/beduerfnisse_sport_data.dart';
import 'package:meinbssb/models/beduerfnisse_datei_data.dart';
import 'package:meinbssb/models/beduerfnisse_auswahl_data.dart';
import 'package:meinbssb/models/disziplin_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/api/workflow_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'beduerfnissantrag_step2_screen_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApiService;
  late FontSizeProvider fontSizeProvider;

  TestWidgetsFlutterBinding.ensureInitialized();

  // Dummy user data for testing
  const dummyUserData = UserData(
    personId: 12345,
    webLoginId: 1,
    passnummer: '12345',
    vereinNr: 1,
    namen: 'Test',
    vorname: 'User',
    vereinName: 'Test Verein',
    passdatenId: 1,
    mitgliedschaftId: 1,
    email: 'test@example.com',
  );

  // Dummy antrag for testing
  final dummyAntrag = BeduerfnisseAntrag(
    antragsnummer: 100,
    personId: 12345,
    statusId: BeduerfnisAntragStatus.entwurf,
    wbkNeu: true,
    wbkArt: 'gelb',
    beduerfnisart: 'Kurzwaffe',
    anzahlWaffen: 2,
    vereinsnummer: 1,
    email: 'test@example.com',
    abbuchungErfolgt: false,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockApiService = MockApiService();
    fontSizeProvider = FontSizeProvider();

    // Default mock responses
    when(
      mockApiService.getBedSportByAntragsnummer(any),
    ).thenAnswer((_) async => []);
    when(mockApiService.getBedAuswahlByTypId(1)).thenAnswer((_) async => []);
    when(mockApiService.getBedAuswahlByTypId(2)).thenAnswer((_) async => []);
    when(mockApiService.fetchDisziplinen()).thenAnswer((_) async => []);
    when(mockApiService.hasBedDateiSport(any)).thenAnswer((_) async => false);
  });

  /// Helper function to create a test widget with necessary providers
  Widget createTestWidget({
    UserData? userData = dummyUserData,
    BeduerfnisseAntrag? antrag,
    bool isLoggedIn = true,
    WorkflowRole userRole = WorkflowRole.mitglied,
    bool readOnly = false,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FontSizeProvider>.value(value: fontSizeProvider),
        Provider<ApiService>.value(value: mockApiService),
      ],
      child: MaterialApp(
        home: BeduerfnissantragStep2Screen(
          userData: userData,
          antrag: antrag ?? dummyAntrag,
          isLoggedIn: isLoggedIn,
          onLogout: () {},
          userRole: userRole,
          readOnly: readOnly,
        ),
      ),
    );
  }

  group('BeduerfnissantragStep2Screen - Rendering & Display', () {
    testWidgets('renders the screen title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('Bedürfnisbescheinigung'), findsOneWidget);
    });

    testWidgets(
      'renders the subtitle "Nachweis der Sportschützeneigenschaft"',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        expect(
          find.text('Nachweis der Sportschützeneigenschaft'),
          findsWidgets,
        );
      },
    );

    testWidgets('shows loading indicator while fetching data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows "Keine Schießdaten vorhanden" when list is empty', (
      WidgetTester tester,
    ) async {
      when(
        mockApiService.getBedSportByAntragsnummer(any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Keine Schießdaten vorhanden.'), findsOneWidget);
    });

    testWidgets('displays bed sport data when available', (
      WidgetTester tester,
    ) async {
      final sportData = BeduerfnisseSport(
        id: 1,
        antragsnummer: 100,
        schiessdatum: DateTime(2024, 1, 15),
        waffenartId: 1,
        disziplinId: 1,
        training: true,
        wettkampfartId: null,
        wettkampfergebnis: null,
        bemerkung: 'Test bemerkung',
      );

      final waffenart = BeduerfnisseAuswahl(
        id: 1,
        typId: 1,
        beschreibung: 'Pistole',
        kuerzel: 'P',
      );

      final disziplin = Disziplin(
        disziplinId: 1,
        disziplinNr: 'D001',
        disziplin: 'Test Disziplin',
      );

      when(
        mockApiService.getBedSportByAntragsnummer(any),
      ).thenAnswer((_) async => [sportData]);
      when(
        mockApiService.getBedAuswahlByTypId(1),
      ).thenAnswer((_) async => [waffenart]);
      when(mockApiService.getBedAuswahlByTypId(2)).thenAnswer((_) async => []);
      when(
        mockApiService.fetchDisziplinen(),
      ).thenAnswer((_) async => [disziplin]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Registrierte Schießaktivitäten:'), findsOneWidget);
      expect(find.text('15.01.2024'), findsOneWidget);
      expect(find.text('Pistole'), findsOneWidget);
      expect(find.text('D001'), findsOneWidget);
      expect(find.text('Bemerkung: Test bemerkung'), findsOneWidget);
    });

    testWidgets('shows training icon with check when training is true', (
      WidgetTester tester,
    ) async {
      final sportData = BeduerfnisseSport(
        id: 1,
        antragsnummer: 100,
        schiessdatum: DateTime(2024, 1, 15),
        waffenartId: 1,
        disziplinId: 1,
        training: true,
      );

      when(
        mockApiService.getBedSportByAntragsnummer(any),
      ).thenAnswer((_) async => [sportData]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find check icon (training=true)
      final checkIcons = find.byIcon(Icons.check);
      expect(checkIcons, findsWidgets);
    });

    testWidgets('shows wettkampf data when available', (
      WidgetTester tester,
    ) async {
      final sportData = BeduerfnisseSport(
        id: 1,
        antragsnummer: 100,
        schiessdatum: DateTime(2024, 1, 15),
        waffenartId: 1,
        disziplinId: 1,
        training: false,
        wettkampfartId: 1,
        wettkampfergebnis: 95.5,
      );

      final wettkampfart = BeduerfnisseAuswahl(
        id: 1,
        typId: 2,
        beschreibung: 'Bundesliga',
        kuerzel: 'BL',
      );

      when(
        mockApiService.getBedSportByAntragsnummer(any),
      ).thenAnswer((_) async => [sportData]);
      when(
        mockApiService.getBedAuswahlByTypId(2),
      ).thenAnswer((_) async => [wettkampfart]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('BL'), findsOneWidget);
      expect(find.text('95.5'), findsOneWidget);
    });
  });

  group('BeduerfnissantragStep2Screen - FAB Buttons', () {
    testWidgets('renders back FAB', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('renders add FAB when not in read-only mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(readOnly: false));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('does not render add FAB in read-only mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(readOnly: true));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsNothing);
    });

    testWidgets('renders next/forward FAB', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('back FAB navigates back', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify navigation happened (screen should be popped)
      expect(find.byType(BeduerfnissantragStep2Screen), findsNothing);
    });

    testWidgets('add FAB opens dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final addButton = find.byIcon(Icons.add);
      expect(addButton, findsOneWidget);

      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Check if dialog is shown (by looking for dialog elements)
      expect(find.byType(Dialog), findsOneWidget);
    });
  });

  group('BeduerfnissantragStep2Screen - Delete Functionality', () {
    testWidgets('shows delete icon in Entwurf status', (
      WidgetTester tester,
    ) async {
      final sportData = BeduerfnisseSport(
        id: 1,
        antragsnummer: 100,
        schiessdatum: DateTime(2024, 1, 15),
        waffenartId: 1,
        disziplinId: 1,
        training: true,
      );

      when(
        mockApiService.getBedSportByAntragsnummer(any),
      ).thenAnswer((_) async => [sportData]);

      final antragEntwurf = dummyAntrag.copyWith(
        statusId: BeduerfnisAntragStatus.entwurf,
      );

      await tester.pumpWidget(
        createTestWidget(antrag: antragEntwurf, readOnly: false),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('does not show delete icon in read-only mode', (
      WidgetTester tester,
    ) async {
      final sportData = BeduerfnisseSport(
        id: 1,
        antragsnummer: 100,
        schiessdatum: DateTime(2024, 1, 15),
        waffenartId: 1,
        disziplinId: 1,
        training: true,
      );

      when(
        mockApiService.getBedSportByAntragsnummer(any),
      ).thenAnswer((_) async => [sportData]);

      await tester.pumpWidget(createTestWidget(readOnly: true));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('does not show delete icon when status is not Entwurf', (
      WidgetTester tester,
    ) async {
      final sportData = BeduerfnisseSport(
        id: 1,
        antragsnummer: 100,
        schiessdatum: DateTime(2024, 1, 15),
        waffenartId: 1,
        disziplinId: 1,
        training: true,
      );

      when(
        mockApiService.getBedSportByAntragsnummer(any),
      ).thenAnswer((_) async => [sportData]);

      final antragSubmitted = dummyAntrag.copyWith(
        statusId: BeduerfnisAntragStatus.eingereichtAmVerein,
      );

      await tester.pumpWidget(
        createTestWidget(antrag: antragSubmitted, readOnly: false),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });
  });

  group('BeduerfnissantragStep2Screen - Navigation to Step 3', () {
    testWidgets(
      'forward FAB navigates in read-only mode without status change',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(readOnly: true));
        await tester.pumpAndSettle();

        final forwardButton = find.byIcon(Icons.arrow_forward);
        await tester.tap(forwardButton);
        await tester.pumpAndSettle();

        // Verify no updateBedAntrag was called in read-only mode
        verifyNever(mockApiService.updateBedAntrag(any));
      },
    );
  });

  group('BeduerfnissantragStep2Screen - Error Handling', () {
    testWidgets('shows error on failed delete', (WidgetTester tester) async {
      final sportData = BeduerfnisseSport(
        id: 1,
        antragsnummer: 100,
        schiessdatum: DateTime(2024, 1, 15),
        waffenartId: 1,
        disziplinId: 1,
        training: true,
      );

      when(
        mockApiService.getBedSportByAntragsnummer(any),
      ).thenAnswer((_) async => [sportData]);
      when(mockApiService.deleteBedSportById(1)).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final deleteButton = find.byIcon(Icons.delete_outline);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      final confirmButton = find.text('Löschen');
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      expect(find.text('Fehler beim Löschen'), findsOneWidget);
    });

    testWidgets('navigates to step 3 when forward button is tapped', (
      WidgetTester tester,
    ) async {
      final antragEntwurf = dummyAntrag.copyWith(
        statusId: BeduerfnisAntragStatus.entwurf,
      );

      await tester.pumpWidget(
        createTestWidget(antrag: antragEntwurf, readOnly: false),
      );
      await tester.pumpAndSettle();

      final forwardButton = find.byIcon(Icons.arrow_forward);
      await tester.tap(forwardButton);
      await tester.pumpAndSettle();

      // After navigation, step 2 screen should no longer be visible
      expect(find.byType(BeduerfnissantragStep2Screen), findsNothing);
    });
  });

  group('BeduerfnissantragStep2Screen - Edge Cases', () {
    testWidgets('handles null userData', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(userData: null));
      await tester.pumpAndSettle();

      // Screen should still render
      expect(find.text('Bedürfnisbescheinigung'), findsOneWidget);
    });

    testWidgets('handles not logged in state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(isLoggedIn: false));
      await tester.pumpAndSettle();

      // Screen should still render
      expect(find.text('Bedürfnisbescheinigung'), findsOneWidget);
    });

    testWidgets('handles empty antragsnummer', (WidgetTester tester) async {
      final antragNoNumber = BeduerfnisseAntrag(
        antragsnummer: null,
        personId: 12345,
        statusId: BeduerfnisAntragStatus.entwurf,
      );

      await tester.pumpWidget(createTestWidget(antrag: antragNoNumber));
      await tester.pumpAndSettle();

      // Should show empty state
      expect(find.text('Keine Schießdaten vorhanden.'), findsOneWidget);
    });

    testWidgets('handles multiple sport entries', (WidgetTester tester) async {
      final sportData1 = BeduerfnisseSport(
        id: 1,
        antragsnummer: 100,
        schiessdatum: DateTime(2024, 1, 15),
        waffenartId: 1,
        disziplinId: 1,
        training: true,
      );

      final sportData2 = BeduerfnisseSport(
        id: 2,
        antragsnummer: 100,
        schiessdatum: DateTime(2024, 2, 20),
        waffenartId: 2,
        disziplinId: 2,
        training: false,
        wettkampfartId: 1,
        wettkampfergebnis: 88.5,
      );

      when(
        mockApiService.getBedSportByAntragsnummer(any),
      ).thenAnswer((_) async => [sportData1, sportData2]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should display both entries
      expect(find.byType(Card), findsNWidgets(2));
      expect(find.text('15.01.2024'), findsOneWidget);
      expect(find.text('20.02.2024'), findsOneWidget);
    });
  });

  group('BeduerfnissantragStep2Screen - Accessibility', () {
    testWidgets('has proper semantic labels for screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label ==
                  'Bedürfnisbescheinigung - Nachweis der Sportschützeneigenschaft',
        ),
        findsOneWidget,
      );
    });

    testWidgets('header has semantic header property', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.header == true &&
              widget.properties.label ==
                  'Nachweis der Sportschützeneigenschaft',
        ),
        findsOneWidget,
      );
    });
  });

  group('BeduerfnissantragStep2Screen - Font Scaling', () {
    testWidgets('respects font size scaling', (WidgetTester tester) async {
      fontSizeProvider.setScaleFactor(1.5);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Screen should render without overflow
      expect(find.text('Bedürfnisbescheinigung'), findsOneWidget);
    });
  });

  group('BeduerfnissantragStep2Screen - Error Handling', () {
    testWidgets('handles null antragsnummer gracefully', (
      WidgetTester tester,
    ) async {
      final antragWithoutNummer = BeduerfnisseAntrag(
        antragsnummer: null,
        personId: 12345,
        statusId: BeduerfnisAntragStatus.entwurf,
        wbkNeu: true,
        wbkArt: 'gelb',
        beduerfnisart: 'Kurzwaffe',
        anzahlWaffen: 2,
      );

      await tester.pumpWidget(createTestWidget(antrag: antragWithoutNummer));
      await tester.pumpAndSettle();

      // Should display screen without errors
      expect(find.text('Bedürfnisbescheinigung'), findsOneWidget);
    });
  });

  group('BeduerfnissantragStep2Screen - Delete Functionality', () {
    testWidgets('shows error when deleting with null sportId', (
      WidgetTester tester,
    ) async {
      final sportData = BeduerfnisseSport(
        id: null, // null ID
        antragsnummer: 100,
        schiessdatum: DateTime(2024, 1, 15),
        waffenartId: 1,
        disziplinId: 1,
        training: true,
      );

      when(
        mockApiService.getBedSportByAntragsnummer(any),
      ).thenAnswer((_) async => [sportData]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Try to delete
      final deleteButton = find.byIcon(Icons.delete_outline).first;
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Fehler: ID nicht gefunden'), findsOneWidget);
    });

    testWidgets('successfully deletes bed sport entry', (
      WidgetTester tester,
    ) async {
      final sportData = BeduerfnisseSport(
        id: 1,
        antragsnummer: 100,
        schiessdatum: DateTime(2024, 1, 15),
        waffenartId: 1,
        disziplinId: 1,
        training: true,
      );

      when(
        mockApiService.getBedSportByAntragsnummer(any),
      ).thenAnswer((_) async => [sportData]);

      when(mockApiService.deleteBedSportById(1)).thenAnswer((_) async => true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap delete button
      final deleteButton = find.byIcon(Icons.delete_outline).first;
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Confirm deletion
      expect(find.text('Nachweis löschen'), findsOneWidget);
      final confirmButton = find.text('Löschen');
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Should show success message
      expect(find.text('Nachweis erfolgreich gelöscht'), findsOneWidget);
    });

    testWidgets('shows error when deletion fails', (WidgetTester tester) async {
      final sportData = BeduerfnisseSport(
        id: 1,
        antragsnummer: 100,
        schiessdatum: DateTime(2024, 1, 15),
        waffenartId: 1,
        disziplinId: 1,
        training: true,
      );

      when(
        mockApiService.getBedSportByAntragsnummer(any),
      ).thenAnswer((_) async => [sportData]);

      when(mockApiService.deleteBedSportById(1)).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap delete button
      final deleteButton = find.byIcon(Icons.delete_outline).first;
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Confirm deletion
      final confirmButton = find.text('Löschen');
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Fehler beim Löschen'), findsOneWidget);
    });

    testWidgets('cancels deletion when user clicks Abbrechen', (
      WidgetTester tester,
    ) async {
      final sportData = BeduerfnisseSport(
        id: 1,
        antragsnummer: 100,
        schiessdatum: DateTime(2024, 1, 15),
        waffenartId: 1,
        disziplinId: 1,
        training: true,
      );

      when(
        mockApiService.getBedSportByAntragsnummer(any),
      ).thenAnswer((_) async => [sportData]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap delete button
      final deleteButton = find.byIcon(Icons.delete_outline).first;
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Cancel deletion
      final cancelButton = find.text('Abbrechen');
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      // Should not call API
      verifyNever(mockApiService.deleteBedSportById(any));
    });
  });

  group('BeduerfnissantragStep2Screen - View Document', () {
    testWidgets('displays sport entries without documents', (
      WidgetTester tester,
    ) async {
      final sportData = BeduerfnisseSport(
        id: 1,
        antragsnummer: 100,
        schiessdatum: DateTime(2024, 1, 15),
        waffenartId: 1,
        disziplinId: 1,
        training: true,
      );

      when(
        mockApiService.getBedSportByAntragsnummer(any),
      ).thenAnswer((_) async => [sportData]);

      when(mockApiService.hasBedDateiSport(1)).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should display the sport entry
      expect(find.byType(Card), findsOneWidget);
    });
  });

  group('BeduerfnissantragStep2Screen - Continue to Step 3', () {
    testWidgets('displays continue FAB', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the forward arrow FAB
      final continueButton = find.byIcon(Icons.arrow_forward);
      expect(continueButton, findsOneWidget);
    });
  });
}
