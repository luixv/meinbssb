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
      id: json['SCHULUNGID'] ?? 0,
      teilnehmerId: json['SCHULUNGENTEILNEHMERID'] ?? 0,
      bezeichnung: json['BEZEICHNUNG'] ?? '',
      datum: json['DATUM'] ?? '',
      ort: json['ORT'] ?? '',
      maxTeilnehmer: json['MAXTEILNEHMER'] ?? 0,
      teilnehmer: json['TEILNEHMER'] ?? 0,
      typ: json['TYP'] ?? '',
      kosten: json['KOSTEN'] ?? 0.0,
      ue: json['UE'] ?? 0,
      omKategorieId: json['OMKATEGORIEID'] ?? 0,
      rechnungAn: json['RECHNUNGAN'] ?? '',
      verpflegungskosten: json['VERPFLEGUNGSKOSTEN'] ?? 0.0,
      uebernachtungskosten: json['UEBERNACHTUNGSKOSTEN'] ?? 0.0,
      lehrmaterialkosten: json['LEHRMATERIALKOSTEN'] ?? 0.0,
      lehrgangsinhalt: json['LEHRGANGSINHALT'] ?? '',
      lehrgangsinhaltHtml: json['LEHRGANGSINHALTHTML'] ?? '',
      webgruppe: json['WEBGRUPPE'] ?? '',
      fuerVerlaengerungen: json['FUERVERLAENGERUNGEN'] ?? false,
    );
  }

  /// Creates a new instance of [Schulung].
  const Schulung({
    required this.id,
    required this.teilnehmerId,
    required this.bezeichnung,
    required this.datum,
    required this.ort,
    required this.maxTeilnehmer,
    required this.teilnehmer,
    required this.typ,
    required this.kosten,
    required this.ue,
    required this.omKategorieId,
    required this.rechnungAn,
    required this.verpflegungskosten,
    required this.uebernachtungskosten,
    required this.lehrmaterialkosten,
    required this.lehrgangsinhalt,
    required this.lehrgangsinhaltHtml,
    required this.webgruppe,
    required this.fuerVerlaengerungen,
  });

  /// The unique identifier of the training.
  final int id;

  /// The unique identifier of the training participant.
  final int teilnehmerId;

  /// The name/description of the training.
  final String bezeichnung;

  /// The date of the training.
  final String datum;

  /// The location of the training.
  final String ort;

  /// The maximum number of participants allowed.
  final int maxTeilnehmer;

  /// The current number of participants.
  final int teilnehmer;

  /// The type of training.
  final String typ;

  /// The cost of the training.
  final double kosten;

  /// The number of teaching units (UE).
  final int ue;

  /// The OM category ID.
  final int omKategorieId;

  /// The billing address.
  final String rechnungAn;

  /// The cost for food.
  final double verpflegungskosten;

  /// The cost for accommodation.
  final double uebernachtungskosten;

  /// The cost for teaching materials.
  final double lehrmaterialkosten;

  /// The content of the training course.
  final String lehrgangsinhalt;

  /// The HTML content of the training course.
  final String lehrgangsinhaltHtml;

  /// The web group.
  final String webgruppe;

  /// Whether the training is for extensions.
  final bool fuerVerlaengerungen;

  /// Converts this [Schulung] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'SCHULUNGID': id,
        'SCHULUNGENTEILNEHMERID': teilnehmerId,
        'BEZEICHNUNG': bezeichnung,
        'DATUM': datum,
        'ORT': ort,
        'MAXTEILNEHMER': maxTeilnehmer,
        'TEILNEHMER': teilnehmer,
        'TYP': typ,
        'KOSTEN': kosten,
        'UE': ue,
        'OMKATEGORIEID': omKategorieId,
        'RECHNUNGAN': rechnungAn,
        'VERPFLEGUNGSKOSTEN': verpflegungskosten,
        'UEBERNACHTUNGSKOSTEN': uebernachtungskosten,
        'LEHRMATERIALKOSTEN': lehrmaterialkosten,
        'LEHRGANGSINHALT': lehrgangsinhalt,
        'LEHRGANGSINHALTHTML': lehrgangsinhaltHtml,
        'WEBGRUPPE': webgruppe,
        'FUERVERLAENGERUNGEN': fuerVerlaengerungen,
      };

  @override
  String toString() {
    return 'Schulung(id: $id, bezeichnung: $bezeichnung, datum: $datum)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Schulung &&
        other.id == id &&
        other.teilnehmerId == teilnehmerId &&
        other.bezeichnung == bezeichnung &&
        other.datum == datum &&
        other.ort == ort &&
        other.maxTeilnehmer == maxTeilnehmer &&
        other.teilnehmer == teilnehmer &&
        other.typ == typ &&
        other.kosten == kosten &&
        other.ue == ue &&
        other.omKategorieId == omKategorieId &&
        other.rechnungAn == rechnungAn &&
        other.verpflegungskosten == verpflegungskosten &&
        other.uebernachtungskosten == uebernachtungskosten &&
        other.lehrmaterialkosten == lehrmaterialkosten &&
        other.lehrgangsinhalt == lehrgangsinhalt &&
        other.lehrgangsinhaltHtml == lehrgangsinhaltHtml &&
        other.webgruppe == webgruppe &&
        other.fuerVerlaengerungen == fuerVerlaengerungen;
  }

  @override
  int get hashCode => Object.hash(
        id,
        teilnehmerId,
        bezeichnung,
        datum,
        ort,
        maxTeilnehmer,
        teilnehmer,
        typ,
        kosten,
        ue,
        omKategorieId,
        rechnungAn,
        verpflegungskosten,
        uebernachtungskosten,
        lehrmaterialkosten,
        lehrgangsinhalt,
        lehrgangsinhaltHtml,
        webgruppe,
        fuerVerlaengerungen,
      );
}
