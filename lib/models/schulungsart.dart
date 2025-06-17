// Project: Mein BSSB
// Filename: schulungsart.dart
// Author: Luis Mandel / NTT DATA

class Schulungsart {
  const Schulungsart({
    required this.schulungsartId,
    required this.bezeichnung,
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
    required this.webGruppe,
    required this.fuerVerlaengerungen,
  });

  factory Schulungsart.fromJson(Map<String, dynamic> json) {
    return Schulungsart(
      schulungsartId: json['SCHULUNGSARTID'] as int,
      bezeichnung: json['BEZEICHNUNG'] as String,
      typ: json['TYP'] as int,
      kosten: (json['KOSTEN'] as num).toDouble(),
      ue: json['UE'] as int,
      omKategorieId: json['OMKATEGORIEID'] as int,
      rechnungAn: json['RECHNUNGAN'] as int,
      verpflegungskosten: (json['VERPFLEGUNGSKOSTEN'] as num).toDouble(),
      uebernachtungskosten: (json['UEBERNACHTUNGSKOSTEN'] as num).toDouble(),
      lehrmaterialkosten: (json['LEHRMATERIALKOSTEN'] as num).toDouble(),
      lehrgangsinhalt: json['LEHRGANGSINHALT'] as String,
      lehrgangsinhaltHtml: json['LEHRGANGSINHALTHTML'] as String,
      webGruppe: json['WEBGRUPPE'] as int,
      fuerVerlaengerungen: json['FUERVERLAENGERUNGEN'] as bool,
    );
  }
  final int schulungsartId;
  final String bezeichnung;
  final int typ;
  final double kosten;
  final int ue; // Unterrichtseinheiten
  final int omKategorieId;
  final int rechnungAn;
  final double verpflegungskosten;
  final double uebernachtungskosten;
  final double lehrmaterialkosten;
  final String lehrgangsinhalt;
  final String lehrgangsinhaltHtml;
  final int webGruppe;
  final bool fuerVerlaengerungen;

  Map<String, dynamic> toJson() {
    return {
      'SCHULUNGSARTID': schulungsartId,
      'BEZEICHNUNG': bezeichnung,
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
      'WEBGRUPPE': webGruppe,
      'FUERVERLAENGERUNGEN': fuerVerlaengerungen,
    };
  }

  @override
  String toString() {
    return 'Schulungsart(schulungsartId: $schulungsartId, bezeichnung: $bezeichnung, typ: $typ)';
  }
}
