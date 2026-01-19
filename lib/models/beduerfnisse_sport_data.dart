import 'package:flutter/foundation.dart';

/// Represents a sport record (bed_sport) in the BSSB system.
@immutable
class BeduerfnisseSport {
  /// Creates a [BeduerfnisseSport] instance from a JSON map.
  factory BeduerfnisseSport.fromJson(Map<String, dynamic> json) {
    return BeduerfnisseSport(
      id: (json['ID'] ?? json['id']) as int?,
      createdAt:
          (json['CREATED_AT'] ?? json['created_at']) == null
              ? null
              : DateTime.parse((json['CREATED_AT'] ?? json['created_at']) as String),
      changedAt:
          (json['CHANGED_AT'] ?? json['changed_at']) == null
              ? null
              : DateTime.parse((json['CHANGED_AT'] ?? json['changed_at']) as String),
      deletedAt:
          (json['DELETED_AT'] ?? json['deleted_at']) == null
              ? null
              : DateTime.parse((json['DELETED_AT'] ?? json['deleted_at']) as String),
      antragsnummer: (json['ANTRAGSNUMMER'] ?? json['antragsnummer']) as int,
      schiessdatum:
          (json['SCHIESSDATUM'] ?? json['schiessdatum']) == null
              ? DateTime.now() // fallback to now if null
              : DateTime.parse((json['SCHIESSDATUM'] ?? json['schiessdatum']) as String),
      waffenartId: (json['WAFFENART_ID'] ?? json['waffenart_id']) as int,
      disziplinId: (json['DISZIPLIN_ID'] ?? json['disziplin_id']) as int,
      training: (json['TRAINING'] ?? json['training']) as bool,
      wettkampfartId: (json['WETTKAMPFART_ID'] ?? json['wettkampfart_id']) as int?,
      wettkampfergebnis:
          (json['WETTKAMPFERGEBNIS'] ?? json['wettkampfergebnis']) == null
              ? null
              : ((json['WETTKAMPFERGEBNIS'] ?? json['wettkampfergebnis']) as num).toDouble(),
      bemerkung: (json['BEMERKUNG'] ?? json['bemerkung']) as String?,
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
    this.bemerkung,
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
  final int antragsnummer;

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

  /// Remarks/notes (nullable).
  final String? bemerkung;

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
      'BEMERKUNG': bemerkung,
    };
  }
}
