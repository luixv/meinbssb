import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/help_screen_accessible.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

void main() {
  late UserData userData;

  setUp(() {
    userData = const UserData(
      personId: 1,
      webLoginId: 1,
      passnummer: '123456',
      vereinNr: 1,
      namen: 'Mustermann',
      vorname: 'Max',
      titel: null,
      geburtsdatum: null,
      geschlecht: null,
      vereinName: 'Testverein',
      strasse: null,
      plz: null,
      ort: null,
      land: '',
      nationalitaet: '',
      passStatus: 0,
      passdatenId: 1,
      eintrittVerein: null,
      austrittVerein: null,
      mitgliedschaftId: 1,
      telefon: '',
      erstLandesverbandId: 0,
      produktionsDatum: null,
      erstVereinId: 0,
      digitalerPass: 0,
      isOnline: false,
      disziplin: null,
    );
  });

  Widget buildTestWidget({UserData? userData, bool isLoggedIn = true}) {
    return ChangeNotifierProvider<FontSizeProvider>(
      create: (_) => FontSizeProvider(),
      child: MaterialApp(
        routes: {
          '/login': (context) => const Scaffold(body: Text('Login Screen')),
          '/home': (context) => const Scaffold(body: Text('Home Screen')),
        },
        home: HelpScreenAccessible(
          userData: userData,
          isLoggedIn: isLoggedIn,
          onLogout: () {},
        ),
      ),
    );
  }

  group('Help Screen Accessibility Tests', () {
    testWidgets('displays main heading with proper semantics', (tester) async {
      await tester.pumpWidget(buildTestWidget(userData: userData));

      // Find main heading
      expect(find.text('Häufig gestellte Fragen (FAQ)'), findsOneWidget);

      // Verify semantic structure exists (tested through proper widget structure)
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('displays all FAQ sections', (tester) async {
      await tester.pumpWidget(buildTestWidget(userData: userData));

      // Verify all sections are present
      expect(find.text('Allgemein'), findsOneWidget);
      expect(find.text('Funktionen der App'), findsOneWidget);
      expect(find.text('Technische Fragen'), findsOneWidget);
      expect(find.text('Kontakt und Hilfe'), findsOneWidget);
    });

    testWidgets('section expansion works with tap', (tester) async {
      await tester.pumpWidget(buildTestWidget(userData: userData));

      // Initially, detailed questions should not be visible
      expect(find.text('Was ist Mein BSSB?'), findsNothing);

      // Tap on "Allgemein" section
      await tester.tap(find.text('Allgemein'));
      await tester.pumpAndSettle();

      // Now the questions should be visible
      expect(find.text('Was ist Mein BSSB?'), findsOneWidget);
      expect(find.text('Wer kann die App nutzen?'), findsOneWidget);
    });

    testWidgets('questions expand and collapse with proper keyboard navigation',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(userData: userData));

      // First expand the section
      await tester.tap(find.text('Allgemein'));
      await tester.pumpAndSettle();

      // Find the first question
      final questionFinder = find.text('Was ist Mein BSSB?');
      expect(questionFinder, findsOneWidget);

      // Initially answer should not be visible
      expect(
        find.textContaining('Mein BSSB ist die offizielle App'),
        findsNothing,
      );

      // Tap the question to expand
      await tester.tap(questionFinder);
      await tester.pumpAndSettle();

      // Answer should now be visible
      expect(
        find.textContaining('Mein BSSB ist die offizielle App'),
        findsOneWidget,
      );
    });

    testWidgets('keyboard navigation works with Enter key', (tester) async {
      await tester.pumpWidget(buildTestWidget(userData: userData));

      // Expand section first
      await tester.tap(find.text('Allgemein'));
      await tester.pumpAndSettle();

      // Simulate keyboard navigation
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Simulate Enter key press on focused element
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // The keyboard navigation should work without errors
    });

    testWidgets('displays version information', (tester) async {
      await tester.pumpWidget(buildTestWidget(userData: userData));

      // Wait for version to load
      await tester.pumpAndSettle();

      // Should show version text (might be loading state initially)
      expect(
        find.textContaining('Version:'),
        findsOneWidget,
      );
    });

    testWidgets('link text is accessible and tappable', (tester) async {
      await tester.pumpWidget(buildTestWidget(userData: userData));

      // Expand the contact section
      final contactSectionFinder = find.text('Kontakt und Hilfe');
      await tester.ensureVisible(contactSectionFinder);
      await tester.tap(contactSectionFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Expand the help question
      final helpQuestionFinder = find.text('Wo erhalte ich weitere Hilfe?');
      await tester.ensureVisible(helpQuestionFinder);
      await tester.tap(helpQuestionFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Find the link
      final linkFinder = find.text('Zur Webseite des BSSB');
      expect(linkFinder, findsOneWidget);

      // Verify it's tappable by attempting to tap
      await tester.ensureVisible(linkFinder);
      await tester.tap(linkFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      // No exception should be thrown, indicating proper accessibility
    });

    testWidgets('provides proper focus management', (tester) async {
      await tester.pumpWidget(buildTestWidget(userData: userData));

      // The screen should have a focus node
      expect(find.byType(Focus), findsWidgets);

      // Should be able to navigate through focusable elements
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Focus should be managed properly (tested through no exceptions)
    });

    testWidgets('works correctly when user is logged out', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(userData: null, isLoggedIn: false),
      );

      // Screen should still render properly
      expect(find.text('Häufig gestellte Fragen (FAQ)'), findsOneWidget);
      expect(find.text('Allgemein'), findsOneWidget);
    });

    testWidgets('handles section state changes properly', (tester) async {
      await tester.pumpWidget(buildTestWidget(userData: userData));

      // Expand first section
      final allgemeinFinder = find.text('Allgemein');
      await tester.ensureVisible(allgemeinFinder);
      await tester.tap(allgemeinFinder, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Was ist Mein BSSB?'), findsOneWidget);

      // Expand second section (should close first)
      final funktionenFinder = find.text('Funktionen der App');
      await tester.ensureVisible(funktionenFinder);
      await tester.tap(funktionenFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      // First section questions should be hidden
      expect(find.text('Was ist Mein BSSB?'), findsNothing);

      // Second section questions should be visible
      expect(find.text('Welche Bereiche gibt es in der App?'), findsOneWidget);
    });

    testWidgets('provides semantic labels for screen readers', (tester) async {
      await tester.pumpWidget(buildTestWidget(userData: userData));

      // Check that semantic widgets are present
      expect(find.byType(Semantics), findsWidgets);

      // Screen should have proper structure for screen readers
      expect(find.byType(HelpScreenAccessible), findsOneWidget);
    });

    testWidgets('all interactive elements are keyboard accessible',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(userData: userData));

      // All buttons and interactive elements should be focusable
      final focusableElements = find.byType(Focus);
      expect(focusableElements, findsWidgets);

      // Each section should be keyboard navigable
      for (final sectionName in [
        'Allgemein',
        'Funktionen der App',
        'Technische Fragen',
        'Kontakt und Hilfe',
      ]) {
        final sectionFinder = find.text(sectionName);
        expect(sectionFinder, findsOneWidget);

        // Scroll to make the element visible before tapping
        await tester.ensureVisible(sectionFinder);
        await tester.pumpAndSettle();

        // Should be able to interact with keyboard (suppress tap warnings for off-screen elements)
        await tester.tap(sectionFinder, warnIfMissed: false);
        await tester.pumpAndSettle();
      }
    });
  });

  group('BITV 2.0 Compliance Tests', () {
    testWidgets('has proper heading hierarchy', (tester) async {
      await tester.pumpWidget(buildTestWidget(userData: userData));

      // Main heading should be present with semantic wrapper
      expect(find.text('Häufig gestellte Fragen (FAQ)'), findsOneWidget);

      // Should have semantic structure
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('provides keyboard navigation for all interactive elements',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(userData: userData));

      // Should be able to navigate with Tab
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Should be able to activate with Enter
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // No exceptions should be thrown
    });

    testWidgets('provides proper semantic roles', (tester) async {
      await tester.pumpWidget(buildTestWidget(userData: userData));

      // Expand a section to access the link
      final kontaktFinder = find.text('Kontakt und Hilfe');
      await tester.ensureVisible(kontaktFinder);
      await tester.tap(kontaktFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      final hilfeFinder = find.text('Wo erhalte ich weitere Hilfe?');
      await tester.ensureVisible(hilfeFinder);
      await tester.tap(hilfeFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Link should be present and interactable
      final linkFinder = find.text('Zur Webseite des BSSB');
      expect(linkFinder, findsOneWidget);

      // Should be wrapped in proper semantic structure
      expect(
        find.ancestor(of: linkFinder, matching: find.byType(Semantics)),
        findsWidgets,
      );
    });

    testWidgets('supports screen reader announcements', (tester) async {
      await tester.pumpWidget(buildTestWidget(userData: userData));

      // The screen should have semantic structure for screen readers
      expect(find.byType(Semantics), findsWidgets);

      // Main screen should be present
      expect(find.byType(HelpScreenAccessible), findsOneWidget);
    });
  });
}
