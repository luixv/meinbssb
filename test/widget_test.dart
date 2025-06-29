// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/app.dart' show MyApp;
import 'unit/helpers/test_helper.dart';

void main() {
  setUp(() {
    TestHelper.setupMocks();
  });

  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Build our app with proper providers and trigger a frame.
    await tester.pumpWidget(TestHelper.createTestApp(home: const MyApp()));

    // Verify that the app renders without crashing
    expect(find.byType(MyApp), findsOneWidget);
  });
}
