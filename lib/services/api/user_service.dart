import 'dart:async';
import 'dart:developer';

import '/services/cache_service.dart';
import '/services/http_client.dart';
import '/services/network_service.dart';

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

  Future<List<dynamic>> fetchKontakte(int personId) async {
    final response = await _httpClient.get('Kontakte/$personId');
    final mappedResponse = _mapKontakteResponse(response);
    return mappedResponse; // Return the mapped response
  }

  List<dynamic> _mapKontakteResponse(dynamic response) {
    if (response is List) {
      return response.map((item) {
        return {
          'PERSONID': item['PERSONID'],
          'KONTAKTID': item['KONTAKTID'],
          'KONTAKTTYP': item['KONTAKTTYP'],
          'KONTAKT': item['KONTAKT'],
        };
      }).toList();
    }
    return [];
  }
}
