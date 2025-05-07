// Filename: api_service.dart
import 'dart:async';
import 'dart:typed_data'; // Import Uint8List

import 'package:flutter/foundation.dart';
import 'package:meinbssb/services/api_service.dart' as network_ex;
import '/services/api/auth_service.dart';
import '/services/api/training_service.dart';
import '/services/api/user_service.dart';
import '/services/cache_service.dart';
import '/services/config_service.dart';
import '/services/http_client.dart';
import '/services/image_service.dart';
import '/services/network_service.dart';

class NetworkException implements Exception {
  NetworkException(this.message);
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class ApiService {
  ApiService({
    required ConfigService configService,
    required HttpClient httpClient,
    required ImageService imageService,
    required CacheService cacheService,
    required NetworkService networkService,
    required TrainingService trainingService,
    required UserService userService,
    required AuthService authService,
  })  : _httpClient = httpClient,
        _imageService = imageService,
        _networkService = networkService,
        _trainingService = trainingService,
        _userService = userService,
        _authService = authService;

  final HttpClient _httpClient;
  final ImageService _imageService;
  final NetworkService _networkService;
  final TrainingService _trainingService;
  final UserService _userService;
  final AuthService _authService;

  Future<bool> hasInternet() => _networkService.hasInternet();

  Duration getCacheExpirationDuration() =>
      _networkService.getCacheExpirationDuration();

  // Use the register method from AuthService
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String passNumber,
    required String email,
    required String birthDate,
    required String zipCode,
  }) async {
    return _authService.register(
      firstName: firstName,
      lastName: lastName,
      passNumber: passNumber,
      email: email,
      birthDate: birthDate,
      zipCode: zipCode,
    );
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _authService.login(username, password);
      return response;
    } on network_ex.NetworkException {
      return {
        'ResultType': 0,
        'ResultMessage': 'Benutzername oder Passwort ist falsch',
      };
    } catch (e) {
      return {
        'ResultType': 0,
        'ResultMessage': 'Benutzername oder Passwort ist falsch',
      };
    }
  }

  // Use the resetPassword method from AuthService
  Future<Map<String, dynamic>> resetPassword(String passNumber) async {
    return _authService.resetPassword(passNumber);
  }

  Future<Map<String, dynamic>> fetchPassdaten(int personId) async {
    return _userService.fetchPassdaten(personId);
  }

  Future<Uint8List> fetchSchuetzenausweis(int personId) async {
    return _imageService.fetchAndCacheSchuetzenausweis(
      personId,
      () => _httpClient.getBytes('Schuetzenausweis/JPG/$personId'), // Now valid
      getCacheExpirationDuration(),
    );
  }

  Future<List<dynamic>> fetchAngemeldeteSchulungen(
    int personId,
    String abDatum,
  ) async {
    return _trainingService.fetchAngemeldeteSchulungen(personId, abDatum);
  }

  Future<List<dynamic>> fetchZweitmitgliedschaften(int personId) async {
    return _userService.fetchZweitmitgliedschaften(personId);
  }

  Future<List<dynamic>> fetchPassdatenZVE(int passdatenId, int personId) async {
    return _userService.fetchPassdatenZVE(passdatenId, personId);
  }
}
