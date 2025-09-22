import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/schulungstermine_zusatzfelder_data.dart';

void main() {
  group('SchulungstermineZusatzfelder', () {
    const model = SchulungstermineZusatzfelder(
      schulungstermineFeldId: 1,
      schulungsterminId: 876,
      feldbezeichnung: 'Feld A',
    );

    test('fromJson creates correct instance', () {
      final json = {
        'SCHULUNGENTERMINEFELDID': 1,
        'SCHULUNGENTERMINID': 876,
        'FELDBEZEICHNUNG': 'Feld A',
      };
      final result = SchulungstermineZusatzfelder.fromJson(json);
      expect(result.schulungstermineFeldId, 1);
      expect(result.schulungsterminId, 876);
      expect(result.feldbezeichnung, 'Feld A');
    });

    test('toJson returns correct map', () {
      final json = model.toJson();
      expect(json, {
        'SCHULUNGENTERMINEFELDID': 1,
        'SCHULUNGENTERMINID': 876,
        'FELDBEZEICHNUNG': 'Feld A',
      });
    });

    test('fromJson and toJson are symmetric', () {
      final json = model.toJson();
      final result = SchulungstermineZusatzfelder.fromJson(json);
      expect(result.schulungstermineFeldId, model.schulungstermineFeldId);
      expect(result.schulungsterminId, model.schulungsterminId);
      expect(result.feldbezeichnung, model.feldbezeichnung);
    });
  });
}
