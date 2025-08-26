import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/pass_data_zve_data.dart';

void main() {
  group('PassDataZVE', () {
    test('creates PassDataZVE from JSON', () {
      final json = {
        'PASSDATENZVID': 34527,
        'ZVEREINID': 2420,
        'VVEREINNR': 421037,
        'DISZIPLINNR': 'B.91',
        'GAUID': 57,
        'BEZIRKID': 4,
        'DISZIAUSBLENDEN': 0,
        'ERSAETZENDURCHID': 0,
        'ZVMITGLIEDSCHAFTID': 510039,
        'VEREINNAME': 'SV Alpenrose Grimolzhausen',
        'DISZIPLIN': 'RWK Luftpistole',
        'DISZIPLINID': 94,
      };

      final passDataZVE = PassDataZVE.fromJson(json);

      expect(passDataZVE.passdatenZvId, equals(34527));
      expect(passDataZVE.zvVereinId, equals(2420));
      expect(passDataZVE.vVereinNr, equals(421037));
      expect(passDataZVE.disziplinNr, equals('B.91'));
      expect(passDataZVE.gauId, equals(57));
      expect(passDataZVE.bezirkId, equals(4));
      expect(passDataZVE.disziAusblenden, equals(0));
      expect(passDataZVE.ersaetzendurchId, equals(0));
      expect(passDataZVE.zvMitgliedschaftId, equals(510039));
      expect(passDataZVE.vereinName, equals('SV Alpenrose Grimolzhausen'));
      expect(passDataZVE.disziplinId, equals(94));
      expect(passDataZVE.disziplin, equals('RWK Luftpistole'));
    });

    test('converts PassDataZVE to JSON', () {
      final passDataZVE = PassDataZVE(
        passdatenZvId: 34527,
        zvVereinId: 2420,
        vVereinNr: 421037,
        disziplinNr: 'B.91',
        gauId: 57,
        bezirkId: 4,
        disziAusblenden: 0,
        ersaetzendurchId: 0,
        zvMitgliedschaftId: 510039,
        vereinName: 'SV Alpenrose Grimolzhausen',
        disziplin: 'RWK Luftpistole',
        disziplinId: 94,
      );

      final json = passDataZVE.toJson();

      expect(json['PASSDATENZVID'], equals(34527));
      expect(json['ZVEREINID'], equals(2420));
      expect(json['VVEREINNR'], equals(421037));
      expect(json['DISZIPLINNR'], equals('B.91'));
      expect(json['GAUID'], equals(57));
      expect(json['BEZIRKID'], equals(4));
      expect(json['DISZIAUSBLENDEN'], equals(0));
      expect(json['ERSAETZENDURCHID'], equals(0));
      expect(json['ZVMITGLIEDSCHAFTID'], equals(510039));
      expect(json['VEREINNAME'], equals('SV Alpenrose Grimolzhausen'));
      expect(json['DISZIPLINID'], equals(94));
      expect(json['DISZIPLIN'], equals('RWK Luftpistole'));
    });

    test('equality operator works correctly', () {
      final passDataZVE1 = PassDataZVE(
        passdatenZvId: 34527,
        zvVereinId: 2420,
        vVereinNr: 421037,
        disziplinNr: 'B.91',
        gauId: 57,
        bezirkId: 4,
        disziAusblenden: 0,
        ersaetzendurchId: 0,
        zvMitgliedschaftId: 510039,
        vereinName: 'SV Alpenrose Grimolzhausen',
        disziplinId: 94,
        disziplin: 'RWK Luftpistole',
      );

      final passDataZVE2 = PassDataZVE(
        passdatenZvId: 34527,
        zvVereinId: 2420,
        vVereinNr: 421037,
        disziplinNr: 'B.91',
        gauId: 57,
        bezirkId: 4,
        disziAusblenden: 0,
        ersaetzendurchId: 0,
        zvMitgliedschaftId: 510039,
        vereinName: 'SV Alpenrose Grimolzhausen',
        disziplin: 'RWK Luftpistole',
        disziplinId: 94,
      );

      final passDataZVE3 = PassDataZVE(
        passdatenZvId: 34528,
        zvVereinId: 2421,
        vVereinNr: 421038,
        disziplinNr: 'B.92',
        gauId: 58,
        bezirkId: 5,
        disziAusblenden: 1,
        ersaetzendurchId: 1,
        zvMitgliedschaftId: 510040,
        vereinName: 'Different Club',
        disziplin: 'Different Discipline',
        disziplinId: 95,
      );

      expect(passDataZVE1, equals(passDataZVE2));
      expect(passDataZVE1, isNot(equals(passDataZVE3)));
    });

    test('hashCode is consistent with equality', () {
      final passDataZVE1 = PassDataZVE(
        passdatenZvId: 34527,
        zvVereinId: 2420,
        vVereinNr: 421037,
        disziplinNr: 'B.91',
        gauId: 57,
        bezirkId: 4,
        disziAusblenden: 0,
        ersaetzendurchId: 0,
        zvMitgliedschaftId: 510039,
        vereinName: 'SV Alpenrose Grimolzhausen',
        disziplin: 'RWK Luftpistole',
        disziplinId: 94,
      );

      final passDataZVE2 = PassDataZVE(
        passdatenZvId: 34527,
        zvVereinId: 2420,
        vVereinNr: 421037,
        disziplinNr: 'B.91',
        gauId: 57,
        bezirkId: 4,
        disziAusblenden: 0,
        ersaetzendurchId: 0,
        zvMitgliedschaftId: 510039,
        vereinName: 'SV Alpenrose Grimolzhausen',
        disziplin: 'RWK Luftpistole',
        disziplinId: 94,
      );

      expect(passDataZVE1.hashCode, equals(passDataZVE2.hashCode));
    });

    test('handles null values in JSON', () {
      final json = {
        'PASSDATENZVID': 34527,
        'ZVEREINID': 2420,
        'VVEREINNR': 421037,
        'DISZIPLINNR': 'B.91',
        'GAUID': 57,
        'BEZIRKID': 4,
        'DISZIAUSBLENDEN': 0,
        'ERSAETZENDURCHID': 0,
        'ZVMITGLIEDSCHAFTID': 510039,
        'VEREINNAME': null,
        'DISZIPLIN': null,
        'DISZIPLINID': 94,
      };

      final passDataZVE = PassDataZVE.fromJson(json);

      expect(passDataZVE.vereinName, isNull);
      expect(passDataZVE.disziplin, isNull);
    });
  });
}
