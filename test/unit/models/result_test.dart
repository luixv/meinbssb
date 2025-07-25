import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/result.dart';

void main() {
  group('Result', () {
    test('fromJson creates correct Result object', () {
      final json = {
        'WETTBEWERB': '97 LGA Ges.-Mannschaften',
        'PLATZ': 0,
        'GESAMT': 415.1,
        'POSTFIX': 'R',
      };
      final result = Result.fromJson(json);
      expect(result.wettbewerb, '97 LGA Ges.-Mannschaften');
      expect(result.platz, 0);
      expect(result.gesamt, 415.1);
      expect(result.postfix, 'R');
    });

    test('toJson returns correct map', () {
      const result = Result(
        wettbewerb: 'Sample Wettbewerb',
        platz: 1,
        gesamt: 123.45,
        postfix: 'X',
      );
      final json = result.toJson();
      expect(json['WETTBEWERB'], 'Sample Wettbewerb');
      expect(json['PLATZ'], 1);
      expect(json['GESAMT'], 123.45);
      expect(json['POSTFIX'], 'X');
    });

    test('fromJson handles integer GESAMT correctly', () {
      final json = {
        'WETTBEWERB': 'Test',
        'PLATZ': 2,
        'GESAMT': 100,
        'POSTFIX': 'Y',
      };
      final result = Result.fromJson(json);
      expect(result.gesamt, 100);
    });
  });
}
