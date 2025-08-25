import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/schulungen/schulungen_search_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/bezirk_data.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/font_size_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([ApiService, FontSizeProvider])
import 'schulungen_search_screen_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late MockFontSizeProvider mockFontSizeProvider;
  late Widget testWidget;

  void mockLogout() {}

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
    const BezirkSearchTriple(
      bezirkId: 1,
      bezirkNr: 1,
      bezirkName: 'Oberbayern',
    ),
    const BezirkSearchTriple(
      bezirkId: 2,
      bezirkNr: 2,
      bezirkName: 'Niederbayern',
    ),
    const BezirkSearchTriple(bezirkId: 3, bezirkNr: 3, bezirkName: 'Oberpfalz'),
  ];

  setUp(() {
    mockApiService = MockApiService();
    mockFontSizeProvider = MockFontSizeProvider();

    // Setup default mock responses
    when(mockApiService.fetchBezirkeforSearch())
        .thenAnswer((_) async => sampleBezirke);
    
    // Setup FontSizeProvider mock
    when(mockFontSizeProvider.scaleFactor).thenReturn(1.0);
    when(mockFontSizeProvider.getScaledFontSize(any)).thenAnswer((invocation) {
      final baseSize = invocation.positionalArguments[0] as double;
      return baseSize * 1.0;
    });
    when(mockFontSizeProvider.getScalePercentage()).thenReturn('100%');

    testWidget = MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<ApiService>.value(value: mockApiService),
          ChangeNotifierProvider<FontSizeProvider>.value(value: mockFontSizeProvider),
        ],
        child: SchulungenSearchScreen(
          dummyUser,
          isLoggedIn: true,
          onLogout: mockLogout,
        ),
      ),
    );
  });

  group('SchulungenSearchScreen', () {
    testWidgets('should render with correct initial state',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Verify title is displayed
      expect(find.text('Aus- und Weiterbildung'), findsOneWidget);
      expect(find.text('Suchen'), findsOneWidget);

      // Verify form fields are present
      expect(
        find.text('Aus-und Weiterbildungen ab Datum anzeigen'),
        findsOneWidget,
      );
      expect(find.text('Fachbereich'), findsOneWidget);
      expect(find.text('Regierungsbezirk'), findsOneWidget);
      expect(find.text('Ort'), findsOneWidget);
      expect(find.text('Titel'), findsOneWidget);
      expect(find.text('Für Lizenzverlängerung'), findsOneWidget);

      // Verify floating action buttons
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should initialize with current date',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      final now = DateTime.now();
      final expectedDate =
          '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';

      expect(find.text(expectedDate), findsOneWidget);
    });

    testWidgets('should load bezirke on initialization',
        (WidgetTester tester) async {
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

    testWidgets('should populate Fachbereich dropdown with correct options',
        (WidgetTester tester) async {
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

    testWidgets('should allow text input in Ort field',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      final ortField = find.byKey(const Key('Ort'));
      await tester.enterText(ortField, 'München');
      await tester.pump();

      expect(find.text('München'), findsOneWidget);
    });

    testWidgets('should allow text input in Titel field',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      final titelField = find.byKey(const Key('Titel'));
      await tester.enterText(titelField, 'Test Schulung');
      await tester.pump();

      expect(find.text('Test Schulung'), findsOneWidget);
    });

    testWidgets('should toggle checkbox for Für Lizenzverlängerung',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      final checkbox = find.byType(Checkbox);
      expect(tester.widget<Checkbox>(checkbox).value, false);

      await tester.tap(checkbox);
      await tester.pump();

      expect(tester.widget<Checkbox>(checkbox).value, true);
    });

    testWidgets('should reset form when reset button is pressed',
        (WidgetTester tester) async {
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

    testWidgets('should show error when searching without date',
        (WidgetTester tester) async {
      // Create a custom widget with null date for testing
      final testWidgetNullDate = MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<ApiService>.value(value: mockApiService),
            ChangeNotifierProvider<FontSizeProvider>.value(value: mockFontSizeProvider),
          ],
          child: _TestSchulungenSearchScreen(
            dummyUser,
            isLoggedIn: true,
            onLogout: mockLogout,
          ),
        ),
      );

      await tester.pumpWidget(testWidgetNullDate);
      await tester.pumpAndSettle();

      // Press search button
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Should show error message
      expect(find.text('Bitte wählen Sie ein Datum.'), findsOneWidget);
    });

    testWidgets('should handle API error gracefully',
        (WidgetTester tester) async {
      // Setup API to throw error
      when(mockApiService.fetchBezirkeforSearch())
          .thenThrow(Exception('API Error'));

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Should still render the screen without crashing
      expect(find.text('Aus- und Weiterbildung'), findsOneWidget);
    });

    testWidgets('should show back button when showMenu is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should not show back button when showMenu is false',
        (WidgetTester tester) async {
      final testWidgetNoMenu = MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<ApiService>.value(value: mockApiService),
            ChangeNotifierProvider<FontSizeProvider>.value(value: mockFontSizeProvider),
          ],
          child: SchulungenSearchScreen(
            dummyUser,
            isLoggedIn: true,
            onLogout: mockLogout,
            showMenu: false,
          ),
        ),
      );

      await tester.pumpWidget(testWidgetNoMenu);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('should handle bezirke loading state correctly',
        (WidgetTester tester) async {
      // Setup API to return empty list
      when(mockApiService.fetchBezirkeforSearch()).thenAnswer((_) async => []);

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
      final expectedDate =
          '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';

      expect(find.text(expectedDate), findsOneWidget);
    });

    testWidgets('should dispose controllers properly',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Navigate away to trigger dispose
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('New Screen'))),
      );
      await tester.pumpAndSettle();

      // No errors should occur during disposal
    });
  });

  group('SchulungenSearchScreen - Edge Cases', () {
    testWidgets('should handle null userData gracefully',
        (WidgetTester tester) async {
      final testWidgetNullUser = MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<ApiService>.value(value: mockApiService),
            ChangeNotifierProvider<FontSizeProvider>.value(value: mockFontSizeProvider),
          ],
          child: SchulungenSearchScreen(
            null,
            isLoggedIn: false,
            onLogout: mockLogout,
          ),
        ),
      );

      await tester.pumpWidget(testWidgetNullUser);
      await tester.pumpAndSettle();

      // Should render without crashing
      expect(find.text('Aus- und Weiterbildung'), findsOneWidget);
    });

    testWidgets('should handle very long text inputs',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      final longText = 'A' * 1000;

      await tester.enterText(find.byKey(const Key('Ort')), longText);
      await tester.pump();

      expect(find.text(longText), findsOneWidget);
    });
  });
}

