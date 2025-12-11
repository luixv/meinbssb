import 'package:intl/intl.dart';
import 'package:meinbssb/services/core/logger_service.dart';

/// Checks if BIC is required based on IBAN country code
/// Returns true if IBAN is not from Germany (DE)
bool isBicRequired(String iban) {
  return !iban.toUpperCase().startsWith('DE');
}

/// Extracts phone number from contact list
/// Prioritizes: type 2 (mobile private), then 6 (mobile business), then 1 (phone private), then 5 (phone business)
String extractPhoneNumber(List<Map<String, dynamic>> contacts) {
  final privatCategory = contacts.firstWhere(
    (category) => category['category'] == 'Privat',
    orElse: () => <String, dynamic>{'contacts': []},
  );
  final privateContacts = privatCategory['contacts'] as List<dynamic>;

  final businessCategory = contacts.firstWhere(
    (category) => category['category'] == 'Geschäftlich',
    orElse: () => <String, dynamic>{'contacts': []},
  );
  final businessContacts = businessCategory['contacts'] as List<dynamic>;
  
  final allContacts = [
    ...privateContacts.cast<Map<String, dynamic>>(),
    ...businessContacts.cast<Map<String, dynamic>>(),
  ];
  
  // Priority order: type 2, then 6, then 1, then 5
  final priorityOrder = [2, 6, 1, 5];
  
  for (final type in priorityOrder) {
    final contact = allContacts.firstWhere(
      (c) => c['rawKontaktTyp'] == type && (c['value'] as String).isNotEmpty,
      orElse: () => <String, dynamic>{'value': ''},
    );
    if (contact['value'] != '') {
      return contact['value'] as String;
    }
  }
  
  return '';
}

/// Extracts email from contact list
/// Prioritizes type 4 (private email), falls back to type 8 (business email)
String extractEmail(List<Map<String, dynamic>> contacts) {
  LoggerService.logInfo('Extract email from contacts: $contacts');
  final privatCategory = contacts.firstWhere(
    (category) => category['category'] == 'Privat',
    orElse: () => <String, dynamic>{'contacts': []},
  );
  final privateContacts = privatCategory['contacts'] as List<dynamic>;
  
  // First try type 4 (private email)
  var emailContact = privateContacts.cast<Map<String, dynamic>>().firstWhere(
    (contact) => contact['rawKontaktTyp'] == 4 && (contact['value'] as String).isNotEmpty,
    orElse: () => <String, dynamic>{'value': ''},
  );
  
  // If not found, try type 8 (business email)
  if (emailContact['value'] == '') {
    final businessCategory = contacts.firstWhere(
      (category) => category['category'] == 'Geschäftlich',
      orElse: () => <String, dynamic>{'contacts': []},
    );
    final businessContacts = businessCategory['contacts'] as List<dynamic>;
    emailContact = businessContacts.cast<Map<String, dynamic>>().firstWhere(
      (contact) => contact['rawKontaktTyp'] == 8 && (contact['value'] as String).isNotEmpty,
      orElse: () => <String, dynamic>{'value': ''},
    );
  }
  
  return emailContact['value'] as String;
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
