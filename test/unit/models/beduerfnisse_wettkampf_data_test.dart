import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/beduerfnisse_wettkampf_data.dart';

void main() {
  group('BeduerfnisseWettkampf', () {
    group('fromJson', () {
      test('creates correct object with snake_case keys', () {
        final json = {
          'id': 1,
          'created_at': '2024-01-01T10:00:00.000Z',
          'changed_at': '2024-01-02T10:00:00.000Z',
          'deleted_at': '2024-01-03T10:00:00.000Z',
          'antragsnummer': 100000,
          'schiessdatum': '2024-06-15T00:00:00.000Z',
          'wettkampfart': 'Bezirksmeisterschaft',
          'disziplin_id': 5,
          'wettkampfergebnis': 95.5,
          'bemerkung': 'Test competition',
        };

        final wettkampf = BeduerfnisseWettkampf.fromJson(json);

        expect(wettkampf.id, 1);
        expect(wettkampf.createdAt, DateTime.parse('2024-01-01T10:00:00.000Z'));
        expect(wettkampf.changedAt, DateTime.parse('2024-01-02T10:00:00.000Z'));
        expect(wettkampf.deletedAt, DateTime.parse('2024-01-03T10:00:00.000Z'));
        expect(wettkampf.antragsnummer, 100000);
        expect(
          wettkampf.schiessdatum,
          DateTime.parse('2024-06-15T00:00:00.000Z'),
        );
        expect(wettkampf.wettkampfart, 'Bezirksmeisterschaft');
        expect(wettkampf.disziplinId, 5);
        expect(wettkampf.wettkampfergebnis, 95.5);
        expect(wettkampf.bemerkung, 'Test competition');
      });

      test('creates correct object with UPPERCASE keys', () {
        final json = {
          'ID': 2,
          'CREATED_AT': '2024-02-01T10:00:00.000Z',
          'CHANGED_AT': '2024-02-02T10:00:00.000Z',
          'DELETED_AT': null,
          'ANTRAGSNUMMER': 100001,
          'SCHIESSDATUM': '2024-07-20T00:00:00.000Z',
          'WETTKAMPFART': 'Landesmeisterschaft',
          'DISZIPLIN_ID': 10,
          'WETTKAMPFERGEBNIS': 88.3,
          'BEMERKUNG': 'Good result',
        };

        final wettkampf = BeduerfnisseWettkampf.fromJson(json);

        expect(wettkampf.id, 2);
        expect(wettkampf.createdAt, DateTime.parse('2024-02-01T10:00:00.000Z'));
        expect(wettkampf.changedAt, DateTime.parse('2024-02-02T10:00:00.000Z'));
        expect(wettkampf.deletedAt, isNull);
        expect(wettkampf.antragsnummer, 100001);
        expect(
          wettkampf.schiessdatum,
          DateTime.parse('2024-07-20T00:00:00.000Z'),
        );
        expect(wettkampf.wettkampfart, 'Landesmeisterschaft');
        expect(wettkampf.disziplinId, 10);
        expect(wettkampf.wettkampfergebnis, 88.3);
        expect(wettkampf.bemerkung, 'Good result');
      });

      test('handles null optional fields', () {
        final json = {
          'id': null,
          'created_at': null,
          'changed_at': null,
          'deleted_at': null,
          'antragsnummer': 100002,
          'schiessdatum': '2024-08-10T00:00:00.000Z',
          'wettkampfart': 'Vereinsmeisterschaft',
          'disziplin_id': 3,
          'wettkampfergebnis': null,
          'bemerkung': null,
        };

        final wettkampf = BeduerfnisseWettkampf.fromJson(json);

        expect(wettkampf.id, isNull);
        expect(wettkampf.createdAt, isNull);
        expect(wettkampf.changedAt, isNull);
        expect(wettkampf.deletedAt, isNull);
        expect(wettkampf.antragsnummer, 100002);
        expect(
          wettkampf.schiessdatum,
          DateTime.parse('2024-08-10T00:00:00.000Z'),
        );
        expect(wettkampf.wettkampfart, 'Vereinsmeisterschaft');
        expect(wettkampf.disziplinId, 3);
        expect(wettkampf.wettkampfergebnis, isNull);
        expect(wettkampf.bemerkung, isNull);
      });

      test('converts int wettkampfergebnis to double', () {
        final json = {
          'antragsnummer': 100003,
          'schiessdatum': '2024-09-01T00:00:00.000Z',
          'wettkampfart': 'Training',
          'disziplin_id': 7,
          'wettkampfergebnis': 90, // int value
        };

        final wettkampf = BeduerfnisseWettkampf.fromJson(json);

        expect(wettkampf.wettkampfergebnis, isA<double>());
        expect(wettkampf.wettkampfergebnis, 90.0);
      });

      test('handles double wettkampfergebnis', () {
        final json = {
          'antragsnummer': 100004,
          'schiessdatum': '2024-09-15T00:00:00.000Z',
          'wettkampfart': 'Probe',
          'disziplin_id': 8,
          'wettkampfergebnis': 92.75, // double value
        };

        final wettkampf = BeduerfnisseWettkampf.fromJson(json);

        expect(wettkampf.wettkampfergebnis, isA<double>());
        expect(wettkampf.wettkampfergebnis, 92.75);
      });
    });

    group('constructor', () {
      test('creates correct object with required fields', () {
        final schiessdatum = DateTime(2024, 6, 15);

        final wettkampf = BeduerfnisseWettkampf(
          antragsnummer: 100000,
          schiessdatum: schiessdatum,
          wettkampfart: 'Meisterschaft',
          disziplinId: 5,
        );

        expect(wettkampf.antragsnummer, 100000);
        expect(wettkampf.schiessdatum, schiessdatum);
        expect(wettkampf.wettkampfart, 'Meisterschaft');
        expect(wettkampf.disziplinId, 5);
        expect(wettkampf.id, isNull);
        expect(wettkampf.createdAt, isNull);
        expect(wettkampf.changedAt, isNull);
        expect(wettkampf.deletedAt, isNull);
        expect(wettkampf.wettkampfergebnis, isNull);
        expect(wettkampf.bemerkung, isNull);
      });

      test('creates correct object with all fields', () {
        final createdAt = DateTime(2024, 1, 1, 10, 0, 0);
        final changedAt = DateTime(2024, 1, 2, 10, 0, 0);
        final deletedAt = DateTime(2024, 1, 3, 10, 0, 0);
        final schiessdatum = DateTime(2024, 6, 15);

        final wettkampf = BeduerfnisseWettkampf(
          id: 1,
          createdAt: createdAt,
          changedAt: changedAt,
          deletedAt: deletedAt,
          antragsnummer: 100000,
          schiessdatum: schiessdatum,
          wettkampfart: 'Bundesmeisterschaft',
          disziplinId: 10,
          wettkampfergebnis: 95.5,
          bemerkung: 'Excellent performance',
        );

        expect(wettkampf.id, 1);
        expect(wettkampf.createdAt, createdAt);
        expect(wettkampf.changedAt, changedAt);
        expect(wettkampf.deletedAt, deletedAt);
        expect(wettkampf.antragsnummer, 100000);
        expect(wettkampf.schiessdatum, schiessdatum);
        expect(wettkampf.wettkampfart, 'Bundesmeisterschaft');
        expect(wettkampf.disziplinId, 10);
        expect(wettkampf.wettkampfergebnis, 95.5);
        expect(wettkampf.bemerkung, 'Excellent performance');
      });
    });

    group('toJson', () {
      test('returns correct map with all fields', () {
        final createdAt = DateTime(2024, 1, 1, 10, 0, 0);
        final changedAt = DateTime(2024, 1, 2, 10, 0, 0);
        final deletedAt = DateTime(2024, 1, 3, 10, 0, 0);
        final schiessdatum = DateTime(2024, 6, 15);

        final wettkampf = BeduerfnisseWettkampf(
          id: 1,
          createdAt: createdAt,
          changedAt: changedAt,
          deletedAt: deletedAt,
          antragsnummer: 100000,
          schiessdatum: schiessdatum,
          wettkampfart: 'Landesliga',
          disziplinId: 7,
          wettkampfergebnis: 89.2,
          bemerkung: 'Rain delayed start',
        );

        final json = wettkampf.toJson();

        expect(json['ID'], 1);
        expect(json['CREATED_AT'], createdAt.toIso8601String());
        expect(json['CHANGED_AT'], changedAt.toIso8601String());
        expect(json['DELETED_AT'], deletedAt.toIso8601String());
        expect(json['ANTRAGSNUMMER'], 100000);
        expect(json['SCHIESSDATUM'], schiessdatum.toIso8601String());
        expect(json['WETTKAMPFART'], 'Landesliga');
        expect(json['DISZIPLIN_ID'], 7);
        expect(json['WETTKAMPFERGEBNIS'], 89.2);
        expect(json['BEMERKUNG'], 'Rain delayed start');
      });

      test('handles null values', () {
        final schiessdatum = DateTime(2024, 7, 20);

        final wettkampf = BeduerfnisseWettkampf(
          id: null,
          createdAt: null,
          changedAt: null,
          deletedAt: null,
          antragsnummer: 100001,
          schiessdatum: schiessdatum,
          wettkampfart: 'Pokal',
          disziplinId: 4,
          wettkampfergebnis: null,
          bemerkung: null,
        );

        final json = wettkampf.toJson();

        expect(json['ID'], isNull);
        expect(json['CREATED_AT'], isNull);
        expect(json['CHANGED_AT'], isNull);
        expect(json['DELETED_AT'], isNull);
        expect(json['ANTRAGSNUMMER'], 100001);
        expect(json['SCHIESSDATUM'], schiessdatum.toIso8601String());
        expect(json['WETTKAMPFART'], 'Pokal');
        expect(json['DISZIPLIN_ID'], 4);
        expect(json['WETTKAMPFERGEBNIS'], isNull);
        expect(json['BEMERKUNG'], isNull);
      });
    });

    group('equality', () {
      test('two identical objects are equal', () {
        final createdAt = DateTime(2024, 1, 1);
        final schiessdatum = DateTime(2024, 6, 15);

        final wettkampf1 = BeduerfnisseWettkampf(
          id: 1,
          createdAt: createdAt,
          changedAt: null,
          deletedAt: null,
          antragsnummer: 100000,
          schiessdatum: schiessdatum,
          wettkampfart: 'Meisterschaft',
          disziplinId: 5,
          wettkampfergebnis: 95.0,
          bemerkung: 'Test',
        );

        final wettkampf2 = BeduerfnisseWettkampf(
          id: 1,
          createdAt: createdAt,
          changedAt: null,
          deletedAt: null,
          antragsnummer: 100000,
          schiessdatum: schiessdatum,
          wettkampfart: 'Meisterschaft',
          disziplinId: 5,
          wettkampfergebnis: 95.0,
          bemerkung: 'Test',
        );

        expect(wettkampf1, equals(wettkampf2));
        expect(wettkampf1.hashCode, equals(wettkampf2.hashCode));
      });

      test('objects with different id are not equal', () {
        final schiessdatum = DateTime(2024, 6, 15);

        final wettkampf1 = BeduerfnisseWettkampf(
          id: 1,
          antragsnummer: 100000,
          schiessdatum: schiessdatum,
          wettkampfart: 'Meisterschaft',
          disziplinId: 5,
        );

        final wettkampf2 = BeduerfnisseWettkampf(
          id: 2,
          antragsnummer: 100000,
          schiessdatum: schiessdatum,
          wettkampfart: 'Meisterschaft',
          disziplinId: 5,
        );

        expect(wettkampf1, isNot(equals(wettkampf2)));
      });

      test('objects with different antragsnummer are not equal', () {
        final schiessdatum = DateTime(2024, 6, 15);

        final wettkampf1 = BeduerfnisseWettkampf(
          id: 1,
          antragsnummer: 100000,
          schiessdatum: schiessdatum,
          wettkampfart: 'Meisterschaft',
          disziplinId: 5,
        );

        final wettkampf2 = BeduerfnisseWettkampf(
          id: 1,
          antragsnummer: 100001,
          schiessdatum: schiessdatum,
          wettkampfart: 'Meisterschaft',
          disziplinId: 5,
        );

        expect(wettkampf1, isNot(equals(wettkampf2)));
      });

      test('objects with different schiessdatum are not equal', () {
        final schiessdatum1 = DateTime(2024, 6, 15);
        final schiessdatum2 = DateTime(2024, 6, 16);

        final wettkampf1 = BeduerfnisseWettkampf(
          id: 1,
          antragsnummer: 100000,
          schiessdatum: schiessdatum1,
          wettkampfart: 'Meisterschaft',
          disziplinId: 5,
        );

        final wettkampf2 = BeduerfnisseWettkampf(
          id: 1,
          antragsnummer: 100000,
          schiessdatum: schiessdatum2,
          wettkampfart: 'Meisterschaft',
          disziplinId: 5,
        );

        expect(wettkampf1, isNot(equals(wettkampf2)));
      });

      test('objects with different wettkampfart are not equal', () {
        final schiessdatum = DateTime(2024, 6, 15);

        final wettkampf1 = BeduerfnisseWettkampf(
          id: 1,
          antragsnummer: 100000,
          schiessdatum: schiessdatum,
          wettkampfart: 'Meisterschaft',
          disziplinId: 5,
        );

        final wettkampf2 = BeduerfnisseWettkampf(
          id: 1,
          antragsnummer: 100000,
          schiessdatum: schiessdatum,
          wettkampfart: 'Pokal',
          disziplinId: 5,
        );

        expect(wettkampf1, isNot(equals(wettkampf2)));
      });

      test('objects with different disziplinId are not equal', () {
        final schiessdatum = DateTime(2024, 6, 15);

        final wettkampf1 = BeduerfnisseWettkampf(
          id: 1,
          antragsnummer: 100000,
          schiessdatum: schiessdatum,
          wettkampfart: 'Meisterschaft',
          disziplinId: 5,
        );

        final wettkampf2 = BeduerfnisseWettkampf(
          id: 1,
          antragsnummer: 100000,
          schiessdatum: schiessdatum,
          wettkampfart: 'Meisterschaft',
          disziplinId: 6,
        );

        expect(wettkampf1, isNot(equals(wettkampf2)));
      });

      test('objects with different wettkampfergebnis are not equal', () {
        final schiessdatum = DateTime(2024, 6, 15);

        final wettkampf1 = BeduerfnisseWettkampf(
          id: 1,
          antragsnummer: 100000,
          schiessdatum: schiessdatum,
          wettkampfart: 'Meisterschaft',
          disziplinId: 5,
          wettkampfergebnis: 95.0,
        );

        final wettkampf2 = BeduerfnisseWettkampf(
          id: 1,
          antragsnummer: 100000,
          schiessdatum: schiessdatum,
          wettkampfart: 'Meisterschaft',
          disziplinId: 5,
          wettkampfergebnis: 96.0,
        );

        expect(wettkampf1, isNot(equals(wettkampf2)));
      });

      test('objects with different bemerkung are not equal', () {
        final schiessdatum = DateTime(2024, 6, 15);

        final wettkampf1 = BeduerfnisseWettkampf(
          id: 1,
          antragsnummer: 100000,
          schiessdatum: schiessdatum,
          wettkampfart: 'Meisterschaft',
          disziplinId: 5,
          bemerkung: 'Good',
        );

        final wettkampf2 = BeduerfnisseWettkampf(
          id: 1,
          antragsnummer: 100000,
          schiessdatum: schiessdatum,
          wettkampfart: 'Meisterschaft',
          disziplinId: 5,
          bemerkung: 'Excellent',
        );

        expect(wettkampf1, isNot(equals(wettkampf2)));
      });

      test('same object reference is equal to itself', () {
        final schiessdatum = DateTime(2024, 6, 15);

        final wettkampf = BeduerfnisseWettkampf(
          id: 1,
          antragsnummer: 100000,
          schiessdatum: schiessdatum,
          wettkampfart: 'Meisterschaft',
          disziplinId: 5,
        );

        expect(wettkampf, equals(wettkampf));
      });
    });

    group('hashCode', () {
      test('identical objects have same hashCode', () {
        final createdAt = DateTime(2024, 1, 1);
        final schiessdatum = DateTime(2024, 6, 15);

        final wettkampf1 = BeduerfnisseWettkampf(
          id: 1,
          createdAt: createdAt,
          antragsnummer: 100000,
          schiessdatum: schiessdatum,
          wettkampfart: 'Meisterschaft',
          disziplinId: 5,
          wettkampfergebnis: 95.0,
        );

        final wettkampf2 = BeduerfnisseWettkampf(
          id: 1,
          createdAt: createdAt,
          antragsnummer: 100000,
          schiessdatum: schiessdatum,
          wettkampfart: 'Meisterschaft',
          disziplinId: 5,
          wettkampfergebnis: 95.0,
        );

        expect(wettkampf1.hashCode, equals(wettkampf2.hashCode));
      });

      test('different objects have different hashCode', () {
        final schiessdatum = DateTime(2024, 6, 15);

        final wettkampf1 = BeduerfnisseWettkampf(
          id: 1,
          antragsnummer: 100000,
          schiessdatum: schiessdatum,
          wettkampfart: 'Meisterschaft',
          disziplinId: 5,
        );

        final wettkampf2 = BeduerfnisseWettkampf(
          id: 2,
          antragsnummer: 100000,
          schiessdatum: schiessdatum,
          wettkampfart: 'Meisterschaft',
          disziplinId: 5,
        );

        expect(wettkampf1.hashCode, isNot(equals(wettkampf2.hashCode)));
      });
    });

    group('fromJson and toJson roundtrip', () {
      test('maintains data integrity through serialization', () {
        final originalJson = {
          'id': 1,
          'created_at': '2024-01-01T10:00:00.000Z',
          'changed_at': '2024-01-02T10:00:00.000Z',
          'deleted_at': null,
          'antragsnummer': 100000,
          'schiessdatum': '2024-06-15T00:00:00.000Z',
          'wettkampfart': 'Landesmeisterschaft',
          'disziplin_id': 8,
          'wettkampfergebnis': 92.75,
          'bemerkung': 'Weather was perfect',
        };

        final wettkampf = BeduerfnisseWettkampf.fromJson(originalJson);
        final serializedJson = wettkampf.toJson();

        // Parse back again
        final wettkampfAgain = BeduerfnisseWettkampf.fromJson({
          'id': serializedJson['ID'],
          'created_at': serializedJson['CREATED_AT'],
          'changed_at': serializedJson['CHANGED_AT'],
          'deleted_at': serializedJson['DELETED_AT'],
          'antragsnummer': serializedJson['ANTRAGSNUMMER'],
          'schiessdatum': serializedJson['SCHIESSDATUM'],
          'wettkampfart': serializedJson['WETTKAMPFART'],
          'disziplin_id': serializedJson['DISZIPLIN_ID'],
          'wettkampfergebnis': serializedJson['WETTKAMPFERGEBNIS'],
          'bemerkung': serializedJson['BEMERKUNG'],
        });

        expect(wettkampfAgain, equals(wettkampf));
      });
    });
  });
}
