import 'package:flutter/foundation.dart';

/// Represents a selection type/category (bed_auswahl_typ) in the BSSB system.
@immutable
class BeduerfnisseAuswahlTyp {
  /// Creates an [BeduerfnisseAuswahlTyp] instance from a JSON map.
  /// Supports both snake_case (PostgREST) and uppercase formats.
  factory BeduerfnisseAuswahlTyp.fromJson(Map<String, dynamic> json) {
    return BeduerfnisseAuswahlTyp(
      id: (json['ID'] ?? json['id']) as int?,
      kuerzel: (json['KUERZEL'] ?? json['kuerzel']) as String,
      beschreibung: (json['BESCHREIBUNG'] ?? json['beschreibung']) as String,
      createdAt: json['CREATED_AT'] ?? json['created_at'] == null
          ? null
          : DateTime.parse((json['CREATED_AT'] ?? json['created_at']) as String),
      deletedAt: json['DELETED_AT'] ?? json['deleted_at'] == null
          ? null
          : DateTime.parse((json['DELETED_AT'] ?? json['deleted_at']) as String),
    );
  }

  /// Creates a new instance of [BeduerfnisseAuswahlTyp].
  const BeduerfnisseAuswahlTyp({
    this.id,
    required this.kuerzel,
    required this.beschreibung,
    this.createdAt,
    this.deletedAt,
  });

  /// The unique identifier for the selection type.
  final int? id;

  /// The short code (unique).
  final String kuerzel;

  /// The long description.
  final String beschreibung;

  /// The creation timestamp.
  final DateTime? createdAt;

  /// The deletion timestamp (nullable).
  final DateTime? deletedAt;

  /// Converts the [BeduerfnisseAuswahlTyp] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'KUERZEL': kuerzel,
      'BESCHREIBUNG': beschreibung,
      'CREATED_AT': createdAt?.toIso8601String(),
      'DELETED_AT': deletedAt?.toIso8601String(),
    };
  }
}
