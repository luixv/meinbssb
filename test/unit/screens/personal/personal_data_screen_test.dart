import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/screens/personal/personal_data_screen.dart';
import '../../helpers/test_helper.dart';

void main() {
  setUp(() {
    TestHelper.setupMocks();
  });

  Widget createPersonalDataScreen() {
    return TestHelper.createTestApp(
      home: PersonDataScreen(
        const UserData(
          personId: 439287,
          webLoginId: 13901,
          passnummer: '40100709',
          vereinNr: 401051,
          namen: 'Schürz',
          vorname: 'Lukas',
          vereinName: 'Feuerschützen Kühbach',
          passdatenId: 2000009155,
          mitgliedschaftId: 439287,
          strasse: 'Aichacher Strasse 21',
          plz: '86574',
          ort: 'Alsmoos',
          telefon: '123456789',
        ),
        isLoggedIn: true,
        onLogout: () {},
      ),
    );
  }

  group('PersonalDataScreen', () {
    testWidgets('renders personal data correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createPersonalDataScreen());
      await tester.pumpAndSettle();

      expect(find.text('Persönliche Daten'), findsOneWidget);
      expect(find.text('Lukas'), findsOneWidget);
      expect(find.text('Schürz'), findsOneWidget);
      expect(find.text('40100709'), findsOneWidget);
    });

    testWidgets('shows edit button', (WidgetTester tester) async {
      await tester.pumpWidget(createPersonalDataScreen());
      await tester.pumpAndSettle();

      // The edit button is a FloatingActionButton with an edit icon
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is FloatingActionButton &&
              widget.child is Icon &&
              (widget.child as Icon).icon == Icons.edit,
        ),
        findsOneWidget,
      );
    });

    testWidgets('enables editing when edit button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createPersonalDataScreen());
      await tester.pumpAndSettle();

      // Tap the edit FAB
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Now the Vorname/Nachname fields should be editable (not readOnly)
      final vornameField = find.widgetWithText(TextFormField, 'Vorname');
      final nachnameField = find.widgetWithText(TextFormField, 'Nachname');
      expect(vornameField, findsWidgets);
      expect(nachnameField, findsWidgets);
      final vornameWidgets = tester.widgetList<TextFormField>(vornameField);
      final nachnameWidgets = tester.widgetList<TextFormField>(nachnameField);
      expect(vornameWidgets.any((w) => w.enabled == true), isTrue);
      expect(nachnameWidgets.any((w) => w.enabled == true), isTrue);
    });
  });
}
