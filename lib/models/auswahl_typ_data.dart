import 'package:flutter/foundation.dart';

/// Represents a selection type/category (bed_auswahl_typ) in the BSSB system.
@immutable
class AuswahlTyp {
  /// Creates an [AuswahlTyp] instance from a JSON map.
  factory AuswahlTyp.fromJson(Map<String, dynamic> json) {
    return AuswahlTyp(
      id: json['ID'] as int?,
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

  /// Creates a new instance of [AuswahlTyp].
  const AuswahlTyp({
    this.id,
    required this.kurz,
    required this.lang,
    this.createdAt,
    this.deletedAt,
  });

  /// The unique identifier for the selection type.
  final int? id;

  /// The short code (unique).
  final String kurz;

  /// The long description.
  final String lang;

  /// The creation timestamp.
  final DateTime? createdAt;

  /// The deletion timestamp (nullable).
  final DateTime? deletedAt;

  /// Converts the [AuswahlTyp] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'KURZ': kurz,
      'LANG': lang,
      'CREATED_AT': createdAt?.toIso8601String(),
      'DELETED_AT': deletedAt?.toIso8601String(),
    };
  }
}
