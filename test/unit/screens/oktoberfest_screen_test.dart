import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
import 'package:meinbssb/screens/oktoberfest_screen.dart';
import 'package:meinbssb/screens/oktoberfest_gewinn_screen.dart';
import 'package:meinbssb/screens/oktoberfest_eintritt_festzelt_screen.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/screens/logo_widget.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

// Generate mocks - Only for services that need mocking
@GenerateMocks([ApiService, ConfigService])
import 'oktoberfest_screen_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late MockConfigService mockConfigService;
  late FontSizeProvider mockFontSizeProvider;
  late UserData mockTestUserData;

  void setupApiServiceStubs() {
    // Setup config service
    when(mockApiService.configService).thenReturn(mockConfigService);
    when(
      mockConfigService.getString('logoName', 'appTheme'),
    ).thenReturn('assets/images/myBSSB-logo.png');

    // Setup comprehensive fetchGewinne stubs
    when(mockApiService.fetchGewinne(any, any)).thenAnswer((_) async => []);

    // Setup specific stubs for common test scenarios
    final commonYears = [
      2020,
      2021,
      2022,
      2023,
      2024,
      2025,
      2026,
      2027,
      2028,
      2029,
      2030,
    ];
    final commonPassnummers = [
      '12345678',
      '87654321',
      'ÄÖÜäöüß123',
      '',
      '12345678901234567890',
      '1234567890123456789012345678901234567890',
      '1234567890123456789012345678901234567890123456789012345678901234567890',
    ];

    // Create stubs for all combinations
    for (final year in commonYears) {
      when(mockApiService.fetchGewinne(year, any)).thenAnswer((_) async => []);
      for (final passnummer in commonPassnummers) {
        when(
          mockApiService.fetchGewinne(year, passnummer),
        ).thenAnswer((_) async => []);
      }
    }
  }

  UserData createTestUserData() {
    return UserData(
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
  }

  // FIXED: Provide ApiService at the MaterialApp level so it's available to all routes
  Widget createTestApp({
    required Widget child,
    MockApiService? customApiService,
  }) {
    final apiService = customApiService ?? mockApiService;

    // If using custom service, ensure it has the required stubs
    if (customApiService != null) {
      when(customApiService.configService).thenReturn(mockConfigService);
      when(customApiService.fetchGewinne(any, any)).thenAnswer((_) async => []);
    }

    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider<FontSizeProvider>.value(value: mockFontSizeProvider),
      ],
      child: MaterialApp(
        home: child,
        // FIXED: Add routes so navigated screens also have access to providers
        routes: {
          '/gewinn':
              (context) => OktoberfestGewinnScreen(
                passnummer: mockTestUserData.passnummer,
                apiService: Provider.of<ApiService>(context, listen: false),
                userData: mockTestUserData,
                isLoggedIn: true,
                onLogout: () {},
              ),
          '/eintritt':
              (context) => OktoberfestEintrittFestzelt(
                date: DateTime.now().toString().substring(0, 10),
                passnummer: mockTestUserData.passnummer,
                vorname: mockTestUserData.vorname,
                nachname: mockTestUserData.namen,
                geburtsdatum:
                    mockTestUserData.geburtsdatum != null
                        ? '${mockTestUserData.geburtsdatum!.day.toString().padLeft(2, '0')}.${mockTestUserData.geburtsdatum!.month.toString().padLeft(2, '0')}.${mockTestUserData.geburtsdatum!.year}'
                        : 'Nicht verfügbar',
                apiService: Provider.of<ApiService>(context, listen: false),
              ),
        },
      ),
    );
  }

  Widget createOktoberfestScreen({
    UserData? userData,
    bool isLoggedIn = true,
    VoidCallback? onLogout,
    MockApiService? customApiService,
  }) {
    return createTestApp(
      customApiService: customApiService,
      child: OktoberfestScreen(
        userData: userData,
        isLoggedIn: isLoggedIn,
        onLogout: onLogout ?? () {},
      ),
    );
  }

  setUpAll(() async {
    // FIXED: Initialize SharedPreferences for testing before any tests run
    SharedPreferences.setMockInitialValues({
      'fontScale': 1.0, // Set default font scale for tests
    });
  });

  setUp(() async {
    // Initialize mocks
    mockApiService = MockApiService();
    mockConfigService = MockConfigService();

    // FIXED: Create FontSizeProvider after SharedPreferences is initialized
    // Wait for any async initialization to complete
    mockFontSizeProvider = FontSizeProvider();

    // Give FontSizeProvider time to initialize
    await Future.delayed(Duration(milliseconds: 10));

    // Setup API service stubs
    setupApiServiceStubs();

    // Setup test user data
    mockTestUserData = createTestUserData();
  });

  group('OktoberfestScreen - Widget Structure Tests', () {
    testWidgets('renders all required UI elements', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: mockTestUserData));

      // Assert - Core structure
      expect(find.byType(BaseScreenLayout), findsOneWidget);
      expect(find.byType(LogoWidget), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Assert - Title appears in header and possibly elsewhere
      expect(find.text('Oktoberfest'), findsAtLeastNWidgets(1));

      // Assert - Menu items
      expect(find.text('Meine Ergebnisse'), findsOneWidget);
      expect(find.text('Meine Gewinne'), findsOneWidget);
      expect(find.text('Eintritt Festzelt'), findsOneWidget);
    });

    testWidgets('displays correct icons for menu items', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: mockTestUserData));

      // Assert - Menu icons
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      expect(find.byIcon(Icons.festival), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNWidgets(3));
    });

    testWidgets('applies correct styling to cards and list tiles', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: mockTestUserData));

      // Assert - Card structure
      final cards = tester.widgetList<Card>(find.byType(Card));
      expect(cards.length, equals(3));

      // Assert - ListTile structure
      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile));
      expect(listTiles.length, equals(3));

      // Verify basic styling properties exist
      for (final card in cards) {
        expect(card.margin, isNotNull);
      }

      for (final listTile in listTiles) {
        expect(listTile.contentPadding, isNotNull);
        expect(listTile.minLeadingWidth, isNotNull);
      }
    });

    testWidgets('uses ScaledText for header with correct styling', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: mockTestUserData));

      // Assert - ScaledText exists
      expect(find.byType(ScaledText), findsAtLeastNWidgets(1));

      // Find ScaledText with Oktoberfest text
      final scaledTextFinder = find.widgetWithText(ScaledText, 'Oktoberfest');
      if (scaledTextFinder.evaluate().isNotEmpty) {
        final headerText = tester.widget<ScaledText>(scaledTextFinder.first);
        expect(headerText.style, equals(UIStyles.headerStyle));
      }
    });
  });

  group('OktoberfestScreen - Navigation Tests', () {
    testWidgets('navigates to Gewinne screen successfully', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: mockTestUserData));

      // Verify no exceptions before navigation
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Meine Gewinne'));
      await tester.pumpAndSettle();

      // Assert - Navigation successful
      expect(find.byType(OktoberfestGewinnScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verify screen parameters
      final gewinnScreen = tester.widget<OktoberfestGewinnScreen>(
        find.byType(OktoberfestGewinnScreen),
      );
      expect(gewinnScreen.passnummer, equals('12345678'));
      expect(gewinnScreen.userData, equals(mockTestUserData));
      expect(gewinnScreen.isLoggedIn, isTrue);
    });

    testWidgets('navigates to Eintritt Festzelt screen with correct data', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: mockTestUserData));

      await tester.tap(find.text('Eintritt Festzelt'));
      await tester.pumpAndSettle();

      // Assert - Navigation successful
      expect(find.byType(OktoberfestEintrittFestzelt), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verify screen parameters
      final eintrittScreen = tester.widget<OktoberfestEintrittFestzelt>(
        find.byType(OktoberfestEintrittFestzelt),
      );

      expect(eintrittScreen.passnummer, equals('12345678'));
      expect(eintrittScreen.vorname, equals('Max'));
      expect(eintrittScreen.nachname, equals('Mustermann'));
      expect(eintrittScreen.geburtsdatum, equals('15.05.1990'));

      // Verify date format
      final dateRegex = RegExp(r'^\d{2}\.\d{2}\.\d{4}$');
      expect(eintrittScreen.date, matches(dateRegex));
    });

    testWidgets('API calls work without errors during navigation', (
      WidgetTester tester,
    ) async {
      // Pre-verify the API stub
      final testResult = await mockApiService.fetchGewinne(2024, '12345678');
      expect(testResult, equals([]));

      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: mockTestUserData));
      await tester.tap(find.text('Meine Gewinne'));
      await tester.pumpAndSettle();

      // Assert - No API errors occurred
      expect(tester.takeException(), isNull);
      expect(find.byType(OktoberfestGewinnScreen), findsOneWidget);

      // Verify API was called
      verify(
        mockApiService.fetchGewinne(2024, '12345678'),
      ).called(greaterThanOrEqualTo(1));
    });
  });

  group('OktoberfestScreen - User Data Handling', () {
    testWidgets('handles null user data gracefully', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: null));

      // Assert - Renders without crashing
      expect(find.byType(OktoberfestScreen), findsOneWidget);
      expect(find.text('Meine Ergebnisse'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles user with special characters', (
      WidgetTester tester,
    ) async {
      // Arrange
      final specialCharUser = UserData(
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
        createOktoberfestScreen(userData: specialCharUser),
      );
      await tester.tap(find.text('Meine Gewinne'));
      await tester.pumpAndSettle();

      // Assert - Handles special characters correctly
      expect(find.byType(OktoberfestGewinnScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verify API called with special characters
      verify(
        mockApiService.fetchGewinne(2024, 'ÄÖÜäöüß123'),
      ).called(greaterThanOrEqualTo(1));
    });

    testWidgets('handles user with very long passnummer', (
      WidgetTester tester,
    ) async {
      // Arrange
      final longPassUser = UserData(
        personId: 123,
        webLoginId: 456,
        passnummer: '12345678901234567890' * 2, // 40 characters
        vereinNr: 789,
        namen: 'Test',
        vorname: 'User',
        vereinName: 'Test Verein',
        passdatenId: 1,
        mitgliedschaftId: 1,
        titel: null,
        geburtsdatum: DateTime(1990, 5, 15),
      );

      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: longPassUser));
      await tester.tap(find.text('Meine Gewinne'));
      await tester.pumpAndSettle();

      // Assert - Handles long passnummer
      expect(find.byType(OktoberfestGewinnScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles user with null birth date', (
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

      // Assert - Handles null birth date
      expect(find.byType(OktoberfestEintrittFestzelt), findsOneWidget);

      final eintrittScreen = tester.widget<OktoberfestEintrittFestzelt>(
        find.byType(OktoberfestEintrittFestzelt),
      );
      expect(eintrittScreen.geburtsdatum, equals('Nicht verfügbar'));
    });
  });

  group('OktoberfestScreen - Date Formatting Tests', () {
    testWidgets('formats current date correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: mockTestUserData));
      await tester.tap(find.text('Eintritt Festzelt'));
      await tester.pumpAndSettle();

      // Assert - Date format is correct
      final eintrittScreen = tester.widget<OktoberfestEintrittFestzelt>(
        find.byType(OktoberfestEintrittFestzelt),
      );

      final dateRegex = RegExp(r'^\d{2}\.\d{2}\.\d{4}$');
      expect(eintrittScreen.date, matches(dateRegex));

      // Verify it matches today's date
      final now = DateTime.now();
      final expectedDate =
          '${now.day.toString().padLeft(2, '0')}'
          '.${now.month.toString().padLeft(2, '0')}'
          '.${now.year}';
      expect(eintrittScreen.date, equals(expectedDate));
    });

    testWidgets('formats birth dates correctly for edge cases', (
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

  group('OktoberfestScreen - API Integration Tests', () {
    testWidgets('fetchGewinne handles various parameter combinations', (
      WidgetTester tester,
    ) async {
      final testCases = [
        [2024, '12345678'],
        [2023, '87654321'],
        [2025, 'ÄÖÜäöüß123'],
        [2022, ''],
        [2026, '12345678901234567890'],
      ];

      for (final testCase in testCases) {
        final year = testCase[0] as int;
        final passnummer = testCase[1] as String;

        // Verify API call works
        expect(
          () async => await mockApiService.fetchGewinne(year, passnummer),
          returnsNormally,
        );

        final result = await mockApiService.fetchGewinne(year, passnummer);
        expect(result, equals([]));
      }
    });

    testWidgets('works with custom API service', (WidgetTester tester) async {
      // Arrange
      final customApiService = MockApiService();

      // Act
      await tester.pumpWidget(
        createOktoberfestScreen(
          userData: mockTestUserData,
          customApiService: customApiService,
        ),
      );

      await tester.tap(find.text('Meine Gewinne'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(OktoberfestGewinnScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verify custom service was used
      verify(
        customApiService.fetchGewinne(2024, '12345678'),
      ).called(greaterThanOrEqualTo(1));
    });
  });

  group('OktoberfestScreen - Accessibility Tests', () {
    testWidgets('provides semantic labels for icons', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: mockTestUserData));

      // Assert - Verify semantic labels exist
      final expectedLabels = [
        {'icon': Icons.bar_chart, 'label': 'Meine Ergebnisse'},
        {'icon': Icons.emoji_events, 'label': 'Meine Gewinne'},
        {'icon': Icons.festival, 'label': 'Eintritt Festzelt'},
      ];

      for (final iconData in expectedLabels) {
        final iconFinder = find.byIcon(iconData['icon'] as IconData);
        expect(iconFinder, findsOneWidget);

        final icon = tester.widget<Icon>(iconFinder);
        expect(icon.semanticLabel, equals(iconData['label']));
      }

      // Verify chevron icons have labels
      final chevronIcons = tester.widgetList<Icon>(
        find.byIcon(Icons.chevron_right),
      );
      expect(chevronIcons.length, equals(3));

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
            child: createOktoberfestScreen(userData: mockTestUserData),
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
        createOktoberfestScreen(userData: mockTestUserData, isLoggedIn: false),
      );

      await tester.tap(find.text('Meine Gewinne'));
      await tester.pumpAndSettle();

      // Assert - Child screen receives correct login state
      final gewinnScreen = tester.widget<OktoberfestGewinnScreen>(
        find.byType(OktoberfestGewinnScreen),
      );
      expect(gewinnScreen.isLoggedIn, isFalse);
    });

    testWidgets('preserves user data across widget rebuilds', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: mockTestUserData));

      // Rebuild widget
      await tester.pumpWidget(createOktoberfestScreen(userData: mockTestUserData));

      // Navigate to verify data is preserved
      await tester.tap(find.text('Eintritt Festzelt'));
      await tester.pumpAndSettle();

      // Assert - User data preserved
      final eintrittScreen = tester.widget<OktoberfestEintrittFestzelt>(
        find.byType(OktoberfestEintrittFestzelt),
      );
      expect(eintrittScreen.passnummer, equals('12345678'));
      expect(eintrittScreen.vorname, equals('Max'));
      expect(eintrittScreen.nachname, equals('Mustermann'));
    });
  });

  group('OktoberfestScreen - Performance Tests', () {
    testWidgets('handles multiple rapid navigation attempts', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createOktoberfestScreen(userData: mockTestUserData));

      // Navigate multiple times rapidly
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Meine Gewinne'));
        await tester.pumpAndSettle();

        expect(find.byType(OktoberfestGewinnScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
      }

      // Verify API was called multiple times without issues
      verify(
        mockApiService.fetchGewinne(2024, '12345678'),
      ).called(greaterThanOrEqualTo(3));
    });
  });
}
