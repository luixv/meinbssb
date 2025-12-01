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

DateTime parseDate(dynamic value) {
  if (value is! String || value.isEmpty) {
    return DateTime(1970, 1, 1);
  }

  // Remove timezone offset like +01:00 or -02:00 or Z
  final cleaned = value.replaceAll(RegExp(r'(Z|[+-]\d{2}:\d{2})$'), '');

  try {
    return DateTime.parse(cleaned);
  } catch (_) {
    // Fallback: parse only yyyy-MM-dd
    try {
      final dateOnly = cleaned.split('T').first;
      return DateTime.parse(dateOnly);
    } catch (_) {
      return DateTime(1970, 1, 1);
    }
  }
}
