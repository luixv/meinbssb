import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/menu/oktoberfest_menu.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import '../../helpers/test_helper.dart';

import 'package:meinbssb/services/api_service.dart';

void main() {
  setUp(() {
    TestHelper.setupMocks();
  });
  group('OktoberfestScreen', () {
    final userData = const UserData(
      personId: 1,
      webLoginId: 1,
      passnummer: '123456',
      vereinNr: 1,
      namen: 'Mustermann',
      vorname: 'Max',
      titel: null,
      geburtsdatum: null,
      geschlecht: null,
      vereinName: 'Testverein',
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
    );

    Widget buildTestWidget() {
      return MultiProvider(
        providers: [
          Provider<ApiService>.value(value: TestHelper.mockApiService),
          ChangeNotifierProvider<FontSizeProvider>(
            create: (_) => FontSizeProvider(),
          ),
        ],
        child: MaterialApp(
          home: OktoberfestScreen(
            userData: userData,
            isLoggedIn: true,
            onLogout: () {},
          ),
        ),
      );
    }

    testWidgets('shows menu items', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Oktoberfest'), findsWidgets); // Allow multiple
      expect(find.text('Meine Ergebnisse'), findsOneWidget);
      expect(find.text('Meine Gewinne'), findsOneWidget);
    });

    testWidgets('tapping Meine Ergebnisse navigates', (tester) async {
      // Stub fetchResults for navigation
      when(
        TestHelper.mockApiService.fetchResults(any),
      ).thenAnswer((_) async => []);
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Meine Ergebnisse'));
      await tester.pumpAndSettle();
      // Should navigate to OktoberfestResultsScreen, but we just check navigation occurred
      expect(find.byType(OktoberfestScreen), findsNothing);
    });

    testWidgets('tapping Meine Gewinne navigates', (tester) async {
      // Stub fetchGewinne for navigation
      when(
        TestHelper.mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => []);
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Meine Gewinne'));
      await tester.pumpAndSettle();
      // Should navigate to OktoberfestGewinnScreen, but we just check navigation occurred
      expect(find.byType(OktoberfestScreen), findsNothing);
    });
  });
}
