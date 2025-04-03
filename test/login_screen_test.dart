import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/login_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/email_service.dart';
import 'package:provider/provider.dart';

class MockApiService extends ApiService {
MockApiService() 
    : super(
        baseIp: 'test', 
        port: '1234',
        serverTimeout: 10, // Add this required parameter
      );
      
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

class MockEmailService extends EmailService {
  @override
  Future<Map<String, dynamic>> sendEmail({
    required String from,
    required String recipient,
    required String subject,
    String? body,
    int? emailId,
  }) async {
    return {'ResultType': 1, 'ResultMessage': 'Success'};
  }
}

void main() {
  testWidgets('LoginScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ApiService>(create: (_) => MockApiService()),
          Provider<EmailService>(create: (_) => MockEmailService()),
        ],
        child: MaterialApp(
          home: LoginScreen(
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
      MultiProvider(
        providers: [
          Provider<ApiService>(create: (_) => MockApiService()),
          Provider<EmailService>(create: (_) => MockEmailService()),
        ],
        child: MaterialApp(
          home: LoginScreen(
            onLoginSuccess: (userData) {},
          ),
        ),
      ),
    );

    expect(find.byType(TextField).last, findsOneWidget);
    final passwordField = tester.widget<TextField>(find.byType(TextField).last);
    expect(passwordField.obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    final updatedPasswordField = tester.widget<TextField>(find.byType(TextField).last);
    expect(updatedPasswordField.obscureText, isFalse);
  });

  testWidgets('Shows error on invalid login', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ApiService>(create: (_) => MockApiService()),
          Provider<EmailService>(create: (_) => MockEmailService()),
        ],
        child: MaterialApp(
          home: LoginScreen(
            onLoginSuccess: (userData) {},
          ),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('usernameField')), 'wrong@test.com');
    await tester.enterText(find.byKey(const Key('passwordField')), 'wrong');
    await tester.tap(find.text('Anmelden'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid credentials'), findsOneWidget);
  });
}