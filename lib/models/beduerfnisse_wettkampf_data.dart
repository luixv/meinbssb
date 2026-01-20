import 'package:flutter/foundation.dart';

/// Represents a competition record (bed_wettkampf) in the BSSB system.
@immutable
class BeduerfnisseWettkampf {
  /// Creates a [BeduerfnisseWettkampf] instance from a JSON map.
  factory BeduerfnisseWettkampf.fromJson(Map<String, dynamic> json) {
    return BeduerfnisseWettkampf(
      id: (json['ID'] ?? json['id']) as int?,
      createdAt: (json['CREATED_AT'] ?? json['created_at']) == null
          ? null
          : DateTime.parse((json['CREATED_AT'] ?? json['created_at']) as String),
      changedAt: (json['CHANGED_AT'] ?? json['changed_at']) == null
          ? null
          : DateTime.parse((json['CHANGED_AT'] ?? json['changed_at']) as String),
      deletedAt: (json['DELETED_AT'] ?? json['deleted_at']) == null
          ? null
          : DateTime.parse((json['DELETED_AT'] ?? json['deleted_at']) as String),
      antragsnummer: (json['ANTRAGSNUMMER'] ?? json['antragsnummer']) as int,
      schiessdatum: DateTime.parse(
        (json['SCHIESSDATUM'] ?? json['schiessdatum']) as String,
      ),
      wettkampfart: (json['WETTKAMPFART'] ?? json['wettkampfart']) as String,
      disziplinId: (json['DISZIPLIN_ID'] ?? json['disziplin_id']) as int,
      wettkampfergebnis:
          (json['WETTKAMPFERGEBNIS'] ?? json['wettkampfergebnis']) == null
              ? null
              : (json['WETTKAMPFERGEBNIS'] ?? json['wettkampfergebnis']) is int
                  ? ((json['WETTKAMPFERGEBNIS'] ?? json['wettkampfergebnis'])
                          as int)
                      .toDouble()
                  : (json['WETTKAMPFERGEBNIS'] ?? json['wettkampfergebnis'])
                      as double,
      bemerkung: (json['BEMERKUNG'] ?? json['bemerkung']) as String?,
    );
  }

  /// Creates a new instance of [BeduerfnisseWettkampf].
  const BeduerfnisseWettkampf({
    this.id,
    this.createdAt,
    this.changedAt,
    this.deletedAt,
    required this.antragsnummer,
    required this.schiessdatum,
    required this.wettkampfart,
    required this.disziplinId,
    this.wettkampfergebnis,
    this.bemerkung,
  });

  /// The unique identifier for the competition record.
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

  /// The competition type.
  final String wettkampfart;

  /// The discipline ID (foreign key).
  final int disziplinId;

  /// The competition result (nullable).
  final double? wettkampfergebnis;

  /// Remarks (nullable).
  final String? bemerkung;

  /// Converts the [BeduerfnisseWettkampf] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'CREATED_AT': createdAt?.toIso8601String(),
      'CHANGED_AT': changedAt?.toIso8601String(),
      'DELETED_AT': deletedAt?.toIso8601String(),
      'ANTRAGSNUMMER': antragsnummer,
      'SCHIESSDATUM': schiessdatum.toIso8601String(),
      'WETTKAMPFART': wettkampfart,
      'DISZIPLIN_ID': disziplinId,
      'WETTKAMPFERGEBNIS': wettkampfergebnis,
      'BEMERKUNG': bemerkung,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BeduerfnisseWettkampf &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          createdAt == other.createdAt &&
          changedAt == other.changedAt &&
          deletedAt == other.deletedAt &&
          antragsnummer == other.antragsnummer &&
          schiessdatum == other.schiessdatum &&
          wettkampfart == other.wettkampfart &&
          disziplinId == other.disziplinId &&
          wettkampfergebnis == other.wettkampfergebnis &&
          bemerkung == other.bemerkung;

  @override
  int get hashCode =>
      id.hashCode ^
      createdAt.hashCode ^
      changedAt.hashCode ^
      deletedAt.hashCode ^
      antragsnummer.hashCode ^
      schiessdatum.hashCode ^
      wettkampfart.hashCode ^
      disziplinId.hashCode ^
      wettkampfergebnis.hashCode ^
      bemerkung.hashCode;
}
