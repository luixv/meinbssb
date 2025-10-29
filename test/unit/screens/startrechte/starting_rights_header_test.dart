import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:meinbssb/screens/startrechte/starting_rights_header.dart';
import 'package:meinbssb/constants/messages.dart';
import 'package:meinbssb/providers/font_size_provider.dart'; // use real provider

void main() {
  Widget wrap(Widget child) => MultiProvider(
    providers: [
      ChangeNotifierProvider<FontSizeProvider>(
        create: (_) => FontSizeProvider(),
      ),
    ],
    child: MaterialApp(home: Scaffold(body: child)),
  );

  group('StartingRightsHeader', () {
    testWidgets('renders title and season string', (tester) async {
      await tester.pumpWidget(
        wrap(const StartingRightsHeader(seasonString: '2024/2025')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Startrechte ändern'), findsOneWidget);
      expect(find.textContaining('Für das Sportjahr'), findsOneWidget);
      expect(find.textContaining('2024/2025'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('shows tooltip on tap (triggerMode.tap)', (tester) async {
      await tester.pumpWidget(
        wrap(const StartingRightsHeader(seasonString: '2025')),
      );
      await tester.pumpAndSettle();
      expect(find.text(Messages.startingRightsHeaderTooltip), findsNothing);
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle();
      expect(find.text(Messages.startingRightsHeaderTooltip), findsOneWidget);
    });

    testWidgets('tooltip toggle does not throw after closing', (tester) async {
      await tester.pumpWidget(
        wrap(const StartingRightsHeader(seasonString: '2030')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle();
      expect(find.text(Messages.startingRightsHeaderTooltip), findsOneWidget);
      await tester.tapAt(const Offset(5, 5)); // dismiss
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
    });
  });
}
