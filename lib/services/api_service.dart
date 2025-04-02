import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:meinbssb/services/localization_service.dart';
import 'package:meinbssb/services/database_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final String baseIp;
  final String port;
  late final String baseUrl;
  final DatabaseService _databaseService = DatabaseService();

  ApiService({this.baseIp = '127.0.0.1', this.port = '3001'}) {
    baseUrl = 'http://$baseIp:$port';
  }

  Future<bool> hasInternet() async {
    bool has = await InternetConnectionChecker.createInstance().hasConnection;
    return has;
  }

  Future<dynamic> _makeRequest(Future<http.Response> request) async {
    try {
      final response = await request.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException("Server timeout");
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Request failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('Exception: $e');
      rethrow;
    }
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
    final String apiUrl = '$baseUrl/RegisterMyBSSB';
    final requestBody = jsonEncode({
      "firstName": firstName,
      "lastName": lastName,
      "passNumber": passNumber,
      "email": email,
      "birthDate": birthDate,
      "zipCode": zipCode,
    });

    debugPrint('Sending registration request to: $apiUrl');
    debugPrint('Request body: $requestBody');

    return _makeRequest(
      http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      ),
    ).then(
      (value) => value is Map<String, dynamic> ? value : {},
    ); // Ensure it's a Map
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final secureStorage = const FlutterSecureStorage();
    final cacheService = CacheService();

    try {
      final String apiUrl = '$baseUrl/LoginMyBSSB';
      final requestBody = jsonEncode({"email": email, "password": password});

      debugPrint('Sending login request to: $apiUrl');
      debugPrint('Request body: $requestBody');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      final decodedResponse = jsonDecode(response.body);
      if (decodedResponse is Map<String, dynamic>) {
        if (decodedResponse['ResultType'] == 1) {
          await cacheService.setString('username', email);
          await secureStorage.write(key: 'password', value: password);
          await cacheService.setInt('personId', decodedResponse['PersonID']);
          await cacheService.setInt(
            'cacheTimestamp',
            DateTime.now().millisecondsSinceEpoch,
          ); // Save timestamp
          debugPrint('User data cached successfully.');
          return decodedResponse;
        } else {
          debugPrint(
            'Login failed on server: ${decodedResponse['ResultMessage']}',
          );
          return decodedResponse;
        }
      } else {
        debugPrint('Invalid server response.');
        return {};
      }
    } on http.ClientException catch (e) {
      if (e.message.contains('refused') ||
          e.message.contains('failed to connect')) {
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
        debugPrint('ClientException, not SocketException: ${e.message}');
        return {
          "ResultType": 0,
          "ResultMessage": "ClientException, not SocketException",
        };
      }
    } catch (e) {
      debugPrint('Other Login error: $e');
      return {"ResultType": 0, "ResultMessage": "Other login error"};
    }
  }

  Future<Map<String, dynamic>> resetPassword(String passNumber) async {
    final String apiUrl = '$baseUrl/PasswordReset/$passNumber';
    final requestBody = jsonEncode({"passNumber": passNumber});
    return _makeRequest(
      http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      ),
    ).then((value) => value is Map<String, dynamic> ? value : {});
  }

  Future<Map<String, dynamic>> fetchPassdaten(int personId) async {
    final validityDuration = getCacheExpirationDuration();
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'passdaten_$personId';

    Future<Map<String, dynamic>> getCachedPassdaten() async {
      try {
        final cachedJson = prefs.getString(cacheKey);
        if (cachedJson != null) {
          final cachedData = jsonDecode(cachedJson) as Map<String, dynamic>;
          final cachedTimestamp = cachedData['timestamp'] as int?;
          if (cachedTimestamp != null) {
            final expirationTime = DateTime.fromMillisecondsSinceEpoch(
              cachedTimestamp,
            ).add(validityDuration);
            if (DateTime.now().isBefore(expirationTime)) {
              debugPrint('Using cached passdaten from SharedPreferences.');
              return cachedData['data'] as Map<String, dynamic>;
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

    if (!await hasInternet()) {
      debugPrint(
        'Device is offline. Attempting to retrieve passdaten from cache.',
      );
      return getCachedPassdaten();
    } else {
      try {
        final String apiUrl = '$baseUrl/Passdaten/$personId';
        final response = await _makeRequest(http.get(Uri.parse(apiUrl)));

        if (response is Map<String, dynamic>) {
          final passdaten = response;

          // fields to cache
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
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          };

          // Cache the selected fields with timestamp
          await prefs.setString(cacheKey, jsonEncode(cachedData));

          return cachedData;
        } else {
          debugPrint('Invalid response format.');
          return {};
        }
      } catch (e) {
        debugPrint('API call error: $e');
        debugPrint(
          'Attempting to retrieve passdaten from cache as API fallback.',
        );
        return getCachedPassdaten();
      }
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

      final String apiUrl = '$baseUrl/Schuetzenausweis/JPG/$personId';
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final imageData = response.bodyBytes;
        await _databaseService.cacheSchuetzenausweis(
          personId,
          imageData,
          DateTime.now().millisecondsSinceEpoch,
        );
        return imageData;
      }
      throw Exception('Failed to load image: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error fetching Schuetzenausweis: $e');
      final cachedImage = await getCachedSchuetzenausweis();
      if (cachedImage != null) {
        return cachedImage;
      }
      // If no cached image, throw a specific exception.
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
    final cacheKey = 'schulungen_${personId}_$abDatum';

    Future<List<dynamic>> getCachedSchulungen() async {
      try {
        final cachedJson = prefs.getString(cacheKey);
        if (cachedJson != null) {
          final cachedData = jsonDecode(cachedJson) as List<dynamic>;
          final cachedTimestamp =
              cachedData.isNotEmpty
                  ? cachedData.first['timestamp'] as int?
                  : null;

          if (cachedTimestamp != null) {
            final expirationTime = DateTime.fromMillisecondsSinceEpoch(
              cachedTimestamp,
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
      final String apiUrl = '$baseUrl/AngemeldeteSchulungen/$personId/$abDatum';
      final response = await _makeRequest(http.get(Uri.parse(apiUrl)));
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
                'timestamp': DateTime.now().millisecondsSinceEpoch,
              };
            }).toList();

        _cacheSchulungenInMainIsolate([cacheKey, cachedSchulungen]);
      }

      return schulungen.isNotEmpty ? schulungen : await getCachedSchulungen();
    } catch (e) {
      debugPrint('Network error: $e');
      return await getCachedSchulungen();
    }
  }
}
