import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/menu/oktoberfest_menu.dart';
import 'package:meinbssb/screens/oktoberfest/oktoberfest_gewinn_screen.dart';
import 'package:meinbssb/screens/oktoberfest/oktoberfest_results_screen.dart';
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
        home: OktoberfestScreen(
          userData: userData,
          isLoggedIn: true,
          onLogout: () {},
        ),
      ),
    );
  }


  group('Oktoberfest menu', () {
    testWidgets('renders heading and menu cards', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Oktoberfest'), findsWidgets);
      expect(find.text('Meine Ergebnisse'), findsOneWidget);
      expect(find.text('Meine Gewinne'), findsOneWidget);
    });

    testWidgets('navigates to results screen', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Meine Ergebnisse'));
      await tester.pumpAndSettle();

      expect(find.byType(OktoberfestResultsScreen), findsOneWidget);
    });

    testWidgets('navigates to gewinn screen', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Meine Gewinne'));
      await tester.pumpAndSettle();

      expect(find.byType(OktoberfestGewinnScreen), findsOneWidget);
    });
  });
}

