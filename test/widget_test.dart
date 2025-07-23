// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import 'unit/helpers/test_helper.dart';

void main() {
  setUp(() {
    TestHelper.setupMocks();
  });

  testWidgets('ScaledText widget renders correctly', (WidgetTester tester) async {
    // Build a simple widget to test basic functionality
    await tester.pumpWidget(
      TestHelper.createTestApp(
        home: const Scaffold(
          body: Center(
            child: ScaledText(
              'Test Text',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );

    // Verify that the text widget renders
    expect(find.text('Test Text'), findsOneWidget);
    expect(find.byType(ScaledText), findsOneWidget);
  });

  testWidgets('Material app basic structure', (WidgetTester tester) async {
    // Test a simple material app structure without complex providers
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Test App')),
          body: const Center(child: Text('Hello World')),
        ),
      ),
    );

    // Verify basic structure
    expect(find.text('Test App'), findsOneWidget);
    expect(find.text('Hello World'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });
}
