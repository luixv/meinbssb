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
    final endDateTime = eventDate.add(const Duration(hours: 8)); // Default 8-hour duration

    final icsContent = '''BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//BSSB//Mein BSSB//DE
CALSCALE:GREGORIAN
METHOD:PUBLISH
BEGIN:VEVENT
UID:${_generateUID(eventTitle, eventDate)}
DTSTART:${_formatDateTime(startDateTime)}
DTEND:${_formatDateTime(endDateTime)}
SUMMARY:${_escapeText(eventTitle)}
DESCRIPTION:${_escapeText(description)}
LOCATION:${_escapeText(location)}
ORGANIZER:MAILTO:$organizerEmail
STATUS:CONFIRMED
SEQUENCE:0
END:VEVENT
END:VCALENDAR''';

    return icsContent;
  }

  /// Saves the .ics content to a file and returns the file path
  Future<String> saveIcsFile({
    required String icsContent,
    required String fileName,
  }) async {
    try {
      if (kIsWeb) {
        // For web, we'll return a data URI that can be used as a download link
        final encodedContent = base64Encode(utf8.encode(icsContent));
        return 'data:text/calendar;charset=utf8;base64,$encodedContent';
      } else {
        // For mobile/desktop, save to app documents directory
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(icsContent);
        LoggerService.logInfo('ICS file saved to: ${file.path}');
        return file.path;
      }
    } catch (e) {
      LoggerService.logError('Error saving ICS file: $e');
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

    final fileName = '${_sanitizeFileName(eventTitle)}_${_formatDateForFileName(eventDate)}.ics';
    return await saveIcsFile(
      icsContent: icsContent,
      fileName: fileName,
    );
  }

  /// Generates a unique identifier for the event
  String _generateUID(String eventTitle, DateTime eventDate) {
    final timestamp = eventDate.millisecondsSinceEpoch;
    final titleHash = eventTitle.hashCode;
    return '${timestamp}_$titleHash@bssb.de';
  }

  /// Formats DateTime to iCalendar format (YYYYMMDDTHHMMSSZ)
  String _formatDateTime(DateTime dateTime) {
    final utc = dateTime.toUtc();
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
  String _escapeText(String text) {
    return text
        .replaceAll('\\', '\\\\')
        .replaceAll(',', '\\,')
        .replaceAll(';', '\\;')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r');
  }

  /// Sanitizes filename for file system compatibility
  String _sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(' ', '_')
        .toLowerCase();
  }

  /// Formats date for filename (YYYY-MM-DD)
  String _formatDateForFileName(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
} 