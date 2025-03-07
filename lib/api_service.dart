import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class ApiService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final String apiUrl = 'http://172.23.48.1:3001/LoginMyBSSB';
    final requestBody = jsonEncode({"email": email, "password": password});

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Login Error: ${response.statusCode}');
        return {"ResultType": 0, "ResultMessage": "Login fehlgeschlagen"};
      }
    } catch (e) {
      debugPrint('Exception: $e');
      return {"ResultType": 0, "ResultMessage": "Netzwerkfehler"};
    }
  }

  static Future<Map<String, dynamic>> fetchPassdaten(int personId) async {
    final String apiUrl = 'http://172.23.48.1:3001/Passdaten/$personId';

    try {
      final response = await http.get(Uri.parse(apiUrl));

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
}
