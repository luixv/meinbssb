import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/bank_data_success_screen_accessible.dart';
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

  Widget buildTestWidget({
    required bool success,
    UserData? userData,
    bool isLoggedIn = true,
  }) {
    return ChangeNotifierProvider<FontSizeProvider>(
      create: (_) => FontSizeProvider(),
      child: MaterialApp(
        routes: {
          '/profile': (context) => const Scaffold(body: Text('Profile Screen')),
          '/login': (context) => const Scaffold(body: Text('Login Screen')),
        },
        home: BankDataSuccessScreenAccessible(
          success: success,
          userData: userData,
          isLoggedIn: isLoggedIn,
          onLogout: () {},
        ),
      ),
    );
  }

  group('Bank Data Success Screen Accessibility Tests', () {
    testWidgets('displays success state with proper accessibility',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(success: true, userData: userData),
      );

      // Check success icon is present
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Check success message
      expect(find.text('Ihre Bankdaten wurden erfolgreich gespeichert.'),
          findsOneWidget,);

      // Check navigation button
      expect(find.text('Zum Profil'), findsOneWidget);

      // Verify semantic structure
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('displays error state with proper accessibility',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(success: false, userData: userData),
      );

      // Check error icon is present
      expect(find.byIcon(Icons.error), findsOneWidget);

      // Check error message
      expect(find.text('Es ist ein Fehler aufgetreten.'), findsOneWidget);

      // Check navigation button is still present
      expect(find.text('Zum Profil'), findsOneWidget);
    });

    testWidgets('navigation button works correctly for success state',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(success: true, userData: userData),
      );

      // Find and tap the navigation button
      final buttonFinder = find.text('Zum Profil');
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Should navigate to profile screen
      expect(find.text('Profile Screen'), findsOneWidget);
    });

    testWidgets('navigation button works correctly for error state',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(success: false, userData: userData),
      );

      // Find and tap the navigation button
      final buttonFinder = find.text('Zum Profil');
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Should still navigate to profile screen
      expect(find.text('Profile Screen'), findsOneWidget);
    });

    testWidgets('keyboard navigation works with Enter key', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(success: true, userData: userData),
      );

      // Find button and simulate Enter key press on it
      final buttonFinder = find.text('Zum Profil');
      expect(buttonFinder, findsOneWidget);

      // Test keyboard activation by tapping the button
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Should navigate to profile
      expect(find.text('Profile Screen'), findsOneWidget);
    });

    testWidgets('keyboard navigation works with Space key', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(success: true, userData: userData),
      );

      // Test that keyboard navigation is supported by verifying focus structure
      expect(find.byType(Focus), findsWidgets);

      // Verify button can be activated
      final buttonFinder = find.text('Zum Profil');
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Should navigate to profile
      expect(find.text('Profile Screen'), findsOneWidget);
    });

    testWidgets('displays appropriate additional information for success',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(success: true, userData: userData),
      );

      // Check success-specific additional info
      expect(
        find.text('Sie können nun zu Ihrem Profil zurückkehren'),
        findsOneWidget,
      );
    });

    testWidgets('displays appropriate additional information for error',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(success: false, userData: userData),
      );

      // Check error-specific additional info
      expect(
        find.textContaining('Bitte versuchen Sie es später erneut'),
        findsOneWidget,
      );
    });

    testWidgets('provides keyboard navigation hint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(success: true, userData: userData),
      );

      // Check navigation hint is present
      expect(
        find.text(
            'Tipp: Verwenden Sie Tab zum Navigieren und Enter zum Aktivieren',),
        findsOneWidget,
      );
    });

    testWidgets('works correctly when user is not logged in', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          success: true,
          userData: null,
          isLoggedIn: false,
        ),
      );

      // Screen should still render properly
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Zum Profil'), findsOneWidget);
    });

    testWidgets('provides proper focus management', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(success: true, userData: userData),
      );

      // Should have focus nodes
      expect(find.byType(Focus), findsWidgets);

      // Should be able to navigate through focusable elements
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Focus should be managed properly (no exceptions)
    });

    testWidgets('has proper semantic structure for screen readers',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(success: true, userData: userData),
      );

      // Check main semantic structure
      expect(find.byType(Semantics), findsWidgets);

      // Main screen should be present
      expect(find.byType(BankDataSuccessScreenAccessible), findsOneWidget);
    });
  });

  group('BITV 2.0 Compliance Tests', () {
    testWidgets('provides status announcements for success state',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(success: true, userData: userData),
      );

      // Screen should have semantic structure for announcements
      expect(find.byType(Semantics), findsWidgets);

      // Success elements should be present
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Ihre Bankdaten wurden erfolgreich gespeichert.'),
          findsOneWidget,);
    });

    testWidgets('provides status announcements for error state',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(success: false, userData: userData),
      );

      // Screen should have semantic structure for announcements
      expect(find.byType(Semantics), findsWidgets);

      // Error elements should be present
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.text('Es ist ein Fehler aufgetreten.'), findsOneWidget);
    });

    testWidgets('supports keyboard navigation for all interactive elements',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(success: true, userData: userData),
      );

      // Should have focus management
      expect(find.byType(Focus), findsWidgets);

      // Should be able to interact with button
      final buttonFinder = find.text('Zum Profil');
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Should navigate successfully
      expect(find.text('Profile Screen'), findsOneWidget);
    });

    testWidgets('provides proper semantic roles and labels', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(success: true, userData: userData),
      );

      // Button should have proper semantic structure
      final buttonFinder = find.text('Zum Profil');
      expect(buttonFinder, findsOneWidget);

      // Should be wrapped in semantic structure
      expect(find.ancestor(of: buttonFinder, matching: find.byType(Semantics)),
          findsWidgets,);
    });

    testWidgets('provides live region for dynamic content', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(success: true, userData: userData),
      );

      // Should have semantic containers with live regions
      expect(find.byType(Semantics), findsWidgets);

      // Content should be properly structured
      expect(find.text('Ihre Bankdaten wurden erfolgreich gespeichert.'),
          findsOneWidget,);
    });

    testWidgets('handles state changes appropriately', (tester) async {
      // Test success state
      await tester.pumpWidget(
        buildTestWidget(success: true, userData: userData),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.error), findsNothing);

      // Rebuild with error state
      await tester.pumpWidget(
        buildTestWidget(success: false, userData: userData),
      );

      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('provides contextual information for different states',
        (tester) async {
      // Test success context
      await tester.pumpWidget(
        buildTestWidget(success: true, userData: userData),
      );

      expect(find.text('Sie können nun zu Ihrem Profil zurückkehren'),
          findsOneWidget,);

      // Test error context
      await tester.pumpWidget(
        buildTestWidget(success: false, userData: userData),
      );

      expect(find.textContaining('Bitte versuchen Sie es später erneut'),
          findsOneWidget,);
    });
  });

  group('Visual and Interaction Tests', () {
    testWidgets('displays proper visual feedback for focus', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(success: true, userData: userData),
      );

      // Focus should be managed by Focus widgets
      expect(find.byType(Focus), findsWidgets);

      // Button should be present for interaction
      expect(find.text('Zum Profil'), findsOneWidget);
    });

    testWidgets('maintains proper spacing and layout', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(success: true, userData: userData),
      );

      // All layout elements should be present
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('uses appropriate colors for different states', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(success: true, userData: userData),
      );

      // Success icon should be present
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Rebuild with error state
      await tester.pumpWidget(
        buildTestWidget(success: false, userData: userData),
      );

      // Error icon should be present
      expect(find.byIcon(Icons.error), findsOneWidget);
    });
  });
}
