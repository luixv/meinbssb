import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/pass_data_zve.dart';
import 'package:meinbssb/models/disziplin.dart';

void main() {
  group('PassDataZVE', () {
    test('should create PassDataZVE from JSON with single discipline', () {
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
        'DISZIPLIN': [
          {'DISZIPLINID': 94, 'DISZIPLINNR': 'R.1', 'DISZIPLIN': 'Luftgewehr'},
        ],
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
      expect(passData.disziplin.length, equals(1));
      expect(passData.disziplin[0].disziplin, equals('Luftgewehr'));
      expect(passData.disziplin[0].disziplinNr, equals('R.1'));
      expect(passData.disziplinId, equals(94));
    });

    test('should create PassDataZVE from JSON with multiple disciplines', () {
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
        'DISZIPLIN': [
          {'DISZIPLINID': 94, 'DISZIPLINNR': 'R.1', 'DISZIPLIN': 'Luftgewehr'},
          {
            'DISZIPLINID': 112,
            'DISZIPLINNR': 'R.2',
            'DISZIPLIN': 'Luftpistole',
          },
        ],
        'DISZIPLINID': 94,
      };

      final passData = PassDataZVE.fromJson(json);

      expect(passData.disziplin.length, equals(2));
      expect(passData.disziplin[0].disziplin, equals('Luftgewehr'));
      expect(passData.disziplin[1].disziplin, equals('Luftpistole'));
    });

    test('should convert PassDataZVE to JSON with single discipline', () {
      final disziplin = Disziplin(
        disziplinId: 94,
        disziplinNr: 'R.1',
        disziplin: 'Luftgewehr',
      );
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
        disziplin: [disziplin],
        disziplinId: 94,
      );

      final json = passData.toJson();

      expect(json['PASSDATENZVID'], equals(34527));
      expect(json['DISZIPLIN'], isA<List>());
      expect((json['DISZIPLIN'] as List).length, 1);
      expect((json['DISZIPLIN'] as List)[0]['DISZIPLIN'], equals('Luftgewehr'));
      expect((json['DISZIPLIN'] as List)[0]['DISZIPLINNR'], equals('R.1'));
    });

    test('should convert PassDataZVE to JSON with multiple disciplines', () {
      final disziplin1 = Disziplin(
        disziplinId: 94,
        disziplinNr: 'R.1',
        disziplin: 'Luftgewehr',
      );
      final disziplin2 = Disziplin(
        disziplinId: 112,
        disziplinNr: 'R.2',
        disziplin: 'Luftpistole',
      );
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
        disziplin: [disziplin1, disziplin2],
        disziplinId: 94,
      );

      final json = passData.toJson();

      expect(json['DISZIPLIN'], isA<List>());
      expect((json['DISZIPLIN'] as List).length, 2);
      expect((json['DISZIPLIN'] as List)[0]['DISZIPLIN'], equals('Luftgewehr'));
      expect(
        (json['DISZIPLIN'] as List)[1]['DISZIPLIN'],
        equals('Luftpistole'),
      );
    });

    test('should handle empty discipline list', () {
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
        // No 'DISZIPLIN' field or empty list
      };

      final passData = PassDataZVE.fromJson(json);

      expect(passData.disziplin, isEmpty);
    });

    test('should implement equality correctly', () {
      final disziplin1 = Disziplin(
        disziplinId: 94,
        disziplinNr: 'R.1',
        disziplin: 'Luftgewehr',
      );
      final disziplin2 = Disziplin(
        disziplinId: 112,
        disziplinNr: 'R.2',
        disziplin: 'Luftpistole',
      );

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
        disziplin: [disziplin1, disziplin2],
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
        disziplin: [disziplin1, disziplin2],
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
        disziplin: [disziplin1],
        disziplinId: 94,
      );

      expect(passData1, equals(passData2));
      expect(passData1.hashCode, equals(passData2.hashCode));
      expect(passData1, isNot(equals(passData3)));
      expect(passData1.hashCode, isNot(equals(passData3.hashCode)));
    });

    test('should have correct string representation', () {
      final disziplin1 = Disziplin(
        disziplinId: 94,
        disziplinNr: 'R.1',
        disziplin: 'Luftgewehr',
      );
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
        disziplin: [disziplin1],
        disziplinId: 94,
      );

      const expectedString =
          'PassDataZVE(passdatenZvId: 34527, zvVereinId: 2420, '
          'vVereinNr: 421037, disziplinNr: B.91, gauId: 57, bezirkId: 4, '
          'disziAusblenden: 0, ersaetzendurchId: 0, zvMitgliedschaftId: 510039, '
          'vereinName: SV Alpenrose Grimolzhausen, disziplin: [Disziplin(disziplinId: 94, disziplinNr: R.1, disziplin: Luftgewehr)], '
          'disziplinId: 94)';

      expect(passData.toString(), equals(expectedString));
    });
  });
}
