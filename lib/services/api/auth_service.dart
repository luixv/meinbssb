import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:meinbssb/constants/messages.dart';

import '/services/core/cache_service.dart';
import '/services/core/http_client.dart';
import '/services/core/logger_service.dart';
import '/services/core/network_service.dart';
import '/services/core/email_service.dart';
import '/services/core/postgrest_service.dart';
import '/services/core/config_service.dart';
import 'package:meinbssb/services/core/token_service.dart';

class AuthService {
  AuthService({
    required HttpClient httpClient,
    required CacheService cacheService,
    required NetworkService networkService,
    required ConfigService configService,
    required PostgrestService postgrestService,
    FlutterSecureStorage? secureStorage,
    required EmailService emailService,
  })  : _httpClient = httpClient,
        _cacheService = cacheService,
        _networkService = networkService,
        _configService = configService,
        _postgrestService = postgrestService,
        _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _emailService = emailService;

  final HttpClient _httpClient;
  final CacheService _cacheService;
  final NetworkService _networkService;
  final ConfigService _configService;
  final PostgrestService _postgrestService;
  final FlutterSecureStorage _secureStorage;
  final EmailService _emailService;

  // Add getter for postgrestService
  PostgrestService get postgrestService => _postgrestService;

  TokenService? _tokenService;

