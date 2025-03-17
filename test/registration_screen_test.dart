import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/registration_screen.dart'; // Adjust the import path as needed

void main() {
  group('RegistrationScreen Validation Tests', () {
    late RegistrationScreenState registrationScreenState;

    setUp(() {
      registrationScreenState = RegistrationScreenState();
    });

    test('Valid ZIP code should pass validation', () {
      expect(registrationScreenState.validateZipCode('12345'), true);
      expect(registrationScreenState.zipCodeError, '');
    });

    test('Invalid ZIP code (too short) should fail validation', () {
      expect(registrationScreenState.validateZipCode('1234'), false);
      expect(registrationScreenState.zipCodeError, 'Postleitzahl muss 5 Ziffern enthalten.');
    });

    test('Invalid ZIP code (too long) should fail validation', () {
      expect(registrationScreenState.validateZipCode('123456'), false);
      expect(registrationScreenState.zipCodeError, 'Postleitzahl muss 5 Ziffern enthalten.');
    });

    test('Invalid ZIP code (non-numeric) should fail validation', () {
      expect(registrationScreenState.validateZipCode('abcde'), false);
      expect(registrationScreenState.zipCodeError, 'Postleitzahl muss 5 Ziffern enthalten.');
    });

    test('Empty ZIP code should fail validation', () {
      expect(registrationScreenState.validateZipCode(''), false);
      expect(registrationScreenState.zipCodeError, 'Postleitzahl ist erforderlich.');
    });

    test('Valid Pass number should pass validation', () {
      expect(registrationScreenState.validatePassNumber('12345678'), true);
      expect(registrationScreenState.passNumberError, '');
    });

    test('Invalid Pass number (too short) should fail validation', () {
      expect(registrationScreenState.validatePassNumber('1234567'), false);
      expect(registrationScreenState.passNumberError, 'Schützenausweisnummer muss 8 Ziffern enthalten.');
    });

    test('Invalid Pass number (too long) should fail validation', () {
      expect(registrationScreenState.validatePassNumber('123456789'), false);
      expect(registrationScreenState.passNumberError, 'Schützenausweisnummer muss 8 Ziffern enthalten.');
    });

    test('Invalid Pass number (non-numeric) should fail validation', () {
      expect(registrationScreenState.validatePassNumber('abcdefgh'), false);
      expect(registrationScreenState.passNumberError, 'Schützenausweisnummer muss 8 Ziffern enthalten.');
    });

    test('Empty Pass number should fail validation', () {
      expect(registrationScreenState.validatePassNumber(''), false);
      expect(registrationScreenState.passNumberError, 'Schützenausweisnummer ist erforderlich.');
    });
  });
}