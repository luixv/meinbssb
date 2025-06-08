// In lib/services/api/bank_service.dart

import 'dart:convert';
import '../core/http_client.dart';
import '../core/logger_service.dart';

class BankService {
  BankService({required HttpClient httpClient}) : _httpClient = httpClient;
  final HttpClient _httpClient;

  /// Fetches bank data for a given weblogin ID.
  /// Assumes _httpClient.get directly returns the JSON-decoded data (List or Map).
  ///
  /// Returns a Map<String, dynamic> including an 'ONLINE' field:
  /// - 'ONLINE': true if data was fetched successfully from the network.
  /// - 'ONLINE': false if an error occurred during network fetch (implies offline or network issue).
  Future<Map<String, dynamic>> fetchBankdaten(int webloginId) async {
    try {
      final dynamic responseData =
          await _httpClient.get('BankdatenMyBSSB/$webloginId');

      final mappedResponse = _mapBankdatenResponse(responseData);

      // If the response is not empty, and we successfully mapped it,
      // it means we were online and got data.
      if (mappedResponse.isNotEmpty) {
        LoggerService.logInfo('Successfully fetched Bankdaten from network.');
        return {...mappedResponse, 'ONLINE': true}; // Add ONLINE: true
      } else {
        // If responseData was empty or couldn't be mapped, consider it offline for this specific data.
        LoggerService.logWarning(
          'Bankdaten response was empty or unmappable. Returning offline data.',
        );
        return {
          'ONLINE': true,
        }; // Return with ONLINE: true if data is empty/unmappable. Because the user is online
      }
    } catch (e) {
      LoggerService.logError(
        'Error fetching Bankdaten: $e. Returning offline data.',
      );
      // If any error occurs during the network request, assume offline status
      return {'ONLINE': false}; // Return with ONLINE: false
    }
  }

  /// Maps the dynamic API response for bank data into a consistent Map<String, dynamic> format.
  Map<String, dynamic> _mapBankdatenResponse(dynamic response) {
    if (response is List) {
      if (response.isNotEmpty) {
        if (response.first is Map<String, dynamic>) {
          final Map<String, dynamic> data =
              response.first as Map<String, dynamic>;
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
          LoggerService.logWarning(
            'Bankdaten response list contains non-map element: ${response.first.runtimeType}',
          );
          return {};
        }
      } else {
        LoggerService.logWarning('Bankdaten response is an empty list.');
        return {};
      }
    } else if (response is Map<String, dynamic>) {
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
    LoggerService.logWarning(
      'Bankdaten response is neither a List nor a Map: ${response.runtimeType}',
    );
    return {};
  }

  /// Registers new bank data.
  /// Assumes _httpClient.post directly returns the JSON-decoded data (Map<String, dynamic>).
  Future<Map<String, dynamic>> registerBankdaten(
    int webloginId,
    String kontoinhaber,
    String iban,
    String bic,
  ) async {
    try {
      final dynamic decodedResponse =
          await _httpClient.post('BankdatenMyBSSB', {
        'WebloginID': webloginId,
        'Kontoinhaber': kontoinhaber,
        'Bankname': '',
        'IBAN': iban,
        'BIC': bic,
        'MandatNr': '',
        'MandatSeq': 2,
      });

      if (decodedResponse is Map<String, dynamic>) {
        if (decodedResponse.isNotEmpty &&
            decodedResponse.containsKey('BankdatenWebID')) {
          LoggerService.logInfo(
            'Successfully registered bankdaten. Response: ${jsonEncode(decodedResponse)}',
          );
          return decodedResponse;
        } else {
          LoggerService.logWarning(
            'registerBankdaten: API returned a map, but not with expected success structure: $decodedResponse',
          );
          return {};
        }
      } else {
        LoggerService.logWarning(
          'registerBankdaten: Expected a Map response, but received: ${decodedResponse.runtimeType} -> $decodedResponse',
        );
        return {};
      }
    } catch (e) {
      LoggerService.logError('Error while registering bankdaten: $e');
      return {};
    }
  }

  Future<bool> deleteBankdaten(int webloginID) async {
    LoggerService.logInfo(
      'Attempting to delete Bankdaten with ID: $webloginID',
    );
    try {
      final response = await _httpClient.delete(
        'BankdatenMyBSSB/$webloginID',
        body: {},
      );

      LoggerService.logInfo(
        'Successfully deleted Bankdaten. Response: $response',
      );
      return true;
    } catch (e) {
      LoggerService.logError(
        'Error while deleting Bankdaten $webloginID: $e',
      );
      return false;
    }
  }

  // --- Static validation methods ---

  static bool validateIBAN(String? iban) {
    if (iban == null || iban.trim().isEmpty) {
      return false;
    }
    final String cleanIban = iban.replaceAll(' ', '').toUpperCase();
    if (cleanIban.length < 15 || cleanIban.length > 34) {
      return false;
    }
    final String rearrangedIban =
        cleanIban.substring(4) + cleanIban.substring(0, 4);
    final StringBuffer numericIbanBuffer = StringBuffer();
    for (int i = 0; i < rearrangedIban.length; i++) {
      final String char = rearrangedIban[i];
      if (char.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
          char.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) {
        numericIbanBuffer.write(char.codeUnitAt(0) - 'A'.codeUnitAt(0) + 10);
      } else {
        numericIbanBuffer.write(char);
      }
    }
    final String numericIban = numericIbanBuffer.toString();
    BigInt? ibanInt;
    try {
      ibanInt = BigInt.parse(numericIban);
    } catch (e) {
      return false;
    }
    return ibanInt % BigInt.from(97) == BigInt.from(1);
  }

  static String? validateBIC(String? bic) {
    if (bic == null || bic.trim().isEmpty) {
      return 'BIC muss 8 oder 11 Zeichen lang sein';
    }
    final String cleanBic = bic.trim().toUpperCase();
    if (cleanBic.length != 8 && cleanBic.length != 11) {
      return 'BIC muss 8 oder 11 Zeichen lang sein';
    }
    if (!RegExp(r'^[A-Z]{6}').hasMatch(cleanBic.substring(0, 6))) {
      return 'Ungültiger BIC (Bank- und Länderkennung)';
    }
    if (!RegExp(r'^[A-Z0-9]{2}').hasMatch(cleanBic.substring(6, 8))) {
      return 'Ungültiger BIC (Ortscode)';
    }
    if (cleanBic.length == 11 &&
        !RegExp(r'^[A-Z0-9]{3}$').hasMatch(cleanBic.substring(8, 11))) {
      return 'Ungültiger BIC (Filialcode)';
    }
    return null; // BIC is valid
  }
}
