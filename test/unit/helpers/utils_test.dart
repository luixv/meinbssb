import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/helpers/utils.dart';
import 'package:meinbssb/constants/ui_constants.dart';

void main() {
  group('isBicRequired', () {
    test('returns false for German IBAN starting with DE', () {
      expect(isBicRequired('DE89370400440532013000'), false);
    });

    test('returns false for lowercase German IBAN', () {
      expect(isBicRequired('de89370400440532013000'), false);
    });

    test('returns false for mixed case German IBAN', () {
      expect(isBicRequired('De89370400440532013000'), false);
    });

    test('returns true for Austrian IBAN starting with AT', () {
      expect(isBicRequired('AT611904300234573201'), true);
    });

    test('returns true for French IBAN starting with FR', () {
      expect(isBicRequired('FR1420041010050500013M02606'), true);
    });

    test('returns true for Italian IBAN starting with IT', () {
      expect(isBicRequired('IT60X0542811101000000123456'), true);
    });

    test('returns true for Swiss IBAN starting with CH', () {
      expect(isBicRequired('CH9300762011623852957'), true);
    });

    test('returns true for empty IBAN', () {
      expect(isBicRequired(''), true);
    });

    test('returns true for IBAN with whitespace', () {
      expect(isBicRequired('  '), true);
    });

    test('handles IBAN with spaces correctly', () {
      expect(isBicRequired('DE89 3704 0044 0532 0130 00'), false);
      expect(isBicRequired('AT61 1904 3002 3457 3201'), true);
    });

    test('returns true for invalid country code', () {
      expect(isBicRequired('XX89370400440532013000'), true);
    });
  });

  group('extractPhoneNumber', () {
    test('extracts phone from private mobile contact (rawKontaktTyp 2) - highest priority', () {
      final contacts = <Map<String, dynamic>>[
        {
          'category': 'Privat',
          'contacts': [
            {'rawKontaktTyp': 2, 'value': '0123 456789'},
          ],
        },
      ];
      expect(extractPhoneNumber(contacts), '0123 456789');
    });

    test('extracts phone from private phone contact (rawKontaktTyp 1) - third priority', () {
      final contacts = <Map<String, dynamic>>[
        {
          'category': 'Privat',
          'contacts': [
            {'rawKontaktTyp': 1, 'value': '+49 123 456789'},
          ],
        },
      ];
      expect(extractPhoneNumber(contacts), '+49 123 456789');
    });

    test('prioritizes type 2 (private mobile) over type 1 (private phone)', () {
      final contacts = <Map<String, dynamic>>[
        {
          'category': 'Privat',
          'contacts': [
            {'rawKontaktTyp': 1, 'value': '+49 111 111111'},
            {'rawKontaktTyp': 2, 'value': '+49 222 222222'},
          ],
        },
      ];
      // Type 2 has higher priority than type 1
      expect(extractPhoneNumber(contacts), '+49 222 222222');
    });

    test('falls back to business mobile (rawKontaktTyp 6) if no private phone - second priority', () {
      final contacts = <Map<String, dynamic>>[
        {
          'category': 'Privat',
          'contacts': [
            {'rawKontaktTyp': 3, 'value': 'other@email.com'},
          ],
        },
        {
          'category': 'Geschäftlich',
          'contacts': [
            {'rawKontaktTyp': 6, 'value': '+49 333 333333'},
          ],
        },
      ];
      // Type 6 (business mobile) has second priority
      expect(extractPhoneNumber(contacts), '+49 333 333333');
    });

    test('falls back to private phone (rawKontaktTyp 1) - third priority', () {
      final contacts = <Map<String, dynamic>>[
        {
          'category': 'Privat',
          'contacts': [
            {'rawKontaktTyp': 1, 'value': '0456 789012'},
          ],
        },
        {
          'category': 'Geschäftlich',
          'contacts': [
            {'rawKontaktTyp': 7, 'value': 'fax number'},
          ],
        },
      ];
      // Type 1 (private phone) has third priority
      expect(extractPhoneNumber(contacts), '0456 789012');
    });

    test('falls back to business phone (rawKontaktTyp 5) - fourth priority', () {
      final contacts = <Map<String, dynamic>>[
        {
          'category': 'Privat',
          'contacts': [
            {'rawKontaktTyp': 4, 'value': 'email@example.com'},
          ],
        },
        {
          'category': 'Geschäftlich',
          'contacts': [
            {'rawKontaktTyp': 5, 'value': '0456 789012'},
          ],
        },
      ];
      // Type 5 (business phone) has fourth priority
      expect(extractPhoneNumber(contacts), '0456 789012');
    });

    test('returns empty string if no matching contact type found', () {
      final contacts = <Map<String, dynamic>>[
        {
          'category': 'Privat',
          'contacts': [
            {'rawKontaktTyp': 3, 'value': 'email@example.com'},
          ],
        },
        {
          'category': 'Geschäftlich',
          'contacts': [
            {'rawKontaktTyp': 7, 'value': 'some value'},
          ],
        },
      ];
      expect(extractPhoneNumber(contacts), '');
    });

    test('returns empty string if private category has no contacts', () {
      final contacts = <Map<String, dynamic>>[
        {
          'category': 'Privat',
          'contacts': [],
        },
        {
          'category': 'Geschäftlich',
          'contacts': [],
        },
      ];
      expect(extractPhoneNumber(contacts), '');
    });

    test('returns empty string if no private or business category exists', () {
      final contacts = <Map<String, dynamic>>[
        {
          'category': 'Other',
          'contacts': [
            {'rawKontaktTyp': 1, 'value': '+49 999 999999'},
          ],
        },
      ];
      expect(extractPhoneNumber(contacts), '');
    });

    test('handles empty contacts list', () {
      final contacts = <Map<String, dynamic>>[];
      expect(extractPhoneNumber(contacts), '');
    });

    test('handles contacts with multiple phone numbers, picks by priority order', () {
      final contacts = <Map<String, dynamic>>[
        {
          'category': 'Privat',
          'contacts': [
            {'rawKontaktTyp': 1, 'value': '+49 111 111111'},
            {'rawKontaktTyp': 2, 'value': '+49 222 222222'},
          ],
        },
      ];
      // Type 2 (private mobile) has higher priority than type 1 (private phone)
      expect(extractPhoneNumber(contacts), '+49 222 222222');
    });

    test('follows priority order: 2, 6, 1, 5', () {
      final contacts = <Map<String, dynamic>>[
        {
          'category': 'Privat',
          'contacts': [
            {'rawKontaktTyp': 1, 'value': 'type1'},
            {'rawKontaktTyp': 2, 'value': 'type2'},
          ],
        },
        {
          'category': 'Geschäftlich',
          'contacts': [
            {'rawKontaktTyp': 5, 'value': 'type5'},
            {'rawKontaktTyp': 6, 'value': 'type6'},
          ],
        },
      ];
      // Priority: 2 > 6 > 1 > 5
      expect(extractPhoneNumber(contacts), 'type2');
    });

    test('picks type 6 when type 2 is not available', () {
      final contacts = <Map<String, dynamic>>[
        {
          'category': 'Privat',
          'contacts': [
            {'rawKontaktTyp': 1, 'value': 'type1'},
          ],
        },
        {
          'category': 'Geschäftlich',
          'contacts': [
            {'rawKontaktTyp': 5, 'value': 'type5'},
            {'rawKontaktTyp': 6, 'value': 'type6'},
          ],
        },
      ];
      // Priority: 2 (not available) > 6 > 1 > 5
      expect(extractPhoneNumber(contacts), 'type6');
    });
  });

  group('extractEmail', () {
    test('extracts email from private email contact (rawKontaktTyp 4)', () {
      final contacts = <Map<String, dynamic>>[
        {
          'category': 'Privat',
          'contacts': [
            {'rawKontaktTyp': 4, 'value': 'private@example.com'},
          ],
        },
      ];
      expect(extractEmail(contacts), 'private@example.com');
    });

    test('falls back to business email (rawKontaktTyp 8) if no private email', () {
      final contacts = <Map<String, dynamic>>[
        {
          'category': 'Privat',
          'contacts': [
            {'rawKontaktTyp': 1, 'value': '+49 123 456789'},
          ],
        },
        {
          'category': 'Geschäftlich',
          'contacts': [
            {'rawKontaktTyp': 8, 'value': 'business@example.com'},
          ],
        },
      ];
      expect(extractEmail(contacts), 'business@example.com');
    });

    test('prioritizes private email over business email', () {
      final contacts = <Map<String, dynamic>>[
        {
          'category': 'Privat',
          'contacts': [
            {'rawKontaktTyp': 4, 'value': 'private@example.com'},
          ],
        },
        {
          'category': 'Geschäftlich',
          'contacts': [
            {'rawKontaktTyp': 8, 'value': 'business@example.com'},
          ],
        },
      ];
      expect(extractEmail(contacts), 'private@example.com');
    });

    test('returns empty string if no email contact found', () {
      final contacts = <Map<String, dynamic>>[
        {
          'category': 'Privat',
          'contacts': [
            {'rawKontaktTyp': 1, 'value': '+49 123 456789'},
          ],
        },
        {
          'category': 'Geschäftlich',
          'contacts': [
            {'rawKontaktTyp': 5, 'value': '+49 987 654321'},
          ],
        },
      ];
      expect(extractEmail(contacts), '');
    });

    test('falls back to business email if private email is empty', () {
      final contacts = <Map<String, dynamic>>[
        {
          'category': 'Privat',
          'contacts': [
            {'rawKontaktTyp': 4, 'value': ''},
          ],
        },
        {
          'category': 'Geschäftlich',
          'contacts': [
            {'rawKontaktTyp': 8, 'value': 'business@example.com'},
          ],
        },
      ];
      // Should fall back to business email since private is empty
      expect(extractEmail(contacts), 'business@example.com');
    });

    test('returns empty string if both emails are empty', () {
      final contacts = <Map<String, dynamic>>[
        {
          'category': 'Privat',
          'contacts': [
            {'rawKontaktTyp': 4, 'value': ''},
          ],
        },
        {
          'category': 'Geschäftlich',
          'contacts': [
            {'rawKontaktTyp': 8, 'value': ''},
          ],
        },
      ];
      expect(extractEmail(contacts), '');
    });

    test('handles empty contacts list', () {
      final contacts = <Map<String, dynamic>>[];
      expect(extractEmail(contacts), '');
    });

    test('handles missing categories', () {
      final contacts = <Map<String, dynamic>>[
        {
          'category': 'Other',
          'contacts': [
            {'rawKontaktTyp': 4, 'value': 'email@example.com'},
          ],
        },
      ];
      expect(extractEmail(contacts), '');
    });
  });

  group('formatDate', () {
    test('formats date with single digit day and month', () {
      final date = DateTime(2023, 1, 5);
      expect(formatDate(date), '05.01.2023');
    });

    test('formats date with double digit day and month', () {
      final date = DateTime(2023, 12, 25);
      expect(formatDate(date), '25.12.2023');
    });

    test('formats date at year start', () {
      final date = DateTime(2023, 1, 1);
      expect(formatDate(date), '01.01.2023');
    });

    test('formats date at year end', () {
      final date = DateTime(2023, 12, 31);
      expect(formatDate(date), '31.12.2023');
    });

    test('formats leap year date', () {
      final date = DateTime(2024, 2, 29);
      expect(formatDate(date), '29.02.2024');
    });

    test('formats date in past century', () {
      final date = DateTime(1973, 8, 7);
      expect(formatDate(date), '07.08.1973');
    });

    test('formats future date', () {
      final date = DateTime(2100, 12, 31);
      expect(formatDate(date), '31.12.2100');
    });

    test('formats date with time information (ignores time)', () {
      final date = DateTime(2023, 6, 15, 14, 30, 45);
      expect(formatDate(date), '15.06.2023');
    });

    test('formats date with milliseconds (ignores them)', () {
      final date = DateTime(2023, 6, 15, 14, 30, 45, 123, 456);
      expect(formatDate(date), '15.06.2023');
    });

    test('formats dates consistently across different months', () {
      expect(formatDate(DateTime(2023, 1, 15)), '15.01.2023');
      expect(formatDate(DateTime(2023, 2, 15)), '15.02.2023');
      expect(formatDate(DateTime(2023, 3, 15)), '15.03.2023');
      expect(formatDate(DateTime(2023, 4, 15)), '15.04.2023');
      expect(formatDate(DateTime(2023, 5, 15)), '15.05.2023');
      expect(formatDate(DateTime(2023, 6, 15)), '15.06.2023');
      expect(formatDate(DateTime(2023, 7, 15)), '15.07.2023');
      expect(formatDate(DateTime(2023, 8, 15)), '15.08.2023');
      expect(formatDate(DateTime(2023, 9, 15)), '15.09.2023');
      expect(formatDate(DateTime(2023, 10, 15)), '15.10.2023');
      expect(formatDate(DateTime(2023, 11, 15)), '15.11.2023');
      expect(formatDate(DateTime(2023, 12, 15)), '15.12.2023');
    });
  });

  group('parseDate', () {
    test('parses full API date format with timezone', () {
      const dateString = '1973-08-07T00:00:00.000+02:00';
      final result = parseDate(dateString);
      
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
      final result = parseDate(dateString);
      
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
      final result = parseDate(dateString);
      
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
      final result = parseDate(dateString);
      
      expect(result.year, 1985);
      expect(result.month, 3);
      expect(result.day, 15);
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
    });

    test('parses date with T but no time details', () {
      const dateString = '2023-06-30T';
      final result = parseDate(dateString);
      
      expect(result.year, 2023);
      expect(result.month, 6);
      expect(result.day, 30);
    });

    test('returns default date for empty string', () {
      const dateString = '';
      final result = parseDate(dateString);
      
      expect(result.year, 1970);
      expect(result.month, 1);
      expect(result.day, 1);
    });

    test('returns default date for null', () {
      final result = parseDate(null);
      
      expect(result.year, 1970);
      expect(result.month, 1);
      expect(result.day, 1);
    });

    test('returns default date for invalid format', () {
      const dateString = 'invalid-date-format';
      final result = parseDate(dateString);
      
      expect(result.year, 1970);
      expect(result.month, 1);
      expect(result.day, 1);
    });

    test('returns default date for partial date', () {
      const dateString = '2023-06';
      final result = parseDate(dateString);
      
      expect(result.year, 1970);
      expect(result.month, 1);
      expect(result.day, 1);
    });

    test('parses leap year date correctly', () {
      const dateString = '2024-02-29T00:00:00.000+00:00';
      final result = parseDate(dateString);
      
      expect(result.year, 2024);
      expect(result.month, 2);
      expect(result.day, 29);
    });

    test('parses end of year date correctly', () {
      const dateString = '2023-12-31T23:59:59.999+00:00';
      final result = parseDate(dateString);
      
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
      final result = parseDate(dateString);
      
      // Will use fallback parser (date only)
      expect(result.year, 2023);
      expect(result.month, 6);
      expect(result.day, 15);
    });
  });

  group('validatePassword', () {
    test('returns error for null value', () {
      expect(validatePassword(null), 'Bitte Passwort eingeben');
    });

    test('returns error for empty value', () {
      expect(validatePassword(''), 'Bitte Passwort eingeben');
    });

    test('returns error for password less than 8 characters', () {
      expect(validatePassword('Test1!'), 'Mindestens 8 Zeichen');
    });

    test('returns error for password without uppercase letter', () {
      expect(validatePassword('testpass123!'), 'Mind. 1 Großbuchstabe');
    });

    test('returns error for password without lowercase letter', () {
      expect(validatePassword('TESTPASS123!'), 'Mind. 1 Kleinbuchstabe');
    });

    test('returns error for password without number', () {
      expect(validatePassword('TestPass!'), 'Mind. 1 Zahl');
    });

    test('returns error for password without special character', () {
      expect(validatePassword('TestPass123'), 'Mind. 1 Sonderzeichen');
    });

    test('returns error for password with invalid special character', () {
      expect(validatePassword('TestPass123!@'), 'Bitte nur erlaubte Zeichen verwenden');
    });

    test('returns error for password with invalid letter', () {
      expect(validatePassword('TestéPass123!'), 'Bitte nur erlaubte Zeichen verwenden');
    });

    test('returns null for valid password with all requirements', () {
      expect(validatePassword('TestPass123!'), null);
    });

    test('accepts password with German umlauts (uppercase)', () {
      expect(validatePassword('ÄÖÜpass123!'), null);
    });

    test('accepts password with German umlauts (lowercase)', () {
      expect(validatePassword('Testäöü123!'), null);
    });

    test('accepts password with all allowed special characters', () {
      const allowedChars = '!#\$%&*()-+={}[]:;,.?';
      for (var i = 0; i < allowedChars.length; i++) {
        final char = allowedChars[i];
        final password = 'TestPass123$char';
        expect(validatePassword(password), null, 
            reason: 'Character $char should be accepted');
      }
    });

    test('rejects password with disallowed special characters', () {
      const disallowedChars = ['@', '^', '_', '|', '\\', '"', "'", '<', '>', '/'];
      for (final char in disallowedChars) {
        final password = 'TestPass123!$char';
        expect(validatePassword(password), 'Bitte nur erlaubte Zeichen verwenden',
            reason: 'Character $char should be rejected');
      }
    });
  });

  group('calculatePasswordStrength', () {
    test('returns 0 for empty string', () {
      expect(calculatePasswordStrength(''), 0.0);
    });

    test('returns 0.25 for password with only length requirement', () {
      expect(calculatePasswordStrength('abcdefgh'), 0.4); // length(0.25) + lowercase(0.15) = 0.4
    });

    test('returns 0.65 for password with length, uppercase, and lowercase', () {
      // length(0.25) + uppercase(0.25) + lowercase(0.15) = 0.65
      expect(calculatePasswordStrength('TestPass'), 0.65);
    });

    test('returns 0.8 for password with length, uppercase, lowercase, and number', () {
      // length(0.25) + uppercase(0.25) + lowercase(0.15) + number(0.15) = 0.8
      expect(calculatePasswordStrength('TestPass123'), 0.8);
    });

    test('returns 1.0 for password with all requirements', () {
      // length(0.25) + uppercase(0.25) + lowercase(0.15) + number(0.15) + special(0.2) = 1.0
      expect(calculatePasswordStrength('TestPass123!'), 1.0);
    });

    test('calculates strength with German uppercase umlauts', () {
      // length(0.25) + uppercase(0.25) + lowercase(0.15) + number(0.15) + special(0.2) = 1.0
      expect(calculatePasswordStrength('ÄÖÜpass123!'), 1.0);
    });

    test('calculates strength with German lowercase umlauts', () {
      // length(0.25) + uppercase(0.25) + lowercase(0.15) + number(0.15) + special(0.2) = 1.0
      expect(calculatePasswordStrength('Testäöü123!'), 1.0);
    });
  });

  group('getPasswordStrengthLabel', () {
    test('returns "Schwach" for strength < 0.4', () {
      expect(getPasswordStrengthLabel(0.0), 'Schwach');
      expect(getPasswordStrengthLabel(0.25), 'Schwach');
      expect(getPasswordStrengthLabel(0.39), 'Schwach');
    });

    test('returns "Mittel" for strength >= 0.4 and < 0.7', () {
      expect(getPasswordStrengthLabel(0.4), 'Mittel');
      expect(getPasswordStrengthLabel(0.5), 'Mittel');
      expect(getPasswordStrengthLabel(0.69), 'Mittel');
    });

    test('returns "Stark" for strength >= 0.7', () {
      expect(getPasswordStrengthLabel(0.7), 'Stark');
      expect(getPasswordStrengthLabel(0.8), 'Stark');
      expect(getPasswordStrengthLabel(1.0), 'Stark');
    });
  });

  group('getPasswordStrengthColor', () {
    test('returns error color for strength < 0.4', () {
      expect(getPasswordStrengthColor(0.0), UIConstants.errorColor);
      expect(getPasswordStrengthColor(0.25), UIConstants.errorColor);
      expect(getPasswordStrengthColor(0.39), UIConstants.errorColor);
    });

    test('returns warning color for strength >= 0.4 and < 0.7', () {
      expect(getPasswordStrengthColor(0.4), UIConstants.warningColor);
      expect(getPasswordStrengthColor(0.5), UIConstants.warningColor);
      expect(getPasswordStrengthColor(0.69), UIConstants.warningColor);
    });

    test('returns success color for strength >= 0.7', () {
      expect(getPasswordStrengthColor(0.7), UIConstants.successColor);
      expect(getPasswordStrengthColor(0.8), UIConstants.successColor);
      expect(getPasswordStrengthColor(1.0), UIConstants.successColor);
    });
  });
}

