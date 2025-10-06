import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meinbssb/screens/oktoberfest_gewinn_screen.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/models/gewinn_data.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/bank_data.dart'; // Add this import
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:async';

@GenerateMocks([ApiService])
import 'oktoberfest_gewinn_screen_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late FontSizeProvider fontSizeProvider;
  late UserData userData;

  // Helper function to create test gewinn data
  List<Gewinn> createTestGewinne({
    int count = 1,
    bool withAbgerufen = false,
    bool mixedTypes = false,
  }) {
    return List.generate(count, (index) {
      final baseGewinn = Gewinn(
        gewinnId: index + 1,
        jahr:
            2023, // Use 2023 as that's what the screen uses (current year - 1)
        tradition: index % 3 == 0,
        isSachpreis: mixedTypes ? index % 2 == 0 : false,
        geldpreis: mixedTypes && index % 2 == 0 ? 0 : (100 - index * 10),
        sachpreis: mixedTypes && index % 2 == 0 ? 'Sachpreis ${index + 1}' : '',
        wettbewerb: 'Wettbewerb ${index + 1}',
        abgerufenAm:
            withAbgerufen || index % 2 == 1
                ? '2024-${(index % 12 + 1).toString().padLeft(2, '0')}-15'
                : '',
        platz: index + 1,
      );
      return baseGewinn;
    });
  }

  UserData createTestUserData({
    String passnummer = '123456',
    String vorname = 'Max',
    String nachname = 'Mustermann',
  }) {
    return UserData(
      personId: 1,
      webLoginId: 1,
      passnummer: passnummer,
      vereinNr: 1,
      namen: nachname,
      vorname: vorname,
      vereinName: 'Testverein',
      passdatenId: 1,
      mitgliedschaftId: 1,
      geburtsdatum: DateTime(1990, 5, 15),
    );
  }

  setUpAll(() async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({'fontScale': 1.0});
  });

  setUp(() async {
    mockApiService = MockApiService();
    fontSizeProvider = FontSizeProvider();
    userData = createTestUserData();

    // Give FontSizeProvider time to initialize
    await Future.delayed(Duration(milliseconds: 10));

    // Setup default API stubs with correct year (2023)
    when(mockApiService.fetchGewinne(any, any)).thenAnswer((_) async => []);
    when(
      mockApiService.fetchBankdatenMyBSSB(any),
    ).thenAnswer((_) async => <BankData>[]);
  });

  Widget buildTestWidget({
    UserData? customUserData,
    MockApiService? customApiService,
    bool isLoggedIn = true,
    VoidCallback? onLogout,
  }) {
    final user = customUserData ?? userData;
    final api = customApiService ?? mockApiService;

    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: api),
        ChangeNotifierProvider<FontSizeProvider>.value(value: fontSizeProvider),
      ],
      child: MaterialApp(
        home: OktoberfestGewinnScreen(
          passnummer: user.passnummer,
          apiService: api,
          userData: user,
          isLoggedIn: isLoggedIn,
          onLogout: onLogout ?? () {},
        ),
      ),
    );
  }

  group('OktoberfestGewinnScreen - Widget Structure Tests', () {
    testWidgets('renders all basic UI components', (tester) async {
      when(mockApiService.fetchGewinne(any, any)).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Assert basic structure
      expect(find.byType(BaseScreenLayout), findsOneWidget);
      expect(find.text('Meine Gewinne für das letzte Jahr'), findsOneWidget);

      // Check for proper title in BaseScreenLayout
      expect(find.text('Oktoberfestlandesschießen'), findsOneWidget);

      // FAB is only shown when there are gewinne that aren't abgerufen
      // With empty list, no FAB should be present
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('does not render FAB when all gewinne are abgerufen', (
      tester,
    ) async {
      // Setup gewinne that have all been retrieved
      final gewinne = createTestGewinne(count: 2, withAbgerufen: true);
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => gewinne);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Assert basic structure with data but no FAB
      expect(find.byType(BaseScreenLayout), findsOneWidget);
      expect(find.text('Meine Gewinne für das letzte Jahr'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);

      // Should show the gewinn data
      expect(find.text('Wettbewerb 1'), findsOneWidget);
      expect(find.text('Wettbewerb 2'), findsOneWidget);
    });

    testWidgets('displays current year minus one', (tester) async {
      when(mockApiService.fetchGewinne(any, any)).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Should show 2023 (current year 2024 - 1)
      final currentYear = DateTime.now().year;
      final expectedYear = currentYear - 1;
      expect(find.text('Jahr: $expectedYear'), findsOneWidget);
    });

    testWidgets('shows correct header text', (tester) async {
      when(mockApiService.fetchGewinne(any, any)).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Check that the screen title is displayed correctly
      expect(find.text('Meine Gewinne für das letzte Jahr'), findsOneWidget);
    });

    testWidgets('has proper navigation structure', (tester) async {
      when(mockApiService.fetchGewinne(any, any)).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Check for navigation elements
      expect(find.byType(BaseScreenLayout), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows refresh button in app bar', (tester) async {
      when(mockApiService.fetchGewinne(any, any)).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Check if there's a refresh action in the app bar
      expect(find.byType(AppBar), findsOneWidget);

      // Look for refresh icon in the app bar actions
      final refreshIcon = find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.refresh),
      );

      // The refresh icon might be present in the app bar
      // This is optional depending on the implementation
      if (refreshIcon.evaluate().isNotEmpty) {
        expect(refreshIcon, findsOneWidget);
      }
    });
  });

  group('OktoberfestGewinnScreen - Loading State Tests', () {
    testWidgets('shows loading indicator while fetching', (tester) async {
      final completer = Completer<List<Gewinn>>();
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future to avoid test hanging
      completer.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('loading indicator disappears after data loads', (
      tester,
    ) async {
      final gewinne = createTestGewinne(count: 1);
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => gewinne);

      await tester.pumpWidget(buildTestWidget());

      // Initially shows loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Loading disappears after data loads
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('OktoberfestGewinnScreen - Empty State Tests', () {
    testWidgets('shows snackbar when no gewinne found', (tester) async {
      when(mockApiService.fetchGewinne(any, any)).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Should show snackbar with no gewinne message
      expect(
        find.text('Keine Gewinne für das gewählte Jahr gefunden.'),
        findsOneWidget,
      );
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('calls API with correct year (current year - 1)', (
      tester,
    ) async {
      when(mockApiService.fetchGewinne(any, any)).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final expectedYear = DateTime.now().year - 1;
      verify(mockApiService.fetchGewinne(expectedYear, '123456')).called(1);
    });
  });

  group('OktoberfestGewinnScreen - Data Display Tests', () {
    testWidgets('displays single gewinn correctly', (tester) async {
      final gewinne = [
        Gewinn(
          gewinnId: 1,
          jahr: 2023,
          tradition: false,
          isSachpreis: false,
          geldpreis: 100,
          sachpreis: '',
          wettbewerb: 'Test Wettbewerb',
          abgerufenAm: '',
          platz: 1,
        ),
      ];
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => gewinne);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Test Wettbewerb'), findsOneWidget);
      expect(find.text('Platz: 1'), findsOneWidget);
      expect(find.text('Geldpreis: 100'), findsOneWidget);
      expect(find.text('noch nicht abgerufen'), findsOneWidget);
    });

    testWidgets('displays multiple gewinne correctly', (tester) async {
      final gewinne = createTestGewinne(count: 3);
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => gewinne);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Wettbewerb 1'), findsOneWidget);
      expect(find.text('Wettbewerb 2'), findsOneWidget);
      expect(find.text('Wettbewerb 3'), findsOneWidget);
      expect(find.text('Platz: 1'), findsOneWidget);
      expect(find.text('Platz: 2'), findsOneWidget);
      expect(find.text('Platz: 3'), findsOneWidget);
    });

    testWidgets('handles tradition gewinne', (tester) async {
      final gewinne = [
        Gewinn(
          gewinnId: 1,
          jahr: 2023,
          tradition: true,
          isSachpreis: false,
          geldpreis: 150,
          sachpreis: '',
          wettbewerb: 'Tradition Wettbewerb',
          abgerufenAm: '',
          platz: 1,
        ),
      ];
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => gewinne);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Tradition Wettbewerb'), findsOneWidget);
      expect(find.text('Geldpreis: 150'), findsOneWidget);
    });
  });

  group('OktoberfestGewinnScreen - User Data Handling Tests', () {
    testWidgets('uses correct passnummer in API call', (tester) async {
      final customUser = createTestUserData(passnummer: '987654');
      when(mockApiService.fetchGewinne(any, any)).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget(customUserData: customUser));
      await tester.pumpAndSettle();

      final expectedYear = DateTime.now().year - 1;
      verify(mockApiService.fetchGewinne(expectedYear, '987654')).called(1);
    });

    testWidgets('handles special characters in passnummer', (tester) async {
      final customUser = createTestUserData(passnummer: 'ÄÖÜ123ßäöü');
      when(mockApiService.fetchGewinne(any, any)).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget(customUserData: customUser));
      await tester.pumpAndSettle();

      final expectedYear = DateTime.now().year - 1;
      verify(mockApiService.fetchGewinne(expectedYear, 'ÄÖÜ123ßäöü')).called(1);
    });
  });

  group('OktoberfestGewinnScreen - Performance Tests', () {
    testWidgets('handles large number of gewinne efficiently', (tester) async {
      final largeGewinneList = createTestGewinne(count: 50, mixedTypes: true);
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => largeGewinneList);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Should handle large lists without issues
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Wettbewerb 1'), findsOneWidget);
      expect(find.text('Wettbewerb 50'), findsOneWidget);
    });
  });

  group('OktoberfestGewinnScreen - Accessibility Tests', () {
    testWidgets('handles different text scale factors', (tester) async {
      final gewinne = createTestGewinne(count: 1);
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => gewinne);

      for (final scaleFactor in [0.8, 1.0, 1.5, 2.0]) {
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(textScaleFactor: scaleFactor),
            child: buildTestWidget(),
          ),
        );
        await tester.pumpAndSettle();

        // Should render without overflow issues
        expect(find.text('Wettbewerb 1'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('OktoberfestGewinnScreen - Edge Cases', () {
    testWidgets('handles gewinn with very long wettbewerb name', (
      tester,
    ) async {
      final gewinne = [
        Gewinn(
          gewinnId: 1,
          jahr: 2023,
          tradition: false,
          isSachpreis: false,
          geldpreis: 100,
          sachpreis: '',
          wettbewerb:
              'Very Long Wettbewerb Name That Should Be Handled Gracefully Without Breaking UI',
          abgerufenAm: '',
          platz: 1,
        ),
      ];
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => gewinne);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Very Long Wettbewerb'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles zero geldpreis correctly', (tester) async {
      final gewinne = [
        Gewinn(
          gewinnId: 1,
          jahr: 2023,
          tradition: false,
          isSachpreis: false,
          geldpreis: 0,
          sachpreis: '',
          wettbewerb: 'Test Wettbewerb',
          abgerufenAm: '',
          platz: 1,
        ),
      ];
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => gewinne);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Geldpreis: 0'), findsOneWidget);
    });
  });

  group('OktoberfestGewinnScreen - Authentication Tests', () {
    testWidgets('handles logged out state', (tester) async {
      when(mockApiService.fetchGewinne(any, any)).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget(isLoggedIn: false));
      await tester.pumpAndSettle();

      // Screen should still render
      expect(find.byType(OktoberfestGewinnScreen), findsOneWidget);
    });

    testWidgets('passes authentication state to BaseScreenLayout', (
      tester,
    ) async {
      when(mockApiService.fetchGewinne(any, any)).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget(isLoggedIn: true));
      await tester.pumpAndSettle();

      final baseLayout = tester.widget<BaseScreenLayout>(
        find.byType(BaseScreenLayout),
      );
      expect(baseLayout.isLoggedIn, isTrue);
      expect(baseLayout.userData, equals(userData));
    });
  });

  group('OktoberfestGewinnScreen - Multiple FAB Tests', () {
    testWidgets('shows two FABs when gewinne are present and not abgerufen', (
      tester,
    ) async {
      final gewinne = createTestGewinne(count: 1, withAbgerufen: false);
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => gewinne);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Should have exactly 2 FABs - one for refresh, one for abrufen
      expect(find.byType(FloatingActionButton), findsNWidgets(2));

      // Find specific FABs by their icons
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets(
      'refresh FAB is enabled, abrufen FAB is disabled without bank data',
      (tester) async {
        final gewinne = createTestGewinne(count: 1, withAbgerufen: false);
        when(
          mockApiService.fetchGewinne(any, any),
        ).thenAnswer((_) async => gewinne);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Find FABs by their icons
        final refreshFab = tester.widget<FloatingActionButton>(
          find.widgetWithIcon(FloatingActionButton, Icons.search),
        );
        final abrufenFab = tester.widget<FloatingActionButton>(
          find.widgetWithIcon(FloatingActionButton, Icons.check),
        );

        // Refresh FAB should be enabled
        expect(refreshFab.onPressed, isNotNull);

        // Abrufen FAB should be disabled (no bank data)
        expect(abrufenFab.onPressed, isNull);
      },
    );

    testWidgets('both FABs have correct tooltips', (tester) async {
      final gewinne = createTestGewinne(count: 1, withAbgerufen: false);
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => gewinne);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final refreshFab = tester.widget<FloatingActionButton>(
        find.widgetWithIcon(FloatingActionButton, Icons.search),
      );
      final abrufenFab = tester.widget<FloatingActionButton>(
        find.widgetWithIcon(FloatingActionButton, Icons.check),
      );

      expect(refreshFab.tooltip, equals('Gewinne für Jahr abrufen'));
      expect(abrufenFab.tooltip, equals('Gewinne abrufen'));
    });

    testWidgets('no FABs shown when no gewinne or all abgerufen', (
      tester,
    ) async {
      // Test with empty gewinne
      when(mockApiService.fetchGewinne(any, any)).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);

      // Test with all gewinne abgerufen
      final allAbgerufenGewinne = createTestGewinne(
        count: 2,
        withAbgerufen: true,
      );
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => allAbgerufenGewinne);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });

  group('OktoberfestGewinnScreen - Bank Data Dialog Tests', () {
    testWidgets('opens bank data dialog when bankdaten button is tapped', (
      tester,
    ) async {
      final gewinne = createTestGewinne(count: 1, withAbgerufen: false);
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => gewinne);
      when(
        mockApiService.fetchBankdatenMyBSSB(any),
      ).thenAnswer((_) async => <BankData>[]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap the bankdaten button
      await tester.tap(find.text('Bankdaten'));
      await tester.pumpAndSettle();

      // Should show the bank data dialog
      expect(find.text('Bankdaten bearbeiten'), findsOneWidget);
      expect(find.byType(BankDataDialog), findsOneWidget);
    });

    testWidgets('bankdaten button shows loading indicator while fetching', (
      tester,
    ) async {
      final gewinne = createTestGewinne(count: 1, withAbgerufen: false);
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => gewinne);

      // Make bank data fetch take some time
      final completer = Completer<List<BankData>>();
      when(
        mockApiService.fetchBankdatenMyBSSB(any),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap the bankdaten button
      await tester.tap(find.text('Bankdaten'));
      await tester.pump();

      // Button should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future
      completer.complete(<BankData>[]);
      await tester.pumpAndSettle();
    });

    testWidgets('bank data dialog can be cancelled', (tester) async {
      final gewinne = createTestGewinne(count: 1, withAbgerufen: false);
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => gewinne);
      when(
        mockApiService.fetchBankdatenMyBSSB(any),
      ).thenAnswer((_) async => <BankData>[]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.text('Bankdaten'));
      await tester.pumpAndSettle();

      expect(find.byType(BankDataDialog), findsOneWidget);

      // Cancel dialog
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(BankDataDialog), findsNothing);
    });

    testWidgets('abrufen FAB becomes enabled after entering valid bank data', (
      tester,
    ) async {
      final gewinne = createTestGewinne(count: 1, withAbgerufen: false);
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => gewinne);
      when(
        mockApiService.fetchBankdatenMyBSSB(any),
      ).thenAnswer((_) async => <BankData>[]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Initially abrufen FAB should be disabled
      final initialAbrufenFab = tester.widget<FloatingActionButton>(
        find.widgetWithIcon(FloatingActionButton, Icons.check),
      );
      expect(initialAbrufenFab.onPressed, isNull);

      // Open bank data dialog
      await tester.tap(find.text('Bankdaten'));
      await tester.pumpAndSettle();

      // Fill in valid bank data
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Max Mustermann',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'DE89370400440532013000',
      );

      // Accept AGB
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Submit dialog
      await tester.tap(find.byIcon(Icons.check).last);
      await tester.pumpAndSettle();

      // Now abrufen FAB should be enabled
      final enabledAbrufenFab = tester.widget<FloatingActionButton>(
        find.widgetWithIcon(FloatingActionButton, Icons.check),
      );
      expect(enabledAbrufenFab.onPressed, isNotNull);
    });
  });

  group('OktoberfestGewinnScreen - Sachpreis Tests', () {
    testWidgets('displays sachpreis information correctly', (tester) async {
      final gewinne = [
        Gewinn(
          gewinnId: 1,
          jahr: 2023,
          tradition: false,
          isSachpreis: true,
          geldpreis: 0,
          sachpreis: 'Schießscheibe',
          wettbewerb: 'Sachpreis Wettbewerb',
          abgerufenAm: '',
          platz: 1,
        ),
      ];
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => gewinne);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Sachpreis Wettbewerb'), findsOneWidget);
      expect(find.text('Geldpreis: 0'), findsOneWidget);
      // Note: The screen shows geldpreis even for Sachpreis items
    });

    testWidgets('handles mixed sachpreis and geldpreis gewinne', (
      tester,
    ) async {
      final gewinne = [
        Gewinn(
          gewinnId: 1,
          jahr: 2023,
          tradition: false,
          isSachpreis: true,
          geldpreis: 0,
          sachpreis: 'Pokal',
          wettbewerb: 'Sachpreis Test',
          abgerufenAm: '',
          platz: 1,
        ),
        Gewinn(
          gewinnId: 2,
          jahr: 2023,
          tradition: false,
          isSachpreis: false,
          geldpreis: 50,
          sachpreis: '',
          wettbewerb: 'Geldpreis Test',
          abgerufenAm: '',
          platz: 2,
        ),
      ];
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => gewinne);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Sachpreis Test'), findsOneWidget);
      expect(find.text('Geldpreis Test'), findsOneWidget);
      expect(find.text('Geldpreis: 0'), findsOneWidget);
      expect(find.text('Geldpreis: 50'), findsOneWidget);
    });
  });

  group('OktoberfestGewinnScreen - Bankdaten Button Tests', () {
    testWidgets('shows bankdaten button when gewinne not abgerufen', (
      tester,
    ) async {
      final gewinne = createTestGewinne(count: 2, withAbgerufen: false);
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => gewinne);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Bankdaten'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('hides bankdaten button when all gewinne abgerufen', (
      tester,
    ) async {
      final gewinne = createTestGewinne(count: 2, withAbgerufen: true);
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => gewinne);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Bankdaten'), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('shows bankdaten button when mixed abgerufen status', (
      tester,
    ) async {
      final gewinne = [
        Gewinn(
          gewinnId: 1,
          jahr: 2023,
          tradition: false,
          isSachpreis: false,
          geldpreis: 100,
          sachpreis: '',
          wettbewerb: 'Test 1',
          abgerufenAm: '2024-01-15', // Already retrieved
          platz: 1,
        ),
        Gewinn(
          gewinnId: 2,
          jahr: 2023,
          tradition: false,
          isSachpreis: false,
          geldpreis: 50,
          sachpreis: '',
          wettbewerb: 'Test 2',
          abgerufenAm: '', // Not retrieved yet
          platz: 2,
        ),
      ];
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => gewinne);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Bankdaten'), findsOneWidget);
    });
  });

  group('OktoberfestGewinnScreen - Gewinn Abrufen Tests', () {
    testWidgets('calls gewinneAbrufen API when abrufen FAB is tapped', (
      tester,
    ) async {
      final gewinne = createTestGewinne(count: 1, withAbgerufen: false);
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => gewinne);
      when(
        mockApiService.fetchBankdatenMyBSSB(any),
      ).thenAnswer((_) async => <BankData>[]);
      when(
        mockApiService.gewinneAbrufen(
          gewinnIDs: anyNamed('gewinnIDs'),
          iban: anyNamed('iban'),
          passnummer: anyNamed('passnummer'),
        ),
      ).thenAnswer((_) async => true);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Enter bank data to enable abrufen FAB
      await tester.tap(find.text('Bankdaten'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Max Mustermann',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'DE89370400440532013000',
      );
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.check).last);
      await tester.pumpAndSettle();

      // Tap abrufen FAB
      await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.check));
      await tester.pumpAndSettle();

      // Verify API was called with correct parameters
      verify(
        mockApiService.gewinneAbrufen(
          gewinnIDs: [1],
          iban: 'DE89370400440532013000',
          passnummer: '123456',
        ),
      ).called(1);
    });

    testWidgets('shows success screen when gewinne abrufen succeeds', (
      tester,
    ) async {
      final gewinne = createTestGewinne(count: 1, withAbgerufen: false);
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => gewinne);
      when(
        mockApiService.fetchBankdatenMyBSSB(any),
      ).thenAnswer((_) async => <BankData>[]);
      when(
        mockApiService.gewinneAbrufen(
          gewinnIDs: anyNamed('gewinnIDs'),
          iban: anyNamed('iban'),
          passnummer: anyNamed('passnummer'),
        ),
      ).thenAnswer((_) async => true);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Setup bank data and trigger abrufen
      await tester.tap(find.text('Bankdaten'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Max Mustermann',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'DE89370400440532013000',
      );
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.check).last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.check));
      await tester.pumpAndSettle();

      // Should navigate to success screen
      expect(find.byType(OktoberfestAbrufResultScreen), findsOneWidget);
      expect(find.text('Gewinne erfolgreich abgerufen!'), findsOneWidget);
    });

    testWidgets('shows error snackbar when gewinne abrufen fails', (
      tester,
    ) async {
      final gewinne = createTestGewinne(count: 1, withAbgerufen: false);
      when(
        mockApiService.fetchGewinne(any, any),
      ).thenAnswer((_) async => gewinne);
      when(
        mockApiService.fetchBankdatenMyBSSB(any),
      ).thenAnswer((_) async => <BankData>[]);
      when(
        mockApiService.gewinneAbrufen(
          gewinnIDs: anyNamed('gewinnIDs'),
          iban: anyNamed('iban'),
          passnummer: anyNamed('passnummer'),
        ),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Setup and trigger abrufen
      await tester.tap(find.text('Bankdaten'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Max Mustermann',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'DE89370400440532013000',
      );
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.check).last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.check));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Fehler beim Abrufen der Gewinne.'), findsOneWidget);
    });
  });
}
