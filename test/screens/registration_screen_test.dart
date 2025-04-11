// test/registration_screen_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/registration_screen.dart';

void main() {
  group('Pure Validation Tests', () {
    test('Pass number validation - accepts 8 digits', () {
      final state = RegistrationScreenState();
      expect(state.validatePassNumber('12345678'), isTrue);
    });

    test('Pass number validation - rejects non-8-digit inputs', () {
      final state = RegistrationScreenState();
      expect(state.validatePassNumber('1234'), isFalse); // Too short
      expect(state.validatePassNumber('123456789'), isFalse); // Too long
      expect(state.validatePassNumber('abcdefgh'), isFalse); // Non-digits
      expect(state.validatePassNumber(''), isFalse); // Empty
    });

    test('Zip code validation', () {
      final state = RegistrationScreenState();
      expect(state.validateZipCode('12345'), isTrue);
      expect(state.validateZipCode('123'), isFalse);
    });

    test('Zip code validation - rejects non-5-digit inputs', () {
      final state = RegistrationScreenState();
      expect(state.validateZipCode('123'), isFalse); // Too short
      expect(state.validateZipCode('123456'), isFalse); // Too long
      expect(state.validateZipCode('abcde'), isFalse); // Non-digits
      expect(state.validateZipCode(''), isFalse); // Empty
    });

    test('Email validation - accepts valid emails', () {
      final state = RegistrationScreenState();
      expect(state.validateEmail('test@example.com'), isTrue);
    });

    test('Email validation - rejects invalid emails', () {
      final state = RegistrationScreenState();
      expect(state.validateEmail('plainstring'), isFalse);
      expect(state.validateEmail('missing@'), isFalse);
      expect(state.validateEmail('@domain.com'), isFalse);
      expect(state.validateEmail('mein@@domain.com'), isFalse);
      expect(state.validateEmail(''), isFalse);
    });

    test('Email validation', () {
      final state = RegistrationScreenState();
      expect(state.validateEmail('test@test.com'), isTrue);
      expect(state.validateEmail('invalid'), isFalse);
    });
  });
}