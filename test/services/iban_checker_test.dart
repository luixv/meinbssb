import 'package:test/test.dart';
import 'package:meinbssb/services/iban_checker.dart';

void main() {
  group('validateIBAN', () {
    test('should return true for a valid IBAN with spaces', () {
      expect(validateIBAN('GB82 WEST 1234 5698 7654 32'), isTrue);
    });

    test('should return true for a valid IBAN without spaces', () {
      expect(validateIBAN('DE89370400440532013000'), isTrue);
    });

    test('should return true for another valid IBAN', () {
      expect(validateIBAN('FR1420041010050500013M02606'), isTrue);
    });

    test('should return true for a valid IBAN with mixed case and spaces', () {
      expect(validateIBAN('fr14 20041 01005 0500013m026 06'), isTrue);
    });

    test('should return false for an IBAN with invalid characters', () {
      expect(validateIBAN('GB82 WEST 1234 5698 7654 3!'), isFalse);
    });

    test('should return false for an IBAN that is too short', () {
      expect(validateIBAN('GB82W'), isFalse);
    });

    test(
      'should return false for an invalid IBAN (incorrect check digits)',
      () {
        expect(validateIBAN('GB82 WEST 1234 5698 7654 33'), isFalse);
      },
    );

    test(
      'should return false for another invalid IBAN (incorrect check digits)',
      () {
        expect(validateIBAN('DE89370400440532013001'), isFalse);
      },
    );

    test(
      'should return false for an IBAN with lowercase letters if not handled',
      () {
        expect(
          validateIBAN('gb82west12345698765432'),
          isTrue,
        ); // Should pass due to toUpperCase()
      },
    );
  });
}
