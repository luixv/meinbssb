import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_status_data.dart';

void main() {
  group('BeduerfnisseAntragStatus', () {
    test('fromJson creates correct object with uppercase keys', () {
      final json = {
        'ID': 1,
        'STATUS': 'offen',
        'BESCHREIBUNG': 'Antrag eingegangen',
        'DELETED_AT': null,
      };
      final status = BeduerfnisseAntragStatus.fromJson(json);
      expect(status.id, 1);
      expect(status.status, 'offen');
      expect(status.beschreibung, 'Antrag eingegangen');
      expect(status.deletedAt, isNull);
    });

    test('fromJson creates correct object with snake_case keys', () {
      final json = {
        'id': 2,
        'status': 'bearbeitung',
        'beschreibung': 'In Bearbeitung',
        'deleted_at': '2024-01-03T10:00:00.000Z',
      };
      final status = BeduerfnisseAntragStatus.fromJson(json);
      expect(status.id, 2);
      expect(status.status, 'bearbeitung');
      expect(status.beschreibung, 'In Bearbeitung');
      expect(status.deletedAt, DateTime.parse('2024-01-03T10:00:00.000Z'));
    });

    test('fromJson handles null beschreibung', () {
      final json = {
        'id': 3,
        'status': 'abgeschlossen',
        'beschreibung': null,
        'deleted_at': null,
      };
      final status = BeduerfnisseAntragStatus.fromJson(json);
      expect(status.id, 3);
      expect(status.status, 'abgeschlossen');
      expect(status.beschreibung, isNull);
      expect(status.deletedAt, isNull);
    });

    test('fromJson handles null id', () {
      final json = {
        'id': null,
        'status': 'neu',
        'beschreibung': 'Neuer Status',
      };
      final status = BeduerfnisseAntragStatus.fromJson(json);
      expect(status.id, isNull);
      expect(status.status, 'neu');
      expect(status.beschreibung, 'Neuer Status');
    });

    test('constructor creates correct object', () {
      const status = BeduerfnisseAntragStatus(
        id: 1,
        status: 'offen',
        beschreibung: 'Antrag eingegangen',
        deletedAt: null,
      );
      expect(status.id, 1);
      expect(status.status, 'offen');
      expect(status.beschreibung, 'Antrag eingegangen');
      expect(status.deletedAt, isNull);
    });

    test('constructor with deletedAt creates correct object', () {
      final deletedAt = DateTime(2024, 1, 2, 10, 0, 0);
      final status = BeduerfnisseAntragStatus(
        id: 1,
        status: 'offen',
        beschreibung: 'Antrag eingegangen',
        deletedAt: deletedAt,
      );
      expect(status.id, 1);
      expect(status.status, 'offen');
      expect(status.beschreibung, 'Antrag eingegangen');
      expect(status.deletedAt, deletedAt);
    });

    test('constructor without beschreibung creates correct object', () {
      const status = BeduerfnisseAntragStatus(
        id: 1,
        status: 'offen',
        beschreibung: null,
      );
      expect(status.id, 1);
      expect(status.status, 'offen');
      expect(status.beschreibung, isNull);
    });

    test('toJson returns correct map', () {
      final deletedAt = DateTime(2024, 1, 2, 10, 0, 0);
      final status = BeduerfnisseAntragStatus(
        id: 1,
        status: 'offen',
        beschreibung: 'Antrag eingegangen',
        deletedAt: deletedAt,
      );
      final json = status.toJson();
      expect(json['ID'], 1);
      expect(json['STATUS'], 'offen');
      expect(json['BESCHREIBUNG'], 'Antrag eingegangen');
      expect(json['DELETED_AT'], deletedAt.toIso8601String());
    });

    test('toJson handles null values', () {
      const status = BeduerfnisseAntragStatus(
        id: null,
        status: 'offen',
        beschreibung: null,
        deletedAt: null,
      );
      final json = status.toJson();
      expect(json['ID'], isNull);
      expect(json['STATUS'], 'offen');
      expect(json['BESCHREIBUNG'], isNull);
      expect(json['DELETED_AT'], isNull);
    });

    test('equality works correctly', () {
      final deletedAt = DateTime(2024, 1, 2);
      final status1 = BeduerfnisseAntragStatus(
        id: 1,
        status: 'offen',
        beschreibung: 'Antrag eingegangen',
        deletedAt: deletedAt,
      );
      final status2 = BeduerfnisseAntragStatus(
        id: 1,
        status: 'offen',
        beschreibung: 'Antrag eingegangen',
        deletedAt: deletedAt,
      );
      expect(status1, equals(status2));
    });

    test('inequality with different status', () {
      const status1 = BeduerfnisseAntragStatus(
        id: 1,
        status: 'offen',
        beschreibung: 'Antrag eingegangen',
      );
      const status2 = BeduerfnisseAntragStatus(
        id: 1,
        status: 'bearbeitung',
        beschreibung: 'Antrag eingegangen',
      );
      expect(status1, isNot(equals(status2)));
    });

    test('inequality with different beschreibung', () {
      const status1 = BeduerfnisseAntragStatus(
        id: 1,
        status: 'offen',
        beschreibung: 'Antrag eingegangen',
      );
      const status2 = BeduerfnisseAntragStatus(
        id: 1,
        status: 'offen',
        beschreibung: 'Andere Beschreibung',
      );
      expect(status1, isNot(equals(status2)));
    });

    test('inequality when one beschreibung is null', () {
      const status1 = BeduerfnisseAntragStatus(
        id: 1,
        status: 'offen',
        beschreibung: 'Antrag eingegangen',
      );
      const status2 = BeduerfnisseAntragStatus(
        id: 1,
        status: 'offen',
        beschreibung: null,
      );
      expect(status1, isNot(equals(status2)));
    });
  });
}
