import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'package:meinbssb/screens/change_password_screen.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/services/core/font_size_provider.dart';
import 'package:meinbssb/services/core/config_service.dart';
import '../helpers/test_helper.dart';

@GenerateMocks([NetworkService, FontSizeProvider, ConfigService])
void main() {
  setUp(() {
    TestHelper.setupMocks();
  });

  Widget createChangePasswordScreen() {
    return TestHelper.createTestApp(
      home: ChangePasswordScreen(
        userData: null,
        isLoggedIn: true,
        onLogout: () {},
      ),
    );
  }

  group('ChangePasswordScreen', () {
    testWidgets('renders change password form', (WidgetTester tester) async {
      await tester.pumpWidget(createChangePasswordScreen());
      await tester.pumpAndSettle();

      expect(find.text('Neues Passwort erstellen'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('validates required fields', (WidgetTester tester) async {
      await tester.pumpWidget(createChangePasswordScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      expect(
        find.text('Bitte geben Sie Ihr aktuelles Passwort ein'),
        findsOneWidget,
      );
      expect(
        find.text('Bitte geben Sie ein Passwort ein'),
        findsOneWidget,
      );
    });
  });
}
