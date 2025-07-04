// Project: Mein BSSB
// Filename: auth_service.dart
// Author: Luis Mandel / NTT DATA

import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:meinbssb/constants/messages.dart';
import 'package:uuid/uuid.dart';  // Add this for generating verification links

import '/services/core/cache_service.dart';
import '/services/core/http_client.dart';
import '/services/core/logger_service.dart';
import '/services/core/network_service.dart';
import '/services/core/email_service.dart';
import '/services/core/postgrest_service.dart';

class AuthService {
  AuthService({
    required HttpClient httpClient,
    required CacheService cacheService,
    required NetworkService networkService,
    required PostgrestService postgrestService,
    FlutterSecureStorage? secureStorage,
    required EmailService emailService,
  })  : _httpClient = httpClient,
        _cacheService = cacheService,
        _networkService = networkService,
        _postgrestService = postgrestService,
        _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _emailService = emailService;

  final HttpClient _httpClient;
  final CacheService _cacheService;
  final NetworkService _networkService;
  final PostgrestService _postgrestService;
  final FlutterSecureStorage _secureStorage;
  final EmailService _emailService;

  // Add getter for postgrestService
  PostgrestService get postgrestService => _postgrestService;

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String passNumber,
    required String email,
    required String birthDate,
    required String zipCode,
  }) async {
    try {
      // First check if user already exists in PostgreSQL
      final existingUser = await _postgrestService.getUserByPassNumber(passNumber);
      if (existingUser != null) {
        return {
          'ResultType': 0,
          'ResultMessage': 'User with this pass number already exists'
        };
      }

      // Get PersonID first
      final personId = await getPersonIDByPassnummer(passNumber);
      if (personId == '0') {
        return {
          'ResultType': 0,
          'ResultMessage': Messages.noPersonIdFound
        };
      }

      // Generate verification link
      final verificationLink = const Uuid().v4();

      // Create user in PostgreSQL
      await _postgrestService.createUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        passNumber: passNumber,
        verificationLink: verificationLink,
      );

      // Store registration data for later use
      final registrationData = {
        'personId': personId,
        'firstName': firstName,
        'lastName': lastName,
        'passNumber': passNumber,
        'email': email,
        'birthDate': birthDate,
        'zipCode': zipCode,
        'verificationLink': verificationLink,
      };

      await _cacheService.setString(
        'registration_$email',
        jsonEncode(registrationData),
      );

      return {
        'ResultType': 1,
        'ResultMessage': Messages.registrationDataStored
      };
    } catch (e) {
      LoggerService.logError('Registration error: $e');
      return {
        'ResultType': 0,
        'ResultMessage': Messages.registrationDataStoreFailed
      };
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

  Future<String> _findeMailadressen(String personId) async {
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
      // Find the email!
      String email = '';

      final response =
          await _httpClient.get('PasswordReset/$passNumber/$email');
      return response is Map<String, dynamic> ? response : {};
    } catch (e) {
      LoggerService.logError('Password reset error: $e');
      rethrow;
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

  Future<Map<String, dynamic>> finalizeRegistration({
    required String email,
    required String password,
    required String token,
    required String passNumber,
  }) async {
    try {
      // Verify the token matches the stored verification link
      final user = await _postgrestService.getUserByPassNumber(passNumber);
      if (user == null || user['verification_link'] != token) {
        return {
          'ResultType': 0,
          'ResultMessage': 'Invalid verification link'
        };
      }

      // Get the PersonID from the stored registration data
      final registrationDataJson = await _cacheService.getString('registration_$email');
      if (registrationDataJson == null) {
        return {
          'ResultType': 0,
          'ResultMessage': Messages.registrationDataNotFound
        };
      }

      final registrationData = jsonDecode(registrationDataJson);
      final personId = registrationData['personId'];

      if (personId == null || personId.isEmpty) {
        return {
          'ResultType': 0,
          'ResultMessage': Messages.registrationDataNotFound
        };
      }

      // Call the API to create the account
      final response = await _httpClient.post(
        'ErstelleMyBSSBAccount',
        {
          'PersonID': personId,
          'Email': email,
          'Passwort': password,
        },
      );

      if (response['ResultType'] == 1) {
        // Mark user as verified in PostgreSQL
        await _postgrestService.verifyUser(token);
        
        // Send notification emails to all associated email addresses
        await _emailService.sendAccountCreationNotifications(personId, email);
        
        // Clear stored registration data after successful account creation
        await _cacheService.remove('registration_$email');
      }

      return response;
    } catch (e) {
      LoggerService.logError('Error in finalizeRegistration: $e');
      return {
        'ResultType': 0,
        'ResultMessage': Messages.accountCreationFailed
      };
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

  /// Checks if a person exists by Nachname and Passnummer. Returns true if found, false otherwise.
  Future<bool> findePersonID2(String nachname, String passnummer) async {
    try {
      final response =
          await _httpClient.get('FindePersonID/$nachname/$passnummer');
      if (response is List && response.isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      LoggerService.logError('findePersonID2 error: $e');
      return false;
    }
  }

  Future<String> getPersonIDByPassnummer(String passNumber) async {
    try {
      final response = await _httpClient.get('PersonID/$passNumber');
      if (response is Map<String, dynamic>) {
        if (response['PERSONID'] != null && response['PERSONID'] != 0) {
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
}
