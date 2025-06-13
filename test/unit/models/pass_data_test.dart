import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/pass_data.dart';

void main() {
  group('PassData', () {
    test('creates instance from JSON with all fields', () {
      final json = {
        'PERSONID': 1,
        'PASSNUMMER': 'P123456',
        'GEBURTSDATUM': '1990-01-01T00:00:00.000Z',
        'TITEL': 'Dr.',
        'VORNAME': 'John',
        'NAMEN': 'Doe',
        'STRASSE': 'Test Street 1',
        'PLZ': '12345',
        'ORT': 'Test City',
        'GESCHLECHT': 1,
      };

      final passData = PassData.fromJson(json);

      expect(passData.personId, 1);
      expect(passData.passnummer, 'P123456');
      expect(
        passData.geburtsdatum,
        DateTime.parse('1990-01-01T00:00:00.000Z'),
      );
      expect(passData.titel, 'Dr.');
      expect(passData.vorname, 'John');
      expect(passData.namen, 'Doe');
      expect(passData.strasse, 'Test Street 1');
      expect(passData.plz, '12345');
      expect(passData.ort, 'Test City');
      expect(passData.geschlecht, 1);
    });

    test('creates instance from JSON with minimal fields', () {
      final json = {
        'PERSONID': 1,
        'PASSNUMMER': 'P123456',
        'GEBURTSDATUM': '1990-01-01T00:00:00.000Z',
      };

      final passData = PassData.fromJson(json);

      expect(passData.personId, 1);
      expect(passData.passnummer, 'P123456');
      expect(
        passData.geburtsdatum,
        DateTime.parse('1990-01-01T00:00:00.000Z'),
      );
      expect(passData.titel, null);
      expect(passData.vorname, null);
      expect(passData.namen, null);
      expect(passData.strasse, null);
      expect(passData.plz, null);
      expect(passData.ort, null);
      expect(passData.geschlecht, null);
    });

    test('converts to JSON correctly', () {
      final passData = PassData(
        personId: 1,
        passnummer: 'P123456',
        geburtsdatum: DateTime.parse('1990-01-01T00:00:00.000Z'),
        titel: 'Dr.',
        vorname: 'John',
        namen: 'Doe',
        strasse: 'Test Street 1',
        plz: '12345',
        ort: 'Test City',
        geschlecht: 1,
      );

      final json = passData.toJson();

      expect(json['PERSONID'], 1);
      expect(json['PASSNUMMER'], 'P123456');
      expect(json['GEBURTSDATUM'], '1990-01-01T00:00:00.000Z');
      expect(json['TITEL'], 'Dr.');
      expect(json['VORNAME'], 'John');
      expect(json['NAMEN'], 'Doe');
      expect(json['STRASSE'], 'Test Street 1');
      expect(json['PLZ'], '12345');
      expect(json['ORT'], 'Test City');
      expect(json['GESCHLECHT'], 1);
    });

    test('equality works correctly', () {
      final passData1 = PassData(
        personId: 1,
        passnummer: 'P123456',
        geburtsdatum: DateTime.parse('1990-01-01T00:00:00.000Z'),
      );

      final passData2 = PassData(
        personId: 1,
        passnummer: 'P123456',
        geburtsdatum: DateTime.parse('1990-01-01T00:00:00.000Z'),
      );

      final passData3 = PassData(
        personId: 2,
        passnummer: 'P123456',
        geburtsdatum: DateTime.parse('1990-01-01T00:00:00.000Z'),
      );

      expect(passData1, passData2);
      expect(passData1, isNot(passData3));
      expect(passData1.hashCode, passData2.hashCode);
      expect(passData1.hashCode, isNot(passData3.hashCode));
    });

    test('toString returns correct representation', () {
      final passData = PassData(
        personId: 1,
        passnummer: 'P123456',
        geburtsdatum: DateTime.parse('1990-01-01T00:00:00.000Z'),
        titel: 'Dr.',
        vorname: 'John',
        namen: 'Doe',
        strasse: 'Test Street 1',
        plz: '12345',
        ort: 'Test City',
        geschlecht: 1,
      );

      final string = passData.toString();

      expect(string, contains('personId: 1'));
      expect(string, contains('passnummer: P123456'));
      expect(string, contains('geburtsdatum: 1990-01-01'));
      expect(string, contains('titel: Dr.'));
      expect(string, contains('vorname: John'));
      expect(string, contains('namen: Doe'));
      expect(string, contains('strasse: Test Street 1'));
      expect(string, contains('plz: 12345'));
      expect(string, contains('ort: Test City'));
      expect(string, contains('geschlecht: 1'));
    });
  });
}
