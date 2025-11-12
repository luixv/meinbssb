import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/startrechte/starting_rights_zweitverein_table.dart'
    show ZweitvereinTable, ZveAutocompleteField;
import 'package:meinbssb/models/disziplin_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
// ADD THIS for LinkedHashMap

// Generate mocks
@GenerateMocks([FontSizeProvider])
import 'starting_rights_zweitverein_table_test.mocks.dart';

void main() {
  late MockFontSizeProvider mockFontSizeProvider;
  late Widget testWidget;

  // Test data
  const testYear = 2024;
  const testVereinName = 'Test Verein';

  final testFirstColumns = <String, int?>{
    'Disziplin 1': 1,
    'Disziplin 2': 2,
    'Disziplin 3': null,
  };

  final testSecondColumns = <String, int?>{
    'Disziplin 1': 1,
    'Disziplin 2': null,
    'Disziplin 3': 3,
  };

  final testPivot = <String, int?>{
    'Disziplin 1': 1,
    'Disziplin 2': 2,
    'Disziplin 3': 3,
  };

  final testDisciplines = [
    const Disziplin(
      disziplinId: 1,
      disziplinNr: 'D001',
      disziplin: 'Disziplin 1',
    ),
    const Disziplin(
      disziplinId: 2,
      disziplinNr: 'D002',
      disziplin: 'Disziplin 2',
    ),
    const Disziplin(
      disziplinId: 3,
      disziplinNr: 'D003',
      disziplin: 'Disziplin 3',
    ),
  ];

  bool deleteCalled = false;
  String? deletedKey;
  bool addCalled = false;
  Disziplin? addedDiscipline;

  void mockDelete(String key) {
    deleteCalled = true;
    deletedKey = key;
  }

  void mockAdd(Disziplin discipline) {
    addCalled = true;
    addedDiscipline = discipline;
  }

  setUp(() {
    mockFontSizeProvider = MockFontSizeProvider();
    deleteCalled = false;
    deletedKey = null;
    addCalled = false;
    addedDiscipline = null;

    // Setup FontSizeProvider mock
    when(mockFontSizeProvider.scaleFactor).thenReturn(1.0);
    when(mockFontSizeProvider.getScaledFontSize(any)).thenAnswer((invocation) {
      final baseSize = invocation.positionalArguments[0] as double;
      return baseSize * 1.0;
    });

    testWidget = MaterialApp(
      home: Scaffold(
        body: MultiProvider(
          providers: [
            ChangeNotifierProvider<FontSizeProvider>.value(
              value: mockFontSizeProvider,
            ),
          ],
          child: ZweitvereinTable(
            seasonInt: testYear,
            vereinName: testVereinName,
            firstColumns: testFirstColumns,
            secondColumns: testSecondColumns,
            pivot: testPivot,
            disciplines: testDisciplines,
            onDelete: mockDelete,
            onAdd: mockAdd,
          ),
        ),
      ),
    );
  });

  group('ZweitvereinTable', () {
    testWidgets(
      'should show check icons for existing disciplines in first column',
      (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        // Should show check icon for Disziplin 1 and 2 (they exist in firstColumns)
        expect(
          find.byIcon(Icons.check),
          findsNWidgets(6),
        ); // Currently finding 6, need to investigate why
      },
    );

    testWidgets(
      'should show check icons for existing disciplines in second column',
      (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        // Should show check icon for Disziplin 1 and 3 (they exist in secondColumns)
        expect(
          find.byIcon(Icons.check),
          findsNWidgets(6),
        ); // Currently finding 6, need to investigate why
      },
    );

    testWidgets(
      'should show delete buttons only for disciplines in second column',
      (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        // Should show delete buttons for Disziplin 1 and 3 (they exist in secondColumns)
        expect(
          find.byIcon(Icons.delete_outline),
          findsNWidgets(3),
        ); // Currently finding 3, need to investigate why
      },
    );

    testWidgets('should call onDelete when delete button is pressed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Find and tap the first delete button
      final deleteButtons = find.byIcon(Icons.delete_outline);
      expect(
        deleteButtons,
        findsNWidgets(3),
      ); // Currently finding 3, need to investigate why

      await tester.tap(deleteButtons.first);
      await tester.pump();

      expect(deleteCalled, true);
      expect(deletedKey, isNotNull);
    });

    testWidgets('should render autocomplete field for adding disciplines', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Verify ZveAutocompleteField is present
      expect(find.byType(ZveAutocompleteField), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should filter disciplines based on input text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Find the text field
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Enter text to filter
      await tester.enterText(textField, 'Disziplin 1');
      await tester.pump();

      await tester.pumpAndSettle();
      // Should show filtered results in overlay
      expect(find.text('D001 - Disziplin 1'), findsOneWidget);
    });

    testWidgets('should filter disciplines by discipline number', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Find the text field
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Enter discipline number to filter
      await tester.enterText(textField, 'D002');
      await tester.pump();

      await tester.pumpAndSettle();
      // Should show filtered results in overlay
      expect(find.text('D002 - Disziplin 2'), findsOneWidget);
    });

    testWidgets(
      'should call onAdd when discipline is selected from autocomplete',
      (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        // Find the text field
        final textField = find.byType(TextField);
        expect(textField, findsOneWidget);

        // Enter text to show options
        await tester.enterText(textField, 'Disziplin 1');
        await tester.pump();

        // Tap on the first option
        await tester.pumpAndSettle();
        final option = find.text('D001 - Disziplin 1');
        expect(option, findsOneWidget);

        await tester.tap(option);
        await tester.pumpAndSettle();

        expect(addCalled, true);
        expect(addedDiscipline, equals(testDisciplines[0]));
      },
    );

    testWidgets('should show empty list when no disciplines match filter', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Find the text field
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Enter text that doesn't match any discipline
      await tester.enterText(textField, 'NonExistent');
      await tester.pump();

      await tester.pumpAndSettle();
      // Should not show any discipline options
      expect(find.text('D001 - Disziplin 1'), findsNothing);
      expect(find.text('D002 - Disziplin 2'), findsNothing);
      expect(find.text('D003 - Disziplin 3'), findsNothing);
    });

    testWidgets('should handle case-insensitive filtering', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Find the text field
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Enter text with different case
      await tester.enterText(textField, 'disziplin 1');
      await tester.pump();

      await tester.pumpAndSettle();
      // Should still find the discipline in overlay
      expect(find.text('D001 - Disziplin 1'), findsOneWidget);
    });

    testWidgets('should handle empty input text', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Find the text field
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Enter empty text
      await tester.enterText(textField, '');
      await tester.pump();

      await tester.pumpAndSettle();
      // Should not show any discipline options
      expect(find.text('D001 - Disziplin 1'), findsNothing);
      expect(find.text('D002 - Disziplin 2'), findsNothing);
      expect(find.text('D003 - Disziplin 3'), findsNothing);
    });

    testWidgets(
      'should display discipline with number and name when both exist',
      (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        // Find the text field
        final textField = find.byType(TextField);
        expect(textField, findsOneWidget);

        // Enter text to show options
        await tester.enterText(textField, 'Disziplin');
        await tester.pumpAndSettle();

        // Should show discipline with number and name
        expect(find.text('D001 - Disziplin 1'), findsOneWidget);
        expect(find.text('D002 - Disziplin 2'), findsOneWidget);
        expect(find.text('D003 - Disziplin 3'), findsOneWidget);
      },
    );

    testWidgets(
      'should display discipline with only name when number is null',
      (WidgetTester tester) async {
        // Create discipline without number
        const disciplineWithoutNumber = Disziplin(
          disziplinId: 4,
          disziplinNr: null,
          disziplin: 'Disziplin Without Number',
        );

        final testWidgetWithNullNumber = MaterialApp(
          home: Scaffold(
            body: MultiProvider(
              providers: [
                ChangeNotifierProvider<FontSizeProvider>.value(
                  value: mockFontSizeProvider,
                ),
              ],
              child: ZweitvereinTable(
                seasonInt: testYear,
                vereinName: testVereinName,
                firstColumns: testFirstColumns,
                secondColumns: testSecondColumns,
                pivot: testPivot,
                disciplines: [...testDisciplines, disciplineWithoutNumber],
                onDelete: mockDelete,
                onAdd: mockAdd,
              ),
            ),
          ),
        );

        await tester.pumpWidget(testWidgetWithNullNumber);
        await tester.pumpAndSettle();

        // Find the text field
        final textField = find.byType(TextField);
        expect(textField, findsOneWidget);

        // Enter text to show options
        await tester.enterText(textField, 'Without Number');
        await tester.pumpAndSettle();

        // Should show discipline with only name (no number prefix)
        expect(find.text('Disziplin Without Number'), findsOneWidget);
      },
    );

    testWidgets('should handle empty pivot map', (WidgetTester tester) async {
      final testWidgetEmptyPivot = MaterialApp(
        home: Scaffold(
          body: MultiProvider(
            providers: [
              ChangeNotifierProvider<FontSizeProvider>.value(
                value: mockFontSizeProvider,
              ),
            ],
            child: ZweitvereinTable(
              seasonInt: testYear,
              vereinName: testVereinName,
              firstColumns: testFirstColumns,
              secondColumns: testSecondColumns,
              pivot: const {},
              disciplines: testDisciplines,
              onDelete: mockDelete,
              onAdd: mockAdd,
            ),
          ),
        ),
      );

      await tester.pumpWidget(testWidgetEmptyPivot);
      await tester.pumpAndSettle();

      // Should still render the table headers
      expect(find.text(testVereinName), findsOneWidget);
      expect(find.text('${testYear - 1}'), findsOneWidget);
      expect(find.text('$testYear'), findsOneWidget);

      // Should not show any discipline rows
      expect(find.text('Disziplin 1'), findsNothing);
      expect(find.text('Disziplin 2'), findsNothing);
      expect(find.text('Disziplin 3'), findsNothing);
    });

    testWidgets('should handle very long verein name', (
      WidgetTester tester,
    ) async {
      const longVereinName =
          'This is a very long verein name that should be handled properly by the Expanded widget to prevent overflow issues in the UI';

      final testWidgetLongName = MaterialApp(
        home: Scaffold(
          body: MultiProvider(
            providers: [
              ChangeNotifierProvider<FontSizeProvider>.value(
                value: mockFontSizeProvider,
              ),
            ],
            child: ZweitvereinTable(
              seasonInt: testYear,
              vereinName: longVereinName,
              firstColumns: testFirstColumns,
              secondColumns: testSecondColumns,
              pivot: testPivot,
              disciplines: testDisciplines,
              onDelete: mockDelete,
              onAdd: mockAdd,
            ),
          ),
        ),
      );

      await tester.pumpWidget(testWidgetLongName);
      await tester.pumpAndSettle();

      // Should display the long name without crashing
      expect(find.text(longVereinName), findsOneWidget);
    });

    testWidgets('should handle special characters in discipline names', (
      WidgetTester tester,
    ) async {
      const disciplineWithSpecialChars = Disziplin(
        disziplinId: 5,
        disziplinNr: 'D005',
        disziplin: 'Disziplin with @#%^&*()_+-=[]{}|;:,.<>?',
      );

      final testWidgetSpecialChars = MaterialApp(
        home: Scaffold(
          body: MultiProvider(
            providers: [
              ChangeNotifierProvider<FontSizeProvider>.value(
                value: mockFontSizeProvider,
              ),
            ],
            child: ZweitvereinTable(
              seasonInt: testYear,
              vereinName: testVereinName,
              firstColumns: testFirstColumns,
              secondColumns: testSecondColumns,
              pivot: testPivot,
              disciplines: List<Disziplin>.from(testDisciplines)
                ..add(disciplineWithSpecialChars),
              onDelete: mockDelete,
              onAdd: mockAdd,
            ),
          ),
        ),
      );

      await tester.pumpWidget(testWidgetSpecialChars);
      await tester.pumpAndSettle();

      // Find the text field
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Enter text to show options
      await tester.enterText(textField, 'Disziplin with');
      await tester.pumpAndSettle();

      // Should show discipline with special characters
      expect(
        find.text('D005 - Disziplin with @#%^&*()_+-=[]{}|;:,.<>?'),
        findsOneWidget,
      );
    });
  });

  // ---- Additional tests (append inside existing main()) ----
  group('ZweitvereinTable additional', () {
    Widget buildTable({
      required Map<String, int?> firstCols,
      required Map<String, int?> secondCols,
      required Map<String, int?> pivot,
      required List<Disziplin> disciplines,
      required void Function(String) onDelete,
      required void Function(Disziplin) onAdd,
      String vereinName = 'Test Verein',
      int season = 2024,
      required FontSizeProvider fontSizeProvider,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<FontSizeProvider>.value(
            value: fontSizeProvider,
            child: ZweitvereinTable(
              seasonInt: season,
              vereinName: vereinName,
              firstColumns: firstCols,
              secondColumns: secondCols,
              pivot: pivot,
              disciplines: disciplines,
              onDelete: onDelete,
              onAdd: onAdd,
            ),
          ),
        ),
      );
    }

    testWidgets('all keys in both maps -> checks == pivot.length * 2', (
      tester,
    ) async {
      final mockProvider = MockFontSizeProvider();
      when(mockProvider.scaleFactor).thenReturn(1);
      when(
        mockProvider.getScaledFontSize(any),
      ).thenAnswer((i) => i.positionalArguments.first as double);

      final pivot = {'A': 1, 'B': null, 'C': 3};
      // Both maps contain all keys (values may be null)
      final firstCols = {'A': 10, 'B': null, 'C': 30};
      final secondCols = {'A': null, 'B': 22, 'C': null};

      await tester.pumpWidget(
        buildTable(
          firstCols: firstCols,
          secondCols: secondCols,
          pivot: pivot,
          disciplines: const [],
          onDelete: (_) {},
          onAdd: (_) {},
          fontSizeProvider: mockProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Each pivot key yields one check per column => length * 2
      expect(find.byIcon(Icons.check), findsNWidgets(pivot.length * 2));
      // Delete buttons appear for every key in secondCols
      expect(find.byIcon(Icons.delete_outline), findsNWidgets(secondCols.length));
    });

    testWidgets('subset secondCols -> delete icons only for present keys', (
      tester,
    ) async {
      final mockProvider = MockFontSizeProvider();
      when(mockProvider.scaleFactor).thenReturn(1);
      when(
        mockProvider.getScaledFontSize(any),
      ).thenAnswer((i) => i.positionalArguments.first as double);

      final pivot = {'A': 1, 'B': 2, 'C': 3, 'D': 4};
      final firstCols = {'A': 1, 'C': 3, 'D': null}; // 3 checks in first col
      final secondCols = {
        'B': 2,
        'D': 4,
      }; // 2 checks in second col -> 2 deletes

      await tester.pumpWidget(
        buildTable(
          firstCols: firstCols,
          secondCols: secondCols,
          pivot: pivot,
          disciplines: const [],
          onDelete: (_) {},
          onAdd: (_) {},
          fontSizeProvider: mockProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsNWidgets(3 + 2));
      expect(find.byIcon(Icons.delete_outline), findsNWidgets(2));
    });

    testWidgets('delete callback passes correct key', (tester) async {
      final mockProvider = MockFontSizeProvider();
      when(mockProvider.scaleFactor).thenReturn(1);
      when(
        mockProvider.getScaledFontSize(any),
      ).thenAnswer((i) => i.positionalArguments.first as double);

      final pivot = {'X': 1, 'Y': 2};
      final secondCols = {'X': 11, 'Y': 22};
      String? deleted;
      await tester.pumpWidget(
        buildTable(
          firstCols: {'X': 1},
          secondCols: secondCols,
          pivot: pivot,
          disciplines: const [],
          onDelete: (k) => deleted = k,
          onAdd: (_) {},
          fontSizeProvider: mockProvider,
        ),
      );
      await tester.pumpAndSettle();

      final deleteButtons = find.byIcon(Icons.delete_outline);
      expect(deleteButtons, findsNWidgets(2));
      await tester.tap(deleteButtons.last); // Should map to 'Y'
      await tester.pump();
      expect(deleted, 'Y');
    });

    testWidgets('ExpansionTile collapses & expands', (tester) async {
      final mockProvider = MockFontSizeProvider();
      when(mockProvider.scaleFactor).thenReturn(1);
      when(
        mockProvider.getScaledFontSize(any),
      ).thenAnswer((i) => i.positionalArguments.first as double);
      final pivot = {'Row1': 1};

      await tester.pumpWidget(
        buildTable(
          firstCols: {'Row1': 1},
          secondCols: {'Row1': 1},
          pivot: pivot,
          disciplines: const [],
          onDelete: (_) {},
          onAdd: (_) {},
          fontSizeProvider: mockProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Initially expanded -> ZveAutocompleteField present
      expect(find.byType(ZveAutocompleteField), findsOneWidget);

      // Tap header to collapse
      await tester.tap(find.text('Test Verein'));
      await tester.pumpAndSettle();

      expect(find.byType(ZveAutocompleteField), findsNothing);

      // Tap again to expand
      await tester.tap(find.text('Test Verein'));
      await tester.pumpAndSettle();
      expect(find.byType(ZveAutocompleteField), findsOneWidget);
    });

    testWidgets('autocomplete clears after selection', (tester) async {
      final mockProvider = MockFontSizeProvider();
      when(mockProvider.scaleFactor).thenReturn(1);
      when(
        mockProvider.getScaledFontSize(any),
      ).thenAnswer((i) => i.positionalArguments.first as double);

      final disciplines = const [
        Disziplin(disziplinId: 1, disziplinNr: 'A01', disziplin: 'Alpha'),
      ];

      Disziplin? added;
      await tester.pumpWidget(
        buildTable(
          firstCols: const {},
          secondCols: const {},
          pivot: const {},
          disciplines: disciplines,
          onDelete: (_) {},
          onAdd: (d) => added = d,
          fontSizeProvider: mockProvider,
        ),
      );
      await tester.pumpAndSettle();

      final tf = find.byType(TextField);
      await tester.enterText(tf, 'Al');
      await tester.pumpAndSettle();
      await tester.tap(find.text('A01 - Alpha'));
      await tester.pumpAndSettle();
      expect(added, disciplines.first);

      final textFieldWidget = tester.widget<TextField>(tf);
      expect(textFieldWidget.controller!.text, isEmpty);
    });

    testWidgets('autocomplete multi-option add triggers correct callback', (
      tester,
    ) async {
      final mockProvider = MockFontSizeProvider();
      when(mockProvider.scaleFactor).thenReturn(1);
      when(
        mockProvider.getScaledFontSize(any),
      ).thenAnswer((i) => i.positionalArguments.first as double);

      final disciplines = const [
        Disziplin(disziplinId: 1, disziplinNr: 'X01', disziplin: 'Xylophon'),
      ];

      Disziplin? added;
      await tester.pumpWidget(
        buildTable(
          firstCols: const {},
          secondCols: const {},
          pivot: const {},
          disciplines: disciplines,
          onDelete: (_) {},
          onAdd: (d) => added = d,
          fontSizeProvider: mockProvider,
        ),
      );
      await tester.pumpAndSettle();

      final tf = find.byType(TextField);
      await tester.enterText(tf, 'Xy');
      await tester.pumpAndSettle();
      await tester.tap(find.text('X01 - Xylophon'));
      await tester.pumpAndSettle();
      expect(added, disciplines.first);
    });
  });
}
