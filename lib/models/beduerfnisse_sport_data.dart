import 'package:flutter/foundation.dart';

/// Represents a sport record (bed_sport) in the BSSB system.
@immutable
class BeduerfnisseSport {
  /// Creates a [BeduerfnisseSport] instance from a JSON map.
  factory BeduerfnisseSport.fromJson(Map<String, dynamic> json) {
    return BeduerfnisseSport(
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
      schiessdatum:
          json['SCHIESSDATUM'] == null
              ? DateTime.now() // fallback to now if null
              : DateTime.parse(json['SCHIESSDATUM'] as String),
      waffenartId: json['WAFFENART_ID'] as int,
      disziplinId: json['DISZIPLIN_ID'] as int,
      training: json['TRAINING'] as bool,
      wettkampfartId: json['WETTKAMPFART_ID'] as int?,
      wettkampfergebnis:
          json['WETTKAMPFERGEBNIS'] == null
              ? null
              : (json['WETTKAMPFERGEBNIS'] as num).toDouble(),
    );
  }

  /// Creates a new instance of [BeduerfnisseSport].
  const BeduerfnisseSport({
    this.id,
    this.createdAt,
    this.changedAt,
    this.deletedAt,
    required this.antragsnummer,
    required this.schiessdatum,
    required this.waffenartId,
    required this.disziplinId,
    required this.training,
    this.wettkampfartId,
    this.wettkampfergebnis,
  });

  /// The unique identifier for the sport record.
  final int? id;

  /// The creation timestamp.
  final DateTime? createdAt;

  /// The last changed timestamp.
  final DateTime? changedAt;

  /// The deletion timestamp (nullable).
  final DateTime? deletedAt;

  /// The application number.
  final String antragsnummer;

  /// The shooting date.
  final DateTime schiessdatum;

  /// The weapon type ID (foreign key).
  final int waffenartId;

  /// The discipline ID (foreign key).
  final int disziplinId;

  /// Whether this is a training event.
  final bool training;

  /// The competition type ID (foreign key, nullable).
  final int? wettkampfartId;

  /// The competition result (nullable).
  final double? wettkampfergebnis;

  /// Converts the [BeduerfnisseSport] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'CREATED_AT': createdAt?.toIso8601String(),
      'CHANGED_AT': changedAt?.toIso8601String(),
      'DELETED_AT': deletedAt?.toIso8601String(),
      'ANTRAGSNUMMER': antragsnummer,
      'SCHIESSDATUM': schiessdatum.toIso8601String(),
      'WAFFENART_ID': waffenartId,
      'DISZIPLIN_ID': disziplinId,
      'TRAINING': training,
      'WETTKAMPFART_ID': wettkampfartId,
      'WETTKAMPFERGEBNIS': wettkampfergebnis,
    };
  }
}
