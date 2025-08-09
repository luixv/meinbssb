import 'dart:async';

import '/services/core/cache_service.dart';
import '/services/core/http_client.dart';
import '/services/core/network_service.dart';
import '/services/core/logger_service.dart';
import '/services/core/config_service.dart';
import 'package:meinbssb/models/passdaten_akzept_or_aktiv.dart';
import 'package:meinbssb/models/contact.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/pass_data_zve.dart';
import 'package:meinbssb/models/zweitmitgliedschaft_data.dart';
import 'package:meinbssb/models/person.dart';

class UserService {
  UserService({
    required HttpClient httpClient,
    required CacheService cacheService,
    required NetworkService networkService,
    required ConfigService configService,
  })  : _httpClient = httpClient,
        _cacheService = cacheService,
        _networkService = networkService,
        _configService = configService;

  /// Fetches the accepted or active pass data for a given personId (int).
  Future<PassdatenAkzeptOrAktiv?> fetchPassdatenAkzeptierterOderAktiverPass(
    int personId,
  ) async {
    try {
      String personIdStr = personId.toString();

      String endpoint = 'PassdatenAkzeptierterOderAktiverPass/$personIdStr';

      final baseUrl =
          ConfigService.buildBaseUrlForServer(_configService, name: 'api1Base');

      final response =
          await _httpClient.get(endpoint, overrideBaseUrl: baseUrl);

      if (response == null || (response is Map && response.isEmpty)) {
        return null;
      }
      // If response is a list, take the first element
      final data =
          response is List && response.isNotEmpty ? response.first : response;
      if (data is Map<String, dynamic>) {
        return PassdatenAkzeptOrAktiv.fromJson(data);
      }
      return null;
    } catch (e) {
      LoggerService.logError(
        'Error fetching PassdatenAkzeptierterOderAktiverPass: $e',
      );
      return null;
    }
  }

  final HttpClient _httpClient;
  final CacheService _cacheService;
  final NetworkService _networkService;
  final ConfigService _configService;

  // In-memory cache to prevent multiple simultaneous calls
  final Map<int, Future<UserData?>> _pendingRequests = {};

  Future<UserData?> fetchPassdaten(int personId) async {
    // Check if there's already a pending request for this personId
    if (_pendingRequests.containsKey(personId)) {
      return await _pendingRequests[personId]!;
    }

    // Create a new request
    final request = _fetchPassdatenInternal(personId);
    _pendingRequests[personId] = request;

    try {
      final result = await request;
      return result;
    } finally {
      // Remove the request from pending requests
      _pendingRequests.remove(personId);
    }
  }

  Future<UserData?> _fetchPassdatenInternal(int personId) async {
    try {
      final Map<String, dynamic> result =
          await _cacheService.cacheAndRetrieveData<Map<String, dynamic>>(
        'passdaten_$personId',
        _networkService.getCacheExpirationDuration(),
        () async {
          // This is the fetchData function that CacheService will call if data is not in cache.
          final response = await _httpClient.get('Passdaten/$personId');
          return _mapPassdatenResponse(response);
        },
        (dynamic rawResponse) {
          // This is the processResponse function for CacheService to process cached data.
          // For cached data, we can assume it's already in the correct format
          if (rawResponse is Map<String, dynamic>) {
            return rawResponse;
          }
          // Fallback to processing if needed
          return _mapPassdatenResponse(rawResponse);
        },
      );

      if (result.isEmpty) {
        return null;
      }

      return UserData.fromJson(result);
    } catch (e) {
      LoggerService.logError('Error fetching Passdaten: $e');
      return null;
    }
  }

