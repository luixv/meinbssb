// Project: Mein BSSB
// Filename: bank_service.dart (Updated)
// Author: Luis Mandel / NTT DATA

import 'dart:async';
import 'dart:convert'; // Import for jsonDecode

import '/services/http_client.dart';
import '/services/logger_service.dart';
import 'package:http/http.dart' as http; // Import http for http.Response

class BankService {
  BankService({
    required HttpClient httpClient,
  }) : _httpClient = httpClient;

  final HttpClient _httpClient;

  Future<Map<String, dynamic>> fetchBankdaten(int webloginId) async {
    try {
      // HttpClient.get returns an http.Response.
      final http.Response response =
          await _httpClient.get('BankdatenMyBSSB/$webloginId');

      // Decode the JSON body of the http.Response before mapping.
      final dynamic decodedResponse = jsonDecode(response.body);
      final mappedResponse = _mapBankdatenResponse(decodedResponse);

      return mappedResponse;
    } catch (e) {
      LoggerService.logError('Error fetching available Schulungen: $e');
      return {};
    }
  }

  Map<String, dynamic> _mapBankdatenResponse(dynamic response) {
    // Handle different response types (List or Map) for robustness
    if (response is List) {
      if (response.isNotEmpty) {
        final Map<String, dynamic> data =
            response.first as Map<String, dynamic>; // Extract the first element
        // Map the fields to the desired structure, including ONLINE
        return {
          'BANKDATENWEBID': data['BANKDATENWEBID'],
          'WEBLOGINID': data['WEBLOGINID'],
          'KONTOINHABER': data['KONTOINHABER'],
          'BANKNAME': data['BANKNAME'],
          'IBAN': data['IBAN'],
          'BIC': data['BIC'],
          'MANDATNR': data['MANDATNR'],
          'LETZTENUTZUNG': data['LETZTENUTZUNG'],
          'MANDATNAME': data['MANDATNAME'],
          'MANDATSEQ': data['MANDATSEQ'],
          'UNGUELTIG': data['UNGUELTIG'],
        };
      } else {
        return {}; // Return empty map for empty list
      }
    } else if (response is Map<String, dynamic>) {
      //if the response is already a map, return it.
      return {
        'BANKDATENWEBID': response['BANKDATENWEBID'],
        'WEBLOGINID': response['WEBLOGINID'],
        'KONTOINHABER': response['KONTOINHABER'],
        'BANKNAME': response['BANKNAME'],
        'IBAN': response['IBAN'],
        'BIC': response['BIC'],
        'MANDATNR': response['MANDATNR'],
        'LETZTENUTZUNG': response['LETZTENUTZUNG'],
        'MANDATNAME': response['MANDATNAME'],
        'MANDATSEQ': response['MANDATSEQ'],
        'UNGUELTIG': response['UNGUELTIG'],
      };
    }
    return {}; // Return empty map for other cases
  }

  // IBAN Validator functions moved from BankDataScreen
  static bool validateIBAN(String iban) {
    iban =
        iban.toUpperCase().replaceAll(' ', ''); // Remove spaces and uppercase

    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(iban)) {
      return false; // Invalid characters
    }

    if (iban.length < 5) {
      return false; // Too short to be a valid IBAN
    }

    String countryCode = iban.substring(0, 2);
    String checkDigits = iban.substring(2, 4);
    String bban = iban.substring(4);

    String movedIban = bban + countryCode + checkDigits;

    String numericIban = '';
    for (int i = 0; i < movedIban.length; i++) {
      String char = movedIban[i];
      if (RegExp(r'^[0-9]$').hasMatch(char)) {
        numericIban += char;
      } else {
        numericIban += (char.codeUnitAt(0) - 55).toString(); // A=10, B=11, ...
      }
    }

    //int remainder = _mod97(numericIban); // Original call to private method
    int remainder = 0; // Inlined _mod97 logic
    for (int i = 0; i < numericIban.length; i++) {
      remainder = (remainder * 10 + int.parse(numericIban[i])) % 97;
    }

    return remainder == 1;
  }

  // BIC Validator
  static String? validateBIC(String? value) {
    if (value == null || value.isEmpty) {
      return 'BIC ist erforderlich';
    }
    // BIC (SWIFT code) is 8 or 11 alphanumeric characters.
    // Format: AAAA BB CC DDD (AAAA: bank code, BB: country code, CC: location code, DDD: optional branch code)
    // Only A-Z and 0-9 are allowed.
    final bicRegex = RegExp(r'^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
    if (!bicRegex.hasMatch(value.toUpperCase())) {
      return 'Ungültiger BIC (Beispiel: DEUTDEFFXXX)';
    }
    return null;
  }

  Future<Map<String, dynamic>> registerBankdaten(
    int webloginId,
    String mandatName,
    String iban,
    String bic,
  ) async {
    try {
      final http.Response response = await _httpClient.post('BankdatenMyBSSB', {
        'WebloginID': webloginId,
        'Kontoinhaber': mandatName,
        'Bankname': '',
        'IBAN': iban,
        'BIC': bic,
        'MandatNr': '',
        'MandatSeq': 2,
      });

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        try {
          final decodedResponse = jsonDecode(response.body);
          if (decodedResponse is Map<String, dynamic>) {
            // Expecting something like {"BankdatenWebID": 1627}
            LoggerService.logInfo(
              'Successfully registered bankdaten. Response: ${jsonEncode(decodedResponse)}',
            );
            return decodedResponse;
          } else {
            // This handles cases where the response is not a Map (e.g., a list, or primitive)
            LoggerService.logWarning(
              'registerBankdaten: Expected a Map, but received: ${decodedResponse.runtimeType} -> $decodedResponse',
            );
            return {};
          }
        } on FormatException catch (e) {
          // Catches errors if response.body is not valid JSON
          LoggerService.logError(
            'registerBankdaten: JSON decoding failed: $e, Body: ${response.body}',
          );
          return {};
        }
      } else {
        // Handles non-200 status codes or empty body
        LoggerService.logError(
          'registerBankdaten HTTP error: Status ${response.statusCode}, Body: ${response.body}',
        );
        return {};
      }
    } catch (e) {
      // Catches network errors or other exceptions during the HTTP request
      LoggerService.logError('Error while registering bankdaten: $e');
      return {};
    }
  }
}
