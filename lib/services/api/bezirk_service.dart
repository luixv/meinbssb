import 'dart:async';
import '/services/core/http_client.dart';
import '/services/core/logger_service.dart';
import '/models/bezirk.dart';
import '/services/core/cache_service.dart';
import '/services/core/network_service.dart';

class BezirkService {
  BezirkService({
    required HttpClient httpClient,
    required CacheService cacheService,
    required NetworkService networkService,
  })  : _httpClient = httpClient,
        _cacheService = cacheService,
        _networkService = networkService;

  final HttpClient _httpClient;
  final CacheService _cacheService;
  final NetworkService _networkService;

  /// Fetches a list of Bezirke (districts/regions).
  /// This method retrieves data from the '/Bezirke' endpoint from the ZMI server.
  Future<List<Bezirk>> fetchBezirke() async {
    const cacheKey = 'bezirke_all';
    final cacheDuration = _networkService.getCacheExpirationDuration();
    try {
      final response = await _cacheService.cacheAndRetrieveData(
        cacheKey,
        cacheDuration,
        () async => await _httpClient.get('Bezirke'),
        (rawResponse) => rawResponse,
      );
      final mappedResponse = _mapBezirkeResponse(response);
      return mappedResponse;
    } catch (e) {
      LoggerService.logError('Error fetching Bezirke: $e');
      return [];
    }
  }

  /// Maps the dynamic API response for Bezirke into a list of [Bezirk] objects.
  List<Bezirk> _mapBezirkeResponse(dynamic response) {
    if (response is List) {
      return response
          .map((item) {
            try {
              if (item is Map<String, dynamic>) {
                return Bezirk.fromJson(item);
              }
              LoggerService.logWarning(
                'Bezirk item is not a Map: ${item.runtimeType}',
              );
              return null;
            } catch (e) {
              LoggerService.logWarning(
                'Failed to parse Bezirk: $e. Item: $item',
              );
              return null;
            }
          })
          .whereType<Bezirk>()
          .toList();
    }
    LoggerService.logWarning(
      'Bezirke response is not a List: ${response.runtimeType}',
    );
    return [];
  }

  /// Fetches details for a single Bezirk based on its Bezirknummer.
  /// This method retrieves data from the '/Bezirk/{bezirkNr}' endpoint.
  Future<List<Bezirk>> fetchBezirk(int bezirkNr) async {
    try {
      final response = await _httpClient.get('Bezirk/$bezirkNr');
      return _mapBezirkResponse(response);
    } catch (e) {
      LoggerService.logError(
        'Error fetching Bezirk with number $bezirkNr: $e',
      );
      return [];
    }
  }

  /// Maps the dynamic API response for a single Bezirk into a list of [Bezirk] objects.
  List<Bezirk> _mapBezirkResponse(dynamic response) {
    if (response is List) {
      return response
          .map((item) {
            try {
              if (item is Map<String, dynamic>) {
                return Bezirk.fromJson(item);
              }
              LoggerService.logWarning(
                'Bezirk item is not a Map: ${item.runtimeType}',
              );
              return null;
            } catch (e) {
              LoggerService.logWarning(
                'Failed to parse Bezirk: $e. Item: $item',
              );
              return null;
            }
          })
          .whereType<Bezirk>()
          .toList();
    }
    LoggerService.logWarning(
      'Bezirk response is not a List or is empty: ${response.runtimeType}',
    );
    return [];
  }

  /// Fetches a lightweight list of Bezirke for search (only id, nr, name), with caching.
  Future<List<BezirkSearchTriple>> fetchBezirkeforSearch() async {
    const cacheKey = 'bezirke_search';
    final cacheDuration = _networkService.getCacheExpirationDuration();
    try {
      final List<Map<String, dynamic>> result =
          await _cacheService.cacheAndRetrieveData<List<Map<String, dynamic>>>(
        cacheKey,
        cacheDuration,
        () async {
          final response = await _httpClient.get('Bezirke');
          if (response is List) {
            // Only keep the fields needed for BezirkSearchTriple
            return response
                .whereType<Map<String, dynamic>>()
                .map(
                  (item) => {
                    'BEZIRKID': item['BEZIRKID'],
                    'BEZIRKNR': item['BEZIRKNR'],
                    'BEZIRKNAME': item['BEZIRKNAME'],
                  },
                )
                .toList();
          }
          return <Map<String, dynamic>>[];
        },
        (dynamic rawResponse) {
          if (rawResponse is List) {
            return rawResponse
                .whereType<Map<String, dynamic>>()
                .map(
                  (item) => {
                    'BEZIRKID': item['BEZIRKID'],
                    'BEZIRKNR': item['BEZIRKNR'],
                    'BEZIRKNAME': item['BEZIRKNAME'],
                  },
                )
                .toList();
          }
          return <Map<String, dynamic>>[];
        },
      );
      return result
          .map((item) {
            try {
              return BezirkSearchTriple.fromJson(item);
            } catch (e) {
              LoggerService.logWarning(
                'Failed to parse BezirkSearchTriple: $e. Item: $item',
              );
              return null;
            }
          })
          .whereType<BezirkSearchTriple>()
          .toList();
    } catch (e) {
      LoggerService.logError('Error fetching Bezirke for search: $e');
      return [];
    }
  }
}
