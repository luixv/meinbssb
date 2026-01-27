import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step4_dialog_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/models/beduerfnisse_waffe_besitz_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'beduerfnisantrag_step4_dialog_screen_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  group('AddWaffeBesitzDialog', () {
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      // Mock all async dropdown data
      when(
        mockApiService.getBedAuswahlByTypId(any),
      ).thenAnswer((_) async => []);
      when(
        mockApiService.createBedWaffeBesitz(
          antragsnummer: anyNamed('antragsnummer'),
          wbkNr: anyNamed('wbkNr'),
          lfdWbk: anyNamed('lfdWbk'),
          waffenartId: anyNamed('waffenartId'),
          kaliberId: anyNamed('kaliberId'),
          kompensator: anyNamed('kompensator'),
          hersteller: anyNamed('hersteller'),
          lauflaengeId: anyNamed('lauflaengeId'),
          gewicht: anyNamed('gewicht'),
          beduerfnisgrundId: anyNamed('beduerfnisgrundId'),
          verbandId: anyNamed('verbandId'),
          bemerkung: anyNamed('bemerkung'),
        ),
      ).thenAnswer((_) async => {});
      when(
        mockApiService.updateBedWaffeBesitz(any),
      ).thenAnswer((_) async => true);
    });

    Widget createDialog({BeduerfnisWaffeBesitz? waffeBesitz}) {
      return MultiProvider(
        providers: [
          Provider<ApiService>.value(value: mockApiService),
          ChangeNotifierProvider(create: (_) => FontSizeProvider()),
        ],
        child: MaterialApp(
          home: Builder(
            builder:
                (context) => AddWaffeBesitzDialog(
                  antragsnummer: 1,
                  waffeBesitz: waffeBesitz,
                ),
          ),
        ),
      );
    }

    testWidgets('renders dialog and form fields', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      expect(find.byType(AddWaffeBesitzDialog), findsOneWidget);
      expect(find.text('Waffenbesitz hinzufügen'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('shows edit title if waffeBesitz is provided', (
      WidgetTester tester,
    ) async {
      final waffe = BeduerfnisWaffeBesitz(
        id: 1,
        antragsnummer: 1,
        wbkNr: 'A',
        lfdWbk: '1',
        waffenartId: 1,
        kaliberId: 1,
        kompensator: false,
      );
      await tester.pumpWidget(createDialog(waffeBesitz: waffe));
      expect(find.text('Waffenbesitz bearbeiten'), findsOneWidget);
    });

    testWidgets('save button is disabled if required fields are empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createDialog());
      await tester.pumpAndSettle();
      // Find the save FAB by heroTag
      final fab = find.byWidgetPredicate(
        (widget) =>
            widget is FloatingActionButton &&
            widget.heroTag == 'fab_save_waffe',
      );
      expect(fab, findsOneWidget);
      final fabWidget = tester.widget<FloatingActionButton>(fab);
      expect(fabWidget.onPressed, isNull);
    });
  });
}
