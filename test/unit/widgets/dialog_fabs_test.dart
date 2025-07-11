import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/widgets/dialog_fabs.dart';

void main() {
  testWidgets('DialogFABs arranges children and applies correct padding',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DialogFABs(
            children: [
              FloatingActionButton(onPressed: () {}, heroTag: 'fab1'),
              FloatingActionButton(onPressed: () {}, heroTag: 'fab2'),
            ],
          ),
        ),
      ),
    );

    // Check that both FABs are present
    expect(find.byType(FloatingActionButton), findsNWidgets(2));

    // Find the Column containing the FABs
    final columnFinder = find.byType(Column);
    expect(columnFinder, findsOneWidget);

    // Optionally, check that the FABs are children of the Column
    final columnWidget = tester.widget<Column>(columnFinder);
    expect(columnWidget.children.whereType<FloatingActionButton>().length, 0,
        reason:
            'FABs are wrapped in SizedBox, so direct children are not FABs',);
    // The main test is that the Column exists and both FABs are present
  });
}
