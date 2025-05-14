// Project: Mein BSSB
// Filename: auth_service.dart
// Author: Luis Mandel / NTT DATA

import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '/services/cache_service.dart';
import '/services/http_client.dart';
import '/services/logger_service.dart';
import '/services/network_service.dart';

class AuthService {
  AuthService({
    required HttpClient httpClient,
    required CacheService cacheService,
    required NetworkService networkService,
  })  : _httpClient = httpClient,
        _cacheService = cacheService,
        _networkService = networkService;

  final HttpClient _httpClient;
  final CacheService _cacheService;
  final NetworkService _networkService;
  final _secureStorage = const FlutterSecureStorage();

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
      LoggerService.logError('Registration error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _httpClient.post('LoginMyBSSB', {
        'email': email,
        'password': password,
      });

      if (response is Map<String, dynamic>) {
        if (response['ResultType'] == 1) {
          await _cacheService.setString('username', email);
          await _secureStorage.write(key: 'password', value: password);
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
      if (e is http.ClientException) {
        LoggerService.logError(
          'http.ClientException occurred: ${e.message}',
        );
        return await _handleOfflineLogin(email, password);
      } else {
        LoggerService.logError('Benutzername oder Passwort ist falsch: $e');
        return {
          'ResultType': 0,
          'ResultMessage': 'Benutzername oder Passwort ist falsch',
        };
      }
    }
  }

  Future<Map<String, dynamic>> _handleOfflineLogin(
    String email,
    String password,
  ) async {
    final cachedUsername = await _cacheService.getString('username');
    final cachedPassword = await _secureStorage.read(key: 'password');
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
    final testExpirationDate = testCachedTimestamp &&
        today.isBefore(expirationTime); // Check timestamp before comparing

    final isCacheValid = testCachedUsername &&
        testCachedPassword &&
        testCachedPersonId &&
        testCachedTimestamp &&
        testExpirationDate;

    if (isCacheValid) {
      LoggerService.logInfo('Login from cache successful.');
      return {'ResultType': 1, 'PersonID': cachedPersonId};
    } else {
      LoggerService.logWarning('Offline login failed.');
      if (testCachedUsername &&
          testCachedPassword &&
          testCachedPersonId &&
          testCachedTimestamp &&
          !testExpirationDate) {
        return {
          'ResultType': 0,
          'ResultMessage':
              'Die Cache Daten sind abgelaufen. Bitte melden Sie sich erneut an.',
        };
      } else {
        return {
          'ResultType': 0,
          'ResultMessage':
              'Offline-Anmeldung fehlgeschlagen: Kein Cache oder falsches Passwort.',
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
    } catch (e) {
      LoggerService.logError('Password reset error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _cacheService.remove('username');
      await _secureStorage.delete(key: 'password');
      await _cacheService.remove('personId');
      await _cacheService.remove('cacheTimestamp');
      LoggerService.logInfo('User logged out successfully.');
    } catch (e) {
      LoggerService.logError('Logout error: $e');
      rethrow;
    }
  }
}
