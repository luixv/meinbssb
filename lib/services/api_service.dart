// Project: Mein BSSB
// Filename: api_service.dart
// Author: Luis Mandel / NTT DATA

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '/services/cache_service.dart';
import '/services/http_client.dart';
import '/services/image_service.dart';
import '/services/logger_service.dart';
import '/services/network_service.dart';

class NetworkException implements Exception {
  NetworkException(this.message);
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class ApiService {
  ApiService({
    required HttpClient httpClient,
    required ImageService imageService,
    required CacheService cacheService,
    required NetworkService networkService,
    required String baseIp,
    required String port,
    required int serverTimeout,
  })  : _httpClient = httpClient,
        _imageService = imageService,
        _cacheService = cacheService,
        _networkService = networkService;
  final HttpClient _httpClient;
  final ImageService _imageService;
  final CacheService _cacheService;

  final NetworkService _networkService;

  Future<bool> hasInternet() => _networkService.hasInternet();

  Duration getCacheExpirationDuration() =>
      _networkService.getCacheExpirationDuration();

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String passNumber,
    required String email,
    required String birthDate,
    required String zipCode,
  }) async {
    try {
      final response = await _httpClient.post('RegisterMyBSSB', {
        'firstName': firstName,
        'lastName': lastName,
        'passNumber': passNumber,
        'email': email,
        'birthDate': birthDate,
        'zipCode': zipCode,
      });
      return response is Map<String, dynamic> ? response : {};
    } catch (e) {
      LoggerService.logError('Invalid server response.');
      return {};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    const secureStorage = FlutterSecureStorage();

    try {
      final response = await _httpClient.post('LoginMyBSSB', {
        'email': email,
        'password': password,
      });

      if (response is Map<String, dynamic>) {
        if (response['ResultType'] == 1) {
          await _cacheService.setString('username', email);
          await secureStorage.write(key: 'password', value: password);
          await _cacheService.setInt('personId', response['PersonID']);
          await _cacheService.setCacheTimestamp();
          LoggerService.logInfo('User data cached successfully.');
          return response;
        } else {
          LoggerService.logError(
            'Login failed on server: ${response['ResultMessage']}',
          );
          return response;
        }
      } else {
        LoggerService.logError('Invalid server response.');
        return {};
      }
    } on Exception catch (e) {
      if (e is http.ClientException &&
          (e.message.contains('refused') ||
              e.message.contains('failed to connect'))) {
        LoggerService.logError(
          'ClientException contains SocketException: ${e.message}',
        );

        final cachedUsername = await _cacheService.getString('username');
        final cachedPassword = await secureStorage.read(key: 'password');
        final cachedPersonId = await _cacheService.getInt('personId');
        final cachedTimestamp = await _cacheService.getInt('cacheTimestamp');
        final expirationDuration = _networkService.getCacheExpirationDuration();
        final expirationTime = DateTime.fromMillisecondsSinceEpoch(
          cachedTimestamp ?? 0,
        ).add(expirationDuration);

        final testCachedUsername = cachedUsername == email;
        final testCachedPassword = cachedPassword == password;
        final testCachedPersonId = cachedPersonId != null;
        final testCachedTimestamp = cachedTimestamp != null;
        final today = DateTime.now();
        final testExpirationDate = today.isBefore(expirationTime);

        final isCacheValid = testCachedUsername &&
            testCachedPassword &&
            testCachedPersonId &&
            testCachedTimestamp &&
            testExpirationDate;

        if (isCacheValid) {
          LoggerService.logInfo('Login from cache successful.');
          return {'ResultType': 1, 'PersonID': cachedPersonId};
        } else {
          LoggerService.logWarning('Cached data expired.');
          return {
            'ResultType': 0,
            'ResultMessage': isCacheValid
                ? 'Cached data expired. Please log in again.'
                : 'Offline-Anmeldung fehlgeschlagen: Kein Cache oder falsches Passwort.',
          };
        }
      } else {
        LoggerService.logError('Benutzername oder Passwort ist falsch: $e');
        return {
          'ResultType': 0,
          'ResultMessage': 'Benutzername oder Passwort ist falsch',
        };
      }
    }
  }

  Future<Map<String, dynamic>> resetPassword(String passNumber) async {
    try {
      final response = await _httpClient.post('PasswordReset/$passNumber', {
        'passNumber': passNumber,
      });
      return response is Map<String, dynamic> ? response : {};
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      throw NetworkException('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> fetchPassdaten(int personId) async {
    return _cacheService.cacheAndRetrieveData<Map<String, dynamic>>(
      'passdaten_$personId',
      getCacheExpirationDuration(),
      () async =>
          await _httpClient.get('Passdaten/$personId') as Map<String, dynamic>,
      (response) => _mapPassdatenResponse(response),
    );
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
      };
    }
    return {};
  }

  Future<Uint8List> fetchSchuetzenausweis(int personId) async {
    final validityDuration = getCacheExpirationDuration();

    Future<Uint8List?> getCachedSchuetzenausweis() async {
      try {
        return await _imageService.getCachedSchuetzenausweis(
          personId,
          validityDuration,
        );
      } catch (cacheError) {
        LoggerService.logError('Cache error: $cacheError');
        return null;
      }
    }

    try {
      final cachedImage = await getCachedSchuetzenausweis();
      if (cachedImage != null) {
        LoggerService.logInfo('Using cached Schuetzenausweis');
        return _imageService.rotatedImage(cachedImage);
      }

      final imageData = await _httpClient.getBytes(
        'Schuetzenausweis/JPG/$personId',
      );

      await _imageService.cacheSchuetzenausweis(
        personId,
        imageData,
        DateTime.now().millisecondsSinceEpoch,
      );
      return _imageService.rotatedImage(imageData);
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      throw NetworkException('An unexpected error occurred: $e');
    }
  }

  Future<List<dynamic>> fetchAngemeldeteSchulungen(
    int personId,
    String abDatum,
  ) async {
    return _cacheService.cacheAndRetrieveData<List<dynamic>>(
      'schulungen_$personId',
      getCacheExpirationDuration(),
      () async => await _httpClient
          .get('AngemeldeteSchulungen/$personId/$abDatum') as List<dynamic>,
      (response) => _mapAngemeldeteSchulungenResponse(response),
    );
  }

  List<dynamic> _mapAngemeldeteSchulungenResponse(dynamic response) {
    if (response is List) {
      return response.map((item) {
        return {
          'DATUM': item['DATUM'],
          'BEZEICHNUNG': item['BEZEICHNUNG'],
          'SCHULUNGENTEILNEHMERID': 0,
          'SCHULUNGENTERMINID': 0,
          'SCHULUNGSARTID': 0,
          'STATUS': 0,
          'DATUMBIS': '',
          'FUERVERLAENGERUNGEN': false,
        };
      }).toList();
    } else if (response is Map && response.containsKey('schulungen')) {
      return List.from(response['schulungen']).map((item) {
        return {
          'DATUM': item['DATUM'],
          'BEZEICHNUNG': item['BEZEICHNUNG'],
          'SCHULUNGENTEILNEHMERID': 0,
          'SCHULUNGENTERMINID': 0,
          'SCHULUNGSARTID': 0,
          'STATUS': 0,
          'DATUMBIS': '',
          'FUERVERLAENGERUNGEN': false,
        };
      }).toList();
    }
    return [];
  }

  Future<List<dynamic>> fetchZweitmitgliedschaften(int personId) async {
    return _cacheService.cacheAndRetrieveData<List<dynamic>>(
      'zweitmitgliedschaften_$personId',
      getCacheExpirationDuration(),
      () async {
        final response = await _httpClient.get(
          'Zweitmitgliedschaften/$personId',
        );
        return _mapZweitmitgliedschaftenRemoteResponse(response);
      },
      (response) => _mapZweitmitgliedschaftenCacheResponse(response),
    );
  }

  List<dynamic> _mapZweitmitgliedschaftenRemoteResponse(dynamic response) {
    if (response is List) {
      return response
          .map(
            (item) => {
              'VEREINID': item['VEREINID'],
              'VEREINNR': item['VEREINNR'],
              'VEREINNAME': item['VEREINNAME'],
              'EINTRITTVEREIN': item['EINTRITTVEREIN'],
            },
          )
          .toList();
    }
    return [];
  }

  List<dynamic> _mapZweitmitgliedschaftenCacheResponse(dynamic response) {
    return response is List ? response : [];
  }

  Future<List<dynamic>> fetchPassdatenZVE(int passdatenId, int personId) async {
    return _cacheService.cacheAndRetrieveData<List<dynamic>>(
      'passdatenzve_${passdatenId}_$personId',
      getCacheExpirationDuration(),
      () async {
        final response = await _httpClient.get(
          'PassdatenZVE/$passdatenId/$personId',
        );
        return _mapPassdatenZVERemoteResponse(response);
      },
      (response) => _mapPassdatenZVECacheResponse(response),
    );
  }

  List<dynamic> _mapPassdatenZVERemoteResponse(dynamic response) {
    if (response is List) {
      return response
          .map(
            (item) => {
              'DISZIPLINNR': item['DISZIPLINNR'],
              'VEREINNAME': item['VEREINNAME'],
              'DISZIPLIN': item['DISZIPLIN'],
              'DISZIPLINID': item['DISZIPLINID'],
            },
          )
          .toList();
    }
    return [];
  }

  List<dynamic> _mapPassdatenZVECacheResponse(dynamic response) {
    return response is List ? response : [];
  }
}
