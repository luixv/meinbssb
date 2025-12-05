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
    reset(TestHelper.mockApiService);
    
    passnummer = 'TEST-123';
    userData = UserData(
      personId: 1,
      webLoginId: 999,
      passnummer: passnummer,
      vereinNr: 42,
      namen: 'Test',
      vorname: 'User',
      vereinName: 'Test Verein',
      passdatenId: 1,
      mitgliedschaftId: 1,
    );
    currentYear = DateTime.now().year;

    when(TestHelper.mockApiService.configService)
        .thenReturn(TestHelper.mockConfigService);
    when(TestHelper.mockApiService.hasInternet())
        .thenAnswer((_) async => true);
    when(TestHelper.mockApiService.fetchGewinneEx(any, any))
        .thenAnswer((_) async => <Gewinn>[]);
    when(TestHelper.mockApiService.fetchBankdatenMyBSSB(any))
        .thenAnswer((_) async => <BankData>[]);
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

  group('SeventyFiveJahreBSSBGewinnScreen - Initialization', () {
    testWidgets('should render screen with title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('75 Jahre BSSB'), findsOneWidget);
    });

    testWidgets('should fetch Gewinne on init', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      verify(TestHelper.mockApiService.fetchGewinneEx(currentYear, passnummer))
          .called(1);
    });

    testWidgets('should fetch bank data on init', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      verify(TestHelper.mockApiService.fetchBankdatenMyBSSB(userData.webLoginId))
          .called(1);
    });
  });

  group('SeventyFiveJahreBSSBGewinnScreen - Bank Data', () {
    testWidgets('should prefill bank data when available', (tester) async {
      when(TestHelper.mockApiService.fetchBankdatenMyBSSB(any))
          .thenAnswer((_) async => [
                BankData(
                  id: 1,
                  webloginId: userData.webLoginId,
                  kontoinhaber: 'Max Mustermann',
                  iban: 'DE89370400440532013000',
                  bic: 'COBADEFFXXX',
                  mandatSeq: 1,
                ),
              ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Max Mustermann'), findsOneWidget);
      expect(find.text('DE89370400440532013000'), findsOneWidget);
      expect(find.text('COBADEFFXXX'), findsOneWidget);
    });
  });
  group('SeventyFiveJahreBSSBGewinnScreen - Submit', () {
    testWidgets('should have submit button disabled when no pending Gewinne',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Gewinne wurden abgerufen.'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('should enable submit button with valid data', (tester) async {
      when(TestHelper.mockApiService.fetchGewinneEx(any, any))
          .thenAnswer((_) async => [
                Gewinn(
                  gewinnId: 1,
                  jahr: currentYear,
                  isSachpreis: false,
                  geldpreis: 100,
                  sachpreis: '',
                  wettbewerb: 'Test',
                  abgerufenAm: '',
                  platz: 1,
                ),
              ]);

      when(TestHelper.mockApiService.fetchBankdatenMyBSSB(any))
          .thenAnswer((_) async => [
                BankData(
                  id: 1,
                  webloginId: userData.webLoginId,
                  kontoinhaber: 'Test User',
                  iban: 'DE89370400440532013000',
                  bic: 'COBADEFFXXX',
                  mandatSeq: 1,
                ),
              ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Gewinne abrufen'), findsOneWidget);
    });
  });
}
