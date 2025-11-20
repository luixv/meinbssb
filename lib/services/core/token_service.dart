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
  static const String _postgrestTokenCacheKey = 'postgrestAuthToken';

  /// Fetches a new authentication token from the server.
  /// Credentials are stored on the server, so no body is sent with the request.
  Future<String> _fetchToken() async {
    final String tokenServerURL =
        _configService.getString('tokenServerURL') ?? '';

    LoggerService.logInfo(
      'TokenService: Fetching new token from: $tokenServerURL',
    );

    try {
      // Simple POST request without body - credentials are on the server
      final http.Response response = await _httpClient.post(
        Uri.parse(tokenServerURL),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      LoggerService.logInfo(
        'TokenService: Response Status Code: ${response.statusCode}',
      );
      LoggerService.logInfo('TokenService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final String token = jsonResponse['Token'];
        await _cacheService.setString(_tokenCacheKey, token);
        LoggerService.logInfo(
          'TokenService: Successfully fetched and cached new token',
        );
        return token;
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

  /// Fetches a new PostgREST JWT token from the token service.
  /// Credentials are stored on the server, so no body is sent with the request.
  Future<String> _fetchPostgrestToken() async {
    final String tokenServerURL =
        _configService.getString('tokenServerURL') ?? '';
    
    // Replace /token with /postgrest-token endpoint
    final String postgrestTokenURL = tokenServerURL.replaceAll('/token', '/postgrest-token');

    LoggerService.logInfo(
      'TokenService: Fetching new PostgREST JWT token from: $postgrestTokenURL',
    );

    try {
      // Simple POST request without body - credentials are on the server
      final http.Response response = await _httpClient.post(
        Uri.parse(postgrestTokenURL),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      LoggerService.logInfo(
        'TokenService: Response Status Code: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final String token = jsonResponse['token'];
        await _cacheService.setString(_postgrestTokenCacheKey, token);
        LoggerService.logInfo(
          'TokenService: Successfully fetched and cached new PostgREST JWT token',
        );
        return token;
      }
    } catch (e) {
      LoggerService.logError('TokenService: Error fetching PostgREST token: $e');
    }
    return '';
  }

  /// Retrieves the PostgREST JWT token.
  /// It first tries to get the token from the cache.
  /// If not found or empty, it fetches a new one.
  Future<String> _getPostgrestToken() async {
    final cachedToken = await _cacheService.getString(_postgrestTokenCacheKey);
    if (cachedToken != null && cachedToken.isNotEmpty) {
      LoggerService.logInfo('TokenService: Using cached PostgREST JWT token');
      return cachedToken;
    } else {
      LoggerService.logInfo(
        'TokenService: No cached PostgREST JWT token found, fetching new one',
      );
      return await _fetchPostgrestToken();
    }
  }

  /// Public method to get PostgREST JWT token.
  /// This is used by PostgrestService to authenticate database requests.
  Future<String> getPostgrestAuthToken() async {
    return _getPostgrestToken();
  }

  /// Clears the cached PostgREST JWT token.
  Future<void> clearPostgrestToken() async {
    await _cacheService.remove(_postgrestTokenCacheKey);
    LoggerService.logInfo('TokenService: PostgREST JWT token cleared from cache');
  }
}
