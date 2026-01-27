import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnissantrag_step4_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/api_service.dart';

import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:mockito/mockito.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  group('BeduerfnissantragStep4Screen', () {
    late MockApiService mockApiService;
    late UserData userData;

    setUp(() {
      mockApiService = MockApiService();
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
        mockApiService.getBedAuswahlByTypId(any),
      ).thenAnswer((_) async => []);
    });

    Widget createWidgetUnderTest({bool isLoggedIn = true}) {
      return MultiProvider(
        providers: [
          Provider<ApiService>.value(value: mockApiService),
          ChangeNotifierProvider(create: (_) => FontSizeProvider()),
        ],
        child: MaterialApp(
          home: BeduerfnissantragStep4Screen(
            userData: userData,
            isLoggedIn: isLoggedIn,
            onLogout: () {},
          ),
        ),
      );
    }

    testWidgets('renders without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(BeduerfnissantragStep4Screen), findsOneWidget);
    });

    testWidgets('shows logout button if logged in', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(isLoggedIn: true));
      expect(find.byIcon(Icons.logout), findsWidgets);
    });

    testWidgets('does not show logout button if not logged in', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(isLoggedIn: false));
      expect(find.byIcon(Icons.logout), findsNothing);
    });

    // Add more tests as needed for form fields, button taps, etc.
  });
}
