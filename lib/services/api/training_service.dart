// Project: Mein BSSB
// Filename: training_service.dart
// Author: Luis Mandel / NTT DATA

import 'package:intl/intl.dart';
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

  Future<bool> unregisterFromSchulung(int personId, int schulungId) async {
    try {
      final response = await _httpClient.post('UnregisterFromSchulung', {
        'personId': personId,
        'schulungId': schulungId,
      });
      return response['ResultType'] == 1;
    } catch (e) {
      LoggerService.logError('Error unregistering from training: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchAbsolvierteSchulungen(int personId) async {
    try {
      final response = await _httpClient.get('AbsolvierteSchulungen/$personId');
      return _mapAbsolvierteSchulungen(response);
    } catch (e) {
      LoggerService.logError('Error registering for training: $e');
      rethrow;
    }
  }

  List<dynamic> _mapAbsolvierteSchulungen(dynamic response) {
    if (response is List) {
      return response.map((item) {
        // Helper function to parse and format dates
        String formatDate(String? dateString) {
          if (dateString == null || dateString.isEmpty) {
            return ''; // Return empty string for null or empty dates
          }
          try {
            // Parse the ISO 8601 string into a DateTime object
            final DateTime dateTime = DateTime.parse(dateString);
            // Format the DateTime object to DD.MM.YYYY
            return DateFormat('dd.MM.yyyy').format(dateTime);
          } catch (e) {
            // Log error if date parsing fails for some reason
            LoggerService.logError('Error parsing date "$dateString": $e');
            return dateString; // Return original string if parsing fails
          }
        }

        return {
          'AUSGESTELLTAM':
              formatDate(item['AUSGESTELLTAM']), // Format this date
          'BEZEICHNUNG': item['BEZEICHNUNG'] ?? '',
          'GUELTIGBIS': formatDate(item['GUELTIGBIS']), // Format this date
          // 'NUMMER': item['NUMMER'] ?? '',
          // 'SCHULUNGID': item['SCHULUNGID'] ?? 0,
          // 'SCHULUNGSARTID': item['SCHULUNGSARTID'] ?? 0,
          // 'FUERVERLAENGERUNGEN': item['FUERVERLAENGERUNGEN'] ?? false,
        };
      }).toList();
    }
    return [];
  }
}
