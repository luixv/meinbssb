import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:meinbssb/screens/oktoberfest_eintritt_festzelt_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import '../helpers/test_helper.dart';

// Generate mocks
@GenerateMocks([ApiService])
import 'oktoberfest_eintritt_festzelt_screen_test.mocks.dart';

void main() {
  late MockApiService mockApiService;

  setUp(() {
    TestHelper.setupMocks();
    mockApiService = MockApiService();
  });

  Widget createOktoberfestScreen({
    String date = '15.10.2024',
    String passnummer = '12345678',
    String vorname = 'Max',
    String nachname = 'Mustermann',
    String geburtsdatum = '01.01.1990',
    ApiService? apiService,
  }) {
    return TestHelper.createTestApp(
      home: OktoberfestEintrittFestzelt(
        date: date,
        passnummer: passnummer,
        vorname: vorname,
        nachname: nachname,
        geburtsdatum: geburtsdatum,
        apiService: apiService ?? mockApiService,
      ),
    );
  }

  group('OktoberfestEintrittFestzelt - Basic Widget Tests', () {
    testWidgets('renders all required elements', (WidgetTester tester) async {
      // Arrange
      when(mockApiService.hasInternet()).thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(createOktoberfestScreen());
      await tester.pump(); // Allow async operations to complete

      // Assert - Basic structure
      expect(find.byType(BaseScreenLayout), findsOneWidget);
      expect(find.text('Eintritt Festzelt'), findsOneWidget);

      // Assert - User data
      expect(find.text('15.10.2024'), findsOneWidget);
      expect(find.text('12345678'), findsOneWidget);
      expect(find.text('Max'), findsOneWidget);
      expect(find.text('Mustermann'), findsOneWidget);
      expect(find.text('01.01.1990'), findsOneWidget);

      // Assert - Table structure
      expect(find.byType(Table), findsOneWidget);
      expect(find.text('Passnummer:'), findsOneWidget);
      expect(find.text('Vorname:'), findsOneWidget);
      expect(find.text('Nachname:'), findsOneWidget);
      expect(find.text('Geburtsdatum:'), findsOneWidget);
    });

    testWidgets('displays background image correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockApiService.hasInternet()).thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(createOktoberfestScreen());
      await tester.pump();

      // Assert - Background image container
      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).image != null,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      final image = decoration.image!;
      expect(image.fit, equals(BoxFit.fitHeight));
      expect(image.alignment, equals(Alignment.topCenter));
    });

    testWidgets('shows current time in correct format', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockApiService.hasInternet()).thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(createOktoberfestScreen());
      await tester.pump();

      // Assert - Time format (HH:MM:SS)
      final timeRegex = RegExp(r'^\d{2}:\d{2}:\d{2}$');
      final timeText = tester.widget<Text>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data != null &&
              timeRegex.hasMatch(widget.data!),
        ),
      );
      expect(timeText.data, matches(timeRegex));
    });

    testWidgets('displays network status correctly when online', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockApiService.hasInternet()).thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(createOktoberfestScreen());
      await tester.pump();
      await tester.pump(); // Allow network check to complete

      // Assert - Online status
      expect(find.text('Online'), findsOneWidget);
      expect(find.byIcon(Icons.wifi), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });

  group('OktoberfestEintrittFestzelt - Clock Functionality Tests', () {
    testWidgets('formats time with leading zeros correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockApiService.hasInternet()).thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(createOktoberfestScreen());
      await tester.pump();

      // Assert - Time format should always have 2 digits for each component
      final timeRegex = RegExp(r'^\d{2}:\d{2}:\d{2}$');
      final timeWidget = tester.widget<Text>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data != null &&
              timeRegex.hasMatch(widget.data!),
        ),
      );

      final timeParts = timeWidget.data!.split(':');
      expect(timeParts.length, equals(3));
      expect(timeParts[0].length, equals(2)); // Hours
      expect(timeParts[1].length, equals(2)); // Minutes
      expect(timeParts[2].length, equals(2)); // Seconds
    });

    testWidgets('stops timer on widget disposal', (WidgetTester tester) async {
      // Arrange
      when(mockApiService.hasInternet()).thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(createOktoberfestScreen());
      await tester.pump();

      // Dispose widget
      await tester.pumpWidget(Container());
      await tester.pump();

      // Assert - No exceptions should occur after disposal
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles rapid widget rebuilds without timer conflicts', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockApiService.hasInternet()).thenAnswer((_) async => true);

      // Act - Create and rebuild widget multiple times
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(createOktoberfestScreen());
        await tester.pump();
        await tester.pumpWidget(Container());
        await tester.pump();
      }

      // Assert - Should handle multiple rebuilds without issues
      expect(tester.takeException(), isNull);
    });
  });

  group('OktoberfestEintrittFestzelt - Network Connectivity Tests', () {
    testWidgets('shows loading state during network check', (
      WidgetTester tester,
    ) async {
      // Arrange
      final completer = Completer<bool>();
      when(mockApiService.hasInternet()).thenAnswer((_) => completer.future);

      // Act
      await tester.pumpWidget(createOktoberfestScreen());
      await tester.pump();

      // Assert - Should show loading state
      expect(find.text('Verbindung prüfen...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future
      completer.complete(true);
      await tester.pump();

      // Assert - Loading should be gone
      expect(find.text('Verbindung prüfen...'), findsNothing);
    });

    testWidgets('refresh button triggers network connectivity check', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockApiService.hasInternet()).thenAnswer((_) async => false);

      // Act
      await tester.pumpWidget(createOktoberfestScreen());
      await tester.pump();
      await tester.pump(); // Allow initial check

      // Verify initial offline state
      expect(find.text('Offline'), findsOneWidget);

      // Change mock to return true and tap refresh
      when(mockApiService.hasInternet()).thenAnswer((_) async => true);
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      await tester.pump(); // Allow network check

      // Assert - Should now show online
      expect(find.text('Online'), findsOneWidget);
      expect(find.byIcon(Icons.wifi), findsOneWidget);
    });
    testWidgets(
      'does not update state if widget is disposed during network check',
      (WidgetTester tester) async {
        // Arrange
        final completer = Completer<bool>();
        when(mockApiService.hasInternet()).thenAnswer((_) => completer.future);

        // Act
        await tester.pumpWidget(createOktoberfestScreen());
        await tester.pump();

        // Dispose widget before network check completes
        await tester.pumpWidget(Container());
        await tester.pump();

        // Complete the network check after disposal
        completer.complete(true);
        await tester.pump();

        // Assert - Should not cause any errors
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('OktoberfestEintrittFestzelt - User Data Display Tests', () {
    testWidgets('displays all user data fields correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockApiService.hasInternet()).thenAnswer((_) async => true);

      const testData = {
        'date': '31.12.2024',
        'passnummer': '87654321',
        'vorname': 'Anna',
        'nachname': 'Schmidt',
        'geburtsdatum': '15.06.1985',
      };

      // Act
      await tester.pumpWidget(
        createOktoberfestScreen(
          date: testData['date']!,
          passnummer: testData['passnummer']!,
          vorname: testData['vorname']!,
          nachname: testData['nachname']!,
          geburtsdatum: testData['geburtsdatum']!,
        ),
      );
      await tester.pump();

      // Assert - All data should be displayed
      expect(find.text(testData['date']!), findsOneWidget);
      expect(find.text(testData['passnummer']!), findsOneWidget);
      expect(find.text(testData['vorname']!), findsOneWidget);
      expect(find.text(testData['nachname']!), findsOneWidget);
      expect(find.text(testData['geburtsdatum']!), findsOneWidget);
    });

    testWidgets('handles empty string values gracefully', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockApiService.hasInternet()).thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(
        createOktoberfestScreen(
          date: '',
          passnummer: '',
          vorname: '',
          nachname: '',
          geburtsdatum: '',
        ),
      );
      await tester.pump();

      // Assert - Should render without errors even with empty values
      expect(find.byType(Table), findsOneWidget);
      expect(find.text('Passnummer:'), findsOneWidget);
      expect(find.text('Vorname:'), findsOneWidget);
      expect(find.text('Nachname:'), findsOneWidget);
      expect(find.text('Geburtsdatum:'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles very long text values correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockApiService.hasInternet()).thenAnswer((_) async => true);

      const longText =
          'Very Long Name That Could Potentially Cause Layout Issues';

      // Act
      await tester.pumpWidget(
        createOktoberfestScreen(vorname: longText, nachname: longText),
      );
      await tester.pump();

      // Assert - Should handle long text without overflow
      expect(find.text(longText), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('displays special characters in user data correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockApiService.hasInternet()).thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(
        createOktoberfestScreen(
          vorname: 'Björn',
          nachname: 'Müller-Lüdenscheidt',
          date: '01.ÄÖÜ.2024',
        ),
      );
      await tester.pump();

      // Assert - Special characters should be displayed correctly
      expect(find.text('Björn'), findsOneWidget);
      expect(find.text('Müller-Lüdenscheidt'), findsOneWidget);
      expect(find.text('01.ÄÖÜ.2024'), findsOneWidget);
    });

    testWidgets('table layout maintains proper alignment', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockApiService.hasInternet()).thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(createOktoberfestScreen());
      await tester.pump();

      // Assert - Table structure
      final table = tester.widget<Table>(find.byType(Table));
      expect(table.children.length, equals(4)); // 4 rows
      expect(
        table.defaultVerticalAlignment,
        equals(TableCellVerticalAlignment.middle),
      );
      expect(table.columnWidths?[0], isA<IntrinsicColumnWidth>());
      expect(table.columnWidths?[1], isA<IntrinsicColumnWidth>());

      // Check that all labels end with colon
      expect(find.text('Passnummer:'), findsOneWidget);
      expect(find.text('Vorname:'), findsOneWidget);
      expect(find.text('Nachname:'), findsOneWidget);
      expect(find.text('Geburtsdatum:'), findsOneWidget);
    });
  });

  group('OktoberfestEintrittFestzelt - UI Layout and Styling Tests', () {
    testWidgets('applies correct styling to text elements', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockApiService.hasInternet()).thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(createOktoberfestScreen());
      await tester.pump();

      // Assert - Date styling
      final dateText = tester.widget<Text>(find.text('15.10.2024'));
      expect(dateText.style?.fontWeight, equals(FontWeight.bold));
      expect(dateText.style?.fontSize, equals(UIConstants.titleFontSize));
      expect(dateText.style?.color, equals(UIConstants.textColor));

      // Assert - Time styling
      final timeWidget = tester.widget<Text>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data != null &&
              RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(widget.data!),
        ),
      );
      expect(timeWidget.style?.fontWeight, equals(FontWeight.bold));
      expect(timeWidget.style?.fontSize, equals(UIConstants.titleFontSize));
      expect(timeWidget.style?.color, equals(UIConstants.textColor));
    });

    testWidgets('applies correct container styling to user data values', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockApiService.hasInternet()).thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(createOktoberfestScreen());
      await tester.pump();

      // Assert - Container styling for user data
      final containers = tester.widgetList<Container>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color ==
                  UIConstants.whiteColor,
        ),
      );

      expect(containers.length, equals(4)); // One for each user data field

      for (final container in containers) {
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, equals(UIConstants.whiteColor));
        expect(decoration.border, isA<Border>());
        expect(decoration.borderRadius, isA<BorderRadius>());
      }
    });

    testWidgets('maintains proper spacing between elements', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockApiService.hasInternet()).thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(createOktoberfestScreen());
      await tester.pump();

      // Assert - SizedBox spacing
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(sizedBoxes.length, greaterThan(0));

      // Check for consistent spacing
      final spacingSBoxes = sizedBoxes.where(
        (box) => box.height == UIConstants.spacingS,
      );
      expect(spacingSBoxes.length, greaterThan(0));
    });


  });

  group('OktoberfestEintrittFestzelt - Performance Tests', () {
    testWidgets('manages memory efficiently during extended operation', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockApiService.hasInternet()).thenAnswer((_) async => true);

      // Act - Simulate extended operation
      await tester.pumpWidget(createOktoberfestScreen());
      await tester.pump();

      // Simulate multiple network checks and time updates
      for (int i = 0; i < 50; i++) {
        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Assert - Should maintain performance
      expect(tester.takeException(), isNull);
      expect(find.text('Online'), findsOneWidget);
    });
  });

  group('OktoberfestEintrittFestzelt - Integration and State Management', () {
    testWidgets('maintains state consistency across widget rebuilds', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockApiService.hasInternet()).thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(createOktoberfestScreen());
      await tester.pump();
      await tester.pump(); // Initial network check

      // Verify initial state
      expect(find.text('Online'), findsOneWidget);

      // Rebuild widget with same data
      await tester.pumpWidget(createOktoberfestScreen());
      await tester.pump();
      await tester.pump(); // Allow new network check

      // Assert - State should be consistent after rebuild
      expect(find.text('Online'), findsOneWidget);
      expect(find.text('15.10.2024'), findsOneWidget);
      expect(find.text('Max'), findsOneWidget);
      expect(find.text('Mustermann'), findsOneWidget);
    });

    testWidgets('preserves user data integrity during all operations', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockApiService.hasInternet()).thenAnswer((_) async => true);

      const originalData = {
        'date': '25.12.2024',
        'passnummer': 'TEST123456',
        'vorname': 'Integration',
        'nachname': 'Test',
        'geburtsdatum': '31.12.1999',
      };

      // Act
      await tester.pumpWidget(
        createOktoberfestScreen(
          date: originalData['date']!,
          passnummer: originalData['passnummer']!,
          vorname: originalData['vorname']!,
          nachname: originalData['nachname']!,
          geburtsdatum: originalData['geburtsdatum']!,
        ),
      );
      await tester.pump();

      // Perform various operations
      await tester.pump(const Duration(seconds: 2)); // Timer updates
      await tester.tap(find.byIcon(Icons.refresh)); // Network refresh
      await tester.pump();
      await tester.pump();

      // Multiple timer cycles
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      // Assert - User data should remain unchanged throughout all operations
      expect(find.text(originalData['date']!), findsOneWidget);
      expect(find.text(originalData['passnummer']!), findsOneWidget);
      expect(find.text(originalData['vorname']!), findsOneWidget);
      expect(find.text(originalData['nachname']!), findsOneWidget);
      expect(find.text(originalData['geburtsdatum']!), findsOneWidget);
    });
  });

  // Fixed accessibility test - CORRECTED the chaining issue
  group('OktoberfestEintrittFestzelt - Fixed Accessibility Tests', () {
    testWidgets('refresh button is accessible via tap - FIXED', (
      WidgetTester tester,
    ) async {
      // Arrange - FIXED: Don't chain thenAnswer calls
      bool networkState = false;
      when(mockApiService.hasInternet()).thenAnswer((_) async => networkState);

      // Act
      await tester.pumpWidget(createOktoberfestScreen());
      await tester.pump();
      await tester.pump(); // Initial network check

      expect(find.text('Offline'), findsOneWidget);

      // Change network state and tap refresh
      networkState = true;
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      await tester.pump(); // Network check after refresh

      // Assert - Should change to online
      expect(find.text('Online'), findsOneWidget);
    });

    testWidgets('provides appropriate contrast ratios', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockApiService.hasInternet()).thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(createOktoberfestScreen());
      await tester.pump();
      await tester.pump();

      // Assert - Text should have appropriate contrast against background
      final dateText = tester.widget<Text>(find.text('15.10.2024'));
      expect(dateText.style?.color, equals(UIConstants.textColor));

      final timeWidget = tester.widget<Text>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data != null &&
              RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(widget.data!),
        ),
      );
      expect(timeWidget.style?.color, equals(UIConstants.textColor));

      // Network status should use appropriate colors
      final onlineText = tester.widget<Text>(find.text('Online'));
      expect(onlineText.style?.color, equals(Colors.green));
    });
  });
}
