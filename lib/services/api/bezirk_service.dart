import 'dart:async';
import '/services/core/http_client.dart';
import '/services/core/logger_service.dart';
import '/models/bezirk.dart';

class BezirkService {
  BezirkService({
    required HttpClient httpClient,
  }) : _httpClient = httpClient;

  final HttpClient _httpClient;

  /// Fetches a list of Bezirke.
  /// This method retrieves data from the '/Bezirke' endpoint.
  Future<List<Bezirk>> fetchBezirke() async {
    try {
      final response = await _httpClient.get('Bezirke');
      return _mapBezirkeResponse(response);
    } catch (e) {
      LoggerService.logError('Error fetching Bezirke: $e');
      return []; // Return an empty list on error
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
  /// This method retrieves data from the '/Bezirk/{bezirksNr}' endpoint.
  Future<List<Bezirk>> fetchBezirk(int bezirksNr) async {
    try {
      final response = await _httpClient.get('Bezirk/$bezirksNr');
      return _mapBezirkResponse(response);
    } catch (e) {
      LoggerService.logError(
        'Error fetching Bezirk with number $bezirksNr: $e',
      );
      return []; // Return an empty list on error
    }
  }

  /// Maps the dynamic API response for a single Bezirk into a list of [Bezirk] objects.
  /// Even though the API returns a list with one item, this method handles it gracefully.
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
}
