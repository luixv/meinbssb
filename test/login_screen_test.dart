import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/login_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:provider/provider.dart';

class MockApiService extends ApiService {
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (email == 'test@test.com' && password == 'password') {
      return {'ResultType': 1, 'PersonID': 123};
    }
    return {'ResultType': 0, 'ResultMessage': 'Invalid credentials'};
  }

  @override
  Future<Map<String, dynamic>> fetchPassdaten(int personId) async {
    return {'dummy': 'data'};
  }
}

void main() {
  testWidgets('LoginScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<ApiService>(
          create: (_) => MockApiService(),
          child: LoginScreen(
            onLoginSuccess: (userData) {},
          ),
        ),
      ),
    );

    expect(find.text('Hier anmelden'), findsOneWidget);
    expect(find.byKey(const Key('usernameField')), findsOneWidget);
    expect(find.byKey(const Key('passwordField')), findsOneWidget);
    expect(find.text('Anmelden'), findsOneWidget);
  });

  testWidgets('Can toggle password visibility', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<ApiService>(
          create: (_) => MockApiService(),
          child: LoginScreen(
            onLoginSuccess: (userData) {},
          ),
        ),
      ),
    );

    // Password should be obscured initially
    expect(find.byType(TextField).last, findsOneWidget);
    final passwordField = tester.widget<TextField>(find.byType(TextField).last);
    expect(passwordField.obscureText, isTrue);

    // Tap the visibility icon
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    // Password should be visible
    final updatedPasswordField = tester.widget<TextField>(find.byType(TextField).last);
    expect(updatedPasswordField.obscureText, isFalse);
  });

  testWidgets('Shows error on invalid login', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<ApiService>(
          create: (_) => MockApiService(),
          child: LoginScreen(
            onLoginSuccess: (userData) {},
          ),
        ),
      ),
    );

    // Invalid credentials
    await tester.enterText(find.byKey(const Key('usernameField')), 'wrong@test.com');
    await tester.enterText(find.byKey(const Key('passwordField')), 'wrong');
    await tester.tap(find.text('Anmelden'));
    await tester.pumpAndSettle();

    // Should show error message
    expect(find.text('Invalid credentials'), findsOneWidget);
  });
}