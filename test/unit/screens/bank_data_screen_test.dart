import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/screens/bank_data_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/models/bank_data.dart';

@GenerateMocks([ApiService])
import 'bank_data_screen_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late UserData testUserData;

  setUp(() {
    mockApiService = MockApiService();
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
  });

  Widget createBankDataScreen({
    UserData? userData,
    bool isLoggedIn = true,
    Function()? onLogout,
  }) {
    return MaterialApp(
      home: Provider<ApiService>.value(
        value: mockApiService,
        child: BaseScreenLayout(
          title: 'Bankdaten',
          userData: userData,
          isLoggedIn: isLoggedIn,
          onLogout: onLogout ?? () {},
          body: BankDataScreen(
            userData,
            webloginId: userData?.webLoginId ?? 0,
            isLoggedIn: isLoggedIn,
            onLogout: onLogout ?? () {},
          ),
        ),
      ),
    );
  }

  group('BankDataScreen', () {
    testWidgets('renders correctly with user data',
        (WidgetTester tester) async {
      // Arrange
      when(mockApiService.fetchBankData(any)).thenAnswer(
        (_) => Future.value([]),
      );

      // Act
      await tester.pumpWidget(createBankDataScreen(userData: testUserData));
      await tester.pump();
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Bankdaten'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows loading state while fetching bank data',
        (WidgetTester tester) async {
      // Arrange
      when(mockApiService.fetchBankData(any)).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 100), () => []),
      );

      // Act
      await tester.pumpWidget(createBankDataScreen(userData: testUserData));
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
    });

    testWidgets('shows error message when fetch fails',
        (WidgetTester tester) async {
      // Arrange
      when(mockApiService.fetchBankData(any))
          .thenThrow(Exception('Test error'));

      // Act
      await tester.pumpWidget(createBankDataScreen(userData: testUserData));
      await tester.pump();
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Bankdaten'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('displays bank data when available',
        (WidgetTester tester) async {
      // Arrange
      final bankData = BankData(
        id: 1,
        webloginId: testUserData.webLoginId,
        kontoinhaber: 'Test User',
        iban: 'DE89370400440532013000',
        bic: 'DEUTDEBBXXX',
      );
      when(mockApiService.fetchBankData(any)).thenAnswer(
        (_) => Future.value([bankData]),
      );

      // Act
      await tester.pumpWidget(createBankDataScreen(userData: testUserData));
      await tester.pump();
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Bankdaten'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('DE89370400440532013000'), findsOneWidget);
      expect(find.text('DEUTDEBBXXX'), findsOneWidget);
    });
  });
}
