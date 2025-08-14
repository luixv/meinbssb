import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/services/core/calendar_service.dart';

void main() {
  group('CalendarService', () {
    late CalendarService calendarService;

    setUp(() {
      calendarService = CalendarService();
    });

    test('generateIcsFile returns valid ICS content', () async {
      const eventTitle = 'Test Event';
      final eventDate = DateTime(2025, 8, 14, 10, 0);
      const location = 'Test Location';
      const description = 'Test Description';
      const organizerEmail = 'organizer@test.com';

      final icsContent = await calendarService.generateIcsFile(
        eventTitle: eventTitle,
        eventDate: eventDate,
        location: location,
        description: description,
        organizerEmail: organizerEmail,
      );

      expect(icsContent, contains('BEGIN:VCALENDAR'));
      expect(icsContent, contains('SUMMARY:Test Event'));
      expect(icsContent, contains('DESCRIPTION:Test Description'));
      expect(icsContent, contains('LOCATION:Test Location'));
      expect(icsContent, contains('ORGANIZER:MAILTO:organizer@test.com'));
      expect(icsContent, contains('END:VCALENDAR'));
    });

    test('sanitizeFileName replaces invalid characters and spaces', () {
      const fileName = 'Test:Event/Name*With?Chars';
      final sanitized = calendarService.sanitizeFileName(fileName);
      expect(sanitized, 'test_event_name_with_chars');
    });

    test('escapeText escapes special characters', () {
      const text = 'Line1,Line2;Line3\\Line4\nLine5\rLine6';
      final escaped = calendarService.escapeText(text);
      expect(escaped, contains('\\,'));
      expect(escaped, contains('\\;'));
      expect(escaped, contains('\\\\'));
      expect(escaped, contains('\\n'));
      expect(escaped, contains('\\r'));
    });

    test('formatDateTime returns correct iCalendar format', () {
      final dateTime = DateTime.utc(2025, 8, 14, 10, 5, 30);
      final formatted = calendarService.formatDateTime(dateTime);
      expect(formatted, '20250814T100530Z');
    });

    test('formatDateForFileName returns correct format', () {
      final date = DateTime(2025, 8, 14);
      final formatted = calendarService.formatDateForFileName(date);
      expect(formatted, '2025-08-14');
    });
    test('generateUID returns unique identifier', () {
      final uid =
          calendarService.generateUID('Test Event', DateTime(2025, 8, 14));
      expect(uid, contains('@bssb.de'));
    });
  });
}
