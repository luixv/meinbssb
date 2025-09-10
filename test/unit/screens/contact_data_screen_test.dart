import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/screens/contact_data_screen.dart';
import '../helpers/test_helper.dart';

void main() {
  // MockApiService mockApiService; // Commented out until mocks are regenerated
  // MockAuthService mockAuthService; // Commented out until mocks are regenerated
  late UserData testUserData;

  setUp(() {
    // mockApiService = MockApiService(); // Commented out until mocks are regenerated
    // mockAuthService = MockAuthService(); // Commented out until mocks are regenerated
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
      // Simple test that doesn't require mocks
      // Act
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pump(); // First pump to build the widget

      // Assert
      expect(find.text('Kontaktdaten'), findsOneWidget);
    });

    testWidgets('add contact button is present', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createContactDataScreen(userData: testUserData));
      await tester.pump(); // First pump to build the widget

      // Assert - should find the floating action button with add icon
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    // Email validation test commented out until mocks are regenerated
    // testWidgets('email validation flow works for private email', ...)
  });
}
