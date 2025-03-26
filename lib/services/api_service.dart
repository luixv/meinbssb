import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:meinbssb/services/localization_service.dart'; 
import 'package:meinbssb/data/database_initializer.dart'; 

class ApiService {
  final String baseIp;
  final String port;
  late final String baseUrl;
  late Database _database;
  late Future<void> _databaseInitialization;

  ApiService({this.baseIp = '127.0.0.1', this.port = '3001'}) {
    baseUrl = 'http://$baseIp:$port';
    _databaseInitialization = _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    _database = await initializeDatabase();
  }

  // Public getter to access the database initialization Future
  Future<void> get databaseInitialization => _databaseInitialization;

  Future<dynamic> _makeRequest(Future<http.Response> request) async {
    try {
      final response = await request.timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("Server timeout");
      });

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Return dynamic, can be List or Map
      } else {
        return {"ResultType": 0, "ResultMessage": "Request failed: ${response.statusCode}"};
      }
    } catch (e) {
      debugPrint('Exception: $e');
      return {"ResultType": 0, "ResultMessage": "Network error: $e"};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final String apiUrl = '$baseUrl/LoginMyBSSB';
    final requestBody = jsonEncode({"email": email, "password": password});

    debugPrint('Sending login request to: $apiUrl');
    debugPrint('Request body: $requestBody');

    return _makeRequest(http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    )).then((value) => value is Map<String, dynamic> ? value : {}); // Ensure it's a Map
  }

Duration getCacheExpirationDuration() {
  int validityHours;
  try {
    validityHours = int.parse(LocalizationService.getString('cacheExpiration'));
  } catch (e) {
    debugPrint("Error parsing cacheExpiration: $e");
    validityHours = 24; // Default value
  }
  return Duration(hours: validityHours);
}
  

  Future<Map<String, dynamic>> getPersonId(String email) async {
    final url = Uri.parse('$baseUrl/GetPersonID?Email=$email');
    return _makeRequest(http.get(url)).then((value) => value is Map<String, dynamic> ? value : {}); // Ensure it's a Map
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

    return _makeRequest(http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    )).then((value) => value is Map<String, dynamic> ? value : {}); // Ensure it's a Map
  }

  Future<Map<String, dynamic>> resetPassword(String passNumber) async {
    final String apiUrl = '$baseUrl/PasswordReset/$passNumber';
    final requestBody = jsonEncode({"passNumber": passNumber});
    return _makeRequest(http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    )).then((value) => value is Map<String, dynamic> ? value : {});
  }

Future<Map<String, dynamic>> fetchPassdaten(int personId) async {
    final String apiUrl = '$baseUrl/Passdaten/$personId';
    return _makeRequest(http.get(Uri.parse(apiUrl))).then((value) => value is Map<String, dynamic> ? value : {}); // Ensure it's a Map
  }

Future<Map<String, dynamic>> fetchPassdatenWithString(String passdaten) async {
    final String apiUrl = '$baseUrl/PassdatenString/$passdaten';
    return _makeRequest(http.get(Uri.parse(apiUrl))).then((value) => value is Map<String, dynamic> ? value : {}); // Ensure it's a Map
  }

Future<Uint8List> fetchSchuetzenausweis(int personId) async {
  final String apiUrl = '$baseUrl/Schuetzenausweis/JPG/$personId';
  try {
    final response = await http.get(Uri.parse(apiUrl))
      .timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    throw Exception('Failed to load image: ${response.statusCode}');
  } catch (e) {
    debugPrint('Error fetching Schuetzenausweis: $e');
    throw Exception('Error loading image: $e');
  }
  }

Future<List<dynamic>> fetchAngemeldeteSchulungen(int personId, String abDatum) async {
  // Get validity duration from strings.json
  final validityDuration = getCacheExpirationDuration();

  try {
    // Fetch from network first
    final String apiUrl = '$baseUrl/AngemeldeteSchulungen/$personId/$abDatum';
    final response = await _makeRequest(http.get(Uri.parse(apiUrl)));

    if (response is List<dynamic>) {
      await _cacheSchulungenData(personId, abDatum, response); // Cache the online data
      return response;
    } else if (response is Map<String, dynamic>) {
      if (response['ResultType'] == 0) {
        return [];
      } else {
        if (response.containsKey('schulungen') && response['schulungen'] is List) {
          final schulungen = List<dynamic>.from(response['schulungen']);
          await _cacheSchulungenData(personId, abDatum, schulungen); // Cache the online data
          return schulungen;
        } else {
          debugPrint("Error: 'schulungen' key not found or not a list.");
          return [];
        }
      }
    } else {
      return [];
    }
  } catch (e) {
    // Network error: check cache
    debugPrint('Network error: $e. Checking cache...');
    final cachedData = await _getCachedSchulungenData(personId, abDatum, validityDuration);
    if (cachedData != null) {
      debugPrint('Using cached schulungen data for $personId and $abDatum');
      return cachedData;
    }
    debugPrint('No valid cache found.');
    return []; // Return empty list if no valid cache
  }
}

Future<List<dynamic>?> _getCachedSchulungenData(int personId, String abDatum, Duration validity) async {
  final now = DateTime.now().millisecondsSinceEpoch;
  final result = await _database.query(
    'schulungen',
    where: 'personId = ? AND abDatum = ? AND timestamp > ?',
    whereArgs: [personId, abDatum, now - validity.inMilliseconds],
  );

  if (result.isNotEmpty) {
    return jsonDecode(result.first['schulungenData'] as String) as List<dynamic>;
  }
  return null;
}

Future<void> _cacheSchulungenData(int personId, String abDatum, List<dynamic> schulungenData) async {
  final now = DateTime.now().millisecondsSinceEpoch;
  await _database.insert(
    'schulungen',
    {
      'personId': personId,
      'abDatum': abDatum,
      'schulungenData': jsonEncode(schulungenData),
      'timestamp': now,
    },
    conflictAlgorithm: ConflictAlgorithm.replace, 
  );
}

}