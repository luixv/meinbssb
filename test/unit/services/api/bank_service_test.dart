// Project: Mein BSSB
// Filename: bank_service_test.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/api/bank_service.dart';
import 'package:meinbssb/services/core/http_client.dart';
// Import dart:convert for jsonEncode (still needed for verify, but not for mock return types)
import 'package:mockito/annotations.dart';

import 'bank_service_test.mocks.dart'; // Adjust path if necessary

@GenerateMocks([HttpClient])
void main() {
  late BankService bankService;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    bankService = BankService(httpClient: mockHttpClient);
  });

  group('BankService', () {
    group('fetchBankdaten', () {
      test('should return mapped bank data when HTTP response is a list',
          () async {
        // Arrange
        const int webloginId = 123;
        final List<Map<String, dynamic>> rawMockResponse = [
          {
            'BANKDATENWEBID': 1,
            'WEBLOGINID': webloginId,
            'KONTOINHABER': 'John Doe',
            'BANKNAME': 'Test Bank',
            'IBAN': 'DE89370400440532013000',
            'BIC': 'COBADEFFXXX',
            'MANDATNR': 'MANDAT123',
            'LETZTENUTZUNG': '2023-01-01',
            'MANDATNAME': 'Mandat Name',
            'MANDATSEQ': 'SEQ1',
            'UNGUELTIG': false,
          }
        ];
        // FIX 1: Mock HttpClient.get to directly return the decoded data
        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => rawMockResponse, // Directly return the List<Map>
        );

        // Act
        final result = await bankService.fetchBankdaten(webloginId);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['KONTOINHABER'], 'John Doe');
        expect(result['IBAN'], 'DE89370400440532013000');
        expect(result['BIC'], 'COBADEFFXXX');
        verify(mockHttpClient.get('BankdatenMyBSSB/$webloginId')).called(1);
      });

      test('should return mapped bank data when HTTP response is a map',
          () async {
        // Arrange
        const int webloginId = 123;
        final Map<String, dynamic> rawMockResponse = {
          'BANKDATENWEBID': 1,
          'WEBLOGINID': webloginId,
          'KONTOINHABER': 'Jane Smith',
          'BANKNAME': 'Another Bank',
          'IBAN': 'GB33BUKB20201555555555',
          'BIC': 'BUKBGB22',
          'MANDATNR': 'MANDAT456',
          'LETZTENUTZUNG': '2023-02-01',
          'MANDATNAME': 'Another Mandate',
          'MANDATSEQ': 'SEQ2',
          'UNGUELTIG': true,
        };
        // FIX 1: Mock HttpClient.get to directly return the decoded data
        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => rawMockResponse, // Directly return the Map
        );

        // Act
        final result = await bankService.fetchBankdaten(webloginId);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['KONTOINHABER'], 'Jane Smith');
        expect(result['IBAN'], 'GB33BUKB20201555555555');
        expect(result['BIC'], 'BUKBGB22');
        verify(mockHttpClient.get('BankdatenMyBSSB/$webloginId')).called(1);
      });

      test('should return empty map and log error on HTTP exception', () async {
        // Arrange
        const int webloginId = 123;
        // FIX 1: Mock HttpClient.get to directly throw the exception
        when(mockHttpClient.get(any)).thenThrow(Exception('Network error'));

        // Act
        final result = await bankService.fetchBankdaten(webloginId);

        // Assert
        expect(result, isEmpty);
      });

      test('should return empty map for empty list response', () async {
        // Arrange
        const int webloginId = 123;
        final List<Map<String, dynamic>> rawMockResponse = [];
        // FIX 1: Mock HttpClient.get to directly return the empty list
        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => rawMockResponse, // Directly return the empty List
        );

        // Act
        final result = await bankService.fetchBankdaten(webloginId);

        // Assert
        expect(result, isEmpty);
      });

      test('should return empty map for non-list/non-map response', () async {
        // Arrange
        const int webloginId = 123;
        const String rawMockResponse = 'invalid data';
        // FIX 1: Mock HttpClient.get to directly return the invalid data (though BankService will handle it)
        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => rawMockResponse, // Directly return the invalid String
        );

        // Act
        final result = await bankService.fetchBankdaten(webloginId);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('registerBankdaten', () {
      test('should return BankdatenWebID on successful registration', () async {
        // Arrange
        const int webloginId = 456;
        const String kontoinhaber = 'Test Kontoinhaber'; // Renamed
        const String iban = 'DE12345678901234567890';
        const String bic = 'TESTBANKBIC';
        const int expectedBankdatenWebId = 1627;

        final Map<String, dynamic> mockSuccessResponse = {
          'BankdatenWebID': expectedBankdatenWebId,
        };

        // FIX 1: Mock HttpClient.post to directly return the decoded data
        when(mockHttpClient.post(any, any)).thenAnswer(
          (_) async => mockSuccessResponse, // Directly return the Map
        );

        // Act
        final result = await bankService.registerBankdaten(
          webloginId,
          kontoinhaber,
          iban,
          bic,
        );

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['BankdatenWebID'], expectedBankdatenWebId);
        // These assertions are still fine as long as the mock doesn't include them
        expect(result.containsKey('ResultType'), isFalse);
        expect(result.containsKey('ResultMessage'), isFalse);

        // Verify the post call with expected arguments
        verify(
          mockHttpClient.post(
            'BankdatenMyBSSB',
            {
              'WebloginID': webloginId,
              'Kontoinhaber': kontoinhaber, // Renamed
              'Bankname': '',
              'IBAN': iban,
              'BIC': bic,
              'MandatNr': '',
              'MandatSeq': 2,
            },
          ),
        ).called(1);
      });

      test('should return empty map and log error on HTTP exception', () async {
        // Arrange
        const int webloginId = 456;
        const String kontoinhaber = 'Test Kontoinhaber'; // Renamed
        const String iban = 'DE12345678901234567890';
        const String bic = 'TESTBANKBIC';

        // FIX 1: Mock HttpClient.post to directly throw the exception
        when(mockHttpClient.post(any, any)).thenThrow(Exception('API error'));

        // Act
        final result = await bankService.registerBankdaten(
          webloginId,
          kontoinhaber,
          iban,
          bic,
        );

        // Assert
        expect(result, isEmpty);
      });

      test('should return empty map if API returns non-success map', () async {
        // Arrange
        const int webloginId = 456;
        const String kontoinhaber = 'Test Kontoinhaber';
        const String iban = 'DE12345678901234567890';
        const String bic = 'TESTBANKBIC';

        // Simulate an API error response that is a Map, but without BankdatenWebID
        final Map<String, dynamic> mockErrorResponse = {
          'error': 'Invalid IBAN provided',
        };

        // FIX 1: Mock HttpClient.post to directly return the mockErrorResponse Map
        when(mockHttpClient.post(any, any)).thenAnswer(
          (_) async => mockErrorResponse,
        );

        // Act
        final result = await bankService.registerBankdaten(
          webloginId,
          kontoinhaber,
          iban,
          bic,
        );

        // Assert
        expect(result, isEmpty);
      });

      test('should return empty map if response is not a Map<String, dynamic>',
          () async {
        // Arrange
        const int webloginId = 456;
        const String kontoinhaber = 'Test Kontoinhaber';
        const String iban = 'DE12345678901234567890';
        const String bic = 'TESTBANKBIC';

        const String mockInvalidResponse =
            'Some non-JSON string'; // Or a List, or null

        // FIX 1: Mock HttpClient.post to directly return the non-Map response
        when(mockHttpClient.post(any, any)).thenAnswer(
          (_) async => mockInvalidResponse,
        );

        // Act
        final result = await bankService.registerBankdaten(
          webloginId,
          kontoinhaber,
          iban,
          bic,
        );

        // Assert
        expect(result, isEmpty);
      });

      test('should return empty map if response body is empty (non-map)',
          () async {
        // Arrange
        const int webloginId = 456;
        const String kontoinhaber = 'Test Kontoinhaber';
        const String iban = 'DE12345678901234567890';
        const String bic = 'TESTBANKBIC';

        // FIX 1: Mock HttpClient.post to directly return an empty string
        when(mockHttpClient.post(any, any)).thenAnswer(
          (_) async => '', // Simulates an empty body (non-map/non-list)
        );

        // Act
        final result = await bankService.registerBankdaten(
          webloginId,
          kontoinhaber,
          iban,
          bic,
        );

        // Assert
        expect(result, isEmpty);
      });
    });

    group('validateIBAN', () {
      test('should return true for a valid German IBAN', () {
        expect(BankService.validateIBAN('DE89370400440532013000'), isTrue);
      });

      test('should return true for a valid UK IBAN', () {
        expect(BankService.validateIBAN('GB33BUKB20201555555555'), isTrue);
      });

      test('should return true for a valid French IBAN', () {
        expect(BankService.validateIBAN('FR1420041010050500013M02606'), isTrue);
      });

      test('should return true for a valid IBAN with spaces', () {
        expect(BankService.validateIBAN('DE89 3704 0044 0532 0130 00'), isTrue);
      });

      test('should return false for an IBAN with invalid characters', () {
        expect(BankService.validateIBAN('DE8937040044053201300@'), isFalse);
      });

      test('should return false for an IBAN that is too short', () {
        expect(BankService.validateIBAN('DE89'), isFalse);
      });

      test('should return false for an IBAN with incorrect check digits', () {
        expect(BankService.validateIBAN('DE89370400440532013001'), isFalse);
      });

      test('should return false for an empty IBAN', () {
        expect(BankService.validateIBAN(''), isFalse);
      });

      test('should return false for an IBAN with wrong country code format',
          () {
        expect(BankService.validateIBAN('1234567890123456789012'), isFalse);
      });
    });

    group('validateBIC', () {
      test('should return null for a valid 8-character BIC', () {
        expect(BankService.validateBIC('DEUTDEFF'), isNull);
      });

      test('should return null for a valid 11-character BIC', () {
        expect(BankService.validateBIC('COBADEFFXXX'), isNull);
      });

      test(
          'should return null for a valid BIC with mixed case (should be uppercased internally)',
          () {
        expect(BankService.validateBIC('dbabdeff'), isNull);
      });

      // FIX 2: Update expected error messages for validateBIC
      test('should return error message for an empty BIC', () {
        expect(
          BankService.validateBIC(''),
          'BIC muss 8 oder 11 Zeichen lang sein',
        );
      });

      test('should return error message for a null BIC', () {
        expect(
          BankService.validateBIC(null),
          'BIC muss 8 oder 11 Zeichen lang sein',
        );
      });

      test('should return error message for a BIC that is too short (7 chars)',
          () {
        expect(
          BankService.validateBIC('DEUTDEF'),
          'BIC muss 8 oder 11 Zeichen lang sein',
        );
      });

      test('should return error message for a BIC that is too long (12 chars)',
          () {
        expect(
          BankService.validateBIC('COBADEFFXXXX'),
          'BIC muss 8 oder 11 Zeichen lang sein',
        );
      });

      test('should return error message for a BIC with invalid characters', () {
        expect(
          BankService.validateBIC('DEUTDE!@'),
          'Ungültiger BIC (Ortscode)', // Based on current code logic
        );
      });

      test(
          'should return error message for a BIC with incorrect format (e.g., numbers in country code)',
          () {
        expect(
          BankService.validateBIC('1234DEFF'),
          'Ungültiger BIC (Bank- und Länderkennung)', // Based on current code logic
        );
      });
    });
  });
}
