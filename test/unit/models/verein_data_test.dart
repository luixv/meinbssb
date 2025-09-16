import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/verein_data.dart';

void main() {
  group('Verein', () {
    test('creates Verein from JSON with all fields', () {
      final json = {
        'VEREINID': 123,
        'VEREINNR': 456,
        'VEREINNAME': 'Test Club',
        'STRASSE': 'Test Street 1',
        'PLZ': '12345',
        'ORT': 'Test City',
        'TELEFON': '123456789',
        'EMAIL': 'test@club.com',
        'HOMEPAGE': 'www.testclub.com',
        'OEFFNUNGSZEITEN': 'Mon-Fri 9-17',
        'NAMEN': 'Smith',
        'VORNAME': 'John',
        'P_STRASSE': 'Contact Street 1',
        'P_PLZ': '54321',
        'P_ORT': 'Contact City',
        'P_EMAIL': 'contact@club.com',
        'GAUID': 1,
        'GAUNR': 1,
        'GAUNAME': 'Test Gau',
        'BEZIRKID': 2,
        'BEZIRKNR': 2,
        'BEZIRKNAME': 'Test Bezirk',
        'LAT': 48.123,
        'LON': 11.456,
        'GEOCODEQUELLE': 1,
        'FACEBOOK': 'facebook.com/testclub',
        'INSTAGRAM': 'instagram.com/testclub',
        'XTWITTER': 'twitter.com/testclub',
        'TIKTOK': 'tiktok.com/@testclub',
        'TWITCH': 'twitch.tv/testclub',
        'ANZAHLMITGLIEDER': 100,
      };

      final verein = Verein.fromJson(json);

      expect(verein.id, equals(123));
      expect(verein.vereinsNr, equals(456));
      expect(verein.name, equals('Test Club'));
      expect(verein.strasse, equals('Test Street 1'));
      expect(verein.plz, equals('12345'));
      expect(verein.ort, equals('Test City'));
      expect(verein.telefon, equals('123456789'));
      expect(verein.email, equals('test@club.com'));
      expect(verein.homepage, equals('www.testclub.com'));
      expect(verein.oeffnungszeiten, equals('Mon-Fri 9-17'));
      expect(verein.namen, equals('Smith'));
      expect(verein.vorname, equals('John'));
      expect(verein.pStrasse, equals('Contact Street 1'));
      expect(verein.pPlz, equals('54321'));
      expect(verein.pOrt, equals('Contact City'));
      expect(verein.pEmail, equals('contact@club.com'));
      expect(verein.gauId, equals(1));
      expect(verein.gauNr, equals(1));
      expect(verein.gauName, equals('Test Gau'));
      expect(verein.bezirkId, equals(2));
      expect(verein.bezirkNr, equals(2));
      expect(verein.bezirkName, equals('Test Bezirk'));
      expect(verein.lat, equals(48.123));
      expect(verein.lon, equals(11.456));
      expect(verein.geocodeQuelle, equals(1));
      expect(verein.facebook, equals('facebook.com/testclub'));
      expect(verein.instagram, equals('instagram.com/testclub'));
      expect(verein.xTwitter, equals('twitter.com/testclub'));
      expect(verein.tiktok, equals('tiktok.com/@testclub'));
      expect(verein.twitch, equals('twitch.tv/testclub'));
      expect(verein.anzahlMitglieder, equals(100));
    });

    test('creates Verein from JSON with only required fields', () {
      final json = {
        'VEREINID': 123,
        'VEREINNR': 456,
        'VEREINNAME': 'Test Club',
      };

      final verein = Verein.fromJson(json);

      expect(verein.id, equals(123));
      expect(verein.vereinsNr, equals(456));
      expect(verein.name, equals('Test Club'));
      expect(verein.strasse, isNull);
      expect(verein.plz, isNull);
      expect(verein.ort, isNull);
      expect(verein.telefon, isNull);
      expect(verein.email, isNull);
      expect(verein.homepage, isNull);
      expect(verein.oeffnungszeiten, isNull);
      expect(verein.namen, isNull);
      expect(verein.vorname, isNull);
      expect(verein.pStrasse, isNull);
      expect(verein.pPlz, isNull);
      expect(verein.pOrt, isNull);
      expect(verein.pEmail, isNull);
      expect(verein.gauId, isNull);
      expect(verein.gauNr, isNull);
      expect(verein.gauName, isNull);
      expect(verein.bezirkId, isNull);
      expect(verein.bezirkNr, isNull);
      expect(verein.bezirkName, isNull);
      expect(verein.lat, isNull);
      expect(verein.lon, isNull);
      expect(verein.geocodeQuelle, isNull);
      expect(verein.facebook, isNull);
      expect(verein.instagram, isNull);
      expect(verein.xTwitter, isNull);
      expect(verein.tiktok, isNull);
      expect(verein.twitch, isNull);
      expect(verein.anzahlMitglieder, isNull);
    });

    test('converts Verein to JSON with all fields', () {
      const verein = Verein(
        id: 123,
        vereinsNr: 456,
        name: 'Test Club',
        strasse: 'Test Street 1',
        plz: '12345',
        ort: 'Test City',
        telefon: '123456789',
        email: 'test@club.com',
        homepage: 'www.testclub.com',
        oeffnungszeiten: 'Mon-Fri 9-17',
        namen: 'Smith',
        vorname: 'John',
        pStrasse: 'Contact Street 1',
        pPlz: '54321',
        pOrt: 'Contact City',
        pEmail: 'contact@club.com',
        gauId: 1,
        gauNr: 1,
        gauName: 'Test Gau',
        bezirkId: 2,
        bezirkNr: 2,
        bezirkName: 'Test Bezirk',
        lat: 48.123,
        lon: 11.456,
        geocodeQuelle: 1,
        facebook: 'facebook.com/testclub',
        instagram: 'instagram.com/testclub',
        xTwitter: 'twitter.com/testclub',
        tiktok: 'tiktok.com/@testclub',
        twitch: 'twitch.tv/testclub',
        anzahlMitglieder: 100,
      );

      final json = verein.toJson();

      expect(json['VEREINID'], equals(123));
      expect(json['VEREINNR'], equals(456));
      expect(json['VEREINNAME'], equals('Test Club'));
      expect(json['STRASSE'], equals('Test Street 1'));
      expect(json['PLZ'], equals('12345'));
      expect(json['ORT'], equals('Test City'));
      expect(json['TELEFON'], equals('123456789'));
      expect(json['EMAIL'], equals('test@club.com'));
      expect(json['HOMEPAGE'], equals('www.testclub.com'));
      expect(json['OEFFNUNGSZEITEN'], equals('Mon-Fri 9-17'));
      expect(json['NAMEN'], equals('Smith'));
      expect(json['VORNAME'], equals('John'));
      expect(json['P_STRASSE'], equals('Contact Street 1'));
      expect(json['P_PLZ'], equals('54321'));
      expect(json['P_ORT'], equals('Contact City'));
      expect(json['P_EMAIL'], equals('contact@club.com'));
      expect(json['GAUID'], equals(1));
      expect(json['GAUNR'], equals(1));
      expect(json['GAUNAME'], equals('Test Gau'));
      expect(json['BEZIRKID'], equals(2));
      expect(json['BEZIRKNR'], equals(2));
      expect(json['BEZIRKNAME'], equals('Test Bezirk'));
      expect(json['LAT'], equals(48.123));
      expect(json['LON'], equals(11.456));
      expect(json['GEOCODEQUELLE'], equals(1));
      expect(json['FACEBOOK'], equals('facebook.com/testclub'));
      expect(json['INSTAGRAM'], equals('instagram.com/testclub'));
      expect(json['XTWITTER'], equals('twitter.com/testclub'));
      expect(json['TIKTOK'], equals('tiktok.com/@testclub'));
      expect(json['TWITCH'], equals('twitch.tv/testclub'));
      expect(json['ANZAHLMITGLIEDER'], equals(100));
    });

    test('converts Verein to JSON with only required fields', () {
      const verein = Verein(
        id: 123,
        vereinsNr: 456,
        name: 'Test Club',
      );

      final json = verein.toJson();

      expect(json['VEREINID'], equals(123));
      expect(json['VEREINNR'], equals(456));
      expect(json['VEREINNAME'], equals('Test Club'));
      expect(json['STRASSE'], isNull);
      expect(json['PLZ'], isNull);
      expect(json['ORT'], isNull);
      expect(json['TELEFON'], isNull);
      expect(json['EMAIL'], isNull);
      expect(json['HOMEPAGE'], isNull);
      expect(json['OEFFNUNGSZEITEN'], isNull);
      expect(json['NAMEN'], isNull);
      expect(json['VORNAME'], isNull);
      expect(json['P_STRASSE'], isNull);
      expect(json['P_PLZ'], isNull);
      expect(json['P_ORT'], isNull);
      expect(json['P_EMAIL'], isNull);
      expect(json['GAUID'], isNull);
      expect(json['GAUNR'], isNull);
      expect(json['GAUNAME'], isNull);
      expect(json['BEZIRKID'], isNull);
      expect(json['BEZIRKNR'], isNull);
      expect(json['BEZIRKNAME'], isNull);
      expect(json['LAT'], isNull);
      expect(json['LON'], isNull);
      expect(json['GEOCODEQUELLE'], isNull);
      expect(json['FACEBOOK'], isNull);
      expect(json['INSTAGRAM'], isNull);
      expect(json['XTWITTER'], isNull);
      expect(json['TIKTOK'], isNull);
      expect(json['TWITCH'], isNull);
      expect(json['ANZAHLMITGLIEDER'], isNull);
    });

    test('handles missing required fields in JSON', () {
      final json = {
        'VEREINID': 123,
        // Missing vereinsNr and name
      };

      expect(
        () => Verein.fromJson(json),
        throwsA(isA<TypeError>()),
      );
    });

    test('handles null values for optional fields in JSON', () {
      final json = {
        'VEREINID': 123,
        'VEREINNR': 456,
        'VEREINNAME': 'Test Club',
        'STRASSE': null,
        'PLZ': null,
        'ORT': null,
      };

      final verein = Verein.fromJson(json);

      expect(verein.id, equals(123));
      expect(verein.vereinsNr, equals(456));
      expect(verein.name, equals('Test Club'));
      expect(verein.strasse, isNull);
      expect(verein.plz, isNull);
      expect(verein.ort, isNull);
    });

    test('handles invalid numeric values in JSON', () {
      final json = {
        'VEREINID': 'invalid',
        'VEREINNR': 456,
        'VEREINNAME': 'Test Club',
      };

      expect(
        () => Verein.fromJson(json),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
