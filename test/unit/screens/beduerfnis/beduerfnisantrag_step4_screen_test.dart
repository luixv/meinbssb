import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step4_screen.dart';
import 'package:meinbssb/models/beduerfnis_waffe_besitz_data.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import 'package:meinbssb/models/beduerfnis_antrag_data.dart';
import 'package:meinbssb/models/beduerfnis_antrag_status_data.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step5_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/api_service.dart';

import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'beduerfnisantrag_step4_screen_test.mocks.dart';

// Helper class for fake waffeBesitz
class TestWaffeBesitz {
  TestWaffeBesitz(
    this.wbkNr,
    this.lfdWbk, {
    this.id,
    this.waffenartId,
    this.lauflaengeId,
    this.beduerfnisgrundId,
    this.hersteller,
    this.kaliberId,
    this.gewicht,
    this.verbandId,
    this.kompensator,
    this.bemerkung,
  });
  final String wbkNr;
  final String lfdWbk;
  final int? id;
  final int? waffenartId;
  final int? lauflaengeId;
  final int? beduerfnisgrundId;
  final String? hersteller;
  final int? kaliberId;
  final String? gewicht;
  final int? verbandId;
  final bool? kompensator;
  final String? bemerkung;

  BeduerfnisWaffeBesitz toModel() {
    return BeduerfnisWaffeBesitz(
      id: id,
      antragsnummer: 1,
      wbkNr: wbkNr,
      lfdWbk: lfdWbk,
      waffenartId: waffenartId ?? 1,
      hersteller: hersteller ?? '',
      kaliberId: kaliberId ?? 1,
      lauflaengeId: lauflaengeId,
      gewicht: gewicht,
      kompensator: kompensator ?? false,
      beduerfnisgrundId: beduerfnisgrundId,
      verbandId: verbandId,
      bemerkung: bemerkung,
    );
  }
}

@GenerateMocks(
  [ApiService],
  customMocks: [MockSpec<ApiService>(as: #TestMockApiService)],
)
void main() {
  group('BeduerfnissantragStep4Screen', () {
    late TestMockApiService mockApiService;
    late UserData userData;

    BeduerfnisAntrag testAntrag = BeduerfnisAntrag(
      antragsnummer: 123,
      personId: 1,
      statusId: BeduerfnisAntragStatus.entwurf,
    );
    setUp(() {
      mockApiService = TestMockApiService();
      userData = UserData(
        personId: 1,
        passnummer: 'P123',
        vereinNr: 42,
        namen: 'Mustermann',
        vorname: 'Max',
        vereinName: 'Testverein',
        passdatenId: 99,
        mitgliedschaftId: 77,
        webLoginId: 123,
      );
      // Mock any async methods used in the screen
      when(
        mockApiService.getBedAuswahlByTypId(argThat(isA<int>())),
      ).thenAnswer((_) async => []);
      when(
        mockApiService.getBedWaffeBesitzByAntragsnummer(any),
      ).thenAnswer((_) async => []);
    });

    Widget createWidgetUnderTest({
      bool isLoggedIn = true,
      BeduerfnisAntrag? antrag,
      bool readOnly = false,
    }) {
      return MultiProvider(
        providers: [
          Provider<ApiService>.value(value: mockApiService),
          ChangeNotifierProvider(create: (_) => FontSizeProvider()),
        ],
        child: MaterialApp(
          home: BeduerfnisantragStep4Screen(
            userData: userData,
            isLoggedIn: isLoggedIn,
            onLogout: () {},
            antrag: antrag ?? testAntrag,
            readOnly: readOnly,
          ),
        ),
      );
    }

    testWidgets('renders without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(BeduerfnisantragStep4Screen), findsOneWidget);
    });

    testWidgets('shows header and empty state', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Keine Waffenbesitz-Einträge'),
        findsOneWidget,
      );
    });

    testWidgets('shows add FAB when editable', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('does not show add FAB when readOnly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(readOnly: true));
      expect(find.byIcon(Icons.add), findsNothing);
    });

    testWidgets('shows next FAB and navigates', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();
      // Should navigate to BeduerfnisantragStep5Screen
      expect(find.byType(BeduerfnisantragStep5Screen), findsOneWidget);
    });

    testWidgets('shows delete and edit icons for waffenbesitz', (
      WidgetTester tester,
    ) async {
      // Provide a fake waffenbesitz entry
      final fakeWaffe = TestWaffeBesitz('A1', '2', id: 1);
      when(
        mockApiService.getBedWaffeBesitzByAntragsnummer(any),
      ).thenAnswer((_) async => [fakeWaffe.toModel()]);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      // Semantics
      expect(find.bySemanticsLabel('Eintrag löschen'), findsOneWidget);
      expect(find.bySemanticsLabel('Eintrag bearbeiten'), findsOneWidget);
    });

    testWidgets('sorts waffenbesitz by wbkNr and lfdWbk', (
      WidgetTester tester,
    ) async {
      final w1 = TestWaffeBesitz('A1', '2', id: 1);
      final w2 = TestWaffeBesitz('A1', '1', id: 2);
      final w3 = TestWaffeBesitz('B1', '1', id: 3);
      when(
        mockApiService.getBedWaffeBesitzByAntragsnummer(any),
      ).thenAnswer((_) async => [w1.toModel(), w2.toModel(), w3.toModel()]);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      // The first card should be w2 (A1,1), then w1 (A1,2), then w3 (B1,1)
      final cards = find.byType(Card);
      expect(cards, findsNWidgets(3));
      final cardTexts =
          tester.widgetList(cards).map((c) {
            final card = c as Card;
            final child = card.child as Stack;
            final padding = child.children.first as Padding;
            final col = padding.child as Column;
            final row = col.children.first as Row;
            final leftCol = (row.children[0] as Expanded).child as Column;
            final infoRow = leftCol.children.first as Row;
            final scaledTextWidget = (infoRow.children[2] as Expanded).child;
            if (scaledTextWidget is ScaledText) {
              return (scaledTextWidget).text;
            }
            return '';
          }).toList();
      expect(cardTexts[0], contains('A1 / 1'));
      expect(cardTexts[1], contains('A1 / 2'));
      expect(cardTexts[2], contains('B1 / 1'));
    });

    // Helper class for fake waffeBesitz is now at the top of the file
  });
}
