import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/email_verification_screen_accessible.dart';
import '../helpers/test_helper.dart';

void main() {
  setUp(() {
    TestHelper.setupMocks();
  });

  group('EmailVerificationScreen', () {
    testWidgets('widget can be constructed with required parameters',
        (WidgetTester tester) async {
      // Test that the widget can be constructed without throwing
      expect(
        () {
          const EmailVerificationScreenAccessible(
            verificationToken: 'test-token',
            personId: '123',
          );
        },
        returnsNormally,
      );
    });

    testWidgets('widget accepts different parameter values',
        (WidgetTester tester) async {
      // Test with custom parameters
      expect(
        () {
          const EmailVerificationScreenAccessible(
            verificationToken: 'custom-token',
            personId: '456',
          );
        },
        returnsNormally,
      );
    });
  });
}
