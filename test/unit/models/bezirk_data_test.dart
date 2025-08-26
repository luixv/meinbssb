import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/bezirk_data.dart';

void main() {
  group('Bezirk', () {
    final bezirkJson = {
      'BEZIRKID': 1,
      'BEZIRKNR': 1,
      'BEZIRKNAME': 'Mittelfranken',
      'STRASSE': 'Schloßackerstr. 9',
      'PLZ': '85293',
      'ORT': 'Reichertshausen-Paindorf',
      'TELEFON': '',
      'EMAIL': 'an157833@bssb-msb.de',
      'HOMEPAGE': 'www.bssb-msb.de',
      'OEFFNUNGSZEITEN':
          'Bürozeiten: \r\nMittwoch: 08:30 – 11:30 Uhr \r\nFreitag: 16:00 – 18:30 Uhr \r\n',
      'NAMEN': 'Guttengeber',
      'VORNAME': 'Adolf',
      'P_STRASSE': 'Alemannenweg 7a',
      'P_PLZ': '84036',
      'P_ORT': 'Landshut',
      'P_EMAIL': 'an912168@bssb-msb.de',
      'LAT': 49.4809379577637,
      'LON': 10.433876991272,
      'FACEBOOK': '',
      'INSTAGRAM': '',
      'XTWITTER': '',
      'TIKTOK': '',
      'TWITCH': '',
      'ANZAHLMITGLIEDER': 64378,
      'GEOCODEQUELLE': 1,
    };

    test('creates Bezirk from JSON with all fields', () {
      final bezirk = Bezirk.fromJson(bezirkJson);

      expect(bezirk.bezirkId, 1);
      expect(bezirk.bezirkNr, 1);
      expect(bezirk.bezirkName, 'Mittelfranken');
      expect(bezirk.strasse, 'Schloßackerstr. 9');
      expect(bezirk.plz, '85293');
      expect(bezirk.ort, 'Reichertshausen-Paindorf');
      expect(bezirk.telefon, '');
      expect(bezirk.email, 'an157833@bssb-msb.de');
      expect(bezirk.homepage, 'www.bssb-msb.de');
      expect(bezirk.oeffnungszeiten,
          'Bürozeiten: \r\nMittwoch: 08:30 – 11:30 Uhr \r\nFreitag: 16:00 – 18:30 Uhr \r\n',);
      expect(bezirk.namen, 'Guttengeber');
      expect(bezirk.vorname, 'Adolf');
      expect(bezirk.pStrasse, 'Alemannenweg 7a');
      expect(bezirk.pPlz, '84036');
      expect(bezirk.pOrt, 'Landshut');
      expect(bezirk.pEmail, 'an912168@bssb-msb.de');
      expect(bezirk.lat, 49.4809379577637);
      expect(bezirk.lon, 10.433876991272);
      expect(bezirk.facebook, '');
      expect(bezirk.instagram, '');
      expect(bezirk.xTwitter, '');
      expect(bezirk.tiktok, '');
      expect(bezirk.twitch, '');
      expect(bezirk.anzahlMitglieder, 64378);
      expect(bezirk.geocodeQuelle, 1);
    });

    test('converts Bezirk to JSON with all fields', () {
      final bezirk = Bezirk.fromJson(bezirkJson);
      final json = bezirk.toJson();

      expect(json, equals(bezirkJson));
    });

    test('creates Bezirk from JSON with only required fields', () {
      final json = {
        'BEZIRKID': 1,
        'BEZIRKNR': 1,
        'BEZIRKNAME': 'Mittelfranken',
      };

      final bezirk = Bezirk.fromJson(json);

      expect(bezirk.bezirkId, 1);
      expect(bezirk.bezirkNr, 1);
      expect(bezirk.bezirkName, 'Mittelfranken');
      expect(bezirk.strasse, isNull);
      expect(bezirk.plz, isNull);
      expect(bezirk.ort, isNull);
      expect(bezirk.telefon, isNull);
      expect(bezirk.email, isNull);
      expect(bezirk.homepage, isNull);
      expect(bezirk.oeffnungszeiten, isNull);
      expect(bezirk.namen, isNull);
      expect(bezirk.vorname, isNull);
      expect(bezirk.pStrasse, isNull);
      expect(bezirk.pPlz, isNull);
      expect(bezirk.pOrt, isNull);
      expect(bezirk.pEmail, isNull);
      expect(bezirk.lat, isNull);
      expect(bezirk.lon, isNull);
      expect(bezirk.facebook, isNull);
      expect(bezirk.instagram, isNull);
      expect(bezirk.xTwitter, isNull);
      expect(bezirk.tiktok, isNull);
      expect(bezirk.twitch, isNull);
      expect(bezirk.anzahlMitglieder, isNull);
      expect(bezirk.geocodeQuelle, isNull);
    });

    test('handles null values for optional fields in JSON', () {
      final json = {
        'BEZIRKID': 1,
        'BEZIRKNR': 1,
        'BEZIRKNAME': 'Mittelfranken',
        'STRASSE': null,
        'PLZ': null,
        'ORT': null,
      };

      final bezirk = Bezirk.fromJson(json);

      expect(bezirk.strasse, isNull);
      expect(bezirk.plz, isNull);
      expect(bezirk.ort, isNull);
    });
  });
}
