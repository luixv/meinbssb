import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:meinbssb/services/localization_service.dart';
import 'package:meinbssb/services/database_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; 
import 'cache_service.dart';

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
        await cacheService.setInt('personId', decodedResponse['PersonID']); // Cache PersonID
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
      final cachedPersonId = await cacheService.getInt('personId'); // Retrieve PersonID

      if (cachedUsername == email && cachedPassword == password && cachedPersonId != null) {
        debugPrint('Login from cache successful.');
        // Return a JSON object with the cached PersonID.
        return {"ResultType": 1, "PersonID": cachedPersonId};
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

    Future<Map<String, dynamic>> getCachedPassdaten() async {
      try {
        final cachedPassdaten = await _databaseService.getCachedPassdaten(
          personId,
          validityDuration,
        );
        if (cachedPassdaten != null) {
          return cachedPassdaten;
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
          await _databaseService.cachePassdaten(
            personId,
            response,
            DateTime.now().millisecondsSinceEpoch,
          );
          return response;
        }
        return {};
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

  Future<List<dynamic>> fetchAngemeldeteSchulungen(
    int personId,
    String abDatum,
  ) async {
    final validityDuration = getCacheExpirationDuration();
    debugPrint('Using cache expiration: ${validityDuration.inHours} hours');

    Future<List<dynamic>> getCachedSchulungen() async {
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

      return schulungen.isNotEmpty ? schulungen : await getCachedSchulungen();
    } catch (e) {
      debugPrint('Network error: $e');
      return await getCachedSchulungen();
    }
  }
}
