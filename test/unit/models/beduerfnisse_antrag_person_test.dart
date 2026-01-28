import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/beduerfnis_antrag_person_data.dart';

void main() {
  group('BeduerfnisseAntragPerson', () {
    test('fromJson creates correct object with snake_case keys', () {
      final json = {
        'id': 1,
        'created_at': '2024-01-01T10:00:00.000Z',
        'changed_at': '2024-01-02T12:00:00.000Z',
        'deleted_at': null,
        'antragsnummer': 'A123',
        'person_id': 100,
        'status_id': 1,
        'vorname': 'Max',
        'nachname': 'Mustermann',
        'vereinsname': 'SV Test',
      };
      final antragPerson = BeduerfnisAntragPerson.fromJson(json);
      expect(antragPerson.id, 1);
      expect(
        antragPerson.createdAt,
        DateTime.parse('2024-01-01T10:00:00.000Z'),
      );
      expect(
        antragPerson.changedAt,
        DateTime.parse('2024-01-02T12:00:00.000Z'),
      );
      expect(antragPerson.deletedAt, isNull);
      expect(antragPerson.antragsnummer, 'A123');
      expect(antragPerson.personId, 100);
      expect(antragPerson.statusId, 1);
      expect(antragPerson.vorname, 'Max');
      expect(antragPerson.nachname, 'Mustermann');
      expect(antragPerson.vereinsname, 'SV Test');
    });

    test('fromJson creates correct object with uppercase keys', () {
      final json = {
        'ID': 2,
        'CREATED_AT': '2024-01-01T10:00:00.000Z',
        'CHANGED_AT': '2024-01-02T12:00:00.000Z',
        'DELETED_AT': null,
        'ANTRAGSNUMMER': 'A124',
        'PERSON_ID': 101,
        'STATUS_ID': 2,
        'VORNAME': 'Maria',
        'NACHNAME': 'Muster',
        'VEREINSNAME': 'TSV Test',
      };
      final antragPerson = BeduerfnisAntragPerson.fromJson(json);
      expect(antragPerson.id, 2);
      expect(
        antragPerson.createdAt,
        DateTime.parse('2024-01-01T10:00:00.000Z'),
      );
      expect(
        antragPerson.changedAt,
        DateTime.parse('2024-01-02T12:00:00.000Z'),
      );
      expect(antragPerson.deletedAt, isNull);
      expect(antragPerson.antragsnummer, 'A124');
      expect(antragPerson.personId, 101);
      expect(antragPerson.statusId, 2);
      expect(antragPerson.vorname, 'Maria');
      expect(antragPerson.nachname, 'Muster');
      expect(antragPerson.vereinsname, 'TSV Test');
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 3,
        'antragsnummer': 'A125',
        'person_id': 102,
        'status_id': null,
        'vorname': null,
        'nachname': null,
        'vereinsname': null,
      };
      final antragPerson = BeduerfnisAntragPerson.fromJson(json);
      expect(antragPerson.id, 3);
      expect(antragPerson.antragsnummer, 'A125');
      expect(antragPerson.personId, 102);
      expect(antragPerson.statusId, isNull);
      expect(antragPerson.vorname, isNull);
      expect(antragPerson.nachname, isNull);
      expect(antragPerson.vereinsname, isNull);
    });

    test('fromJson handles null id', () {
      final json = {'id': null, 'antragsnummer': 'A126', 'person_id': 103};
      final antragPerson = BeduerfnisAntragPerson.fromJson(json);
      expect(antragPerson.id, isNull);
      expect(antragPerson.antragsnummer, 'A126');
      expect(antragPerson.personId, 103);
    });

    test('fromJson handles null timestamps', () {
      final json = {
        'id': 4,
        'created_at': null,
        'changed_at': null,
        'deleted_at': null,
        'antragsnummer': 'A127',
        'person_id': 104,
      };
      final antragPerson = BeduerfnisAntragPerson.fromJson(json);
      expect(antragPerson.id, 4);
      expect(antragPerson.createdAt, isNull);
      expect(antragPerson.changedAt, isNull);
      expect(antragPerson.deletedAt, isNull);
      expect(antragPerson.antragsnummer, 'A127');
      expect(antragPerson.personId, 104);
    });

    test('constructor creates correct object with required fields only', () {
      const antragPerson = BeduerfnisAntragPerson(
        antragsnummer: 'A123',
        personId: 100,
      );
      expect(antragPerson.antragsnummer, 'A123');
      expect(antragPerson.personId, 100);
      expect(antragPerson.id, isNull);
      expect(antragPerson.statusId, isNull);
      expect(antragPerson.vorname, isNull);
      expect(antragPerson.nachname, isNull);
      expect(antragPerson.vereinsname, isNull);
    });

    test('constructor creates correct object with all fields', () {
      final createdAt = DateTime(2024, 1, 1, 10, 0, 0);
      final changedAt = DateTime(2024, 1, 2, 12, 0, 0);
      final deletedAt = DateTime(2024, 1, 3, 14, 0, 0);
      final antragPerson = BeduerfnisAntragPerson(
        id: 1,
        createdAt: createdAt,
        changedAt: changedAt,
        deletedAt: deletedAt,
        antragsnummer: 'A123',
        personId: 100,
        statusId: 1,
        vorname: 'Max',
        nachname: 'Mustermann',
        vereinsname: 'SV Test',
      );
      expect(antragPerson.id, 1);
      expect(antragPerson.createdAt, createdAt);
      expect(antragPerson.changedAt, changedAt);
      expect(antragPerson.deletedAt, deletedAt);
      expect(antragPerson.antragsnummer, 'A123');
      expect(antragPerson.personId, 100);
      expect(antragPerson.statusId, 1);
      expect(antragPerson.vorname, 'Max');
      expect(antragPerson.nachname, 'Mustermann');
      expect(antragPerson.vereinsname, 'SV Test');
    });

    test('toJson returns correct map with all fields', () {
      final createdAt = DateTime(2024, 1, 1, 10, 0, 0);
      final changedAt = DateTime(2024, 1, 2, 12, 0, 0);
      final antragPerson = BeduerfnisAntragPerson(
        id: 1,
        createdAt: createdAt,
        changedAt: changedAt,
        antragsnummer: 'A123',
        personId: 100,
        statusId: 1,
        vorname: 'Max',
        nachname: 'Mustermann',
        vereinsname: 'SV Test',
      );
      final json = antragPerson.toJson();
      expect(json['ID'], 1);
      expect(json['CREATED_AT'], createdAt.toIso8601String());
      expect(json['CHANGED_AT'], changedAt.toIso8601String());
      expect(json['ANTRAGSNUMMER'], 'A123');
      expect(json['PERSON_ID'], 100);
      expect(json['STATUS_ID'], 1);
      expect(json['VORNAME'], 'Max');
      expect(json['NACHNAME'], 'Mustermann');
      expect(json['VEREINSNAME'], 'SV Test');
    });

    test('toJson handles null values', () {
      const antragPerson = BeduerfnisAntragPerson(
        id: null,
        antragsnummer: 'A123',
        personId: 100,
        statusId: null,
        vorname: null,
        nachname: null,
        vereinsname: null,
      );
      final json = antragPerson.toJson();
      expect(json['ID'], isNull);
      expect(json['CREATED_AT'], isNull);
      expect(json['CHANGED_AT'], isNull);
      expect(json['ANTRAGSNUMMER'], 'A123');
      expect(json['PERSON_ID'], 100);
      expect(json['STATUS_ID'], isNull);
      expect(json['VORNAME'], isNull);
      expect(json['NACHNAME'], isNull);
      expect(json['VEREINSNAME'], isNull);
    });

    test('inequality with different antragsnummer', () {
      const antragPerson1 = BeduerfnisAntragPerson(
        id: 1,
        antragsnummer: 'A123',
        personId: 100,
      );
      const antragPerson2 = BeduerfnisAntragPerson(
        id: 1,
        antragsnummer: 'A124',
        personId: 100,
      );
      expect(antragPerson1, isNot(equals(antragPerson2)));
    });

    test('inequality with different personId', () {
      const antragPerson1 = BeduerfnisAntragPerson(
        id: 1,
        antragsnummer: 'A123',
        personId: 100,
      );
      const antragPerson2 = BeduerfnisAntragPerson(
        id: 1,
        antragsnummer: 'A123',
        personId: 101,
      );
      expect(antragPerson1, isNot(equals(antragPerson2)));
    });

    test('inequality with different vorname', () {
      const antragPerson1 = BeduerfnisAntragPerson(
        id: 1,
        antragsnummer: 'A123',
        personId: 100,
        vorname: 'Max',
      );
      const antragPerson2 = BeduerfnisAntragPerson(
        id: 1,
        antragsnummer: 'A123',
        personId: 100,
        vorname: 'Maria',
      );
      expect(antragPerson1, isNot(equals(antragPerson2)));
    });

    test('inequality with different vereinsname', () {
      const antragPerson1 = BeduerfnisAntragPerson(
        id: 1,
        antragsnummer: 'A123',
        personId: 100,
        vereinsname: 'SV Test',
      );
      const antragPerson2 = BeduerfnisAntragPerson(
        id: 1,
        antragsnummer: 'A123',
        personId: 100,
        vereinsname: 'TSV Test',
      );
      expect(antragPerson1, isNot(equals(antragPerson2)));
    });

    test('roundtrip JSON serialization preserves data', () {
      final createdAt = DateTime(2024, 1, 1, 10, 0, 0);
      final original = BeduerfnisAntragPerson(
        id: 1,
        createdAt: createdAt,
        antragsnummer: 'A123',
        personId: 100,
        statusId: 1,
        vorname: 'Max',
        nachname: 'Mustermann',
        vereinsname: 'SV Test',
      );

      final json = original.toJson();
      final restored = BeduerfnisAntragPerson.fromJson(json);

      expect(restored.id, original.id);
      expect(
        restored.createdAt?.toIso8601String(),
        original.createdAt?.toIso8601String(),
      );
      expect(restored.antragsnummer, original.antragsnummer);
      expect(restored.personId, original.personId);
      expect(restored.statusId, original.statusId);
      expect(restored.vorname, original.vorname);
      expect(restored.nachname, original.nachname);
      expect(restored.vereinsname, original.vereinsname);
    });
  });
}
