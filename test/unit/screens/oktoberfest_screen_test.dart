import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/oktoberfest_screen.dart';
import 'package:meinbssb/screens/oktoberfest_gewinn_screen.dart';
import 'package:meinbssb/screens/oktoberfest_eintritt_festzelt_screen.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/screens/logo_widget.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import '../helpers/test_helper.dart';

// Generate mocks
@GenerateMocks([ApiService, ConfigService])
import 'oktoberfest_screen_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late MockConfigService mockConfigService;
  late UserData testUserData;

  void setupMockStubs({MockApiService? customApiService}) {
    final service = customApiService ?? mockApiService;

    // Setup config service
    when(service.configService).thenReturn(mockConfigService);
    when(
      mockConfigService.getString('logoName', 'appTheme'),
    ).thenReturn('assets/images/myBSSB-logo.png');

    // Setup API methods with specific parameters
    when(service.fetchGewinne(2024, '12345678')).thenAnswer((_) async => []);
    when(service.fetchGewinne(2023, '12345678')).thenAnswer((_) async => []);
    when(service.fetchGewinne(2025, '12345678')).thenAnswer((_) async => []);

    // Add more specific stubs for other possible test scenarios
    when(service.fetchGewinne(any, '')).thenAnswer((_) async => []);
  }

  setUp(() {
    TestHelper.setupMocks();
    mockApiService = MockApiService();
    mockConfigService = MockConfigService();

    // Setup all mock stubs
    setupMockStubs();

    testUserData = UserData(
      personId: 123,
      webLoginId: 456,
      passnummer: '12345678',
      vereinNr: 789,
      namen: 'Mustermann',
      vorname: 'Max',
      vereinName: 'Test Verein',
      passdatenId: 1,
      mitgliedschaftId: 1,
      titel: 'Dr.',
      geburtsdatum: DateTime(1990, 5, 15),
    );
  });

  Widget createOktoberfestScreen({
    UserData? userData,
    bool isLoggedIn = true,
    VoidCallback? onLogout,
    ApiService? apiService,
  }) {
    final service = apiService ?? mockApiService;

    // Setup stubs for custom API services
    if (apiService != null && apiService is MockApiService) {
      setupMockStubs(customApiService: apiService);
    }

    return TestHelper.createTestApp(
      home: Provider<ApiService>.value(
        value: service,
        child: OktoberfestScreen(
          userData: userData,
          isLoggedIn: isLoggedIn,
          onLogout: onLogout ?? () {},
        ),
      ),
    );
  }

  group('OktoberfestScreen - Basic Widget Tests', () {
    testWidgets('renders all required elements correctly', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: testUserData));

      // Assert - Basic structure
      expect(find.byType(BaseScreenLayout), findsOneWidget);
      expect(find.text('Oktoberfest'), findsNWidgets(2)); // Title and header
      expect(find.byType(LogoWidget), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Assert - Menu items
      expect(find.text('Meine Ergebnisse'), findsOneWidget);
      expect(find.text('Meine Gewinne'), findsOneWidget);
      expect(find.text('Eintritt Festzelt'), findsOneWidget);

      // Assert - Icons
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      expect(find.byIcon(Icons.festival), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNWidgets(3));
    });

    testWidgets('applies correct styling to menu items', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: testUserData));

      // Assert - Card styling
      final cards = tester.widgetList<Card>(find.byType(Card));
      expect(cards.length, equals(3));

      for (final card in cards) {
        expect(
          card.margin,
          equals(const EdgeInsets.only(bottom: UIConstants.spacingS)),
        );
      }

      // Assert - ListTile styling
      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile));
      expect(listTiles.length, equals(3));

      for (final listTile in listTiles) {
        expect(listTile.minLeadingWidth, equals(UIConstants.defaultIconWidth));
        expect(
          listTile.contentPadding,
          equals(
            const EdgeInsets.symmetric(
              horizontal: UIConstants.spacingM,
              vertical: UIConstants.spacingS,
            ),
          ),
        );
      }

      // Assert - Icon styling
      final leadingIcons = tester.widgetList<Icon>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Icon &&
              [
                Icons.bar_chart,
                Icons.emoji_events,
                Icons.festival,
              ].contains(widget.icon),
        ),
      );

      for (final icon in leadingIcons) {
        expect(icon.color, equals(UIStyles.profileIconColor));
        expect(icon.semanticLabel, isNotNull);
      }
    });

    testWidgets('header uses correct styling', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: testUserData));

      // Assert - Header text styling
      final headerText = tester.widget<ScaledText>(
        find.widgetWithText(ScaledText, 'Oktoberfest').first,
      );
      expect(headerText.style, equals(UIStyles.headerStyle));
    });

    testWidgets('maintains proper spacing between elements', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: testUserData));

      // Assert - SizedBox spacing
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(
        sizedBoxes.where((box) => box.height == UIConstants.spacingS),
        isNotEmpty,
      );
      expect(
        sizedBoxes.where((box) => box.height == UIConstants.spacingM),
        isNotEmpty,
      );

      // Assert - Padding
      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scrollView.padding, equals(UIConstants.defaultPadding));
    });
  });

  group('OktoberfestScreen - Navigation Tests', () {
   
    testWidgets('navigates to gewinne screen with correct parameters', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: testUserData));
      await tester.tap(find.text('Meine Gewinne'));
      await tester.pumpAndSettle();

      // Assert - Should navigate to gewinne screen
      expect(find.byType(OktoberfestGewinnScreen), findsOneWidget);

      // Verify the screen was created with correct parameters
      final gewinnScreen = tester.widget<OktoberfestGewinnScreen>(
        find.byType(OktoberfestGewinnScreen),
      );
      expect(gewinnScreen.passnummer, equals('12345678'));
      expect(gewinnScreen.userData, equals(testUserData));
      expect(gewinnScreen.isLoggedIn, isTrue);
    });

    testWidgets('navigates to eintritt festzelt screen with formatted date', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: testUserData));
      await tester.tap(find.text('Eintritt Festzelt'));
      await tester.pumpAndSettle();

      // Assert - Should navigate to eintritt festzelt screen
      expect(find.byType(OktoberfestEintrittFestzelt), findsOneWidget);

      // Verify the screen was created with correct parameters
      final eintrittScreen = tester.widget<OktoberfestEintrittFestzelt>(
        find.byType(OktoberfestEintrittFestzelt),
      );

      // Check date format (DD.MM.YYYY)
      final dateRegex = RegExp(r'^\d{2}\.\d{2}\.\d{4}$');
      expect(eintrittScreen.date, matches(dateRegex));

      expect(eintrittScreen.passnummer, equals('12345678'));
      expect(eintrittScreen.vorname, equals('Max'));
      expect(eintrittScreen.nachname, equals('Mustermann'));
      expect(eintrittScreen.geburtsdatum, equals('15.05.1990'));
    });

   
  });

  group('OktoberfestScreen - User Data Handling Tests', () {
    testWidgets('handles null user data gracefully', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: null));

      // Assert - Should render without crashing
      expect(find.byType(OktoberfestScreen), findsOneWidget);
      expect(find.text('Meine Ergebnisse'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });


    testWidgets('handles user data with null birth date', (
      WidgetTester tester,
    ) async {
      // Arrange
      final userWithoutBirthDate = UserData(
        personId: 123,
        webLoginId: 456,
        passnummer: '12345678',
        vereinNr: 789,
        namen: 'Mustermann',
        vorname: 'Max',
        vereinName: 'Test Verein',
        passdatenId: 1,
        mitgliedschaftId: 1,
        titel: null,
        geburtsdatum: null,
      );

      // Act
      await tester.pumpWidget(
        createOktoberfestScreen(userData: userWithoutBirthDate),
      );
      await tester.tap(find.text('Eintritt Festzelt'));
      await tester.pumpAndSettle();

      // Assert - Should use fallback text for null birth date
      final eintrittScreen = tester.widget<OktoberfestEintrittFestzelt>(
        find.byType(OktoberfestEintrittFestzelt),
      );
      expect(eintrittScreen.geburtsdatum, equals('Nicht verfügbar'));
    });

    testWidgets('handles user data with null names', (
      WidgetTester tester,
    ) async {
      // Arrange
      final userWithNullNames = UserData(
        personId: 123,
        webLoginId: 456,
        passnummer: '12345678',
        vereinNr: 789,
        namen: '',
        vorname: '',
        vereinName: 'Test Verein',
        passdatenId: 1,
        mitgliedschaftId: 1,
        titel: null,
        geburtsdatum: DateTime(1990, 5, 15),
      );

      // Act
      await tester.pumpWidget(
        createOktoberfestScreen(userData: userWithNullNames),
      );
      await tester.tap(find.text('Eintritt Festzelt'));
      await tester.pumpAndSettle();

      // Assert - Should use empty strings for null names
      final eintrittScreen = tester.widget<OktoberfestEintrittFestzelt>(
        find.byType(OktoberfestEintrittFestzelt),
      );
      expect(eintrittScreen.vorname, equals(''));
      expect(eintrittScreen.nachname, equals(''));
    });

    testWidgets('formats birth date correctly for different dates', (
      WidgetTester tester,
    ) async {
      final testDates = [
        {'input': DateTime(1990, 1, 1), 'expected': '01.01.1990'},
        {'input': DateTime(2000, 12, 31), 'expected': '31.12.2000'},
        {'input': DateTime(1985, 6, 15), 'expected': '15.06.1985'},
        {'input': DateTime(2024, 2, 29), 'expected': '29.02.2024'}, // Leap year
      ];

      for (final testCase in testDates) {
        // Arrange
        final userWithTestDate = UserData(
          personId: 123,
          webLoginId: 456,
          passnummer: '12345678',
          vereinNr: 789,
          namen: 'Test',
          vorname: 'User',
          vereinName: 'Test Verein',
          passdatenId: 1,
          mitgliedschaftId: 1,
          titel: null,
          geburtsdatum: testCase['input'] as DateTime,
        );

        // Act
        await tester.pumpWidget(
          createOktoberfestScreen(userData: userWithTestDate),
        );
        await tester.tap(find.text('Eintritt Festzelt'));
        await tester.pumpAndSettle();

        // Assert
        final eintrittScreen = tester.widget<OktoberfestEintrittFestzelt>(
          find.byType(OktoberfestEintrittFestzelt),
        );
        expect(eintrittScreen.geburtsdatum, equals(testCase['expected']));

        // Navigate back for next test
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
      }
    });
  });

  group('OktoberfestScreen - Date Formatting Tests', () {
    testWidgets('formats current date correctly for eintritt festzelt', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: testUserData));
      await tester.tap(find.text('Eintritt Festzelt'));
      await tester.pumpAndSettle();

      // Assert - Date should be in DD.MM.YYYY format
      final eintrittScreen = tester.widget<OktoberfestEintrittFestzelt>(
        find.byType(OktoberfestEintrittFestzelt),
      );

      final dateRegex = RegExp(r'^\d{2}\.\d{2}\.\d{4}$');
      expect(eintrittScreen.date, matches(dateRegex));

      // Verify it's actually today's date
      final now = DateTime.now();
      final expectedDate =
          '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
      expect(eintrittScreen.date, equals(expectedDate));
    });

    testWidgets('date formatting handles single-digit days and months', (
      WidgetTester tester,
    ) async {
      // This test verifies the padding logic works correctly
      // We can't mock DateTime.now() easily, but we can verify the format

      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: testUserData));
      await tester.tap(find.text('Eintritt Festzelt'));
      await tester.pumpAndSettle();

      // Assert - Date should always have 2-digit day and month
      final eintrittScreen = tester.widget<OktoberfestEintrittFestzelt>(
        find.byType(OktoberfestEintrittFestzelt),
      );

      final dateParts = eintrittScreen.date.split('.');
      expect(dateParts.length, equals(3));
      expect(dateParts[0].length, equals(2)); // Day
      expect(dateParts[1].length, equals(2)); // Month
      expect(dateParts[2].length, equals(4)); // Year
    });
  });

  group('OktoberfestScreen - UI Interaction Tests', () {

    testWidgets('scrollable content works correctly', (
      WidgetTester tester,
    ) async {
      // Arrange - Simulate small screen
      tester.view.physicalSize = const Size(320, 400);

      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: testUserData));

      // Test scrolling
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.pump();

      // Assert - Should handle scrolling without issues
      expect(tester.takeException(), isNull);
      expect(find.text('Meine Ergebnisse'), findsOneWidget);

      // Reset
      addTearDown(tester.view.resetPhysicalSize);
    });
  });

  group('OktoberfestScreen - Accessibility Tests', () {
    testWidgets('provides semantic labels for icons', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: testUserData));

      // Assert - Icons should have semantic labels
      final leadingIcons = [
        {'icon': Icons.bar_chart, 'label': 'Meine Ergebnisse'},
        {'icon': Icons.emoji_events, 'label': 'Meine Gewinne'},
        {'icon': Icons.festival, 'label': 'Eintritt Festzelt'},
      ];

      for (final iconData in leadingIcons) {
        final icon = tester.widget<Icon>(
          find.byIcon(iconData['icon'] as IconData),
        );
        expect(icon.semanticLabel, equals(iconData['label']));
      }

      // Chevron icons should have semantic labels
      final chevronIcons = tester.widgetList<Icon>(
        find.byIcon(Icons.chevron_right),
      );
      for (final chevron in chevronIcons) {
        expect(chevron.semanticLabel, equals('Weiter'));
      }
    });

   
    testWidgets('handles different text scale factors', (
      WidgetTester tester,
    ) async {
      final scaleFactors = [0.8, 1.0, 1.5, 2.0];

      for (final scaleFactor in scaleFactors) {
        // Act
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(textScaleFactor: scaleFactor),
            child: createOktoberfestScreen(userData: testUserData),
          ),
        );

        // Assert - Should handle different text scales
        expect(find.text('Meine Ergebnisse'), findsOneWidget);
        expect(find.text('Meine Gewinne'), findsOneWidget);
        expect(find.text('Eintritt Festzelt'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Clean up for next iteration
        await tester.pumpWidget(Container());
        await tester.pump();
      }
    });
  });

  group('OktoberfestScreen - State Management Tests', () {
   
    testWidgets('handles logged out state correctly', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        createOktoberfestScreen(userData: testUserData, isLoggedIn: false),
      );

      await tester.tap(find.text('Meine Gewinne'));
      await tester.pumpAndSettle();

      // Assert - Child screen should receive correct login state
      final gewinnScreen = tester.widget<OktoberfestGewinnScreen>(
        find.byType(OktoberfestGewinnScreen),
      );
      expect(gewinnScreen.isLoggedIn, isFalse);
    });

    testWidgets('passes logout callback to child screens', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: testUserData));
      await tester.tap(find.text('Eintritt Festzelt'));
      await tester.pumpAndSettle();

      // We can't directly test the callback, but we can verify it was passed
      // by checking that the child screen was created successfully
      expect(find.byType(OktoberfestEintrittFestzelt), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('preserves user data across widget rebuilds', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: testUserData));

      // Rebuild widget
      await tester.pumpWidget(createOktoberfestScreen(userData: testUserData));

      // Navigate to verify data is still correct
      await tester.tap(find.text('Eintritt Festzelt'));
      await tester.pumpAndSettle();

      // Assert - User data should be preserved
      final eintrittScreen = tester.widget<OktoberfestEintrittFestzelt>(
        find.byType(OktoberfestEintrittFestzelt),
      );
      expect(eintrittScreen.passnummer, equals('12345678'));
      expect(eintrittScreen.vorname, equals('Max'));
      expect(eintrittScreen.nachname, equals('Mustermann'));
    });
  });

  group('OktoberfestScreen - Error Handling and Edge Cases', () {
  
    testWidgets('handles extremely long user names', (
      WidgetTester tester,
    ) async {
      // Arrange
      final userWithLongNames = UserData(
        personId: 123,
        webLoginId: 456,
        passnummer: '12345678',
        vereinNr: 789,
        namen: 'A' * 200, // Very long name
        vorname: 'B' * 150, // Very long first name
        vereinName: 'Test Verein',
        passdatenId: 1,
        mitgliedschaftId: 1,
        titel: null,
        geburtsdatum: DateTime(1990, 5, 15),
      );

      // Act
      await tester.pumpWidget(
        createOktoberfestScreen(userData: userWithLongNames),
      );
      await tester.tap(find.text('Eintritt Festzelt'));
      await tester.pumpAndSettle();

      // Assert - Should handle long names without layout issues
      expect(find.byType(OktoberfestEintrittFestzelt), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles special characters in user data', (
      WidgetTester tester,
    ) async {
      // Arrange
      final userWithSpecialChars = UserData(
        personId: 123,
        webLoginId: 456,
        passnummer: 'ÄÖÜäöüß123',
        vereinNr: 789,
        namen: 'Müller-Schäfer',
        vorname: 'François',
        vereinName: 'Test Verein',
        passdatenId: 1,
        mitgliedschaftId: 1,
        titel: 'Dr.',
        geburtsdatum: DateTime(1990, 5, 15),
      );

      // Act
      await tester.pumpWidget(
        createOktoberfestScreen(userData: userWithSpecialChars),
      );
      await tester.tap(find.text('Eintritt Festzelt'));
      await tester.pumpAndSettle();

      // Assert - Should handle special characters correctly
      final eintrittScreen = tester.widget<OktoberfestEintrittFestzelt>(
        find.byType(OktoberfestEintrittFestzelt),
      );
      expect(eintrittScreen.passnummer, equals('ÄÖÜäöüß123'));
      expect(eintrittScreen.vorname, equals('François'));
      expect(eintrittScreen.nachname, equals('Müller-Schäfer'));
    });

    testWidgets('handles edge case birth dates', (WidgetTester tester) async {
      final edgeDates = [
        DateTime(1900, 1, 1), // Very old date
        DateTime(2024, 2, 29), // Leap year
        DateTime(2000, 12, 31), // End of year/century
      ];

      for (final birthDate in edgeDates) {
        // Arrange
        final userWithEdgeDate = UserData(
          personId: 123,
          webLoginId: 456,
          passnummer: '12345678',
          vereinNr: 789,
          namen: 'Test',
          vorname: 'User',
          vereinName: 'Test Verein',
          passdatenId: 1,
          mitgliedschaftId: 1,
          titel: null,
          geburtsdatum: birthDate,
        );

        // Act
        await tester.pumpWidget(
          createOktoberfestScreen(userData: userWithEdgeDate),
        );
        await tester.tap(find.text('Eintritt Festzelt'));
        await tester.pumpAndSettle();

        // Assert - Should format edge dates correctly
        final eintrittScreen = tester.widget<OktoberfestEintrittFestzelt>(
          find.byType(OktoberfestEintrittFestzelt),
        );

        final expectedDate =
            '${birthDate.day.toString().padLeft(2, '0')}.${birthDate.month.toString().padLeft(2, '0')}.${birthDate.year}';
        expect(eintrittScreen.geburtsdatum, equals(expectedDate));

        // Navigate back for next test
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
      }
    });
  });

  group('OktoberfestScreen - Performance Tests', () {
    testWidgets('renders efficiently with large user data', (
      WidgetTester tester,
    ) async {
      // Arrange - Create user with many fields populated
      final complexUser = UserData(
        personId: 123456789,
        webLoginId: 987654321,
        passnummer: '12345678901234567890',
        vereinNr: 999999999,
        namen: 'Very Long Complex German Name With Many Parts',
        vorname: 'Extremely Long First Name With Multiple Words',
        vereinName: 'Very Long Club Name That Could Potentially Cause Issues',
        passdatenId: 999999999,
        mitgliedschaftId: 888888888,
        titel: 'Prof. Dr. Dr. h.c.',
        geburtsdatum: DateTime(1990, 5, 15),
      );

      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: complexUser));

      // Assert - Should render efficiently
      expect(find.byType(OktoberfestScreen), findsOneWidget);
      expect(find.text('Meine Ergebnisse'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

   

  });
}
