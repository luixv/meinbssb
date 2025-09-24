import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'package:meinbssb/screens/password_reset_screen.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/services/core/config_service.dart';
import '../helpers/test_helper.dart';

@GenerateMocks([AuthService, NetworkService, FontSizeProvider, ConfigService])
void main() {
  setUp(() {
    TestHelper.setupMocks();
  });

  Widget createPasswordResetScreen() {
    return TestHelper.createTestApp(
      home: PasswordResetScreen(
        apiService: TestHelper.mockApiService,
        userData: null,
        isLoggedIn: false,
        onLogout: () {},
      ),
    );
  }

  group('PasswordResetScreen', () {
    testWidgets('renders password reset form', (WidgetTester tester) async {
      await tester.pumpWidget(createPasswordResetScreen());
      await tester.pumpAndSettle();

      expect(find.text('Passwort zurücksetzen'), findsAtLeastNWidgets(1));
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Passwort zurücksetzen'), findsAtLeastNWidgets(1));
    });

    testWidgets('validates email field', (WidgetTester tester) async {
      await tester.pumpWidget(createPasswordResetScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Passwort zurücksetzen').first);
      await tester.pumpAndSettle();

      expect(
        find.text('Bitte geben Sie eine E-Mail-Adresse ein'),
        findsNothing,
      );
    });
  });
}
