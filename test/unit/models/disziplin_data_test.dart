import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/disziplin_data.dart';

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
      const disziplin = Disziplin(
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
      const disziplin1 = Disziplin(
        disziplinId: 1,
        disziplinNr: '1.10',
        disziplin: 'Luftgewehr',
      );

      const disziplin2 = Disziplin(
        disziplinId: 1,
        disziplinNr: '1.10',
        disziplin: 'Luftgewehr',
      );

      const disziplin3 = Disziplin(
        disziplinId: 2,
        disziplinNr: '1.11',
        disziplin: 'Luftgewehr Auflage',
      );

      expect(disziplin1, equals(disziplin2));
      expect(disziplin1, isNot(equals(disziplin3)));
    });

    test('hashCode is consistent with equality', () {
      const disziplin1 = Disziplin(
        disziplinId: 1,
        disziplinNr: '1.10',
        disziplin: 'Luftgewehr',
      );

      const disziplin2 = Disziplin(
        disziplinId: 1,
        disziplinNr: '1.10',
        disziplin: 'Luftgewehr',
      );

      expect(disziplin1.hashCode, equals(disziplin2.hashCode));
    });

    test('handles null values in JSON', () {
      final json = {
        'DISZIPLINID': 1,
        'DISZIPLINNR': null,
        'DISZIPLIN': null,
      };

      final disziplin = Disziplin.fromJson(json);

      expect(disziplin.disziplinId, equals(1));
      expect(disziplin.disziplinNr, isNull);
      expect(disziplin.disziplin, isNull);
    });

    test('handles missing values in JSON', () {
      final json = {
        'DISZIPLINID': 1,
      };

      final disziplin = Disziplin.fromJson(json);

      expect(disziplin.disziplinId, equals(1));
      expect(disziplin.disziplinNr, isNull);
      expect(disziplin.disziplin, isNull);
    });

    test('toString returns correct representation', () {
      const disziplin = Disziplin(
        disziplinId: 1,
        disziplinNr: '1.10',
        disziplin: 'Luftgewehr',
      );

      expect(
        disziplin.toString(),
        equals(
          'Disziplin(disziplinId: 1, disziplinNr: 1.10, disziplin: Luftgewehr)',
        ),
      );
    });

    test('copyWith creates new instance with updated values', () {
      const disziplin = Disziplin(
        disziplinId: 1,
        disziplinNr: '1.10',
        disziplin: 'Luftgewehr',
      );

      final updatedDisziplin = disziplin.copyWith(
        disziplinId: 2,
        disziplinNr: '1.11',
        disziplin: 'Luftgewehr Auflage',
      );

      expect(updatedDisziplin.disziplinId, equals(2));
      expect(updatedDisziplin.disziplinNr, equals('1.11'));
      expect(updatedDisziplin.disziplin, equals('Luftgewehr Auflage'));
      expect(disziplin.disziplinId, equals(1)); // Original unchanged
    });

    test('copyWith with null values keeps original values', () {
      const disziplin = Disziplin(
        disziplinId: 1,
        disziplinNr: '1.10',
        disziplin: 'Luftgewehr',
      );

      final updatedDisziplin = disziplin.copyWith(
        disziplinId: null,
        disziplinNr: null,
        disziplin: null,
      );

      expect(updatedDisziplin.disziplinId, equals(1));
      expect(updatedDisziplin.disziplinNr, equals('1.10'));
      expect(updatedDisziplin.disziplin, equals('Luftgewehr'));
    });
  });
}
