import 'package:flutter/foundation.dart';

/// Represents a bed_antrag_person entry in the BSSB system.
@immutable
class BeduerfnisAntragPerson {
  /// Creates a [BeduerfnisAntragPerson] instance from a JSON map.
  /// Supports both snake_case (PostgREST) and uppercase formats.
  factory BeduerfnisAntragPerson.fromJson(Map<String, dynamic> json) {
    return BeduerfnisAntragPerson(
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
      antragsnummer: (json['ANTRAGSNUMMER'] ?? json['antragsnummer']) as String,
      personId: (json['PERSON_ID'] ?? json['person_id']) as int,
      statusId: (json['STATUS_ID'] ?? json['status_id']) as int?,
      vorname: (json['VORNAME'] ?? json['vorname']) as String?,
      nachname: (json['NACHNAME'] ?? json['nachname']) as String?,
      vereinsname: (json['VEREINSNAME'] ?? json['vereinsname']) as String?,
    );
  }

  /// Creates a new instance of [BeduerfnisAntragPerson].
  const BeduerfnisAntragPerson({
    this.id,
    this.createdAt,
    this.changedAt,
    this.deletedAt,
    required this.antragsnummer,
    required this.personId,
    this.statusId,
    this.vorname,
    this.nachname,
    this.vereinsname,
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
  final String antragsnummer;

  /// The person ID (foreign key to person table).
  final int personId;

  /// The status ID (foreign key to bed_antrag_status table).
  final int? statusId;

  /// The first name.
  final String? vorname;

  /// The last name.
  final String? nachname;

  /// The club/association name.
  final String? vereinsname;

  /// Converts the [BeduerfnisAntragPerson] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'CREATED_AT': createdAt?.toIso8601String(),
      'CHANGED_AT': changedAt?.toIso8601String(),
      'ANTRAGSNUMMER': antragsnummer,
      'PERSON_ID': personId,
      'STATUS_ID': statusId,
      'VORNAME': vorname,
      'NACHNAME': nachname,
      'VEREINSNAME': vereinsname,
    };
  }
}
