import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/screens/bank_data_screen.dart';
import '../helpers/test_helper.dart';

void main() {
  setUp(() {
    TestHelper.setupMocks();
  });

  Widget createBankDataScreen() {
    return TestHelper.createTestApp(
      home: BankDataScreen(
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
        webloginId: 13901,
        isLoggedIn: true,
        onLogout: () {},
      ),
    );
  }

  group('BankDataScreen', () {
    testWidgets('renders bank data form', (WidgetTester tester) async {
      await tester.pumpWidget(createBankDataScreen());
      await tester.pumpAndSettle();

      expect(find.text('Bankdaten'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(FloatingActionButton), findsWidgets);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });
  });
}
