import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/zve.dart';

void main() {
  group('ZVE', () {
    final json = {
      'VEREINID': 1,
      'VEREINNR': 123,
      'VEREINNAME': 'Test Verein',
      'DISZIPLINID': 42,
      'DISZIPLINNR': 'D42',
      'DISZIPLIN': 'Luftgewehr',
    };

    test('fromJson creates correct object', () {
      final zve = ZVE.fromJson(json);
      expect(zve.vereinId, 1);
      expect(zve.vereinNr, 123);
      expect(zve.vereinName, 'Test Verein');
      expect(zve.disziplinId, 42);
      expect(zve.disziplinNr, 'D42');
      expect(zve.disziplin, 'Luftgewehr');
    });

    test('toJson returns correct map', () {
      final zve = ZVE.fromJson(json);
      expect(zve.toJson(), json);
    });

    test('copyWith returns modified copy', () {
      final zve = ZVE.fromJson(json);
      final copy = zve.copyWith(vereinName: 'Other', disziplinId: 99);
      expect(copy.vereinName, 'Other');
      expect(copy.disziplinId, 99);
      expect(copy.vereinId, zve.vereinId);
    });

    test('equality and hashCode', () {
      final zve1 = ZVE.fromJson(json);
      final zve2 = ZVE.fromJson(json);
      expect(zve1, zve2);
      expect(zve1.hashCode, zve2.hashCode);
    });

    test('toString returns readable string', () {
      final zve = ZVE.fromJson(json);
      expect(zve.toString(), contains('ZVE(vereinId: 1'));
    });

    test('handles nullables', () {
      final jsonWithNulls = {
        'VEREINID': 2,
        'VEREINNR': 456,
        'VEREINNAME': null,
        'DISZIPLINID': 99,
        'DISZIPLINNR': null,
        'DISZIPLIN': null,
      };
      final zve = ZVE.fromJson(jsonWithNulls);
      expect(zve.vereinName, isNull);
      expect(zve.disziplinNr, isNull);
      expect(zve.disziplin, isNull);
      expect(zve.toJson(), jsonWithNulls);
    });
  });
}
