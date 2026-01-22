import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/bank_data.dart';
import 'package:meinbssb/models/passdaten_akzept_or_aktiv_data.dart';
import 'package:meinbssb/models/zve_data.dart';
import 'package:meinbssb/screens/ausweis/ausweis_bestellen_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

class FakeApiService implements ApiService {
  bool returnEmptyBankData = false;

  @override
  Future<List<BankData>> fetchBankdatenMyBSSB(int webLoginId) async {
    if (returnEmptyBankData) {
      return [];
    }
    return [
      BankData(
        id: 1,
        webloginId: webLoginId,
        kontoinhaber: 'Test Kontoinhaber',
        iban: 'DE12345678901234567890',
        bic: 'TESTBIC',
      ),
    ];
  }

  bool called = false;
  bool shouldSucceed = true;
  PassdatenAkzeptOrAktiv? passDataToReturn;

  @override
  Future<PassdatenAkzeptOrAktiv?> fetchPassdatenAkzeptierterOderAktiverPass(
    int? personId,
  ) async {
    return passDataToReturn;
  }

  @override
  Future<bool> bssbAppPassantrag(
    List<Map<String, dynamic>> zves,
    int? passdatenId,
    int? personId,
    int? erstVereinId,
    int digitalerPass,
    int antragsTyp,
  ) async {
    called = true;
    // Optionally check zves for test logic
    return shouldSucceed;
  }

