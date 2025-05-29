import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/screens/start_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/config_service.dart';
import 'start_screen_test.mocks.dart';

// Mock ConfigService para Provider
class MockConfigService extends Mock implements ConfigService {}

@GenerateMocks(
  [ApiService],
  customMocks: [MockSpec<ApiService>(as: #CustomMockApiService)],
)
void main() {
  // CORRECTED: Flatten the userData map structure
  final userData = {
    'PERSONID': 123,
    'VORNAME': 'John',
    'NAMEN': 'Doe',
    'PASSNUMMER': 'ABC123',
    'VEREINNAME': 'My Vereinsname',
  };

  testWidgets('StartScreen displays loading spinner while fetching data',
      (WidgetTester tester) async {
    final mockApiService = CustomMockApiService();

    when(
      mockApiService.fetchAngemeldeteSchulungen(any, any),
    ).thenAnswer(
      (_) async => Future.delayed(const Duration(seconds: 1), () => []),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Provider<ConfigService>(
          create: (_) => MockConfigService(),
          child: Provider<ApiService>(
            create: (_) => mockApiService,
            child: StartScreen(userData, isLoggedIn: true, onLogout: () {}),
          ),
        ),
      ),
    );

    // Mientras espera el resultado, debe mostrar CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    // Luego de cargarse los datos, ya no debe mostrar el spinner
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('StartScreen displays no Schulungen found message when no data',
      (WidgetTester tester) async {
    final mockApiService = CustomMockApiService();

    when(
      mockApiService.fetchAngemeldeteSchulungen(any, any),
    ).thenAnswer((_) async => []);

    await tester.pumpWidget(
      MaterialApp(
        home: Provider<ConfigService>(
          create: (_) => MockConfigService(),
          child: Provider<ApiService>(
            create: (_) => mockApiService,
            child: StartScreen(userData, isLoggedIn: true, onLogout: () {}),
          ),
        ),
      ),
    );

    // Esperamos que se muestre el texto de 'Keine Schulungen gefunden.'
    await tester.pumpAndSettle();
    expect(find.text('Keine Schulungen gefunden.'), findsOneWidget);
  });

  testWidgets('StartScreen displays list of Schulungen when data is present',
      (WidgetTester tester) async {
    final mockApiService = CustomMockApiService();

    final schulungenMock = [
      {
        'DATUM': '2025-05-26',
        'BEZEICHNUNG': 'Test Schulung 1',
        'ONLINE': true,
        'SCHULUNGENTEILNEHMERID': 111,
      },
      {
        'DATUM': '2025-05-27',
        'BEZEICHNUNG': 'Test Schulung 2',
        'ONLINE': false,
        'SCHULUNGENTEILNEHMERID': 222,
      },
    ];

    when(
      mockApiService.fetchAngemeldeteSchulungen(any, any),
    ).thenAnswer((_) async => schulungenMock);

    await tester.pumpWidget(
      MaterialApp(
        home: Provider<ConfigService>(
          create: (_) => MockConfigService(),
          child: Provider<ApiService>(
            create: (_) => mockApiService,
            child: StartScreen(userData, isLoggedIn: true, onLogout: () {}),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verificamos que los nombres de las Schulungen estén en pantalla
    expect(find.text('Test Schulung 1'), findsOneWidget);
    expect(find.text('Test Schulung 2'), findsOneWidget);

    // También que el texto de 'Keine Schulungen gefunden.' no está
    expect(find.text('Keine Schulungen gefunden.'), findsNothing);
  });
}
