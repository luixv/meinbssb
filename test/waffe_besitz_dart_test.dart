import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/beduerfnisse_waffe_besitz_dart.dart';

void main() {
  group('BeduerfnisseWaffeBesitz', () {
    test('fromJson and toJson', () {
      final json = {
        'ID': 5,
        'CREATED_AT': '2023-06-06T12:00:00.000Z',
        'CHANGED_AT': null,
        'DELETED_AT': null,
        'ANTRAGSNUMMER': 'abcde',
        'WBK_NR': 'WBK123',
        'LFD_WBK': '001',
        'WAFFENART_ID': 30,
        'HERSTELLER': 'Glock',
        'KALIBER_ID': 40,
        'LAUFLAENGE_ID': null,
        'GEWICHT': '1.2',
        'KOMPENSATOR': false,
        'BEDUERFNISGRUND_ID': null,
        'VERBAND_ID': null,
        'BEMERKUNG': null,
      };
      final model = BeduerfnisseWaffeBesitz.fromJson(json);
      expect(model.id, 5);
      expect(model.createdAt, DateTime.parse('2023-06-06T12:00:00.000Z'));
      expect(model.changedAt, null);
      expect(model.deletedAt, null);
      expect(model.antragsnummer, 'abcde');
      expect(model.wbkNr, 'WBK123');
      expect(model.lfdWbk, '001');
      expect(model.waffenartId, 30);
      expect(model.hersteller, 'Glock');
      expect(model.kaliberId, 40);
      expect(model.lauflaengeId, null);
      expect(model.gewicht, '1.2');
      expect(model.kompensator, false);
      expect(model.beduerfnisgrundId, null);
      expect(model.verbandId, null);
      expect(model.bemerkung, null);
      expect(model.toJson(), json);
    });

    test('toJson with all fields', () {
      final model = BeduerfnisseWaffeBesitz(
        id: 6,
        createdAt: DateTime.parse('2023-07-07T12:00:00.000Z'),
        changedAt: DateTime.parse('2023-08-08T12:00:00.000Z'),
        deletedAt: DateTime.parse('2023-09-09T12:00:00.000Z'),
        antragsnummer: 'fghij',
        wbkNr: 'WBK456',
        lfdWbk: '002',
        waffenartId: 31,
        hersteller: 'Sig Sauer',
        kaliberId: 41,
        lauflaengeId: 100,
        gewicht: '1.5',
        kompensator: true,
        beduerfnisgrundId: 200,
        verbandId: 300,
        bemerkung: 'Test',
      );
      final json = model.toJson();
      expect(json['ID'], 6);
      expect(json['CREATED_AT'], '2023-07-07T12:00:00.000Z');
      expect(json['CHANGED_AT'], '2023-08-08T12:00:00.000Z');
      expect(json['DELETED_AT'], '2023-09-09T12:00:00.000Z');
      expect(json['ANTRAGSNUMMER'], 'fghij');
      expect(json['WBK_NR'], 'WBK456');
      expect(json['LFD_WBK'], '002');
      expect(json['WAFFENART_ID'], 31);
      expect(json['HERSTELLER'], 'Sig Sauer');
      expect(json['KALIBER_ID'], 41);
      expect(json['LAUFLAENGE_ID'], 100);
      expect(json['GEWICHT'], '1.5');
      expect(json['KOMPENSATOR'], true);
      expect(json['BEDUERFNISGRUND_ID'], 200);
      expect(json['VERBAND_ID'], 300);
      expect(json['BEMERKUNG'], 'Test');
    });

    test('fromJson with null optionals', () {
      final json = {
        'ID': null,
        'CREATED_AT': null,
        'CHANGED_AT': null,
        'DELETED_AT': null,
        'ANTRAGSNUMMER': 'xyz',
        'WBK_NR': 'WBK789',
        'LFD_WBK': '003',
        'WAFFENART_ID': 32,
        'HERSTELLER': null,
        'KALIBER_ID': 42,
        'LAUFLAENGE_ID': null,
        'GEWICHT': null,
        'KOMPENSATOR': true,
        'BEDUERFNISGRUND_ID': null,
        'VERBAND_ID': null,
        'BEMERKUNG': null,
      };
      final model = BeduerfnisseWaffeBesitz.fromJson(json);
      expect(model.id, null);
      expect(model.createdAt, null);
      expect(model.changedAt, null);
      expect(model.deletedAt, null);
      expect(model.hersteller, null);
      expect(model.lauflaengeId, null);
      expect(model.gewicht, null);
      expect(model.beduerfnisgrundId, null);
      expect(model.verbandId, null);
      expect(model.bemerkung, null);
    });
  });
}
