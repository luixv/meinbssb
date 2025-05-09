// Project: Mein BSSB
// Filename: user_service.dart
// Author: Luis Mandel / NTT DATA

import 'dart:async';

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
      () async =>
          await _httpClient.get('Passdaten/$personId') as Map<String, dynamic>,
      (response) => _mapPassdatenResponse(response),
    );

    final passdaten = result['data'] as Map<String, dynamic>? ?? {};
    final isOnline = result['ONLINE'] as bool? ?? false;

    return {
      ...passdaten,
      'ONLINE': isOnline,
    };
  }

  Map<String, dynamic> _mapPassdatenResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
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
      };
    }
    return {};
  }

  Future<List<dynamic>> fetchZweitmitgliedschaften(int personId) async {
    final result = await _cacheService.cacheAndRetrieveData<List<dynamic>>(
      'zweitmitgliedschaften_$personId',
      _networkService.getCacheExpirationDuration(),
      () async => await _httpClient.get('Zweitmitgliedschaften/$personId')
          as List<dynamic>,
      (response) => _mapZweitmitgliedschaftenResponse(response),
    );

    final zweitmitgliedschaften = result['data'] as List<dynamic>? ?? [];
    final isOnline = result['ONLINE'] as bool? ?? false;

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
        };
      }).toList();
    }
    return [];
  }

  Future<List<dynamic>> fetchPassdatenZVE(int passdatenId, int personId) async {
    final result = await _cacheService.cacheAndRetrieveData<List<dynamic>>(
      'passdaten_zve_$passdatenId',
      _networkService.getCacheExpirationDuration(),
      () async => await _httpClient.get('PassdatenZVE/$passdatenId/$personId')
          as List<dynamic>,
      (response) => _mapPassdatenZVEResponse(response),
    );

    final passdatenZVE = result['data'] as List<dynamic>? ?? [];
    final isOnline = result['ONLINE'] as bool? ?? false;

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
        };
      }).toList();
    }
    return [];
  }
}
