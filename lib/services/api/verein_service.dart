import 'dart:async';
import '../core/http_client.dart';
import '../core/logger_service.dart';

class VereinService {
  VereinService({
    required HttpClient httpClient,
  }) : _httpClient = httpClient;

  final HttpClient _httpClient;

  /// Fetches a list of Vereine (clubs/associations).
  /// This method retrieves data from the '/Vereine' endpoint.
  Future<List<Map<String, dynamic>>> fetchVereine() async {
    try {
      final response = await _httpClient.get('Vereine');
      return _mapVereineResponse(response);
    } catch (e) {
      LoggerService.logError('Error fetching Vereine: $e');
      return []; // Return an empty list on error
    }
  }

  /// Maps the dynamic API response for Vereine into a consistent List<Map<String, dynamic>> format.
  List<Map<String, dynamic>> _mapVereineResponse(dynamic response) {
    if (response is List) {
      return response.map((item) {
        final Map<String, dynamic> typedItem =
            Map<String, dynamic>.from(item as Map);
        return {
          'VEREINID': typedItem['VEREINID'],
          'GAUID': typedItem['GAUID'],
          'GAUNR': typedItem['GAUNR'],
          'VEREINNR': typedItem['VEREINNR'],
          'VEREINNAME': typedItem['VEREINNAME'],
          'LAT': typedItem['LAT'],
          'LON': typedItem['LON'],
          'GEOCODEQUELLE': typedItem['GEOCODEQUELLE'],
        };
      }).toList();
    }
    LoggerService.logWarning(
      'Vereine response is not a List: ${response.runtimeType}',
    );
    return [];
  }

  /// Fetches details for a single Verein based on its Vereinsnummer.
  /// This method retrieves data from the '/Verein/{vereinsNr}' endpoint.
  Future<List<Map<String, dynamic>>> fetchVerein(int vereinsNr) async {
    try {
      final response = await _httpClient.get('Verein/$vereinsNr');
      return _mapVereinResponse(response);
    } catch (e) {
      LoggerService.logError(
        'Error fetching Verein with number $vereinsNr: $e',
      );
      return []; // Return an empty list on error
    }
  }

  /// Maps the dynamic API response for a single Verein into a consistent List<Map<String, dynamic>> format.
  /// Even though the API returns a list with one item, this method handles it gracefully.
  List<Map<String, dynamic>> _mapVereinResponse(dynamic response) {
    if (response is List && response.isNotEmpty) {
      return response.map((item) {
        final Map<String, dynamic> typedItem =
            Map<String, dynamic>.from(item as Map);
        return {
          'VEREINID': typedItem['VEREINID'],
          'VEREINNR': typedItem['VEREINNR'],
          'VEREINNAME': typedItem['VEREINNAME'],
          'STRASSE': typedItem['STRASSE'],
          'PLZ': typedItem['PLZ'],
          'ORT': typedItem['ORT'],
          'TELEFON': typedItem['TELEFON'],
          'EMAIL': typedItem['EMAIL'],
          'HOMEPAGE': typedItem['HOMEPAGE'],
          'OEFFNUNGSZEITEN': typedItem['OEFFNUNGSZEITEN'],
          'NAMEN': typedItem['NAMEN'],
          'VORNAME': typedItem['VORNAME'],
          'P_STRASSE': typedItem['P_STRASSE'],
          'P_PLZ': typedItem['P_PLZ'],
          'P_ORT': typedItem['P_ORT'],
          'P_EMAIL': typedItem['P_EMAIL'],
          'GAUID': typedItem['GAUID'],
          'GAUNR': typedItem['GAUNR'],
          'GAUNAME': typedItem['GAUNAME'],
          'BEZIRKID': typedItem['BEZIRKID'],
          'BEZIRKNR': typedItem['BEZIRKNR'],
          'BEZIRKNAME': typedItem['BEZIRKNAME'],
          'LAT': typedItem['LAT'],
          'LON': typedItem['LON'],
          'GEOCODEQUELLE': typedItem['GEOCODEQUELLE'],
          'FACEBOOK': typedItem['FACEBOOK'],
          'INSTAGRAM': typedItem['INSTAGRAM'],
          'XTWITTER': typedItem['XTWITTER'],
          'TIKTOK': typedItem['TIKTOK'],
          'TWITCH': typedItem['TWITCH'],
          'ANZAHLMITGLIEDER': typedItem['ANZAHLMITGLIEDER'],
        };
      }).toList();
    }
    LoggerService.logWarning(
      'Verein response is not a List or is empty: ${response.runtimeType}',
    );
    return [];
  }
}
