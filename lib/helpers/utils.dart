import 'package:intl/intl.dart';
import 'package:meinbssb/services/core/logger_service.dart';

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
DateTime parseDate(dynamic value) {
  if (value is! String || value.isEmpty) {
    return DateTime(1970, 1, 1);
  }

  try {
    // Use only the date part: yyyy-MM-dd
    final dateOnly = value.split('T').first; // "1997-03-06"
    final parts = dateOnly.split('-'); // ["1997", "03", "06"]

    if (parts.length == 3) {
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      LoggerService.logInfo('Dateonly: $dateOnly, Day: $day');
      // Use UTC so it never shifts when converting/localizing
      return DateTime.utc(year, month, day);
    }
  } catch (_) {
    // ignore and fall through
  }

  return DateTime(1970, 1, 1);
}
