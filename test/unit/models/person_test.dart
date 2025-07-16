import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/person.dart';

void main() {
  group('Person', () {
    test('fromJson creates correct Person object', () {
      final json = {
        'PERSONID': 123,
        'NAMEN': 'Mustermann',
        'VORNAME': 'Max',
        'GESCHLECHT': true,
        'GEBURTSDATUM': '2000-01-01T00:00:00.000',
        'PASSNUMMER': '12345678',
        'STRASSE': 'Teststr. 1',
        'PLZ': '12345',
        'ORT': 'Teststadt',
      };
      final person = Person.fromJson(json);
      expect(person.personId, 123);
      expect(person.namen, 'Mustermann');
      expect(person.vorname, 'Max');
      expect(person.geschlecht, true);
      expect(person.geburtsdatum, DateTime.parse('2000-01-01T00:00:00.000'));
      expect(person.passnummer, '12345678');
      expect(person.strasse, 'Teststr. 1');
      expect(person.plz, '12345');
      expect(person.ort, 'Teststadt');
    });

    test('toJson returns correct map', () {
      final person = Person(
        personId: 1,
        namen: 'Doe',
        vorname: 'Jane',
        geschlecht: false,
        geburtsdatum: DateTime(1990, 5, 20),
        passnummer: '87654321',
        strasse: 'Hauptstr. 2',
        plz: '54321',
        ort: 'Beispielstadt',
      );
      final json = person.toJson();
      expect(json['PERSONID'], 1);
      expect(json['NAMEN'], 'Doe');
      expect(json['VORNAME'], 'Jane');
      expect(json['GESCHLECHT'], false);
      expect(json['GEBURTSDATUM'], '1990-05-20T00:00:00.000');
      expect(json['PASSNUMMER'], '87654321');
      expect(json['STRASSE'], 'Hauptstr. 2');
      expect(json['PLZ'], '54321');
      expect(json['ORT'], 'Beispielstadt');
    });

    test('fromJson handles null geburtsdatum', () {
      final json = {
        'PERSONID': 2,
        'NAMEN': 'Nullmann',
        'VORNAME': 'Nulla',
        'GESCHLECHT': false,
        'GEBURTSDATUM': null,
        'PASSNUMMER': '00000000',
        'STRASSE': 'Leere Str.',
        'PLZ': '00000',
        'ORT': 'Nullstadt',
      };
      final person = Person.fromJson(json);
      expect(person.geburtsdatum, isNull);
    });

    test('fromJson handles int geschlecht as 1/0', () {
      final jsonMale = {
        'PERSONID': 3,
        'NAMEN': 'Mann',
        'VORNAME': 'Herr',
        'GESCHLECHT': 1,
        'GEBURTSDATUM': '1980-01-01T00:00:00.000',
        'PASSNUMMER': '11111111',
        'STRASSE': 'Männerweg',
        'PLZ': '11111',
        'ORT': 'Männerstadt',
      };
      final jsonFemale = {
        'PERSONID': 4,
        'NAMEN': 'Frau',
        'VORNAME': 'Dame',
        'GESCHLECHT': 0,
        'GEBURTSDATUM': '1985-01-01T00:00:00.000',
        'PASSNUMMER': '22222222',
        'STRASSE': 'Frauenweg',
        'PLZ': '22222',
        'ORT': 'Frauenstadt',
      };
      final personMale = Person.fromJson(jsonMale);
      final personFemale = Person.fromJson(jsonFemale);
      expect(personMale.geschlecht, true);
      expect(personFemale.geschlecht, false);
    });
  });
}
