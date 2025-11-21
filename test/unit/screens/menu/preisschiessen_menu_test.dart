import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/menu/preisschiessen_menu.dart';
import 'package:meinbssb/screens/menu/oktoberfest_menu.dart';
import 'package:meinbssb/screens/oktoberfest/seventyfive_jahre_bssb_gewinn_screen.dart';
import 'package:meinbssb/services/api_service.dart';

import '../../helpers/test_helper.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockNavigatorObserver navigatorObserver;

  const userData = UserData(
    personId: 1,
    webLoginId: 1,
    passnummer: '123456',
    vereinNr: 1,
    namen: 'Mustermann',
    vorname: 'Max',
    vereinName: 'Testverein',
    passdatenId: 1,
    mitgliedschaftId: 1,
    land: '',
    nationalitaet: '',
    passStatus: 0,
    telefon: '',
    erstLandesverbandId: 0,
    erstVereinId: 0,
    digitalerPass: 0,
    isOnline: false,
  );

  setUp(() {
    TestHelper.setupMocks();
    navigatorObserver = MockNavigatorObserver();
    when(TestHelper.mockApiService.fetchResults(any)).thenAnswer(
      (_) async => [],
    );
    when(TestHelper.mockApiService.fetchResults(any)).thenAnswer(
      (_) async => [],
    );
    when(TestHelper.mockApiService.fetchGewinne(any, any)).thenAnswer(
      (_) async => [],
    );
    when(TestHelper.mockApiService.fetchBankdatenMyBSSB(any)).thenAnswer(
      (_) async => [],
    );
  });

  Widget buildTestWidget() {
    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: TestHelper.mockApiService),
        ChangeNotifierProvider<FontSizeProvider>(
          create: (_) => FontSizeProvider(),
        ),
      ],
      child: MaterialApp(
        navigatorObservers: [navigatorObserver],
        home: PreisschiessenScreen(
          userData: userData,
          isLoggedIn: true,
          onLogout: () {},
        ),
      ),
    );
  }

  group('Preisschießen menu', () {
    testWidgets('renders heading and menu cards', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Preisschießen'), findsWidgets);
      expect(find.text('Oktoberfest'), findsOneWidget);
      expect(find.text('75 Jahre BSSB'), findsOneWidget);
    });

    testWidgets('navigates to Oktoberfest screen', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Oktoberfest'));
      await tester.pumpAndSettle();

      expect(find.byType(OktoberfestScreen), findsOneWidget);
    });

    testWidgets('navigates to 75 Jahre BSSB screen', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('75 Jahre BSSB'));
      await tester.pumpAndSettle();

      expect(find.byType(SeventyFiveJahreBSSBGewinnScreen), findsOneWidget);
    });
  });
}

