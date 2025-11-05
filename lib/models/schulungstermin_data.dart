import 'package:meinbssb/helpers/utils.dart';

class Schulungstermin {
  Schulungstermin({
    required this.schulungsterminId,
    required this.schulungsartId,
    required this.schulungsTeilnehmerId,
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
    required this.fuerVuelVerlaengerungen,
    required this.anmeldeErlaubt,
    required this.verbandsInternPasswort,
    required this.bezeichnung,
    required this.angemeldeteTeilnehmer,
  });
  factory Schulungstermin.fromJson(Map<String, dynamic> json) {
    try {
      return Schulungstermin(
        schulungsterminId: json['SCHULUNGENTERMINID'] as int? ?? 0,
        schulungsartId: json['SCHULUNGSARTID'] as int? ?? 0,
        schulungsTeilnehmerId: json['SCHULUNGENTEILNEHMERID'] as int? ?? 0,
        datum: parseDate(json['DATUM']),
        bemerkung: json['BEMERKUNG'] as String? ?? '',
        kosten: (json['KOSTEN'] as num?)?.toDouble() ?? 0.0,
        ort: json['ORT'] as String? ?? '',
        lehrgangsleiter: json['LEHRGANGSLEITER'] as String? ?? '',
        verpflegungskosten:
            (json['VERPFLEGUNGSKOSTEN'] as num?)?.toDouble() ?? 0.0,
        uebernachtungskosten:
            (json['UEBERNACHTUNGSKOSTEN'] as num?)?.toDouble() ?? 0.0,
        lehrmaterialkosten:
            (json['LEHRMATERIALKOSTEN'] as num?)?.toDouble() ?? 0.0,
        lehrgangsinhalt: json['LEHRGANGSINHALT'] as String? ?? '',
        maxTeilnehmer: json['MAXTEILNEHMER'] as int? ?? 0,
        webVeroeffentlichenAm: json['WEBVEROEFFENTLICHENAM'] as String? ?? '',
        anmeldungenGesperrt: json['ANMELDUNGENGESPERRT'] as bool? ?? false,
        status: json['STATUS'] as int? ?? 0,
        datumBis: json['DATUMBIS'] as String? ?? '',
        lehrgangsinhaltHtml: json['LEHRGANGSINHALTHTML'] as String? ?? '',
        lehrgangsleiter2: json['LEHRGANGSLEITER2'] as String? ?? '',
        lehrgangsleiter3: json['LEHRGANGSLEITER3'] as String? ?? '',
        lehrgangsleiter4: json['LEHRGANGSLEITER4'] as String? ?? '',
        lehrgangsleiterTel: json['LEHRGANGSLEITERTEL'] as String? ?? '',
        lehrgangsleiter2Tel: json['LEHRGANGSLEITER2TEL'] as String? ?? '',
        lehrgangsleiter3Tel: json['LEHRGANGSLEITER3TEL'] as String? ?? '',
        lehrgangsleiter4Tel: json['LEHRGANGSLEITER4TEL'] as String? ?? '',
        lehrgangsleiterMail: json['LEHRGANGSLEITERMAIL'] as String? ?? '',
        lehrgangsleiter2Mail: json['LEHRGANGSLEITER2MAIL'] as String? ?? '',
        lehrgangsleiter3Mail: json['LEHRGANGSLEITER3MAIL'] as String? ?? '',
        lehrgangsleiter4Mail: json['LEHRGANGSLEITER4MAIL'] as String? ?? '',
        anmeldeStopp: json['ANMELDESTOPP'] as String? ?? '',
        abmeldeStopp: json['ABMELDESTOPP'] as String? ?? '',
        geloescht: json['GELOESCHT'] as bool? ?? false,
        stornoGrund: json['STORNOGRUND'] as String? ?? '',
        webGruppe: json['WEBGRUPPE'] as int? ?? 0,
        veranstaltungsBezirk: json['VERANSTALTUNGSBEZIRK'] as int? ?? 0,
        fuerVerlaengerungen: json['FUERVERLAENGERUNGEN'] as bool? ?? false,
        fuerVuelVerlaengerungen:
            json['FUERVUELVERLAENGERUNGEN'] as bool? ?? false,
        anmeldeErlaubt: json['ANMELDENERLAUBT'] as int? ?? 0,
        verbandsInternPasswort: json['VERBANDSINTERNPASSWORT'] as String? ?? '',
        bezeichnung: json['BEZEICHNUNG'] as String? ?? '',
        angemeldeteTeilnehmer: json['ANGEMELDETETEILNEHMER'] as int? ?? 0,
      );
    } catch (e) {
      rethrow;
    }
  }

  final int schulungsterminId;
  final int schulungsartId;
  int schulungsTeilnehmerId;
  int get getSchulungsTeilnehmerId => schulungsTeilnehmerId;
  set setSchulungsTeilnehmerId(int value) => schulungsTeilnehmerId = value;
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
  final bool fuerVuelVerlaengerungen;
  final int anmeldeErlaubt;
  final String verbandsInternPasswort;
  final String bezeichnung;
  final int angemeldeteTeilnehmer;

  Map<String, dynamic> toJson() {
    return {
      'SCHULUNGENTERMINID': schulungsterminId,
      'SCHULUNGSARTID': schulungsartId,
      'SCHULUNGENTEILNEHMERID': schulungsTeilnehmerId,
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
      'FUERVUELVERLAENGERUNGEN': fuerVuelVerlaengerungen,
      'ANMELDENERLAUBT': anmeldeErlaubt,
      'VERBANDSINTERNPASSWORT': verbandsInternPasswort,
      'BEZEICHNUNG': bezeichnung,
      'ANGEMELDETETEILNEHMER': angemeldeteTeilnehmer,
    };
  }

  @override
  String toString() {
    return 'Schulungstermin(schulungsterminId: $schulungsterminId, '
        'schulungsartId: $schulungsartId, '
        'schulungsTeilnehmerId: $schulungsTeilnehmerId, '
        'datum: $datum, '
        'bezeichnung: $bezeichnung, '
        'ort: $ort, '
        'status: $status)';
  }

  String get webGruppeLabel {
    return webGruppeMap[webGruppe] ?? 'nicht zugeordnet';
  }

  static const Map<int, String> webGruppeMap = {
    0: 'Alle',
    1: 'Jugend',
    2: 'Sport',
    3: 'Überfachlich',
  };
}
