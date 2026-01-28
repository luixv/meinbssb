import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/widgets/delete_confirm_dialog.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

void main() {
  group('DeleteConfirmDialog', () {
    Widget buildDialog({
      VoidCallback? onDelete,
      VoidCallback? onCancel,
      double scaleFactor = 1.0,
    }) {
      return ChangeNotifierProvider<FontSizeProvider>(
        create: (_) {
          final provider = FontSizeProvider();
          provider.setScaleFactor(scaleFactor);
          return provider;
        },
        child: MaterialApp(
          home: Builder(
            builder:
                (context) => DeleteConfirmDialog(
                  title: 'Test Title',
                  message: 'Test Message',
                  onDelete: onDelete,
                  onCancel: onCancel,
                ),
          ),
        ),
      );
    }

    testWidgets('renders title and message', (WidgetTester tester) async {
      await tester.pumpWidget(buildDialog());
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Message'), findsOneWidget);
    });

    testWidgets('renders Abbrechen and Löschen buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildDialog());
      expect(find.text('Abbrechen'), findsOneWidget);
      expect(find.text('Löschen'), findsOneWidget);
    });

    testWidgets('calls onCancel when Abbrechen is pressed', (
      WidgetTester tester,
    ) async {
      bool cancelCalled = false;
      await tester.pumpWidget(
        buildDialog(
          onCancel: () {
            cancelCalled = true;
          },
        ),
      );
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();
      expect(cancelCalled, isTrue);
    });

    testWidgets('calls onDelete when Löschen is pressed', (
      WidgetTester tester,
    ) async {
      bool deleteCalled = false;
      await tester.pumpWidget(
        buildDialog(
          onDelete: () {
            deleteCalled = true;
          },
        ),
      );
      await tester.tap(find.text('Löschen'));
      await tester.pumpAndSettle();
      expect(deleteCalled, isTrue);
    });

    testWidgets('uses scaleFactor for font size', (WidgetTester tester) async {
      await tester.pumpWidget(buildDialog(scaleFactor: 1.5));
      final titleText = tester.widget<Text>(find.text('Test Title'));
      expect(titleText.style?.fontSize, greaterThan(20)); // Should be scaled
    });
  });
}