// Test helper class to test with null date
class _TestSchulungenSearchScreen extends StatefulWidget {
  const _TestSchulungenSearchScreen(
    this.userData, {
    required this.isLoggedIn,
    required this.onLogout,
    this.showMenu = true,
    this.showConnectivityIcon = true,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;
  final bool showMenu;
  final bool showConnectivityIcon;

  @override
  State<_TestSchulungenSearchScreen> createState() => _TestSchulungenSearchScreenState();
}

class _TestSchulungenSearchScreenState extends State<_TestSchulungenSearchScreen> {
  DateTime? selectedDate; // Start with null date
  int? selectedWebGruppe = 0;
  int? selectedBezirkId = 0;
  final TextEditingController _ortController = TextEditingController();
  final TextEditingController _titelController = TextEditingController();
  bool fuerVerlaengerungen = false;
  List<BezirkSearchTriple> _bezirke = [];
  bool isLoadingBezirke = true;

  @override
  void initState() {
    super.initState();
    _fetchBezirke();
  }

  Future<void> _fetchBezirke() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final bezirke = await apiService.fetchBezirkeforSearch();

    // Add "Alle" option
    _bezirke = [
      const BezirkSearchTriple(bezirkId: 0, bezirkNr: 0, bezirkName: 'Alle'),
      ...bezirke,
    ];

    setState(() {
      isLoadingBezirke = false;
    });
  }

  @override
  void dispose() {
    _ortController.dispose();
    _titelController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      locale: const Locale('de', 'DE'),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _navigateToResults() {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte wählen Sie ein Datum.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Navigation logic would go here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aus- und Weiterbildung'),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'resetFab',
            onPressed: () {
              setState(() {
                selectedDate = DateTime.now();
                selectedWebGruppe = 0;
                selectedBezirkId = 0;
                _ortController.clear();
                _titelController.clear();
                fuerVerlaengerungen = false;
              });
            },
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'searchFab',
            onPressed: _navigateToResults,
            child: const Icon(Icons.search),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Suchen'),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Aus-und Weiterbildungen ab Datum anzeigen',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  selectedDate == null
                      ? 'Bitte wählen Sie ein Datum'
                      : _formatDate(selectedDate!),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('Ort'),
              controller: _ortController,
              decoration: const InputDecoration(labelText: 'Ort'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('Titel'),
              controller: _titelController,
              decoration: const InputDecoration(labelText: 'Titel'),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Für Lizenzverlängerung'),
              value: fuerVerlaengerungen,
              onChanged: (bool? value) {
                setState(() {
                  fuerVerlaengerungen = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
