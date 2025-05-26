// Project: Mein BSSB
// Filename: bank_service_test.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/api/bank_service.dart';
import 'package:meinbssb/services/http_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import dart:convert for jsonEncode
import 'package:mockito/annotations.dart';

import 'bank_service_test.mocks.dart'; // Adjust path if necessary

@GenerateMocks([HttpClient])
void main() {
  late BankService bankService;
  // Use the generated MockHttpClient class directly.
  late MockHttpClient mockHttpClient;

  setUp(() {
    // Instantiate the generated mock.
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
        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(jsonEncode(rawMockResponse), 200),
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
        // Correctly mock HttpClient.get to return an http.Response
        // The HttpClient.get method does NOT take 'headers' or 'body' as named parameters.
        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(jsonEncode(rawMockResponse), 200),
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
        // The HttpClient.get method does NOT take 'headers' or 'body' as named parameters.
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
        // Correctly mock HttpClient.get to return an http.Response
        // with an empty JSON list body.
        // The HttpClient.get method does NOT take 'headers' or 'body' as named parameters.
        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(jsonEncode(rawMockResponse), 200),
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
        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response(rawMockResponse, 200));

        // Act
        final result = await bankService.fetchBankdaten(webloginId);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('BankService', () {
      // ... (fetchBankdaten group) ...

      group('registerBankdaten', () {
        test('should return BankdatenWebID on successful registration',
            () async {
          // Arrange
          const int webloginId = 456;
          const String mandatName = 'Test Mandat';
          const String iban = 'DE12345678901234567890';
          const String bic = 'TESTBANKBIC';
          const int expectedBankdatenWebId = 1627; // New expected ID

          // The mock response now reflects the actual API output
          final Map<String, dynamic> mockSuccessResponse = {
            'BankdatenWebID': expectedBankdatenWebId,
          };

          when(mockHttpClient.post(any, any)).thenAnswer(
            (_) async => http.Response(jsonEncode(mockSuccessResponse), 200),
          );

          // Act
          final result = await bankService.registerBankdaten(
            webloginId,
            mandatName,
            iban,
            bic,
          );

          // Assert
          expect(result, isA<Map<String, dynamic>>());
          expect(
            result['BankdatenWebID'],
            expectedBankdatenWebId,
          ); // Expect the ID
          expect(
            result.containsKey('ResultType'),
            isFalse,
          ); // Ensure no ResultType
          expect(
            result.containsKey('ResultMessage'),
            isFalse,
          ); // Ensure no ResultMessage

          // Verify the post call with expected arguments
          verify(
            mockHttpClient.post(
              'BankdatenMyBSSB',
              {
                'WebloginID': webloginId,
                'Kontoinhaber': mandatName,
                'Bankname': '',
                'IBAN': iban,
                'BIC': bic,
                'MandatNr': '',
                'MandatSeq': 2,
              },
            ),
          ).called(1);
        });

        test('should return empty map and log error on HTTP exception',
            () async {
          // Arrange
          const int webloginId = 456;
          const String mandatName = 'Test Mandat';
          const String iban = 'DE12345678901234567890';
          const String bic = 'TESTBANKBIC';

          when(mockHttpClient.post(any, any)).thenThrow(Exception('API error'));

          // Act
          final result = await bankService.registerBankdaten(
            webloginId,
            mandatName,
            iban,
            bic,
          );

          // Assert
          expect(result, isEmpty);
        });

        test('should return empty map if API returns non-200 status code',
            () async {
          // Arrange
          const int webloginId = 456;
          const String mandatName = 'Test Mandat';
          const String iban = 'DE12345678901234567890';
          const String bic = 'TESTBANKBIC';

          // Simulate an API error response (e.g., 400 Bad Request)
          final Map<String, dynamic> mockErrorResponse = {
            'error': 'Invalid IBAN provided',
          };

          when(mockHttpClient.post(any, any)).thenAnswer(
            (_) async =>
                http.Response(jsonEncode(mockErrorResponse), 400), // Status 400
          );

          // Act
          final result = await bankService.registerBankdaten(
            webloginId,
            mandatName,
            iban,
            bic,
          );

          // Assert
          expect(
            result,
            isEmpty,
          ); // Expect empty map as per your error handling
        });

        test(
            'should return empty map if response is not a Map<String, dynamic>',
            () async {
          // Arrange
          const int webloginId = 456;
          const String mandatName = 'Test Mandat';
          const String iban = 'DE12345678901234567890';
          const String bic = 'TESTBANKBIC';

          const String mockInvalidResponse =
              'Some non-JSON string'; // Or a List, or null

          when(mockHttpClient.post(any, any)).thenAnswer(
            (_) async => http.Response(
              mockInvalidResponse,
              200,
            ), // Status 200 but invalid body
          );

          // Act
          final result = await bankService.registerBankdaten(
            webloginId,
            mandatName,
            iban,
            bic,
          );

          // Assert
          expect(result, isEmpty);
        });

        test('should return empty map if response body is empty', () async {
          // Arrange
          const int webloginId = 456;
          const String mandatName = 'Test Mandat';
          const String iban = 'DE12345678901234567890';
          const String bic = 'TESTBANKBIC';

          when(mockHttpClient.post(any, any)).thenAnswer(
            (_) async => http.Response('', 200), // Empty body
          );

          // Act
          final result = await bankService.registerBankdaten(
            webloginId,
            mandatName,
            iban,
            bic,
          );

          // Assert
          expect(result, isEmpty);
        });
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

      test('should return error message for an empty BIC', () {
        expect(BankService.validateBIC(''), 'BIC ist erforderlich');
      });

      test('should return error message for a null BIC', () {
        expect(BankService.validateBIC(null), 'BIC ist erforderlich');
      });

      test('should return error message for a BIC that is too short (7 chars)',
          () {
        expect(
          BankService.validateBIC('DEUTDEF'),
          'Ungültiger BIC (Beispiel: DEUTDEFFXXX)',
        );
      });

      test('should return error message for a BIC that is too long (12 chars)',
          () {
        expect(
          BankService.validateBIC('COBADEFFXXXX'),
          'Ungültiger BIC (Beispiel: DEUTDEFFXXX)',
        );
      });

      test('should return error message for a BIC with invalid characters', () {
        expect(
          BankService.validateBIC('DEUTDE!@'),
          'Ungültiger BIC (Beispiel: DEUTDEFFXXX)',
        );
      });

      test(
          'should return error message for a BIC with incorrect format (e.g., numbers in country code)',
          () {
        expect(
          BankService.validateBIC('1234DEFF'),
          'Ungültiger BIC (Beispiel: DEUTDEFFXXX)',
        );
      });
    });
  });
}
