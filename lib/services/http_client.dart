// In lib/services/http_client.dart

import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '/services/logger_service.dart';
import '/services/config_service.dart';
import '/services/cache_service.dart';

class HttpClient {
  HttpClient({
    required this.baseUrl,
    required this.serverTimeout,
    required ConfigService configService,
    required CacheService cacheService,
    http.Client? client,
  })  : _client = client ?? http.Client(),
        _configService = configService,
        _cacheService = cacheService;

  final String baseUrl;
  final int serverTimeout;
  final ConfigService _configService;
  final http.Client _client;
  final CacheService _cacheService;
  static const String _tokenCacheKey = 'authToken';

  // Helper method to get the token
  Future<String> _fetchToken() async {
    final String tokenServerURL =
        _configService.getString('tokenServerURL') ?? '';

    final usernameWebUser = _configService.getString('usernameWebUser') ?? '';
    final passwordWebUser = _configService.getString('passwordWebUser') ?? '';

    final Map<String, String> body = {
      'username': usernameWebUser,
      'password': passwordWebUser,
    };

    // Create a multipart request.
    var request = http.MultipartRequest('POST', Uri.parse(tokenServerURL));
    body.forEach((key, value) {
      request.fields[key] = value;
    });

    LoggerService.logInfo('Fetching new token from: $tokenServerURL');

    try {
      final http.StreamedResponse streamedResponse = await request.send();
      final http.Response response =
          await http.Response.fromStream(streamedResponse);

      LoggerService.logInfo('Response Status Code: ${response.statusCode}');
      LoggerService.logInfo('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final String token = jsonResponse['Token'];
        await _cacheService.setString(_tokenCacheKey, token);
        LoggerService.logInfo('Successfully fetched and cached new token');
        return token;
      }
    } catch (e) {
      LoggerService.logInfo('POST Request Error: $e');
    }
    return '';
  }

  // Helper method to get token from cache or fetch if needed
  Future<String> _getToken() async {
    final cachedToken = await _cacheService.getString(_tokenCacheKey);
    if (cachedToken != null && cachedToken.isNotEmpty) {
      LoggerService.logInfo('Using cached token');
      return cachedToken;
    } else {
      LoggerService.logInfo('No cached token found, fetching new one');
      return await _fetchToken();
    }
  }

  // Public method to get and cache the token (for login)
  Future<String> requestToken() async {
    final token = await _fetchToken();
    return token;
  }

  // Method to make HTTP requests with token handling
  Future<dynamic> _makeRequest(
    String method,
    String url,
    Map<String, String>? headers,
    dynamic body, {
    bool retry = true,
  }) async {
    try {
      final token = await _getToken(); // Get the token
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
        // Added DELETE method handling
        response = await _client
            .delete(
              Uri.parse(url),
              headers: requestHeaders,
              body: body, // DELETE requests can also have a body
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

          LoggerService.logInfo('Sending GET Request to: $url');
          LoggerService.logInfo('Headers: $headers');
          LoggerService.logInfo('Body: $body');

          final streamedResponse = await _client.send(request);
          response = await http.Response.fromStream(streamedResponse);
          //.timeout(Duration(seconds: serverTimeout)); // Timeout is handled by send() now
        }
      } else {
        throw Exception('Unsupported HTTP method: $method');
      }

      LoggerService.logInfo(
        'Response status: ${response.statusCode}, url: ${response.request?.url}',
      );
      LoggerService.logInfo('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 204 No Content is common for successful DELETE
        return jsonDecode(response.body);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Handle token expiration/invalidation
        if (retry) {
          LoggerService.logWarning('Token expired, attempting to refresh');
          await _cacheService.remove(_tokenCacheKey); //remove invalid token
          final newToken = await _fetchToken();

          await _cacheService.setString(
            _tokenCacheKey,
            newToken,
          ); // Cache the new token
          return _makeRequest(
            method,
            url,
            requestHeaders,
            body,
            retry: false,
          ); // Retry the request once
        } else {
          throw Exception(
            'Request failed after token refresh: ${response.statusCode}, body: ${response.body}',
          );
        }
      } else {
        throw Exception(
          'Request failed: ${response.statusCode}, body: ${response.body}',
        );
      }
    } catch (e) {
      LoggerService.logError('Exception in _makeRequest: $e');
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
      final token = await _getToken(); // Get the token
      final requestHeaders = headers ?? {};
      requestHeaders['Authorization'] = 'Bearer $token';

      http.Response response;

      if (method == 'GET') {
        response = await _client.get(Uri.parse(url), headers: requestHeaders);
      } else {
        throw Exception('Method not supported for byte requests');
      }

      LoggerService.logInfo(
        'Response status: ${response.statusCode}, url: ${response.request?.url}',
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        if (retry) {
          LoggerService.logWarning(
            'Token expired, attempting to refresh for bytes request',
          );
          await _cacheService.remove(_tokenCacheKey);
          final newToken = await _fetchToken();
          await _cacheService.setString(_tokenCacheKey, newToken);
          return _makeBytesRequest(method, url, requestHeaders, retry: false);
        } else {
          throw Exception(
            'Request failed after token refresh: ${response.statusCode}, body: ${response.body}',
          );
        }
      } else {
        throw Exception('Failed to load bytes: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.logError('Error fetching bytes in _makeBytesRequest: $e');
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final String apiUrl = '$baseUrl/$endpoint';
    final requestBody = jsonEncode(body);

    LoggerService.logInfo('Sending POST request to: $apiUrl');
    LoggerService.logInfo('Request body: $requestBody');

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

    LoggerService.logInfo('Sending PUT request to: $apiUrl');
    LoggerService.logInfo('Request body: $requestBody');

    return _makeRequest(
      'PUT',
      apiUrl,
      {
        'Content-Type': 'application/json',
      },
      requestBody,
    );
  }

  // New DELETE method
  Future<dynamic> delete(String endpoint, {Map<String, dynamic>? body}) async {
    final String apiUrl = '$baseUrl/$endpoint';
    final requestBody = body != null ? jsonEncode(body) : null;

    LoggerService.logInfo('Sending DELETE request to: $apiUrl');
    if (requestBody != null) {
      LoggerService.logInfo('Request body: $requestBody');
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
    LoggerService.logInfo('Sending GET request to: $apiUrl');
    return _makeRequest('GET', apiUrl, null, null);
  }

  // New method to send GET request with a body (non-standard but supported by your _makeRequest)
  Future<dynamic> getWithBody(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final String apiUrl = '$baseUrl/$endpoint';
    LoggerService.logWarning(
      'Sending GET request with a body to: $apiUrl. This is not standard HTTP practice.',
    );

    final baseIP = _configService.getString('apiBaseServer', 'api') ??
        'webintern.bssb.bayern';
    final port = _configService.getString('apiPort', 'api') ?? '56400';
    final host = '$baseIP:$port';

    final requestBody = jsonEncode(body);

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Content-Length': utf8.encode(requestBody).length.toString(),
      'Host': host, //'webintern.bssb.bayern:56400'
    };

    LoggerService.logInfo('Sending GET to: $apiUrl');
    LoggerService.logInfo('Headers: $headers');
    LoggerService.logInfo('Body: $requestBody');

    return _makeRequest('GET', apiUrl, headers, requestBody);
  }

  Future<Uint8List> getBytes(String endpoint) async {
    final String apiUrl = '$baseUrl/$endpoint';
    LoggerService.logInfo('Sending GET bytes request to: $apiUrl');
    return _makeBytesRequest('GET', apiUrl, null);
  }
}
