import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:meinbssb/screens/absolvierte_schulungen_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/models/user_data.dart';
import '../helpers/test_helper.dart';


@GenerateMocks([ApiService, NetworkService, FontSizeProvider, ConfigService])
void main() {
  setUp(() {
    TestHelper.setupMocks();
  });

  Widget createAbsolvierteSchulungenScreen() {
    return TestHelper.createTestApp(
      home: AbsolvierteSchulungenScreen(
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

  group('AbsolvierteSchulungenScreen', () {
    testWidgets('renders absolvierte schulungen screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createAbsolvierteSchulungenScreen());
      await tester.pumpAndSettle();

      expect(find.text('Absolvierte Schulungen'), findsOneWidget);
    });

    testWidgets('shows offline message when offline',
        (WidgetTester tester) async {
      when(TestHelper.mockNetworkService.hasInternet())
          .thenAnswer((_) async => false);

      await tester.pumpWidget(createAbsolvierteSchulungenScreen());
      await tester.pumpAndSettle();

      expect(find.text('Absolvierte Schulungen sind offline nicht verfügbar'),
          findsOneWidget,);
    });
  });
}
