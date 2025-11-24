import 'dart:async';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/core/logger_service.dart';
import 'package:meinbssb/models/gewinn_data.dart';
import 'package:meinbssb/models/result_data.dart';

import 'package:meinbssb/services/core/config_service.dart';

class OktoberfestService {
  OktoberfestService({
    required HttpClient httpClient,
  }) : _httpClient = httpClient;

  final HttpClient _httpClient;

  Future<List<Result>> fetchResults({
    required String passnummer,
    required ConfigService configService,
  }) async {
    try {
      final baseUrl = ConfigService.buildBaseUrlForServer(
        configService,
        name: 'oktoberFestBase',
      );
      final endpoint = 'results/$passnummer';
      final response =
          await _httpClient.get(endpoint, overrideBaseUrl: baseUrl);
      if (response is List) {
        return response
            .map((json) => Result.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response is Map<String, dynamic>) {
        return [Result.fromJson(response)];
      } else {
        LoggerService.logWarning(
          'Unexpected response type for fetchResults: \\${response.runtimeType}',
        );
        return [];
      }
    } catch (e) {
      LoggerService.logError('Error fetching Results: $e');
      return [];
    }
  }

  Future<List<Gewinn>> fetchGewinne({
    required int jahr,
    required String passnummer,
    required ConfigService configService,
  }) async {
    try {
      final baseUrl = ConfigService.buildBaseUrlForServer(
        configService,
        name: 'oktoberFestBase',
      );
      final endpoint = 'GewinneEx/$jahr/$passnummer/1';
      final response =
          await _httpClient.get(endpoint, overrideBaseUrl: baseUrl);
      if (response is List) {
        return response
            .map((json) => Gewinn.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response is Map<String, dynamic>) {
        return [Gewinn.fromJson(response)];
      } else {
        LoggerService.logWarning(
          'Unexpected response type for fetchGewinne: \\${response.runtimeType}',
        );
        return [];
      }
    } catch (e) {
      LoggerService.logError('Error fetching Gewinne: $e');
      return [];
    }
  }

  /// Posts GewinnIDs, IBAN, and Passnummer to the GewinneAbrufen endpoint.
  /// Returns true if successful, false otherwise. Logs errors if present.
  Future<bool> gewinneAbrufen({
    required List<int> gewinnIDs,
    required String iban,
    required String passnummer,
    required ConfigService configService,
  }) async {
    try {
      final baseUrl = ConfigService.buildBaseUrlForServer(
        configService,
        name: 'oktoberFestBase',
      );
      const endpoint = 'GewinneAbrufen';
      final body = {
        'GewinnIDs': gewinnIDs,
        'IBAN': iban,
        'Passnummer': int.tryParse(passnummer) ?? passnummer,
      };
      final response =
          await _httpClient.post(endpoint, body, overrideBaseUrl: baseUrl);
      if (response is Map<String, dynamic>) {
        if (response['result'] == true) {
          return true;
        } else if (response.containsKey('Error')) {
          LoggerService.logError(
            'GewinneAbrufen error: \\${response['Error']}',
          );
          return false;
        }
      }
      LoggerService.logWarning(
        'Unexpected response for GewinneAbrufen: \\${response.runtimeType}',
      );
      return false;
    } catch (e) {
      LoggerService.logError('Error in gewinneAbrufen: $e');
      return false;
    }
  }

  Future<List<Gewinn>> fetchGewinneEx({
    required int jahr,
    required String passnummer,
    required ConfigService configService,
  }) async {
    try {
      final baseUrl = ConfigService.buildBaseUrlForServer(
        configService,
        name: 'oktoberFestBase',
      );
      final endpoint = 'GewinneEx/2025/$passnummer/3';
      final response =
          await _httpClient.get(endpoint, overrideBaseUrl: baseUrl);
      LoggerService.logWarning('fetchGewinneEx endpoint: $endpoint');
      if (response is List) {
        return response
            .map((json) => Gewinn.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response is Map<String, dynamic>) {
        return [Gewinn.fromJson(response)];
      } else {
        LoggerService.logWarning(
          'Unexpected response type for fetchGewinneEx: \\${response.runtimeType}',
        );
        return [];
      }
    } catch (e) {
      LoggerService.logError('Error fetching GewinneEx: $e');
      return [];
    }
  }

  Future<bool> gewinneAbrufenEx({
    required List<int> gewinnIDs,
    required String iban,
    required String passnummer,
    required ConfigService configService,
  }) async {
    try {
      final baseUrl = ConfigService.buildBaseUrlForServer(
        configService,
        name: 'oktoberFestBase',
      );
      const endpoint = 'GewinneAbrufenEx';
      final body = {
        'GewinnIDs': gewinnIDs,
        'IBAN': iban,
        'Passnummer': int.tryParse(passnummer) ?? passnummer,
        'GewinnTyp': 3
      };
      final response =
          await _httpClient.post(endpoint, body, overrideBaseUrl: baseUrl);
      if (response is Map<String, dynamic>) {
        if (response['result'] == true) {
          return true;
        } else if (response.containsKey('Error')) {
          LoggerService.logError(
            'GewinneAbrufen error: \\${response['Error']}',
          );
          return false;
        }
      }
      LoggerService.logWarning(
        'Unexpected response for GewinneAbrufenEx: \\${response.runtimeType}',
      );
      return false;
    } catch (e) {
      LoggerService.logError('Error in gewinneAbrufenEx: $e');
      return false;
    }
  }

}
