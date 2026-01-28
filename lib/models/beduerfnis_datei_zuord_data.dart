import 'package:flutter/foundation.dart';

/// Represents a file association (bed_datei_zuord) in the BSSB system.
@immutable
class BeduerfnisDateiZuord {
  /// Creates a [BeduerfnisDateiZuord] instance from a JSON map.
  /// Supports both snake_case (PostgREST) and uppercase formats.
  factory BeduerfnisDateiZuord.fromJson(Map<String, dynamic> json) {
    return BeduerfnisDateiZuord(
      id: (json['ID'] ?? json['id']) as int?,
      createdAt:
          (json['CREATED_AT'] ?? json['created_at']) == null
              ? null
              : DateTime.parse(
                (json['CREATED_AT'] ?? json['created_at']) as String,
              ),
      changedAt:
          (json['CHANGED_AT'] ?? json['changed_at']) == null
              ? null
              : DateTime.parse(
                (json['CHANGED_AT'] ?? json['changed_at']) as String,
              ),
      deletedAt:
          (json['DELETED_AT'] ?? json['deleted_at']) == null
              ? null
              : DateTime.parse(
                (json['DELETED_AT'] ?? json['deleted_at']) as String,
              ),
      antragsnummer: (json['ANTRAGSNUMMER'] ?? json['antragsnummer']) as int,
      dateiId: (json['DATEI_ID'] ?? json['datei_id']) as int,
      dateiArt: (json['DATEI_ART'] ?? json['datei_art']) as String,
      bedSportId: (json['BED_SPORT_ID'] ?? json['bed_sport_id']) as int?,
      label: (json['LABEL'] ?? json['label']) as String?,
    );
  }

  /// Creates a new instance of [BeduerfnisDateiZuord].
  const BeduerfnisDateiZuord({
    this.id,
    this.createdAt,
    this.changedAt,
    this.deletedAt,
    required this.antragsnummer,
    required this.dateiId,
    required this.dateiArt,
    this.bedSportId,
    this.label,
  });

  /// The unique identifier.
  final int? id;

  /// The creation timestamp.
  final DateTime? createdAt;

  /// The last modification timestamp.
  final DateTime? changedAt;

  /// The deletion timestamp (nullable).
  final DateTime? deletedAt;

  /// The application number.
  final int antragsnummer;

  /// The file ID (foreign key to bed_datei table).
  final int dateiId;

  /// The file association type (SPORT or WBK).
  final String dateiArt;

  /// The sport record ID (foreign key to bed_sport table, nullable).
  final int? bedSportId;

  /// The label for the file association (nullable).
  final String? label;

  /// Converts the [BeduerfnisDateiZuord] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'CREATED_AT': createdAt?.toIso8601String(),
      'CHANGED_AT': changedAt?.toIso8601String(),
      'DELETED_AT': deletedAt?.toIso8601String(),
      'ANTRAGSNUMMER': antragsnummer,
      'DATEI_ID': dateiId,
      'DATEI_ART': dateiArt,
      'BED_SPORT_ID': bedSportId,
      'LABEL': label,
    };
  }
}
