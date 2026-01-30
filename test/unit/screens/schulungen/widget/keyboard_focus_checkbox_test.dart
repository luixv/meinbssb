import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

import 'package:meinbssb/screens/schulungen/widgets/keyboard_focus_checkbox.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KeyboardFocusCheckbox', () {
    testWidgets('renders and toggles via tap', (WidgetTester tester) async {
      bool? changedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: KeyboardFocusCheckbox(
                label: 'Test',
                value: false,
                onChanged: (v) {
                  changedValue = v;
                },
              ),
            ),
          ),
        ),
      );

      // Should find a Checkbox widget
      expect(find.byType(Checkbox), findsOneWidget);

      // Tap the checkbox - should call onChanged with true
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(changedValue, isTrue);
    });

    testWidgets(
      'pressing Enter toggles when focused and keyboard highlight mode is traditional',
      (WidgetTester tester) async {
        bool? changedValue;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: KeyboardFocusCheckbox(
                  label: 'EnterTest',
                  value: false,
                  onChanged: (v) {
                    changedValue = v;
                  },
                ),
              ),
            ),
          ),
        );

        // Simulate keyboard navigation to focus the widget
        final widgetFinder = find.byType(KeyboardFocusCheckbox);
        expect(widgetFinder, findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab); // move focus
        await tester.pumpAndSettle();

        // Send an Enter key event (down+up)
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(changedValue, isTrue);
      },
    );

    testWidgets(
      'shows focus decoration only when focused in keyboard highlight mode',
      (WidgetTester tester) async {
        // We'll inspect the Container decoration used in the widget
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: KeyboardFocusCheckbox(
                  label: 'DecorTest',
                  value: false,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        );

        // Initially highlightMode is usually touch; ensure decoration is NOT present
        final containerBefore =
            tester
                .widgetList<Container>(
                  find.descendant(
                    of: find.byType(KeyboardFocusCheckbox),
                    matching: find.byType(Container),
                  ),
                )
                .first;
        expect(
          containerBefore.decoration,
          isNull,
          reason: 'No decoration expected when not focused/keyboard mode.',
        );

        // Simulate keyboard navigation to focus the widget
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        // Now the decorated Container should be present as the inner Container used by the widget
        final containerAfter =
            tester
                .widgetList<Container>(
                  find.descendant(
                    of: find.byType(KeyboardFocusCheckbox),
                    matching: find.byType(Container),
                  ),
                )
                .first;

        expect(
          containerAfter.decoration,
          isA<BoxDecoration>(),
          reason: 'Decoration should appear when focused in keyboard mode.',
        );

        final BoxDecoration dec = containerAfter.decoration as BoxDecoration;
        // check border is present and has a width (matching implementation)
        expect(dec.border, isNotNull);
        expect(dec.border!.top.width, greaterThan(0.0));

        // No highlightMode reset needed
      },
    );
  });
}
