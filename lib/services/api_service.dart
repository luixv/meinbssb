import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:meinbssb/services/localization_service.dart';
import 'package:meinbssb/services/database_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ApiService {
  final String baseIp;
  final String port;
  late final String baseUrl;
  final DatabaseService _databaseService = DatabaseService();

  ApiService({this.baseIp = '127.0.0.1', this.port = '3001'}) {
    baseUrl = 'http://$baseIp:$port';
  }

  Future<bool> hasInternet() async {
    bool has = await InternetConnectionChecker().hasConnection;
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
        throw Exception(
          "Request failed: ${response.statusCode}",
        ); // Throw exception on error
      }
    } catch (e) {
      debugPrint('Exception: $e');
      rethrow; // Throw exception on any error
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
    try {
      final String apiUrl = '$baseUrl/LoginMyBSSB';
      final requestBody = jsonEncode({"email": email, "password": password});

      debugPrint('Sending login request to: $apiUrl');
      debugPrint('Request body: $requestBody');

      // Separate network call

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      final decodedResponse = jsonDecode(response.body);
      if (decodedResponse is Map<String, dynamic>) {
        if (decodedResponse['ResultType'] == 1) {
          await _databaseService.cacheUser(
            email,
            password,
            decodedResponse,
            DateTime.now().millisecondsSinceEpoch,
          );
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
        // Check for connection refusal or failure
        debugPrint('ClientException contains SocketException: ${e.message}');
        try {
          final cachedUser = await _databaseService.getCachedUser(email);
          debugPrint('Cached user data: $cachedUser');
          debugPrint('Entered password: $password');
          if (cachedUser != null) {
            if (cachedUser['password'] == password) {
              debugPrint('Login from cache successful.');
              return cachedUser;
            } else {
              debugPrint('Login failed, password mismatch.');
              return {
                "ResultType": 0,
                "ResultMessage": "Offline login failed, password mismatch",
              };
            }
          } else {
            debugPrint('Login failed, no cache found.');

            return {
              "ResultType": 0,
              "ResultMessage": "Offline login failed, no cache",
            };
          }
        } catch (cacheError) {
          debugPrint('Cache error: $cacheError');
          return {"ResultType": 0, "ResultMessage": "Network and cache error"};
        }
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

    if (!await hasInternet()) {
      debugPrint(
        'Device is offline. Attempting to retrieve passdaten from cache.',
      );
      try {
        final cachedPassdaten = await _databaseService.getCachedPassdaten(
          personId,
          validityDuration,
        );
        if (cachedPassdaten != null) {
          return cachedPassdaten;
        }
        return {}; // return empty map if no cache found
      } catch (cacheError) {
        debugPrint('Cache error: $cacheError');
        return {};
      }
    } else {
      try {
        final String apiUrl = '$baseUrl/Passdaten/$personId';
        final response = await _makeRequest(http.get(Uri.parse(apiUrl)));

        if (response is Map<String, dynamic>) {
          // Only save valid data from server response
          await _databaseService.cachePassdaten(
            personId,
            response,
            DateTime.now().millisecondsSinceEpoch,
          );
          return response;
        }
        return {}; // return empty map if response is not map
      } catch (e) {
        debugPrint('API call error: $e');
        return {};
      }
    }
  }

  Future<Map<String, dynamic>> fetchPassdatenWithString(
    String passdaten,
  ) async {
    final String apiUrl = '$baseUrl/PassdatenString/$passdaten';
    return _makeRequest(http.get(Uri.parse(apiUrl))).then(
      (value) => value is Map<String, dynamic> ? value : {},
    ); // Ensure it's a Map
  }

  Future<Uint8List> fetchSchuetzenausweis(int personId) async {
    final validityDuration = getCacheExpirationDuration();
    try {
      final cachedImage = await _databaseService.getCachedSchuetzenausweis(
        personId,
        validityDuration,
      );
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
      try {
        final cachedImage = await _databaseService.getCachedSchuetzenausweis(
          personId,
          validityDuration,
        );
        if (cachedImage != null) {
          return cachedImage;
        }
        // If no cached image, throw a specific exception.
        throw Exception('Schützenausweis ist nicht verfügbar');
      } catch (cacheError) {
        debugPrint('Cache error: $cacheError');
        throw Exception('Schützenausweis ist nicht verfügbar');
      }
    }
  }

  Future<List<dynamic>> fetchAngemeldeteSchulungen(
    int personId,
    String abDatum,
  ) async {
    final validityDuration = getCacheExpirationDuration();
    debugPrint('Using cache expiration: ${validityDuration.inHours} hours');

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

      debugPrint('Parsed ${schulungen.length} schulungen');

      if (schulungen.isNotEmpty) {
        DateTime? dateTimeAbDatum = DateTime.tryParse(abDatum);
        dateTimeAbDatum ??= DateTime.now();
        await _databaseService.cacheSchulungen(
          personId,
          dateTimeAbDatum,
          jsonEncode(schulungen),
          DateTime.now().millisecondsSinceEpoch,
        );
      }

      DateTime? cachedDateTimeAbDatum = DateTime.tryParse(abDatum);
      cachedDateTimeAbDatum ??= DateTime.now();
      final cachedResults = await _databaseService.getCachedSchulungen(
        personId,
        cachedDateTimeAbDatum,
        validityDuration,
      );
      List<dynamic> cachedData = [];

      cachedData =
          cachedResults
              .map((result) {
                final data = result['schulungenData'] as String?;
                if (data != null) {
                  return jsonDecode(data);
                }
                return null;
              })
              .where((element) => element != null)
              .expand((element) => element)
              .toList();

      debugPrint('Using ${cachedData.length} cached schulungen');

      return schulungen.isNotEmpty ? schulungen : cachedData;
    } catch (e) {
      debugPrint('Network error: $e');
      try {
        DateTime? cachedDateTimeAbDatum = DateTime.tryParse(abDatum);
        cachedDateTimeAbDatum ??= DateTime.now();
        final cachedResults = await _databaseService.getCachedSchulungen(
          personId,
          cachedDateTimeAbDatum,
          validityDuration,
        );
        List<dynamic> cachedData = [];

        cachedData =
            cachedResults
                .map((result) {
                  final data = result['schulungenData'] as String?;
                  if (data != null) {
                    return jsonDecode(data);
                  }
                  return null;
                })
                .where((element) => element != null)
                .expand((element) => element)
                .toList();

        debugPrint('Using ${cachedData.length} cached schulungen');
        return cachedData;
      } catch (cacheError) {
        debugPrint('Cache error: $cacheError');
        return [];
      }
    }
  }
}
