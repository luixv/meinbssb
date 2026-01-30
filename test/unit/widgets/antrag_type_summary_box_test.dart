import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/widgets/antrag_type_summary_box.dart';
// import 'package:meinbssb/models/beduerfnisse_antrag_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

void main() {
  group('AntragTypeSummaryBox', () {
    Widget wrapWithProvider(Widget child) {
      return ChangeNotifierProvider<FontSizeProvider>(
        create: (_) => FontSizeProvider(),
        child: MaterialApp(home: Scaffold(body: child)),
      );
    }

    testWidgets('shows message for neue WBK when wbkNeu is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProvider(AntragTypeSummaryBox(wbkNeu: true)),
      );
      expect(find.textContaining('neue WBK'), findsOneWidget);
      expect(find.textContaining('bestehende WBK'), findsNothing);
    });

    testWidgets('shows message for bestehende WBK when wbkNeu is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProvider(AntragTypeSummaryBox(wbkNeu: false)),
      );
      expect(find.textContaining('bestehende WBK'), findsOneWidget);
      expect(find.textContaining('neue WBK'), findsNothing);
    });

    testWidgets('shows message for neue WBK when wbkNeu is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProvider(
          AntragTypeSummaryBox(wbkNeu: true),
        ), // null defaults to true (new WBK)
      );
      expect(find.textContaining('neue WBK'), findsOneWidget);
      expect(find.textContaining('bestehende WBK'), findsNothing);
    });
  });
}
