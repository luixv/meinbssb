// In lib/services/api/bank_service.dart

import 'dart:convert'; // Still needed for registerBankdaten, and potentially for other parts
import 'package:http/http.dart'
    as http; // Still good to have for http.Response type if used elsewhere
import '/services/http_client.dart'; // Assuming your HttpClient is here
import '/services/logger_service.dart';

class BankService {
  BankService({required HttpClient httpClient}) : _httpClient = httpClient;
  final HttpClient _httpClient;

  Future<Map<String, dynamic>> fetchBankdaten(int webloginId) async {
    try {
      // Assuming _httpClient.get directly returns the JSON-decoded data (List or Map)
      final dynamic responseData =
          await _httpClient.get('BankdatenMyBSSB/$webloginId');

      // Now pass the raw decoded data to your mapping function
      final mappedResponse = _mapBankdatenResponse(responseData);
      return mappedResponse;
    } catch (e) {
      LoggerService.logError('Error fetching Bankdaten: $e');
      return {}; // Return empty map on any exception
    }
  }

  // Your existing _mapBankdatenResponse method remains largely the same,
  // as it correctly handles `List` or `Map` input.
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
      // If the response is already a map, return it after mapping (if necessary)
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

  Future<Map<String, dynamic>> registerBankdaten(
    int webloginId,
    String mandatName,
    String iban,
    String bic,
  ) async {
    // This part remains the same, assuming _httpClient.post returns http.Response
    // and you handle decoding it here.
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
            LoggerService.logInfo(
              'Successfully registered bankdaten. Response: ${jsonEncode(decodedResponse)}',
            );
            return decodedResponse;
          } else {
            LoggerService.logWarning(
              'registerBankdaten: Expected a Map, but received: ${decodedResponse.runtimeType} -> $decodedResponse',
            );
            return {};
          }
        } on FormatException catch (e) {
          LoggerService.logError(
            'registerBankdaten: JSON decoding failed: $e, Body: ${response.body}',
          );
          return {};
        }
      } else {
        LoggerService.logError(
          'registerBankdaten HTTP error: Status ${response.statusCode}, Body: ${response.body}',
        );
        return {};
      }
    } catch (e) {
      LoggerService.logError('Error while registering bankdaten: $e');
      return {};
    }
  }

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
      return null;
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
    return null;
  }
}
