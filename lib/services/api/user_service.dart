import 'dart:async';
import 'dart:developer';

import '/services/cache_service.dart';
import '/services/http_client.dart';
import '/services/network_service.dart';
import '/services/logger_service.dart';

class UserService {
  UserService({
    required HttpClient httpClient,
    required CacheService cacheService,
    required NetworkService networkService,
  })  : _httpClient = httpClient,
        _cacheService = cacheService,
        _networkService = networkService;

  final HttpClient _httpClient;
  final CacheService _cacheService;
  final NetworkService _networkService;

  Future<Map<String, dynamic>> fetchPassdaten(int personId) async {
    final result =
        await _cacheService.cacheAndRetrieveData<Map<String, dynamic>>(
      'passdaten_$personId',
      _networkService.getCacheExpirationDuration(),
      () async {
        final response = await _httpClient.get('Passdaten/$personId');
        final mappedResponse = _mapPassdatenResponse(response);
        return mappedResponse; // Return the mapped response
      },
      (cachedResponse) {
        // Check the type of cachedResponse. If it's already a map, return it directly.
        if (cachedResponse is Map<String, dynamic>) {
          return cachedResponse;
        }
        // If it is not a map, map it.
        return _mapPassdatenResponse(cachedResponse);
      },
    );
    // Debug log to inspect the structure of 'result'
    log('fetchPassdaten result: $result');
    return result;
  }

