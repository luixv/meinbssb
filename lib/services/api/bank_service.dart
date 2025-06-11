// In lib/services/api/bank_service.dart

import '/models/bank_data.dart';
import '/services/core/http_client.dart';
import '/services/core/logger_service.dart';

/// Service for handling bank data operations.
class BankService {
  /// Creates a new instance of [BankService].
  const BankService(this._httpClient);

  final HttpClient _httpClient;

  /// Fetches bank data for a given weblogin ID.
  Future<List<BankData>> fetchBankData(int webloginId) async {
    try {
      final dynamic response =
          await _httpClient.get('BankdatenMyBSSB/$webloginId');
      if (response is List) {
        return response
            .map((item) {
              if (item is Map<String, dynamic>) {
                return BankData.fromJson(item);
              }
              LoggerService.logWarning(
                'Bank data list contains non-map item: ${item.runtimeType}',
              );
              return null;
            })
            .whereType<BankData>()
            .toList();
      }
      return [];
    } catch (e) {
      LoggerService.logError('Error fetching bank data: $e');
      return [];
    }
  }

  /// Registers new bank data.
  Future<bool> registerBankData(BankData bankData) async {
    try {
      final Map<String, dynamic> response = await _httpClient.post(
        'BankdatenMyBSSB',
        bankData.toJson(),
      );

      if (response.isNotEmpty && response.containsKey('BankdatenWebID')) {
        LoggerService.logInfo(
          'Bank data registered successfully for webloginId: ${bankData.webloginId}',
        );
        return true;
      } else {
        LoggerService.logWarning(
          'registerBankData: API indicated failure or unexpected response. Response: $response',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error registering bank data: $e');
      return false;
    }
  }

  /// Deletes bank data.
  Future<bool> deleteBankData(BankData bankData) async {
    try {
      final Map<String, dynamic> response = await _httpClient.delete(
        'BankdatenMyBSSB/${bankData.webloginId}',
        body: {},
      );

      if (response['result'] == true) {
        LoggerService.logInfo(
          'Bank data deleted successfully for webloginId: ${bankData.webloginId}',
        );
        return true;
      } else {
        LoggerService.logWarning(
          'deleteBankData: API indicated failure or unexpected response. Response: $response',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error deleting bank data: $e');
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
