// Project: Mein BSSB
// Filename: http_client.dart
// Author: Luis Mandel / NTT DATA

import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '/services/logger_service.dart';

class HttpClient {
  HttpClient({
    required this.baseUrl,
    required this.serverTimeout,
    http.Client? client, // Add optional client parameter
  }) : _client = client ?? http.Client(); // Use provided client or default

  final String baseUrl;
  final int serverTimeout;
  final http.Client _client; // Private client instance

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final String apiUrl = '$baseUrl/$endpoint';
    final requestBody = jsonEncode(body);

    LoggerService.logInfo('Sending POST request to: $apiUrl');
    LoggerService.logInfo('Request body: $requestBody');

    return _makeRequest(
      _client.post(
        // Use the private _client
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      ),
    );
  }

  Future<dynamic> get(String endpoint) async {
    final String apiUrl = '$baseUrl/$endpoint';

    LoggerService.logInfo('Sending GET request to: $apiUrl');

    return _makeRequest(
      _client.get(Uri.parse(apiUrl)),
    ); // Use the private _client
  }

  Future<Uint8List> getBytes(String endpoint) async {
    final String apiUrl = '$baseUrl/$endpoint';

    LoggerService.logInfo('Sending GET bytes request to: $apiUrl');

    return _makeBytesRequest(
      _client.get(Uri.parse(apiUrl)),
    ); // Use the private _client
  }

  Future<dynamic> _makeRequest(Future<http.Response> request) async {
    try {
      final response = await request.timeout(
        Duration(seconds: serverTimeout),
        onTimeout: () {
          throw TimeoutException('Server timeout');
        },
      );

      LoggerService.logInfo('Response status: ${response.statusCode}');
      LoggerService.logInfo('Response body http_client: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Request failed: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.logError('Exception in http_client: $e');
      rethrow;
    }
  }

  Future<Uint8List> _makeBytesRequest(Future<http.Response> request) async {
    try {
      final response = await request.timeout(
        Duration(seconds: serverTimeout),
        onTimeout: () {
          throw TimeoutException('Server timeout');
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.logError('Error fetching bytes in http_client: $e');
      rethrow;
    }
  }
}
