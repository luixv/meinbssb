// Project: Mein BSSB
// Filename: training_service.dart
// Author: Luis Mandel / NTT DATA

import 'dart:async';
import 'package:http/http.dart' as http;

import '/services/cache_service.dart';
import '/services/http_client.dart';
import '/services/logger_service.dart';
import '/services/network_service.dart';

class TrainingService {
  TrainingService({
    required HttpClient httpClient,
    required CacheService cacheService,
    required NetworkService networkService,
  }) : _httpClient = httpClient,
       _cacheService = cacheService,
       _networkService = networkService;

  final HttpClient _httpClient;
  final CacheService _cacheService;
  final NetworkService _networkService;

  Future<List<dynamic>> fetchAngemeldeteSchulungen(
    int personId,
    String abDatum,
  ) async {
    return _cacheService.cacheAndRetrieveData<List<dynamic>>(
      'schulungen_$personId',
      _networkService.getCacheExpirationDuration(),
      () async =>
          await _httpClient.get('AngemeldeteSchulungen/$personId/$abDatum')
              as List<dynamic>,
      (response) => _mapAngemeldeteSchulungenResponse(response),
    );
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
      final response = await _httpClient.get('AvailableSchulungen');
      return _mapAvailableSchulungenResponse(response);
    } catch (e) {
      LoggerService.logError('Error fetching available trainings: $e');
      rethrow;
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
      final response = await _httpClient.post(
        'RegisterForSchulung',
        {
          'personId': personId,
          'schulungId': schulungId,
        },
      );
      return response['ResultType'] == 1;
    } catch (e) {
      LoggerService.logError('Error registering for training: $e');
      rethrow;
    }
  }
} 