  /// Generates a secure verification token for email verification
  String generateVerificationToken() {
    final secureRandom = Random.secure();
    final bytes = List<int>.generate(32, (_) => secureRandom.nextInt(256));
    return base64Url.encode(bytes);
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String passNumber,
    required String email,
    required String birthDate,
    required String zipCode,
    required String personId,
  }) async {
    try {
      // Generate a secure verification token
      final verificationToken = generateVerificationToken();

      // Create user in PostgreSQL
      await _postgrestService.createUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        passNumber: passNumber,
        personId: personId,
        verificationToken: verificationToken, // pass as verificationToken
      );
      LoggerService.logInfo(
        'User created...',
      );
      final tokenUrl = ConfigService.buildBaseUrlForServer(
        _configService,
        name: 'web',
      );
      final verificationLink =
          '${tokenUrl}set-password?token=$verificationToken';
      LoggerService.logInfo(
        'Verification link: $verificationLink',
      );
      // Send registration email
      await _emailService.sendRegistrationEmail(
        email: email,
        firstName: firstName,
        lastName: lastName,
        verificationLink: verificationLink,
      );
      return {
        'ResultType': 1,
        'ResultMessage': Messages.registrationDataStored,
      };
    } catch (e) {
      LoggerService.logError('Registration error: $e');
      return {
        'ResultType': 0,
        'ResultMessage': Messages.registrationDataStoreFailed,
      };
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final baseUrl =
          ConfigService.buildBaseUrlForServer(_configService, name: 'api1Base');

      const endpoint = 'LoginMeinBSSBApp';
      final response = await _httpClient.post(
        endpoint,
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

  Future<Map<String, dynamic>> myBSSBPasswortAendern(
    int personId,
    String newPassword,
  ) async {
    try {
      const endpoint = 'MyBSSBPasswortAendern';
      final response = await _httpClient.put(endpoint, {
        'PersonID': personId,
        'PasswortNeu': newPassword,
      });
      return response is Map<String, dynamic> ? response : {};
    } catch (e) {
      LoggerService.logError('Change Password  error: $e');
      rethrow;
    }
  }

  Future finalizeRegistration({
    required String email,
    required String password,
    required String token,
    required String personId,
    required String passNumber,
  }) async {
    try {
      const endpoint = 'ErstelleMyBSSBAccount';
      final response = await _httpClient.post(
        endpoint,
        {
          'PersonID': int.tryParse(personId),
          'Email': email,
          'Passwort': password,
        },
      );
      if (response is List && response.isNotEmpty) {
        final result = response[0];
        LoggerService.logInfo('We got this response: $result');
        LoggerService.logInfo("Result type is: ${result['RESULTTYPE']}");
        if (result['RESULTTYPE'] == 1) {
          // Mark user as verified in PostgreSQL
          await _postgrestService.verifyUser(token);
          // Send notification emails to all associated email addresses
          await _emailService.sendAccountCreationNotifications(personId, email);
        }
      }
      return response;
    } catch (e) {
      LoggerService.logError('Error in finalizeRegistration: $e');
      return {'ResultType': 0, 'ResultMessage': Messages.accountCreationFailed};
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

  Future<String> getPersonIDByPassnummer(String passNumber) async {
    try {
      final baseUrl =
          ConfigService.buildBaseUrlForServer(_configService, name: 'api1Base');
      final endpoint = 'PersonID/$passNumber';
      final response =
          await _httpClient.get(endpoint, overrideBaseUrl: baseUrl);
      if (response is List && response.isNotEmpty) {
        final personId = response[0]['PERSONID'];
        if (personId != null && personId != 0) {
          return personId.toString();
        }
      }
      LoggerService.logError('Person ID not found.');
      return '0';
    } catch (e) {
      LoggerService.logError('Find Person ID error: $e');
      return '0';
    }
  }

  Future<Map<String, dynamic>> getPassDatenByPersonId(String personId) async {
    try {
      final baseUrl =
          ConfigService.buildBaseUrlForServer(_configService, name: 'apiBase');
      final endpoint = 'Passdaten/$personId';
      final response =
          await _httpClient.get(endpoint, overrideBaseUrl: baseUrl);
      if (response is List && response.isNotEmpty) {
        return response[0];
      }
      LoggerService.logError('Person ID not found.');
      return {};
    } catch (e) {
      LoggerService.logError('Find Person ID error: $e');
      return {};
    }
  }

  Future<String> findePersonID(
    String lastName,
    String firstName,
    String birthDate,
    String passNumber,
    String zipCode,
  ) async {
    try {
      // Convert birthdate from YYYY-MM-DD to DD.MM.YYYY format
      String formattedBirthDate;
      try {
        final date = DateTime.parse(birthDate);
        formattedBirthDate =
            '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
      } catch (e) {
        // If parsing fails, assume it's already in the correct format
        formattedBirthDate = birthDate;
      }

      final baseUrl =
          ConfigService.buildBaseUrlForServer(_configService, name: 'apiBase');
      final endpoint =
          'FindePersonID/$lastName/$firstName/$formattedBirthDate/$passNumber/$zipCode';
      LoggerService.logInfo('Searching for person: $baseUrl$endpoint');
      final response =
          await _httpClient.get(endpoint, overrideBaseUrl: baseUrl);
      if (response is List && response.isNotEmpty) {
        final personId = response[0]['PERSONID'];
        if (personId != null && personId != 0) {
          LoggerService.logInfo('Found person id: $personId');
          return personId.toString();
        }
      }
      LoggerService.logError('Person ID not found.');
      return '0';
    } catch (e) {
      LoggerService.logError('Find Person ID error: $e');
      return '0';
    }
  }

  /// Step 1: Send password reset link to user
  Future<Map<String, dynamic>> resetPasswordStep1(
    String passNumber,
  ) async {
    try {
      String personId = await getPersonIDByPassnummer(passNumber);
      final emailAddresses =
          await _emailService.getEmailAddressesByPersonId(personId);

      if (emailAddresses.isEmpty) {
        // Propagate error: no email found for passNumber
        return {
          'ResultType': 99,
          'ResultMessage': 'Keine Emails für diese Passnummer gefunden.',
          'PersonID': 0,
          'EmailListe': '',
          'PasswortNeu': '',
        };
      }
      final passData = await getPassDatenByPersonId(personId);

      // Check latest password reset for this person
      final latestReset =
          await _postgrestService.getLatestPasswordResetForPerson(personId);
      if (latestReset != null && latestReset['created_at'] != null) {
        final createdAt =
            DateTime.tryParse(latestReset['created_at'].toString());
        if (createdAt != null &&
            DateTime.now().difference(createdAt).inHours < 24) {
          return {
            'ResultType': 98,
            'ResultMessage':
                'Passwort-Link wurde bereits an Ihre E-Mail gesendet. Bitte prüfen Sie Ihr Postfach.',
          };
        }
      }
      final verificationToken = generateVerificationToken();
      final tokenUrl = ConfigService.buildBaseUrlForServer(
        _configService,
        name: 'web',
      );
      final verificationLink =
          '${tokenUrl}reset-password?token=$verificationToken&personId=$personId';
      LoggerService.logInfo(
        'Verification link: $verificationLink',
      );
      await _emailService.sendPasswordResetNotifications(
        passData,
        emailAddresses,
        verificationLink,
      );
      LoggerService.logInfo('Verification link is: $verificationLink');
      // Store password reset entry in PostgREST
      await _postgrestService.createPasswordResetEntry(
        personId: personId,
        verificationToken: verificationToken,
      );
      return {
        'ResultType': 1,
        'ResultMessage': 'Passwort-Reset-Link wurde gesendet.',
      };
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

  /// Resets password using the provided token and new password
  Future<Map<String, dynamic>> resetPasswordStep2(
    String token,
    String personId,
    String newPassword,
  ) async {
    try {
      // Step 1: Parse personId and verificationToken from token
      LoggerService.logInfo('Got token: $token');
      LoggerService.logInfo('Got personId: $personId');
      LoggerService.logInfo('Calling MyBSSBPasswortAendern...');
      // Step 2: Call the API endpoint

      const endpoint = 'MyBSSBPasswortAendern';
      final response = await _httpClient.put(
        endpoint,
        {
          'PersonID': int.parse(personId),
          'PasswortNeu': newPassword,
        },
      );
      LoggerService.logInfo("Got response: $response['result']");
      // Step 3: Check response
      if (response is Map<String, dynamic> &&
          response.containsKey('result') &&
          response['result'] == true) {
        // Success case
        await _postgrestService.markPasswordResetEntryUsed(
          verificationToken: token,
        );
        return {
          'success': true,
          'message': 'Ihr Passwort wurde erfolgreich zurückgesetzt.',
        };
      } else {
        // Empty response or unexpected format
        return {
          'success': false,
          'message':
              'Fehler beim Zurücksetzen des Passworts: Ungültige Server-Antwort.',
        };
      }
    } catch (e) {
      LoggerService.logError('Password reset error: $e');
      return {
        'success': false,
        'message': 'Fehler beim Zurücksetzen des Passworts: $e',
      };
    }
  }
}
