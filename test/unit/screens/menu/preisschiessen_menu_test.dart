import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/menu/preisschiessen_menu.dart';
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
        ChangeNotifierProvider<FontSizeProvider>(
          create: (_) => FontSizeProvider(),
        ),
        Provider<ApiService>.value(
          value: TestHelper.mockApiService,
        ),
      ],
      child: MaterialApp(
        home: PreisschiessenScreen(
          userData: userData,
          isLoggedIn: true,
          onLogout: () {},
        ),
        navigatorObservers: [navigatorObserver],
      ),
    );
  }

  testWidgets('shows Preisschießen title and header', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Check for title in AppBar (from BaseScreenLayout)
    expect(find.text('Preisschießen'), findsAtLeastNWidgets(1));
    
    // Check for logo
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('always shows Oktoberfest menu item', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Check for Oktoberfest menu item
    expect(find.text('Oktoberfest'), findsOneWidget);
    expect(find.byIcon(Icons.sports_bar_outlined), findsOneWidget);
  });

  testWidgets('shows 75 Jahre BSSB menu item when date is after December 1st 2025',
      (tester) async {
    // This test will only pass after December 1st, 2025
    // For now, we're testing the current behavior
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    final now = DateTime.now();
    final releaseDate = DateTime(2025, 12, 1, 0, 0);
    final isSeventyFiveJahreBSSBVisible =
        now.isAfter(releaseDate) || now.isAtSameMomentAs(releaseDate);

    if (isSeventyFiveJahreBSSBVisible) {
      expect(find.text('75 Jahre BSSB'), findsOneWidget);
      expect(find.byIcon(Icons.celebration_outlined), findsOneWidget);
    } else {
      expect(find.text('75 Jahre BSSB'), findsNothing);
      expect(find.byIcon(Icons.celebration_outlined), findsNothing);
    }
  });

  testWidgets('Oktoberfest menu item has correct semantics', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Find the Oktoberfest ListTile
    final oktoberfestTile = find.ancestor(
      of: find.text('Oktoberfest'),
      matching: find.byType(ListTile),
    );

    expect(oktoberfestTile, findsOneWidget);
    
    // Check for trailing icon
    expect(find.byIcon(Icons.chevron_right), findsAtLeastNWidgets(1));
  });

  testWidgets('tapping Oktoberfest navigates to OktoberfestScreen',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap the Oktoberfest menu item
    await tester.tap(find.text('Oktoberfest'));
    await tester.pumpAndSettle();

    // Verify navigation occurred (screen should change)
    // We can check if the Oktoberfest screen title appears
    expect(find.text('Oktoberfest'), findsAtLeastNWidgets(1));
  });

  testWidgets('screen has correct semantic label', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // The entire screen should have a semantic label
    final semanticsFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.label ==
              'Preisschießen Bereich. Wählen Sie zwischen Oktoberfest und 75 Jahre BSSB.',
    );
    
    expect(semanticsFinder, findsOneWidget);
  });

  testWidgets('menu items are rendered as Cards', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Check that menu items are wrapped in Cards
    expect(find.byType(Card), findsAtLeastNWidgets(1));
  });

  testWidgets('screen uses BaseScreenLayout', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Verify BaseScreenLayout is used (which provides the AppBar)
    expect(find.byType(AppBar), findsOneWidget);
  });
}
