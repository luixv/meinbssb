// api_service.dart
import 'package:meinbssb/services/http_client.dart';
import 'dart:async';
import 'package:meinbssb/services/localization_service.dart';
import 'package:meinbssb/services/database_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() {
    return 'NetworkException: $message';
  }
}

class ApiService {
  final HttpClient _httpClient;
  final DatabaseService _databaseService;
  final CacheService _cacheService;

  ApiService({
    required HttpClient httpClient,
    required DatabaseService databaseService,
    required CacheService cacheService,
    required String baseIp,
    required String port,
    required int serverTimeout,
  }) : _httpClient = httpClient,
       _databaseService = databaseService,
       _cacheService = cacheService;

  Future<bool> hasInternet() async {
    return await InternetConnectionChecker.createInstance().hasConnection;
  }

  Duration getCacheExpirationDuration() {
    int validityHours;
    try {
      validityHours = int.parse(
        LocalizationService.getString('cacheExpiration'),
      );
    } catch (e) {
      debugPrint("Error parsing cacheExpiration: $e");
      validityHours = 24; // Default value
    }
    return Duration(hours: validityHours);
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String passNumber,
    required String email,
    required String birthDate,
    required String zipCode,
  }) async {
    return _httpClient
        .post('RegisterMyBSSB', {
          "firstName": firstName,
          "lastName": lastName,
          "passNumber": passNumber,
          "email": email,
          "birthDate": birthDate,
          "zipCode": zipCode,
        })
        .then((value) => value is Map<String, dynamic> ? value : {});
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final secureStorage = const FlutterSecureStorage();

    try {
      final response = await _httpClient.post('LoginMyBSSB', {
        "email": email,
        "password": password,
      });

      if (response is Map<String, dynamic>) {
        if (response['ResultType'] == 1) {
          await _cacheService.setString('username', email);
          await secureStorage.write(key: 'password', value: password);
          await _cacheService.setInt('personId', response['PersonID']);
          await _cacheService.setCacheTimestamp();
          debugPrint('User data cached successfully.');
          return response;
        } else {
          debugPrint('Login failed on server: ${response['ResultMessage']}');
          return response;
        }
      } else {
        debugPrint('Invalid server response.');
        return {};
      }
    } on Exception catch (e) {
      if (e is http.ClientException &&
          (e.message.contains('refused') ||
              e.message.contains('failed to connect'))) {
        debugPrint('ClientException contains SocketException: ${e.message}');

        final cachedUsername = await _cacheService.getString('username');
        final cachedPassword = await secureStorage.read(key: 'password');
        final cachedPersonId = await _cacheService.getInt('personId');
        final cachedTimestamp = await _cacheService.getInt('cacheTimestamp');

        if (cachedUsername == email &&
            cachedPassword == password &&
            cachedPersonId != null &&
            cachedTimestamp != null) {
          final validityHours = int.parse(
            LocalizationService.getString('cacheExpiration'),
          );
          final expirationTime = DateTime.fromMillisecondsSinceEpoch(
            cachedTimestamp,
          ).add(Duration(hours: validityHours));

          if (DateTime.now().isBefore(expirationTime)) {
            debugPrint('Login from cache successful.');
            return {"ResultType": 1, "PersonID": cachedPersonId};
          } else {
            debugPrint('Cached data expired.');
            return {
              "ResultType": 0,
              "ResultMessage": "Cached data expired. Please log in again.",
            };
          }
        }
        return {
          "ResultType": 0,
          "ResultMessage":
              "Offline login failed, no cache or password mismatch",
        };
      } else {
        debugPrint('Other Login error: $e');
        return {"ResultType": 0, "ResultMessage": "Other login error"};
      }
    }
  }

  Future<Map<String, dynamic>> resetPassword(String passNumber) async {
    try {
      return _httpClient
          .post('PasswordReset/$passNumber', {"passNumber": passNumber})
          .then((value) => value is Map<String, dynamic> ? value : {});
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
      (response) {
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
      },
    );
  }

  Future<Uint8List> fetchSchuetzenausweis(int personId) async {
    final validityDuration = getCacheExpirationDuration();

    Future<Uint8List?> getCachedSchuetzenausweis() async {
      try {
        return await _databaseService.getCachedSchuetzenausweis(
          personId,
          validityDuration,
        );
      } catch (cacheError) {
        debugPrint('Cache error: $cacheError');
        return null;
      }
    }

    try {
      final cachedImage = await getCachedSchuetzenausweis();
      if (cachedImage != null) {
        debugPrint('Using cached Schuetzenausweis');
        return cachedImage;
      }

      final imageData = await _httpClient.getBytes(
        'Schuetzenausweis/JPG/$personId',
      );

      await _databaseService.cacheSchuetzenausweis(
        personId,
        imageData,
        DateTime.now().millisecondsSinceEpoch,
      );
      return imageData;
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
      () async =>
          await _httpClient.get('AngemeldeteSchulungen/$personId/$abDatum')
              as List<dynamic>,
      (response) {
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
      },
    );
  }
}
