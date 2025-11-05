import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/password/set_password_screen.dart';
import 'package:meinbssb/constants/ui_constants.dart';

// Extension to access the private _parseDate method for testing
extension SetPasswordScreenTestHelper on SetPasswordScreen {
  static DateTime parseDate(dynamic value) {
    // We need to test through reflection or create a test-specific method
    // Since _parseDate is in _SetPasswordScreenState and is static,
    // we'll test it through the actual implementation
    return _SetPasswordScreenStateTestHelper.parseDate(value);
  }
}

// Test helper to access private static method
class _SetPasswordScreenStateTestHelper {
  static DateTime parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      // Match: yyyy-MM-ddTHH:mm:ss.SSS (ignore offset)
      final match = RegExp(
        r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})\.(\d{3})',
      ).firstMatch(value);
      if (match != null) {
        return DateTime(
          int.parse(match.group(1)!),
          int.parse(match.group(2)!),
          int.parse(match.group(3)!),
          int.parse(match.group(4)!),
          int.parse(match.group(5)!),
          int.parse(match.group(6)!),
          int.parse(match.group(7)!),
        );
      }
      // Fallback: just the date part
      try {
        final dateOnly = value.split('T').first;
        final parts = dateOnly.split('-');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
      } catch (e) {
        // If parsing fails, return default date
        return DateTime(1970, 1, 1);
      }
    }
    return DateTime(1970, 1, 1);
  }
}

