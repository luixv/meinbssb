import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/helpers/utils.dart';

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
    test('extracts phone from private mobile contact (rawKontaktTyp 1)', () {
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

    test('extracts phone from private phone contact (rawKontaktTyp 2)', () {
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

    test('prioritizes private contacts over business contacts', () {
      final contacts = <Map<String, dynamic>>[
        {
          'category': 'Privat',
          'contacts': [
            {'rawKontaktTyp': 1, 'value': '+49 111 111111'},
          ],
        },
        {
          'category': 'Geschäftlich',
          'contacts': [
            {'rawKontaktTyp': 5, 'value': '+49 222 222222'},
          ],
        },
      ];
      expect(extractPhoneNumber(contacts), '+49 111 111111');
    });

    test('falls back to business mobile (rawKontaktTyp 5) if no private phone', () {
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
            {'rawKontaktTyp': 5, 'value': '+49 333 333333'},
          ],
        },
      ];
      expect(extractPhoneNumber(contacts), '+49 333 333333');
    });

    test('falls back to business phone (rawKontaktTyp 6) if no private phone', () {
      final contacts = <Map<String, dynamic>>[
        {
          'category': 'Privat',
          'contacts': [
            {'rawKontaktTyp': 4, 'value': 'fax number'},
          ],
        },
        {
          'category': 'Geschäftlich',
          'contacts': [
            {'rawKontaktTyp': 6, 'value': '0456 789012'},
          ],
        },
      ];
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

    test('handles contacts with multiple phone numbers, picks first match', () {
      final contacts = <Map<String, dynamic>>[
        {
          'category': 'Privat',
          'contacts': [
            {'rawKontaktTyp': 1, 'value': '+49 111 111111'},
            {'rawKontaktTyp': 2, 'value': '+49 222 222222'},
          ],
        },
      ];
      expect(extractPhoneNumber(contacts), '+49 111 111111');
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
}

