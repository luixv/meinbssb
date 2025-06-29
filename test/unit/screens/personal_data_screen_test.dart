import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/screens/personal_data_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/services/core/font_size_provider.dart';
import 'package:meinbssb/services/core/config_service.dart';

@GenerateMocks([ApiService, NetworkService, FontSizeProvider, ConfigService])
import 'personal_data_screen_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late MockNetworkService mockNetworkService;
  late MockFontSizeProvider mockFontSizeProvider;
  late MockConfigService mockConfigService;
  late UserData testUserData;

  setUp(() {
    mockApiService = MockApiService();
    mockNetworkService = MockNetworkService();
    mockFontSizeProvider = MockFontSizeProvider();
    mockConfigService = MockConfigService();
    testUserData = const UserData(
      personId: 123,
      webLoginId: 456,
      passnummer: '12345678',
      vereinNr: 789,
      namen: 'User',
      vorname: 'Test',
      vereinName: 'Test Club',
      passdatenId: 1,
      mitgliedschaftId: 1,
    );

    when(mockNetworkService.hasInternet()).thenAnswer((_) async => true);
    when(mockFontSizeProvider.scaleFactor).thenReturn(1.0);
    when(mockConfigService.getString('logoName', 'appTheme'))
        .thenReturn('assets/images/myBSSB-logo.png');
  });

  Widget createPersonalDataScreen({
    UserData? userData,
    bool isLoggedIn = true,
    VoidCallback? onLogout,
  }) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<ApiService>.value(value: mockApiService),
          Provider<NetworkService>.value(value: mockNetworkService),
          ChangeNotifierProvider<FontSizeProvider>.value(
              value: mockFontSizeProvider,),
          Provider<ConfigService>.value(value: mockConfigService),
        ],
        child: PersonDataScreen(
          userData,
          isLoggedIn: isLoggedIn,
          onLogout: onLogout ?? () {},
        ),
      ),
    );
  }

  group('PersonalDataScreen', () {
    testWidgets('renders correctly with user data',
        (WidgetTester tester) async {
      // Arrange
      when(mockApiService.fetchPassdaten(any)).thenAnswer(
        (_) => Future.value(null),
      );

      // Act
      await tester.pumpWidget(createPersonalDataScreen(userData: testUserData));
      await tester.pump();
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Persönliche Daten'), findsOneWidget);
    });

    testWidgets('shows loading state while fetching personal data',
        (WidgetTester tester) async {
      // Arrange
      when(mockApiService.fetchPassdaten(any)).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 100), () => null),
      );

      // Act
      await tester.pumpWidget(createPersonalDataScreen(userData: testUserData));
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
    });

    testWidgets('shows error message when fetch fails',
        (WidgetTester tester) async {
      // Arrange
      when(mockApiService.fetchPassdaten(any))
          .thenThrow(Exception('Test error'));

      // Act
      await tester.pumpWidget(createPersonalDataScreen(userData: testUserData));
      await tester.pump();
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Persönliche Daten'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('hides FABs when offline', (WidgetTester tester) async {
      // Arrange
      when(mockNetworkService.hasInternet()).thenAnswer((_) async => false);
      when(mockApiService.fetchPassdaten(any)).thenAnswer(
        (_) => Future.value(null),
      );

      // Act
      await tester.pumpWidget(createPersonalDataScreen(userData: testUserData));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Persönliche Daten'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });
}
