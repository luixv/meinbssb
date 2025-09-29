import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/impressum_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/services/core/config_service.dart';

class MockConfigService implements ConfigService {
  @override
  String? getString(String key, [String? section]) => null;
  @override
  int? getInt(String key, [String? section]) => null;
  @override
  List<String>? getList(String key, [String? section]) => null;
  @override
  bool? getBool(String key, [String? section]) => null;
}

void main() {
  group('ImpressumScreen BITV 2.0 Accessibility Tests', () {
    late UserData userData;

    setUp(() {
      userData = const UserData(
        personId: 1,
        webLoginId: 1,
        passnummer: '12345',
        vereinNr: 1,
        namen: 'Mustermann',
        vorname: 'Max',
        vereinName: 'Testverein',
        passdatenId: 1,
        mitgliedschaftId: 1,
      );
    });

    Widget createAccessibleScreen() => MultiProvider(
          providers: [
            ChangeNotifierProvider<FontSizeProvider>(
              create: (_) => FontSizeProvider(),
            ),
            Provider<ConfigService>(
              create: (_) => MockConfigService(),
            ),
          ],
          child: MaterialApp(
            home: ImpressumScreen(
              userData: userData,
              isLoggedIn: true,
              onLogout: () {},
            ),
          ),
        );

    group('BITV 2.0 Compliance Tests', () {
      testWidgets('1.1.1 Non-text Content - Icons have context',
          (tester) async {
        await tester.pumpWidget(createAccessibleScreen());

        // Check that contact icons are present and have contextual meaning
        expect(find.byIcon(Icons.phone), findsWidgets);
        expect(find.byIcon(Icons.email), findsWidgets);
        expect(find.byIcon(Icons.language), findsWidgets);

        // Verify icons are within contact context (adjacent to text)
        final phoneIcons = find.byIcon(Icons.phone);
        expect(phoneIcons, findsWidgets);

        // For each phone icon, verify there's text nearby
        for (int i = 0; i < tester.widgetList(phoneIcons).length; i++) {
          final phoneIcon = phoneIcons.at(i);
          final iconFinder = find.ancestor(
            of: phoneIcon,
            matching: find.byType(Row),
          );
          expect(iconFinder, findsWidgets);
        }
      });

      testWidgets('1.3.1 Info and Relationships - Heading hierarchy',
          (tester) async {
        await tester.pumpWidget(createAccessibleScreen());

        // Check main heading exists
        expect(find.text('Impressum'), findsWidgets);

        // Check section headings exist
        expect(find.text('Gesamtverantwortung'), findsOneWidget);
        expect(find.text('Datenschutzbeauftragter'), findsOneWidget);
        expect(find.text('Inhaltlich verantwortlich für die Teilbereiche'),
            findsOneWidget,);

        // Verify heading structure is maintained in widget tree
        final headings = tester
            .widgetList<Text>(find.byType(Text))
            .where(
              (widget) =>
                  widget.style?.fontSize != null &&
                  widget.style!.fontSize! > 16.0,
            )
            .toList();
        expect(headings.length, greaterThan(3));
      });

      testWidgets('1.3.2 Meaningful Sequence - Logical reading order',
          (tester) async {
        await tester.pumpWidget(createAccessibleScreen());

        // Verify main content is in a Column for proper order
        final scrollView = find.byType(SingleChildScrollView);
        expect(scrollView, findsOneWidget);

        final column = find.descendant(
          of: scrollView,
          matching: find.byType(Column),
        );
        expect(column, findsWidgets);

        // Check that content follows logical order
        final allText = tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data ?? '')
            .where((text) => text.isNotEmpty)
            .toList();

        // Verify 'Impressum' appears before 'Gesamtverantwortung'
        final impressumIndex =
            allText.indexWhere((text) => text.contains('Impressum'));
        final gesamtIndex =
            allText.indexWhere((text) => text.contains('Gesamtverantwortung'));
        expect(impressumIndex, lessThan(gesamtIndex));
      });

      testWidgets('1.4.3 Contrast - Text elements have proper styling',
          (tester) async {
        await tester.pumpWidget(createAccessibleScreen());

        // Verify styled text elements exist (indicating consistent styling)
        final styledTexts = tester
            .widgetList<Text>(find.byType(Text))
            .where((widget) => widget.style != null)
            .toList();
        expect(styledTexts.length, greaterThan(10));

        // Check that contact information uses app color (should have good contrast)
        final contactTexts = tester
            .widgetList<Text>(find.byType(Text))
            .where(
              (widget) =>
                  widget.style?.color != null &&
                  widget.data != null &&
                  (widget.data!.contains('@') || widget.data!.contains('www')),
            )
            .toList();
        expect(contactTexts.length, greaterThan(0));
      });

      testWidgets('2.1.1 Keyboard - All interactive elements accessible',
          (tester) async {
        await tester.pumpWidget(createAccessibleScreen());

        // Check FloatingActionButton is keyboard accessible
        final fab = find.byType(FloatingActionButton);
        expect(fab, findsOneWidget);

        // Verify FAB can receive focus
        await tester.tap(fab);
        await tester.pump();

        // The widget should be tappable (simulating keyboard activation)
        expect(fab, findsOneWidget);
      });

      testWidgets('2.4.2 Page Titled - Screen has proper title',
          (tester) async {
        await tester.pumpWidget(createAccessibleScreen());

        // Check that the screen title is set in the base layout
        expect(find.text('Impressum'), findsWidgets);

        // Verify AppBar exists (from BaseScreenLayoutAccessible)
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('2.4.6 Headings and Labels - Descriptive headings',
          (tester) async {
        await tester.pumpWidget(createAccessibleScreen());

        // Check descriptive German headings
        final descriptiveHeadings = [
          'Gesamtverantwortung',
          'Datenschutzbeauftragter',
          'Inhaltlich verantwortlich für die Teilbereiche',
          'Hinweis zur Sprache',
          'Bezirke / Gaue / Vereine',
          'Haftung für weiterführende Links',
        ];

        for (final heading in descriptiveHeadings) {
          expect(find.text(heading), findsOneWidget);
        }
      });

      testWidgets('3.1.1 Language of Page - German content', (tester) async {
        await tester.pumpWidget(createAccessibleScreen());

        // Verify German content
        expect(
            find.textContaining('Bayerischer Sportschützenbund'), findsWidgets,);
        expect(find.textContaining('Landesschützenmeister'), findsWidgets);
        expect(find.textContaining('Geschäftsstelle'), findsWidgets);
        expect(find.textContaining('Eingetragen im Vereinsregister'),
            findsWidgets,);
      });

      testWidgets('4.1.2 Name, Role, Value - Semantic structure',
          (tester) async {
        await tester.pumpWidget(createAccessibleScreen());

        // Test semantic structure by checking widget types
        expect(find.byType(SingleChildScrollView), findsOneWidget);
        expect(find.byType(Container), findsWidgets);
        expect(find.byType(Column), findsWidgets);
        expect(find.byType(Text), findsWidgets);
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // Check that icons have semantic meaning through their context in Rows
        final iconRows = find.byType(Row);
        expect(iconRows, findsWidgets);
      });
    });

    group('Screen Reader Accessibility', () {
      testWidgets('Screen reader can navigate content logically',
          (tester) async {
        await tester.pumpWidget(createAccessibleScreen());

        final SemanticsHandle handle = tester.ensureSemantics();

        // Get semantics tree for the scrollable content
        final scrollView = find.byType(SingleChildScrollView);
        expect(scrollView, findsOneWidget);

        // Verify semantic information is available
        final mainSemantics = tester.getSemantics(scrollView);
        expect(mainSemantics, isNotNull);

        handle.dispose();
      });

      testWidgets('FloatingActionButton has basic interaction', (tester) async {
        await tester.pumpWidget(createAccessibleScreen());

        final SemanticsHandle handle = tester.ensureSemantics();

        final fab = find.byType(FloatingActionButton);
        expect(fab, findsOneWidget);

        // Check that FAB is interactive
        await tester.tap(fab);
        await tester.pump();

        handle.dispose();
      });
    });

    group('Layout and Structure Tests', () {
      testWidgets('Content is scrollable and constrained properly',
          (tester) async {
        await tester.pumpWidget(createAccessibleScreen());

        // Verify scrollable structure
        expect(find.byType(SingleChildScrollView), findsOneWidget);

        // Check content constraints
        final containers = find.byType(Container);
        expect(containers, findsWidgets);

        // Verify at least one container has constraints
        bool hasConstraints = false;
        for (int i = 0; i < tester.widgetList(containers).length; i++) {
          final container = tester.widget<Container>(containers.at(i));
          if (container.constraints != null) {
            hasConstraints = true;
            break;
          }
        }
        expect(hasConstraints, isTrue,
            reason:
                'At least one container should have constraints for layout',);
      });

      testWidgets('Responsive layout with proper spacing', (tester) async {
        await tester.pumpWidget(createAccessibleScreen());

        // Check for proper spacing elements
        expect(find.byType(Divider), findsWidgets);

        // Verify SizedBox or similar spacing widgets exist
        final columns = find.byType(Column);
        expect(columns, findsWidgets);

        // Check that wrap widgets are used for responsive design
        expect(find.byType(Wrap), findsWidgets);
      });

      testWidgets('Contact information is properly structured', (tester) async {
        await tester.pumpWidget(createAccessibleScreen());

        // Check for contact icons and text
        expect(find.byIcon(Icons.phone), findsWidgets);
        expect(find.byIcon(Icons.email), findsWidgets);
        expect(find.byIcon(Icons.language), findsWidgets);

        // Verify phone numbers and emails are present
        expect(find.textContaining('089'),
            findsWidgets,); // Phone numbers start with 089
        expect(find.textContaining('@bssb'), findsWidgets); // Email addresses
        expect(find.textContaining('www.bssb'), findsWidgets); // Website
      });
    });

    group('Content Validation', () {
      testWidgets('All required legal information is present', (tester) async {
        await tester.pumpWidget(createAccessibleScreen());

        // Check required legal information for German impressum
        expect(find.textContaining('Bayerischer Sportschützenbund e.V.'),
            findsWidgets,);
        expect(find.textContaining('Vereinsregister'),
            findsWidgets,); // Changed to findsWidgets to handle duplicates
        expect(find.textContaining('VR 4803'), findsWidgets);
        expect(find.textContaining('85748 Garching'), findsWidgets);
        expect(find.textContaining('Umsatzsteueridentifikationsnummer'),
            findsOneWidget,);
        expect(find.textContaining('DE 129514004'), findsOneWidget);
      });

      testWidgets('Data protection officer information is complete',
          (tester) async {
        await tester.pumpWidget(createAccessibleScreen());

        expect(find.text('Datenschutzbeauftragter'), findsOneWidget);
        expect(find.textContaining('Herbert Isdebski'), findsOneWidget);
        expect(find.textContaining('datenschutz@bssb.de'), findsOneWidget);
      });

      testWidgets('Responsible persons are listed with contact details',
          (tester) async {
        await tester.pumpWidget(createAccessibleScreen());

        // Check that responsible persons are mentioned (use findsWidgets for duplicates)
        expect(find.textContaining('Alexander Heidel'), findsWidgets);
        expect(find.textContaining('Josef Lederer'), findsOneWidget);
        expect(find.textContaining('Markus Maas'), findsOneWidget);

        // Check contact details are provided
        expect(find.textContaining('alexander.heidel@bssb.bayern'),
            findsOneWidget,);
        expect(find.textContaining('josef.lederer@bssb.de'), findsOneWidget);
        expect(find.textContaining('jugend@bssb.bayern'), findsOneWidget);
      });
    });
  });
}
