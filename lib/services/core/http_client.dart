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
    required CacheService cacheService,
    http.Client? client,
  })  : _client = client ?? http.Client(),
        _tokenService = tokenService,
        _configService = configService;

  final String baseUrl;
  final int serverTimeout;
  final http.Client _client;
  final TokenService _tokenService;
  final ConfigService _configService;

  // Method to make HTTP requests with token handling and retry logic
  Future<dynamic> _makeRequest(
    String method,
    String url,
    Map<String, String>? headers,
    dynamic body, {
    bool retry = true, // Added retry parameter for consistency
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
          response = await http.Response.fromStream(streamedResponse).timeout(
            Duration(
              seconds: serverTimeout,
            ),
          );
        }
      } else {
        throw Exception('Unsupported HTTP method: $method');
      }

      // Check for CORS preflight response and handle token expiration
      if (response.statusCode == 204 || response.statusCode == 200) {
        return _parseResponse(response);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        if (retry) {
          LoggerService.logWarning(
            'HttpClient: Token expired, attempting to refresh for request via TokenService. URL: $url, Status: ${response.statusCode}',
          );
          await _tokenService
              .clearToken(); // Tell TokenService to clear its cached token
          final newToken = await _tokenService
              .requestToken(); // Request a new token from TokenService

          if (newToken.isEmpty) {
            // If token refresh failed
            throw Exception(
              'HttpClient: Token refresh failed for request: ${response.statusCode}, body: ${response.body}',
            );
          }
          // Retry the request with the new token
          return _makeRequest(method, url, headers, body, retry: false);
        } else {
          throw Exception(
            'HttpClient: Request failed after token refresh: ${response.statusCode}, body: ${response.body}',
          );
        }
      } else {
        throw Exception(
          'HttpClient: Request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      LoggerService.logError('HttpClient: Error in _makeRequest: $e');
      rethrow; // Rethrow the original exception
    }
  }

  dynamic _parseResponse(http.Response response) {
    if (response.body.isEmpty) {
      LoggerService.logInfo('HttpClient: Empty response body');
      return null;
    }
    try {
      final decoded = jsonDecode(response.body);

      return decoded;
    } catch (e) {
      LoggerService.logError('HttpClient: Error parsing response: $e');
      // Rethrow the FormatException directly
      rethrow;
    }
  }

  // Method to make HTTP requests to get bytes with token handling
  // This method now largely mirrors _makeRequest for consistency,
  // but specifically handles byte responses.
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
        response = await _client
            .get(Uri.parse(url), headers: requestHeaders)
            .timeout(Duration(seconds: serverTimeout)); // Added timeout
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
              'HttpClient: Token refresh failed for bytes request: ${response.statusCode}, body: ${response.body}',
            );
          }
          return _makeBytesRequest(method, url, headers, retry: false);
        } else {
          throw Exception(
            'HttpClient: Request failed after token refresh: ${response.statusCode}, body: ${response.body}',
          );
        }
      } else {
        throw Exception(
          'HttpClient: Failed to load bytes: ${response.statusCode}',
        );
      }
    } catch (e) {
      LoggerService.logError(
        'HttpClient: Error fetching bytes in _makeBytesRequest: $e',
      );
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

  Future<dynamic> get(
    String endpoint, {
    String? overrideBaseUrl,
  }) async {
    final url = overrideBaseUrl != null 
        ? '$overrideBaseUrl/$endpoint'
        : '$baseUrl/$endpoint';
    return _makeRequest('GET', url, null, null);
  }

    Future<dynamic> get2(String endpoint) async {
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
    // Using _makeBytesRequest specifically for byte responses, maintaining its unique behavior
    return _makeBytesRequest('GET', apiUrl, null);
  }
}
