import 'package:flutter/foundation.dart';

/// Represents a selection data value (bed_auswahl_data) in the BSSB system.
@immutable
class BeduerfnisAuswahl {
  /// Creates an [BeduerfnisAuswahl] instance from a JSON map.
  /// Supports both snake_case (PostgREST) and uppercase formats.
  factory BeduerfnisAuswahl.fromJson(Map<String, dynamic> json) {
    return BeduerfnisAuswahl(
      id: (json['ID'] ?? json['id']) as int?,
      typId: (json['TYP_ID'] ?? json['typ_id']) as int,
      kuerzel: (json['KUERZEL'] ?? json['kuerzel']) as String,
      beschreibung: (json['BESCHREIBUNG'] ?? json['beschreibung']) as String,
      sortReihenfolge:
          (json['SORT_REIHENFOLGE'] ?? json['sort_reihenfolge']) as int?,
      createdAt:
          json['CREATED_AT'] ?? json['created_at'] == null
              ? null
              : DateTime.parse(
                (json['CREATED_AT'] ?? json['created_at']) as String,
              ),
      deletedAt:
          json['DELETED_AT'] ?? json['deleted_at'] == null
              ? null
              : DateTime.parse(
                (json['DELETED_AT'] ?? json['deleted_at']) as String,
              ),
    );
  }

  /// Creates a new instance of [BeduerfnisAuswahl].
  const BeduerfnisAuswahl({
    this.id,
    required this.typId,
    required this.kuerzel,
    required this.beschreibung,
    this.sortReihenfolge,
    this.createdAt,
    this.deletedAt,
  });

  /// The unique identifier for the selection data value.
  final int? id;

  /// The foreign key to AuswahlTyp (TYP_ID).
  final int typId;

  /// The short code (unique per type).
  final String kuerzel;

  /// The long description.
  final String beschreibung;

  /// The sort order.
  final int? sortReihenfolge;

  /// The creation timestamp.
  final DateTime? createdAt;

  /// The deletion timestamp (nullable).
  final DateTime? deletedAt;

  /// Converts the [BeduerfnisAuswahl] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'TYP_ID': typId,
      'KUERZEL': kuerzel,
      'BESCHREIBUNG': beschreibung,
      'SORT_REIHENFOLGE': sortReihenfolge,
      'CREATED_AT': createdAt?.toIso8601String(),
      'DELETED_AT': deletedAt?.toIso8601String(),
    };
  }
}
