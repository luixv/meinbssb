import 'package:intl/intl.dart';

/// Checks if BIC is required based on IBAN country code
/// Returns true if IBAN is not from Germany (DE)
bool isBicRequired(String iban) {
  return !iban.toUpperCase().startsWith('DE');
}

/// Extracts phone number from contact list
/// Prioritizes private contacts (mobile/phone), falls back to business contacts
String extractPhoneNumber(List<Map<String, dynamic>> contacts) {
  final privateContacts =
      contacts.firstWhere(
            (category) => category['category'] == 'Privat',
            orElse: () => <String, dynamic>{'contacts': []},
          )['contacts']
          as List<dynamic>;
  var phoneContact = privateContacts.cast<Map<String, dynamic>>().firstWhere(
    (contact) => contact['rawKontaktTyp'] == 1 || contact['rawKontaktTyp'] == 2,
    orElse: () => <String, dynamic>{'value': ''},
  );
  if (phoneContact['value'] == '') {
    final businessContacts =
        contacts.firstWhere(
              (category) => category['category'] == 'Geschäftlich',
              orElse: () => <String, dynamic>{'contacts': []},
            )['contacts']
            as List<dynamic>;
    phoneContact = businessContacts.cast<Map<String, dynamic>>().firstWhere(
      (contact) =>
          contact['rawKontaktTyp'] == 5 || contact['rawKontaktTyp'] == 6,
      orElse: () => <String, dynamic>{'value': ''},
    );
  }
  return phoneContact['value'] as String;
}

/// Formats a DateTime to German date format (dd.MM.yyyy)
String formatDate(DateTime date) {
  return DateFormat('dd.MM.yyyy').format(date);
}

/// Parses dates like "1997-03-06T00:00:00.000+01:00"
/// Ignores time and timezone completely and returns a pure date (UTC).
/// Formats a DateTime to German date format (dd.MM.yyyy)
DateTime parseDate(dynamic value) {
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
