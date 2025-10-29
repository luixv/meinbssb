import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/email/email_verification_screen.dart';
import '../../helpers/test_helper.dart';

void main() {
  setUp(() {
    TestHelper.setupMocks();
  });

  Widget createEmailVerificationScreen({
    String verificationToken = 'test-token',
    String personId = '123',
  }) {
    return TestHelper.createTestApp(
      home: EmailVerificationScreen(
        verificationToken: verificationToken,
        personId: personId,
      ),
    );
  }

  group('EmailVerificationScreen', () {
    testWidgets('renders correctly and shows loading state',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createEmailVerificationScreen());
      await tester.pump(); // First pump to build the widget

      // Assert
      expect(find.text('E-Mail-Bestätigung'), findsOneWidget);
      expect(find.text('E-Mail-Adresse wird bestätigt...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('creates EmailVerificationScreen with correct parameters',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createEmailVerificationScreen(
        verificationToken: 'custom-token',
        personId: '456',
      ),);
      await tester.pump();

      // Assert - screen should render with the parameters
      expect(find.text('E-Mail-Bestätigung'), findsOneWidget);
    });
  });
}
