import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/widgets/dialog_fabs.dart';
import 'package:meinbssb/constants/ui_constants.dart';

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

    // Find the Row containing the FABs
    final rowFinder = find.byType(Row);
    expect(rowFinder, findsOneWidget);

    // Find the Padding widget that is the direct parent of this Row
    final paddingFinder = find.ancestor(
      of: rowFinder,
      matching: find.byType(Padding),
    );
    expect(paddingFinder, findsOneWidget);
    final padding = tester.widget<Padding>(paddingFinder);
    final paddingValue = padding.padding as EdgeInsets;
    expect(paddingValue.right, UIConstants.dialogFabRight);
    expect(paddingValue.bottom, UIConstants.dialogFabBottom);
  });
}
