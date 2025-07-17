// Project: Mein BSSB
// Filename: auth_service.dart
// Author: Luis Mandel / NTT DATA

import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '/services/core/cache_service.dart';
import '/services/core/http_client.dart';
import '/services/core/logger_service.dart';
import '/services/core/network_service.dart';
import '/services/core/config_service.dart';
import 'package:meinbssb/services/core/token_service.dart';

class AuthService {
  AuthService({
    required HttpClient httpClient,
    required CacheService cacheService,
    required NetworkService networkService,
    required ConfigService configService,
    FlutterSecureStorage? secureStorage,
  })  : _httpClient = httpClient,
        _cacheService = cacheService,
        _networkService = networkService,
        _configService = configService,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final HttpClient _httpClient;
  final CacheService _cacheService;
  final NetworkService _networkService;
  final ConfigService _configService;
  final FlutterSecureStorage
      _secureStorage; // <--- Declare it here, but DO NOT initialize it with 'const FlutterSecureStorage()'

  TokenService? _tokenService;

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

// This method will return THE FIRST EMAIL... Is thi correct??

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
      final baseUrl =
          ConfigService.buildBaseUrlForServer(_configService, name: 'api1Base');

      final response = await _httpClient.post(
        'LoginMyBSSB',
        {
          'Email': email,
          'Passwort': password,
        },
        overrideBaseUrl: baseUrl,
      );

      if (response is Map<String, dynamic>) {
        if (response['ResultType'] == 1) {
          await _cacheService.setString('username', email);
          await _secureStorage.write(key: 'password', value: password);
          await _cacheService.setInt('personId', response['PersonID']);
          await _cacheService.setInt('webLoginId', response['WebLoginID']);
          await _cacheService.setCacheTimestampForKey('username');
          await _cacheService.setCacheTimestampForKey('personId');
          await _cacheService.setCacheTimestampForKey('webLoginId');
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
    final cachedUsernameTimestamp =
        await _cacheService.getCacheTimestampForKey('username');
    final cachedPersonIdTimestamp =
        await _cacheService.getCacheTimestampForKey('personId');
    final cachedWebloginIdTimestamp =
        await _cacheService.getCacheTimestampForKey('webLoginId');
    final expirationDuration = _networkService.getCacheExpirationDuration();
    final now = DateTime.now();
    bool isUsernameValid = false;
    bool isPersonIdValid = false;
    bool isWebloginIdValid = false;
    if (cachedUsernameTimestamp != null) {
      final expirationTime =
          DateTime.fromMillisecondsSinceEpoch(cachedUsernameTimestamp)
              .add(expirationDuration);
      isUsernameValid = now.isBefore(expirationTime);
    }
    if (cachedPersonIdTimestamp != null) {
      final expirationTime =
          DateTime.fromMillisecondsSinceEpoch(cachedPersonIdTimestamp)
              .add(expirationDuration);
      isPersonIdValid = now.isBefore(expirationTime);
    }
    if (cachedWebloginIdTimestamp != null) {
      final expirationTime =
          DateTime.fromMillisecondsSinceEpoch(cachedWebloginIdTimestamp)
              .add(expirationDuration);
      isWebloginIdValid = now.isBefore(expirationTime);
    }
    final testCachedUsername = cachedUsername == email;
    final testCachedPassword = cachedPassword == password;
    final testCachedPersonId = cachedPersonId != null;
    final testCachedWebloginId = cachedWebloginId != null;
    final isCacheValid = testCachedUsername &&
        testCachedPassword &&
        testCachedPersonId &&
        testCachedWebloginId &&
        isUsernameValid &&
        isPersonIdValid &&
        isWebloginIdValid;
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
          testCachedWebloginId &&
          (!isUsernameValid || !isPersonIdValid || !isWebloginIdValid)) {
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

  Future<Map<String, dynamic>> passwordReset(
    String passNumber,
  ) async {
    try {
      String email = await fetchLoginEmail(passNumber);

      if (email.isEmpty) {
        // Propagate error: no email found for passNumber
        return {
          'ResultType': 99,
          'ResultMessage': 'Keine Login-Email für diese Passnummer gefunden.',
          'PersonID': 0,
          'EmailListe': '',
          'PasswortNeu': '',
        };
      }

      final response =
          await _httpClient.get('MyBSSBPasswortReset/$passNumber/$email');

      // Propagate all responses, let the screen check ResultType
      if (response is Map<String, dynamic>) {
        return response;
      } else {
        return {
          'ResultType': 98,
          'ResultMessage': 'Ungültige Serverantwort.',
          'PersonID': 0,
          'EmailListe': '',
          'PasswortNeu': '',
        };
      }
    } catch (e) {
      LoggerService.logError('Password reset error: $e');
      return {
        'ResultType': 97,
        'ResultMessage': 'Fehler beim Zurücksetzen des Passworts: $e',
        'PersonID': 0,
        'EmailListe': '',
        'PasswortNeu': '',
      };
    }
  }

  Future<Map<String, dynamic>> changePassword(
    int personId,
    String newPassword,
  ) async {
    try {
      final response = await _httpClient.put('MyBSSBPasswortAendern', {
        'PersonID': personId,
        'PasswortNeu': newPassword,
      });
      return response is Map<String, dynamic> ? response : {};
    } catch (e) {
      LoggerService.logError('Change Password  error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      LoggerService.logInfo('User logged out successfully.');
    } catch (e) {
      LoggerService.logError('Logout error: $e');
      rethrow;
    }
  }

  /// Looks up a person by Nachname and Passnummer. Returns the PERSONID as a String if found, or an empty string otherwise.
  Future<int> findePersonID2(String nachname, String passnummer) async {
    try {
      final endpoint = 'FindePersonID2/$nachname/$passnummer';
      final response = await _httpClient.get(endpoint);
      if (response is List && response.isNotEmpty) {
        final person = response[0];
        if (person is Map<String, dynamic> && person['PERSONID'] != null) {
          return person['PERSONID'];
        }
      }
      return 0;
    } catch (e) {
      LoggerService.logError('findePersonID2 error: $e');
      return 0;
    }
  }

  /// Fetches the login email for a given passnummer using a special base URL from config.json.
  Future<String> fetchLoginEmail(String passnummer) async {
    try {
      // Build base URL (e.g., https://webintern.bssb.bayern:56400/rest/zmi/api1)
      final baseUrl =
          ConfigService.buildBaseUrlForServer(_configService, name: 'api1Base');
      final endpoint = 'FindeLoginMail/$passnummer';
      final response =
          await _httpClient.get(endpoint, overrideBaseUrl: baseUrl);
      if (response is List && response.isNotEmpty) {
        final loginMail = response[0]['LOGINMAIL'];
        if (loginMail is String) {
          return loginMail;
        }
      }
      return '';
    } catch (e) {
      LoggerService.logError('fetchLoginEmail error: $e');
      return '';
    }
  }

  /// Checks if the current authentication token is valid (exists and is not empty).
  Future<bool> isTokenValid() async {
    try {
      final tokenService = _tokenService ??= TokenService(
        configService: _configService,
        cacheService: _cacheService,
      );
      final token = await tokenService.getAuthToken();
      return token.isNotEmpty;
    } catch (e) {
      LoggerService.logError('isTokenValid error: $e');
      return false;
    }
  }
}
