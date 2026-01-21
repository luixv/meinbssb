import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisbescheinigung_screen.dart';
import 'package:meinbssb/screens/beduerfnisse/meine_beduerfnisseantraege_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

void main() {
  const dummyUser = UserData(
    personId: 1,
    webLoginId: 1,
    passnummer: '12345',
    vereinNr: 1,
    namen: 'User',
    vorname: 'Test',
    vereinName: 'Test Verein',
    passdatenId: 1,
    mitgliedschaftId: 1,
  );

  Widget createTestWidget({
    UserData? userData,
    bool isLoggedIn = true,
    VoidCallback? onLogout,
  }) {
    return ChangeNotifierProvider<FontSizeProvider>(
      create: (_) => FontSizeProvider(),
      child: MaterialApp(
        home: BeduerfnisbescheinigungScreen(
          userData: userData ?? dummyUser,
          isLoggedIn: isLoggedIn,
          onLogout: onLogout ?? () {},
        ),
      ),
    );
  }

  group('BeduerfnisbescheinigungScreen', () {
    testWidgets('renders screen with correct title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Bedürfnisbescheinigung'), findsOneWidget);
    });

    testWidgets('renders introduction text', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('Hier können Sie die Bedürfnisbescheinigung beantragen.'),
        findsOneWidget,
      );
      expect(
        find.text('Der Prozess sieht folgende Schritte vor:'),
        findsOneWidget,
      );
    });

    testWidgets('renders section header', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Ablaufbeschreibung'), findsOneWidget);
    });

    testWidgets('renders all four process steps', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Step 1
      expect(find.text('Erfassen der Daten'), findsOneWidget);

      // Step 2
      expect(
        find.text('Bestätigung der Angaben durch den Vorstand nach §26 BGB'),
        findsOneWidget,
      );

      // Step 3
      expect(find.text('Prüfung der Daten durch den BSSB'), findsOneWidget);

      // Step 4
      expect(
        find.text('Erstellung / Ablehnung der Bedürfnisbescheinigung'),
        findsOneWidget,
      );
    });

    testWidgets('renders step 1 sub-items', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for sub-items in step 1
      expect(
        find.text(
          'Auswahl ob ein Bedürfnis für eine neue WBK beantragt werden soll, oder eine weitere Waffe einer bestehenden WBK hinzugefügt werden soll.',
        ),
        findsOneWidget,
      );
      expect(find.text('Auswahl der WBK Art'), findsOneWidget);
      expect(
        find.text('Erfassen der Sportschützeneigenschaft'),
        findsOneWidget,
      );
      expect(
        find.text('Ggf. erfassen der Kurz- oder Langwaffen'),
        findsOneWidget,
      );
      expect(
        find.text('Ggf. Nachweis der Teilnahme an Wettbewerben'),
        findsOneWidget,
      );
    });

    testWidgets('renders floating action button with correct icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find FAB with list_alt icon
      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);

      // Check for the icon
      final iconFinder = find.descendant(
        of: fabFinder,
        matching: find.byIcon(Icons.list_alt),
      );
      expect(iconFinder, findsOneWidget);
    });

    testWidgets('FAB has correct properties and is enabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the FAB
      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);

      // Verify FAB has onPressed callback (is enabled)
      final fab = tester.widget<FloatingActionButton>(fabFinder);
      expect(fab.onPressed, isNotNull);
    });

    testWidgets('FAB has correct tooltip', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Long press to show tooltip
      final fabFinder = find.byType(FloatingActionButton);
      await tester.longPress(fabFinder);
      await tester.pumpAndSettle();

      expect(find.text('Meine Bedürfnisseanträge'), findsOneWidget);
    });

    testWidgets('renders with null userData', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(userData: null));
      await tester.pumpAndSettle();

      // Should still render screen
      expect(find.text('Bedürfnisbescheinigung'), findsOneWidget);
    });

    testWidgets('renders when not logged in', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(isLoggedIn: false));
      await tester.pumpAndSettle();

      // Should still render screen
      expect(find.text('Bedürfnisbescheinigung'), findsOneWidget);
    });

    testWidgets('has correct semantic labels', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find semantic widgets
      final semanticFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Bedürfnisbescheinigung',
      );
      expect(semanticFinder, findsOneWidget);

      final bodySemanticFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label != null &&
            widget.properties.label!.contains('Bedürfnisbescheinigungsbereich'),
      );
      expect(bodySemanticFinder, findsOneWidget);
    });

    testWidgets('renders steps in correct order', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Get all step titles in order
      final step1Finder = find.text('1. ');
      final step2Finder = find.text('2. ');
      final step3Finder = find.text('3. ');
      final step4Finder = find.text('4. ');

      expect(step1Finder, findsOneWidget);
      expect(step2Finder, findsOneWidget);
      expect(step3Finder, findsOneWidget);
      expect(step4Finder, findsOneWidget);

      // Verify vertical ordering (step 1 should be above step 2, etc.)
      final step1Position = tester.getTopLeft(step1Finder);
      final step2Position = tester.getTopLeft(step2Finder);
      final step3Position = tester.getTopLeft(step3Finder);
      final step4Position = tester.getTopLeft(step4Finder);

      expect(step1Position.dy < step2Position.dy, true);
      expect(step2Position.dy < step3Position.dy, true);
      expect(step3Position.dy < step4Position.dy, true);
    });

    testWidgets('screen is scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the scrollable widget
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('bullet points are rendered for step 1 items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find bullet points (• character)
      final bulletFinder = find.text('• ');

      // Step 1 has 5 items, so we should find 5 bullet points
      expect(bulletFinder, findsNWidgets(5));
    });

    testWidgets('respects FontSizeProvider scaling', (
      WidgetTester tester,
    ) async {
      final fontSizeProvider = FontSizeProvider();
      fontSizeProvider.setScaleFactor(1.5);

      await tester.pumpWidget(
        ChangeNotifierProvider<FontSizeProvider>.value(
          value: fontSizeProvider,
          child: MaterialApp(
            home: BeduerfnisbescheinigungScreen(
              userData: dummyUser,
              isLoggedIn: true,
              onLogout: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Screen should render with scaled font sizes
      expect(find.text('Bedürfnisbescheinigung'), findsOneWidget);
      expect(find.text('Ablaufbeschreibung'), findsOneWidget);
    });

    testWidgets('_buildStepSection creates proper widget hierarchy', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Each step should have a Column with CrossAxisAlignment.start
      final columnFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Column &&
            widget.crossAxisAlignment == CrossAxisAlignment.start,
      );

      // Multiple columns expected (one for each step + main column + sub-items)
      expect(columnFinder, findsWidgets);
    });

    testWidgets('onLogout callback is passed correctly', (
      WidgetTester tester,
    ) async {
      bool logoutCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          onLogout: () {
            logoutCalled = true;
          },
        ),
      );
      await tester.pumpAndSettle();

      // The screen should render and accept the callback
      expect(find.text('Bedürfnisbescheinigung'), findsOneWidget);
      expect(logoutCalled, false); // Not called yet
    });

    testWidgets('contains Focus widget with autofocus', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find Focus widget - there may be multiple autofocus widgets in the tree
      final focusFinder = find.byWidgetPredicate(
        (widget) => widget is Focus && widget.autofocus == true,
      );
      expect(focusFinder, findsWidgets);
    });

    testWidgets('steps without items do not render bullet points', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Only step 1 has items (5 items), so we should find exactly 5 bullets
      final bulletFinder = find.text('• ');
      expect(bulletFinder, findsNWidgets(5));
    });

    testWidgets('correctly renders step titles with proper formatting', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that step numbers are separate from titles
      expect(find.text('1. '), findsOneWidget);
      expect(find.text('2. '), findsOneWidget);
      expect(find.text('3. '), findsOneWidget);
      expect(find.text('4. '), findsOneWidget);

      // Titles should be in Expanded widgets to handle long text
      final expandedFinder = find.byType(Expanded);
      expect(expandedFinder, findsWidgets);
    });

    testWidgets('sub-items have proper indentation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find padding widgets that are used for indentation
      final paddingFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Padding &&
            widget.padding is EdgeInsets &&
            (widget.padding as EdgeInsets).left > 0,
      );

      // Should have multiple padded widgets (for indentation)
      expect(paddingFinder, findsWidgets);
    });

    testWidgets('all semantic labels are properly set', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for header semantic
      final headerSemanticFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Ablaufbeschreibung' &&
            widget.properties.header == true,
      );
      expect(headerSemanticFinder, findsOneWidget);
    });
  });
}
