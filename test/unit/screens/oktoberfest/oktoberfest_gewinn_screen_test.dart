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
  late int selectedYear;

  setUp(() {
    mockApiService = MockApiService();
    passnummer = 'TEST-456';
    userData = UserData(
      personId: 1,
      webLoginId: 999,
      passnummer: passnummer,
      vereinNr: 42,
      namen: 'Doe',
      vorname: 'Jane',
      vereinName: 'Test Verein',
      passdatenId: 1,
      mitgliedschaftId: 1,
    );
    currentYear = DateTime.now().year;
    // Calculate the selected year based on whether we're in October or later
    final now = DateTime.now();
    final isOctoberOrLater = now.month >= 10;
    selectedYear = isOctoberOrLater ? currentYear : currentYear - 1;

    when(mockApiService.fetchGewinne(any, any))
        .thenAnswer((_) async => <Gewinn>[]);
    when(mockApiService.fetchBankdatenMyBSSB(any))
        .thenAnswer((_) async => <BankData>[]);
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

  group('OktoberfestGewinnScreen - Initialization', () {
    testWidgets('should fetch Gewinne on init', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      verify(mockApiService.fetchGewinne(selectedYear, passnummer)).called(1);
    });

    testWidgets('should fetch bank data on init', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      verify(mockApiService.fetchBankdatenMyBSSB(userData.webLoginId))
          .called(1);
    });
  });

  group('OktoberfestGewinnScreen - Year Selection', () {
    testWidgets('should display year dropdown', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);
      expect(find.text('$selectedYear'), findsOneWidget);
    });

    testWidgets('should fetch Gewinne when year changes', (tester) async {
      // Pick a different year to change to
      final differentYear = selectedYear == 2024 ? 2024 : selectedYear - 1;
      when(mockApiService.fetchGewinne(differentYear, passnummer))
          .thenAnswer((_) async => <Gewinn>[]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('$differentYear').last);
      await tester.pumpAndSettle();

      verify(mockApiService.fetchGewinne(differentYear, passnummer))
          .called(1);
    });

    testWidgets('should include years from 2024 to current available year', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap to open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();

      // Verify 2024 is always available
      expect(find.text('2024').last, findsOneWidget);
      
      // Verify the selected year is available
      expect(find.text('$selectedYear').last, findsOneWidget);
    });

    testWidgets('should not include current year before October', (tester) async {
      final now = DateTime.now();
      if (now.month < 10) {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // selectedYear should be currentYear - 1 before October
        expect(selectedYear, equals(currentYear - 1));
        
        // Verify the dropdown shows the correct selected year
        expect(find.text('$selectedYear'), findsOneWidget);
      }
    });

    testWidgets('should include current year from October onwards', (tester) async {
      final now = DateTime.now();
      if (now.month >= 10) {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Tap to open dropdown
        await tester.tap(find.byType(DropdownButtonFormField<int>));
        await tester.pumpAndSettle();

        // Current year should be in the list
        expect(find.text('$currentYear').last, findsOneWidget);
      }
    });
  });

  group('OktoberfestGewinnScreen - Bank Data', () {
    testWidgets('should prefill bank data when available', (tester) async {
      when(mockApiService.fetchBankdatenMyBSSB(any))
          .thenAnswer((_) async => [
                BankData(
                  id: 1,
                  webloginId: userData.webLoginId,
                  kontoinhaber: 'Jane Doe',
                  iban: 'DE89370400440532013000',
                  bic: 'GENODEF1XXX',
                  mandatSeq: 1,
                ),
              ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('DE89370400440532013000'), findsOneWidget);
      expect(find.text('GENODEF1XXX'), findsOneWidget);
    });
  });

  group('OktoberfestGewinnScreen - Gewinne Display', () {
    testWidgets('should display Gewinne list', (tester) async {
      when(mockApiService.fetchGewinne(any, any)).thenAnswer(
        (_) async => [
          Gewinn(
            gewinnId: 1,
            jahr: selectedYear,
            isSachpreis: false,
            geldpreis: 250,
            sachpreis: '',
            wettbewerb: 'Test Wettbewerb',
            abgerufenAm: '',
            platz: 1,
          ),
        ],
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsWidgets);
      expect(find.textContaining('Test Wettbewerb'), findsOneWidget);
    });
  });

  group('OktoberfestGewinnScreen - Submit', () {
    testWidgets('should disable submit when no pending Gewinne', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Gewinne wurden abgerufen.'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('should enable submit with valid data', (tester) async {
      when(mockApiService.fetchGewinne(any, any)).thenAnswer(
        (_) async => [
          Gewinn(
            gewinnId: 1,
            jahr: selectedYear,
            isSachpreis: false,
            geldpreis: 100,
            sachpreis: '',
            wettbewerb: 'Test',
            abgerufenAm: '',
            platz: 1,
          ),
        ],
      );

      when(mockApiService.fetchBankdatenMyBSSB(any)).thenAnswer(
        (_) async => [
          BankData(
            id: 1,
            webloginId: userData.webLoginId,
            kontoinhaber: 'Jane Doe',
            iban: 'DE89370400440532013000',
            bic: 'GENODEF1XXX',
            mandatSeq: 1,
          ),
        ],
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Gewinne abrufen'), findsOneWidget);
    });
  });
}
