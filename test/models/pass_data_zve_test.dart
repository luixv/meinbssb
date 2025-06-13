import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/pass_data_zve.dart';

void main() {
  group('PassDataZVE', () {
    test('should create PassDataZVE from JSON', () {
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

      final passData = PassDataZVE.fromJson(json);

      expect(passData.passdatenZvId, equals(34527));
      expect(passData.zvVereinId, equals(2420));
      expect(passData.vVereinNr, equals(421037));
      expect(passData.disziplinNr, equals('B.91'));
      expect(passData.gauId, equals(57));
      expect(passData.bezirkId, equals(4));
      expect(passData.disziAusblenden, equals(0));
      expect(passData.ersaetzendurchId, equals(0));
      expect(passData.zvMitgliedschaftId, equals(510039));
      expect(passData.vereinName, equals('SV Alpenrose Grimolzhausen'));
      expect(passData.disziplin, equals('RWK Luftpistole'));
      expect(passData.disziplinId, equals(94));
    });

    test('should convert PassDataZVE to JSON', () {
      final passData = PassDataZVE(
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

      final json = passData.toJson();

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
      expect(json['DISZIPLIN'], equals('RWK Luftpistole'));
      expect(json['DISZIPLINID'], equals(94));
    });

    test('should handle null optional fields', () {
      final json = {
        'PASSDATENZVID': 34527,
        'ZVEREINID': 2420,
        'VVEREINNR': 421037,
        'GAUID': 57,
        'BEZIRKID': 4,
        'DISZIAUSBLENDEN': 0,
        'ERSAETZENDURCHID': 0,
        'ZVMITGLIEDSCHAFTID': 510039,
        'DISZIPLINID': 94,
      };

      final passData = PassDataZVE.fromJson(json);

      expect(passData.disziplinNr, isNull);
      expect(passData.vereinName, isNull);
      expect(passData.disziplin, isNull);
    });

    test('should implement equality correctly', () {
      final passData1 = PassDataZVE(
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

      final passData2 = PassDataZVE(
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

      final passData3 = PassDataZVE(
        passdatenZvId: 34528, // Different ID
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

      expect(passData1, equals(passData2));
      expect(passData1.hashCode, equals(passData2.hashCode));
      expect(passData1, isNot(equals(passData3)));
      expect(passData1.hashCode, isNot(equals(passData3.hashCode)));
    });

    test('should have correct string representation', () {
      final passData = PassDataZVE(
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

      const expectedString =
          'PassDataZVE(passdatenZvId: 34527, zvVereinId: 2420, '
          'vVereinNr: 421037, disziplinNr: B.91, gauId: 57, bezirkId: 4, '
          'disziAusblenden: 0, ersaetzendurchId: 0, zvMitgliedschaftId: 510039, '
          'vereinName: SV Alpenrose Grimolzhausen, disziplin: RWK Luftpistole, '
          'disziplinId: 94)';

      expect(passData.toString(), equals(expectedString));
    });
  });
}
