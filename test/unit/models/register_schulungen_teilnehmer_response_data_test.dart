import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/register_schulungen_teilnehmer_response_data.dart';

void main() {
  group('RegisterSchulungenTeilnehmerResponse', () {
    test('can be constructed with all fields', () {
      final resp = RegisterSchulungenTeilnehmerResponse(
        msg: 'ok',
        platz: 2,
        maxPlaetze: 10,
      );
      expect(resp.msg, 'ok');
      expect(resp.platz, 2);
      expect(resp.maxPlaetze, 10);
    });

    test('fromJson with all fields', () {
      final resp = RegisterSchulungenTeilnehmerResponse.fromJson({
        'msg': 'success',
        'Platz': 5,
        'MaxPlaetze': 20,
      });
      expect(resp.msg, 'success');
      expect(resp.platz, 5);
      expect(resp.maxPlaetze, 20);
    });

    test('fromJson with missing fields uses defaults', () {
      final resp = RegisterSchulungenTeilnehmerResponse.fromJson({});
      expect(resp.msg, '');
      expect(resp.platz, 0);
      expect(resp.maxPlaetze, 0);
    });

    test('fromJson with null values uses defaults', () {
      final resp = RegisterSchulungenTeilnehmerResponse.fromJson({
        'msg': null,
        'Platz': null,
        'MaxPlaetze': null,
      });
      expect(resp.msg, '');
      expect(resp.platz, 0);
      expect(resp.maxPlaetze, 0);
    });
  });
}
