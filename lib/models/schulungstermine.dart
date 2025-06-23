class Schulungstermine {
  factory Schulungstermine.fromJson(Map<String, dynamic> json) {
    return Schulungstermine(
      schulungsterminId: json['SCHULUNGENTERMINID'] as int,
      schulungsartId: json['SCHULUNGSARTID'] as int,
      datum: DateTime.parse(json['DATUM'] as String),
      bemerkung: json['BEMERKUNG'] as String,
      kosten: (json['KOSTEN'] as num).toDouble(),
      ort: json['ORT'] as String,
      lehrgangsleiter: json['LEHRGANGSLEITER'] as String,
      verpflegungskosten: (json['VERPFLEGUNGSKOSTEN'] as num).toDouble(),
      uebernachtungskosten: (json['UEBERNACHTUNGSKOSTEN'] as num).toDouble(),
      lehrmaterialkosten: (json['LEHRMATERIALKOSTEN'] as num).toDouble(),
      lehrgangsinhalt: json['LEHRGANGSINHALT'] as String,
      maxTeilnehmer: json['MAXTEILNEHMER'] as int,
      webVeroeffentlichenAm: json['WEBVEROEFFENTLICHENAM'] as String,
      anmeldungenGesperrt: json['ANMELDUNGENGESPERRT'] as bool,
      status: json['STATUS'] as int,
      datumBis: json['DATUMBIS'] as String,
      lehrgangsinhaltHtml: json['LEHRGANGSINHALTHTML'] as String,
      lehrgangsleiter2: json['LEHRGANGSLEITER2'] as String,
      lehrgangsleiter3: json['LEHRGANGSLEITER3'] as String,
      lehrgangsleiter4: json['LEHRGANGSLEITER4'] as String,
      lehrgangsleiterTel: json['LEHRGANGSLEITERTEL'] as String,
      lehrgangsleiter2Tel: json['LEHRGANGSLEITER2TEL'] as String,
      lehrgangsleiter3Tel: json['LEHRGANGSLEITER3TEL'] as String,
      lehrgangsleiter4Tel: json['LEHRGANGSLEITER4TEL'] as String,
      lehrgangsleiterMail: json['LEHRGANGSLEITERMAIL'] as String,
      lehrgangsleiter2Mail: json['LEHRGANGSLEITER2MAIL'] as String,
      lehrgangsleiter3Mail: json['LEHRGANGSLEITER3MAIL'] as String,
      lehrgangsleiter4Mail: json['LEHRGANGSLEITER4MAIL'] as String,
      anmeldeStopp: json['ANMELDESTOPP'] as String,
      abmeldeStopp: json['ABMELDESTOPP'] as String,
      geloescht: json['GELOESCHT'] as bool,
      stornoGrund: json['STORNOGRUND'] as String,
      webGruppe: json['WEBGRUPPE'] as int,
      veranstaltungsBezirk: json['VERANSTALTUNGSBEZIRK'] as int,
      fuerVerlaengerungen: json['FUERVERLAENGERUNGEN'] as bool,
      anmeldeErlaubt: json['ANMELDENERLAUBT'] as int,
      verbandsInternPasswort: json['VERBANDSINTERNPASSWORT'] as String,
      bezeichnung: json['BEZEICHNUNG'] as String,
      angemeldeteTeilnehmer: json['ANGEMELDETETEILNEHMER'] as int,
    );
  }

  Schulungstermine({
    required this.schulungsterminId,
    required this.schulungsartId,
    required this.datum,
    required this.bemerkung,
    required this.kosten,
    required this.ort,
    required this.lehrgangsleiter,
    required this.verpflegungskosten,
    required this.uebernachtungskosten,
    required this.lehrmaterialkosten,
    required this.lehrgangsinhalt,
    required this.maxTeilnehmer,
    required this.webVeroeffentlichenAm,
    required this.anmeldungenGesperrt,
    required this.status,
    required this.datumBis,
    required this.lehrgangsinhaltHtml,
    required this.lehrgangsleiter2,
    required this.lehrgangsleiter3,
    required this.lehrgangsleiter4,
    required this.lehrgangsleiterTel,
    required this.lehrgangsleiter2Tel,
    required this.lehrgangsleiter3Tel,
    required this.lehrgangsleiter4Tel,
    required this.lehrgangsleiterMail,
    required this.lehrgangsleiter2Mail,
    required this.lehrgangsleiter3Mail,
    required this.lehrgangsleiter4Mail,
    required this.anmeldeStopp,
    required this.abmeldeStopp,
    required this.geloescht,
    required this.stornoGrund,
    required this.webGruppe,
    required this.veranstaltungsBezirk,
    required this.fuerVerlaengerungen,
    required this.anmeldeErlaubt,
    required this.verbandsInternPasswort,
    required this.bezeichnung,
    required this.angemeldeteTeilnehmer,
  });
  final int schulungsterminId;
  final int schulungsartId;
  final DateTime datum;
  final String bemerkung;
  final double kosten;
  final String ort;
  final String lehrgangsleiter;
  final double verpflegungskosten;
  final double uebernachtungskosten;
  final double lehrmaterialkosten;
  final String lehrgangsinhalt;
  final int maxTeilnehmer;
  final String webVeroeffentlichenAm;
  final bool anmeldungenGesperrt;
  final int status;
  final String datumBis;
  final String lehrgangsinhaltHtml;
  final String lehrgangsleiter2;
  final String lehrgangsleiter3;
  final String lehrgangsleiter4;
  final String lehrgangsleiterTel;
  final String lehrgangsleiter2Tel;
  final String lehrgangsleiter3Tel;
  final String lehrgangsleiter4Tel;
  final String lehrgangsleiterMail;
  final String lehrgangsleiter2Mail;
  final String lehrgangsleiter3Mail;
  final String lehrgangsleiter4Mail;
  final String anmeldeStopp;
  final String abmeldeStopp;
  final bool geloescht;
  final String stornoGrund;
  final int webGruppe;
  final int veranstaltungsBezirk;
  final bool fuerVerlaengerungen;
  final int anmeldeErlaubt;
  final String verbandsInternPasswort;
  final String bezeichnung;
  final int angemeldeteTeilnehmer;

  Map<String, dynamic> toJson() {
    return {
      'SCHULUNGENTERMINID': schulungsterminId,
      'SCHULUNGSARTID': schulungsartId,
      'DATUM': datum.toIso8601String(),
      'BEMERKUNG': bemerkung,
      'KOSTEN': kosten,
      'ORT': ort,
      'LEHRGANGSLEITER': lehrgangsleiter,
      'VERPFLEGUNGSKOSTEN': verpflegungskosten,
      'UEBERNACHTUNGSKOSTEN': uebernachtungskosten,
      'LEHRMATERIALKOSTEN': lehrmaterialkosten,
      'LEHRGANGSINHALT': lehrgangsinhalt,
      'MAXTEILNEHMER': maxTeilnehmer,
      'WEBVEROEFFENTLICHENAM': webVeroeffentlichenAm,
      'ANMELDUNGENGESPERRT': anmeldungenGesperrt,
      'STATUS': status,
      'DATUMBIS': datumBis,
      'LEHRGANGSINHALTHTML': lehrgangsinhaltHtml,
      'LEHRGANGSLEITER2': lehrgangsleiter2,
      'LEHRGANGSLEITER3': lehrgangsleiter3,
      'LEHRGANGSLEITER4': lehrgangsleiter4,
      'LEHRGANGSLEITERTEL': lehrgangsleiterTel,
      'LEHRGANGSLEITER2TEL': lehrgangsleiter2Tel,
      'LEHRGANGSLEITER3TEL': lehrgangsleiter3Tel,
      'LEHRGANGSLEITER4TEL': lehrgangsleiter4Tel,
      'LEHRGANGSLEITERMAIL': lehrgangsleiterMail,
      'LEHRGANGSLEITER2MAIL': lehrgangsleiter2Mail,
      'LEHRGANGSLEITER3MAIL': lehrgangsleiter3Mail,
      'LEHRGANGSLEITER4MAIL': lehrgangsleiter4Mail,
      'ANMELDESTOPP': anmeldeStopp,
      'ABMELDESTOPP': abmeldeStopp,
      'GELOESCHT': geloescht,
      'STORNOGRUND': stornoGrund,
      'WEBGRUPPE': webGruppe,
      'VERANSTALTUNGSBEZIRK': veranstaltungsBezirk,
      'FUERVERLAENGERUNGEN': fuerVerlaengerungen,
      'ANMELDENERLAUBT': anmeldeErlaubt,
      'VERBANDSINTERNPASSWORT': verbandsInternPasswort,
      'BEZEICHNUNG': bezeichnung,
      'ANGEMELDETETEILNEHMER': angemeldeteTeilnehmer,
    };
  }

  @override
  String toString() {
    return 'Schulungstermine(schulungsterminId: $schulungsterminId, '
        'schulungsartId: $schulungsartId, '
        'datum: $datum, '
        'bezeichnung: $bezeichnung, '
        'ort: $ort, '
        'status: $status)';
  }

  String get webGruppeLabel {
    switch (webGruppe) {
      case 1:
        return 'Wettbewerbe';
      case 2:
        return 'Jugend';
      case 3:
        return 'Sport';
      case 4:
        return 'Überfachlich';
      case 5:
        return 'Verbandsintern';
      case 0:
      default:
        return 'nicht zugeordnet';
    }
  }
}
