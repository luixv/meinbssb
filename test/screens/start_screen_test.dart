import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/screens/start_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/config_service.dart';
import 'start_screen_test.mocks.dart';

@GenerateMocks(
  [ApiService],
  customMocks: [MockSpec<ApiService>(as: #CustomMockApiService)],
)
void main() {
  testWidgets('StartScreen displays loading spinner while fetching data', (
    WidgetTester tester,
  ) async {
    final mockApiService = CustomMockApiService();
    final userData = {
      'PERSONID': 123,
      'VORNAME': 'John',
      'NAMEN': 'Doe',
      'PASSNUMMER': 'ABC123',
      'VEREINNAME': 'My Vereinsname',
    };

    when(
      mockApiService.fetchAngemeldeteSchulungen(any, any),
    ).thenAnswer((_) async => Future.delayed(Duration(seconds: 1), () => []));

    await tester.pumpWidget(
      MaterialApp(
        home: Provider<ConfigService>(
          // Provide ConfigService
          create: (_) => MockConfigService(),
          child: Provider<ApiService>(
            create: (_) => mockApiService,
            child: StartScreen(userData, isLoggedIn: true, onLogout: () {}),
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('StartScreen displays no Schulungen found message when no data', (
    WidgetTester tester,
  ) async {
    final mockApiService = CustomMockApiService();
    final userData = {
      'PERSONID': 123,
      'VORNAME': 'John',
      'NAMEN': 'Doe',
      'PASSNUMMER': 'ABC123',
      'VEREINNAME': 'My Vereinsname',
    };

    when(
      mockApiService.fetchAngemeldeteSchulungen(any, any),
    ).thenAnswer((_) async => []);

    await tester.pumpWidget(
      MaterialApp(
        home: Provider<ConfigService>(
          // Provide ConfigService
          create: (_) => MockConfigService(),
          child: Provider<ApiService>(
            create: (_) => mockApiService,
            child: StartScreen(userData, isLoggedIn: true, onLogout: () {}),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Keine Schulungen gefunden.'), findsOneWidget);
  });

  testWidgets('StartScreen displays Schulungen list when data is returned', (
    WidgetTester tester,
  ) async {
    final mockApiService = CustomMockApiService();
    final userData = {
      'PERSONID': 123,
      'VORNAME': 'Jane',
      'NAMEN': 'Doe',
      'PASSNUMMER': 'XYZ456',
      'VEREINNAME': 'Vereinsname XYZ',
    };

    final schulungList = [
      {'BEZEICHNUNG': 'Schulung 1', 'DATUM': '2023-01-01'},
      {'BEZEICHNUNG': 'Schulung 2', 'DATUM': '2023-01-15'},
    ];

    when(
      mockApiService.fetchAngemeldeteSchulungen(any, any),
    ).thenAnswer((_) async => schulungList);

    await tester.pumpWidget(
      MaterialApp(
        home: Provider<ConfigService>(
          // Provide ConfigService
          create: (_) => MockConfigService(),
          child: Provider<ApiService>(
            create: (_) => mockApiService,
            child: StartScreen(userData, isLoggedIn: true, onLogout: () {}),
          ),
        ),
      ),
    );

    // Use pump with a duration to allow for the async operation to complete.
    await tester.pump(
      Duration(milliseconds: 500),
    ); // Adjust duration as needed.

    expect(find.text('Schulung 1'), findsOneWidget);
    expect(find.text('Schulung 2'), findsOneWidget);
  });
}

class MockConfigService extends Mock implements ConfigService {
  @override
  String? getString(String key, [String? section]) =>
      super.noSuchMethod(
            Invocation.method(#getString, [key, section]),
            returnValue: null,
          )
          as String?;
}
