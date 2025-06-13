import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/passdata_zve.dart';

void main() {
  group('PassdataZVE', () {
    test('creates instance from JSON with all fields', () {
      final json = {
        'PASSDATENID': 1,
        'PERSONID': 1,
        'PASSNUMMER': 'P123456',
        'VEREINNR': 123,
        'VEREINNAME': 'Test Club',
        'NAMEN': 'Doe',
        'VORNAME': 'John',
        'TITEL': 'Dr.',
        'GEBURTSDATUM': '1990-01-01T00:00:00.000Z',
        'GESCHLECHT': 1,
        'STRASSE': 'Test Street 1',
        'PLZ': '12345',
        'ORT': 'Test City',
        'ONLINE': true,
      };

      final passdataZVE = PassdataZVE.fromJson(json);

      expect(passdataZVE.passdatenId, 1);
      expect(passdataZVE.personId, 1);
      expect(passdataZVE.passnummer, 'P123456');
      expect(passdataZVE.vereinNr, 123);
      expect(passdataZVE.vereinName, 'Test Club');
      expect(passdataZVE.namen, 'Doe');
      expect(passdataZVE.vorname, 'John');
      expect(passdataZVE.titel, 'Dr.');
      expect(
          passdataZVE.geburtsdatum, DateTime.parse('1990-01-01T00:00:00.000Z'),);
      expect(passdataZVE.geschlecht, 1);
      expect(passdataZVE.strasse, 'Test Street 1');
      expect(passdataZVE.plz, '12345');
      expect(passdataZVE.ort, 'Test City');
      expect(passdataZVE.isOnline, true);
    });

    test('creates instance from JSON with minimal fields', () {
      final json = {
        'PASSDATENID': 1,
        'PERSONID': 1,
        'PASSNUMMER': 'P123456',
      };

      final passdataZVE = PassdataZVE.fromJson(json);

      expect(passdataZVE.passdatenId, 1);
      expect(passdataZVE.personId, 1);
      expect(passdataZVE.passnummer, 'P123456');
      expect(passdataZVE.vereinNr, null);
      expect(passdataZVE.vereinName, null);
      expect(passdataZVE.namen, null);
      expect(passdataZVE.vorname, null);
      expect(passdataZVE.titel, null);
      expect(passdataZVE.geburtsdatum, null);
      expect(passdataZVE.geschlecht, null);
      expect(passdataZVE.strasse, null);
      expect(passdataZVE.plz, null);
      expect(passdataZVE.ort, null);
      expect(passdataZVE.isOnline, false);
    });

    test('converts to JSON correctly', () {
      final passdataZVE = PassdataZVE(
        passdatenId: 1,
        personId: 1,
        passnummer: 'P123456',
        vereinNr: 123,
        vereinName: 'Test Club',
        namen: 'Doe',
        vorname: 'John',
        titel: 'Dr.',
        geburtsdatum: DateTime.parse('1990-01-01T00:00:00.000Z'),
        geschlecht: 1,
        strasse: 'Test Street 1',
        plz: '12345',
        ort: 'Test City',
        isOnline: true,
      );

      final json = passdataZVE.toJson();

      expect(json['PASSDATENID'], 1);
      expect(json['PERSONID'], 1);
      expect(json['PASSNUMMER'], 'P123456');
      expect(json['VEREINNR'], 123);
      expect(json['VEREINNAME'], 'Test Club');
      expect(json['NAMEN'], 'Doe');
      expect(json['VORNAME'], 'John');
      expect(json['TITEL'], 'Dr.');
      expect(json['GEBURTSDATUM'], '1990-01-01T00:00:00.000Z');
      expect(json['GESCHLECHT'], 1);
      expect(json['STRASSE'], 'Test Street 1');
      expect(json['PLZ'], '12345');
      expect(json['ORT'], 'Test City');
      expect(json['ONLINE'], true);
    });

    test('equality and hashCode', () {
      final passdataZVE1 = PassdataZVE(
        passdatenId: 1,
        personId: 1,
        passnummer: 'P123456',
        vereinNr: 123,
        vereinName: 'Test Club',
        namen: 'Doe',
        vorname: 'John',
        titel: 'Dr.',
        geburtsdatum: DateTime.parse('1990-01-01T00:00:00.000Z'),
        geschlecht: 1,
        strasse: 'Test Street 1',
        plz: '12345',
        ort: 'Test City',
        isOnline: true,
      );

      final passdataZVE2 = PassdataZVE(
        passdatenId: 1,
        personId: 1,
        passnummer: 'P123456',
        vereinNr: 123,
        vereinName: 'Test Club',
        namen: 'Doe',
        vorname: 'John',
        titel: 'Dr.',
        geburtsdatum: DateTime.parse('1990-01-01T00:00:00.000Z'),
        geschlecht: 1,
        strasse: 'Test Street 1',
        plz: '12345',
        ort: 'Test City',
        isOnline: true,
      );

      final passdataZVE3 = PassdataZVE(
        passdatenId: 2,
        personId: 1,
        passnummer: 'P123456',
        vereinNr: 123,
        vereinName: 'Test Club',
        namen: 'Doe',
        vorname: 'John',
        titel: 'Dr.',
        geburtsdatum: DateTime.parse('1990-01-01T00:00:00.000Z'),
        geschlecht: 1,
        strasse: 'Test Street 1',
        plz: '12345',
        ort: 'Test City',
        isOnline: true,
      );

      expect(passdataZVE1, passdataZVE2);
      expect(passdataZVE1, isNot(passdataZVE3));
      expect(passdataZVE1.hashCode, passdataZVE2.hashCode);
      expect(passdataZVE1.hashCode, isNot(passdataZVE3.hashCode));
    });

    test('toString returns correct representation', () {
      final passdataZVE = PassdataZVE(
        passdatenId: 1,
        personId: 1,
        passnummer: 'P123456',
        vereinNr: 123,
        vereinName: 'Test Club',
        namen: 'Doe',
        vorname: 'John',
        titel: 'Dr.',
        geburtsdatum: DateTime.parse('1990-01-01T00:00:00.000Z'),
        geschlecht: 1,
        strasse: 'Test Street 1',
        plz: '12345',
        ort: 'Test City',
        isOnline: true,
      );

      final string = passdataZVE.toString();

      expect(string, contains('passdatenId: 1'));
      expect(string, contains('personId: 1'));
      expect(string, contains('passnummer: P123456'));
      expect(string, contains('vereinNr: 123'));
      expect(string, contains('vereinName: Test Club'));
      expect(string, contains('namen: Doe'));
      expect(string, contains('vorname: John'));
      expect(string, contains('titel: Dr.'));
      expect(string, contains('geburtsdatum: 1990-01-01 00:00:00.000Z'));
      expect(string, contains('geschlecht: 1'));
      expect(string, contains('strasse: Test Street 1'));
      expect(string, contains('plz: 12345'));
      expect(string, contains('ort: Test City'));
      expect(string, contains('isOnline: true'));
    });
  });
}
