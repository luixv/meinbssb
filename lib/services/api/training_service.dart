// Project: Mein BSSB
// Filename: training_service.dart
// Author: Luis Mandel / NTT DATA

import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert'; // Keep for jsonEncode in logs, but not for direct data processing

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

  Future<List<Map<String, dynamic>>> fetchAngemeldeteSchulungen(
    int personId,
    String abDatum,
  ) async {
    try {
      final List<Map<String, dynamic>> result =
          await _cacheService.cacheAndRetrieveData<List<Map<String, dynamic>>>(
        'schulungen_$personId',
        _networkService.getCacheExpirationDuration(),
        () async {
          final response =
              await _httpClient.get('AngemeldeteSchulungen/$personId/$abDatum');
          return _mapAngemeldeteSchulungenResponse(response);
        },
        _mapAngemeldeteSchulungenResponse,
      );

      LoggerService.logInfo(
        'Returning angemeldete Schulungen: ${jsonEncode(result)}',
      );

      return result;
    } catch (e) {
      LoggerService.logError('Error fetching Schulungen: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _mapAngemeldeteSchulungenResponse(
      dynamic response,) {
    if (response is List) {
      return response.map((item) {
        // Explicitly cast item to Map<String, dynamic> here
        final Map<String, dynamic> typedItem =
            Map<String, dynamic>.from(item as Map);
        return {
          'DATUM': typedItem['DATUM'],
          'BEZEICHNUNG': typedItem['BEZEICHNUNG'],
          'SCHULUNGENTEILNEHMERID': typedItem['SCHULUNGENTEILNEHMERID'] ?? 0,
        };
      }).toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchAvailableSchulungen() async {
    try {
      final List<Map<String, dynamic>> result =
          await _cacheService.cacheAndRetrieveData<List<Map<String, dynamic>>>(
        'available_schulungen',
        _networkService.getCacheExpirationDuration(),
        () async {
          final response = await _httpClient.get('AvailableSchulungen');
          return _mapAvailableSchulungenResponse(response);
        },
        _mapAvailableSchulungenResponse,
      );

      LoggerService.logInfo(
        'Returning available Schulungen: ${jsonEncode(result)}',
      );
      return result;
    } catch (e) {
      LoggerService.logError('Error fetching available Schulungen: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _mapAvailableSchulungenResponse(dynamic response) {
    if (response is List) {
      return response.map((item) {
        // Explicitly cast item to Map<String, dynamic> here
        final Map<String, dynamic> typedItem =
            Map<String, dynamic>.from(item as Map);
        return {
          'SCHULUNGID': typedItem['SCHULUNGID'],
          'BEZEICHNUNG': typedItem['BEZEICHNUNG'],
          'DATUM': typedItem['DATUM'],
          'ORT': typedItem['ORT'],
          'MAXTEILNEHMER': typedItem['MAXTEILNEHMER'],
          'TEILNEHMER': typedItem['TEILNEHMER'],
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

  Future<bool> unregisterFromSchulung(int schulungenTeilnehmerID) async {
    LoggerService.logInfo(
      'Attempting to unregister from Schulung with ID: $schulungenTeilnehmerID',
    );
    try {
      final response = await _httpClient.delete(
        'SchulungenTeilnehmer/$schulungenTeilnehmerID',
        body: {},
      );

      LoggerService.logInfo(
        'Successfully unregistered from Schulung. Response: $response',
      );
      return true;
    } catch (e) {
      LoggerService.logError(
        'Error unregistering from Schulung $schulungenTeilnehmerID: $e',
      );
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAbsolvierteSchulungen(
      int personId,) async {
    try {
      final response = await _httpClient.get('AbsolvierteSchulungen/$personId');
      return _mapAbsolvierteSchulungen(response);
    } catch (e) {
      LoggerService.logError('Error registering for training: $e');
      rethrow;
    }
  }

  List<Map<String, dynamic>> _mapAbsolvierteSchulungen(dynamic response) {
    if (response is List) {
      return response.map((item) {
        String formatDate(String? dateString) {
          if (dateString == null || dateString.isEmpty) {
            return '';
          }
          try {
            final DateTime dateTime = DateTime.parse(dateString);
            return DateFormat('dd.MM.yyyy').format(dateTime);
          } catch (e) {
            LoggerService.logError('Error parsing date "$dateString": $e');
            return dateString;
          }
        }

        // Explicitly cast item to Map<String, dynamic> here
        final Map<String, dynamic> typedItem =
            Map<String, dynamic>.from(item as Map);
        return {
          'AUSGESTELLTAM': formatDate(typedItem['AUSGESTELLTAM']),
          'BEZEICHNUNG': typedItem['BEZEICHNUNG'] ?? '',
          'GUELTIGBIS': formatDate(typedItem['GUELTIGBIS']),
        };
      }).toList();
    }
    return [];
  }
}
