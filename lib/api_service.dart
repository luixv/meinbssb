import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';

class ApiService {
  static const String _baseIp = '127.0.0.1'; // Change to your server's IP if needed
  static const String _port = '3001';
  static const String _baseUrl = 'http://$_baseIp:$_port';

  static Future<Map<String, dynamic>> _makeRequest(
      Future<http.Response> request) async {
    try {
      final response = await request.timeout(const Duration(seconds: 10),
          onTimeout: () {
        throw TimeoutException("Server timeout");
      });

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "ResultType": 0,
          "ResultMessage": "Request failed: ${response.statusCode}"
        };
      }
    } catch (e) {
      debugPrint('Exception: $e');
      return {"ResultType": 0, "ResultMessage": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final String apiUrl = '$_baseUrl/LoginMyBSSB';
    final requestBody = jsonEncode({"email": email, "password": password});

    debugPrint('Sending login request to: $apiUrl');
    debugPrint('Request body: $requestBody');

    return _makeRequest(http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    ));
  }

  static Future<Map<String, dynamic>> fetchPassdaten(int personId) async {
    final String apiUrl = '$_baseUrl/Passdaten/$personId';

    return _makeRequest(http.get(Uri.parse(apiUrl)));
  }

  static Future<Map<String, dynamic>> getPersonId(String email) async {
    final url = Uri.parse('$_baseUrl/GetPersonID?Email=$email');
    return _makeRequest(http.get(url));
  }

  static Future<List<dynamic>> fetchAngemeldeteSchulungen(
      int personId, String abDatum) async {
    final String apiUrl = '$_baseUrl/AngemeldeteSchulungen/$personId/$abDatum';

    final response = await _makeRequest(http.get(Uri.parse(apiUrl)));

    if (response['ResultType'] == 0) {
      return []; // Return empty list on error
    } else {
      if (response.containsKey('schulungen') && response['schulungen'] is List) {
        return List<dynamic>.from(response['schulungen']);
      } else {
        debugPrint("Error: 'schulungen' key not found or not a list.");
        return []; // Return empty list on unexpected structure
      }
    }
  }

  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String passNumber,
    required String email,
    required String birthDate,
    required String zipCode,
  }) async {
    final String apiUrl = '$_baseUrl/RegisterMyBSSB';
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
    ));
  }

  static Future<Map<String, dynamic>> fetchPassdatenWithString(String passdaten) async {
      final String apiUrl = '$_baseUrl/PassdatenString/$passdaten';

      return _makeRequest(http.get(Uri.parse(apiUrl)));
  }

  


static Future<Map<String, dynamic>> resetPassword(String passNumber) async {
    final String apiUrl = '$_baseUrl/PasswordReset/$passNumber';
    final requestBody = jsonEncode({
      "passNumber": passNumber,
    });
    return _makeRequest(http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    ));
  }


}