import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/beduerfnis_antrag_data.dart';
import 'package:meinbssb/models/beduerfnis_antrag_status_data.dart';

void main() {
  group('BeduerfnisseAntrag', () {
    test('fromJson creates correct object with snake_case keys', () {
      final json = {
        'id': 2,
        'created_at': '2024-01-01T10:00:00.000Z',
        'changed_at': null,
        'deleted_at': '2024-01-03T10:00:00.000Z',
        'antragsnummer': 100000,
        'person_id': 101,
        'status_id': 2,
        'wbk_neu': false,
        'wbk_art': 'gruen',
        'beduerfnisart': 'kurzwaffe',
        'anzahl_waffen': 1,
        'vereinsnummer': 12345,
        'email': 'test2@example.com',
        'bankdaten': {'iban': 'DE0987654321'},
        'abbuchung_erfolgt': true,
        'bemerkung': 'Another bemerkung',
      };
      final antrag = BeduerfnisAntrag.fromJson(json);
      expect(antrag.id, 2);
      expect(antrag.createdAt, DateTime.parse('2024-01-01T10:00:00.000Z'));
      expect(antrag.changedAt, isNull);
      expect(antrag.deletedAt, DateTime.parse('2024-01-03T10:00:00.000Z'));
      expect(antrag.antragsnummer, 100000);
      expect(antrag.personId, 101);
      expect(antrag.statusId, BeduerfnisAntragStatus.eingereichtAmVerein);
      expect(antrag.wbkNeu, false);
      expect(antrag.wbkArt, 'gruen');
      expect(antrag.beduerfnisart, 'kurzwaffe');
      expect(antrag.anzahlWaffen, 1);
      expect(antrag.vereinsnummer, 12345);
      expect(antrag.email, 'test2@example.com');
      expect(antrag.bankdaten, {'iban': 'DE0987654321'});
      expect(antrag.abbuchungErfolgt, true);
      expect(antrag.bemerkung, 'Another bemerkung');
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 3,
        'antragsnummer': 100001,
        'person_id': 102,
        'status_id': null,
        'wbk_neu': null,
        'wbk_art': null,
        'beduerfnisart': null,
        'anzahl_waffen': null,
        'vereinsnummer': null,
        'email': null,
        'bankdaten': null,
        'abbuchung_erfolgt': null,
        'bemerkung': null,
      };
      final antrag = BeduerfnisAntrag.fromJson(json);
      expect(antrag.id, 3);
      expect(antrag.antragsnummer, 100001);
      expect(antrag.personId, 102);
      expect(antrag.statusId, isNull);
      expect(antrag.wbkNeu, false); // Default value
      expect(antrag.wbkArt, isNull);
      expect(antrag.beduerfnisart, isNull);
      expect(antrag.anzahlWaffen, isNull);
      expect(antrag.vereinsnummer, isNull);
      expect(antrag.email, isNull);
      expect(antrag.bankdaten, isNull);
      expect(antrag.abbuchungErfolgt, false); // Default value
      expect(antrag.bemerkung, isNull);
    });

    test('fromJson handles default values for boolean fields', () {
      final json = {
        'id': 4,
        'antragsnummer': 100002,
        'person_id': 103,
        'wbk_neu': null,
        'abbuchung_erfolgt': null,
      };
      final antrag = BeduerfnisAntrag.fromJson(json);
      expect(antrag.wbkNeu, false);
      expect(antrag.abbuchungErfolgt, false);
    });

    test('fromJson handles null id', () {
      final json = {'id': null, 'antragsnummer': 100003, 'person_id': 104};
      final antrag = BeduerfnisAntrag.fromJson(json);
      expect(antrag.id, isNull);
      expect(antrag.antragsnummer, 100003);
      expect(antrag.personId, 104);
    });

    test('constructor creates correct object with required fields', () {
      const antrag = BeduerfnisAntrag(antragsnummer: 100000, personId: 100);
      expect(antrag.antragsnummer, 100000);
      expect(antrag.personId, 100);
      expect(antrag.id, isNull);
      expect(antrag.statusId, isNull);
    });

    test('constructor creates correct object with all fields', () {
      const antrag = BeduerfnisAntrag(
        id: 1,
        createdAt: null,
        changedAt: null,
        deletedAt: null,
        antragsnummer: 100000,
        personId: 100,
        statusId: BeduerfnisAntragStatus.entwurf,
        wbkNeu: true,
        wbkArt: 'gelb',
        beduerfnisart: 'langwaffe',
        anzahlWaffen: 2,
        vereinsnummer: 67890,
        email: 'test@example.com',
        bankdaten: null,
        abbuchungErfolgt: false,
        bemerkung: 'Test',
      );
      expect(antrag.id, 1);
      expect(antrag.antragsnummer, 100000);
      expect(antrag.personId, 100);
      expect(antrag.statusId, BeduerfnisAntragStatus.entwurf);
      expect(antrag.wbkNeu, true);
      expect(antrag.wbkArt, 'gelb');
      expect(antrag.beduerfnisart, 'langwaffe');
      expect(antrag.anzahlWaffen, 2);
      expect(antrag.vereinsnummer, 67890);
      expect(antrag.email, 'test@example.com');
      expect(antrag.bankdaten, isNull);
      expect(antrag.abbuchungErfolgt, false);
      expect(antrag.bemerkung, 'Test');
    });

    test('toJson returns correct map', () {
      final createdAt = DateTime(2024, 1, 1, 10, 0, 0);
      final changedAt = DateTime(2024, 1, 2, 10, 0, 0);
      final deletedAt = DateTime(2024, 1, 3, 10, 0, 0);
      final bankdaten = {'iban': 'DE1234567890'};
      final antrag = BeduerfnisAntrag(
        id: 1,
        createdAt: createdAt,
        changedAt: changedAt,
        deletedAt: deletedAt,
        antragsnummer: 100000,
        personId: 100,
        statusId: BeduerfnisAntragStatus.entwurf,
        wbkNeu: true,
        wbkArt: 'gelb',
        beduerfnisart: 'langwaffe',
        anzahlWaffen: 2,
        vereinsnummer: 67890,
        email: 'test@example.com',
        bankdaten: bankdaten,
        abbuchungErfolgt: false,
        bemerkung: 'Test bemerkung',
      );
      final json = antrag.toJson();
      expect(json['ID'], 1);
      expect(json['CREATED_AT'], createdAt.toIso8601String());
      expect(json['CHANGED_AT'], changedAt.toIso8601String());
      expect(json['DELETED_AT'], deletedAt.toIso8601String());
      expect(json['ANTRAGSNUMMER'], 100000);
      expect(json['PERSON_ID'], 100);
      expect(json['STATUS_ID'], 1);
      expect(json['WBK_NEU'], true);
      expect(json['WBK_ART'], 'gelb');
      expect(json['BEDUERFNISART'], 'langwaffe');
      expect(json['ANZAHL_WAFFEN'], 2);
      expect(json['VEREINSNUMMER'], 67890);
      expect(json['EMAIL'], 'test@example.com');
      expect(json['BANKDATEN'], bankdaten);
      expect(json['ABBUCHUNG_ERFOLGT'], false);
      expect(json['BEMERKUNG'], 'Test bemerkung');
    });

    test('toJson handles null values', () {
      const antrag = BeduerfnisAntrag(
        id: null,
        antragsnummer: 100000,
        personId: 100,
        statusId: null,
        wbkArt: null,
        beduerfnisart: null,
        anzahlWaffen: null,
        email: null,
        bankdaten: null,
        bemerkung: null,
      );
      final json = antrag.toJson();
      expect(json['ID'], isNull);
      expect(json['CREATED_AT'], isNull);
      expect(json['CHANGED_AT'], isNull);
      expect(json['DELETED_AT'], isNull);
      expect(json['ANTRAGSNUMMER'], 100000);
      expect(json['PERSON_ID'], 100);
      expect(json['STATUS_ID'], isNull);
      expect(json['WBK_ART'], isNull);
      expect(json['BEDUERFNISART'], isNull);
      expect(json['ANZAHL_WAFFEN'], isNull);
      expect(json['EMAIL'], isNull);
      expect(json['BANKDATEN'], isNull);
      expect(json['BEMERKUNG'], isNull);
    });

    test('inequality with different antragsnummer', () {
      const antrag1 = BeduerfnisAntrag(
        id: 1,
        antragsnummer: 100000,
        personId: 100,
      );
      const antrag2 = BeduerfnisAntrag(
        id: 1,
        antragsnummer: 100001,
        personId: 100,
      );
      expect(antrag1, isNot(equals(antrag2)));
    });

    test('inequality with different personId', () {
      const antrag1 = BeduerfnisAntrag(
        id: 1,
        antragsnummer: 100000,
        personId: 100,
      );
      const antrag2 = BeduerfnisAntrag(
        id: 1,
        antragsnummer: 100000,
        personId: 101,
      );
      expect(antrag1, isNot(equals(antrag2)));
    });

    test('inequality with different bankdaten', () {
      const antrag1 = BeduerfnisAntrag(
        id: 1,
        antragsnummer: 100000,
        personId: 100,
        bankdaten: {'iban': 'DE1234567890'},
      );
      const antrag2 = BeduerfnisAntrag(
        id: 1,
        antragsnummer: 100000,
        personId: 100,
        bankdaten: {'iban': 'DE0987654321'},
      );
      expect(antrag1, isNot(equals(antrag2)));
    });
  });
}
