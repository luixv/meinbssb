import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/sport_data.dart';

void main() {
  group('Sport', () {
    test('fromJson and toJson', () {
      final json = {
        'ID': 4,
        'CREATED_AT': '2023-04-04T12:00:00.000Z',
        'CHANGED_AT': null,
        'DELETED_AT': null,
        'ANTRAGSNUMMER': '67890',
        'SCHIESSDATUM': '2023-05-05T12:00:00.000Z',
        'WAFFENART_ID': 10,
        'DISZIPLIN_ID': 20,
        'TRAINING': true,
        'WETTKAMPFART_ID': null,
        'WETTKAMPFERGEBNIS': 99.9,
      };
      final model = Sport.fromJson(json);
      expect(model.id, 4);
      expect(model.createdAt, DateTime.parse('2023-04-04T12:00:00.000Z'));
      expect(model.changedAt, null);
      expect(model.deletedAt, null);
      expect(model.antragsnummer, '67890');
      expect(model.schiessdatum, DateTime.parse('2023-05-05T12:00:00.000Z'));
      expect(model.waffenartId, 10);
      expect(model.disziplinId, 20);
      expect(model.training, true);
      expect(model.wettkampfartId, null);
      expect(model.wettkampfergebnis, 99.9);
      expect(model.toJson(), json);
    });

    test('toJson with all fields', () {
      final model = Sport(
        id: 5,
        createdAt: DateTime.parse('2023-06-06T12:00:00.000Z'),
        changedAt: DateTime.parse('2023-07-07T12:00:00.000Z'),
        deletedAt: DateTime.parse('2023-08-08T12:00:00.000Z'),
        antragsnummer: 'abc',
        schiessdatum: DateTime.parse('2023-09-09T12:00:00.000Z'),
        waffenartId: 11,
        disziplinId: 21,
        training: false,
        wettkampfartId: 100,
        wettkampfergebnis: 88.8,
      );
      final json = model.toJson();
      expect(json['ID'], 5);
      expect(json['CREATED_AT'], '2023-06-06T12:00:00.000Z');
      expect(json['CHANGED_AT'], '2023-07-07T12:00:00.000Z');
      expect(json['DELETED_AT'], '2023-08-08T12:00:00.000Z');
      expect(json['ANTRAGSNUMMER'], 'abc');
      expect(json['SCHIESSDATUM'], '2023-09-09T12:00:00.000Z');
      expect(json['WAFFENART_ID'], 11);
      expect(json['DISZIPLIN_ID'], 21);
      expect(json['TRAINING'], false);
      expect(json['WETTKAMPFART_ID'], 100);
      expect(json['WETTKAMPFERGEBNIS'], 88.8);
    });

    test('fromJson with nulls and fallback', () {
      final json = {
        'ID': null,
        'CREATED_AT': null,
        'CHANGED_AT': null,
        'DELETED_AT': null,
        'ANTRAGSNUMMER': 'test',
        'SCHIESSDATUM': null,
        'WAFFENART_ID': 12,
        'DISZIPLIN_ID': 22,
        'TRAINING': false,
        'WETTKAMPFART_ID': null,
        'WETTKAMPFERGEBNIS': null,
      };
      final model = Sport.fromJson(json);
      expect(model.id, null);
      expect(model.createdAt, null);
      expect(model.changedAt, null);
      expect(model.deletedAt, null);
      expect(model.schiessdatum, isA<DateTime>()); // fallback to now
      expect(model.wettkampfergebnis, null);
    });
  });
}
