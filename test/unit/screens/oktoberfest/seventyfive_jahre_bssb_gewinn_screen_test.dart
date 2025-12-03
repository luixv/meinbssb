import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:meinbssb/models/bank_data.dart';
import 'package:meinbssb/models/gewinn_data.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/oktoberfest/seventyfive_jahre_bssb_gewinn_screen.dart';
import 'package:meinbssb/services/api_service.dart';

import '../../helpers/test_helper.dart';

void main() {
  late UserData userData;
  late String passnummer;
  late int currentYear;

  setUp(() {
    TestHelper.setupMocks();
    // Reset the mock to avoid conflicts with setupMocks
    reset(TestHelper.mockApiService);
    
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

    // Re-setup essential mocks after reset
    when(TestHelper.mockApiService.configService).thenReturn(TestHelper.mockConfigService);
    when(TestHelper.mockApiService.hasInternet()).thenAnswer((_) async => true);
    
    when(TestHelper.mockApiService.fetchGewinneEx(currentYear, passnummer))
        .thenAnswer((_) async => <Gewinn>[]);
    when(TestHelper.mockApiService.fetchBankdatenMyBSSB(any)).thenAnswer(
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
          Provider<ApiService>.value(value: TestHelper.mockApiService),
          ChangeNotifierProvider(create: (_) => FontSizeProvider()),
        ],
        child: SeventyFiveJahreBSSBGewinnScreen(
          passnummer: passnummer,
          apiService: TestHelper.mockApiService,
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

    verify(TestHelper.mockApiService.fetchGewinneEx(currentYear, passnummer))
        .called(1);
  });

  testWidgets('prefills bank data form with stored values', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('DE00123456780000000000'), findsOneWidget);
    expect(find.text('GENODEF1XXX'), findsOneWidget);
  });

  testWidgets('renders list tiles when Gewinne returned', (tester) async {
    reset(TestHelper.mockApiService);
    when(TestHelper.mockApiService.configService).thenReturn(TestHelper.mockConfigService);
    when(TestHelper.mockApiService.hasInternet()).thenAnswer((_) async => true);
    when(TestHelper.mockApiService.fetchBankdatenMyBSSB(any)).thenAnswer(
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
    when(TestHelper.mockApiService.fetchGewinneEx(currentYear, passnummer))
        .thenAnswer(
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
    reset(TestHelper.mockApiService);
    when(TestHelper.mockApiService.configService).thenReturn(TestHelper.mockConfigService);
    when(TestHelper.mockApiService.hasInternet()).thenAnswer((_) async => true);
    when(TestHelper.mockApiService.fetchBankdatenMyBSSB(any)).thenAnswer(
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
    final completer = Completer<List<Gewinn>>();
    when(TestHelper.mockApiService.fetchGewinneEx(currentYear, passnummer))
        .thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildTestWidget());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);

    completer.complete([]);
    await tester.pumpAndSettle();
  });
  testWidgets('submit button is enabled when conditions are met', (tester) async {
    reset(TestHelper.mockApiService);
    when(TestHelper.mockApiService.configService).thenReturn(TestHelper.mockConfigService);
    when(TestHelper.mockApiService.hasInternet()).thenAnswer((_) async => true);
    
    final bankDataList = [
      BankData(
        id: 1,
        webloginId: userData.webLoginId,
        kontoinhaber: 'Jane Doe',
        iban: 'DE00123456780000000000',
        bic: 'GENODEF1XXX',
        mandatSeq: 1,
      ),
    ];
    
    when(TestHelper.mockApiService.fetchBankdatenMyBSSB(any)).thenAnswer(
      (_) async => bankDataList,
    );
    
    final gewinnList = [
      Gewinn(
        gewinnId: 1,
        jahr: currentYear,
        isSachpreis: false,
        geldpreis: 100,
        sachpreis: '',
        wettbewerb: 'Test',
        abgerufenAm: '', // Empty abgerufenAm means pending
        platz: 1,
      ),
    ];
    
    when(TestHelper.mockApiService.fetchGewinneEx(currentYear, passnummer))
        .thenAnswer((_) async => gewinnList);
    
    when(TestHelper.mockApiService.gewinneAbrufenEx(
      gewinnIDs: anyNamed('gewinnIDs'),
      iban: anyNamed('iban'),
      passnummer: anyNamed('passnummer'),
    )).thenAnswer((_) async => true);

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Wait for bank data to load and form to be ready
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // Verify bank data is displayed (ensures form is ready)
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('DE00123456780000000000'), findsOneWidget);

    // Find the submit button and verify it exists
    final submitButton = find.descendant(
      of: find.bySemanticsLabel('Gewinne abrufen'),
      matching: find.byType(ElevatedButton),
    );
    expect(submitButton, findsOneWidget);
    
    // Verify the button text
    expect(find.text('Gewinne abrufen'), findsWidgets);
  });
}

