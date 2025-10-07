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

  group('BankData additional coverage', () {
    test('fromJson sets defaults when optional fields missing or null', () {
      final json = {
        'BANKDATENWEBID': 5,
        'WEBLOGINID': 9,
        'KONTOINHABER': 'Alice',
        'IBAN': 'DE001122',
        'BIC': 'TESTBIC',
        'BANKNAME': null,
        'MANDATNR': null,
        'MANDATNAME': null,
        'MANDATSEQ': null,
        'LETZTENUTZUNG': null,
        'UNGUELTIG': null,
      };
      final data = BankData.fromJson(json);
      expect(data.id, 5);
      expect(data.webloginId, 9);
      expect(data.bankName, '');
      expect(data.mandatNr, '');
      expect(data.mandatName, '');
      expect(data.mandatSeq, 0);
      expect(data.letzteNutzung, isNull);
      expect(data.ungueltig, false);
    });

    test(
      'fromJson parses LETZTENUTZUNG when valid and ignores invalid format',
      () {
        final good = BankData.fromJson({
          'BANKDATENWEBID': 1,
          'WEBLOGINID': 1,
          'KONTOINHABER': 'A',
          'IBAN': 'X',
          'BIC': 'Y',
          'LETZTENUTZUNG': '2024-05-01T12:34:56Z',
        });
        expect(good.letzteNutzung, isNotNull);

        final bad = BankData.fromJson({
          'BANKDATENWEBID': 2,
          'WEBLOGINID': 1,
          'KONTOINHABER': 'B',
          'IBAN': 'X',
          'BIC': 'Y',
          'LETZTENUTZUNG': 'not-a-date',
        });
        expect(bad.letzteNutzung, isNull);
      },
    );

    test('fromJson coerces MANDATSEQ when provided as string', () {
      final data = BankData.fromJson({
        'BANKDATENWEBID': 3,
        'WEBLOGINID': 4,
        'KONTOINHABER': 'C',
        'IBAN': 'I',
        'BIC': 'B',
        'MANDATSEQ': '7',
      });
      expect(data.mandatSeq, 7);
    });

    test('toJson includes optional fields when set', () {
      final data = BankData(
        id: 10,
        webloginId: 11,
        kontoinhaber: 'Holder',
        iban: 'DE123',
        bic: 'BICX',
        bankName: 'Bank X',
        mandatNr: 'MN',
        mandatName: 'Name X',
        mandatSeq: 4,
        letzteNutzung: DateTime.parse('2024-01-01T00:00:00Z'),
        ungueltig: true,
      );
      final json = data.toJson();
      expect(json['Bankname'], 'Bank X');
      expect(json['MandatNr'], 'MN');
      expect(json['MandatSeq'], 4);
      // id may intentionally not be serialized (depends on model) so no assertion on id
    });

    test('copyWith can update every mutable field', () {
      final original = BankData(
        id: 1,
        webloginId: 2,
        kontoinhaber: 'Orig',
        iban: 'IBAN1',
        bic: 'BIC1',
        bankName: 'Bank1',
        mandatNr: 'M1',
        mandatName: 'MN1',
        mandatSeq: 1,
        letzteNutzung: DateTime.parse('2024-04-01T00:00:00Z'),
        ungueltig: false,
      );
      final newDate = DateTime.parse('2024-05-01T00:00:00Z');
      final updated = original.copyWith(
        kontoinhaber: 'New',
        iban: 'IBAN2',
        bic: 'BIC2',
        bankName: 'Bank2',
        mandatNr: 'M2',
        mandatName: 'MN2',
        mandatSeq: 9,
        letzteNutzung: newDate,
        ungueltig: true,
      );
      expect(updated.kontoinhaber, 'New');
      expect(updated.iban, 'IBAN2');
      expect(updated.bic, 'BIC2');
      expect(updated.bankName, 'Bank2');
      expect(updated.mandatNr, 'M2');
      expect(updated.mandatName, 'MN2');
      expect(updated.mandatSeq, 9);
      expect(updated.letzteNutzung, newDate);
      expect(updated.ungueltig, true);
      // unchanged
      expect(updated.id, original.id);
      expect(updated.webloginId, original.webloginId);
    });

    test('equality differs when a single field (iban) changes', () {
      const a = BankData(
        id: 1,
        webloginId: 2,
        kontoinhaber: 'Same',
        iban: 'IBAN_A',
        bic: 'BIC',
      );
      const b = BankData(
        id: 1,
        webloginId: 2,
        kontoinhaber: 'Same',
        iban: 'IBAN_B',
        bic: 'BIC',
      );
      expect(a == b, isFalse);
    });

    test('round trip fromJson -> toJson preserves key fields', () {
      final src = {
        'BANKDATENWEBID': 99,
        'WEBLOGINID': 3,
        'KONTOINHABER': 'Holder',
        'IBAN': 'DE3344',
        'BIC': 'BICZ',
        'BANKNAME': 'MyBank',
        'MANDATNR': 'M55',
        'MANDATNAME': 'Holder',
        'MANDATSEQ': 12,
        'UNGUELTIG': true,
      };
      final model = BankData.fromJson(src);
      final json = model.toJson();
      expect(json['WebloginID'], 3);
      expect(json['Kontoinhaber'], 'Holder');
      expect(json['IBAN'], 'DE3344');
      expect(json['BIC'], 'BICZ');
      expect(json['Bankname'], 'MyBank');
      expect(json['MandatNr'], 'M55');
      expect(json['MandatSeq'], 12);
    });

    test('toString reflects ungueltig true state', () {
      final model = BankData(
        id: 7,
        webloginId: 8,
        kontoinhaber: 'Z',
        iban: 'IB',
        bic: 'BC',
        ungueltig: true,
      );
      final s = model.toString();
      expect(s, contains('ungueltig: true'));
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
