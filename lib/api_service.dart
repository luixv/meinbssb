import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class ApiService {
  static Future<String> sendPostRequest() async {
    final String apiUrl = 'http://172.23.48.1:3001/mock-register';
    final requestBody = {
      'vorname': 'Luis',
      'nachname': 'Mandel',
      'email': 'luismandel@gmail.com',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return 'Status Code: ${response.statusCode}\nBody: ${response.body}';
      } else {
        debugPrint('HTTP Error: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');
        return 'Error: ${response.statusCode}\nBody: ${response.body}';
      }
    } catch (e) {
      debugPrint('Exception: $e');
      return 'Error: $e';
    }
  }
}
