import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/screens/contact_data_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import '../helpers/test_helper.dart';

@GenerateMocks([ApiService])
import 'contact_data_screen_test.mocks.dart';

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
    TestHelper.setupMocks();
  });

  Widget createContactDataScreen({
    UserData? userData,
    bool isLoggedIn = true,
    VoidCallback? onLogout,
  }) {
    return TestHelper.createTestApp(
      home: ContactDataScreen(
        userData,
        isLoggedIn: isLoggedIn,
        onLogout: onLogout ?? () {},
      ),
    );
  }

  group('ContactDataScreen', () {
    testWidgets('renders correctly with user data',
        (WidgetTester tester) async {
      // Arrange
      when(mockApiService.fetchKontakte(any)).thenAnswer(
        (_) => Future.value([]),
      );

      // Act
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pump(); // First pump to build the widget
      await tester
          .pumpAndSettle(); // Wait for all animations and async operations

      // Assert
      expect(find.text('Kontaktdaten'), findsOneWidget);
    });

    testWidgets('shows loading state while fetching contacts',
        (WidgetTester tester) async {
      // Arrange
      when(mockApiService.fetchKontakte(any)).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 100), () => []),
      );

      // Act
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pump(); // First pump to build the widget

      // Assert - should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for the delayed future to complete
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
    });

    testWidgets('shows error message when fetch fails',
        (WidgetTester tester) async {
      // Arrange
      when(mockApiService.fetchKontakte(any))
          .thenThrow(Exception('Test error'));

      // Act
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pump(); // First pump to build the widget
      await tester
          .pumpAndSettle(); // Wait for all animations and async operations

      // Assert
      expect(find.text('Kontaktdaten'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('add contact button is present', (WidgetTester tester) async {
      // Arrange
      when(mockApiService.fetchKontakte(any)).thenAnswer(
        (_) => Future.value([]),
      );

      // Act
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pump(); // First pump to build the widget
      await tester
          .pumpAndSettle(); // Wait for all animations and async operations

      // Assert - should find the floating action button with add icon
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
