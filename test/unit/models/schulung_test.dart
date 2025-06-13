import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/schulung.dart';

void main() {
  group('Schulung', () {
    test('creates Schulung from JSON with all fields', () {
      final json = {
        'ID': 1,
        'BEZEICHNUNG': 'Test Training',
        'DATUM': '2024-01-01',
        'AUSGESTELLTAM': '2023-12-01',
        'TEILNEHMERID': 123,
        'SCHULUNGSARTID': 456,
        'SCHULUNGSARTBEZEICHNUNG': 'Basic Training',
        'SCHULUNGSARTKURZBEZEICHNUNG': 'BT',
        'SCHULUNGSARTBESCHREIBUNG': 'Basic training description',
        'MAXTEILNEHMER': 20,
        'ANZAHLTEILNEHMER': 15,
        'ORT': 'Test Location',
        'UHRZEIT': '09:00',
        'DAUER': '2 hours',
        'PREIS': '50€',
        'ZIELGRUPPE': 'Beginners',
        'VORAUSSETZUNGEN': 'None',
        'INHALT': 'Training content',
        'ABSCHLUSS': 'Certificate',
        'ANMERKUNGEN': 'Additional notes',
        'ISONLINE': true,
        'LINK': 'https://test.com',
        'STATUS': 'Active',
        'GUELTIGBIS': '2024-12-31',
      };

      final schulung = Schulung.fromJson(json);

      expect(schulung.id, equals(1));
      expect(schulung.bezeichnung, equals('Test Training'));
      expect(schulung.datum, equals('2024-01-01'));
      expect(schulung.ausgestelltAm, equals('2023-12-01'));
      expect(schulung.teilnehmerId, equals(123));
      expect(schulung.schulungsartId, equals(456));
      expect(schulung.schulungsartBezeichnung, equals('Basic Training'));
      expect(schulung.schulungsartKurzbezeichnung, equals('BT'));
      expect(
        schulung.schulungsartBeschreibung,
        equals('Basic training description'),
      );
      expect(schulung.maxTeilnehmer, equals(20));
      expect(schulung.anzahlTeilnehmer, equals(15));
      expect(schulung.ort, equals('Test Location'));
      expect(schulung.uhrzeit, equals('09:00'));
      expect(schulung.dauer, equals('2 hours'));
      expect(schulung.preis, equals('50€'));
      expect(schulung.zielgruppe, equals('Beginners'));
      expect(schulung.voraussetzungen, equals('None'));
      expect(schulung.inhalt, equals('Training content'));
      expect(schulung.abschluss, equals('Certificate'));
      expect(schulung.anmerkungen, equals('Additional notes'));
      expect(schulung.isOnline, isTrue);
      expect(schulung.link, equals('https://test.com'));
      expect(schulung.status, equals('Active'));
      expect(schulung.gueltigBis, equals('2024-12-31'));
    });

    test('creates Schulung from JSON with missing fields', () {
      final json = {
        'ID': 1,
        'BEZEICHNUNG': 'Test Training',
        // Missing other fields
      };

      final schulung = Schulung.fromJson(json);

      expect(schulung.id, equals(1));
      expect(schulung.bezeichnung, equals('Test Training'));
      expect(schulung.datum, isEmpty);
      expect(schulung.ausgestelltAm, isEmpty);
      expect(schulung.teilnehmerId, equals(0));
      expect(schulung.schulungsartId, equals(0));
      expect(schulung.schulungsartBezeichnung, isEmpty);
      expect(schulung.schulungsartKurzbezeichnung, isEmpty);
      expect(schulung.schulungsartBeschreibung, isEmpty);
      expect(schulung.maxTeilnehmer, equals(0));
      expect(schulung.anzahlTeilnehmer, equals(0));
      expect(schulung.ort, isEmpty);
      expect(schulung.uhrzeit, isEmpty);
      expect(schulung.dauer, isEmpty);
      expect(schulung.preis, isEmpty);
      expect(schulung.zielgruppe, isEmpty);
      expect(schulung.voraussetzungen, isEmpty);
      expect(schulung.inhalt, isEmpty);
      expect(schulung.abschluss, isEmpty);
      expect(schulung.anmerkungen, isEmpty);
      expect(schulung.isOnline, isFalse);
      expect(schulung.link, isEmpty);
      expect(schulung.status, isEmpty);
      expect(schulung.gueltigBis, isEmpty);
    });

    test('converts Schulung to JSON', () {
      const schulung = Schulung(
        id: 1,
        bezeichnung: 'Test Training',
        datum: '2024-01-01',
        ausgestelltAm: '2023-12-01',
        teilnehmerId: 123,
        schulungsartId: 456,
        schulungsartBezeichnung: 'Basic Training',
        schulungsartKurzbezeichnung: 'BT',
        schulungsartBeschreibung: 'Basic training description',
        maxTeilnehmer: 20,
        anzahlTeilnehmer: 15,
        ort: 'Test Location',
        uhrzeit: '09:00',
        dauer: '2 hours',
        preis: '50€',
        zielgruppe: 'Beginners',
        voraussetzungen: 'None',
        inhalt: 'Training content',
        abschluss: 'Certificate',
        anmerkungen: 'Additional notes',
        isOnline: true,
        link: 'https://test.com',
        status: 'Active',
        gueltigBis: '2024-12-31',
      );

      final json = schulung.toJson();

      expect(json['ID'], equals(1));
      expect(json['BEZEICHNUNG'], equals('Test Training'));
      expect(json['DATUM'], equals('2024-01-01'));
      expect(json['AUSGESTELLTAM'], equals('2023-12-01'));
      expect(json['TEILNEHMERID'], equals(123));
      expect(json['SCHULUNGSARTID'], equals(456));
      expect(json['SCHULUNGSARTBEZEICHNUNG'], equals('Basic Training'));
      expect(json['SCHULUNGSARTKURZBEZEICHNUNG'], equals('BT'));
      expect(
        json['SCHULUNGSARTBESCHREIBUNG'],
        equals('Basic training description'),
      );
      expect(json['MAXTEILNEHMER'], equals(20));
      expect(json['ANZAHLTEILNEHMER'], equals(15));
      expect(json['ORT'], equals('Test Location'));
      expect(json['UHRZEIT'], equals('09:00'));
      expect(json['DAUER'], equals('2 hours'));
      expect(json['PREIS'], equals('50€'));
      expect(json['ZIELGRUPPE'], equals('Beginners'));
      expect(json['VORAUSSETZUNGEN'], equals('None'));
      expect(json['INHALT'], equals('Training content'));
      expect(json['ABSCHLUSS'], equals('Certificate'));
      expect(json['ANMERKUNGEN'], equals('Additional notes'));
      expect(json['ISONLINE'], isTrue);
      expect(json['LINK'], equals('https://test.com'));
      expect(json['STATUS'], equals('Active'));
      expect(json['GUELTIGBIS'], equals('2024-12-31'));
    });

    test('equality operator works correctly', () {
      const schulung1 = Schulung(
        id: 1,
        bezeichnung: 'Test Training',
        datum: '2024-01-01',
        ausgestelltAm: '2023-12-01',
        teilnehmerId: 123,
        schulungsartId: 456,
        schulungsartBezeichnung: 'Basic Training',
        schulungsartKurzbezeichnung: 'BT',
        schulungsartBeschreibung: 'Basic training description',
        maxTeilnehmer: 20,
        anzahlTeilnehmer: 15,
        ort: 'Test Location',
        uhrzeit: '09:00',
        dauer: '2 hours',
        preis: '50€',
        zielgruppe: 'Beginners',
        voraussetzungen: 'None',
        inhalt: 'Training content',
        abschluss: 'Certificate',
        anmerkungen: 'Additional notes',
        isOnline: true,
        link: 'https://test.com',
        status: 'Active',
        gueltigBis: '2024-12-31',
      );

      const schulung2 = Schulung(
        id: 1,
        bezeichnung: 'Test Training',
        datum: '2024-01-01',
        ausgestelltAm: '2023-12-01',
        teilnehmerId: 123,
        schulungsartId: 456,
        schulungsartBezeichnung: 'Basic Training',
        schulungsartKurzbezeichnung: 'BT',
        schulungsartBeschreibung: 'Basic training description',
        maxTeilnehmer: 20,
        anzahlTeilnehmer: 15,
        ort: 'Test Location',
        uhrzeit: '09:00',
        dauer: '2 hours',
        preis: '50€',
        zielgruppe: 'Beginners',
        voraussetzungen: 'None',
        inhalt: 'Training content',
        abschluss: 'Certificate',
        anmerkungen: 'Additional notes',
        isOnline: true,
        link: 'https://test.com',
        status: 'Active',
        gueltigBis: '2024-12-31',
      );

      const schulung3 = Schulung(
        id: 2,
        bezeichnung: 'Different Training',
        datum: '2024-02-01',
        ausgestelltAm: '2024-01-01',
        teilnehmerId: 789,
        schulungsartId: 101,
        schulungsartBezeichnung: 'Advanced Training',
        schulungsartKurzbezeichnung: 'AT',
        schulungsartBeschreibung: 'Advanced training description',
        maxTeilnehmer: 10,
        anzahlTeilnehmer: 5,
        ort: 'Different Location',
        uhrzeit: '14:00',
        dauer: '3 hours',
        preis: '100€',
        zielgruppe: 'Advanced',
        voraussetzungen: 'Basic Training',
        inhalt: 'Advanced content',
        abschluss: 'Advanced Certificate',
        anmerkungen: 'Different notes',
        isOnline: false,
        link: 'https://different.com',
        status: 'Pending',
        gueltigBis: '2024-06-30',
      );

      expect(schulung1, equals(schulung2));
      expect(schulung1, isNot(equals(schulung3)));
    });

    test('hashCode is consistent with equality', () {
      const schulung1 = Schulung(
        id: 1,
        bezeichnung: 'Test Training',
        datum: '2024-01-01',
        ausgestelltAm: '2023-12-01',
        teilnehmerId: 123,
        schulungsartId: 456,
        schulungsartBezeichnung: 'Basic Training',
        schulungsartKurzbezeichnung: 'BT',
        schulungsartBeschreibung: 'Basic training description',
        maxTeilnehmer: 20,
        anzahlTeilnehmer: 15,
        ort: 'Test Location',
        uhrzeit: '09:00',
        dauer: '2 hours',
        preis: '50€',
        zielgruppe: 'Beginners',
        voraussetzungen: 'None',
        inhalt: 'Training content',
        abschluss: 'Certificate',
        anmerkungen: 'Additional notes',
        isOnline: true,
        link: 'https://test.com',
        status: 'Active',
        gueltigBis: '2024-12-31',
      );

      const schulung2 = Schulung(
        id: 1,
        bezeichnung: 'Test Training',
        datum: '2024-01-01',
        ausgestelltAm: '2023-12-01',
        teilnehmerId: 123,
        schulungsartId: 456,
        schulungsartBezeichnung: 'Basic Training',
        schulungsartKurzbezeichnung: 'BT',
        schulungsartBeschreibung: 'Basic training description',
        maxTeilnehmer: 20,
        anzahlTeilnehmer: 15,
        ort: 'Test Location',
        uhrzeit: '09:00',
        dauer: '2 hours',
        preis: '50€',
        zielgruppe: 'Beginners',
        voraussetzungen: 'None',
        inhalt: 'Training content',
        abschluss: 'Certificate',
        anmerkungen: 'Additional notes',
        isOnline: true,
        link: 'https://test.com',
        status: 'Active',
        gueltigBis: '2024-12-31',
      );

      expect(schulung1.hashCode, equals(schulung2.hashCode));
    });

    test('toString returns correct representation', () {
      const schulung = Schulung(
        id: 1,
        bezeichnung: 'Test Training',
        datum: '2024-01-01',
        ausgestelltAm: '2023-12-01',
        teilnehmerId: 123,
        schulungsartId: 456,
        schulungsartBezeichnung: 'Basic Training',
        schulungsartKurzbezeichnung: 'BT',
        schulungsartBeschreibung: 'Basic training description',
        maxTeilnehmer: 20,
        anzahlTeilnehmer: 15,
        ort: 'Test Location',
        uhrzeit: '09:00',
        dauer: '2 hours',
        preis: '50€',
        zielgruppe: 'Beginners',
        voraussetzungen: 'None',
        inhalt: 'Training content',
        abschluss: 'Certificate',
        anmerkungen: 'Additional notes',
        isOnline: true,
        link: 'https://test.com',
        status: 'Active',
        gueltigBis: '2024-12-31',
      );

      expect(
        schulung.toString(),
        equals(
          'Schulung(id: 1, bezeichnung: Test Training, datum: 2024-01-01, '
          'ausgestelltAm: 2023-12-01, teilnehmerId: 123, schulungsartId: 456, '
          'schulungsartBezeichnung: Basic Training, schulungsartKurzbezeichnung: BT, '
          'schulungsartBeschreibung: Basic training description, maxTeilnehmer: 20, '
          'anzahlTeilnehmer: 15, ort: Test Location, uhrzeit: 09:00, dauer: 2 hours, '
          'preis: 50€, zielgruppe: Beginners, voraussetzungen: None, '
          'inhalt: Training content, abschluss: Certificate, '
          'anmerkungen: Additional notes, isOnline: true, link: https://test.com, '
          'status: Active, gueltigBis: 2024-12-31)',
        ),
      );
    });

    test('handles null values in JSON', () {
      final json = {
        'ID': 1,
        'BEZEICHNUNG': 'Test Training',
        'DATUM': null,
        'AUSGESTELLTAM': null,
        'TEILNEHMERID': null,
        'SCHULUNGSARTID': null,
        'SCHULUNGSARTBEZEICHNUNG': null,
        'SCHULUNGSARTKURZBEZEICHNUNG': null,
        'SCHULUNGSARTBESCHREIBUNG': null,
        'MAXTEILNEHMER': null,
        'ANZAHLTEILNEHMER': null,
        'ORT': null,
        'UHRZEIT': null,
        'DAUER': null,
        'PREIS': null,
        'ZIELGRUPPE': null,
        'VORAUSSETZUNGEN': null,
        'INHALT': null,
        'ABSCHLUSS': null,
        'ANMERKUNGEN': null,
        'ISONLINE': null,
        'LINK': null,
        'STATUS': null,
        'GUELTIGBIS': null,
      };

      final schulung = Schulung.fromJson(json);

      expect(schulung.id, equals(1));
      expect(schulung.bezeichnung, equals('Test Training'));
      expect(schulung.datum, isEmpty);
      expect(schulung.ausgestelltAm, isEmpty);
      expect(schulung.teilnehmerId, equals(0));
      expect(schulung.schulungsartId, equals(0));
      expect(schulung.schulungsartBezeichnung, isEmpty);
      expect(schulung.schulungsartKurzbezeichnung, isEmpty);
      expect(schulung.schulungsartBeschreibung, isEmpty);
      expect(schulung.maxTeilnehmer, equals(0));
      expect(schulung.anzahlTeilnehmer, equals(0));
      expect(schulung.ort, isEmpty);
      expect(schulung.uhrzeit, isEmpty);
      expect(schulung.dauer, isEmpty);
      expect(schulung.preis, isEmpty);
      expect(schulung.zielgruppe, isEmpty);
      expect(schulung.voraussetzungen, isEmpty);
      expect(schulung.inhalt, isEmpty);
      expect(schulung.abschluss, isEmpty);
      expect(schulung.anmerkungen, isEmpty);
      expect(schulung.isOnline, isFalse);
      expect(schulung.link, isEmpty);
      expect(schulung.status, isEmpty);
      expect(schulung.gueltigBis, isEmpty);
    });
  });
}
