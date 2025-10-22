import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/schulungstermin_data.dart';

void main() {
  group('Schulungstermin', () {
    test('creates instance from JSON', () {
      final json = {
        'SCHULUNGENTERMINID': 1012,
        'SCHULUNGSARTID': 15,
        'SCHULUNGENTEILNEHMERID': 12345,
        'DATUM': '2022-12-11T00:00:00.000+01:00',
        'BEMERKUNG': '',
        'KOSTEN': 40,
        'ORT': 'Garching-Hochbrück',
        'LEHRGANGSLEITER': 'Lederer, Förg',
        'VERPFLEGUNGSKOSTEN': 0,
        'UEBERNACHTUNGSKOSTEN': 0,
        'LEHRMATERIALKOSTEN': 0,
        'MAXTEILNEHMER': 15,
        'WEBVEROEFFENTLICHENAM': '',
        'ANMELDUNGENGESPERRT': true,
        'STATUS': 1,
        'DATUMBIS': '',
        'LEHRGANGSINHALTHTML':
            '<span style="color:#333"><b>Beschreibung</b><br><b>Inhalt:</b><br>Immer vielfältiger werden die Aufgaben eines Vereins-Sportleiters….</span>',
        'LEHRGANGSLEITER2': '',
        'LEHRGANGSLEITER3': '',
        'LEHRGANGSLEITER4': '',
        'LEHRGANGSLEITERTEL': '',
        'LEHRGANGSLEITER2TEL': '',
        'LEHRGANGSLEITER3TEL': '',
        'LEHRGANGSLEITER4TEL': '',
        'LEHRGANGSLEITERMAIL': '',
        'LEHRGANGSLEITER2MAIL': '',
        'LEHRGANGSLEITER3MAIL': '',
        'LEHRGANGSLEITER4MAIL': '',
        'ANMELDESTOPP': '2022-11-29T00:00:00.000+01:00',
        'ABMELDESTOPP': '2022-11-29T00:00:00.000+01:00',
        'GELOESCHT': false,
        'STORNOGRUND': '',
        'WEBGRUPPE': 4,
        'VERANSTALTUNGSBEZIRK': 0,
        'FUERVERLAENGERUNGEN': true,
        'FUERVUELVERLAENGERUNGEN': true,
        'ANMELDENERLAUBT': 0,
        'VERBANDSINTERNPASSWORT': '',
        'BEZEICHNUNG': 'Der Sportleiter im Verein / Kugeldisziplinen',
        'ANGEMELDETETEILNEHMER': 25,
      };

      final schulungstermin = Schulungstermin.fromJson(json);

      expect(schulungstermin.schulungsterminId, 1012);
      expect(schulungstermin.schulungsartId, 15);
      expect(schulungstermin.schulungsTeilnehmerId, 12345);
      expect(schulungstermin.datum, DateTime(2022, 12, 11, 0, 0, 0, 0, 0));
      expect(schulungstermin.bemerkung, '');
      expect(schulungstermin.kosten, 40);
      expect(schulungstermin.ort, 'Garching-Hochbrück');
      expect(schulungstermin.lehrgangsleiter, 'Lederer, Förg');
      expect(schulungstermin.verpflegungskosten, 0);
      expect(schulungstermin.uebernachtungskosten, 0);
      expect(schulungstermin.lehrmaterialkosten, 0);
      expect(schulungstermin.maxTeilnehmer, 15);
      expect(schulungstermin.webVeroeffentlichenAm, '');
      expect(schulungstermin.anmeldungenGesperrt, true);
      expect(schulungstermin.status, 1);
      expect(schulungstermin.datumBis, '');
      expect(
        schulungstermin.lehrgangsinhaltHtml,
        '<span style="color:#333"><b>Beschreibung</b><br><b>Inhalt:</b><br>Immer vielfältiger werden die Aufgaben eines Vereins-Sportleiters….</span>',
      );
      expect(schulungstermin.lehrgangsleiter2, '');
      expect(schulungstermin.lehrgangsleiter3, '');
      expect(schulungstermin.lehrgangsleiter4, '');
      expect(schulungstermin.lehrgangsleiterTel, '');
      expect(schulungstermin.lehrgangsleiter2Tel, '');
      expect(schulungstermin.lehrgangsleiter3Tel, '');
      expect(schulungstermin.lehrgangsleiter4Tel, '');
      expect(schulungstermin.lehrgangsleiterMail, '');
      expect(schulungstermin.lehrgangsleiter2Mail, '');
      expect(schulungstermin.lehrgangsleiter3Mail, '');
      expect(schulungstermin.lehrgangsleiter4Mail, '');
      expect(schulungstermin.anmeldeStopp, '2022-11-29T00:00:00.000+01:00');
      expect(schulungstermin.abmeldeStopp, '2022-11-29T00:00:00.000+01:00');
      expect(schulungstermin.geloescht, false);
      expect(schulungstermin.stornoGrund, '');
      expect(schulungstermin.webGruppe, 4);
      expect(schulungstermin.veranstaltungsBezirk, 0);
      expect(schulungstermin.fuerVerlaengerungen, true);
      expect(schulungstermin.fuerVuelVerlaengerungen, true);
      expect(schulungstermin.anmeldeErlaubt, 0);
      expect(schulungstermin.verbandsInternPasswort, '');
      expect(
        schulungstermin.bezeichnung,
        'Der Sportleiter im Verein / Kugeldisziplinen',
      );
      expect(schulungstermin.angemeldeteTeilnehmer, 25);
    });

    test('converts to JSON', () {
      final schulungstermin = Schulungstermin(
        schulungsterminId: 1012,
        schulungsartId: 15,
        schulungsTeilnehmerId: 12345,
        datum: DateTime(2022, 12, 11, 0, 0, 0, 0, 0),
        bemerkung: '',
        kosten: 40,
        ort: 'Garching-Hochbrück',
        lehrgangsleiter: 'Lederer, Förg',
        verpflegungskosten: 0,
        uebernachtungskosten: 0,
        lehrmaterialkosten: 0,
        lehrgangsinhalt: '',
        maxTeilnehmer: 15,
        webVeroeffentlichenAm: '',
        anmeldungenGesperrt: true,
        status: 1,
        datumBis: '',
        lehrgangsinhaltHtml:
            '<span style="color:#333"><b>Beschreibung</b><br><b>Inhalt:</b><br>Immer vielfältiger werden die Aufgaben eines Vereins-Sportleiters….</span>',
        lehrgangsleiter2: '',
        lehrgangsleiter3: '',
        lehrgangsleiter4: '',
        lehrgangsleiterTel: '',
        lehrgangsleiter2Tel: '',
        lehrgangsleiter3Tel: '',
        lehrgangsleiter4Tel: '',
        lehrgangsleiterMail: '',
        lehrgangsleiter2Mail: '',
        lehrgangsleiter3Mail: '',
        lehrgangsleiter4Mail: '',
        anmeldeStopp: '2022-11-29T00:00:00.000+01:00',
        abmeldeStopp: '2022-11-29T00:00:00.000+01:00',
        geloescht: false,
        stornoGrund: '',
        webGruppe: 4,
        veranstaltungsBezirk: 0,
        fuerVerlaengerungen: true,
        fuerVuelVerlaengerungen: true,
        anmeldeErlaubt: 0,
        verbandsInternPasswort: '',
        bezeichnung: 'Der Sportleiter im Verein / Kugeldisziplinen',
        angemeldeteTeilnehmer: 25,
      );

      final json = schulungstermin.toJson();

      expect(json['SCHULUNGENTERMINID'], 1012);
      expect(json['SCHULUNGSARTID'], 15);
      expect(json['SCHULUNGENTEILNEHMERID'], 12345);
      expect(json['DATUM'], '2022-12-11T00:00:00.000');
      expect(json['BEMERKUNG'], '');
      expect(json['KOSTEN'], 40);
      expect(json['ORT'], 'Garching-Hochbrück');
      expect(json['LEHRGANGSLEITER'], 'Lederer, Förg');
      expect(json['VERPFLEGUNGSKOSTEN'], 0);
      expect(json['UEBERNACHTUNGSKOSTEN'], 0);
      expect(json['LEHRMATERIALKOSTEN'], 0);
      expect(json['MAXTEILNEHMER'], 15);
      expect(json['WEBVEROEFFENTLICHENAM'], '');
      expect(json['ANMELDUNGENGESPERRT'], true);
      expect(json['STATUS'], 1);
      expect(json['DATUMBIS'], '');
      expect(
        json['LEHRGANGSINHALTHTML'],
        '<span style="color:#333"><b>Beschreibung</b><br><b>Inhalt:</b><br>Immer vielfältiger werden die Aufgaben eines Vereins-Sportleiters….</span>',
      );
      expect(json['LEHRGANGSLEITER2'], '');
      expect(json['LEHRGANGSLEITER3'], '');
      expect(json['LEHRGANGSLEITER4'], '');
      expect(json['LEHRGANGSLEITERTEL'], '');
      expect(json['LEHRGANGSLEITER2TEL'], '');
      expect(json['LEHRGANGSLEITER3TEL'], '');
      expect(json['LEHRGANGSLEITER4TEL'], '');
      expect(json['LEHRGANGSLEITERMAIL'], '');
      expect(json['LEHRGANGSLEITER2MAIL'], '');
      expect(json['LEHRGANGSLEITER3MAIL'], '');
      expect(json['LEHRGANGSLEITER4MAIL'], '');
      expect(json['ANMELDESTOPP'], '2022-11-29T00:00:00.000+01:00');
      expect(json['ABMELDESTOPP'], '2022-11-29T00:00:00.000+01:00');
      expect(json['GELOESCHT'], false);
      expect(json['STORNOGRUND'], '');
      expect(json['WEBGRUPPE'], 4);
      expect(json['VERANSTALTUNGSBEZIRK'], 0);
      expect(json['FUERVERLAENGERUNGEN'], true);
      expect(json['FUERVUELVERLAENGERUNGEN'], true);
      expect(json['ANMELDENERLAUBT'], 0);
      expect(json['VERBANDSINTERNPASSWORT'], '');
      expect(
        json['BEZEICHNUNG'],
        'Der Sportleiter im Verein / Kugeldisziplinen',
      );
      expect(json['ANGEMELDETETEILNEHMER'], 25);
    });

    test('toString returns correct format', () {
      final schulungstermin = Schulungstermin(
        schulungsterminId: 1012,
        schulungsartId: 15,
        schulungsTeilnehmerId: 12345,
        datum: DateTime(2022, 12, 11, 0, 0, 0, 0, 0),
        bemerkung: '',
        kosten: 40,
        ort: 'Garching-Hochbrück',
        lehrgangsleiter: 'Lederer, Förg',
        verpflegungskosten: 0,
        uebernachtungskosten: 0,
        lehrmaterialkosten: 0,
        lehrgangsinhalt: '',
        maxTeilnehmer: 15,
        webVeroeffentlichenAm: '',
        anmeldungenGesperrt: true,
        status: 1,
        datumBis: '',
        lehrgangsinhaltHtml:
            '<span style="color:#333"><b>Beschreibung</b><br><b>Inhalt:</b><br>Immer vielfältiger werden die Aufgaben eines Vereins-Sportleiters….</span>',
        lehrgangsleiter2: '',
        lehrgangsleiter3: '',
        lehrgangsleiter4: '',
        lehrgangsleiterTel: '',
        lehrgangsleiter2Tel: '',
        lehrgangsleiter3Tel: '',
        lehrgangsleiter4Tel: '',
        lehrgangsleiterMail: '',
        lehrgangsleiter2Mail: '',
        lehrgangsleiter3Mail: '',
        lehrgangsleiter4Mail: '',
        anmeldeStopp: '2022-11-29T00:00:00.000+01:00',
        abmeldeStopp: '2022-11-29T00:00:00.000+01:00',
        geloescht: false,
        stornoGrund: '',
        webGruppe: 4,
        veranstaltungsBezirk: 0,
        fuerVerlaengerungen: true,
        fuerVuelVerlaengerungen: true,
        anmeldeErlaubt: 0,
        verbandsInternPasswort: '',
        bezeichnung: 'Der Sportleiter im Verein / Kugeldisziplinen',
        angemeldeteTeilnehmer: 25,
      );

      expect(
        schulungstermin.toString(),
        'Schulungstermin(schulungsterminId: 1012, '
        'schulungsartId: 15, '
        'schulungsTeilnehmerId: 12345, '
        'datum: 2022-12-11 00:00:00.000, '
        'bezeichnung: Der Sportleiter im Verein / Kugeldisziplinen, '
        'ort: Garching-Hochbrück, '
        'status: 1)',
      );
    });
  });
}
