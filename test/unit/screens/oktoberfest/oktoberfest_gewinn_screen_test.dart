import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:meinbssb/models/bank_data.dart';
import 'package:meinbssb/models/gewinn_data.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/oktoberfest/oktoberfest_gewinn_screen.dart';
import 'package:meinbssb/services/api_service.dart';

import 'oktoberfest_gewinn_screen_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApiService;
  late UserData userData;
  late String passnummer;
  late int currentYear;

  setUp(() {
    mockApiService = MockApiService();
    passnummer = 'PASS-1';
    userData = UserData(
      personId: 1,
      webLoginId: 999,
      passnummer: passnummer,
      vereinNr: 42,
      namen: 'Doe',
      vorname: 'Jane',
      vereinName: 'Demo Verein',
      passdatenId: 77,
      mitgliedschaftId: 88,
    );
    currentYear = DateTime.now().year;

    when(mockApiService.fetchGewinne(any, any)).thenAnswer((_) async => []);
    when(mockApiService.fetchBankdatenMyBSSB(any)).thenAnswer(
      (_) async => [
        BankData(
          id: 1,
          webloginId: userData.webLoginId,
          kontoinhaber: 'Jane Doe',
          iban: 'DE00123456780000000000',
          bic: 'GENODEF1XXX',
          mandatSeq: 1,
        ),
      ],
    );
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<ApiService>.value(value: mockApiService),
          ChangeNotifierProvider(create: (_) => FontSizeProvider()),
        ],
        child: OktoberfestGewinnScreen(
          passnummer: passnummer,
          apiService: mockApiService,
          userData: userData,
          isLoggedIn: true,
          onLogout: () {},
        ),
      ),
    );
  }

  testWidgets('fetches Gewinne for current year on init', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    verify(mockApiService.fetchGewinne(currentYear, passnummer))
        .called(1);
  });

  testWidgets('prefills bank data form with stored values', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('DE00123456780000000000'), findsOneWidget);
    expect(find.text('GENODEF1XXX'), findsOneWidget);
  });

  testWidgets('changing year triggers new fetch', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    when(mockApiService.fetchGewinne(currentYear - 1, passnummer))
        .thenAnswer((_) async => [Gewinn(gewinnId: 1, jahr: currentYear - 1, isSachpreis: true, geldpreis: 0, sachpreis: 'Preis', wettbewerb: 'Test', abgerufenAm: '', platz: 1)]);

    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('${currentYear - 1}').last);
    await tester.pumpAndSettle();

    verify(mockApiService.fetchGewinne(currentYear - 1, passnummer))
        .called(1);
  });

  testWidgets('renders list tiles when Gewinne returned', (tester) async {
    when(mockApiService.fetchGewinne(any, any)).thenAnswer(
      (_) async => [
        Gewinn(
          gewinnId: 7,
          jahr: currentYear,
          isSachpreis: false,
          geldpreis: 250,
          sachpreis: '',
          wettbewerb: 'Schießen A',
          abgerufenAm: '',
          platz: 2,
        ),
      ],
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsWidgets);
    expect(find.textContaining('Schießen A'), findsOneWidget);
  });

  testWidgets('shows loading indicator while fetching', (tester) async {
    final completer = Completer<List<Gewinn>>();
    when(mockApiService.fetchGewinne(currentYear - 1, passnummer))
        .thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('${currentYear - 1}').last);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);

    completer.complete([]);
    await tester.pumpAndSettle();
  });
}
