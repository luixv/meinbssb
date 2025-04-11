// Project: Mein BSSB
// Filename: http_client.dart
// Author: Luis Mandel / NTT DATA

import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class HttpClient {
  final String baseUrl;
  final int serverTimeout;

  HttpClient({required this.baseUrl, required this.serverTimeout});

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final String apiUrl = '$baseUrl/$endpoint';
    final requestBody = jsonEncode(body);

    debugPrint('Sending POST request to: $apiUrl');
    debugPrint('Request body: $requestBody');

    return _makeRequest(
      http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      ),
    );
  }

  Future<dynamic> get(String endpoint) async {
    final String apiUrl = '$baseUrl/$endpoint';

    debugPrint('Sending GET request to: $apiUrl');

    return _makeRequest(http.get(Uri.parse(apiUrl)));
  }

  Future<dynamic> getBytes(String endpoint) async {
    final String apiUrl = '$baseUrl/$endpoint';

    debugPrint('Sending GET bytes request to: $apiUrl');

    return _makeBytesRequest(http.get(Uri.parse(apiUrl)));
  }

  Future<dynamic> _makeRequest(Future<http.Response> request) async {
    try {
      final response = await request.timeout(
        Duration(seconds: serverTimeout),
        onTimeout: () {
          throw TimeoutException("Server timeout");
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body http_client: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Request failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('Exception in http_client: $e');
      rethrow;
    }
  }

  Future<Uint8List> _makeBytesRequest(Future<http.Response> request) async {
    try {
      final response = await request.timeout(
        Duration(seconds: serverTimeout),
        onTimeout: () {
          throw TimeoutException("Server timeout");
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching bytes in http_client: $e');
      rethrow;
    }
  }
}
