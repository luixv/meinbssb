// Project: Mein BSSB
// Filename: training_service.dart
// Author: Luis Mandel / NTT DATA

import 'dart:async';
import 'dart:convert';

import '/services/cache_service.dart';
import '/services/http_client.dart';
import '/services/logger_service.dart';
import '/services/network_service.dart';

class TrainingService {
  TrainingService({
    required HttpClient httpClient,
    required CacheService cacheService,
    required NetworkService networkService,
  })  : _httpClient = httpClient,
        _cacheService = cacheService,
        _networkService = networkService;

  final HttpClient _httpClient;
  final CacheService _cacheService;
  final NetworkService _networkService;
/*
  Future<List<dynamic>> fetchAngemeldeteSchulungen(
    int personId,
    String abDatum,
  ) async {
    final result = await _cacheService.cacheAndRetrieveData<List<dynamic>>(
      'schulungen_$personId',
      _networkService.getCacheExpirationDuration(),
      () async => await _httpClient
          .get('AngemeldeteSchulungen/$personId/$abDatum') as List<dynamic>,
      (response) => _mapAngemeldeteSchulungenResponse(response),
    );

    final schulungen = result['data'] as List<dynamic>? ?? [];
    final isOnline = result['ONLINE'] as bool? ?? false;

    return schulungen.map((schulung) {
      return {...schulung, 'ONLINE': isOnline};
    }).toList();
  }
*/

  Future<List<dynamic>> fetchAngemeldeteSchulungen(
    int personId,
    String abDatum,
  ) async {
    try {
      final result = await _cacheService.cacheAndRetrieveData<List<dynamic>>(
        'schulungen_$personId',
        _networkService.getCacheExpirationDuration(),
        () async {
          final response =
              await _httpClient.get('AngemeldeteSchulungen/$personId/$abDatum');
          return _mapAngemeldeteSchulungenResponse(response);
        },
        _mapAngemeldeteSchulungenResponse,
      );

      final responseData = (result['data'] as List<dynamic>?) ?? [];
      final isOnline = result['ONLINE'] as bool? ?? false;

      LoggerService.logInfo(
        'Returning angemeldete Schulungen (ONLINE=$isOnline): ${jsonEncode(responseData)}',
      );

      return responseData.map((schulung) {
        return {...schulung, 'ONLINE': isOnline};
      }).toList();
    } catch (e) {
      LoggerService.logError('Error fetching Schulungen: $e');
      return [];
    }
  }

  List<dynamic> _mapAngemeldeteSchulungenResponse(dynamic response) {
    if (response is List) {
      return response.map((item) {
        return {
          'DATUM': item['DATUM'],
          'BEZEICHNUNG': item['BEZEICHNUNG'],
          'SCHULUNGENTEILNEHMERID': item['SCHULUNGENTEILNEHMERID'] ?? 0,
        };
      }).toList();
    }
    return [];
  }

  Future<List<dynamic>> fetchAvailableSchulungen() async {
    try {
      final result = await _cacheService.cacheAndRetrieveData<List<dynamic>>(
        'available_schulungen',
        _networkService.getCacheExpirationDuration(),
        () async {
          final response = await _httpClient.get('AvailableSchulungen');
          return _mapAvailableSchulungenResponse(response);
        },
        _mapAvailableSchulungenResponse,
      );

      final responseData = (result['data'] as List<dynamic>?) ?? [];
      LoggerService.logInfo(
        'Returning available Schulungen: ${jsonEncode(responseData)}',
      );
      return responseData;
    } catch (e) {
      LoggerService.logError('Error fetching available Schulungen: $e');
      return [];
    }
  }

  List<dynamic> _mapAvailableSchulungenResponse(dynamic response) {
    if (response is List) {
      return response.map((item) {
        return {
          'SCHULUNGID': item['SCHULUNGID'],
          'BEZEICHNUNG': item['BEZEICHNUNG'],
          'DATUM': item['DATUM'],
          'ORT': item['ORT'],
          'MAXTEILNEHMER': item['MAXTEILNEHMER'],
          'TEILNEHMER': item['TEILNEHMER'],
        };
      }).toList();
    }
    return [];
  }

  Future<bool> registerForSchulung(int personId, int schulungId) async {
    try {
      final response = await _httpClient.post('RegisterForSchulung', {
        'personId': personId,
        'schulungId': schulungId,
      });
      return response['ResultType'] == 1;
    } catch (e) {
      LoggerService.logError('Error registering for training: $e');
      rethrow;
    }
  }
}
