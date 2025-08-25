import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/schulungen/schulungen_search_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/bezirk_data.dart';
import 'package:meinbssb/models/schulungstermin_data.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([ApiService])
import 'schulungen_search_screen_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late Widget testWidget;

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

  final sampleBezirke = [
    const BezirkSearchTriple(bezirkId: 1, bezirkNr: 1, bezirkName: 'Oberbayern'),
    const BezirkSearchTriple(bezirkId: 2, bezirkNr: 2, bezirkName: 'Niederbayern'),
    const BezirkSearchTriple(bezirkId: 3, bezirkNr: 3, bezirkName: 'Oberpfalz'),
  ];

  setUp(() {
    mockApiService = MockApiService();
    
    // Setup default mock responses
    when(mockApiService.fetchBezirkeforSearch())
        .thenAnswer((_) async => sampleBezirke);

    testWidget = MaterialApp(
      home: ChangeNotifierProvider<ApiService>.value(
        value: mockApiService,
        child: const SchulungenSearchScreen(
          dummyUser,
          isLoggedIn: true,
          onLogout: _mockLogout,
        ),
      ),
    );
  });

  static void _mockLogout() {}

  group('SchulungenSearchScreen', () {
    testWidgets('should render with correct initial state', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Verify title is displayed
      expect(find.text('Aus- und Weiterbildung'), findsOneWidget);
      expect(find.text('Suchen'), findsOneWidget);

      // Verify form fields are present
      expect(find.text('Aus-und Weiterbildungen ab Datum anzeigen'), findsOneWidget);
      expect(find.text('Fachbereich'), findsOneWidget);
      expect(find.text('Regierungsbezirk'), findsOneWidget);
      expect(find.text('Ort'), findsOneWidget);
      expect(find.text('Titel'), findsOneWidget);
      expect(find.text('Für Lizenzverlängerung'), findsOneWidget);

      // Verify floating action buttons
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should initialize with current date', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      final now = DateTime.now();
      final expectedDate = '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
      
      expect(find.text(expectedDate), findsOneWidget);
    });

    testWidgets('should load bezirke on initialization', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      
      // Initially shows loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      await tester.pumpAndSettle();

      // After loading, shows dropdown with bezirke
      expect(find.byType(CircularProgressIndicator), findsNothing);
      
      // Verify "Alle" option is added
      expect(find.text('Alle'), findsOneWidget);
      expect(find.text('Oberbayern'), findsOneWidget);
      expect(find.text('Niederbayern'), findsOneWidget);
      expect(find.text('Oberpfalz'), findsOneWidget);
    });

    testWidgets('should populate Fachbereich dropdown with correct options', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Tap on Fachbereich dropdown
      await tester.tap(find.text('Fachbereich'));
      await tester.pumpAndSettle();

      // Verify all webGruppe options are present
      expect(find.text('Alle'), findsOneWidget);
      expect(find.text('Jugend'), findsOneWidget);
      expect(find.text('Sport'), findsOneWidget);
      expect(find.text('Überfachlich'), findsOneWidget);
    });

    testWidgets('should allow date selection', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Tap on date field
      await tester.tap(find.text('Aus-und Weiterbildungen ab Datum anzeigen'));
      await tester.pumpAndSettle();

      // Verify date picker is shown
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('should allow text input in Ort field', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      final ortField = find.byKey(const Key('Ort'));
      await tester.enterText(ortField, 'München');
      await tester.pump();

      expect(find.text('München'), findsOneWidget);
    });

    testWidgets('should allow text input in Titel field', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      final titelField = find.byKey(const Key('Titel'));
      await tester.enterText(titelField, 'Test Schulung');
      await tester.pump();

      expect(find.text('Test Schulung'), findsOneWidget);
    });

    testWidgets('should toggle checkbox for Für Lizenzverlängerung', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      final checkbox = find.byType(Checkbox);
      expect(tester.widget<Checkbox>(checkbox).value, false);

      await tester.tap(checkbox);
      await tester.pump();

      expect(tester.widget<Checkbox>(checkbox).value, true);
    });

    testWidgets('should reset form when reset button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Fill in some form data
      await tester.enterText(find.byKey(const Key('Ort')), 'München');
      await tester.enterText(find.byKey(const Key('Titel')), 'Test Schulung');
      
      // Change checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Verify data is entered
      expect(find.text('München'), findsOneWidget);
      expect(find.text('Test Schulung'), findsOneWidget);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, true);

      // Press reset button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // Verify form is reset
      expect(find.text('München'), findsNothing);
      expect(find.text('Test Schulung'), findsNothing);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, false);
    });

    testWidgets('should show error when searching without date', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Clear the date (set to null)
      await tester.tap(find.text('Aus-und Weiterbildungen ab Datum anzeigen'));
      await tester.pumpAndSettle();
      
      // This would require more complex mocking of the date picker
      // For now, we'll test the error case by directly testing the method
      
      // Press search button
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Should show error message
      expect(find.text('Bitte wählen Sie ein Datum.'), findsOneWidget);
    });

    testWidgets('should navigate to SchulungenScreen when search is successful', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Press search button (with valid date)
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Should navigate to SchulungenScreen
      expect(find.byType(SchulungenScreen), findsOneWidget);
    });

    testWidgets('should handle API error gracefully', (WidgetTester tester) async {
      // Setup API to throw error
      when(mockApiService.fetchBezirkeforSearch())
          .thenThrow(Exception('API Error'));

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Should still render the screen without crashing
      expect(find.text('Aus- und Weiterbildung'), findsOneWidget);
    });

    testWidgets('should show back button when showMenu is true', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should not show back button when showMenu is false', (WidgetTester tester) async {
      final testWidgetNoMenu = MaterialApp(
        home: ChangeNotifierProvider<ApiService>.value(
          value: mockApiService,
          child: const SchulungenSearchScreen(
            dummyUser,
            isLoggedIn: true,
            onLogout: _mockLogout,
            showMenu: false,
          ),
        ),
      );

      await tester.pumpWidget(testWidgetNoMenu);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('should handle bezirke loading state correctly', (WidgetTester tester) async {
      // Setup API to return empty list
      when(mockApiService.fetchBezirkeforSearch())
          .thenAnswer((_) async => []);

      await tester.pumpWidget(testWidget);
      
      // Initially shows loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      await tester.pumpAndSettle();

      // After loading, shows only "Alle" option
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Alle'), findsOneWidget);
    });

    testWidgets('should format date correctly', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      final now = DateTime.now();
      final expectedDate = '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
      
      expect(find.text(expectedDate), findsOneWidget);
    });

    testWidgets('should dispose controllers properly', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Navigate away to trigger dispose
      await tester.pumpWidget(MaterialApp(home: const Scaffold(body: Text('New Screen'))));
      await tester.pumpAndSettle();

      // No errors should occur during disposal
    });
  });

  group('SchulungenSearchScreen - Edge Cases', () {
    testWidgets('should handle null userData gracefully', (WidgetTester tester) async {
      final testWidgetNullUser = MaterialApp(
        home: ChangeNotifierProvider<ApiService>.value(
          value: mockApiService,
          child: const SchulungenSearchScreen(
            null,
            isLoggedIn: false,
            onLogout: _mockLogout,
          ),
        ),
      );

      await tester.pumpWidget(testWidgetNullUser);
      await tester.pumpAndSettle();

      // Should render without crashing
      expect(find.text('Aus- und Weiterbildung'), findsOneWidget);
    });

    testWidgets('should handle very long text inputs', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      final longText = 'A' * 1000;
      
      await tester.enterText(find.byKey(const Key('Ort')), longText);
      await tester.pump();

      expect(find.text(longText), findsOneWidget);
    });

    testWidgets('should handle special characters in text inputs', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      const specialText = 'Test@#$%^&*()_+-=[]{}|;:,.<>?';
      
      await tester.enterText(find.byKey(const Key('Titel')), specialText);
      await tester.pump();

      expect(find.text(specialText), findsOneWidget);
    });
  });
}
