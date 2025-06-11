import 'package:flutter/foundation.dart';

/// Represents a contact entry in the system.
@immutable
class Contact {
  /// Creates a [Contact] instance from a JSON map.
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['KONTAKTID'] as int,
      personId: json['PERSONID'] as int,
      type: json['KONTAKTTYP'] as int,
      value: json['KONTAKT'] as String,
    );
  }

  /// Creates a new instance of [Contact].
  const Contact({
    required this.id,
    required this.personId,
    required this.type,
    required this.value,
  });

  /// The unique identifier of the contact.
  final int id;

  /// The ID of the person this contact belongs to.
  final int personId;

  /// The type of contact (1-8).
  /// 1: Telefonnummer Privat
  /// 2: Mobilnummer Privat
  /// 3: Fax Privat
  /// 4: E-Mail Privat
  /// 5: Telefonnummer Geschäftlich
  /// 6: Mobilnummer Geschäftlich
  /// 7: Fax Geschäftlich
  /// 8: E-Mail Geschäftlich
  final int type;

  /// The contact value (phone number, email, etc.).
  final String value;

  /// Converts this [Contact] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'KONTAKTID': id,
      'PERSONID': personId,
      'KONTAKTTYP': type,
      'KONTAKT': value,
    };
  }

  /// Creates a copy of this [Contact] with the given fields replaced with the new values.
  Contact copyWith({
    int? id,
    int? personId,
    int? type,
    String? value,
  }) {
    return Contact(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      type: type ?? this.type,
      value: value ?? this.value,
    );
  }

  /// Returns the display label for this contact type.
  String get typeLabel {
    const Map<int, String> labels = {
      1: 'Telefonnummer Privat',
      2: 'Mobilnummer Privat',
      3: 'Fax Privat',
      4: 'E-Mail Privat',
      5: 'Telefonnummer Geschäftlich',
      6: 'Mobilnummer Geschäftlich',
      7: 'Fax Geschäftlich',
      8: 'E-Mail Geschäftlich',
    };
    return labels[type] ?? 'Unbekannter Kontakt ($type)';
  }

  /// Returns whether this contact is private (type 1-4) or business (type 5-8).
  bool get isPrivate => type >= 1 && type <= 4;

  /// Returns whether this contact is business-related (type 5-8).
  bool get isBusiness => type >= 5 && type <= 8;

  /// Returns whether this contact is an email address (type 4 or 8).
  bool get isEmail => type == 4 || type == 8;

  /// Returns whether this contact is a phone number (type 1, 2, 5, or 6).
  bool get isPhone => type == 1 || type == 2 || type == 5 || type == 6;

  /// Returns whether this contact is a fax number (type 3 or 7).
  bool get isFax => type == 3 || type == 7;

  @override
  String toString() {
    return 'Contact(id: $id, personId: $personId, type: $type, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Contact &&
        other.id == id &&
        other.personId == personId &&
        other.type == type &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(id, personId, type, value);
} 