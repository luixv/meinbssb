// api_service.dart
import 'package:meinbssb/services/http_client.dart';
import 'dart:async';
import 'package:meinbssb/services/localization_service.dart';
import 'package:meinbssb/services/database_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final HttpClient _httpClient;
  final DatabaseService _databaseService = DatabaseService();

  ApiService({
    required String baseIp,
    required String port,
    required int serverTimeout,
  }) : _httpClient = HttpClient(
         baseUrl: 'http://$baseIp:$port',
         serverTimeout: serverTimeout,
       );

  Future<bool> hasInternet() async {
    bool has = await InternetConnectionChecker.createInstance().hasConnection;
    return has;
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
    final cacheService = CacheService();

    try {
      final response = await _httpClient.post('LoginMyBSSB', {
        "email": email,
        "password": password,
      });

      if (response is Map<String, dynamic>) {
        if (response['ResultType'] == 1) {
          await cacheService.setString('username', email);
          await secureStorage.write(key: 'password', value: password);
          await cacheService.setInt('personId', response['PersonID']);
          await cacheService.setInt(
            'cacheTimestamp',
            DateTime.now().millisecondsSinceEpoch,
          );
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

        final cachedUsername = await cacheService.getString('username');
        final cachedPassword = await secureStorage.read(key: 'password');
        final cachedPersonId = await cacheService.getInt('personId');
        final cachedTimestamp = await cacheService.getInt('cacheTimestamp');

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
    return _httpClient
        .post('PasswordReset/$passNumber', {"passNumber": passNumber})
        .then(
          (value) => value is Map<String, dynamic> ? value : {},
        ); // Corrected line
  }

  Future<Map<String, dynamic>> fetchPassdaten(int personId) async {
    final validityDuration = getCacheExpirationDuration();
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'passdaten_$personId';
    final cacheService = CacheService();

    Future<Map<String, dynamic>> getCachedPassdaten() async {
      try {
        final cachedJson = prefs.getString(cacheKey);
        if (cachedJson != null) {
          final cachedData = jsonDecode(cachedJson) as Map<String, dynamic>;
          final globalTimestamp = await cacheService.getInt('cacheTimestamp');

          if (globalTimestamp != null) {
            final expirationTime = DateTime.fromMillisecondsSinceEpoch(
              globalTimestamp,
            ).add(validityDuration);
            if (DateTime.now().isBefore(expirationTime)) {
              debugPrint('Using cached passdaten from SharedPreferences.');
              return cachedData;
            } else {
              debugPrint('Cached passdaten expired.');
              return {};
            }
          }
        }
        return {};
      } catch (cacheError) {
        debugPrint('Cache error: $cacheError');
        return {};
      }
    }

    try {
      final response = await _httpClient.get('Passdaten/$personId');

      if (response is Map<String, dynamic>) {
        final passdaten = response;

        final cachedData = {
          'PASSNUMMER': passdaten['PASSNUMMER'],
          'VEREINNR': passdaten['VEREINNR'],
          'NAMEN': passdaten['NAMEN'],
          'VORNAME': passdaten['VORNAME'],
          'TITEL': passdaten['TITEL'],
          'GEBURTSDATUM': passdaten['GEBURTSDATUM'],
          'GESCHLECHT': passdaten['GESCHLECHT'],
          'VEREINNAME': passdaten['VEREINNAME'],
          'PASSDATENID': passdaten['PASSDATENID'],
          'MITGLIEDSCHAFTID': passdaten['MITGLIEDSCHAFTID'],
          'PERSONID': passdaten['PERSONID'],
        };

        await prefs.setString(cacheKey, jsonEncode(cachedData));
        await cacheService.setInt(
          'cacheTimestamp',
          DateTime.now().millisecondsSinceEpoch,
        );

        return passdaten;
      } else {
        debugPrint('Invalid response format from API.');
        return getCachedPassdaten();
      }
    } catch (e) {
      debugPrint(
        'API call error: $e. Attempting to retrieve passdaten from cache.',
      );
      return getCachedPassdaten();
    }
  }

  Future<Uint8List> fetchSchuetzenausweis(int personId) async {
    final validityDuration = getCacheExpirationDuration();

    Future<Uint8List?> getCachedSchuetzenausweis() async {
      try {
        final cachedImage = await _databaseService.getCachedSchuetzenausweis(
          personId,
          validityDuration,
        );
        return cachedImage;
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
    } catch (e) {
      debugPrint('Error fetching Schuetzenausweis: $e');
      final cachedImage = await getCachedSchuetzenausweis();
      if (cachedImage != null) {
        return cachedImage;
      }
      throw Exception('Schützenausweis ist nicht verfügbar');
    }
  }

  Future<void> _cacheSchulungenInMainIsolate(List<dynamic> args) async {
    final String cacheKey = args[0];
    final List<Map<String, dynamic>> cachedSchulungen =
        List<Map<String, dynamic>>.from(args[1]);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(cacheKey, jsonEncode(cachedSchulungen));
  }

  Future<List<dynamic>> fetchAngemeldeteSchulungen(
    int personId,
    String abDatum,
  ) async {
    final validityDuration = getCacheExpirationDuration();
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'schulungen_$personId';
    final cacheService = CacheService();

    debugPrint(
      'fetchAngemeldeteSchulungen called with personId: $personId, abDatum: $abDatum',
    );

    Future<List<dynamic>> getCachedSchulungen() async {
      try {
        final cachedJson = prefs.getString(cacheKey);
        if (cachedJson != null) {
          final cachedData = jsonDecode(cachedJson) as List<dynamic>;
          final globalTimestamp = await cacheService.getInt('cacheTimestamp');

          if (globalTimestamp != null) {
            final expirationTime = DateTime.fromMillisecondsSinceEpoch(
              globalTimestamp,
            ).add(validityDuration);
            if (DateTime.now().isBefore(expirationTime)) {
              debugPrint('Using cached schulungen from SharedPreferences.');
              return cachedData.map((item) {
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
            } else {
              debugPrint('Cached schulungen expired.');
              return [];
            }
          }
        }
        return [];
      } catch (cacheError) {
        debugPrint('Cache error: $cacheError');
        return [];
      }
    }

    try {
      final response = await _httpClient.get(
        'AngemeldeteSchulungen/$personId/$abDatum',
      );
      debugPrint('API response type: ${response.runtimeType}');

      List<dynamic> schulungen = [];

      if (response is List) {
        schulungen = response;
      } else if (response is Map && response.containsKey('schulungen')) {
        schulungen = List.from(response['schulungen']);
      } else if (response is Map && response.containsKey('ResultType')) {
        debugPrint('API error response: $response');
        throw Exception(response['ResultMessage'] ?? 'Unknown error');
      }

      if (schulungen.isNotEmpty) {
        final cachedSchulungen =
            schulungen.map((item) {
              return {
                'DATUM': item['DATUM'],
                'BEZEICHNUNG': item['BEZEICHNUNG'],
              };
            }).toList();

        _cacheSchulungenInMainIsolate([cacheKey, cachedSchulungen]);
        await cacheService.setInt(
          'cacheTimestamp',
          DateTime.now().millisecondsSinceEpoch,
        );
      }

      return schulungen.isNotEmpty ? schulungen : await getCachedSchulungen();
    } catch (e) {
      debugPrint('Network error: $e');
      return await getCachedSchulungen();
    }
  }
}
