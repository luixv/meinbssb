import 'dart:async';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/core/logger_service.dart';
import 'package:meinbssb/models/verein_data.dart';

import 'package:meinbssb/models/fremde_verband_data.dart';

class VereinService {
  VereinService({
    required HttpClient httpClient,
  }) : _httpClient = httpClient;

  final HttpClient _httpClient;

  /// Fetches a list of Vereine (clubs/associations).
  /// This method retrieves data from the '/Vereine' endpoint.
  Future<List<Verein>> fetchVereine() async {
    try {
      const endpoint = 'Vereine';
      final response = await _httpClient.get(endpoint);
      return _mapVereineResponse(response);
    } catch (e) {
      LoggerService.logError('Error fetching Vereine: $e');
      return []; // Return an empty list on error
    }
  }

  /// Maps the dynamic API response for Vereine into a list of [Verein] objects.
  List<Verein> _mapVereineResponse(dynamic response) {
    if (response is List) {
      return response
          .map((item) {
            try {
              if (item is Map<String, dynamic>) {
                return Verein.fromJson(item);
              }
              LoggerService.logWarning(
                'Verein item is not a Map: ${item.runtimeType}',
              );
              return null;
            } catch (e) {
              LoggerService.logWarning(
                'Failed to parse Verein: $e. Item: $item',
              );
              return null;
            }
          })
          .whereType<Verein>()
          .toList();
    }
    LoggerService.logWarning(
      'Vereine response is not a List: ${response.runtimeType}',
    );
    return [];
  }

  /// Fetches details for a single Verein based on its Vereinsnummer.
  /// This method retrieves data from the '/Verein/{vereinsNr}' endpoint.
  Future<List<Verein>> fetchVerein(int vereinsNr) async {
    try {
      final endpoint = 'Verein/$vereinsNr';
      final response = await _httpClient.get(endpoint);
      return _mapVereinResponse(response);
    } catch (e) {
      LoggerService.logError(
        'Error fetching Verein with number $vereinsNr: $e',
      );
      return []; // Return an empty list on error
    }
  }

  /// Maps the dynamic API response for a single Verein into a list of [Verein] objects.
  /// Even though the API returns a list with one item, this method handles it gracefully.
  List<Verein> _mapVereinResponse(dynamic response) {
    if (response is List) {
      return response
          .map((item) {
            try {
              if (item is Map<String, dynamic>) {
                return Verein.fromJson(item);
              }
              LoggerService.logWarning(
                'Verein item is not a Map: ${item.runtimeType}',
              );
              return null;
            } catch (e) {
              LoggerService.logWarning(
                'Failed to parse Verein: $e. Item: $item',
              );
              return null;
            }
          })
          .whereType<Verein>()
          .toList();
    }
    LoggerService.logWarning(
      'Verein response is not a List or is empty: ${response.runtimeType}',
    );
    return [];
  }

  /// Fetches a list of FremdeVerbaende (external associations).
  /// This method retrieves data from the '/FremdeVerbaende' endpoint.
  Future<List<FremdeVerband>> fetchFremdeVerbaende() async {
    try {
      const endpoint = 'FremdeVerbaende';
      final response = await _httpClient.get(endpoint);
      return _mapFremdeVerbaendeResponse(response);
    } catch (e) {
      LoggerService.logError('Error fetching FremdeVerbaende: $e');
      return []; // Return an empty list on error
    }
  }

  /// Maps the dynamic API response for FremdeVerbaende into a list of [FremdeVerband] objects.
  List<FremdeVerband> _mapFremdeVerbaendeResponse(dynamic response) {
    if (response is List) {
      return response
          .map((item) {
            try {
              if (item is Map<String, dynamic>) {
                return FremdeVerband.fromJson(item);
              }
              LoggerService.logWarning(
                'FremdeVerband item is not a Map: ${item.runtimeType}',
              );
              return null;
            } catch (e) {
              LoggerService.logWarning(
                'Failed to parse FremdeVerband: $e. Item: $item',
              );
              return null;
            }
          })
          .whereType<FremdeVerband>()
          .toList();
    }
    LoggerService.logWarning(
      'FremdeVerbaende response is not a List: ${response.runtimeType}',
    );
    return [];
  }
}
