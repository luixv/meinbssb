import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/schulungsart_data.dart';

void main() {
  group('Schulungsart', () {
    test('should create Schulungsart from JSON', () {
      // Arrange
      final json = {
        'SCHULUNGSARTID': 41,
        'BEZEICHNUNG': 'Vereinsmanager C, Aufbauphase, Qualifizierungskurs',
        'TYP': 6,
        'KOSTEN': 0.0,
        'UE': 0,
        'OMKATEGORIEID': 1,
        'RECHNUNGAN': 1,
        'VERPFLEGUNGSKOSTEN': 0.0,
        'UEBERNACHTUNGSKOSTEN': 0.0,
        'LEHRMATERIALKOSTEN': 0.0,
        'LEHRGANGSINHALT': '',
        'LEHRGANGSINHALTHTML': '',
        'WEBGRUPPE': 3,
        'FUERVERLAENGERUNGEN': false,
      };

      // Act
      final schulungsart = Schulungsart.fromJson(json);

      // Assert
      expect(schulungsart.schulungsartId, equals(41));
      expect(
        schulungsart.bezeichnung,
        equals('Vereinsmanager C, Aufbauphase, Qualifizierungskurs'),
      );
      expect(schulungsart.typ, equals(6));
      expect(schulungsart.kosten, equals(0.0));
      expect(schulungsart.ue, equals(0));
      expect(schulungsart.omKategorieId, equals(1));
      expect(schulungsart.rechnungAn, equals(1));
      expect(schulungsart.verpflegungskosten, equals(0.0));
      expect(schulungsart.uebernachtungskosten, equals(0.0));
      expect(schulungsart.lehrmaterialkosten, equals(0.0));
      expect(schulungsart.lehrgangsinhalt, equals(''));
      expect(schulungsart.lehrgangsinhaltHtml, equals(''));
      expect(schulungsart.webGruppe, equals(3));
      expect(schulungsart.fuerVerlaengerungen, equals(false));
    });

    test('should convert Schulungsart to JSON', () {
      // Arrange
      const schulungsart = Schulungsart(
        schulungsartId: 41,
        bezeichnung: 'Vereinsmanager C, Aufbauphase, Qualifizierungskurs',
        typ: 6,
        kosten: 0.0,
        ue: 0,
        omKategorieId: 1,
        rechnungAn: 1,
        verpflegungskosten: 0.0,
        uebernachtungskosten: 0.0,
        lehrmaterialkosten: 0.0,
        lehrgangsinhalt: '',
        lehrgangsinhaltHtml: '',
        webGruppe: 3,
        fuerVerlaengerungen: false,
      );

      // Act
      final json = schulungsart.toJson();

      // Assert
      expect(json['SCHULUNGSARTID'], equals(41));
      expect(
        json['BEZEICHNUNG'],
        equals('Vereinsmanager C, Aufbauphase, Qualifizierungskurs'),
      );
      expect(json['TYP'], equals(6));
      expect(json['KOSTEN'], equals(0.0));
      expect(json['UE'], equals(0));
      expect(json['OMKATEGORIEID'], equals(1));
      expect(json['RECHNUNGAN'], equals(1));
      expect(json['VERPFLEGUNGSKOSTEN'], equals(0.0));
      expect(json['UEBERNACHTUNGSKOSTEN'], equals(0.0));
      expect(json['LEHRMATERIALKOSTEN'], equals(0.0));
      expect(json['LEHRGANGSINHALT'], equals(''));
      expect(json['LEHRGANGSINHALTHTML'], equals(''));
      expect(json['WEBGRUPPE'], equals(3));
      expect(json['FUERVERLAENGERUNGEN'], equals(false));
    });

    test('should handle numeric values correctly', () {
      // Arrange
      final json = {
        'SCHULUNGSARTID': 41,
        'BEZEICHNUNG': 'Test Schulung',
        'TYP': 6,
        'KOSTEN': 100, // Integer instead of double
        'UE': 0,
        'OMKATEGORIEID': 1,
        'RECHNUNGAN': 1,
        'VERPFLEGUNGSKOSTEN': 50, // Integer instead of double
        'UEBERNACHTUNGSKOSTEN': 75, // Integer instead of double
        'LEHRMATERIALKOSTEN': 25, // Integer instead of double
        'LEHRGANGSINHALT': '',
        'LEHRGANGSINHALTHTML': '',
        'WEBGRUPPE': 3,
        'FUERVERLAENGERUNGEN': false,
      };

      // Act
      final schulungsart = Schulungsart.fromJson(json);

      // Assert
      expect(schulungsart.kosten, equals(100.0));
      expect(schulungsart.verpflegungskosten, equals(50.0));
      expect(schulungsart.uebernachtungskosten, equals(75.0));
      expect(schulungsart.lehrmaterialkosten, equals(25.0));
    });

    test('toString should return correct format', () {
      // Arrange
      const schulungsart = Schulungsart(
        schulungsartId: 41,
        bezeichnung: 'Test Schulung',
        typ: 6,
        kosten: 0.0,
        ue: 0,
        omKategorieId: 1,
        rechnungAn: 1,
        verpflegungskosten: 0.0,
        uebernachtungskosten: 0.0,
        lehrmaterialkosten: 0.0,
        lehrgangsinhalt: '',
        lehrgangsinhaltHtml: '',
        webGruppe: 3,
        fuerVerlaengerungen: false,
      );

      // Act
      final string = schulungsart.toString();

      // Assert
      expect(
        string,
        equals(
          'Schulungsart(schulungsartId: 41, bezeichnung: Test Schulung, typ: 6)',
        ),
      );
    });
  });
}
