import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/beduerfnisse_auswahl_data.dart';

void main() {
  group('BeduerfnisseAuswahl', () {
    test('fromJson creates correct object with snake_case keys', () {
      final json = {
        'id': 2,
        'typ_id': 20,
        'kuerzel': 'REV',
        'beschreibung': 'Revolver',
        'created_at': '2024-01-02T10:00:00.000Z',
        'deleted_at': '2024-01-03T10:00:00.000Z',
      };
      final auswahl = BeduerfnisseAuswahl.fromJson(json);
      expect(auswahl.id, 2);
      expect(auswahl.typId, 20);
      expect(auswahl.kuerzel, 'REV');
      expect(auswahl.beschreibung, 'Revolver');
      expect(auswahl.createdAt, DateTime.parse('2024-01-02T10:00:00.000Z'));
      expect(auswahl.deletedAt, DateTime.parse('2024-01-03T10:00:00.000Z'));
    });

    test('fromJson handles null timestamps', () {
      final json = {
        'id': 3,
        'typ_id': 30,
        'kuerzel': 'GEW',
        'beschreibung': 'Gewehr',
        'created_at': null,
        'deleted_at': null,
      };
      final auswahl = BeduerfnisseAuswahl.fromJson(json);
      expect(auswahl.id, 3);
      expect(auswahl.typId, 30);
      expect(auswahl.kuerzel, 'GEW');
      expect(auswahl.beschreibung, 'Gewehr');
      expect(auswahl.createdAt, isNull);
      expect(auswahl.deletedAt, isNull);
    });

    test('fromJson handles null id', () {
      final json = {
        'id': null,
        'typ_id': 40,
        'kuerzel': 'TE',
        'beschreibung': 'Test',
      };
      final auswahl = BeduerfnisseAuswahl.fromJson(json);
      expect(auswahl.id, isNull);
      expect(auswahl.typId, 40);
      expect(auswahl.kuerzel, 'TE');
      expect(auswahl.beschreibung, 'Test');
    });

    test('constructor creates correct object', () {
      const auswahl = BeduerfnisseAuswahl(
        id: 1,
        typId: 10,
        kuerzel: 'PIS',
        beschreibung: 'Pistole',
        createdAt: null,
        deletedAt: null,
      );
      expect(auswahl.id, 1);
      expect(auswahl.typId, 10);
      expect(auswahl.kuerzel, 'PIS');
      expect(auswahl.beschreibung, 'Pistole');
      expect(auswahl.createdAt, isNull);
      expect(auswahl.deletedAt, isNull);
    });

    test('constructor with timestamps creates correct object', () {
      final createdAt = DateTime(2024, 1, 1, 10, 0, 0);
      final deletedAt = DateTime(2024, 1, 2, 10, 0, 0);
      final auswahl = BeduerfnisseAuswahl(
        id: 1,
        typId: 10,
        kuerzel: 'PIS',
        beschreibung: 'Pistole',
        createdAt: createdAt,
        deletedAt: deletedAt,
      );
      expect(auswahl.id, 1);
      expect(auswahl.typId, 10);
      expect(auswahl.kuerzel, 'PIS');
      expect(auswahl.beschreibung, 'Pistole');
      expect(auswahl.createdAt, createdAt);
      expect(auswahl.deletedAt, deletedAt);
    });

    test('toJson returns correct map', () {
      final createdAt = DateTime(2024, 1, 1, 10, 0, 0);
      final deletedAt = DateTime(2024, 1, 2, 10, 0, 0);
      final auswahl = BeduerfnisseAuswahl(
        id: 1,
        typId: 10,
        kuerzel: 'PIS',
        beschreibung: 'Pistole',
        createdAt: createdAt,
        deletedAt: deletedAt,
      );
      final json = auswahl.toJson();
      expect(json['ID'], 1);
      expect(json['TYP_ID'], 10);
      expect(json['KUERZEL'], 'PIS');
      expect(json['BESCHREIBUNG'], 'Pistole');
      expect(json['CREATED_AT'], createdAt.toIso8601String());
      expect(json['DELETED_AT'], deletedAt.toIso8601String());
    });

    test('toJson handles null values', () {
      const auswahl = BeduerfnisseAuswahl(
        id: null,
        typId: 10,
        kuerzel: 'PIS',
        beschreibung: 'Pistole',
        createdAt: null,
        deletedAt: null,
      );
      final json = auswahl.toJson();
      expect(json['ID'], isNull);
      expect(json['TYP_ID'], 10);
      expect(json['KUERZEL'], 'PIS');
      expect(json['BESCHREIBUNG'], 'Pistole');
      expect(json['CREATED_AT'], isNull);
      expect(json['DELETED_AT'], isNull);
    });
    test('inequality with different typId', () {
      const auswahl1 = BeduerfnisseAuswahl(
        id: 1,
        typId: 10,
        kuerzel: 'PIS',
        beschreibung: 'Pistole',
      );
      const auswahl2 = BeduerfnisseAuswahl(
        id: 1,
        typId: 20,
        kuerzel: 'PIS',
        beschreibung: 'Pistole',
      );
      expect(auswahl1, isNot(equals(auswahl2)));
    });

    test('inequality with different kuerzel', () {
      const auswahl1 = BeduerfnisseAuswahl(
        id: 1,
        typId: 10,
        kuerzel: 'PIS',
        beschreibung: 'Pistole',
      );
      const auswahl2 = BeduerfnisseAuswahl(
        id: 1,
        typId: 10,
        kuerzel: 'REV',
        beschreibung: 'Pistole',
      );
      expect(auswahl1, isNot(equals(auswahl2)));
    });
  });
}
