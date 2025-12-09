import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/auswahl_data_data.dart';

void main() {
  group('AuswahlData', () {
    test('fromJson and toJson', () {
      final json = {
        'ID': 2,
        'TYP_ID': 1,
        'KURZ': 'B',
        'LANG': 'Bravo',
        'CREATED_AT': '2023-02-02T12:00:00.000Z',
        'DELETED_AT': null,
      };
      final model = AuswahlData.fromJson(json);
      expect(model.id, 2);
      expect(model.typId, 1);
      expect(model.kurz, 'B');
      expect(model.lang, 'Bravo');
      expect(model.createdAt, DateTime.parse('2023-02-02T12:00:00.000Z'));
      expect(model.deletedAt, null);
      expect(model.toJson(), json);
    });

    test('toJson with all fields', () {
      final model = AuswahlData(
        id: 3,
        typId: 2,
        kurz: 'C',
        lang: 'Charlie',
        createdAt: DateTime.parse('2023-03-03T12:00:00.000Z'),
        deletedAt: DateTime.parse('2023-04-04T12:00:00.000Z'),
      );
      final json = model.toJson();
      expect(json['ID'], 3);
      expect(json['TYP_ID'], 2);
      expect(json['KURZ'], 'C');
      expect(json['LANG'], 'Charlie');
      expect(json['CREATED_AT'], '2023-03-03T12:00:00.000Z');
      expect(json['DELETED_AT'], '2023-04-04T12:00:00.000Z');
    });

    test('fromJson with null dates', () {
      final json = {
        'ID': 4,
        'TYP_ID': 3,
        'KURZ': 'D',
        'LANG': 'Delta',
        'CREATED_AT': null,
        'DELETED_AT': null,
      };
      final model = AuswahlData.fromJson(json);
      expect(model.id, 4);
      expect(model.typId, 3);
      expect(model.kurz, 'D');
      expect(model.lang, 'Delta');
      expect(model.createdAt, null);
      expect(model.deletedAt, null);
    });
  });
}
