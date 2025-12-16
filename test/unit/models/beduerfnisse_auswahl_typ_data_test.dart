import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/beduerfnisse_auswahl_typ_data.dart';

void main() {
  group('BeduerfnisseAuswahlTyp', () {
    test('fromJson creates correct object with uppercase keys', () {
      final json = {
        'ID': 1,
        'KUERZEL': 'WA',
        'BESCHREIBUNG': 'Waffenart',
        'CREATED_AT': '2024-01-01T10:00:00.000Z',
        'DELETED_AT': null,
      };
      final auswahlTyp = BeduerfnisseAuswahlTyp.fromJson(json);
      expect(auswahlTyp.id, 1);
      expect(auswahlTyp.kuerzel, 'WA');
      expect(auswahlTyp.beschreibung, 'Waffenart');
      expect(auswahlTyp.createdAt, DateTime.parse('2024-01-01T10:00:00.000Z'));
      expect(auswahlTyp.deletedAt, isNull);
    });

    test('fromJson creates correct object with snake_case keys', () {
      final json = {
        'id': 2,
        'kuerzel': 'DI',
        'beschreibung': 'Disziplin',
        'created_at': '2024-01-02T10:00:00.000Z',
        'deleted_at': '2024-01-03T10:00:00.000Z',
      };
      final auswahlTyp = BeduerfnisseAuswahlTyp.fromJson(json);
      expect(auswahlTyp.id, 2);
      expect(auswahlTyp.kuerzel, 'DI');
      expect(auswahlTyp.beschreibung, 'Disziplin');
      expect(auswahlTyp.createdAt, DateTime.parse('2024-01-02T10:00:00.000Z'));
      expect(auswahlTyp.deletedAt, DateTime.parse('2024-01-03T10:00:00.000Z'));
    });

    test('fromJson handles null timestamps', () {
      final json = {
        'id': 3,
        'kuerzel': 'KA',
        'beschreibung': 'Kaliber',
        'created_at': null,
        'deleted_at': null,
      };
      final auswahlTyp = BeduerfnisseAuswahlTyp.fromJson(json);
      expect(auswahlTyp.id, 3);
      expect(auswahlTyp.kuerzel, 'KA');
      expect(auswahlTyp.beschreibung, 'Kaliber');
      expect(auswahlTyp.createdAt, isNull);
      expect(auswahlTyp.deletedAt, isNull);
    });

    test('fromJson handles null id', () {
      final json = {
        'id': null,
        'kuerzel': 'TE',
        'beschreibung': 'Test',
      };
      final auswahlTyp = BeduerfnisseAuswahlTyp.fromJson(json);
      expect(auswahlTyp.id, isNull);
      expect(auswahlTyp.kuerzel, 'TE');
      expect(auswahlTyp.beschreibung, 'Test');
    });

    test('constructor creates correct object', () {
      const auswahlTyp = BeduerfnisseAuswahlTyp(
        id: 1,
        kuerzel: 'WA',
        beschreibung: 'Waffenart',
        createdAt: null,
        deletedAt: null,
      );
      expect(auswahlTyp.id, 1);
      expect(auswahlTyp.kuerzel, 'WA');
      expect(auswahlTyp.beschreibung, 'Waffenart');
      expect(auswahlTyp.createdAt, isNull);
      expect(auswahlTyp.deletedAt, isNull);
    });

    test('constructor with timestamps creates correct object', () {
      final createdAt = DateTime(2024, 1, 1, 10, 0, 0);
      final deletedAt = DateTime(2024, 1, 2, 10, 0, 0);
      final auswahlTyp = BeduerfnisseAuswahlTyp(
        id: 1,
        kuerzel: 'WA',
        beschreibung: 'Waffenart',
        createdAt: createdAt,
        deletedAt: deletedAt,
      );
      expect(auswahlTyp.id, 1);
      expect(auswahlTyp.kuerzel, 'WA');
      expect(auswahlTyp.beschreibung, 'Waffenart');
      expect(auswahlTyp.createdAt, createdAt);
      expect(auswahlTyp.deletedAt, deletedAt);
    });

    test('toJson returns correct map', () {
      final createdAt = DateTime(2024, 1, 1, 10, 0, 0);
      final deletedAt = DateTime(2024, 1, 2, 10, 0, 0);
      final auswahlTyp = BeduerfnisseAuswahlTyp(
        id: 1,
        kuerzel: 'WA',
        beschreibung: 'Waffenart',
        createdAt: createdAt,
        deletedAt: deletedAt,
      );
      final json = auswahlTyp.toJson();
      expect(json['ID'], 1);
      expect(json['KUERZEL'], 'WA');
      expect(json['BESCHREIBUNG'], 'Waffenart');
      expect(json['CREATED_AT'], createdAt.toIso8601String());
      expect(json['DELETED_AT'], deletedAt.toIso8601String());
    });

    test('toJson handles null values', () {
      const auswahlTyp = BeduerfnisseAuswahlTyp(
        id: null,
        kuerzel: 'WA',
        beschreibung: 'Waffenart',
        createdAt: null,
        deletedAt: null,
      );
      final json = auswahlTyp.toJson();
      expect(json['ID'], isNull);
      expect(json['KUERZEL'], 'WA');
      expect(json['BESCHREIBUNG'], 'Waffenart');
      expect(json['CREATED_AT'], isNull);
      expect(json['DELETED_AT'], isNull);
    });

    test('equality works correctly', () {
      final createdAt = DateTime(2024, 1, 1);
      final auswahlTyp1 = BeduerfnisseAuswahlTyp(
        id: 1,
        kuerzel: 'WA',
        beschreibung: 'Waffenart',
        createdAt: createdAt,
      );
      final auswahlTyp2 = BeduerfnisseAuswahlTyp(
        id: 1,
        kuerzel: 'WA',
        beschreibung: 'Waffenart',
        createdAt: createdAt,
      );
      expect(auswahlTyp1, equals(auswahlTyp2));
    });

    test('inequality with different id', () {
      const auswahlTyp1 = BeduerfnisseAuswahlTyp(
        id: 1,
        kuerzel: 'WA',
        beschreibung: 'Waffenart',
      );
      const auswahlTyp2 = BeduerfnisseAuswahlTyp(
        id: 2,
        kuerzel: 'WA',
        beschreibung: 'Waffenart',
      );
      expect(auswahlTyp1, isNot(equals(auswahlTyp2)));
    });

    test('inequality with different kuerzel', () {
      const auswahlTyp1 = BeduerfnisseAuswahlTyp(
        id: 1,
        kuerzel: 'WA',
        beschreibung: 'Waffenart',
      );
      const auswahlTyp2 = BeduerfnisseAuswahlTyp(
        id: 1,
        kuerzel: 'DI',
        beschreibung: 'Waffenart',
      );
      expect(auswahlTyp1, isNot(equals(auswahlTyp2)));
    });
  });
}
