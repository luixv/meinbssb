import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:meinbssb/screens/absolvierte_schulungen_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/services/core/font_size_provider.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/models/user_data.dart';

import 'absolvierte_schulungen_screen_test.mocks.dart';

@GenerateMocks([ApiService, NetworkService, FontSizeProvider, ConfigService])
void main() {
  late MockApiService mockApiService;
  late MockNetworkService mockNetworkService;
  late MockFontSizeProvider mockFontSizeProvider;
  late MockConfigService mockConfigService;

  setUp(() {
    mockApiService = MockApiService();
    mockNetworkService = MockNetworkService();
    mockFontSizeProvider = MockFontSizeProvider();
    mockConfigService = MockConfigService();
    when(mockNetworkService.hasInternet()).thenAnswer((_) async => true);
    when(mockFontSizeProvider.scaleFactor).thenReturn(1.0);
    when(mockConfigService.getString('logoName', 'appTheme'))
        .thenReturn('assets/images/myBSSB-logo.png');
  });

  Future<void> pumpAbsolvierteSchulungenScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ApiService>.value(value: mockApiService),
          Provider<NetworkService>.value(value: mockNetworkService),
          ChangeNotifierProvider<FontSizeProvider>.value(
            value: mockFontSizeProvider,
          ),
          Provider<ConfigService>.value(value: mockConfigService),
        ],
        child: MaterialApp(
          home: AbsolvierteSchulungenScreen(
            const UserData(
              personId: 123,
              webLoginId: 456,
              passnummer: '12345678',
              vereinNr: 789,
              namen: 'User',
              vorname: 'Test',
              vereinName: 'Test Club',
              passdatenId: 1,
              mitgliedschaftId: 1,
            ),
            isLoggedIn: true,
            onLogout: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('shows loading state initially', (WidgetTester tester) async {
    when(mockApiService.fetchAbsolvierteSchulungen(any)).thenAnswer(
      (_) => Future.value([]),
    );

    await pumpAbsolvierteSchulungenScreen(tester);
    await tester.pump(); // Show loading state

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle(); // Wait for async operations to complete
  });

  testWidgets('shows empty state when no trainings found',
      (WidgetTester tester) async {
    when(mockApiService.fetchAbsolvierteSchulungen(any)).thenAnswer(
      (_) => Future.value([]),
    );

    await pumpAbsolvierteSchulungenScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Absolvierte Schulungen'), findsWidgets);
    expect(
      find.text('Keine absolvierten Schulungen gefunden.'),
      findsOneWidget,
    );
  });

  testWidgets('shows offline message when offline',
      (WidgetTester tester) async {
    when(mockNetworkService.hasInternet()).thenAnswer((_) async => false);
    when(mockApiService.fetchAbsolvierteSchulungen(any)).thenAnswer(
      (_) => Future.value([]),
    );

    await pumpAbsolvierteSchulungenScreen(tester);
    await tester.pumpAndSettle();

    expect(
      find.text('Absolvierte Schulungen sind offline nicht verfügbar'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Bitte stellen Sie sicher, dass Sie mit dem Internet verbunden sind, um Ihre absolvierten Schulungen anzuzeigen.',
      ),
      findsOneWidget,
    );
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('shows FAB when online', (WidgetTester tester) async {
    when(mockApiService.fetchAbsolvierteSchulungen(any)).thenAnswer(
      (_) => Future.value([]),
    );

    await pumpAbsolvierteSchulungenScreen(tester);
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