  Future<bool> updateKritischeFelderUndAdresse(
    int personId,
    String titel,
    String namen,
    String vorname,
    int geschlecht,
    String strasse,
    String plz,
    String ort,
  ) async {
    try {
      final Map<String, dynamic> body = {
        'PersonID': personId,
        'Titel': titel,
        'Namen': namen,
        'Vorname': vorname,
        'Geschlecht': geschlecht,
        'Strasse': strasse,
        'PLZ': plz,
        'Ort': ort, // Kontakt must be empty  for deletion.
      };

      LoggerService.logInfo('Attempting to delete contact with body: $body');

      final Map<String, dynamic> response = await _httpClient.put(
        'KritischeFelderUndAdresse',
        body,
      );

      LoggerService.logInfo(
        'KritischeFelderUndAdresse (UPDATE) API response: $response',
      );

      // Check the 'result' field in the response
      if (response['result'] == true) {
        LoggerService.logInfo(
          'KritischeFelderUndAdresse UPDATED successfully for PersonID: $personId',
        );
        return true;
      } else {
        LoggerService.logWarning(
          'KritischeFelderUndAdresse: API indicated failure or unexpected response. Response: $response',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error updating KritischeFelderUndAdresse: $e');
      return false; // Return false on any error during the API call
    }
  }

  // This function is crucial for ensuring the correct data structure
  Map<String, dynamic> _mapPassdatenResponse(dynamic response) {
    // Handle different response types (List or Map) for robustness
    if (response is List) {
      if (response.isNotEmpty) {
        final Map<String, dynamic> data =
            response.first as Map<String, dynamic>; // Extract the first element
        // Map the fields to the desired structure, including ONLINE
        return {
          'PASSNUMMER': data['PASSNUMMER'],
          'VEREINNR': data['VEREINNR'],
          'NAMEN': data['NAMEN'],
          'VORNAME': data['VORNAME'],
          'TITEL': data['TITEL'],
          'GEBURTSDATUM': data['GEBURTSDATUM'],
          'GESCHLECHT': data['GESCHLECHT'],
          'VEREINNAME': data['VEREINNAME'],
          'PASSDATENID': data['PASSDATENID'],
          'MITGLIEDSCHAFTID': data['MITGLIEDSCHAFTID'],
          'PERSONID': data['PERSONID'],
          'STRASSE': data['STRASSE'],
          'PLZ': data['PLZ'],
          'ORT': data['ORT'],
          'ONLINE':
              data['ONLINE'] ?? false, // Default to false if ONLINE is missing
        };
      } else {
        return {}; // Return empty map for empty list
      }
    } else if (response is Map<String, dynamic>) {
      //if the response is already a map, return it.
      return {
        'PASSNUMMER': response['PASSNUMMER'],
        'VEREINNR': response['VEREINNR'],
        'NAMEN': response['NAMEN'],
        'VORNAME': response['VORNAME'],
        'TITEL': response['TITEL'],
        'GEBURTSDATUM': response['GEBURTSDATUM'],
        'GESCHLECHT': response['GESCHLECHT'],
        'VEREINNAME': response['VEREINNAME'],
        'PASSDATENID': response['PASSDATENID'],
        'MITGLIEDSCHAFTID': response['MITGLIEDSCHAFTID'],
        'PERSONID': response['PERSONID'],
        'STRASSE': response['STRASSE'],
        'PLZ': response['PLZ'],
        'ORT': response['ORT'],
        'ONLINE': response['ONLINE'] ??
            false, // Default to false if ONLINE is missing
      };
    }
    return {}; // Return empty map for other cases
  }

  Future<List<dynamic>> fetchZweitmitgliedschaften(int personId) async {
    final dynamic result =
        await _cacheService.cacheAndRetrieveData<List<dynamic>>(
      'zweitmitgliedschaften_$personId',
      _networkService.getCacheExpirationDuration(),
      () async => await _httpClient.get('Zweitmitgliedschaften/$personId'),
      (response) => _mapZweitmitgliedschaftenResponse(response),
    );
    final List<dynamic> zweitmitgliedschaften =
        result is List<dynamic> ? result : [];
    final bool isOnline = zweitmitgliedschaften.isNotEmpty
        ? zweitmitgliedschaften.first['ONLINE'] as bool? ?? false
        : false;

    return zweitmitgliedschaften.map((mitgliedschaft) {
      return {...mitgliedschaft, 'ONLINE': isOnline};
    }).toList();
  }

  List<dynamic> _mapZweitmitgliedschaftenResponse(dynamic response) {
    if (response is List) {
      return response.map((item) {
        return {
          'VEREINID': item['VEREINID'],
          'VEREINNAME': item['VEREINNAME'],
          'EINTRITTVEREIN': item['EINTRITTVEREIN'],
          'ONLINE':
              item['ONLINE'] ?? false, // Default to false if ONLINE is missing
        };
      }).toList();
    }
    return [];
  }

  Future<List<dynamic>> fetchPassdatenZVE(int passdatenId, int personId) async {
    final dynamic result =
        await _cacheService.cacheAndRetrieveData<List<dynamic>>(
      'passdaten_zve_$passdatenId',
      _networkService.getCacheExpirationDuration(),
      () async => await _httpClient.get('PassdatenZVE/$passdatenId/$personId'),
      (response) => _mapPassdatenZVEResponse(response),
    );
    final List<dynamic> passdatenZVE = result is List<dynamic> ? result : [];
    final bool isOnline = passdatenZVE.isNotEmpty
        ? passdatenZVE.first['ONLINE'] as bool? ?? false
        : false;

    return passdatenZVE.map((zveData) {
      return {...zveData, 'ONLINE': isOnline};
    }).toList();
  }

  List<dynamic> _mapPassdatenZVEResponse(dynamic response) {
    if (response is List) {
      return response.map((item) {
        return {
          'DISZIPLINNR': item['DISZIPLINNR'],
          'DISZIPLIN': item['DISZIPLIN'],
          'VEREINNAME': item['VEREINNAME'],
          'ONLINE':
              item['ONLINE'] ?? false, // Default to false if ONLINE is missing
        };
      }).toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchKontakte(int personId) async {
    try {
      final dynamic response = await _httpClient.get('Kontakte/$personId');

      if (response is List) {
        final List<Map<String, dynamic>> mappedContacts =
            _mapKontakteResponse(response);
        return mappedContacts;
      } else {
        LoggerService.logWarning(
          'fetchKontakte: API response was not a List: ${response.runtimeType}',
        );
        return [];
      }
    } catch (e) {
      LoggerService.logError('Error fetching Kontakte: $e');
      return [];
    }
  }

  /// Groups raw contact items into 'Privat' and 'Geschäftlich' lists.
  /// IMPORTANT: This now correctly includes 'kontaktId' and 'rawKontaktTyp' in each contact entry.
  List<Map<String, dynamic>> _mapKontakteResponse(dynamic response) {
    if (response is! List) {
      LoggerService.logWarning(
        '_mapKontakteResponse received non-list: ${response.runtimeType}',
      );
      return [];
    }

    final List<Map<String, dynamic>> privateContacts = [];
    final List<Map<String, dynamic>> businessContacts = [];

    const Map<int, String> contactTypeLabels = {
      1: 'Telefonnummer Privat',
      2: 'Mobilnummer Privat',
      3: 'Fax Privat',
      4: 'E-Mail Privat',
      5: 'Telefonnummer Geschäftlich',
      6: 'Mobilnummer Geschäftlich',
      7: 'Fax Geschäftlich',
      8: 'E-Mail Geschäftlich',
    };

    for (var item in response) {
      if (item is Map<String, dynamic>) {
        int? kontaktTyp = item['KONTAKTTYP'];
        int? kontaktId =
            item['KONTAKTID']; // <--- ENSURE YOU EXTRACT KONTAKTID HERE
        String? kontaktValue = item['KONTAKT'];

        // Add null checks for kontaktTyp, kontaktValue, AND kontaktId
        if (kontaktTyp != null &&
            kontaktValue != null &&
            kontaktValue.isNotEmpty &&
            kontaktId != null) {
          final String label = contactTypeLabels[kontaktTyp] ??
              'Unbekannter Kontakt ($kontaktTyp)';
          final Map<String, dynamic> contactEntry = {
            'type': label,
            'value': kontaktValue,
            'kontaktId': kontaktId, // <--- ADD KONTAKTID TO THE MAP
            'rawKontaktTyp': kontaktTyp, // <--- ADD raw KONTAKTTYP TO THE MAP
          };

          if (kontaktTyp >= 1 && kontaktTyp <= 4) {
            privateContacts.add(contactEntry);
          } else if (kontaktTyp >= 5 && kontaktTyp <= 8) {
            businessContacts.add(contactEntry);
          } else {
            LoggerService.logWarning(
              'Unknown KONTAKTTYP: $kontaktTyp for contact: $kontaktValue',
            );
          }
        } else {
          // Log if any critical piece of data is missing from an API item
          LoggerService.logWarning(
            'Skipping contact due to missing data (KONTAKTTYP, KONTAKT, or KONTAKTID): $item',
          );
        }
      } else {
        LoggerService.logWarning(
          'Contact list contains non-map item: ${item.runtimeType}',
        );
      }
    }

    return [
      {'category': 'Privat', 'contacts': privateContacts},
      {'category': 'Geschäftlich', 'contacts': businessContacts},
    ];
  }

  Future<bool> addKontakt(int personId, int kontaktTyp, String kontakt) async {
    try {
      final Map<String, dynamic> body = {
        'PersonID': personId,
        'KontaktTyp': kontaktTyp,
        'Kontakt': kontakt,
      };

      LoggerService.logInfo('Attempting to add contact with body: $body');

      final Map<String, dynamic> response = await _httpClient.post(
        'KontaktHinzufuegen',
        body,
      );

      LoggerService.logInfo('addKontakt API response: $response');

      // Check the 'result' field in the response
      if (response['result'] == true) {
        LoggerService.logInfo(
          'Contact added successfully for PersonID: $personId',
        );
        return true;
      } else {
        LoggerService.logWarning(
          'addKontakt: API indicated failure or unexpected response. Response: $response',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error adding contact: $e');
      return false; // Return false on any error during the API call
    }
  }

  Future<bool> deleteKontakt(
    int personId,
    int kontaktId,
    int kontaktTyp,
  ) async {
    try {
      final Map<String, dynamic> body = {
        'PersonID': personId,
        'KontaktID': kontaktId,
        'KontaktTyp': kontaktTyp,
        'Kontakt': '', // Kontakt must be empty  for deletion.
      };

      LoggerService.logInfo('Attempting to delete contact with body: $body');

      final Map<String, dynamic> response = await _httpClient.put(
        'KontaktAendern',
        body,
      );

      LoggerService.logInfo('KontaktAendern (DELETE) API response: $response');

      // Check the 'result' field in the response
      if (response['result'] == true) {
        LoggerService.logInfo(
          'Contact deleted successfully for PersonID: $personId',
        );
        return true;
      } else {
        LoggerService.logWarning(
          'deleteKontakt: API indicated failure or unexpected response. Response: $response',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error adding contact: $e');
      return false; // Return false on any error during the API call
    }
  }
}
