import 'package:flutter/foundation.dart';

/// Represents a training (Schulung) in the system.
@immutable
class Schulung {
  /// Creates a [Schulung] instance from a JSON map.
  factory Schulung.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      if (value is int) return value != 0;
      return false;
    }

    return Schulung(
      id: parseInt(json['ID']),
      bezeichnung: (json['BEZEICHNUNG'] ?? '').toString(),
      datum: (json['DATUM'] ?? '').toString(),
      ausgestelltAm: (json['AUSGESTELLTAM'] ?? '').toString(),
      teilnehmerId: parseInt(json['TEILNEHMERID']),
      schulungsartId: parseInt(json['SCHULUNGSARTID']),
      schulungsartBezeichnung:
          (json['SCHULUNGSARTBEZEICHNUNG'] ?? '').toString(),
      schulungsartKurzbezeichnung:
          (json['SCHULUNGSARTKURZBEZEICHNUNG'] ?? '').toString(),
      schulungsartBeschreibung:
          (json['SCHULUNGSARTBESCHREIBUNG'] ?? '').toString(),
      maxTeilnehmer: parseInt(json['MAXTEILNEHMER']),
      anzahlTeilnehmer: parseInt(json['ANZAHLTEILNEHMER']),
      ort: (json['ORT'] ?? '').toString(),
      uhrzeit: (json['UHRZEIT'] ?? '').toString(),
      dauer: (json['DAUER'] ?? '').toString(),
      preis: (json['PREIS'] ?? '').toString(),
      zielgruppe: (json['ZIELGRUPPE'] ?? '').toString(),
      voraussetzungen: (json['VORAUSSETZUNGEN'] ?? '').toString(),
      inhalt: (json['INHALT'] ?? '').toString(),
      abschluss: (json['ABSCHLUSS'] ?? '').toString(),
      anmerkungen: (json['ANMERKUNGEN'] ?? '').toString(),
      isOnline: parseBool(json['ISONLINE']),
      link: (json['LINK'] ?? '').toString(),
      status: (json['STATUS'] ?? '').toString(),
      gueltigBis: (json['GUELTIGBIS'] ?? '').toString(),
      lehrgangsinhaltHtml: (json['LEHRGANGSINHALTHTML'] ?? '').toString(),
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
    required this.lehrgangsinhaltHtml,
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

  /// The content of the training course in HTML format.
  final String lehrgangsinhaltHtml;

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
        'LEHRGANGSINHALTHTML': lehrgangsinhaltHtml,
        'ABSCHLUSS': abschluss,
        'ANMERKUNGEN': anmerkungen,
        'ISONLINE': isOnline,
        'LINK': link,
        'STATUS': status,
        'GUELTIGBIS': gueltigBis,
      };

  /// Creates a copy of the current [Schulung] instance with the given parameters.
  ///
  /// This method allows you to create a new instance of [Schulung] with
  /// modified fields, while keeping the other fields the same as the
  /// current instance.
  Schulung copyWith({
    int? id,
    String? bezeichnung,
    String? datum,
    String? ausgestelltAm,
    int? teilnehmerId,
    int? schulungsartId,
    String? schulungsartBezeichnung,
    String? schulungsartKurzbezeichnung,
    String? schulungsartBeschreibung,
    int? maxTeilnehmer,
    int? anzahlTeilnehmer,
    String? ort,
    String? uhrzeit,
    String? dauer,
    String? preis,
    String? zielgruppe,
    String? voraussetzungen,
    String? inhalt,
    String? abschluss,
    String? anmerkungen,
    bool? isOnline,
    String? link,
    String? status,
    String? gueltigBis,
    String? lehrgangsinhaltHtml,
  }) {
    return Schulung(
      id: id ?? this.id,
      bezeichnung: bezeichnung ?? this.bezeichnung,
      datum: datum ?? this.datum,
      ausgestelltAm: ausgestelltAm ?? this.ausgestelltAm,
      teilnehmerId: teilnehmerId ?? this.teilnehmerId,
      schulungsartId: schulungsartId ?? this.schulungsartId,
      schulungsartBezeichnung:
          schulungsartBezeichnung ?? this.schulungsartBezeichnung,
      schulungsartKurzbezeichnung:
          schulungsartKurzbezeichnung ?? this.schulungsartKurzbezeichnung,
      schulungsartBeschreibung:
          schulungsartBeschreibung ?? this.schulungsartBeschreibung,
      maxTeilnehmer: maxTeilnehmer ?? this.maxTeilnehmer,
      anzahlTeilnehmer: anzahlTeilnehmer ?? this.anzahlTeilnehmer,
      ort: ort ?? this.ort,
      uhrzeit: uhrzeit ?? this.uhrzeit,
      dauer: dauer ?? this.dauer,
      preis: preis ?? this.preis,
      zielgruppe: zielgruppe ?? this.zielgruppe,
      voraussetzungen: voraussetzungen ?? this.voraussetzungen,
      inhalt: inhalt ?? this.inhalt,
      abschluss: abschluss ?? this.abschluss,
      anmerkungen: anmerkungen ?? this.anmerkungen,
      isOnline: isOnline ?? this.isOnline,
      link: link ?? this.link,
      status: status ?? this.status,
      gueltigBis: gueltigBis ?? this.gueltigBis,
      lehrgangsinhaltHtml: lehrgangsinhaltHtml ?? this.lehrgangsinhaltHtml,
    );
  }

  @override
  String toString() {
    return 'Schulung(id: $id, bezeichnung: $bezeichnung, datum: $datum, ausgestelltAm: $ausgestelltAm, teilnehmerId: $teilnehmerId, schulungsartId: $schulungsartId, schulungsartBezeichnung: $schulungsartBezeichnung, schulungsartKurzbezeichnung: $schulungsartKurzbezeichnung, schulungsartBeschreibung: $schulungsartBeschreibung, maxTeilnehmer: $maxTeilnehmer, anzahlTeilnehmer: $anzahlTeilnehmer, ort: $ort, uhrzeit: $uhrzeit, dauer: $dauer, preis: $preis, zielgruppe: $zielgruppe, voraussetzungen: $voraussetzungen, inhalt: $inhalt, lehrgangsinhaltHtml: $lehrgangsinhaltHtml, abschluss: $abschluss, anmerkungen: $anmerkungen, isOnline: $isOnline, link: $link, status: $status, gueltigBis: $gueltigBis)';
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
        other.lehrgangsinhaltHtml == lehrgangsinhaltHtml &&
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
      lehrgangsinhaltHtml,
      abschluss,
      anmerkungen,
      isOnline,
      link,
      status,
      gueltigBis,
    ]);
  }
}
