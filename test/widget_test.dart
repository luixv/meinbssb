import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/main.dart';
import 'package:meinbssb/screens/login_screen.dart'; 

void main() {
  testWidgets('Login screen loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the login screen is displayed.
    expect(find.byType(LoginScreen), findsOneWidget);

    // I might add more specific tests for your login screen here,
    // such as checking for specific widgets or input fields.
    // For example:
    expect(find.byKey(const Key('usernameField')), findsOneWidget);
    expect(find.byKey(const Key('passwordField')), findsOneWidget);
  });
}