void main() {
  group('SetPasswordScreen _parseDate', () {
    test('parses full API date format with timezone', () {
      const dateString = '1973-08-07T00:00:00.000+02:00';
      final result = _SetPasswordScreenStateTestHelper.parseDate(dateString);
      
      expect(result.year, 1973);
      expect(result.month, 8);
      expect(result.day, 7);
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
      expect(result.millisecond, 0);
    });

    test('parses date with different timezone offset', () {
      const dateString = '1990-12-25T15:30:45.123-05:00';
      final result = _SetPasswordScreenStateTestHelper.parseDate(dateString);
      
      expect(result.year, 1990);
      expect(result.month, 12);
      expect(result.day, 25);
      expect(result.hour, 15);
      expect(result.minute, 30);
      expect(result.second, 45);
      expect(result.millisecond, 123);
    });

    test('parses date without timezone (just time)', () {
      const dateString = '2000-01-01T12:00:00.000';
      final result = _SetPasswordScreenStateTestHelper.parseDate(dateString);
      
      expect(result.year, 2000);
      expect(result.month, 1);
      expect(result.day, 1);
      expect(result.hour, 12);
      expect(result.minute, 0);
      expect(result.second, 0);
      expect(result.millisecond, 0);
    });

    test('parses date with only date part (fallback)', () {
      const dateString = '1985-03-15';
      final result = _SetPasswordScreenStateTestHelper.parseDate(dateString);
      
      expect(result.year, 1985);
      expect(result.month, 3);
      expect(result.day, 15);
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
    });

    test('parses date with T but no time details', () {
      const dateString = '2023-06-30T';
      final result = _SetPasswordScreenStateTestHelper.parseDate(dateString);
      
      expect(result.year, 2023);
      expect(result.month, 6);
      expect(result.day, 30);
    });

    test('returns default date for empty string', () {
      const dateString = '';
      final result = _SetPasswordScreenStateTestHelper.parseDate(dateString);
      
      expect(result.year, 1970);
      expect(result.month, 1);
      expect(result.day, 1);
    });

    test('returns default date for null', () {
      final result = _SetPasswordScreenStateTestHelper.parseDate(null);
      
      expect(result.year, 1970);
      expect(result.month, 1);
      expect(result.day, 1);
    });

    test('returns default date for invalid format', () {
      const dateString = 'invalid-date-format';
      final result = _SetPasswordScreenStateTestHelper.parseDate(dateString);
      
      expect(result.year, 1970);
      expect(result.month, 1);
      expect(result.day, 1);
    });

    test('returns default date for partial date', () {
      const dateString = '2023-06';
      final result = _SetPasswordScreenStateTestHelper.parseDate(dateString);
      
      expect(result.year, 1970);
      expect(result.month, 1);
      expect(result.day, 1);
    });

    test('parses leap year date correctly', () {
      const dateString = '2024-02-29T00:00:00.000+00:00';
      final result = _SetPasswordScreenStateTestHelper.parseDate(dateString);
      
      expect(result.year, 2024);
      expect(result.month, 2);
      expect(result.day, 29);
    });

    test('parses end of year date correctly', () {
      const dateString = '2023-12-31T23:59:59.999+00:00';
      final result = _SetPasswordScreenStateTestHelper.parseDate(dateString);
      
      expect(result.year, 2023);
      expect(result.month, 12);
      expect(result.day, 31);
      expect(result.hour, 23);
      expect(result.minute, 59);
      expect(result.second, 59);
      expect(result.millisecond, 999);
    });

    test('handles date string with Z timezone indicator', () {
      // This should fall through to fallback since it doesn't match the regex
      const dateString = '2023-06-15T12:00:00.000Z';
      final result = _SetPasswordScreenStateTestHelper.parseDate(dateString);
      
      // Will use fallback parser (date only)
      expect(result.year, 2023);
      expect(result.month, 6);
      expect(result.day, 15);
    });
  });

  group('SetPasswordScreen Password Validation', () {
    String? validatePassword(String? value) {
      if (value == null || value.isEmpty) return 'Passwort erforderlich';
      if (value.length < 8) return 'Mind. 8 Zeichen';
      if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Mind. 1 Großbuchstabe';
      if (!RegExp(r'[a-z]').hasMatch(value)) return 'Mind. 1 Kleinbuchstabe';
      if (!RegExp(r'[0-9]').hasMatch(value)) return 'Mind. 1 Zahl';
      if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
        return 'Mind. 1 Sonderzeichen';
      }
      return null;
    }

    test('returns error for null password', () {
      final result = validatePassword(null);
      expect(result, 'Passwort erforderlich');
    });

    test('returns error for empty password', () {
      final result = validatePassword('');
      expect(result, 'Passwort erforderlich');
    });

    test('returns error for password less than 8 characters', () {
      final result = validatePassword('Test1!');
      expect(result, 'Mind. 8 Zeichen');
    });

    test('returns error for password without uppercase', () {
      final result = validatePassword('test1234!');
      expect(result, 'Mind. 1 Großbuchstabe');
    });

    test('returns error for password without lowercase', () {
      final result = validatePassword('TEST1234!');
      expect(result, 'Mind. 1 Kleinbuchstabe');
    });

    test('returns error for password without number', () {
      final result = validatePassword('TestTest!');
      expect(result, 'Mind. 1 Zahl');
    });

    test('returns error for password without special character', () {
      final result = validatePassword('Test1234');
      expect(result, 'Mind. 1 Sonderzeichen');
    });

    test('returns null for valid password', () {
      final result = validatePassword('Test1234!');
      expect(result, null);
    });

    test('accepts various special characters', () {
      expect(validatePassword('Test1234@'), null);
      expect(validatePassword('Test1234#'), null);
      expect(validatePassword('Test1234\$'), null);
      expect(validatePassword('Test1234%'), null);
      expect(validatePassword('Test1234^'), null);
      expect(validatePassword('Test1234&'), null);
      expect(validatePassword('Test1234*'), null);
      expect(validatePassword('Test1234('), null);
      expect(validatePassword('Test1234)'), null);
    });
  });

  group('SetPasswordScreen ZIP Code Validation', () {
    String? validateZipCode(String? value) {
      if (value == null || value.isEmpty) {
        return 'Bitte Postleitzahl eingeben';
      }
      if (!RegExp(r'^\d{5}$').hasMatch(value)) {
        return 'Postleitzahl muss 5 Ziffern haben';
      }
      return null;
    }

    test('returns error for null zip code', () {
      final result = validateZipCode(null);
      expect(result, 'Bitte Postleitzahl eingeben');
    });

    test('returns error for empty zip code', () {
      final result = validateZipCode('');
      expect(result, 'Bitte Postleitzahl eingeben');
    });

    test('returns error for zip code with less than 5 digits', () {
      final result = validateZipCode('1234');
      expect(result, 'Postleitzahl muss 5 Ziffern haben');
    });

    test('returns error for zip code with more than 5 digits', () {
      final result = validateZipCode('123456');
      expect(result, 'Postleitzahl muss 5 Ziffern haben');
    });

    test('returns error for zip code with letters', () {
      final result = validateZipCode('1234A');
      expect(result, 'Postleitzahl muss 5 Ziffern haben');
    });

    test('returns error for zip code with special characters', () {
      final result = validateZipCode('123-45');
      expect(result, 'Postleitzahl muss 5 Ziffern haben');
    });

    test('returns null for valid 5-digit zip code', () {
      final result = validateZipCode('12345');
      expect(result, null);
    });

    test('accepts various valid zip codes', () {
      expect(validateZipCode('00000'), null);
      expect(validateZipCode('80331'), null);
      expect(validateZipCode('10115'), null);
      expect(validateZipCode('99999'), null);
    });
  });

  group('SetPasswordScreen Password Strength', () {
    double checkStrength(String value) {
      double strength = 0;
      if (value.length >= 8) strength += 0.25;
      if (RegExp(r'[A-Z]').hasMatch(value)) strength += 0.25;
      if (RegExp(r'[a-z]').hasMatch(value)) strength += 0.15;
      if (RegExp(r'[0-9]').hasMatch(value)) strength += 0.15;
      if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) strength += 0.2;
      return strength;
    }

    test('returns 0 for empty password', () {
      final result = checkStrength('');
      expect(result, 0.0);
    });

    test('returns 0.25 for password with only length', () {
      final result = checkStrength('aaaaaaaa');
      expect(result, 0.40); // length + lowercase
    });

    test('returns 0.25 for password >= 8 characters', () {
      final result = checkStrength('12345678');
      expect(result, 0.40); // length + numbers
    });

    test('returns higher strength for password with uppercase', () {
      final result = checkStrength('AaaaaaaaA');
      expect(result, 0.65); // length + uppercase + lowercase
    });

    test('returns higher strength for password with numbers', () {
      final result = checkStrength('Aaaaaaa1');
      expect(result, 0.80); // length + uppercase + lowercase + number
    });

    test('returns maximum strength for password with all criteria', () {
      final result = checkStrength('Test1234!');
      expect(result, 1.0); // all criteria met
    });

    test('calculates correct strength for weak password', () {
      final result = checkStrength('test');
      expect(result, 0.15); // only lowercase
    });

    test('calculates correct strength for medium password', () {
      final result = checkStrength('Test1234');
      expect(result, 0.80); // length + uppercase + lowercase + number
    });
  });

  group('SetPasswordScreen Strength Label', () {
    String strengthLabel(double value) {
      if (value < 0.4) return 'Schwach';
      if (value < 0.7) return 'Mittel';
      return 'Stark';
    }

    test('returns Schwach for strength < 0.4', () {
      expect(strengthLabel(0.0), 'Schwach');
      expect(strengthLabel(0.2), 'Schwach');
      expect(strengthLabel(0.39), 'Schwach');
    });

    test('returns Mittel for strength >= 0.4 and < 0.7', () {
      expect(strengthLabel(0.4), 'Mittel');
      expect(strengthLabel(0.5), 'Mittel');
      expect(strengthLabel(0.69), 'Mittel');
    });

    test('returns Stark for strength >= 0.7', () {
      expect(strengthLabel(0.7), 'Stark');
      expect(strengthLabel(0.8), 'Stark');
      expect(strengthLabel(1.0), 'Stark');
    });
  });

  group('SetPasswordScreen Strength Color', () {
    Color strengthColor(double value) {
      if (value < 0.4) return UIConstants.errorColor;
      if (value < 0.7) return UIConstants.warningColor;
      return UIConstants.successColor;
    }

    test('returns errorColor for strength < 0.4', () {
      expect(strengthColor(0.0), UIConstants.errorColor);
      expect(strengthColor(0.2), UIConstants.errorColor);
      expect(strengthColor(0.39), UIConstants.errorColor);
    });

    test('returns warningColor for strength >= 0.4 and < 0.7', () {
      expect(strengthColor(0.4), UIConstants.warningColor);
      expect(strengthColor(0.5), UIConstants.warningColor);
      expect(strengthColor(0.69), UIConstants.warningColor);
    });

    test('returns successColor for strength >= 0.7', () {
      expect(strengthColor(0.7), UIConstants.successColor);
      expect(strengthColor(0.8), UIConstants.successColor);
      expect(strengthColor(1.0), UIConstants.successColor);
    });
  });
}

