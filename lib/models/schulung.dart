// Project: Mein BSSB
// Filename: schulung.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/foundation.dart';

/// Represents a training (Schulung) in the system.
@immutable
class Schulung {
  /// Creates a [Schulung] instance from a JSON map.
  factory Schulung.fromJson(Map<String, dynamic> json) {
    return Schulung(
      id: json['ID'] as int? ?? 0,
      bezeichnung: json['BEZEICHNUNG'] as String? ?? '',
      datum: json['DATUM']?.toString() ?? '',
      ausgestelltAm: json['AUSGESTELLTAM']?.toString() ?? '',
      teilnehmerId: json['TEILNEHMERID'] as int? ?? 0,
      schulungsartId: json['SCHULUNGSARTID'] as int? ?? 0,
      schulungsartBezeichnung: json['SCHULUNGSARTBEZEICHNUNG'] as String? ?? '',
      schulungsartKurzbezeichnung:
          json['SCHULUNGSARTKURZBEZEICHNUNG'] as String? ?? '',
      schulungsartBeschreibung:
          json['SCHULUNGSARTBESCHREIBUNG'] as String? ?? '',
      maxTeilnehmer: json['MAXTEILNEHMER'] as int? ?? 0,
      anzahlTeilnehmer: json['ANZAHLTEILNEHMER'] as int? ?? 0,
      ort: json['ORT'] as String? ?? '',
      uhrzeit: json['UHRZEIT']?.toString() ?? '',
      dauer: json['DAUER']?.toString() ?? '',
      preis: json['PREIS']?.toString() ?? '',
      zielgruppe: json['ZIELGRUPPE'] as String? ?? '',
      voraussetzungen: json['VORAUSSETZUNGEN'] as String? ?? '',
      inhalt: json['INHALT'] as String? ?? '',
      abschluss: json['ABSCHLUSS'] as String? ?? '',
      anmerkungen: json['ANMERKUNGEN'] as String? ?? '',
      isOnline: json['ISONLINE'] as bool? ?? false,
      link: json['LINK'] as String? ?? '',
      status: json['STATUS'] as String? ?? '',
      gueltigBis: json['GUELTIGBIS']?.toString() ?? '',
    );
  }

  /// Creates a new instance of [Schulung].
  const Schulung({
    required this.id,
    required this.bezeichnung,
    required this.datum,
    required this.ausgestelltAm,
    required this.teilnehmerId,
    required this.schulungsartId,
    required this.schulungsartBezeichnung,
    required this.schulungsartKurzbezeichnung,
    required this.schulungsartBeschreibung,
    required this.maxTeilnehmer,
    required this.anzahlTeilnehmer,
    required this.ort,
    required this.uhrzeit,
    required this.dauer,
    required this.preis,
    required this.zielgruppe,
    required this.voraussetzungen,
    required this.inhalt,
    required this.abschluss,
    required this.anmerkungen,
    required this.isOnline,
    required this.link,
    required this.status,
    required this.gueltigBis,
  });

  /// The unique identifier of the training.
  final int id;

  /// The name/description of the training.
  final String bezeichnung;

  /// The date of the training.
  final String datum;

  /// The date the training was issued.
  final String ausgestelltAm;

  /// The unique identifier of the training participant.
  final int teilnehmerId;

  /// The unique identifier of the training type.
  final int schulungsartId;

  /// The name of the training type.
  final String schulungsartBezeichnung;

  /// The short name of the training type.
  final String schulungsartKurzbezeichnung;

  /// The description of the training type.
  final String schulungsartBeschreibung;

  /// The maximum number of participants allowed.
  final int maxTeilnehmer;

  /// The current number of participants.
  final int anzahlTeilnehmer;

  /// The location of the training.
  final String ort;

  /// The time of the training.
  final String uhrzeit;

  /// The duration of the training.
  final String dauer;

  /// The price of the training.
  final String preis;

  /// The target group for the training.
  final String zielgruppe;

  /// The prerequisites for the training.
  final String voraussetzungen;

  /// The content of the training course.
  final String inhalt;

  /// The conclusion of the training.
  final String abschluss;

