import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/datei_data.dart';

void main() {
  group('Datei', () {
    test('fromJson and toJson', () {
      final json = {
        'ID': 3,
        'CREATED_AT': '2023-03-03T12:00:00.000Z',
        'CHANGED_AT': null,
        'DELETED_AT': null,
        'ANTRAGSNUMMER': '12345',
        'DATEINAME': 'file.txt',
        'FILE_BYTES': [1, 2, 3, 4],
      };
      final model = Datei.fromJson(json);
      expect(model.id, 3);
      expect(model.createdAt, DateTime.parse('2023-03-03T12:00:00.000Z'));
      expect(model.changedAt, null);
      expect(model.deletedAt, null);
      expect(model.antragsnummer, '12345');
      expect(model.dateiname, 'file.txt');
      expect(model.fileBytes, [1, 2, 3, 4]);
      expect(model.toJson(), json);
    });

    test('toJson with all fields', () {
      final model = Datei(
        id: 4,
        createdAt: DateTime.parse('2023-04-04T12:00:00.000Z'),
        changedAt: DateTime.parse('2023-05-05T12:00:00.000Z'),
        deletedAt: DateTime.parse('2023-06-06T12:00:00.000Z'),
        antragsnummer: '67890',
        dateiname: 'test.pdf',
        fileBytes: [10, 20, 30],
      );
      final json = model.toJson();
      expect(json['ID'], 4);
      expect(json['CREATED_AT'], '2023-04-04T12:00:00.000Z');
      expect(json['CHANGED_AT'], '2023-05-05T12:00:00.000Z');
      expect(json['DELETED_AT'], '2023-06-06T12:00:00.000Z');
      expect(json['ANTRAGSNUMMER'], '67890');
      expect(json['DATEINAME'], 'test.pdf');
      expect(json['FILE_BYTES'], [10, 20, 30]);
    });

    test('fromJson with empty bytes', () {
      final json = {
        'ID': 5,
        'CREATED_AT': null,
        'CHANGED_AT': null,
        'DELETED_AT': null,
        'ANTRAGSNUMMER': 'empty',
        'DATEINAME': 'empty.txt',
        'FILE_BYTES': [],
      };
      final model = Datei.fromJson(json);
      expect(model.id, 5);
      expect(model.createdAt, null);
      expect(model.changedAt, null);
      expect(model.deletedAt, null);
      expect(model.fileBytes, isEmpty);
    });
  });
}
