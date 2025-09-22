import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/starting_rights_screen.dart';

import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/services/core/font_size_provider.dart';

import 'package:meinbssb/models/disziplin_data.dart';
import 'package:meinbssb/models/pass_data_zve_data.dart';
import 'package:meinbssb/models/passdaten_akzept_or_aktiv_data.dart';
import 'package:meinbssb/models/zweitmitgliedschaft_data.dart';
import 'package:meinbssb/models/user_data.dart';

class FakeApiService implements ApiService {
  bool passantragShouldSucceed = true;

  @override
  Future<bool> bssbAppPassantrag(
    Map<int, Map<String, int?>> secondColumns,
    int? passdatenId,
    int? personId,
    int? erstVereinId,
    int digitalerPass,
    int antragsTyp,
  ) async {
    return passantragShouldSucceed;
  }

  @override
  Future<void> sendStartingRightsChangeNotifications({
    required int personId,
  }) async {}

  @override
  Future<List<Disziplin>> fetchDisziplinen() async => [];

  @override
  Future<List<PassDataZVE>> fetchPassdatenZVE(
    int passdatenId,
    int personId,
  ) async =>
      [];

  @override
  Future<PassdatenAkzeptOrAktiv?> fetchPassdatenAkzeptierterOderAktiverPass(
    int personId,
  ) async =>
      null;

  @override
  Future<List<ZweitmitgliedschaftData>> fetchZweitmitgliedschaftenZVE(
    int personId,
    int passStatus,
  ) async =>
      [];

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
    fakeApiService = FakeApiService();
    fakeNetworkService = FakeNetworkService();
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

  testWidgets('shows save FAB and success snackbar when saving',
      (tester) async {
    // We need to trigger _hasUnsavedChanges = true.
    // The easiest way is to tap the checkbox for "zusätzlicher physikalischer Ausweis"
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

    // Tap the FAB to save
    await tester.tap(fabFinder);
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

    // Tap the FAB to save
    await tester.tap(fabFinder);
    await tester.pumpAndSettle();

    expect(find.textContaining('Fehler beim Speichern'), findsOneWidget);
  });
}
