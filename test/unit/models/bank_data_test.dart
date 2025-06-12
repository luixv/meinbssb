import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/bank_data.dart';

void main() {
  group('BankData', () {
    test('creates instance from JSON with all fields', () {
      final json = {
        'BANKDATENWEBID': 1,
        'WEBLOGINID': 2,
        'KONTOINHABER': 'John Doe',
        'IBAN': 'DE89370400440532013000',
        'BIC': 'DEUTDEBBXXX',
        'BANKNAME': 'Deutsche Bank',
        'MANDATNR': 'MANDATE123',
        'MANDATNAME': 'John Doe',
        'MANDATSEQ': 1,
        'LETZTENUTZUNG': '2024-03-20T10:00:00Z',
        'UNGUELTIG': false,
      };

      final bankData = BankData.fromJson(json);

      expect(bankData.id, 1);
      expect(bankData.webloginId, 2);
      expect(bankData.kontoinhaber, 'John Doe');
      expect(bankData.iban, 'DE89370400440532013000');
      expect(bankData.bic, 'DEUTDEBBXXX');
      expect(bankData.bankName, 'Deutsche Bank');
      expect(bankData.mandatNr, 'MANDATE123');
      expect(bankData.mandatName, 'John Doe');
      expect(bankData.mandatSeq, 1);
      expect(bankData.letzteNutzung, DateTime.parse('2024-03-20T10:00:00Z'));
      expect(bankData.ungueltig, false);
    });

    test('creates instance from JSON with minimal fields', () {
      final json = {
        'BANKDATENWEBID': 1,
        'WEBLOGINID': 2,
        'KONTOINHABER': 'John Doe',
        'IBAN': 'DE89370400440532013000',
        'BIC': 'DEUTDEBBXXX',
      };

      final bankData = BankData.fromJson(json);

      expect(bankData.id, 1);
      expect(bankData.webloginId, 2);
      expect(bankData.kontoinhaber, 'John Doe');
      expect(bankData.iban, 'DE89370400440532013000');
      expect(bankData.bic, 'DEUTDEBBXXX');
      expect(bankData.bankName, '');
      expect(bankData.mandatNr, '');
      expect(bankData.mandatName, '');
      expect(bankData.mandatSeq, 0);
      expect(bankData.letzteNutzung, null);
      expect(bankData.ungueltig, false);
    });

    test('converts to JSON correctly', () {
      final bankData = BankData(
        id: 1,
        webloginId: 2,
        kontoinhaber: 'John Doe',
        iban: 'DE89370400440532013000',
        bic: 'DEUTDEBBXXX',
        bankName: 'Deutsche Bank',
        mandatNr: 'MANDATE123',
        mandatName: 'John Doe',
        mandatSeq: 1,
        letzteNutzung: DateTime.parse('2024-03-20T10:00:00Z'),
        ungueltig: false,
      );

      final json = bankData.toJson();

      expect(json['WebloginID'], 2);
      expect(json['Kontoinhaber'], 'John Doe');
      expect(json['IBAN'], 'DE89370400440532013000');
      expect(json['BIC'], 'DEUTDEBBXXX');
      expect(json['Bankname'], 'Deutsche Bank');
      expect(json['MandatNr'], 'MANDATE123');
      expect(json['MandatSeq'], 1);
    });

    test('copyWith creates new instance with updated fields', () {
      const original = BankData(
        id: 1,
        webloginId: 2,
        kontoinhaber: 'John Doe',
        iban: 'DE89370400440532013000',
        bic: 'DEUTDEBBXXX',
      );

      final updated = original.copyWith(
        kontoinhaber: 'Jane Doe',
        bankName: 'New Bank',
      );

      expect(updated.id, original.id);
      expect(updated.webloginId, original.webloginId);
      expect(updated.kontoinhaber, 'Jane Doe');
      expect(updated.iban, original.iban);
      expect(updated.bic, original.bic);
      expect(updated.bankName, 'New Bank');
      expect(updated.mandatNr, original.mandatNr);
      expect(updated.mandatName, original.mandatName);
      expect(updated.mandatSeq, original.mandatSeq);
      expect(updated.letzteNutzung, original.letzteNutzung);
      expect(updated.ungueltig, original.ungueltig);
    });

    test('equality works correctly', () {
      const bankData1 = BankData(
        id: 1,
        webloginId: 2,
        kontoinhaber: 'John Doe',
        iban: 'DE89370400440532013000',
        bic: 'DEUTDEBBXXX',
      );

      const bankData2 = BankData(
        id: 1,
        webloginId: 2,
        kontoinhaber: 'John Doe',
        iban: 'DE89370400440532013000',
        bic: 'DEUTDEBBXXX',
      );

      const bankData3 = BankData(
        id: 2,
        webloginId: 2,
        kontoinhaber: 'John Doe',
        iban: 'DE89370400440532013000',
        bic: 'DEUTDEBBXXX',
      );

      expect(bankData1, bankData2);
      expect(bankData1, isNot(bankData3));
      expect(bankData1.hashCode, bankData2.hashCode);
      expect(bankData1.hashCode, isNot(bankData3.hashCode));
    });

    test('toString returns correct representation', () {
      final bankData = BankData(
        id: 1,
        webloginId: 2,
        kontoinhaber: 'John Doe',
        iban: 'DE89370400440532013000',
        bic: 'DEUTDEBBXXX',
        bankName: 'Deutsche Bank',
        mandatNr: 'MANDATE123',
        mandatName: 'John Doe',
        mandatSeq: 1,
        letzteNutzung: DateTime.parse('2024-03-20T10:00:00Z'),
        ungueltig: false,
      );

      final string = bankData.toString();

      expect(string, contains('id: 1'));
      expect(string, contains('webloginId: 2'));
      expect(string, contains('kontoinhaber: John Doe'));
      expect(string, contains('iban: DE89370400440532013000'));
      expect(string, contains('bic: DEUTDEBBXXX'));
      expect(string, contains('bankName: Deutsche Bank'));
      expect(string, contains('mandatNr: MANDATE123'));
      expect(string, contains('mandatName: John Doe'));
      expect(string, contains('mandatSeq: 1'));
      expect(string, contains('letzteNutzung: 2024-03-20 10:00:00.000Z'));
      expect(string, contains('ungueltig: false'));
    });
  });

  test('BankData creates instance from JSON', () {
    final json = {
      'BANKDATENWEBID': 1,
      'WEBLOGINID': 2,
      'KONTOINHABER': 'John Doe',
      'IBAN': 'DE89370400440532013000',
      'BIC': 'DEUTDEBBXXX',
    };

    final bankData = BankData.fromJson(json);

    expect(bankData.id, 1);
    expect(bankData.webloginId, 2);
    expect(bankData.kontoinhaber, 'John Doe');
    expect(bankData.iban, 'DE89370400440532013000');
    expect(bankData.bic, 'DEUTDEBBXXX');
  });
}
