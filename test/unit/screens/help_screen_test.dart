import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/help_screen.dart';
import '../helpers/test_helper.dart';

void main() {
  setUp(() {
    TestHelper.setupMocks();
  });

  Widget createHelpScreen() {
    return TestHelper.createTestApp(
      home: HelpScreen(
        userData: null,
        isLoggedIn: false,
        onLogout: () {},
      ),
    );
  }

  testWidgets('renders correctly with user data', (WidgetTester tester) async {
    await tester.pumpWidget(createHelpScreen());
    await tester.pumpAndSettle();
    expect(find.text('FAQ'), findsOneWidget);
    expect(find.text('Was ist Mein BSSB?'), findsOneWidget);
  });
}
