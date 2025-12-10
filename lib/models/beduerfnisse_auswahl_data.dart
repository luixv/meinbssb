import 'package:flutter/foundation.dart';

/// Represents a selection data value (bed_auswahl_data) in the BSSB system.
@immutable
class BeduerfnisseAuswahl {
  /// Creates an [BeduerfnisseAuswahl] instance from a JSON map.
  factory BeduerfnisseAuswahl.fromJson(Map<String, dynamic> json) {
    return BeduerfnisseAuswahl(
      id: json['ID'] as int?,
      typId: json['TYP_ID'] as int,
      kurz: json['KURZ'] as String,
      lang: json['LANG'] as String,
      createdAt:
          json['CREATED_AT'] == null
              ? null
              : DateTime.parse(json['CREATED_AT'] as String),
      deletedAt:
          json['DELETED_AT'] == null
              ? null
              : DateTime.parse(json['DELETED_AT'] as String),
    );
  }

  /// Creates a new instance of [BeduerfnisseAuswahl].
  const BeduerfnisseAuswahl({
    this.id,
    required this.typId,
    required this.kurz,
    required this.lang,
    this.createdAt,
    this.deletedAt,
  });

  /// The unique identifier for the selection data value.
  final int? id;

  /// The foreign key to AuswahlTyp (TYP_ID).
  final int typId;

  /// The short code (unique per type).
  final String kurz;

  /// The long description.
  final String lang;

  /// The creation timestamp.
  final DateTime? createdAt;

  /// The deletion timestamp (nullable).
  final DateTime? deletedAt;

  /// Converts the [BeduerfnisseAuswahl] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'TYP_ID': typId,
      'KURZ': kurz,
      'LANG': lang,
      'CREATED_AT': createdAt?.toIso8601String(),
      'DELETED_AT': deletedAt?.toIso8601String(),
    };
  }
}
