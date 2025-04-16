// Project: Mein BSSB
// Filename: api_service.dart
// Author: Luis Mandel / NTT DATA

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../utils/error_handler.dart';
import 'base_service.dart';
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

class ApiService extends BaseService {
  ApiService({
    required HttpClient httpClient,
    required ImageService imageService,
    required CacheService cacheService,
    required NetworkService networkService,
  }) : _imageService = imageService,
       _networkService = networkService,
       super(httpClient: httpClient, cacheService: cacheService);

  final ImageService _imageService;
  final NetworkService _networkService;
  final _secureStorage = const FlutterSecureStorage();

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
    return ErrorHandler.handleAsyncError(() async {
      final response = await handleResponse<Map<String, dynamic>>(
        request: () => httpClient.post('RegisterMyBSSB', {
          'firstName': firstName,
          'lastName': lastName,
          'passNumber': passNumber,
          'email': email,
          'birthDate': birthDate,
          'zipCode': zipCode,
        }),
        mapper: (response) => response as Map<String, dynamic>,
      );
      return response;
    });
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    return ErrorHandler.handleAsyncError(() async {
      final response = await handleResponse<Map<String, dynamic>>(
        request: () => httpClient.post('LoginMyBSSB', {
          'email': email,
          'password': password,
        }),
        mapper: (response) => response as Map<String, dynamic>,
      );

      if (response['ResultType'] == 1) {
        await _handleSuccessfulLogin(email, password, response['PersonID']);
      } else {
        LoggerService.logError('Login failed: ${response['ResultMessage']}');
      }

      return response;
    });
  }

  Future<void> _handleSuccessfulLogin(
    String email,
    String password,
    int personId,
  ) async {
    await Future.wait([
      cacheService.setString('username', email),
      _secureStorage.write(key: 'password', value: password),
      cacheService.setInt('personId', personId),
      cacheService.setCacheTimestamp(),
    ]);
    LoggerService.logInfo('User data cached successfully');
  }

  Future<Map<String, dynamic>> resetPassword(String passNumber) async {
    try {
      final response = await httpClient.post('PasswordReset/$passNumber', {
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
    return ErrorHandler.handleAsyncError(() async {
      return handleResponse<Map<String, dynamic>>(
        request: () => httpClient.get('Passdaten/$personId'),
        mapper: _mapPassdatenResponse,
        cacheKey: 'passdaten_$personId',
        cacheDuration: AppConfig.cacheExpirationDuration,
      );
    });
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
    return ErrorHandler.handleAsyncError(() async {
      final cacheKey = 'schuetzenausweis_$personId';
      
      try {
        final cachedImage = await _imageService.getCachedSchuetzenausweis(
          personId,
          AppConfig.cacheExpirationDuration,
        );
        
        if (cachedImage != null) {
          LoggerService.logInfo('Using cached Schuetzenausweis');
          return _imageService.rotatedImage(cachedImage);
        }

        final imageData = await handleImageResponse(
          request: () => httpClient.getBytes('Schuetzenausweis/JPG/$personId'),
          cacheKey: cacheKey,
          cacheDuration: AppConfig.cacheExpirationDuration,
        );

        await _imageService.cacheSchuetzenausweis(
          personId,
          imageData,
          DateTime.now().millisecondsSinceEpoch,
        );
        
        return _imageService.rotatedImage(imageData);
      } catch (e) {
        LoggerService.logError('Error fetching Schuetzenausweis: $e');
        rethrow;
      }
    });
  }

  Future<List<dynamic>> fetchAngemeldeteSchulungen(
    int personId,
    String abDatum,
  ) async {
    return ErrorHandler.handleAsyncError(() async {
      return handleResponse<List<dynamic>>(
        request: () => httpClient.get('AngemeldeteSchulungen/$personId/$abDatum'),
        mapper: _mapAngemeldeteSchulungenResponse,
        cacheKey: 'schulungen_$personId',
        cacheDuration: AppConfig.cacheExpirationDuration,
      );
    });
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
    return ErrorHandler.handleAsyncError(() async {
      return handleResponse<List<dynamic>>(
        request: () => httpClient.get('Zweitmitgliedschaften/$personId'),
        mapper: _mapZweitmitgliedschaftenRemoteResponse,
        cacheKey: 'zweitmitgliedschaften_$personId',
        cacheDuration: AppConfig.cacheExpirationDuration,
      );
    });
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
    return ErrorHandler.handleAsyncError(() async {
      return handleResponse<List<dynamic>>(
        request: () => httpClient.get('PassdatenZVE/$passdatenId/$personId'),
        mapper: _mapPassdatenZVERemoteResponse,
        cacheKey: 'passdatenzve_${passdatenId}_$personId',
        cacheDuration: AppConfig.cacheExpirationDuration,
      );
    });
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
