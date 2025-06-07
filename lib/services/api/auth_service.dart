// Project: Mein BSSB
// Filename: auth_service.dart
// Author: Luis Mandel / NTT DATA

import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../core/cache_service.dart';
import '../core/http_client.dart';
import '../core/logger_service.dart';
import '../core/network_service.dart';

class AuthService {
  AuthService({
    required HttpClient httpClient,
    required CacheService cacheService,
    required NetworkService networkService,
    FlutterSecureStorage? secureStorage,
  })  : _httpClient = httpClient,
        _cacheService = cacheService,
        _networkService = networkService,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final HttpClient _httpClient;
  final CacheService _cacheService;
  final NetworkService _networkService;
  final FlutterSecureStorage
      _secureStorage; // <--- Declare it here, but DO NOT initialize it with 'const FlutterSecureStorage()'

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String passNumber,
    required String email,
    required String birthDate,
    required String zipCode,
  }) async {
    try {
      /* ErstelleMyBSSBAccount/
           Body as JSON
           {"PersonID": 439287,
            "Email": "kostas@rizoudis1.de",
            "Passwort": "test1"}
      */

      String password = '';
      String personId = await _findePersonID(
        lastName,
        firstName,
        birthDate,
        passNumber,
        zipCode,
      );

      String loginMail = await _findeMailadressen(personId);

      // ERROR - This logical condition (loginMail.isEmpty && loginMail == 'null' && loginMail != email)
      // is always false and will never return {}. The post call will always be made.
      if (loginMail.isEmpty && loginMail == 'null' && loginMail != email) {
        LoggerService.logError('No email address found.');
        return {};
      }

      final response = await _httpClient.post('RegisterMyBSSB', {
        'PersonId': personId,
        'Email': email,
        'Passwort': password,
      });

      return response is Map<String, dynamic> ? response : {};
    } catch (e) {
      LoggerService.logError('Registration error: $e');
      rethrow;
    }
  }
/*
  Future<String> _findePersonIDUndDokumente(
    String lastName,
    String passNumber,
  ) async {
    try {
      final response = await _httpClient
          .get('FindePersonIDUndDokumente/$lastName/$passNumber');
      if (response is Map<String, dynamic>) {
        if (response['PERSONID'] != 0) {
          return response['PERSONID'].toString();
        } else {
          LoggerService.logError('Person ID not found.');
          return '0';
        }
      } else {
        LoggerService.logError('Invalid server response.');
        return '0';
      }
    } catch (e) {
      LoggerService.logError('Find Person ID error: $e');
      rethrow;
    }
  }
  */

/*
/FindePersonID/{Namen}/{Vorname}/{Geburtsdatum}/{Passnummer}/{PLZ}
/FindePersonID/rizoudis/konstantinos/30.12.1968/40101205/86574
Ergebnis der Abfrage:
[{"PERSONID":439287}]
*/
  Future<String> _findePersonID(
    String namen,
    String vorname,
    String geburtsdatum,
    String passNumber,
    String plz,
  ) async {
    try {
      final response = await _httpClient
          .get('FindePersonID/$namen/$vorname/$geburtsdatum/$passNumber/$plz');
      if (response is Map<String, dynamic>) {
        if (response['PERSONID'] != 0) {
          return response['PERSONID'].toString();
        } else {
          LoggerService.logError('Person ID not found.');
          return '0';
        }
      } else {
        LoggerService.logError('Invalid server response.');
        return '0';
      }
    } catch (e) {
      LoggerService.logError('Find Person ID error: $e');
      rethrow;
    }
  }

  Future<String> _findeMailadressen(
    String personId,

    /*
    /FindeMailadressen/{PersonID}
    Response
    [
    {
        "MAILADRESSEN": "an719328@gmail.com",
        "LOGINMAIL": "kostas@rizoudis1.de"
    },
    {
        "MAILADRESSEN": "an963916@freenet.de",
        "LOGINMAIL": "kostas@rizoudis1.de"
    }
  ]
    */
  ) async {
    try {
      final response = await _httpClient.get('FindeMailadressen/$personId');
      if (response is List) {
        if (response.isNotEmpty) {
          final email = response[0]['LOGINMAIL'];
          return email;
        } else {
          LoggerService.logError('No email addresses found.');
          return '';
        }
      } else {
        LoggerService.logError('Invalid server response.');
        return '';
      }
    } catch (e) {
      LoggerService.logError('Find email address error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _httpClient.getWithBody('LoginMyBSSB', {
        'Email': email,
        'Passwort': password,
      });

      if (response is Map<String, dynamic>) {
        if (response['ResultType'] == 1) {
          await _cacheService.setString('username', email);
          await _secureStorage.write(key: 'password', value: password);
          await _cacheService.setInt('personId', response['PersonID']);
          await _cacheService.setInt('webLoginId', response['WebLoginID']);
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
    final cachedWebloginId = await _cacheService.getInt('webLoginId');
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
      return {
        'ResultType': 1,
        'PersonID': cachedPersonId,
        'WebLoginID': cachedWebloginId,
      };
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
      // This method needs the email address of the user

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
