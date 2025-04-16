// Project: Mein BSSB
// Filename: api_service.dart
// Author: Luis Mandel / NTT DATA

import 'dart:async';

import '/services/cache_service.dart';
import '/services/http_client.dart';
import '/services/logger_service.dart';
import '/services/network_service.dart';
import '/services/image_service.dart';
import '/services/api/user_service.dart';
import '/services/api/training_service.dart';

class ApiService {
  ApiService({
    required HttpClient httpClient,
    required CacheService cacheService,
    required NetworkService networkService,
    required ImageService imageService,
    String? baseIp,
    String? port,
    int? serverTimeout,
  }) : _httpClient = httpClient,
       _imageService = imageService,
       _userService = UserService(
         httpClient: httpClient,
         cacheService: cacheService,
         networkService: networkService,
       ),
       _trainingService = TrainingService(
         httpClient: httpClient,
         cacheService: cacheService,
         networkService: networkService,
       );

  final HttpClient _httpClient;
  final ImageService _imageService;
  final UserService _userService;
  final TrainingService _trainingService;

  // User related methods
  Future<Map<String, dynamic>> fetchPassdaten(int personId) async {
    return _userService.fetchPassdaten(personId);
  }

  Future<List<dynamic>> fetchZweitmitgliedschaften(int personId) async {
    return _userService.fetchZweitmitgliedschaften(personId);
  }

  Future<List<dynamic>> fetchPassdatenZVE(int passdatenId, int personId) async {
    return _userService.fetchPassdatenZVE(passdatenId, personId);
  }

  // Training related methods
  Future<List<dynamic>> fetchAngemeldeteSchulungen(
    int personId,
    String abDatum,
  ) async {
    return _trainingService.fetchAngemeldeteSchulungen(personId, abDatum);
  }

  Future<List<dynamic>> fetchAvailableSchulungen() async {
    return _trainingService.fetchAvailableSchulungen();
  }

  Future<bool> registerForSchulung(int personId, int schulungId) async {
    return _trainingService.registerForSchulung(personId, schulungId);
  }

  // Other API methods that don't fit into specialized services
  Future<Map<String, dynamic>> fetchUserData(String username) async {
    try {
      final response = await _httpClient.get('UserData/$username');
      return _mapUserDataResponse(response);
    } catch (e) {
      LoggerService.logError('Error fetching user data: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _mapUserDataResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
      return {
        'PERSONID': response['PERSONID'],
        'USERNAME': response['USERNAME'],
        'EMAIL': response['EMAIL'],
        'FIRSTNAME': response['FIRSTNAME'],
        'LASTNAME': response['LASTNAME'],
      };
    }
    return {};
  }

  Future<bool> updateUserData(
    int personId,
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await _httpClient.post('UpdateUserData', {
        'personId': personId,
        ...userData,
      });
      return response['ResultType'] == 1;
    } catch (e) {
      LoggerService.logError('Error updating user data: $e');
      rethrow;
    }
  }
}
