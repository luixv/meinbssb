import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/schulungstermine.dart';

void main() {
  group('Schulungstermine', () {
    test('creates instance from JSON', () {
      final json = {
        'SCHULUNGENTERMINID': 1691,
        'SCHULUNGSARTID': 15,
        'DATUM': '2025-12-28T00:00:00.000+01:00',
        'BEMERKUNG': '',
        'KOSTEN': 72.07,
        'ORT': 'Online',
        'LEHRGANGSLEITER': '',
        'VERPFLEGUNGSKOSTEN': 0.0,
        'UEBERNACHTUNGSKOSTEN': 0.0,
        'LEHRMATERIALKOSTEN': 0.0,
        'LEHRGANGSINHALT': 'Test content',
        'MAXTEILNEHMER': 30,
        'WEBVEROEFFENTLICHENAM': '',
        'ANMELDUNGENGESPERRT': false,
        'STATUS': 2,
        'DATUMBIS': '',
        'LEHRGANGSINHALTHTML': '<p>Test HTML</p>',
        'LEHRGANGSLEITER2': '',
        'LEHRGANGSLEITER3': '',
        'LEHRGANGSLEITER4': '',
        'LEHRGANGSLEITERTEL': '089/316949-16',
        'LEHRGANGSLEITER2TEL': '',
        'LEHRGANGSLEITER3TEL': '',
        'LEHRGANGSLEITER4TEL': '',
        'LEHRGANGSLEITERMAIL': 'sabine.freitag@bssb.bayern',
        'LEHRGANGSLEITER2MAIL': '',
        'LEHRGANGSLEITER3MAIL': '',
        'LEHRGANGSLEITER4MAIL': '',
        'ANMELDESTOPP': '',
        'ABMELDESTOPP': '',
        'GELOESCHT': false,
        'STORNOGRUND': 'Test - Teams Besprechnung 03.03.2025 - Gerhard Reile',
        'WEBGRUPPE': 4,
        'VERANSTALTUNGSBEZIRK': 4,
        'FUERVERLAENGERUNGEN': true,
        'ANMELDENERLAUBT': 0,
        'VERBANDSINTERNPASSWORT': '',
        'BEZEICHNUNG': 'Der Sportleiter im Verein / Kugeldisziplinen',
        'ANGEMELDETETEILNEHMER': 1,
      };

      final schulungstermine = Schulungstermine.fromJson(json);

      expect(schulungstermine.schulungsterminId, 1691);
      expect(schulungstermine.schulungsartId, 15);
      expect(
        schulungstermine.datum,
        DateTime.parse('2025-12-28T00:00:00.000+01:00'),
      );
      expect(schulungstermine.bemerkung, '');
      expect(schulungstermine.kosten, 72.07);
      expect(schulungstermine.ort, 'Online');
      expect(schulungstermine.lehrgangsleiter, '');
      expect(schulungstermine.verpflegungskosten, 0.0);
      expect(schulungstermine.uebernachtungskosten, 0.0);
      expect(schulungstermine.lehrmaterialkosten, 0.0);
      expect(schulungstermine.lehrgangsinhalt, 'Test content');
      expect(schulungstermine.maxTeilnehmer, 30);
      expect(schulungstermine.webVeroeffentlichenAm, '');
      expect(schulungstermine.anmeldungenGesperrt, false);
      expect(schulungstermine.status, 2);
      expect(schulungstermine.datumBis, '');
      expect(schulungstermine.lehrgangsinhaltHtml, '<p>Test HTML</p>');
      expect(schulungstermine.lehrgangsleiterTel, '089/316949-16');
      expect(
        schulungstermine.lehrgangsleiterMail,
        'sabine.freitag@bssb.bayern',
      );
      expect(schulungstermine.geloescht, false);
      expect(
        schulungstermine.stornoGrund,
        'Test - Teams Besprechnung 03.03.2025 - Gerhard Reile',
      );
      expect(schulungstermine.webGruppe, 4);
      expect(schulungstermine.veranstaltungsBezirk, 4);
      expect(schulungstermine.fuerVerlaengerungen, true);
      expect(schulungstermine.anmeldeErlaubt, 0);
      expect(schulungstermine.verbandsInternPasswort, '');
      expect(
        schulungstermine.bezeichnung,
        'Der Sportleiter im Verein / Kugeldisziplinen',
      );
      expect(schulungstermine.angemeldeteTeilnehmer, 1);
    });

    test('converts to JSON', () {
      final schulungstermine = Schulungstermine(
        schulungsterminId: 1691,
        schulungsartId: 15,
        datum: DateTime.parse('2025-12-28T00:00:00.000+01:00'),
        bemerkung: '',
        kosten: 72.07,
        ort: 'Online',
        lehrgangsleiter: '',
        verpflegungskosten: 0.0,
        uebernachtungskosten: 0.0,
        lehrmaterialkosten: 0.0,
        lehrgangsinhalt: 'Test content',
        maxTeilnehmer: 30,
        webVeroeffentlichenAm: '',
        anmeldungenGesperrt: false,
        status: 2,
        datumBis: '',
        lehrgangsinhaltHtml: '<p>Test HTML</p>',
        lehrgangsleiter2: '',
        lehrgangsleiter3: '',
        lehrgangsleiter4: '',
        lehrgangsleiterTel: '089/316949-16',
        lehrgangsleiter2Tel: '',
        lehrgangsleiter3Tel: '',
        lehrgangsleiter4Tel: '',
        lehrgangsleiterMail: 'sabine.freitag@bssb.bayern',
        lehrgangsleiter2Mail: '',
        lehrgangsleiter3Mail: '',
        lehrgangsleiter4Mail: '',
        anmeldeStopp: '',
        abmeldeStopp: '',
        geloescht: false,
        stornoGrund: 'Test - Teams Besprechnung 03.03.2025 - Gerhard Reile',
        webGruppe: 4,
        veranstaltungsBezirk: 4,
        fuerVerlaengerungen: true,
        anmeldeErlaubt: 0,
        verbandsInternPasswort: '',
        bezeichnung: 'Der Sportleiter im Verein / Kugeldisziplinen',
        angemeldeteTeilnehmer: 1,
      );

      final json = schulungstermine.toJson();

      expect(json['SCHULUNGENTERMINID'], 1691);
      expect(json['SCHULUNGSARTID'], 15);
      expect(json['DATUM'], '2025-12-28T00:00:00.000+01:00');
      expect(json['BEMERKUNG'], '');
      expect(json['KOSTEN'], 72.07);
      expect(json['ORT'], 'Online');
      expect(json['LEHRGANGSLEITER'], '');
      expect(json['VERPFLEGUNGSKOSTEN'], 0.0);
      expect(json['UEBERNACHTUNGSKOSTEN'], 0.0);
      expect(json['LEHRMATERIALKOSTEN'], 0.0);
      expect(json['LEHRGANGSINHALT'], 'Test content');
      expect(json['MAXTEILNEHMER'], 30);
      expect(json['WEBVEROEFFENTLICHENAM'], '');
      expect(json['ANMELDUNGENGESPERRT'], false);
      expect(json['STATUS'], 2);
      expect(json['DATUMBIS'], '');
      expect(json['LEHRGANGSINHALTHTML'], '<p>Test HTML</p>');
      expect(json['LEHRGANGSLEITERTEL'], '089/316949-16');
      expect(json['LEHRGANGSLEITERMAIL'], 'sabine.freitag@bssb.bayern');
      expect(json['GELOESCHT'], false);
      expect(
        json['STORNOGRUND'],
        'Test - Teams Besprechnung 03.03.2025 - Gerhard Reile',
      );
      expect(json['WEBGRUPPE'], 4);
      expect(json['VERANSTALTUNGSBEZIRK'], 4);
      expect(json['FUERVERLAENGERUNGEN'], true);
      expect(json['ANMELDENERLAUBT'], 0);
      expect(json['VERBANDSINTERNPASSWORT'], '');
      expect(
        json['BEZEICHNUNG'],
        'Der Sportleiter im Verein / Kugeldisziplinen',
      );
      expect(json['ANGEMELDETETEILNEHMER'], 1);
    });

    test('toString returns correct format', () {
      final schulungstermine = Schulungstermine(
        schulungsterminId: 1691,
        schulungsartId: 15,
        datum: DateTime.parse('2025-12-28T00:00:00.000+01:00'),
        bemerkung: '',
        kosten: 72.07,
        ort: 'Online',
        lehrgangsleiter: '',
        verpflegungskosten: 0.0,
        uebernachtungskosten: 0.0,
        lehrmaterialkosten: 0.0,
        lehrgangsinhalt: 'Test content',
        maxTeilnehmer: 30,
        webVeroeffentlichenAm: '',
        anmeldungenGesperrt: false,
        status: 2,
        datumBis: '',
        lehrgangsinhaltHtml: '<p>Test HTML</p>',
        lehrgangsleiter2: '',
        lehrgangsleiter3: '',
        lehrgangsleiter4: '',
        lehrgangsleiterTel: '089/316949-16',
        lehrgangsleiter2Tel: '',
        lehrgangsleiter3Tel: '',
        lehrgangsleiter4Tel: '',
        lehrgangsleiterMail: 'sabine.freitag@bssb.bayern',
        lehrgangsleiter2Mail: '',
        lehrgangsleiter3Mail: '',
        lehrgangsleiter4Mail: '',
        anmeldeStopp: '',
        abmeldeStopp: '',
        geloescht: false,
        stornoGrund: 'Test - Teams Besprechnung 03.03.2025 - Gerhard Reile',
        webGruppe: 4,
        veranstaltungsBezirk: 4,
        fuerVerlaengerungen: true,
        anmeldeErlaubt: 0,
        verbandsInternPasswort: '',
        bezeichnung: 'Der Sportleiter im Verein / Kugeldisziplinen',
        angemeldeteTeilnehmer: 1,
      );

      expect(
        schulungstermine.toString(),
        'Schulungstermine(schulungsterminId: 1691, '
        'schulungsartId: 15, '
        'datum: 2025-12-28 00:00:00.000+01:00, '
        'bezeichnung: Der Sportleiter im Verein / Kugeldisziplinen, '
        'ort: Online, '
        'status: 2)',
      );
    });
  });
}
