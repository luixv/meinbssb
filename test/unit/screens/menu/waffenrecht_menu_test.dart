import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/menu/waffenrecht_menu.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

void main() {
  group('WaffenrechtMenuScreen', () {
    testWidgets('renders Bedürfnisse menu item and navigates on tap', (
      WidgetTester tester,
    ) async {
      final testUser = UserData(
        personId: 1,
        webLoginId: 2,
        passnummer: '12345',
        vereinNr: 10,
        namen: 'Mustermann',
        vorname: 'Max',
        vereinName: 'Testverein',
        passdatenId: 100,
        mitgliedschaftId: 200,
      );
      final observer = TestNavigatorObserver();
      await tester.pumpWidget(
        ChangeNotifierProvider<FontSizeProvider>(
          create: (_) => FontSizeProvider(),
          child: MaterialApp(
            home: WaffenrechtMenuScreen(
              userData: testUser,
              isLoggedIn: true,
              onLogout: () {},
            ),
            navigatorObservers: [observer],
          ),
        ),
      );
      expect(find.text('Bedürfnisse'), findsOneWidget);
      await tester.tap(find.text('Bedürfnisse'));
      await tester.pumpAndSettle();
      // Should have pushed a new route
      expect(observer.pushedRoutes.isNotEmpty, isTrue);
    });
  });
}

class TestNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = <Route<dynamic>>[];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }
}
