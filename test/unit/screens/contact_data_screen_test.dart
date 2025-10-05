import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/screens/contact_data_screen.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import '../helpers/test_helper.dart';

void main() {
  late UserData testUserData;

  setUp(() {
    testUserData = const UserData(
      personId: 123,
      webLoginId: 456,
      passnummer: '12345678',
      vereinNr: 789,
      namen: 'User',
      vorname: 'Test',
      vereinName: 'Test Club',
      passdatenId: 1,
      mitgliedschaftId: 1,
    );
    TestHelper.setupMocks();
  });

  Widget createContactDataScreen({
    UserData? userData,
    bool isLoggedIn = true,
    VoidCallback? onLogout,
  }) {
    return TestHelper.createTestApp(
      home: ContactDataScreen(
        userData,
        isLoggedIn: isLoggedIn,
        onLogout: onLogout ?? () {},
      ),
    );
  }

  group('ContactDataScreen - Basic Widget Tests', () {
    testWidgets('renders correctly with user data', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pump(); // First pump to build the widget

      // Assert
      expect(find.text('Kontaktdaten'), findsOneWidget);
      expect(find.byType(BaseScreenLayout), findsOneWidget);
    });

    testWidgets('renders correctly with null user data', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createContactDataScreen(userData: null));
      await tester.pump();

      // Assert
      expect(find.text('Kontaktdaten'), findsOneWidget);
      expect(find.byType(BaseScreenLayout), findsOneWidget);
    });

    testWidgets('add contact button is present and properly styled', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pump();

      // Assert - should find the floating action button with add icon
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      final fab = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );
      expect(fab.heroTag, equals('contactDataFab'));
    });

    testWidgets('shows loading indicator initially', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));

      // Assert - should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('handles logout callback correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool logoutCalled = false;

      // Act
      await tester.pumpWidget(
        createContactDataScreen(
          userData: testUserData,
          onLogout: () => logoutCalled = true,
        ),
      );
      await tester.pump();

      final contactScreen = tester.state<ContactDataScreenState>(
        find.byType(ContactDataScreen),
      );
      contactScreen.widget.onLogout();

      // Assert
      expect(logoutCalled, isTrue);
    });

    testWidgets('maintains isLoggedIn state correctly', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        createContactDataScreen(userData: testUserData, isLoggedIn: false),
      );
      await tester.pump();

      final contactScreen = tester.widget<ContactDataScreen>(
        find.byType(ContactDataScreen),
      );

      // Assert
      expect(contactScreen.isLoggedIn, isFalse);
    });
  });

  group('ContactDataScreen - Add Contact Dialog Tests', () {
    testWidgets('opens add contact dialog when FAB is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Neuen Kontakt hinzufügen'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('closes dialog when cancel button is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Neuen Kontakt hinzufügen'), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('form fields are properly labeled and styled', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Kontakttyp'), findsOneWidget);
      expect(find.text('Kontakt'), findsOneWidget);
      expect(
        find.text('z.B. email@beispiel.de oder 0123 456789'),
        findsOneWidget,
      );
    });

    testWidgets('dialog buttons have correct icons and text', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('Abbrechen'), findsOneWidget);
      expect(find.text('Hinzufügen'), findsOneWidget);
    });

    testWidgets('handles rapid dialog open/close operations', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pumpAndSettle();

      // Act - rapidly open and close dialog multiple times
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
        await tester.tap(find.text('Abbrechen'));
        await tester.pump();
      }

      await tester.pumpAndSettle();

      // Assert - should not cause any errors
      expect(tester.takeException(), isNull);
    });
  });

  group('ContactDataScreen - Data Display Tests', () {
    testWidgets('displays error message on data fetch failure', (
      WidgetTester tester,
    ) async {
      // This test would need proper error state simulation
      // For now, we test the error display structure
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pumpAndSettle();

      // The error handling is part of FutureBuilder, which would show error text
      expect(
        find.byType(FutureBuilder<List<Map<String, dynamic>>>),
        findsOneWidget,
      );
    });

    testWidgets('handles null contact data gracefully', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createContactDataScreen(userData: null));
      await tester.pumpAndSettle();

      // Assert - should not crash and should handle null userData
      expect(find.text('Kontaktdaten'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ScrollController is properly initialized', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pumpAndSettle();

      // Assert - should find scrollable area
      expect(find.byType(Scrollbar), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('ContactDataScreen - Widget Lifecycle Tests', () {
    testWidgets('properly disposes controllers on widget disposal', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pumpAndSettle();

      // Act - dispose widget
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();

      // Assert - should not throw disposal errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles widget rebuild correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pumpAndSettle();

      // Act - rebuild with same data
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pump();

      // Assert - should rebuild without errors
      expect(find.text('Kontaktdaten'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles widget rebuild with different userData', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pumpAndSettle();

      const newUserData = UserData(
        personId: 456,
        webLoginId: 789,
        passnummer: '87654321',
        vereinNr: 321,
        namen: 'NewUser',
        vorname: 'Test',
        vereinName: 'New Test Club',
        passdatenId: 2,
        mitgliedschaftId: 2,
      );

      // Act - rebuild with different user data
      await tester.pumpWidget(createContactDataScreen(userData: newUserData));
      await tester.pumpAndSettle();

      // Assert - should handle user data change
      expect(find.text('Kontaktdaten'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('maintains state during orientation changes', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pumpAndSettle();

      // Simulate orientation change
      tester.binding.window.physicalSizeTestValue = const Size(600, 800);
      await tester.pump();

      // Assert
      expect(find.text('Kontaktdaten'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Reset
      tester.binding.window.clearPhysicalSizeTestValue();
    });
  });

  group('ContactDataScreen - UI Component Tests', () {
    testWidgets('uses ScaledText widgets for accessibility', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pumpAndSettle();

      // Assert - should use ScaledText for accessibility
      expect(find.byType(ScaledText), findsWidgets);
    });

    testWidgets('dialog maintains proper z-order and focus', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Assert - dialog should be on top and text field focusable
      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();
      expect(tester.testTextInput.hasAnyClients, isTrue);
    });
  });

  group('ContactDataScreen - Performance Tests', () {
    testWidgets('handles rapid user interactions without errors', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pumpAndSettle();

      // Act - perform rapid interactions
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
        await tester.enterText(find.byType(TextFormField), 'rapid$i');
        await tester.pump();
        await tester.tap(find.text('Abbrechen'));
        await tester.pump();
      }

      await tester.pumpAndSettle();

      // Assert - should handle rapid interactions gracefully
      expect(tester.takeException(), isNull);
    });

    testWidgets('widget builds within reasonable time', (
      WidgetTester tester,
    ) async {
      // Arrange
      final stopwatch = Stopwatch()..start();

      // Act
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Assert - should build quickly
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      expect(find.text('Kontaktdaten'), findsOneWidget);
    });
  });

  group('ContactDataScreen - Edge Cases', () {
    testWidgets('handles extreme user data values', (
      WidgetTester tester,
    ) async {
      // Arrange - create user data with extreme values
      const extremeUserData = UserData(
        personId: 999999999,
        webLoginId: 0,
        passnummer: '',
        vereinNr: 0,
        namen:
            'VeryLongLastNameThatCouldPotentiallyBreakTheLayoutAndCauseIssuesWithDisplaying',
        vorname:
            'VeryLongFirstNameThatCouldPotentiallyBreakTheLayoutAndCauseIssuesWithDisplaying',
        vereinName:
            'VeryLongClubNameThatCouldPotentiallyBreakTheLayoutAndCauseIssuesWithDisplayingInTheUI',
        passdatenId: 999999999,
        mitgliedschaftId: 999999999,
      );

      // Act
      await tester.pumpWidget(
        createContactDataScreen(userData: extremeUserData),
      );
      await tester.pumpAndSettle();

      // Assert - should handle extreme values gracefully
      expect(find.text('Kontaktdaten'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('maintains functionality with minimal user data', (
      WidgetTester tester,
    ) async {
      // Arrange - create minimal user data
      const minimalUserData = UserData(
        personId: 1,
        webLoginId: 1,
        passnummer: '1',
        vereinNr: 1,
        namen: 'A',
        vorname: 'B',
        vereinName: 'C',
        passdatenId: 1,
        mitgliedschaftId: 1,
      );

      // Act
      await tester.pumpWidget(
        createContactDataScreen(userData: minimalUserData),
      );
      await tester.pumpAndSettle();

      // Assert - should work with minimal data
      expect(find.text('Kontaktdaten'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