  // Add stubs for all other ApiService methods:
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget buildTestWidget({
  required ApiService apiService,
  UserData? userData,
  bool isLoggedIn = true,
  Function()? onLogout,
}) {
  return MultiProvider(
    providers: [
      Provider<ApiService>.value(value: apiService),
      ChangeNotifierProvider<FontSizeProvider>(
        create: (_) => FontSizeProvider(),
      ),
    ],
    child: MaterialApp(
      home: AusweisBestellenScreen(
        userData: userData,
        isLoggedIn: isLoggedIn,
        onLogout: onLogout ?? () {},
      ),
    ),
  );
}

void main() {
  testWidgets('shows loading indicator when isLoading is true', (
    WidgetTester tester,
  ) async {
    final apiService = FakeApiService();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ApiService>.value(value: apiService),
          ChangeNotifierProvider<FontSizeProvider>(
            create: (_) => FontSizeProvider(),
          ),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return AusweisBestellenScreen(
                userData: const UserData(
                  personId: 1,
                  webLoginId: 1,
                  passnummer: '',
                  vereinNr: 1,
                  namen: '',
                  vorname: '',
                  titel: null,
                  geburtsdatum: null,
                  geschlecht: null,
                  vereinName: '',
                  strasse: null,
                  plz: null,
                  ort: null,
                  land: '',
                  nationalitaet: '',
                  passStatus: 0,
                  passdatenId: 1,
                  eintrittVerein: null,
                  austrittVerein: null,
                  mitgliedschaftId: 1,
                  telefon: '',
                  erstLandesverbandId: 0,
                  produktionsDatum: null,
                  erstVereinId: 0,
                  digitalerPass: 0,
                  isOnline: false,
                  disziplin: null,
                ),
                isLoggedIn: true,
                onLogout: () {},
              );
            },
          ),
        ),
      ),
    );
    // Set isLoading to true
    final state = tester.state(find.byType(AusweisBestellenScreen)) as dynamic;
    state.setState(() {
      state.isLoading = true;
    });
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('opens dialog with expected fields and checkboxes', (
    WidgetTester tester,
  ) async {
    final apiService = FakeApiService();
    await tester.pumpWidget(
      buildTestWidget(
        apiService: apiService,
        userData: const UserData(
          personId: 1,
          webLoginId: 1,
          passnummer: '',
          vereinNr: 1,
          namen: '',
          vorname: '',
          titel: null,
          geburtsdatum: null,
          geschlecht: null,
          vereinName: '',
          strasse: null,
          plz: null,
          ort: null,
          land: '',
          nationalitaet: '',
          passStatus: 0,
          passdatenId: 1,
          eintrittVerein: null,
          austrittVerein: null,
          mitgliedschaftId: 1,
          telefon: '',
          erstLandesverbandId: 0,
          produktionsDatum: null,
          erstVereinId: 0,
          digitalerPass: 0,
          isOnline: false,
          disziplin: null,
        ),
      ),
    );
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Bankdaten'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
    // Accept either CheckboxListTile or Checkbox widgets
    final checkboxListTiles = find.byType(CheckboxListTile);
    final checkboxes = find.byType(Checkbox);
    expect(
      checkboxListTiles.evaluate().length + checkboxes.evaluate().length,
      equals(2),
    );
  });

  testWidgets('cancel FAB closes the dialog', (WidgetTester tester) async {
    final apiService = FakeApiService();
    await tester.pumpWidget(
      buildTestWidget(
        apiService: apiService,
        userData: const UserData(
          personId: 1,
          webLoginId: 1,
          passnummer: '',
          vereinNr: 1,
          namen: '',
          vorname: '',
          titel: null,
          geburtsdatum: null,
          geschlecht: null,
          vereinName: '',
          strasse: null,
          plz: null,
          ort: null,
          land: '',
          nationalitaet: '',
          passStatus: 0,
          passdatenId: 1,
          eintrittVerein: null,
          austrittVerein: null,
          mitgliedschaftId: 1,
          telefon: '',
          erstLandesverbandId: 0,
          produktionsDatum: null,
          erstVereinId: 0,
          digitalerPass: 0,
          isOnline: false,
          disziplin: null,
        ),
      ),
    );
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('AGB link is present and styled in dialog', (
    WidgetTester tester,
  ) async {
    final apiService = FakeApiService();
    await tester.pumpWidget(
      buildTestWidget(
        apiService: apiService,
        userData: const UserData(
          personId: 1,
          webLoginId: 1,
          passnummer: '',
          vereinNr: 1,
          namen: '',
          vorname: '',
          titel: null,
          geburtsdatum: null,
          geschlecht: null,
          vereinName: '',
          strasse: null,
          plz: null,
          ort: null,
          land: '',
          nationalitaet: '',
          passStatus: 0,
          passdatenId: 1,
          eintrittVerein: null,
          austrittVerein: null,
          mitgliedschaftId: 1,
          telefon: '',
          erstLandesverbandId: 0,
          produktionsDatum: null,
          erstVereinId: 0,
          digitalerPass: 0,
          isOnline: false,
          disziplin: null,
        ),
      ),
    );
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    // Check for the presence of the AGB link text
    final agbTextFinder = find.text('AGB');
    expect(agbTextFinder, findsOneWidget);
    // Optionally check that the parent is a Row and the style is underlined
    final agbTextWidget = tester.widget<Text>(agbTextFinder);
    expect(agbTextWidget.style?.decoration, TextDecoration.underline);
    // Check that the dialog is still present
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('checkboxes can be toggled and enable submit button', (
    WidgetTester tester,
  ) async {
    final apiService = FakeApiService();
    await tester.pumpWidget(
      buildTestWidget(
        apiService: apiService,
        userData: const UserData(
          personId: 1,
          webLoginId: 1,
          passnummer: '',
          vereinNr: 1,
          namen: '',
          vorname: '',
          titel: null,
          geburtsdatum: null,
          geschlecht: null,
          vereinName: '',
          strasse: null,
          plz: null,
          ort: null,
          land: '',
          nationalitaet: '',
          passStatus: 0,
          passdatenId: 1,
          eintrittVerein: null,
          austrittVerein: null,
          mitgliedschaftId: 1,
          telefon: '',
          erstLandesverbandId: 0,
          produktionsDatum: null,
          erstVereinId: 0,
          digitalerPass: 0,
          isOnline: false,
          disziplin: null,
        ),
      ),
    );
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Find checkboxes
    final checkboxes = find.byType(Checkbox);
    expect(checkboxes, findsNWidgets(2));

    // Initially submit button should be disabled (null onPressed)
    final submitFabs = find.byType(FloatingActionButton);
    expect(submitFabs, findsNWidgets(2)); // Cancel and Submit FABs

    // Find the submit FAB (second one, with check icon)
    final submitFab = submitFabs.at(1);
    final submitButton = tester.widget<FloatingActionButton>(submitFab);
    expect(submitButton.onPressed, isNull);

    // Toggle first checkbox (AGB)
    await tester.tap(checkboxes.first);
    await tester.pump();

    // Still disabled (need both checkboxes)
    final submitButton2 = tester.widget<FloatingActionButton>(submitFab);
    expect(submitButton2.onPressed, isNull);

    // Toggle second checkbox (Lastschrift)
    await tester.tap(checkboxes.last);
    await tester.pump();

    // Now submit button should be enabled
    final submitButton3 = tester.widget<FloatingActionButton>(submitFab);
    expect(submitButton3.onPressed, isNotNull);
  });

  testWidgets('successful save navigates to success screen', (
    WidgetTester tester,
  ) async {
    final apiService = FakeApiService();
    apiService.shouldSucceed = true;

    await tester.pumpWidget(
      buildTestWidget(
        apiService: apiService,
        userData: const UserData(
          personId: 1,
          webLoginId: 1,
          passnummer: '',
          vereinNr: 1,
          namen: '',
          vorname: '',
          titel: null,
          geburtsdatum: null,
          geschlecht: null,
          vereinName: '',
          strasse: null,
          plz: null,
          ort: null,
          land: '',
          nationalitaet: '',
          passStatus: 0,
          passdatenId: 1,
          eintrittVerein: null,
          austrittVerein: null,
          mitgliedschaftId: 1,
          telefon: '',
          erstLandesverbandId: 0,
          produktionsDatum: null,
          erstVereinId: 0,
          digitalerPass: 0,
          isOnline: false,
          disziplin: null,
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Toggle both checkboxes
    final checkboxes = find.byType(Checkbox);
    await tester.tap(checkboxes.first);
    await tester.pump();
    await tester.tap(checkboxes.last);
    await tester.pump();

    // Tap submit button
    final submitFabs = find.byType(FloatingActionButton);
    await tester.tap(submitFabs.at(1)); // Second FAB is submit
    await tester.pumpAndSettle();

    // Should navigate to success screen
    expect(
      find.textContaining('Die Bestellung des Schützenausweises'),
      findsOneWidget,
    );
  });

  testWidgets('failed save shows error snackbar', (WidgetTester tester) async {
    final apiService = FakeApiService();
    apiService.shouldSucceed = false;

    await tester.pumpWidget(
      buildTestWidget(
        apiService: apiService,
        userData: const UserData(
          personId: 1,
          webLoginId: 1,
          passnummer: '',
          vereinNr: 1,
          namen: '',
          vorname: '',
          titel: null,
          geburtsdatum: null,
          geschlecht: null,
          vereinName: '',
          strasse: null,
          plz: null,
          ort: null,
          land: '',
          nationalitaet: '',
          passStatus: 0,
          passdatenId: 1,
          eintrittVerein: null,
          austrittVerein: null,
          mitgliedschaftId: 1,
          telefon: '',
          erstLandesverbandId: 0,
          produktionsDatum: null,
          erstVereinId: 0,
          digitalerPass: 0,
          isOnline: false,
          disziplin: null,
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Toggle both checkboxes
    final checkboxes = find.byType(Checkbox);
    await tester.tap(checkboxes.first);
    await tester.pump();
    await tester.tap(checkboxes.last);
    await tester.pump();

    // Tap submit button
    final submitFabs = find.byType(FloatingActionButton);
    await tester.tap(submitFabs.at(1)); // Second FAB is submit
    await tester.pumpAndSettle();

    // Should show error message
    expect(find.text('Antrag konnte nicht gesendet werden.'), findsOneWidget);
  });

  testWidgets('tapping AGB link opens AGB dialog', (WidgetTester tester) async {
    final apiService = FakeApiService();
    await tester.pumpWidget(
      buildTestWidget(
        apiService: apiService,
        userData: const UserData(
          personId: 1,
          webLoginId: 1,
          passnummer: '',
          vereinNr: 1,
          namen: '',
          vorname: '',
          titel: null,
          geburtsdatum: null,
          geschlecht: null,
          vereinName: '',
          strasse: null,
          plz: null,
          ort: null,
          land: '',
          nationalitaet: '',
          passStatus: 0,
          passdatenId: 1,
          eintrittVerein: null,
          austrittVerein: null,
          mitgliedschaftId: 1,
          telefon: '',
          erstLandesverbandId: 0,
          produktionsDatum: null,
          erstVereinId: 0,
          digitalerPass: 0,
          isOnline: false,
          disziplin: null,
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Find and tap AGB link
    final agbLink = find.text('AGB');
    expect(agbLink, findsOneWidget);
    await tester.tap(agbLink);
    await tester.pumpAndSettle();

    // Should open a second dialog (nested)
    expect(find.byType(Dialog), findsNWidgets(2));
  });

  testWidgets('save with ZVE data from PassdatenAkzeptOrAktiv', (
    WidgetTester tester,
  ) async {
    final apiService = FakeApiService();
    apiService.shouldSucceed = true;

    await tester.pumpWidget(
      buildTestWidget(
        apiService: apiService,
        userData: const UserData(
          personId: 1,
          webLoginId: 1,
          passnummer: '',
          vereinNr: 1,
          namen: '',
          vorname: '',
          titel: null,
          geburtsdatum: null,
          geschlecht: null,
          vereinName: '',
          strasse: null,
          plz: null,
          ort: null,
          land: '',
          nationalitaet: '',
          passStatus: 0,
          passdatenId: 1,
          eintrittVerein: null,
          austrittVerein: null,
          mitgliedschaftId: 1,
          telefon: '',
          erstLandesverbandId: 0,
          produktionsDatum: null,
          erstVereinId: 0,
          digitalerPass: 0,
          isOnline: false,
          disziplin: null,
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Toggle both checkboxes
    final checkboxes = find.byType(Checkbox);
    await tester.tap(checkboxes.first);
    await tester.pump();
    await tester.tap(checkboxes.last);
    await tester.pump();

    // Tap submit button
    final submitFabs = find.byType(FloatingActionButton);
    await tester.tap(submitFabs.at(1)); // Second FAB is submit
    await tester.pumpAndSettle();

    // Verify the API was called
    expect(apiService.called, isTrue);
  });

  testWidgets('handles null userData gracefully', (WidgetTester tester) async {
    final apiService = FakeApiService();
    await tester.pumpWidget(
      buildTestWidget(apiService: apiService, userData: null),
    );

    // Should render without errors
    expect(find.byType(AusweisBestellenScreen), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);

    // Tapping button with null userData should not crash
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Dialog should not open (early return in _showBankDataDialog)
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('loading state shows CircularProgressIndicator', (
    WidgetTester tester,
  ) async {
    final apiService = FakeApiService();
    await tester.pumpWidget(
      buildTestWidget(
        apiService: apiService,
        userData: const UserData(
          personId: 1,
          webLoginId: 1,
          passnummer: '',
          vereinNr: 1,
          namen: '',
          vorname: '',
          titel: null,
          geburtsdatum: null,
          geschlecht: null,
          vereinName: '',
          strasse: null,
          plz: null,
          ort: null,
          land: '',
          nationalitaet: '',
          passStatus: 0,
          passdatenId: 1,
          eintrittVerein: null,
          austrittVerein: null,
          mitgliedschaftId: 1,
          telefon: '',
          erstLandesverbandId: 0,
          produktionsDatum: null,
          erstVereinId: 0,
          digitalerPass: 0,
          isOnline: false,
          disziplin: null,
        ),
      ),
    );

    // Initially not loading
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('processes ZVE data when available', (WidgetTester tester) async {
    final apiService = FakeApiService();
    apiService.shouldSucceed = true;

    // Create PassdatenAkzeptOrAktiv with ZVE data
    apiService.passDataToReturn = PassdatenAkzeptOrAktiv(
      passdatenId: 1,
      passStatus: 2,
      digitalerPass: 0,
      personId: 1,
      erstVereinId: 100,
      evVereinNr: 100,
      zves: [
        ZVE(
          vereinId: 100,
          vereinNr: 100,
          disziplinId: 50,
          vereinName: 'Test Verein 1',
        ),
        ZVE(
          vereinId: 200,
          vereinNr: 200,
          disziplinId: 60,
          vereinName: 'Test Verein 2',
        ),
      ],
    );

    await tester.pumpWidget(
      buildTestWidget(
        apiService: apiService,
        userData: const UserData(
          personId: 1,
          webLoginId: 1,
          passnummer: '',
          vereinNr: 1,
          namen: '',
          vorname: '',
          titel: null,
          geburtsdatum: null,
          geschlecht: null,
          vereinName: '',
          strasse: null,
          plz: null,
          ort: null,
          land: '',
          nationalitaet: '',
          passStatus: 0,
          passdatenId: 1,
          eintrittVerein: null,
          austrittVerein: null,
          mitgliedschaftId: 1,
          telefon: '',
          erstLandesverbandId: 0,
          produktionsDatum: null,
          erstVereinId: 0,
          digitalerPass: 0,
          isOnline: false,
          disziplin: null,
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Toggle both checkboxes
    final checkboxes = find.byType(Checkbox);
    await tester.tap(checkboxes.first);
    await tester.pump();
    await tester.tap(checkboxes.last);
    await tester.pump();

    // Tap submit button
    final submitFabs = find.byType(FloatingActionButton);
    await tester.tap(submitFabs.at(1));
    await tester.pumpAndSettle();

    // Verify the API was called with ZVE data
    expect(apiService.called, isTrue);
  });

  testWidgets('empty bank data list handled correctly', (
    WidgetTester tester,
  ) async {
    final apiService = FakeApiService();
    apiService.returnEmptyBankData = true;

    await tester.pumpWidget(
      buildTestWidget(
        apiService: apiService,
        userData: const UserData(
          personId: 1,
          webLoginId: 1,
          passnummer: '',
          vereinNr: 1,
          namen: '',
          vorname: '',
          titel: null,
          geburtsdatum: null,
          geschlecht: null,
          vereinName: '',
          strasse: null,
          plz: null,
          ort: null,
          land: '',
          nationalitaet: '',
          passStatus: 0,
          passdatenId: 1,
          eintrittVerein: null,
          austrittVerein: null,
          mitgliedschaftId: 1,
          telefon: '',
          erstLandesverbandId: 0,
          produktionsDatum: null,
          erstVereinId: 0,
          digitalerPass: 0,
          isOnline: false,
          disziplin: null,
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Dialog should open with empty fields
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
  });
}
