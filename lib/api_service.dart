import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async'; // Add this import for TimeoutException

class ApiService {
  static const String _baseIp = '127.0.0.1';
  static const String _port = '3001';
  static const String _baseUrl = 'http://$_baseIp:$_port';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final String apiUrl = '$_baseUrl/LoginMyBSSB';
    final requestBody = jsonEncode({"email": email, "password": password});

    try {
      debugPrint('Sending login request to: $apiUrl');
      debugPrint('Request body: $requestBody');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      ).timeout(Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("Server timeout"); // Now this will work
      });

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"ResultType": 0, "ResultMessage": "Login fehlgeschlagen"};
      }
    } catch (e) {
      debugPrint('Exception: $e');
      return {"ResultType": 0, "ResultMessage": "Netzwerkfehler"};
    }
  }

  static Future<Map<String, dynamic>> fetchPassdaten(int personId) async {
    final String apiUrl = '$_baseUrl/Passdaten/$personId';

    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Passdaten Error: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      debugPrint('Exception: $e');
      return {};
    }
  }

  static Future<List<dynamic>> fetchAngemeldeteSchulungen(int personId, String abDatum) async {
    final String apiUrl = '$_baseUrl/AngemeldeteSchulungen/$personId/$abDatum';

    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('AngemeldeteSchulungen Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Exception: $e');
      return [];
    }
  }
}