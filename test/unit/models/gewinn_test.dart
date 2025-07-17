import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/gewinn.dart';

void main() {
  group('Gewinn', () {
    test('fromJson creates correct Gewinn object', () {
      final json = {
        'GEWINNID': 50,
        'JAHR': 2024,
        'TRADITION': false,
        'ISSACHPREIS': false,
        'GELDPREIS': 15,
        'SACHPREIS': '',
        'WETTBEWERB': '02 Preis des Deutschen Schützenbundes LG & LP',
        'ABGERUFENAM': '',
        'PLATZ': 1,
      };
      final gewinn = Gewinn.fromJson(json);
      expect(gewinn.gewinnId, 50);
      expect(gewinn.jahr, 2024);
      expect(gewinn.tradition, false);
      expect(gewinn.isSachpreis, false);
      expect(gewinn.geldpreis, 15);
      expect(gewinn.sachpreis, '');
      expect(
          gewinn.wettbewerb, '02 Preis des Deutschen Schützenbundes LG & LP',);
      expect(gewinn.abgerufenAm, '');
      expect(gewinn.platz, 1);
    });

    test('toJson returns correct map', () {
      const gewinn = Gewinn(
        gewinnId: 51,
        jahr: 2023,
        tradition: true,
        isSachpreis: true,
        geldpreis: 0,
        sachpreis: 'Pokale',
        wettbewerb: 'Test Wettbewerb',
        abgerufenAm: '2023-01-01',
        platz: 2,
      );
      final json = gewinn.toJson();
      expect(json['GEWINNID'], 51);
      expect(json['JAHR'], 2023);
      expect(json['TRADITION'], true);
      expect(json['ISSACHPREIS'], true);
      expect(json['GELDPREIS'], 0);
      expect(json['SACHPREIS'], 'Pokale');
      expect(json['WETTBEWERB'], 'Test Wettbewerb');
      expect(json['ABGERUFENAM'], '2023-01-01');
      expect(json['PLATZ'], 2);
    });

    test('fromJson handles numeric geldpreis as double', () {
      final json = {
        'GEWINNID': 52,
        'JAHR': 2022,
        'TRADITION': true,
        'ISSACHPREIS': false,
        'GELDPREIS': 12.5,
        'SACHPREIS': 'Medaille',
        'WETTBEWERB': 'Test',
        'ABGERUFENAM': '',
        'PLATZ': 3,
      };
      final gewinn = Gewinn.fromJson(json);
      expect(gewinn.geldpreis, 12.5);
    });
  });
}
