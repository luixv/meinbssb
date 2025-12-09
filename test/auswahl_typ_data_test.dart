import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/beduerfnisse_auswahl_typ_data.dart';

void main() {
  group('BeduerfnisseAuswahlTyp', () {
    test('fromJson and toJson', () {
      final json = {
        'ID': 1,
        'KURZ': 'A',
        'LANG': 'Alpha',
        'CREATED_AT': '2023-01-01T12:00:00.000Z',
        'DELETED_AT': null,
      };
      final model = BeduerfnisseAuswahlTyp.fromJson(json);
      expect(model.id, 1);
      expect(model.kurz, 'A');
      expect(model.lang, 'Alpha');
      expect(model.createdAt, DateTime.parse('2023-01-01T12:00:00.000Z'));
      expect(model.deletedAt, null);
      expect(model.toJson(), json);
    });

    test('toJson with all fields', () {
      final model = BeduerfnisseAuswahlTyp(
        id: 2,
        kurz: 'B',
        lang: 'Bravo',
        createdAt: DateTime.parse('2023-02-02T12:00:00.000Z'),
        deletedAt: DateTime.parse('2023-03-03T12:00:00.000Z'),
      );
      final json = model.toJson();
      expect(json['ID'], 2);
      expect(json['KURZ'], 'B');
      expect(json['LANG'], 'Bravo');
      expect(json['CREATED_AT'], '2023-02-02T12:00:00.000Z');
      expect(json['DELETED_AT'], '2023-03-03T12:00:00.000Z');
    });

    test('fromJson with null dates', () {
      final json = {
        'ID': 3,
        'KURZ': 'C',
        'LANG': 'Charlie',
        'CREATED_AT': null,
        'DELETED_AT': null,
      };
      final model = BeduerfnisseAuswahlTyp.fromJson(json);
      expect(model.id, 3);
      expect(model.kurz, 'C');
      expect(model.lang, 'Charlie');
      expect(model.createdAt, null);
      expect(model.deletedAt, null);
    });
  });
}
