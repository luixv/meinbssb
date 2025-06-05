// lib/services/http_client.dart
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'logger_service.dart';
import 'config_service.dart'; 
import 'cache_service.dart'; 
import 'token_service.dart'; 

class HttpClient {
  HttpClient({
    required this.baseUrl,
    required this.serverTimeout,
    required TokenService tokenService, 
    required ConfigService configService, 
    required CacheService
        cacheService, // Keep to pass to TokenService, or for specific cache clear actions if needed
    http.Client? client,
  })  : _client = client ?? http.Client(),
        _tokenService = tokenService,
        _configService = configService;

  final String baseUrl;
  final int serverTimeout;
  final http.Client _client;
  final TokenService _tokenService; 
  final ConfigService _configService; 

  // Method to make HTTP requests with token handling
  Future<dynamic> _makeRequest(
    String method,
    String url,
    Map<String, String>? headers,
    dynamic body, {
    bool retry = true,
  }) async {
    try {
      // Get the token from the TokenService
      final token = await _tokenService.getAuthToken();

      // Add Authorization header
      final requestHeaders = headers ?? {};
      requestHeaders['Authorization'] = 'Bearer $token';

      http.Response response;
      if (method == 'POST') {
        response = await _client
            .post(
              Uri.parse(url),
              headers: requestHeaders,
              body: body,
            )
            .timeout(Duration(seconds: serverTimeout));
      } else if (method == 'PUT') {
        response = await _client
            .put(
              Uri.parse(url),
              headers: requestHeaders,
              body: body,
            )
            .timeout(Duration(seconds: serverTimeout));
      } else if (method == 'DELETE') {
        response = await _client
            .delete(
              Uri.parse(url),
              headers: requestHeaders,
              body: body,
            )
            .timeout(Duration(seconds: serverTimeout));
      } else if (method == 'GET') {
        if (body == null) {
          response = await _client
              .get(Uri.parse(url), headers: requestHeaders)
              .timeout(Duration(seconds: serverTimeout));
        } else {
          // Handle GET with body using http.Request
          requestHeaders['Content-Length'] =
              utf8.encode(body).length.toString();

          final request = http.Request('GET', Uri.parse(url));
          request.headers.addAll(requestHeaders);
          request.body = body;

          LoggerService.logInfo('HttpClient: Sending GET Request to: $url');
          LoggerService.logInfo('HttpClient: Headers: $requestHeaders');
          LoggerService.logInfo('HttpClient: Body: $body');

          final streamedResponse = await _client.send(request);
          response =
              await http.Response.fromStream(streamedResponse).timeout(Duration(
            seconds: serverTimeout,
          ),);
        }
      } else {
        throw Exception('Unsupported HTTP method: $method');
      }

      LoggerService.logInfo(
        'HttpClient: Response status: ${response.statusCode}, url: ${response.request?.url}',
      );
      LoggerService.logInfo('HttpClient: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // For 204 No Content, body might be empty. Only decode if body is not empty.
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body);
        }
        return {}; // Return empty map for 204 or empty body
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Handle token expiration/invalidation
        if (retry) {
          LoggerService.logWarning(
              'HttpClient: Token expired, attempting to refresh via TokenService',);
          await _tokenService
              .clearToken(); // Tell TokenService to clear its cached token
          final newToken = await _tokenService
              .requestToken(); // Request a new token from TokenService

          if (newToken.isEmpty) {
            // If token refresh failed
            throw Exception(
                'HttpClient: Token refresh failed: ${response.statusCode}, body: ${response.body}',);
          }
          // Retry the request once with the new token
          // Pass original headers as Authorization will be re-added by _makeRequest
          return _makeRequest(
            method,
            url,
            headers,
            body,
            retry: false,
          );
        } else {
          throw Exception(
            'HttpClient: Request failed after token refresh: ${response.statusCode}, body: ${response.body}',
          );
        }
      } else {
        throw Exception(
          'HttpClient: Request failed: ${response.statusCode}, body: ${response.body}',
        );
      }
    } catch (e) {
      LoggerService.logError('HttpClient: Exception in _makeRequest: $e');
      rethrow;
    }
  }

  // Method to make HTTP requests to get bytes with token handling
  Future<Uint8List> _makeBytesRequest(
    String method,
    String url,
    Map<String, String>? headers, {
    bool retry = true,
  }) async {
    try {
      final token =
          await _tokenService.getAuthToken(); // Get the token from TokenService
      final requestHeaders = headers ?? {};
      requestHeaders['Authorization'] = 'Bearer $token';

      http.Response response;

      if (method == 'GET') {
        response = await _client.get(Uri.parse(url), headers: requestHeaders);
      } else {
        throw Exception('Method not supported for byte requests');
      }

      LoggerService.logInfo(
        'HttpClient: Response status: ${response.statusCode}, url: ${response.request?.url}',
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        if (retry) {
          LoggerService.logWarning(
            'HttpClient: Token expired, attempting to refresh for bytes request via TokenService',
          );
          await _tokenService
              .clearToken(); // Tell TokenService to clear its cached token
          final newToken = await _tokenService
              .requestToken(); // Request a new token from TokenService

          if (newToken.isEmpty) {
            // If token refresh failed
            throw Exception(
                'HttpClient: Token refresh failed for bytes request: ${response.statusCode}, body: ${response.body}',);
          }
          return _makeBytesRequest(method, url, headers, retry: false);
        } else {
          throw Exception(
            'HttpClient: Request failed after token refresh: ${response.statusCode}, body: ${response.body}',
          );
        }
      } else {
        throw Exception(
            'HttpClient: Failed to load bytes: ${response.statusCode}',);
      }
    } catch (e) {
      LoggerService.logError(
          'HttpClient: Error fetching bytes in _makeBytesRequest: $e',);
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final String apiUrl = '$baseUrl/$endpoint';
    final requestBody = jsonEncode(body);

    LoggerService.logInfo('HttpClient: Sending POST request to: $apiUrl');
    LoggerService.logInfo('HttpClient: Request body: $requestBody');

    return _makeRequest(
      'POST',
      apiUrl,
      {
        'Content-Type': 'application/json',
      },
      requestBody,
    );
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final String apiUrl = '$baseUrl/$endpoint';
    final requestBody = jsonEncode(body);

    LoggerService.logInfo('HttpClient: Sending PUT request to: $apiUrl');
    LoggerService.logInfo('HttpClient: Request body: $requestBody');

    return _makeRequest(
      'PUT',
      apiUrl,
      {
        'Content-Type': 'application/json',
      },
      requestBody,
    );
  }

  Future<dynamic> delete(String endpoint, {Map<String, dynamic>? body}) async {
    final String apiUrl = '$baseUrl/$endpoint';
    final requestBody = body != null ? jsonEncode(body) : null;

    LoggerService.logInfo('HttpClient: Sending DELETE request to: $apiUrl');
    if (requestBody != null) {
      LoggerService.logInfo('HttpClient: Request body: $requestBody');
    }

    return _makeRequest(
      'DELETE',
      apiUrl,
      {
        'Content-Type': 'application/json',
      },
      requestBody,
    );
  }

  Future<dynamic> get(String endpoint) async {
    final String apiUrl = '$baseUrl/$endpoint';
    LoggerService.logInfo('HttpClient: Sending GET request to: $apiUrl');
    return _makeRequest('GET', apiUrl, null, null);
  }

  Future<dynamic> getWithBody(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final String apiUrl = '$baseUrl/$endpoint';
    LoggerService.logWarning(
      'HttpClient: Sending GET request with a body to: $apiUrl. This is not standard HTTP practice.',
    );

    final baseIP = _configService.getString('apiBaseServer', 'api') ??
        'webintern.bssb.bayern';
    final port = _configService.getString('apiPort', 'api') ?? '56400';
    final host = '$baseIP:$port';

    final requestBody = jsonEncode(body);

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Content-Length': utf8.encode(requestBody).length.toString(),
      'Host': host,
    };

    LoggerService.logInfo('HttpClient: Sending GET to: $apiUrl');
    LoggerService.logInfo('HttpClient: Headers: $headers');
    LoggerService.logInfo('HttpClient: Body: $requestBody');

    return _makeRequest('GET', apiUrl, headers, requestBody);
  }

  Future<Uint8List> getBytes(String endpoint) async {
    final String apiUrl = '$baseUrl/$endpoint';
    LoggerService.logInfo('HttpClient: Sending GET bytes request to: $apiUrl');
    return _makeBytesRequest('GET', apiUrl, null);
  }
}
