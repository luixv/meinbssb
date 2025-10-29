import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/agb/agb_ausweis_screen.dart';

void main() {
  group('AgbScreen', () {
    testWidgets('renders app bar title and close button', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AgbScreen()));
      expect(find.text('AGB'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('renders main sections and paragraphs', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AgbScreen()));
      // Check for some known section titles and paragraphs
      expect(find.textContaining('Geltungsbereich'), findsWidgets);
      expect(find.textContaining('Vertragsschluss'), findsWidgets);
      expect(
        find.textContaining('Preise und Zahlungsbedingungen'),
        findsWidgets,
      );
      expect(find.textContaining('Widerrufsrecht'), findsWidgets);
      expect(find.textContaining('Haftung und Verlust'), findsWidgets);
      expect(
        find.textContaining('Anwendbares Recht und Gerichtsstand'),
        findsWidgets,
      );
    });

    testWidgets('renders semantics label', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AgbScreen()));
      final semanticsFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label != null &&
            widget.properties.label!.contains(
              'Allgemeine Geschäftsbedingungen',
            ),
      );
      expect(semanticsFinder, findsOneWidget);
    });
  });
}
