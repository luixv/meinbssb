// Project: Mein BSSB
// Filename: training_service.dart
// Author: Luis Mandel / NTT DATA

import 'dart:async';

import '/services/http_client.dart';
import '/services/logger_service.dart';

class BankService {
  BankService({
    required HttpClient httpClient,
  }) : _httpClient = httpClient;

  final HttpClient _httpClient;

  Future<Map<String, dynamic>> fetchBankdaten(int webloginId) async {
    try {
      final response = await _httpClient.get('BankdatenMyBSSB/$webloginId');
      final mappedResponse = _mapBankdatenResponse(response);

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
}
