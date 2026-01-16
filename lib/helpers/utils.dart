import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meinbssb/services/core/logger_service.dart';
import 'package:meinbssb/constants/ui_constants.dart';

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

/// Validates password according to application rules
/// Returns null if valid, error message if invalid
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Bitte Passwort eingeben';
  if (value.length < 8) return 'Mindestens 8 Zeichen';
  // Allowed uppercase letters: A-Z, Ä, Ö, Ü
  if (!RegExp(r'[A-ZÄÖÜ]').hasMatch(value)) return 'Mind. 1 Großbuchstabe';
  // Allowed lowercase letters: a-z, ä, ö, ü
  if (!RegExp(r'[a-zäöü]').hasMatch(value)) return 'Mind. 1 Kleinbuchstabe';
  if (!RegExp(r'[0-9]').hasMatch(value)) return 'Mind. 1 Zahl';
  // Allowed special characters: ! # $ % & * ( ) - + = { } [ ] : ; , . ?
  if (!RegExp('[!#\\\$%&*()\\-+=\\{\\}\\[\\]:;,.?]').hasMatch(value)) {
    return 'Mind. 1 Sonderzeichen';
  }
  // Check for invalid characters (only allow: A-Z, a-z, Ä, Ö, Ü, ä, ö, ü, 0-9, and allowed special chars)
  if (RegExp('[^A-Za-zÄÖÜäöü0-9!#\\\$%&*()\\-+=\\{\\}\\[\\]:;,.?]').hasMatch(value)) {
    return 'Bitte nur erlaubte Zeichen verwenden';
  }
  return null;
}

/// Calculates password strength (0.0 to 1.0)
double calculatePasswordStrength(String value) {
  double strength = 0;
  if (value.length >= 8) strength += 0.25;
  // Allowed uppercase letters: A-Z, Ä, Ö, Ü
  if (RegExp(r'[A-ZÄÖÜ]').hasMatch(value)) strength += 0.25;
  // Allowed lowercase letters: a-z, ä, ö, ü
  if (RegExp(r'[a-zäöü]').hasMatch(value)) strength += 0.15;
  if (RegExp(r'[0-9]').hasMatch(value)) strength += 0.15;
  // Allowed special characters: ! # $ % & * ( ) - + = { } [ ] : ; , . ?
  if (RegExp('[!#\\\$%&*()\\-+=\\{\\}\\[\\]:;,.?]').hasMatch(value)) strength += 0.2;
  return strength;
}

/// Returns label for password strength
String getPasswordStrengthLabel(double value) {
  if (value < 0.4) return 'Schwach';
  if (value < 0.7) return 'Mittel';
  return 'Stark';
}

/// Returns color for password strength
Color getPasswordStrengthColor(double value) {
  if (value < 0.4) return UIConstants.errorColor;
  if (value < 0.7) return UIConstants.warningColor;
  return UIConstants.successColor;
}
