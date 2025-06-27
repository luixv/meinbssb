import 'dart:async';
import '/services/core/http_client.dart';
import '/services/core/logger_service.dart';
import '/models/bezirk.dart';

class BezirkService {
  BezirkService({
    required HttpClient httpClient,
  }) : _httpClient = httpClient;

  final HttpClient _httpClient;

  /// Fetches a list of Bezirke (districts/regions).
  /// This method retrieves data from the '/Bezirke' endpoint from the ZMI server.
  Future<List<Bezirk>> fetchBezirke() async {
    try {
      final response = await _httpClient.get('Bezirke');
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
                'Bezirk item is not a Map: ${item.runtimeType}',
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

  /// Fetches a lightweight list of Bezirke for search (only id, nr, name).
  Future<List<BezirkSearchTriple>> fetchBezirkeforSearch() async {
    try {
      final response = await _httpClient.get('Bezirke');
      if (response is List) {
        return response
            .map((item) {
              try {
                if (item is Map<String, dynamic>) {
                  return BezirkSearchTriple.fromJson(item);
                }
                LoggerService.logWarning(
                  'BezirkSearchTriple item is not a Map: ${item.runtimeType}',
                );
                return null;
              } catch (e) {
                LoggerService.logWarning(
                  'Failed to parse BezirkSearchTriple: $e. Item: $item',
                );
                return null;
              }
            })
            .whereType<BezirkSearchTriple>()
            .toList();
      }
      LoggerService.logWarning(
        'Bezirke response is not a List: ${response.runtimeType}',
      );
      return [];
    } catch (e) {
      LoggerService.logError('Error fetching Bezirke for search: $e');
      return [];
    }
  }
}
