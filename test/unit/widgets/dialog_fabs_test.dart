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

    // Check the structure of the Column
    final columnWidget = tester.widget<Column>(columnFinder);
    expect(columnWidget.children.length, 3, reason: 'Should have 2 FABs and 1 spacing SizedBox');
    
    // Verify the spacing between FABs
    final spacingWidget = columnWidget.children[1];
    expect(spacingWidget, isA<SizedBox>());
    expect((spacingWidget as SizedBox).height, equals(16));
    
    // Verify the FABs are present
    expect(find.byType(FloatingActionButton), findsNWidgets(2));
  });
}
