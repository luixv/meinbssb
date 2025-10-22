import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'logger_service.dart';

class CalendarService {
  /// Generates an .ics calendar file for a training event
  Future<String> generateIcsFile({
    required String eventTitle,
    required DateTime eventDate,
    required String location,
    required String description,
    required String organizerEmail,
  }) async {
    final startDateTime = eventDate;
    final endDateTime = eventDate.add(
      const Duration(hours: 8),
    ); // Default 8-hour duration

    final icsContent = '''BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//BSSB//Mein BSSB//DE
CALSCALE:GREGORIAN
METHOD:PUBLISH
BEGIN:VEVENT
UID:${generateUID(eventTitle, eventDate)}
DTSTART:${formatDateTime(startDateTime)}
DTEND:${formatDateTime(endDateTime)}
SUMMARY:${escapeText(eventTitle)}
DESCRIPTION:${escapeText(description)}
LOCATION:${escapeText(location)}
ORGANIZER:MAILTO:$organizerEmail
STATUS:CONFIRMED
SEQUENCE:0
END:VEVENT
END:VCALENDAR''';

    return icsContent;
  }

  /// Saves the .ics content to a file and returns a data URI for email compatibility
  Future<String> saveIcsFile({
    required String icsContent,
    required String fileName,
  }) async {
    try {
      // Always return a data URI for email compatibility
      // This works across all platforms and email clients
      final encodedContent = base64Encode(utf8.encode(icsContent));
      final dataUri = 'data:text/calendar;charset=utf8;base64,$encodedContent';

      // Optionally save to file for non-web platforms (for local access)
      if (!kIsWeb) {
        try {
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/$fileName');
          await file.writeAsString(icsContent);
          LoggerService.logInfo('ICS file also saved locally to: ${file.path}');
        } catch (e) {
          LoggerService.logWarning('Could not save ICS file locally: $e');
        }
      }

      return dataUri;
    } catch (e) {
      LoggerService.logError('Error creating ICS data URI: $e');
      rethrow;
    }
  }

  /// Generates a calendar link for the training event
  Future<String> generateCalendarLink({
    required String eventTitle,
    required DateTime eventDate,
    required String location,
    required String description,
    required String organizerEmail,
  }) async {
    final icsContent = await generateIcsFile(
      eventTitle: eventTitle,
      eventDate: eventDate,
      location: location,
      description: description,
      organizerEmail: organizerEmail,
    );

    final fileName =
        '${sanitizeFileName(eventTitle)}_${formatDateForFileName(eventDate)}.ics';
    return await saveIcsFile(icsContent: icsContent, fileName: fileName);
  }

  /// Generates a unique identifier for the event
  String generateUID(String eventTitle, DateTime eventDate) {
    final timestamp = eventDate.millisecondsSinceEpoch;
    final titleHash = eventTitle.hashCode;
    return '${timestamp}_$titleHash@bssb.de';
  }

  /// Formats DateTime to iCalendar format (YYYYMMDDTHHMMSSZ)
  String formatDateTime(DateTime dateTime) {
    final utc = dateTime;
    return '${utc.year.toString().padLeft(4, '0')}'
        '${utc.month.toString().padLeft(2, '0')}'
        '${utc.day.toString().padLeft(2, '0')}'
        'T'
        '${utc.hour.toString().padLeft(2, '0')}'
        '${utc.minute.toString().padLeft(2, '0')}'
        '${utc.second.toString().padLeft(2, '0')}'
        'Z';
  }

  /// Escapes text for iCalendar format
  String escapeText(String text) {
    return text
        .replaceAll('\\', '\\\\')
        .replaceAll(',', '\\,')
        .replaceAll(';', '\\;')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r');
  }

  /// Sanitizes filename for file system compatibility
  String sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(' ', '_')
        .toLowerCase();
  }

  /// Formats date for filename (YYYY-MM-DD)
  String formatDateForFileName(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
