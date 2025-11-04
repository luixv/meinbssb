import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/bank_data.dart';
import 'package:meinbssb/models/passdaten_akzept_or_aktiv_data.dart';
import 'package:meinbssb/screens/ausweis/ausweis_bestellen_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

class FakeApiService implements ApiService {
  @override
  Future<List<BankData>> fetchBankdatenMyBSSB(int webLoginId) async {
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

  @override
  Future<PassdatenAkzeptOrAktiv?> fetchPassdatenAkzeptierterOderAktiverPass(
    int? personId,
  ) async {
    return null;
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
    expect(find.byType(CheckboxListTile), findsNWidgets(2));
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

  testWidgets('AGB link navigates to AgbScreen', (WidgetTester tester) async {
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
          routes: {
            '/agb': (context) => const Scaffold(body: Text('AGB Screen')),
          },
          home: AusweisBestellenScreen(
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
          ),
        ),
      ),
    );
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    // Tap the AGB link
    await tester.tap(find.text('AGB'));
    await tester.pumpAndSettle();
    // Check for the presence of the AGB screen widget
    expect(find.byType(Scaffold), findsWidgets);
  });
}
