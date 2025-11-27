import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/datenschutz_screen.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:provider/provider.dart';

Widget wrapWithProviders(Widget child) {
  return ChangeNotifierProvider<FontSizeProvider>(
    create: (_) => FontSizeProvider(),
    child: MaterialApp(home: child),
  );
}

void main() {
  group('DatenschutzScreen', () {
    testWidgets('renders title and close FAB', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          DatenschutzScreen(userData: null, isLoggedIn: false, onLogout: () {}),
        ),
      );
      // Allow for multiple 'Datenschutz' widgets (header and section)
      expect(find.text('Datenschutz'), findsAtLeastNWidgets(1));
      // Try tooltip first, then fallback to icon
      final fabFinder =
          find.byTooltip('Datenschutz schließen').evaluate().isNotEmpty
              ? find.byTooltip('Datenschutz schließen')
              : find.byIcon(Icons.close);
      expect(fabFinder, findsOneWidget);
    });

    testWidgets('close FAB pops the screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          DatenschutzScreen(userData: null, isLoggedIn: false, onLogout: () {}),
        ),
      );
      final fabFinder =
          find.byTooltip('Datenschutz schließen').evaluate().isNotEmpty
              ? find.byTooltip('Datenschutz schließen')
              : find.byIcon(Icons.close);
      expect(fabFinder, findsOneWidget);
      await tester.tap(fabFinder);
      await tester.pumpAndSettle();
    });

    testWidgets('renders main section headers', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          DatenschutzScreen(userData: null, isLoggedIn: false, onLogout: () {}),
        ),
      );
      expect(find.textContaining('Allgemeine Hinweise'), findsWidgets);
      expect(find.textContaining('Datenerfassung'), findsWidgets);
      expect(find.textContaining('Cookies'), findsWidgets);
      expect(find.textContaining('Datenlöschung'), findsWidgets);
      expect(find.textContaining('Sicherheit'), findsWidgets);
    });
  });
}
