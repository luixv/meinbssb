// lib/services/token_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'logger_service.dart';
import 'config_service.dart';
import 'cache_service.dart';

/// A service responsible for managing authentication tokens,
/// including fetching, caching, and providing them.
class TokenService {

  TokenService({
    required ConfigService configService,
    required CacheService cacheService,
    http.Client? client, // Optional HTTP client for token requests
  })  : _configService = configService,
        _cacheService = cacheService,
        _httpClient = client ?? http.Client();
  // Add _client field to hold the injected HTTP client
  final http.Client _httpClient; // Initialize _client here

  final ConfigService _configService;
  final CacheService _cacheService;

  static const String _tokenCacheKey = 'authToken';

  /// Fetches a new authentication token from the server.
  /// This method is responsible for making the actual HTTP request
  /// to the token endpoint.
  Future<String> _fetchToken() async {
    try {
      final loginServiceBase = ConfigService.buildBaseUrlForServer(
        _configService,
        name: 'web',
        protocolKey: 'webProtocol',
      );

      final usernameWebUser = _configService.getString('usernameWebUser') ?? '';
      final passwordWebUser = _configService.getString('passwordWebUser') ?? '';

      final uri = Uri.parse('${loginServiceBase}bssb-token');

      LoggerService.logInfo(
        'TokenService: Fetching token via login service: $uri',
      );

      final response = await _httpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': usernameWebUser,
          'password': passwordWebUser,
        }),
      );

      LoggerService.logInfo(
        'TokenService: Response Status Code: ${response.statusCode}',
      );
      LoggerService.logInfo('TokenService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final String token = jsonResponse['Token'] ?? '';
        if (token.isNotEmpty) {
          await _cacheService.setString(_tokenCacheKey, token);
          LoggerService.logInfo(
            'TokenService: Successfully fetched and cached new token',
          );
          return token;
        }
      }
    } catch (e) {
      LoggerService.logError('TokenService: Error fetching token: $e');
    }
    return '';
  }

  /// Retrieves the authentication token.
  /// It first tries to get the token from the cache.
  /// If not found or empty, it fetches a new one.
  Future<String> _getToken() async {
    final cachedToken = await _cacheService.getString(_tokenCacheKey);
    if (cachedToken != null && cachedToken.isNotEmpty) {
      LoggerService.logInfo('TokenService: Using cached token');
      return cachedToken;
    } else {
      LoggerService.logInfo(
        'TokenService: No cached token found, fetching new one',
      );
      return await _fetchToken();
    }
  }

  /// Public method to request and retrieve the token directly.
  /// This is typically used during login or when a new token is explicitly needed.
  Future<String> requestToken() async {
    final token = await _fetchToken();
    return token;
  }

  /// Clears the cached authentication token.
  Future<void> clearToken() async {
    await _cacheService.remove(_tokenCacheKey);
    LoggerService.logInfo('TokenService: Auth token cleared from cache');
  }

  /// Retrieves the token for internal use by other services (e.g., HttpClient).
  /// This method is intended to be called by `HttpClient` to get a token
  /// for outgoing requests, handling refresh logic internally.
  Future<String> getAuthToken() async {
    return _getToken();
  }
}
