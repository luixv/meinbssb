import 'package:flutter/foundation.dart';

/// Represents a weapon possession record (bed_waffe_besitz) in the BSSB system.
@immutable
class BeduerfnisseWaffeBesitz {
  /// Creates a [BeduerfnisseWaffeBesitz] instance from a JSON map.
  factory BeduerfnisseWaffeBesitz.fromJson(Map<String, dynamic> json) {
    return BeduerfnisseWaffeBesitz(
      id: json['ID'] as int?,
      createdAt:
          json['CREATED_AT'] == null
              ? null
              : DateTime.parse(json['CREATED_AT'] as String),
      changedAt:
          json['CHANGED_AT'] == null
              ? null
              : DateTime.parse(json['CHANGED_AT'] as String),
      deletedAt:
          json['DELETED_AT'] == null
              ? null
              : DateTime.parse(json['DELETED_AT'] as String),
      antragsnummer: json['ANTRAGSNUMMER'] as String,
      wbkNr: json['WBK_NR'] as String,
      lfdWbk: json['LFD_WBK'] as String,
      waffenartId: json['WAFFENART_ID'] as int,
      hersteller: json['HERSTELLER'] as String?,
      kaliberId: json['KALIBER_ID'] as int,
      lauflaengeId: json['LAUFLAENGE_ID'] as int?,
      gewicht: json['GEWICHT'] as String?,
      kompensator: json['KOMPENSATOR'] as bool,
      beduerfnisgrundId: json['BEDUERFNISGRUND_ID'] as int?,
      verbandId: json['VERBAND_ID'] as int?,
      bemerkung: json['BEMERKUNG'] as String?,
    );
  }

  /// Creates a new instance of [BeduerfnisseWaffeBesitz].
  const BeduerfnisseWaffeBesitz({
    this.id,
    this.createdAt,
    this.changedAt,
    this.deletedAt,
    required this.antragsnummer,
    required this.wbkNr,
    required this.lfdWbk,
    required this.waffenartId,
    this.hersteller,
    required this.kaliberId,
    this.lauflaengeId,
    this.gewicht,
    required this.kompensator,
    this.beduerfnisgrundId,
    this.verbandId,
    this.bemerkung,
  });

  /// The unique identifier for the weapon possession record.
  final int? id;

  /// The creation timestamp.
  final DateTime? createdAt;

  /// The last changed timestamp.
  final DateTime? changedAt;

  /// The deletion timestamp (nullable).
  final DateTime? deletedAt;

  /// The application number.
  final String antragsnummer;

  /// The WBK number.
  final String wbkNr;

  /// The running WBK number.
  final String lfdWbk;

  /// The weapon type ID (foreign key).
  final int waffenartId;

  /// The manufacturer (nullable).
  final String? hersteller;

  /// The caliber ID (foreign key).
  final int kaliberId;

  /// The barrel length ID (foreign key, nullable).
  final int? lauflaengeId;

  /// The weight (nullable).
  final String? gewicht;

  /// Whether the weapon has a compensator.
  final bool kompensator;

  /// The reason for need ID (foreign key, nullable).
  final int? beduerfnisgrundId;

  /// The association ID (foreign key, nullable).
  final int? verbandId;

  /// Remarks (nullable).
  final String? bemerkung;

  /// Converts the [BeduerfnisseWaffeBesitz] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'CREATED_AT': createdAt?.toIso8601String(),
      'CHANGED_AT': changedAt?.toIso8601String(),
      'DELETED_AT': deletedAt?.toIso8601String(),
      'ANTRAGSNUMMER': antragsnummer,
      'WBK_NR': wbkNr,
      'LFD_WBK': lfdWbk,
      'WAFFENART_ID': waffenartId,
      'HERSTELLER': hersteller,
      'KALIBER_ID': kaliberId,
      'LAUFLAENGE_ID': lauflaengeId,
      'GEWICHT': gewicht,
      'KOMPENSATOR': kompensator,
      'BEDUERFNISGRUND_ID': beduerfnisgrundId,
      'VERBAND_ID': verbandId,
      'BEMERKUNG': bemerkung,
    };
  }
}
