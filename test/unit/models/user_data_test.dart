import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/user_data.dart';

void main() {
  group('UserData', () {
    test('creates UserData with required fields', () {
      const userData = UserData(
        personId: 123,
        webLoginId: 456,
        passnummer: '12345678',
        vereinNr: 789,
        namen: 'Mustermann',
        vorname: 'Max',
        vereinName: 'Test Verein',
        passdatenId: 101,
        mitgliedschaftId: 102,
      );

      expect(userData.personId, 123);
      expect(userData.webLoginId, 456);
      expect(userData.passnummer, '12345678');
      expect(userData.vereinNr, 789);
      expect(userData.namen, 'Mustermann');
      expect(userData.vorname, 'Max');
      expect(userData.vereinName, 'Test Verein');
      expect(userData.passdatenId, 101);
      expect(userData.mitgliedschaftId, 102);
    });

    test('creates UserData with optional fields', () {
      final userData = UserData(
        personId: 123,
        webLoginId: 456,
        passnummer: '12345678',
        vereinNr: 789,
        namen: 'Mustermann',
        vorname: 'Max',
        vereinName: 'Test Verein',
        passdatenId: 101,
        mitgliedschaftId: 102,
        titel: 'Dr.',
        geburtsdatum: DateTime(1990, 1, 1),
        geschlecht: 1,
        strasse: 'Teststraße 1',
        plz: '12345',
        ort: 'Teststadt',
      );

      expect(userData.titel, 'Dr.');
      expect(userData.geburtsdatum, DateTime(1990, 1, 1));
      expect(userData.geschlecht, 1);
      expect(userData.strasse, 'Teststraße 1');
      expect(userData.plz, '12345');
      expect(userData.ort, 'Teststadt');
    });

    test('creates UserData with default values for optional fields', () {
      const userData = UserData(
        personId: 123,
        webLoginId: 456,
        passnummer: '12345678',
        vereinNr: 789,
        namen: 'Mustermann',
        vorname: 'Max',
        vereinName: 'Test Verein',
        passdatenId: 101,
        mitgliedschaftId: 102,
      );

      expect(userData.titel, null);
      expect(userData.geburtsdatum, null);
      expect(userData.geschlecht, null);
      expect(userData.strasse, null);
      expect(userData.plz, null);
      expect(userData.ort, null);
      expect(userData.land, '');
      expect(userData.nationalitaet, '');
      expect(userData.passStatus, 0);
      expect(userData.telefon, '');
      expect(userData.erstLandesverbandId, 0);
      expect(userData.erstVereinId, 0);
      expect(userData.digitalerPass, 0);
      expect(userData.isOnline, false);
    });

    test('creates UserData from JSON with all fields', () {
      final json = {
        'PERSONID': 123,
        'WEBLOGINID': 456,
        'PASSNUMMER': '12345678',
        'VEREINNR': 789,
        'NAMEN': 'Mustermann',
        'VORNAME': 'Max',
        'TITEL': 'Dr.',
        'GEBURTSDATUM': '1990-01-01',
        'GESCHLECHT': 1,
        'VEREINNAME': 'Test Verein',
        'STRASSE': 'Teststraße 1',
        'PLZ': '12345',
        'ORT': 'Teststadt',
        'PASSDATENID': 101,
        'MITGLIEDSCHAFTID': 102,
        'ONLINE': true,
      };

      final userData = UserData.fromJson(json);

      expect(userData.personId, 123);
      expect(userData.webLoginId, 456);
      expect(userData.passnummer, '12345678');
      expect(userData.vereinNr, 789);
      expect(userData.namen, 'Mustermann');
      expect(userData.vorname, 'Max');
      expect(userData.titel, 'Dr.');
      expect(userData.geburtsdatum, DateTime(1990, 1, 1));
      expect(userData.geschlecht, 1);
      expect(userData.vereinName, 'Test Verein');
      expect(userData.strasse, 'Teststraße 1');
      expect(userData.plz, '12345');
      expect(userData.ort, 'Teststadt');
      expect(userData.passdatenId, 101);
      expect(userData.mitgliedschaftId, 102);
      expect(userData.isOnline, true);
    });

    test('creates UserData from JSON with missing fields', () {
      final json = {
        'PERSONID': 123,
        'WEBLOGINID': 456,
        'PASSNUMMER': '12345678',
        'VEREINNR': 789,
        'NAMEN': 'Mustermann',
        'VORNAME': 'Max',
        'VEREINNAME': 'Test Verein',
        'PASSDATENID': 101,
        'MITGLIEDSCHAFTID': 102,
      };

      final userData = UserData.fromJson(json);

      expect(userData.personId, 123);
      expect(userData.webLoginId, 456);
      expect(userData.passnummer, '12345678');
      expect(userData.vereinNr, 789);
      expect(userData.namen, 'Mustermann');
      expect(userData.vorname, 'Max');
      expect(userData.titel, null);
      expect(userData.geburtsdatum, null);
      expect(userData.geschlecht, null);
      expect(userData.vereinName, 'Test Verein');
      expect(userData.strasse, null);
      expect(userData.plz, null);
      expect(userData.ort, null);
      expect(userData.passdatenId, 101);
      expect(userData.mitgliedschaftId, 102);
      expect(userData.isOnline, false);
    });

    test('creates UserData from JSON with null values', () {
      final json = {
        'PERSONID': 123,
        'WEBLOGINID': 456,
        'PASSNUMMER': '12345678',
        'VEREINNR': 789,
        'NAMEN': 'Mustermann',
        'VORNAME': 'Max',
        'TITEL': null,
        'GEBURTSDATUM': null,
        'GESCHLECHT': null,
        'VEREINNAME': 'Test Verein',
        'STRASSE': null,
        'PLZ': null,
        'ORT': null,
        'PASSDATENID': 101,
        'MITGLIEDSCHAFTID': 102,
        'ONLINE': null,
      };

      final userData = UserData.fromJson(json);

      expect(userData.personId, 123);
      expect(userData.webLoginId, 456);
      expect(userData.passnummer, '12345678');
      expect(userData.vereinNr, 789);
      expect(userData.namen, 'Mustermann');
      expect(userData.vorname, 'Max');
      expect(userData.titel, null);
      expect(userData.geburtsdatum, null);
      expect(userData.geschlecht, null);
      expect(userData.vereinName, 'Test Verein');
      expect(userData.strasse, null);
      expect(userData.plz, null);
      expect(userData.ort, null);
      expect(userData.passdatenId, 101);
      expect(userData.mitgliedschaftId, 102);
      expect(userData.isOnline, false);
    });

    test('converts UserData to JSON', () {
      final userData = UserData(
        personId: 123,
        webLoginId: 456,
        passnummer: '12345678',
        vereinNr: 789,
        namen: 'Mustermann',
        vorname: 'Max',
        titel: 'Dr.',
        geburtsdatum: DateTime(1990, 1, 1),
        geschlecht: 1,
        vereinName: 'Test Verein',
        strasse: 'Teststraße 1',
        plz: '12345',
        ort: 'Teststadt',
        passdatenId: 101,
        mitgliedschaftId: 102,
        isOnline: true,
      );

      final json = userData.toJson();

      expect(json['PERSONID'], 123);
      expect(json['WEBLOGINID'], 456);
      expect(json['PASSNUMMER'], '12345678');
      expect(json['VEREINNR'], 789);
      expect(json['NAMEN'], 'Mustermann');
      expect(json['VORNAME'], 'Max');
      expect(json['TITEL'], 'Dr.');
      expect(json['GEBURTSDATUM'], '1990-01-01T00:00:00.000');
      expect(json['GESCHLECHT'], 1);
      expect(json['VEREINNAME'], 'Test Verein');
      expect(json['STRASSE'], 'Teststraße 1');
      expect(json['PLZ'], '12345');
      expect(json['ORT'], 'Teststadt');
      expect(json['PASSDATENID'], 101);
      expect(json['MITGLIEDSCHAFTID'], 102);
      expect(json['ONLINE'], true);
    });

    test('creates copy of UserData with modified fields', () {
      const userData = UserData(
        personId: 123,
        webLoginId: 456,
        passnummer: '12345678',
        vereinNr: 789,
        namen: 'Mustermann',
        vorname: 'Max',
        vereinName: 'Test Verein',
        passdatenId: 101,
        mitgliedschaftId: 102,
      );

      final modifiedUserData = userData.copyWith(
        webLoginId: 789,
        titel: 'Dr.',
        geburtsdatum: DateTime(1990, 1, 1),
      );

      expect(modifiedUserData.personId, 123); // unchanged
      expect(modifiedUserData.webLoginId, 789); // changed
      expect(modifiedUserData.passnummer, '12345678'); // unchanged
      expect(modifiedUserData.vereinNr, 789); // unchanged
      expect(modifiedUserData.namen, 'Mustermann'); // unchanged
      expect(modifiedUserData.vorname, 'Max'); // unchanged
      expect(modifiedUserData.titel, 'Dr.'); // added
      expect(modifiedUserData.geburtsdatum, DateTime(1990, 1, 1)); // added
      expect(modifiedUserData.vereinName, 'Test Verein'); // unchanged
      expect(modifiedUserData.passdatenId, 101); // unchanged
      expect(modifiedUserData.mitgliedschaftId, 102); // unchanged
    });

    test('copyWith with no arguments returns identical object', () {
      const userData = UserData(
        personId: 123,
        webLoginId: 456,
        passnummer: '12345678',
        vereinNr: 789,
        namen: 'Mustermann',
        vorname: 'Max',
        vereinName: 'Test Verein',
        passdatenId: 101,
        mitgliedschaftId: 102,
      );

      final copy = userData.copyWith();

      expect(copy, equals(userData));
    });

    test('equality and hashCode', () {
      const user1 = UserData(
        personId: 1,
        webLoginId: 2,
        passnummer: 'A',
        vereinNr: 3,
        namen: 'N',
        vorname: 'V',
        vereinName: 'VN',
        passdatenId: 4,
        mitgliedschaftId: 5,
      );
      const user2 = UserData(
        personId: 1,
        webLoginId: 2,
        passnummer: 'A',
        vereinNr: 3,
        namen: 'N',
        vorname: 'V',
        vereinName: 'VN',
        passdatenId: 4,
        mitgliedschaftId: 5,
      );
      expect(user1, equals(user2));
      expect(user1.hashCode, equals(user2.hashCode));
    });

    test('toString returns a string containing key fields', () {
      const userData = UserData(
        personId: 123,
        webLoginId: 456,
        passnummer: '12345678',
        vereinNr: 789,
        namen: 'Mustermann',
        vorname: 'Max',
        vereinName: 'Test Verein',
        passdatenId: 101,
        mitgliedschaftId: 102,
      );
      final str = userData.toString();
      expect(str, contains('personId: 123'));
      expect(str, contains('namen: Mustermann'));
      expect(str, contains('vereinName: Test Verein'));
    });
  });
}
