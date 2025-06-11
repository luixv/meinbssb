import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import '../core/cache_service.dart';
import '../core/http_client.dart';
import '../core/logger_service.dart';
import '../core/network_service.dart';

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
    dynamic response,
  ) {
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
      final response = await _httpClient.get('AvailableSchulungen');
      return _mapAvailableSchulungenResponse(response);
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

  /// Fetches available training types.
  /// The response will include an 'ONLINE' field indicating if data was fetched from network (true) or cache (false).
  Future<List<Map<String, dynamic>>> fetchSchulungsarten() async {
    try {
      final response = await _httpClient.get('Schulungsarten/false');
      return _mapSchulungsartenResponse(response);
    } catch (e) {
      LoggerService.logError('Error fetching Schulungsarten: $e');
      // If an error occurs, return an empty list. The cache service will handle
      // adding the 'ONLINE: false' if it falls back to cached data.
      return [];
    }
  }

  /// Maps the dynamic API response for training types into a consistent List<Map<String, dynamic>> format.
  List<Map<String, dynamic>> _mapSchulungsartenResponse(dynamic response) {
    if (response is List) {
      return response.map((item) {
        final Map<String, dynamic> typedItem =
            Map<String, dynamic>.from(item as Map);
        return {
          'SCHULUNGSARTID': typedItem['SCHULUNGSARTID'],
          'BEZEICHNUNG': typedItem['BEZEICHNUNG'],
          'TYP': typedItem['TYP'],
          'KOSTEN': typedItem['KOSTEN'],
          'UE': typedItem['UE'],
          'OMKATEGORIEID': typedItem['OMKATEGORIEID'],
          'RECHNUNGAN': typedItem['RECHNUNGAN'],
          'VERPFLEGUNGSKOSTEN': typedItem['VERPFLEGUNGSKOSTEN'],
          'UEBERNACHTUNGSKOSTEN': typedItem['UEBERNACHTUNGSKOSTEN'],
          'LEHRMATERIALKOSTEN': typedItem['LEHRMATERIALKOSTEN'],
          'LEHRGANGSINHALT': typedItem['LEHRGANGSINHALT'],
          'LEHRGANGSINHALTHTML': typedItem['LEHRGANGSINHALTHTML'],
          'WEBGRUPPE': typedItem['WEBGRUPPE'],
          'FUERVERLAENGERUNGEN': typedItem['FUERVERLAENGERUNGEN'],
        };
      }).toList();
    }
    LoggerService.logWarning(
      'Schulungsarten response is not a List: ${response.runtimeType}',
    );
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

      bool responseNotNull = response != null;
      bool responseHasResult =
          response is Map && response.containsKey('result');
      bool responseIsTrue = response['result'] == true;

      bool responseDeleteCondition =
          responseNotNull && responseHasResult && responseIsTrue;

      if (responseDeleteCondition) {
        LoggerService.logInfo(
          'Successfully unregistered from Schulung. Response: $response',
        );
        return true;
      } else {
        LoggerService.logWarning(
          'Unregistration API returned unexpected result: $response',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError(
        'Error unregistering from Schulung $schulungenTeilnehmerID: $e',
      );
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAbsolvierteSchulungen(
    int personId,
  ) async {
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
