import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/starting_rights_screen.dart';

import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

import 'package:meinbssb/models/disziplin_data.dart';
import 'package:meinbssb/models/pass_data_zve_data.dart';
import 'package:meinbssb/models/passdaten_akzept_or_aktiv_data.dart';
import 'package:meinbssb/models/zweitmitgliedschaft_data.dart';
import 'package:meinbssb/models/user_data.dart';

class FakeApiService implements ApiService {
  FakeApiService(this.networkService);
  bool passantragShouldSucceed = true;
  final NetworkService networkService;

  @override
  Future<bool> hasInternet() => networkService.hasInternet();

  @override
  Future<bool> bssbAppPassantrag(
    List<Map<String, dynamic>> zves,
    int? passdatenId,
    int? personId,
    int? erstVereinId,
    int digitalerPass,
    int antragsTyp,
  ) async {
    // Optionally check zves for test logic
    return passantragShouldSucceed;
  }

  @override
  Future<void> sendStartingRightsChangeNotifications({
    required int personId,
  }) async {}

  @override
  Future<List<Disziplin>> fetchDisziplinen() async => [
    const Disziplin(
      disziplinId: 1,
      disziplinNr: '1',
      disziplin: 'Test Disziplin',
    ),
  ];

  @override
  Future<List<PassDataZVE>> fetchPassdatenZVE(
    int passdatenId,
    int personId,
  ) async => [
    PassDataZVE(
      passdatenZvId: 1,
      zvVereinId: 1,
      vVereinNr: 123,
      disziplinNr: '1',
      gauId: 1,
      bezirkId: 1,
      disziAusblenden: 0,
      ersaetzendurchId: 0,
      zvMitgliedschaftId: 1,
      vereinName: 'Test ZVE Verein',
      disziplin: 'Test Disziplin',
      disziplinId: 1,
    ),
  ];

  @override
  Future<PassdatenAkzeptOrAktiv?> fetchPassdatenAkzeptierterOderAktiverPass(
    int? personId,
  ) async => PassdatenAkzeptOrAktiv(
    passdatenId: 1,
    personId: personId ?? 1,
    passStatus: 1,
    digitalerPass: 0,
    erstVereinId: 1,
    evVereinNr: 123,
  );

  @override
  Future<List<ZweitmitgliedschaftData>> fetchZweitmitgliedschaftenZVE(
    int personId,
    int passStatus,
  ) async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeNetworkService implements NetworkService {
  bool hasInternetValue = true;
  @override
  Future<bool> hasInternet() async => hasInternetValue;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late FakeApiService fakeApiService;
  late FakeNetworkService fakeNetworkService;
  late UserData userData;

  setUp(() {
    fakeNetworkService = FakeNetworkService();
    fakeApiService = FakeApiService(fakeNetworkService);
    userData = const UserData(
      personId: 1,
      passdatenId: 1,
      erstVereinId: 1,
      vereinName: 'Test Verein',
      webLoginId: 1,
      passnummer: 'P123',
      vereinNr: 123,
      namen: 'Mustermann',
      vorname: 'Max',
      mitgliedschaftId: 1,
    );
  });

  Widget createWidgetUnderTest({UserData? data}) {
    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: fakeApiService),
        Provider<NetworkService>.value(value: fakeNetworkService),
        ChangeNotifierProvider<FontSizeProvider>(
          create: (_) => FontSizeProvider(),
        ),
      ],
      child: MaterialApp(
        home: StartingRightsScreen(
          userData: data ?? userData,
          isLoggedIn: true,
          onLogout: () {},
        ),
      ),
    );
  }

  testWidgets('shows loading indicator initially', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows offline error if no internet', (tester) async {
    fakeNetworkService.hasInternetValue = false;
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Startrechte sind offline nicht verfügbar'),
      findsOneWidget,
    );
  });

  testWidgets('shows header after loading', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();
    expect(find.textContaining('Startrechte'), findsWidgets);
  });

  testWidgets('shows save FAB and success snackbar when saving', (
    tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Tap the checkbox to trigger unsaved changes
    final checkboxFinder = find.byType(Checkbox);
    expect(checkboxFinder, findsOneWidget);
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    // Now the FAB should be visible
    final fabFinder = find.byType(FloatingActionButton);
    expect(fabFinder, findsOneWidget);

    // Tap the FAB to open the confirmation dialog
    await tester.tap(fabFinder);
    await tester.pumpAndSettle();

    // The confirmation dialog should appear
    // The confirmation dialog should appear (check for the 'Ändern' button)
    expect(find.widgetWithText(ElevatedButton, 'Ändern'), findsOneWidget);

    // Tap the 'Ändern' button in the dialog
    final aendernButtonFinder = find.widgetWithText(ElevatedButton, 'Ändern');
    expect(aendernButtonFinder, findsOneWidget);
    await tester.tap(aendernButtonFinder);
    await tester.pumpAndSettle();

    expect(find.textContaining('erfolgreich gespeichert'), findsOneWidget);
  });

  testWidgets('shows error snackbar if save fails', (tester) async {
    fakeApiService.passantragShouldSucceed = false;
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Tap the checkbox to trigger unsaved changes
    final checkboxFinder = find.byType(Checkbox);
    expect(checkboxFinder, findsOneWidget);
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    // Now the FAB should be visible
    final fabFinder = find.byType(FloatingActionButton);
    expect(fabFinder, findsOneWidget);

    // Tap the FAB to open the confirmation dialog
    await tester.tap(fabFinder);
    await tester.pumpAndSettle();

    // The confirmation dialog should appear
    // The confirmation dialog should appear (check for the 'Ändern' button)
    expect(find.widgetWithText(ElevatedButton, 'Ändern'), findsOneWidget);

    // Tap the 'Ändern' button in the dialog
    final aendernButtonFinder = find.widgetWithText(ElevatedButton, 'Ändern');
    expect(aendernButtonFinder, findsOneWidget);
    await tester.tap(aendernButtonFinder);
    await tester.pumpAndSettle();

    expect(find.textContaining('Fehler beim Speichern'), findsOneWidget);
  });
}
