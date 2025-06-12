import 'dart:async';
import 'dart:developer'
    as dev_log; // Using dev_log to avoid conflict with `log`
// if you have a custom LoggerService.log.

import '../core/cache_service.dart';
import '../core/http_client.dart';
import '../core/network_service.dart';
import '../core/logger_service.dart';
import 'package:meinbssb/models/contact.dart';

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
    try {
      // cacheAndRetrieveData now returns the flattened map directly,
      // with 'ONLINE' flag merged into it by CacheService.
      final Map<String, dynamic> result =
          await _cacheService.cacheAndRetrieveData<Map<String, dynamic>>(
        'passdaten_$personId',
        _networkService.getCacheExpirationDuration(),
        () async {
          // This is the fetchData function that CacheService will call if data is not in cache.
          final response = await _httpClient.get('Passdaten/$personId');
          return _mapPassdatenResponse(response); // Use the robust mapper
        },
        (dynamic rawResponse) {
          // This is the processResponse function for CacheService to process cached data.
          // This will be called on data retrieved from cache or the result of fetchData.
          return _mapPassdatenResponse(rawResponse); // Use the robust mapper
        },
      );
      // Debug log to inspect the structure of 'result'
      dev_log.log('fetchPassdaten result: $result');
      return result; // 'result' already contains the mapped data and 'ONLINE' flag.
    } catch (e) {
      LoggerService.logError('Error fetching Passdaten: $e');
      return {}; // Return empty map on any error during the API call or caching
    }
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
        'Ort': ort,
      };

      LoggerService.logInfo(
        'Attempting to update KritischeFelderUndAdresse with body: $body',
      );

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
  // It handles both List (with single item) and direct Map responses.
  // It also now explicitly handles empty/invalid inputs to return an empty map.
  Map<String, dynamic> _mapPassdatenResponse(dynamic response) {
    Map<String, dynamic> dataToProcess = {}; // Initialize as an empty map

    // Case 1: Response is a List and has elements.
    // We assume the actual Passdaten is the first element.
    if (response is List && response.isNotEmpty) {
      if (response.first is Map<String, dynamic>) {
        dataToProcess = response.first as Map<String, dynamic>;
      } else {
        // Log if the first element in the list is not a map
        LoggerService.logWarning(
          'Passdaten response list element is not a map: ${response.first.runtimeType}',
        );
        // dataToProcess remains empty, which will lead to returning {} below.
      }
    }
    // Case 2: Response is already a Map.
    else if (response is Map<String, dynamic>) {
      dataToProcess = response;
    }
    // Case 3: Response is an empty list, null, or any other non-map type.
    // In this case, dataToProcess remains an empty map, so the method will correctly return {}.
    else {
      LoggerService.logInfo(
        'Passdaten response is empty or unexpected type: ${response.runtimeType}',
      );
      // dataToProcess remains empty, which will lead to returning {} below.
    }

    // IMPORTANT: If `dataToProcess` is an empty map at this point (which happens
    // if the original `response` was an empty list, null, or a non-map type),
    // then extracting values like `dataToProcess['PASSNUMMER']` would result in `null`s.
    // To prevent returning a map full of `null`s, we check if `dataToProcess` is empty.
    if (dataToProcess.isEmpty) {
      return {}; // Return an empty map directly if there's no valid data to process.
    }

    // Safely extract values from dataToProcess.
    return {
      'PASSNUMMER': dataToProcess['PASSNUMMER'],
      'VEREINNR': dataToProcess['VEREINNR'],
      'NAMEN': dataToProcess['NAMEN'],
      'VORNAME': dataToProcess['VORNAME'],
      'TITEL': dataToProcess['TITEL'],
      'GEBURTSDATUM': dataToProcess['GEBURTSDATUM'],
      'GESCHLECHT': dataToProcess['GESCHLECHT'],
      'VEREINNAME': dataToProcess['VEREINNAME'],
      'PASSDATENID': dataToProcess['PASSDATENID'],
      'MITGLIEDSCHAFTID': dataToProcess['MITGLIEDSCHAFTID'],
      'PERSONID': dataToProcess['PERSONID'],
      'STRASSE': dataToProcess['STRASSE'],
      'PLZ': dataToProcess['PLZ'],
      'ORT': dataToProcess['ORT'],
      // The 'ONLINE' key should NOT be added here. CacheService adds it.
    };
  }

  Future<List<dynamic>> fetchZweitmitgliedschaften(int personId) async {
    // The result from cacheAndRetrieveData will now directly be a List<dynamic>
    // with the 'ONLINE' flag included in each item.
    try {
      final List<dynamic> result =
          await _cacheService.cacheAndRetrieveData<List<dynamic>>(
        'zweitmitgliedschaften_$personId',
        _networkService.getCacheExpirationDuration(),
        () async => await _httpClient.get('Zweitmitgliedschaften/$personId'),
        (dynamic rawResponse) => _mapZweitmitgliedschaftenResponse(rawResponse),
      );
      // The 'ONLINE' flag is already merged into `result` by CacheService.
      return result;
    } catch (e) {
      LoggerService.logError('Error fetching Zweitmitgliedschaften: $e');
      return []; // Return empty list on error
    }
  }

  List<dynamic> _mapZweitmitgliedschaftenResponse(dynamic response) {
    if (response is List) {
      return response
          .map((item) {
            // Ensure item is a Map before accessing keys
            if (item is Map<String, dynamic>) {
              return {
                'VEREINID': item['VEREINID'],
                'VEREINNAME': item['VEREINNAME'],
                'EINTRITTVEREIN': item['EINTRITTVEREIN'],
              };
            }
            LoggerService.logWarning(
              'Zweitmitgliedschaften list contains non-map item: ${item.runtimeType}',
            );
            return {}; // Return empty map for invalid items
          })
          .where((item) => item.isNotEmpty)
          .toList(); // Filter out any empty maps
    }
    return [];
  }

  Future<List<dynamic>> fetchPassdatenZVE(int passdatenId, int personId) async {
    // The result from cacheAndRetrieveData will now directly be a List<dynamic>
    // with the 'ONLINE' flag included in each item.
    try {
      final List<dynamic> result =
          await _cacheService.cacheAndRetrieveData<List<dynamic>>(
        'passdaten_zve_$passdatenId',
        _networkService.getCacheExpirationDuration(),
        () async =>
            await _httpClient.get('PassdatenZVE/$passdatenId/$personId'),
        (dynamic rawResponse) => _mapPassdatenZVEResponse(rawResponse),
      );
      // The 'ONLINE' flag is already merged into `result` by CacheService.
      return result;
    } catch (e) {
      LoggerService.logError('Error fetching PassdatenZVE: $e');
      return []; // Return empty list on error
    }
  }

  List<dynamic> _mapPassdatenZVEResponse(dynamic response) {
    if (response is List) {
      return response
          .map((item) {
            // Ensure item is a Map before accessing keys
            if (item is Map<String, dynamic>) {
              return {
                'DISZIPLINNR': item['DISZIPLINNR'],
                'DISZIPLIN': item['DISZIPLIN'],
                'VEREINNAME': item['VEREINNAME'],
              };
            }
            LoggerService.logWarning(
              'PassdatenZVE list contains non-map item: ${item.runtimeType}',
            );
            return {}; // Return empty map for invalid items
          })
          .where((item) => item.isNotEmpty)
          .toList(); // Filter out any empty maps
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchKontakte(int personId) async {
    try {
      final data = await _httpClient.get('Kontakte/$personId');

      if (data is List) {
        // Convert to Contact objects and filter out empty values and invalid entries
        final List<Contact> contactList = data
            .map((item) {
              try {
                if (item is! Map<String, dynamic>) {
                  LoggerService.logWarning(
                    'Contact item is not a Map: ${item.runtimeType}',
                  );
                  return null;
                }

                final contact = Contact.fromJson(item);
                return contact;
              } catch (e) {
                LoggerService.logWarning(
                  'Failed to parse contact: $e. Item: $item',
                );
                return null;
              }
            })
            .where((contact) {
              final isValid = contact != null && contact.value.isNotEmpty;
              return isValid;
            })
            .cast<Contact>()
            .toList();

        // Categorize contacts
        final List<Map<String, dynamic>> categorizedContacts = [
          {
            'category': 'Privat',
            'contacts': contactList
                .where((contact) => contact.isPrivate)
                .map(
                  (contact) => {
                    'kontaktId': contact.id,
                    'type': contact.typeLabel,
                    'value': contact.value,
                    'rawKontaktTyp': contact.type,
                  },
                )
                .toList(),
          },
          {
            'category': 'Geschäftlich',
            'contacts': contactList
                .where((contact) => contact.isBusiness)
                .map(
                  (contact) => {
                    'kontaktId': contact.id,
                    'type': contact.typeLabel,
                    'value': contact.value,
                    'rawKontaktTyp': contact.type,
                  },
                )
                .toList(),
          },
        ];

        return categorizedContacts;
      } else {
        LoggerService.logError(
          'Failed to fetch contacts: Invalid response type ${data.runtimeType}',
        );
        return [];
      }
    } catch (e) {
      LoggerService.logError('Error fetching contacts: $e');
      return [];
    }
  }

  Future<bool> addKontakt(Contact contact) async {
    try {
      LoggerService.logInfo(
        'Adding contact for person ID: ${contact.personId}',
      );

      // Validate contact type
      if (!Contact.isValidType(contact.type)) {
        LoggerService.logError('Invalid contact type: ${contact.type}');
        return false;
      }

      final response = await _httpClient.post(
        'KontaktHinzufuegen',
        {
          'PersonID': contact.personId,
          'KontaktTyp': contact.type,
          'Kontakt': contact.value,
        },
      );

      LoggerService.logInfo('addKontakt API response: $response');

      // Check if response is a Map and has a 'result' field
      if (response is Map<String, dynamic> && response['result'] == true) {
        return true;
      } else {
        LoggerService.logWarning(
          'addKontakt: API indicated failure or unexpected response. Response: $response',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error adding contact: $e');
      return false;
    }
  }

  Future<bool> deleteKontakt(Contact contact) async {
    try {
      final response = await _httpClient.put(
        'KontaktAendern',
        {
          'PersonID': contact.personId,
          'KontaktID': contact.id,
          'KontaktTyp': contact.type,
          'Kontakt': '', // Empty contact value to indicate deletion
        },
      );

      if (response is Map<String, dynamic>) {
        if (response.containsKey('error') || response['result'] == false) {
          LoggerService.logError(
            'Failed to delete contact: ${response['error'] ?? 'Unknown error'}',
          );
          return false;
        }
        return response['result'] == true;
      } else {
        LoggerService.logError(
          'Invalid response type from deleteKontakt: ${response.runtimeType}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error deleting contact: $e');
      return false;
    }
  }

  Future<bool> updateKontakt(Contact contact) async {
    try {
      // Validate input
      if (contact.value.trim().isEmpty) {
        LoggerService.logError('Cannot update contact with empty value');
        return false;
      }

      final response = await _httpClient.put(
        'KontaktAendern',
        contact.toJson(),
      );

      LoggerService.logInfo('Update contact response: $response');

      if (response is Map<String, dynamic>) {
        if (response.containsKey('error') || response['result'] == false) {
          LoggerService.logError(
            'Failed to update contact: ${response['error'] ?? 'Unknown error'}',
          );
          return false;
        }
        return response['result'] == true;
      } else {
        LoggerService.logError(
          'Invalid response type from updateKontakt: ${response.runtimeType}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.logError('Error updating contact: $e');
      return false;
    }
  }
}
