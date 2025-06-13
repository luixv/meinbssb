import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/disziplin.dart';

void main() {
  group('Disziplin', () {
    test('creates Disziplin from JSON', () {
      final json = {
        'DISZIPLINID': 1,
        'DISZIPLINNR': '1.10',
        'DISZIPLIN': 'Luftgewehr',
      };

      final disziplin = Disziplin.fromJson(json);

      expect(disziplin.disziplinId, equals(1));
      expect(disziplin.disziplinNr, equals('1.10'));
      expect(disziplin.disziplin, equals('Luftgewehr'));
    });

    test('converts Disziplin to JSON', () {
      final disziplin = Disziplin(
        disziplinId: 1,
        disziplinNr: '1.10',
        disziplin: 'Luftgewehr',
      );

      final json = disziplin.toJson();

      expect(json['DISZIPLINID'], equals(1));
      expect(json['DISZIPLINNR'], equals('1.10'));
      expect(json['DISZIPLIN'], equals('Luftgewehr'));
    });

    test('equality operator works correctly', () {
      final disziplin1 = Disziplin(
        disziplinId: 1,
        disziplinNr: '1.10',
        disziplin: 'Luftgewehr',
      );

      final disziplin2 = Disziplin(
        disziplinId: 1,
        disziplinNr: '1.10',
        disziplin: 'Luftgewehr',
      );

      final disziplin3 = Disziplin(
        disziplinId: 2,
        disziplinNr: '1.11',
        disziplin: 'Luftgewehr Auflage',
      );

      expect(disziplin1, equals(disziplin2));
      expect(disziplin1, isNot(equals(disziplin3)));
    });

    test('hashCode is consistent with equality', () {
      final disziplin1 = Disziplin(
        disziplinId: 1,
        disziplinNr: '1.10',
        disziplin: 'Luftgewehr',
      );

      final disziplin2 = Disziplin(
        disziplinId: 1,
        disziplinNr: '1.10',
        disziplin: 'Luftgewehr',
      );

      expect(disziplin1.hashCode, equals(disziplin2.hashCode));
    });
  });
}