  /// Additional notes about the training.
  final String anmerkungen;

  /// Whether the training is online.
  final bool isOnline;

  /// The link to the training.
  final String link;

  /// The status of the training.
  final String status;

  /// The validity period of the training.
  final String gueltigBis;

  /// Converts this [Schulung] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'ID': id,
        'BEZEICHNUNG': bezeichnung,
        'DATUM': datum,
        'AUSGESTELLTAM': ausgestelltAm,
        'TEILNEHMERID': teilnehmerId,
        'SCHULUNGSARTID': schulungsartId,
        'SCHULUNGSARTBEZEICHNUNG': schulungsartBezeichnung,
        'SCHULUNGSARTKURZBEZEICHNUNG': schulungsartKurzbezeichnung,
        'SCHULUNGSARTBESCHREIBUNG': schulungsartBeschreibung,
        'MAXTEILNEHMER': maxTeilnehmer,
        'ANZAHLTEILNEHMER': anzahlTeilnehmer,
        'ORT': ort,
        'UHRZEIT': uhrzeit,
        'DAUER': dauer,
        'PREIS': preis,
        'ZIELGRUPPE': zielgruppe,
        'VORAUSSETZUNGEN': voraussetzungen,
        'INHALT': inhalt,
        'ABSCHLUSS': abschluss,
        'ANMERKUNGEN': anmerkungen,
        'ISONLINE': isOnline,
        'LINK': link,
        'STATUS': status,
        'GUELTIGBIS': gueltigBis,
      };

  @override
  String toString() {
    return 'Schulung(id: $id, bezeichnung: $bezeichnung, datum: $datum, ausgestelltAm: $ausgestelltAm, teilnehmerId: $teilnehmerId, schulungsartId: $schulungsartId, schulungsartBezeichnung: $schulungsartBezeichnung, schulungsartKurzbezeichnung: $schulungsartKurzbezeichnung, schulungsartBeschreibung: $schulungsartBeschreibung, maxTeilnehmer: $maxTeilnehmer, anzahlTeilnehmer: $anzahlTeilnehmer, ort: $ort, uhrzeit: $uhrzeit, dauer: $dauer, preis: $preis, zielgruppe: $zielgruppe, voraussetzungen: $voraussetzungen, inhalt: $inhalt, abschluss: $abschluss, anmerkungen: $anmerkungen, isOnline: $isOnline, link: $link, status: $status, gueltigBis: $gueltigBis)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Schulung &&
        other.id == id &&
        other.bezeichnung == bezeichnung &&
        other.datum == datum &&
        other.ausgestelltAm == ausgestelltAm &&
        other.teilnehmerId == teilnehmerId &&
        other.schulungsartId == schulungsartId &&
        other.schulungsartBezeichnung == schulungsartBezeichnung &&
        other.schulungsartKurzbezeichnung == schulungsartKurzbezeichnung &&
        other.schulungsartBeschreibung == schulungsartBeschreibung &&
        other.maxTeilnehmer == maxTeilnehmer &&
        other.anzahlTeilnehmer == anzahlTeilnehmer &&
        other.ort == ort &&
        other.uhrzeit == uhrzeit &&
        other.dauer == dauer &&
        other.preis == preis &&
        other.zielgruppe == zielgruppe &&
        other.voraussetzungen == voraussetzungen &&
        other.inhalt == inhalt &&
        other.abschluss == abschluss &&
        other.anmerkungen == anmerkungen &&
        other.isOnline == isOnline &&
        other.link == link &&
        other.status == status &&
        other.gueltigBis == gueltigBis;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      bezeichnung,
      datum,
      ausgestelltAm,
      teilnehmerId,
      schulungsartId,
      schulungsartBezeichnung,
      schulungsartKurzbezeichnung,
      schulungsartBeschreibung,
      maxTeilnehmer,
      anzahlTeilnehmer,
      ort,
      uhrzeit,
      dauer,
      preis,
      zielgruppe,
      voraussetzungen,
      inhalt,
      abschluss,
      anmerkungen,
      isOnline,
      link,
      status,
      gueltigBis,
    ]);
  }
}
