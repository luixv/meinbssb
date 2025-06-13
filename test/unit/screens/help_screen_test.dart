import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/screens/help_screen.dart';

void main() {
  late UserData testUserData;

  setUp(() {
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

  Widget createHelpScreen({
    UserData? userData,
    bool isLoggedIn = true,
    VoidCallback? onLogout,
  }) {
    return MaterialApp(
      home: HelpScreen(
        userData: userData,
        isLoggedIn: isLoggedIn,
        onLogout: onLogout ?? () {},
      ),
    );
  }

  group('HelpScreen', () {
    testWidgets('renders correctly with user data',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createHelpScreen(userData: testUserData));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('FAQ'), findsOneWidget);
      expect(find.text('Häufig gestellte Fragen (FAQ)'), findsOneWidget);
      expect(find.text('Allgemein'), findsOneWidget);
      expect(find.text('Funktionen der App'), findsOneWidget);
      expect(find.text('Technische Fragen'), findsOneWidget);
      expect(find.text('Kontakt und Hilfe'), findsOneWidget);
    });
  });
}