  Future<bool> updateKritischeFelderUndAdresse(UserData userData) async {
    try {
      final Map<String, dynamic> body = {
        'PersonID': userData.personId,
        'Titel': userData.titel,
        'Namen': userData.namen,
        'Vorname': userData.vorname,
        'Geschlecht': userData.geschlecht,
        'Strasse': userData.strasse,
        'PLZ': userData.plz,
        'Ort': userData.ort,
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
          'KritischeFelderUndAdresse UPDATED successfully for PersonID: ${userData.personId}',
        );
        // Clear the passdaten cache after successful update
        await clearPassdatenCache(userData.personId);
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

  /// Clears the cache for a specific person's passdaten
  Future<void> clearPassdatenCache(int personId) async {
    try {
      final cacheKey = 'passdaten_$personId';
      await _cacheService.remove(cacheKey);
      LoggerService.logInfo('Cleared passdaten cache for personId: $personId');
    } catch (e) {
      LoggerService.logError('Error clearing passdaten cache: $e');
    }
  }

  /// Clears all passdaten caches
  Future<void> clearAllPassdatenCache() async {
    try {
      await _cacheService.clearPattern('passdaten_');
      LoggerService.logInfo('Cleared all passdaten cache entries');
    } catch (e) {
      LoggerService.logError('Error clearing all passdaten cache: $e');
    }
  }

  // Optimized function for processing Passdaten response
  Map<String, dynamic> _mapPassdatenResponse(dynamic response) {
    Map<String, dynamic> dataToProcess = {};

    // Handle different response formats
    if (response is List && response.isNotEmpty) {
      if (response.first is Map<String, dynamic>) {
        dataToProcess = response.first as Map<String, dynamic>;
      } else {
        LoggerService.logWarning(
          'Passdaten response list element is not a map: ${response.first.runtimeType}',
        );
        return {};
      }
    } else if (response is Map<String, dynamic>) {
      dataToProcess = response;
    } else {
      LoggerService.logInfo(
        'Passdaten response is empty or unexpected type: ${response.runtimeType}',
      );
      return {};
    }

    if (dataToProcess.isEmpty) {
      return {};
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return {
      'PASSNUMMER': dataToProcess['PASSNUMMER']?.toString() ?? '',
      'VEREINNR': parseInt(dataToProcess['VEREINNR']),
      'NAMEN': dataToProcess['NAMEN']?.toString() ?? '',
      'VORNAME': dataToProcess['VORNAME']?.toString() ?? '',
      'TITEL': dataToProcess['TITEL']?.toString() ?? '',
      'GEBURTSDATUM': dataToProcess['GEBURTSDATUM']?.toString() ?? '',
      'GESCHLECHT': parseInt(dataToProcess['GESCHLECHT']),
      'VEREINNAME': dataToProcess['VEREINNAME']?.toString() ?? '',
      'PASSDATENID': parseInt(dataToProcess['PASSDATENID']),
      'MITGLIEDSCHAFTID': parseInt(dataToProcess['MITGLIEDSCHAFTID']),
      'PERSONID': parseInt(dataToProcess['PERSONID']),
      'STRASSE': dataToProcess['STRASSE']?.toString() ?? '',
      'PLZ': dataToProcess['PLZ']?.toString() ?? '',
      'ORT': dataToProcess['ORT']?.toString() ?? '',
      'ONLINE': dataToProcess['ONLINE'] as bool? ?? false,
    };
  }

  Future<List<ZweitmitgliedschaftData>> fetchZweitmitgliedschaften(
    int personId,
  ) async {
    try {
      final List<dynamic> result =
          await _cacheService.cacheAndRetrieveData<List<dynamic>>(
        'zweitmitgliedschaften_$personId',
        _networkService.getCacheExpirationDuration(),
        () async => await _httpClient.get('Zweitmitgliedschaften/$personId'),
        (dynamic rawResponse) => _mapZweitmitgliedschaftenResponse(rawResponse),
      );
      return result
          .map((json) => ZweitmitgliedschaftData.fromJson(json))
          .toList();
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
                'VEREINNR': item['VEREINNR'],
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

  Future<List<PassDataZVE>> fetchPassdatenZVE(
    int passdatenId,
    int personId,
  ) async {
    try {
      final List<dynamic> result =
          await _cacheService.cacheAndRetrieveData<List<dynamic>>(
        'passdaten_zve_$passdatenId',
        _networkService.getCacheExpirationDuration(),
        () async =>
            await _httpClient.get('PassdatenZVE/$passdatenId/$personId'),
        (dynamic rawResponse) => _mapPassdatenZVEResponse(rawResponse),
      );
      return result.map((json) => PassDataZVE.fromJson(json)).toList();
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
                'PASSDATENZVID': item['PASSDATENZVID'],
                'ZVEREINID': item['ZVEREINID'],
                'VVEREINNR': item['VVEREINNR'],
                'DISZIPLINNR': item['DISZIPLINNR'],
                'GAUID': item['GAUID'],
                'BEZIRKID': item['BEZIRKID'],
                'DISZIAUSBLENDEN': item['DISZIAUSBLENDEN'],
                'ERSAETZENDURCHID': item['ERSAETZENDURCHID'],
                'ZVMITGLIEDSCHAFTID': item['ZVMITGLIEDSCHAFTID'],
                'VEREINNAME': item['VEREINNAME'],
                'DISZIPLIN': item['DISZIPLIN'],
                'DISZIPLINID': item['DISZIPLINID'],
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

  Future<bool> postBSSBAppPassantrag(Contact contact) async {
    try {
      LoggerService.logInfo(
        'Adding BSSBAppPassantrag for person ID: ${contact.personId}',
      );
      final baseUrl =
          ConfigService.buildBaseUrlForServer(_configService, name: 'api1Base');

      final response = await _httpClient.post(
        'BSSBAppPassantrag',
        {
          'PersonID': contact.personId,
          'KontaktTyp': contact.type,
          'Kontakt': contact.value,
        },
        overrideBaseUrl: baseUrl,
      );

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

  Future<List<Person>> fetchAdresseVonPersonID(int personId) async {
    try {
      final response = await _httpClient.get('AdresseVonPersonID/$personId');
      List<dynamic> dataList;
      if (response is List) {
        dataList = response;
      } else if (response is Map<String, dynamic>) {
        dataList = [response];
      } else {
        LoggerService.logWarning(
          'Unexpected response type for AdresseVonPersonID: ${response.runtimeType}',
        );
        return [];
      }
      return dataList
          .map((json) => Person.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggerService.logError('Error fetching AdresseVonPersonID: $e');
      return [];
    }
  }
}
