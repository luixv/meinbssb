import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/passdaten_akzept_or_aktiv_data.dart';
import 'package:meinbssb/models/zve_data.dart';

void main() {
  group('PassdatenAkzeptOrAktiv', () {
    final zveJson = {
      'VEREINID': 1,
      'VEREINNR': 123,
      'VEREINNAME': 'Test Verein',
      'DISZIPLINID': 42,
      'DISZIPLINNR': 'D42',
      'DISZIPLIN': 'Luftgewehr',
    };
    final json = {
      'PASSDATENID': 10,
      'PASSSTATUS': 2,
      'PASSSTATUSTEXT': 'Aktiv',
      'DIGITALERPASS': 1,
      'PERSONID': 99,
      'ERSTVEREINID': 5,
      'EVVEREINNR': 888,
      'EVVEREINNAME': 'EV Verein',
      'PASSNUMMER': 'P123',
      'ERSTELLTAM': '2023-01-01T12:00:00.000Z',
      'ERSTELLTVON': 'admin',
      'ZVEs': [zveJson],
    };

    test('fromJson creates correct object', () {
      final obj = PassdatenAkzeptOrAktiv.fromJson(json);
      expect(obj.passdatenId, 10);
      expect(obj.passStatus, 2);
      expect(obj.passStatusText, 'Aktiv');
      expect(obj.digitalerPass, 1);
      expect(obj.personId, 99);
      expect(obj.erstVereinId, 5);
      expect(obj.evVereinNr, 888);
      expect(obj.evVereinName, 'EV Verein');
      expect(obj.passNummer, 'P123');
      expect(
          obj.erstelltAm, DateTime.parse('2023-01-01T12:00:00.000Z').toUtc(),);
      expect(obj.erstelltVon, 'admin');
      expect(obj.zves.length, 1);
      expect(obj.zves.first, ZVE.fromJson(zveJson));
    });

    test('toJson returns correct map', () {
      final obj = PassdatenAkzeptOrAktiv.fromJson(json);
      final map = obj.toJson();
      expect(map['PASSDATENID'], 10);
      expect(map['ZVEs'], isA<List>());
      expect(map['ZVEs'].first, zveJson);
    });

    test('copyWith returns modified copy', () {
      final obj = PassdatenAkzeptOrAktiv.fromJson(json);
      final copy = obj.copyWith(passStatus: 5, passStatusText: 'Neu');
      expect(copy.passStatus, 5);
      expect(copy.passStatusText, 'Neu');
      expect(copy.passdatenId, obj.passdatenId);
    });

    test('equality and hashCode', () {
      final obj1 = PassdatenAkzeptOrAktiv.fromJson(json);
      final obj2 = PassdatenAkzeptOrAktiv.fromJson(json);
      expect(obj1, obj2);
      expect(obj1.hashCode, obj2.hashCode);
    });

    test('toString returns readable string', () {
      final obj = PassdatenAkzeptOrAktiv.fromJson(json);
      expect(
          obj.toString(), contains('PassdatenAkzeptOrAktiv(passdatenId: 10'),);
    });

    test('handles nullables and empty ZVEs', () {
      final jsonWithNulls = {
        'PASSDATENID': 11,
        'PASSSTATUS': 0,
        'PASSSTATUSTEXT': null,
        'DIGITALERPASS': 0,
        'PERSONID': 0,
        'ERSTVEREINID': 0,
        'EVVEREINNR': 0,
        'EVVEREINNAME': null,
        'PASSNUMMER': null,
        'ERSTELLTAM': null,
        'ERSTELLTVON': null,
        'ZVEs': [],
      };
      final obj = PassdatenAkzeptOrAktiv.fromJson(jsonWithNulls);
      expect(obj.passStatusText, isNull);
      expect(obj.evVereinName, isNull);
      expect(obj.passNummer, isNull);
      expect(obj.erstelltAm, isNull);
      expect(obj.erstelltVon, isNull);
      expect(obj.zves, isEmpty);
      expect(obj.toJson()['ZVEs'], isEmpty);
    });
  });
}
