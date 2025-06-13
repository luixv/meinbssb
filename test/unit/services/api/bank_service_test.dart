import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:meinbssb/services/api/bank_service.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/models/bank_data.dart';

@GenerateMocks([HttpClient])
import 'bank_service_test.mocks.dart';

void main() {
  late BankService bankService;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    bankService = BankService(mockHttpClient);
  });

  group('BankService', () {
    group('fetchBankData', () {
      test('returns list of BankData on successful API call', () async {
        final testResponse = [
          {
            'BANKDATENWEBID': 1,
            'WEBLOGINID': 13901,
            'KONTOINHABER': 'Test User',
            'IBAN': 'DE89370400440532013000',
            'BIC': 'DEUTDEBBXXX',
            'BANKNAME': 'Test Bank',
            'MANDATNR': 'M123456',
            'MANDATNAME': 'Test Mandate',
            'MANDATSEQ': 1,
            'LETZTENUTZUNG': DateTime.now().toIso8601String(),
          }
        ];

        when(mockHttpClient.get('BankdatenMyBSSB/13901'))
            .thenAnswer((_) async => testResponse);

        final result = await bankService.fetchBankData(13901);

        expect(result.length, 1);
        expect(result[0].webloginId, 13901);
        expect(result[0].kontoinhaber, 'Test User');
        expect(result[0].iban, 'DE89370400440532013000');
        verify(mockHttpClient.get('BankdatenMyBSSB/13901')).called(1);
      });

      test('returns empty list when API returns empty response', () async {
        when(mockHttpClient.get('BankdatenMyBSSB/13901'))
            .thenAnswer((_) async => []);

        final result = await bankService.fetchBankData(13901);

        expect(result, isEmpty);
        verify(mockHttpClient.get('BankdatenMyBSSB/13901')).called(1);
      });

      test('returns empty list when API throws exception', () async {
        when(mockHttpClient.get('BankdatenMyBSSB/13901'))
            .thenThrow(Exception('API error'));

        final result = await bankService.fetchBankData(13901);

        expect(result, isEmpty);
        verify(mockHttpClient.get('BankdatenMyBSSB/13901')).called(1);
      });
    });

    group('registerBankData', () {
      final testBankData = BankData(
        id: 1,
        webloginId: 13901,
        kontoinhaber: 'Test User',
        iban: 'DE89370400440532013000',
        bic: 'DEUTDEBBXXX',
        bankName: 'Test Bank',
        mandatNr: 'M123456',
        mandatName: 'Test Mandate',
        mandatSeq: 1,
        letzteNutzung: DateTime.now(),
      );

      test('returns true on successful registration', () async {
        when(mockHttpClient.post('BankdatenMyBSSB', testBankData.toJson()))
            .thenAnswer((_) async => {'BankdatenWebID': 1});

        final result = await bankService.registerBankData(testBankData);

        expect(result, isTrue);
        verify(mockHttpClient.post('BankdatenMyBSSB', testBankData.toJson()))
            .called(1);
      });

      test('returns false when API response is empty', () async {
        when(mockHttpClient.post('BankdatenMyBSSB', testBankData.toJson()))
            .thenAnswer((_) async => {});

        final result = await bankService.registerBankData(testBankData);

        expect(result, isFalse);
        verify(mockHttpClient.post('BankdatenMyBSSB', testBankData.toJson()))
            .called(1);
      });

      test('returns false when API throws exception', () async {
        when(mockHttpClient.post('BankdatenMyBSSB', testBankData.toJson()))
            .thenThrow(Exception('API error'));

        final result = await bankService.registerBankData(testBankData);

        expect(result, isFalse);
        verify(mockHttpClient.post('BankdatenMyBSSB', testBankData.toJson()))
            .called(1);
      });
    });

    group('deleteBankData', () {
      final testBankData = BankData(
        id: 1,
        webloginId: 13901,
        kontoinhaber: 'Test User',
        iban: 'DE89370400440532013000',
        bic: 'DEUTDEBBXXX',
        bankName: 'Test Bank',
        mandatNr: 'M123456',
        mandatName: 'Test Mandate',
        mandatSeq: 1,
        letzteNutzung: DateTime.now(),
      );

      test('returns true on successful deletion', () async {
        when(mockHttpClient.delete('BankdatenMyBSSB/13901', body: {}))
            .thenAnswer((_) async => {'result': true});

        final result = await bankService.deleteBankData(testBankData);

        expect(result, isTrue);
        verify(mockHttpClient.delete('BankdatenMyBSSB/13901', body: {}))
            .called(1);
      });

      test('returns false when API response indicates failure', () async {
        when(mockHttpClient.delete('BankdatenMyBSSB/13901', body: {}))
            .thenAnswer((_) async => {'result': false});

        final result = await bankService.deleteBankData(testBankData);

        expect(result, isFalse);
        verify(mockHttpClient.delete('BankdatenMyBSSB/13901', body: {}))
            .called(1);
      });

      test('returns false when API throws exception', () async {
        when(mockHttpClient.delete('BankdatenMyBSSB/13901', body: {}))
            .thenThrow(Exception('API error'));

        final result = await bankService.deleteBankData(testBankData);

        expect(result, isFalse);
        verify(mockHttpClient.delete('BankdatenMyBSSB/13901', body: {}))
            .called(1);
      });
    });

    group('Static validation methods', () {
      group('validateIBAN', () {
        test('returns true for valid IBAN', () {
          expect(BankService.validateIBAN('DE89370400440532013000'), isTrue);
          expect(
            BankService.validateIBAN('DE89 3704 0044 0532 0130 00'),
            isTrue,
          );
        });

        test('returns false for invalid IBAN', () {
          expect(BankService.validateIBAN(null), isFalse);
          expect(BankService.validateIBAN(''), isFalse);
          expect(
            BankService.validateIBAN('DE8937040044053201300'),
            isFalse,
          ); // Too short
          expect(
            BankService.validateIBAN('DE893704004405320130000'),
            isFalse,
          ); // Too long
          expect(
            BankService.validateIBAN('DE89370400440532013001'),
            isFalse,
          ); // Invalid checksum
        });
      });

      group('validateBIC', () {
        test('returns null for valid BIC', () {
          expect(BankService.validateBIC('DEUTDEBBXXX'), isNull);
          expect(BankService.validateBIC('DEUTDEBB'), isNull);
        });

        test('returns error message for invalid BIC', () {
          expect(BankService.validateBIC(null), isNotNull);
          expect(BankService.validateBIC(''), isNotNull);
          expect(BankService.validateBIC('DEUTDE'), isNotNull); // Too short
          expect(
            BankService.validateBIC('DEUTDEBBXXXX'),
            isNotNull,
          ); // Too long
          expect(
            BankService.validateBIC('12345678'),
            isNotNull,
          ); // Invalid format
        });
      });
    });
  });
}
