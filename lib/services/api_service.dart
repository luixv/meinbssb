import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:meinbssb/services/localization_service.dart'; 
import 'package:meinbssb/services/database_service.dart';


class ApiService {
  final String baseIp;
  final String port;
  late final String baseUrl;
  final DatabaseService _databaseService = DatabaseService();

  ApiService({this.baseIp = '127.0.0.1', this.port = '3001'}) {
    baseUrl = 'http://$baseIp:$port';
  }

Future<dynamic> _makeRequest(Future<http.Response> request) async {
    try {
      final response = await request.timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("Server timeout");
      });

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
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
    final validityDuration = getCacheExpirationDuration();
    try {
      final cachedImage = await _databaseService.getCachedSchuetzenausweis(personId, validityDuration);
      if (cachedImage != null) {
        debugPrint('Using cached Schuetzenausweis');
        return cachedImage;
      }

      final String apiUrl = '$baseUrl/Schuetzenausweis/JPG/$personId';
      final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final imageData = response.bodyBytes;
        await _databaseService.cacheSchuetzenausweis(personId, imageData, DateTime.now().millisecondsSinceEpoch);
        return imageData;
      }
      throw Exception('Failed to load image: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error fetching Schuetzenausweis: $e');
      try {
        final cachedImage = await _databaseService.getCachedSchuetzenausweis(personId, validityDuration);
        if (cachedImage != null){
          return cachedImage;
        }
        throw Exception('Error loading cached image: $e');
      } catch (cacheError) {
        debugPrint('Cache error: $cacheError');
        throw Exception('Error loading image: $e');
      }
    }
  }



  Future<List<dynamic>> fetchAngemeldeteSchulungen(int personId, String abDatum) async {
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
        await _databaseService.cacheSchulungen(
          personId,
          abDatum,
          jsonEncode(schulungen),
          DateTime.now().millisecondsSinceEpoch,
        );
      }

      final cachedResults = await _databaseService.getCachedSchulungen(personId, abDatum, validityDuration);
      List<dynamic> cachedData = [];

      cachedData = cachedResults.map((result){
        final data = result['schulungenData'] as String?;
        if(data != null){
          return jsonDecode(data);
        }
        return null;
      }).where((element) => element != null).expand((element) => element).toList();
    
      debugPrint('Using ${cachedData.length} cached schulungen');

      return schulungen.isNotEmpty ? schulungen : cachedData;

    } catch (e) {
      debugPrint('Network error: $e');
      try {
        final cachedResults = await _databaseService.getCachedSchulungen(personId, abDatum, validityDuration);
        List<dynamic> cachedData = [];

        cachedData = cachedResults.map((result){
          final data = result['schulungenData'] as String?;
          if(data != null){
            return jsonDecode(data);
          }
          return null;
        }).where((element) => element != null).expand((element) => element).toList();
      
        debugPrint('Using ${cachedData.length} cached schulungen');
        return cachedData;
      } catch (cacheError) {
        debugPrint('Cache error: $cacheError');
        return [];
      }
    }
  }


}