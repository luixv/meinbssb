import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/menu/waffenrecht_menu.dart';
import 'package:meinbssb/models/user_data.dart';

void main() {
  group('WaffenrechtMenuScreen', () {
    testWidgets('renders Bedürfnisse menu item and navigates on tap', (
      WidgetTester tester,
    ) async {
      bool navigated = false;
      final testUser = UserData(personId: 1, webLoginId: 2);
      await tester.pumpWidget(
        MaterialApp(
          home: WaffenrechtMenuScreen(
            userData: testUser,
            isLoggedIn: true,
            onLogout: () {},
          ),
          navigatorObservers: [
            TestNavigatorObserver(onPush: () => navigated = true),
          ],
        ),
      );
      // Check for Bedürfnisse menu item
      expect(find.text('Bedürfnisse'), findsOneWidget);
      // Tap the Bedürfnisse menu item
      await tester.tap(find.text('Bedürfnisse'));
      await tester.pumpAndSettle();
      // Should have navigated
      expect(navigated, isTrue);
    });
  });
}

class TestNavigatorObserver extends NavigatorObserver {
  final VoidCallback onPush;
  TestNavigatorObserver({required this.onPush});
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onPush();
    super.didPush(route, previousRoute);
  }
}
