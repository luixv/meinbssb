import 'package:flutter/foundation.dart';

/// Represents an application/request (bed_antrag) in the BSSB system.
@immutable
class BeduerfnisseAntrag {
  /// Creates a [BeduerfnisseAntrag] instance from a JSON map.
  /// Supports both snake_case (PostgREST) and uppercase formats.
  factory BeduerfnisseAntrag.fromJson(Map<String, dynamic> json) {
    return BeduerfnisseAntrag(
      id: (json['ID'] ?? json['id']) as int?,
      createdAt: json['CREATED_AT'] ?? json['created_at'] == null
          ? null
          : DateTime.parse((json['CREATED_AT'] ?? json['created_at']) as String),
      changedAt: json['CHANGED_AT'] ?? json['changed_at'] == null
          ? null
          : DateTime.parse((json['CHANGED_AT'] ?? json['changed_at']) as String),
      deletedAt: json['DELETED_AT'] ?? json['deleted_at'] == null
          ? null
          : DateTime.parse((json['DELETED_AT'] ?? json['deleted_at']) as String),
      antragsnummer: (json['ANTRAGSNUMMER'] ?? json['antragsnummer']) as String,
      personId: (json['PERSON_ID'] ?? json['person_id']) as int,
      statusId: (json['STATUS_ID'] ?? json['status_id']) as int?,
      wbkNeu: (json['WBK_NEU'] ?? json['wbk_neu']) as bool? ?? false,
      wbkArt: (json['WBK_ART'] ?? json['wbk_art']) as String?,
      beduerfnisart: (json['BEDUERFNISART'] ?? json['beduerfnisart']) as String?,
      anzahlWaffen: (json['ANZAHL_WAFFEN'] ?? json['anzahl_waffen']) as int?,
      vereinGenehmigt: (json['VEREIN_GENEHMIGT'] ?? json['verein_genehmigt']) as bool? ?? false,
      email: (json['EMAIL'] ?? json['email']) as String?,
      bankdaten: (json['BANKDATEN'] ?? json['bankdaten']) as Map<String, dynamic>?,
      abbuchungErfolgt: (json['ABBUCHUNG_ERFOLGT'] ?? json['abbuchung_erfolgt']) as bool? ?? false,
      bemerkung: (json['BEMERKUNG'] ?? json['bemerkung']) as String?,
    );
  }

  /// Creates a new instance of [BeduerfnisseAntrag].
  const BeduerfnisseAntrag({
    this.id,
    this.createdAt,
    this.changedAt,
    this.deletedAt,
    required this.antragsnummer,
    required this.personId,
    this.statusId,
    this.wbkNeu,
    this.wbkArt,
    this.beduerfnisart,
    this.anzahlWaffen,
    this.vereinGenehmigt,
    this.email,
    this.bankdaten,
    this.abbuchungErfolgt,
    this.bemerkung,
  });

  /// The unique identifier for the application.
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

  /// Whether this is a new weapon permit (WBK neu).
  final bool? wbkNeu;

  /// The weapon permit type ('yellow' or 'green').
  final String? wbkArt;

  /// The need type ('langwaffe' or 'kurzwaffe').
  final String? beduerfnisart;

  /// The number of weapons.
  final int? anzahlWaffen;

  /// Whether the club has approved.
  final bool? vereinGenehmigt;

  /// The email address.
  final String? email;

  /// Bank data as JSON.
  final Map<String, dynamic>? bankdaten;

  /// Whether the debit has been executed.
  final bool? abbuchungErfolgt;

  /// Additional remarks.
  final String? bemerkung;

  /// Converts the [BeduerfnisseAntrag] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'CREATED_AT': createdAt?.toIso8601String(),
      'CHANGED_AT': changedAt?.toIso8601String(),
      'DELETED_AT': deletedAt?.toIso8601String(),
      'ANTRAGSNUMMER': antragsnummer,
      'PERSON_ID': personId,
      'STATUS_ID': statusId,
      'WBK_NEU': wbkNeu,
      'WBK_ART': wbkArt,
      'BEDUERFNISART': beduerfnisart,
      'ANZAHL_WAFFEN': anzahlWaffen,
      'VEREIN_GENEHMIGT': vereinGenehmigt,
      'EMAIL': email,
      'BANKDATEN': bankdaten,
      'ABBUCHUNG_ERFOLGT': abbuchungErfolgt,
      'BEMERKUNG': bemerkung,
    };
  }
}
