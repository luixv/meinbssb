import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/screens/schulungen_search_screen.dart';
import '../helpers/test_helper.dart';

void main() {
  setUp(() {
    TestHelper.setupMocks();
  });

  Widget createSchulungenSearchScreen() {
    return TestHelper.createTestApp(
      home: SchulungenSearchScreen(
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

  group('SchulungenSearchScreen', () {
    testWidgets('renders correctly with user data',
        (WidgetTester tester) async {
      when(TestHelper.mockNetworkService.hasInternet())
          .thenAnswer((_) async => true);

      await tester.pumpWidget(createSchulungenSearchScreen());
      await tester.pumpAndSettle();

      expect(find.text('Schulungen'), findsOneWidget);
      expect(find.text('Schulungen suchen'), findsOneWidget);
      expect(find.text('Datum wählen'), findsOneWidget);
      expect(find.text('Gruppe'), findsOneWidget);
      expect(find.text('Bezirk'), findsOneWidget);
      expect(find.text('Ort'), findsOneWidget);
      expect(find.text('Titel'), findsOneWidget);
      expect(find.text('Für Lizenzverlängerung'), findsOneWidget);
    });

    testWidgets('shows offline message when offline',
        (WidgetTester tester) async {
      when(TestHelper.mockNetworkService.hasInternet())
          .thenAnswer((_) async => false);

      await tester.pumpWidget(createSchulungenSearchScreen());
      await tester.pumpAndSettle();

      expect(
        find.text('Schulungen suchen ist offline nicht verfügbar'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Bitte stellen Sie sicher, dass Sie mit dem Internet verbunden sind, um nach Schulungen zu suchen.',
        ),
        findsOneWidget,
      );
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('shows FABs when online', (WidgetTester tester) async {
      when(TestHelper.mockNetworkService.hasInternet())
          .thenAnswer((_) async => true);

      await tester.pumpWidget(createSchulungenSearchScreen());
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNWidgets(2));
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('hides FABs when offline', (WidgetTester tester) async {
      when(TestHelper.mockNetworkService.hasInternet())
          .thenAnswer((_) async => false);

      await tester.pumpWidget(createSchulungenSearchScreen());
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('shows loading indicator while checking network status',
        (WidgetTester tester) async {
      when(TestHelper.mockNetworkService.hasInternet()).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 100), () => true),
      );

      await tester.pumpWidget(createSchulungenSearchScreen());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
    });

    testWidgets('displays form fields when online',
        (WidgetTester tester) async {
      when(TestHelper.mockNetworkService.hasInternet())
          .thenAnswer((_) async => true);

      await tester.pumpWidget(createSchulungenSearchScreen());
      await tester.pumpAndSettle();

      expect(find.text('Schulungen suchen'), findsOneWidget);
      expect(find.text('Datum wählen'), findsOneWidget);
      expect(find.text('Gruppe'), findsOneWidget);
      expect(find.text('Bezirk'), findsOneWidget);
      expect(find.text('Ort'), findsOneWidget);
      expect(find.text('Titel'), findsOneWidget);
      expect(find.text('Für Lizenzverlängerung'), findsOneWidget);
    });
  });
}
