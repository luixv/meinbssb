// Project: Mein BSSB
// Filename: auth_service.dart
// Author: Luis Mandel / NTT DATA

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:meinbssb/constants/messages.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
      final secureRandom = Random.secure();
      final bytes = List<int>.generate(32, (_) => secureRandom.nextInt(256));
      final verificationToken = base64Url.encode(bytes);

      // Create user in PostgreSQL
      await _postgrestService.createUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        passNumber: passNumber,
        personId: personId,
        verificationToken: verificationToken, // pass as verificationToken
      );

      // Send registration email
      final fromEmail = await _emailService.getFromEmail();
      final subject = await _emailService.getRegistrationSubject();
      final emailContent = await _emailService.getRegistrationContent();
      // Use the app's frontend URL for the verification link
      final baseUrl = ConfigService.buildBaseUrlForServer(
        _configService,
        name: 'email',
        protocolKey: 'emailProtocol',
      );
      final baseUrlWebApp = ConfigService.buildBaseUrlForServer(
        _configService,
        name: 'web',
        protocolKey: 'webProtocol',
      );
      if (fromEmail != null &&
          subject != null &&
          emailContent != null &&
          baseUrl.isNotEmpty) {
        final verificationLink =
            '${baseUrlWebApp}set-password?token=$verificationToken';
        final emailBody = emailContent
            .replaceAll('{firstName}', firstName)
            .replaceAll('{lastName}', lastName)
            .replaceAll('{verificationLink}', verificationLink);
        await _emailService.sendEmail(
          from: fromEmail,
          recipient: email,
          subject: subject,
          htmlBody: emailBody,
        );
      }

      // Store registration data for later use
      final registrationData = {
        'personId': personId,
        'firstName': firstName,
        'lastName': lastName,
        'passNumber': passNumber,
        'email': email,
        'birthDate': birthDate,
        'zipCode': zipCode,
        'verificationToken':
            verificationToken, // keep as verificationToken in Dart
      };

      await _cacheService.setString(
        'registration_$email',
        jsonEncode(registrationData),
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

/*
/FindePersonID/{Namen}/{Vorname}/{Geburtsdatum}/{Passnummer}/{PLZ}
/FindePersonID/rizoudis/konstantinos/30.12.1968/40101205/86574
Ergebnis der Abfrage:
[{"PERSONID":439287}]
*/

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

  Future finalizeRegistration({
    required String email,
    required String password,
    required String token,
    required String personId,
    required String passNumber,
  }) async {
    try {
      final response = await _httpClient.post(
        'ErstelleMyBSSBAccount',
        {
          'PersonID': int.tryParse(personId),
          'Email': email,
          'Passwort': jsonEncode(password),
        },
      );
      if (response is List && response.isNotEmpty) {
        final result = response[0];
        if (result['ResultType'] == 1) {
          // Mark user as verified in PostgreSQL
          await _postgrestService.verifyUser(token);

          // Send notification emails to all associated email addresses
          await _emailService.sendAccountCreationNotifications(personId, email);

          // Clear stored registration data after successful account creation
          await _cacheService.remove('registration_$email');
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
      rethrow;
    }
  }

  /// Generates a QR code image as Uint8List for the given personId.
  Future<Uint8List?> getEncryptedQRCode(
    int personId,
    DateTime geburtsdatum,
    String vorname,
    String namen,
    String strasse,
    String plz,
    String ort,
    String land,
    String passnummer,
  ) async {
    // 1. Create JSON payload
    final payload = jsonEncode({
      'personId': personId,
      'geburtsdatum':
          '${geburtsdatum.day.toString().padLeft(2, '0')}.${geburtsdatum.month.toString().padLeft(2, '0')}.${geburtsdatum.year}',
      'vorname': vorname,
      'namen': namen,
      'strasse': strasse,
      'plz': plz,
      'ort': ort,
      'land': land,
      'passnummer': passnummer,
    });

    final String? keyString =
        _configService.getString('keyString'); // must be 32 bytes
    final encrypt.Key key = encrypt.Key.fromUtf8(keyString!);
    final encrypt.IV iv = encrypt.IV.fromLength(16);

    // 2. Encrypt the payload
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(payload, iv: iv);

    // 3. Encode encrypted data as base64
    final encryptedData = encrypted.base64;

    // Now, generate the QR code with the encrypted data
    final qrValidationResult = QrValidator.validate(
      data: encryptedData,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );

    if (qrValidationResult.status != QrValidationStatus.valid) {
      return null;
    }

    final qrCode = qrValidationResult.qrCode;
    final painter = QrPainter.withQr(
      qr: qrCode!,
      color: Colors.black,
      emptyColor: Colors.white,
      gapless: true,
    );

    final picData = await painter.toImageData(300);
    return picData?.buffer.asUint8List();
  }

  Future<Map<String, dynamic>?> decryptQRCodeData(
    String encryptedBase64,
  ) async {
    try {
      final String? keyString =
          _configService.getString('keyString'); // same key as encryption
      final encrypt.Key key = encrypt.Key.fromUtf8(keyString!);
      final encrypt.IV iv =
          encrypt.IV.fromLength(16); // same IV used during encryption

      // Create encrypted object from base64 string
      final encrypted = encrypt.Encrypted.fromBase64(encryptedBase64);

      // Initialize encrypter
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      // Decrypt to string
      final String decryptedString = encrypter.decrypt(encrypted, iv: iv);

      // Parse JSON string to Map
      final Map<String, dynamic> payload = jsonDecode(decryptedString);
      return payload;
    } catch (e) {
      //print('Decryption failed: $e');
      return null;
    }
  }
}
