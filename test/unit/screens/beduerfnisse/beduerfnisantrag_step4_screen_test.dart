import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step4_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/api_service.dart';

import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'beduerfnisantrag_step4_screen_test.mocks.dart';

@GenerateMocks(
  [ApiService],
  customMocks: [MockSpec<ApiService>(as: #TestMockApiService)],
)
void main() {
  group('BeduerfnissantragStep4Screen', () {
    late TestMockApiService mockApiService;
    late UserData userData;

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
    });

    Widget createWidgetUnderTest({bool isLoggedIn = true}) {
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
          ),
        ),
      );
    }

    testWidgets('renders without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(BeduerfnisantragStep4Screen), findsOneWidget);
    });
    // Add more tests as needed for form fields, button taps, etc.
  });
}
