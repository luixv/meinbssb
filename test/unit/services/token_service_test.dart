// test/unit/services/token_service_test.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:meinbssb/services/token_service.dart';
import 'package:meinbssb/services/config_service.dart';
import 'package:meinbssb/services/cache_service.dart';

// Generate mocks
@GenerateMocks([
  ConfigService,
  CacheService,
])
import 'token_service_test.mocks.dart';

void main() {
  group('TokenService', () {
    late TokenService tokenService;
    late MockConfigService mockConfigService;
    late MockCacheService mockCacheService;

    const String testUsername = 'testuser';
    const String testPassword = 'testpass';
    const String testToken = 'test-auth-token-12345';
    const String cachedToken = 'cached-token-67890';

    setUp(() {
      mockConfigService = MockConfigService();
      mockCacheService = MockCacheService();

      // Setup default config service responses
      when(mockConfigService.getString('usernameWebUser'))
          .thenReturn(testUsername);
      when(mockConfigService.getString('passwordWebUser'))
          .thenReturn(testPassword);

      tokenService = TokenService(
        configService: mockConfigService,
        cacheService: mockCacheService,
      );
    });

    group('requestToken', () {
      test('should fetch and return new token successfully', () async {
        // Arrange
        final mockServer = await HttpServer.bind('localhost', 0);
        final serverUrl = 'http://localhost:${mockServer.port}';

        when(mockConfigService.getString('tokenServerURL'))
            .thenReturn(serverUrl);

        mockServer.listen((request) async {
          if (request.method == 'POST') {
            final responseBody = jsonEncode({'Token': testToken});
            request.response
              ..statusCode = 200
              ..headers.contentType = ContentType.json
              ..write(responseBody);
            await request.response.close();
          }
        });

        when(mockCacheService.setString(any, any)).thenAnswer((_) async {});

        // Act
        final result = await tokenService.requestToken();

        // Clean up
        await mockServer.close();

        // Assert
        expect(result, equals(testToken));
        verify(mockCacheService.setString('authToken', testToken)).called(1);
        verify(mockConfigService.getString('tokenServerURL')).called(1);
        verify(mockConfigService.getString('usernameWebUser')).called(1);
        verify(mockConfigService.getString('passwordWebUser')).called(1);
      });

      test('should return empty string when server returns non-200 status',
          () async {
        // Arrange
        final mockServer = await HttpServer.bind('localhost', 0);
        final serverUrl = 'http://localhost:${mockServer.port}';

        when(mockConfigService.getString('tokenServerURL'))
            .thenReturn(serverUrl);

        mockServer.listen((request) async {
          request.response
            ..statusCode = 401
            ..write('{"error": "Invalid credentials"}');
          await request.response.close();
        });

        // Act
        final result = await tokenService.requestToken();

        // Clean up
        await mockServer.close();

        // Assert
        expect(result, equals(''));
        verifyNever(mockCacheService.setString(any, any));
      });

      test('should handle missing config values gracefully', () async {
        // Arrange
        when(mockConfigService.getString('tokenServerURL')).thenReturn('');
        when(mockConfigService.getString('usernameWebUser')).thenReturn('');
        when(mockConfigService.getString('passwordWebUser')).thenReturn('');

        // Act
        final result = await tokenService.requestToken();

        // Assert
        expect(result, equals(''));
      });

      test('should return empty string when network error occurs', () async {
        // Arrange
        when(mockConfigService.getString('tokenServerURL'))
            .thenReturn('http://nonexistent-server:9999');

        // Act
        final result = await tokenService.requestToken();

        // Assert
        expect(result, equals(''));
      });
    });

    group('getAuthToken', () {
      test('should return cached token when available', () async {
        // Arrange
        when(mockCacheService.getString('authToken'))
            .thenAnswer((_) async => cachedToken);

        // Act
        final result = await tokenService.getAuthToken();

        // Assert
        expect(result, equals(cachedToken));
        verify(mockCacheService.getString('authToken')).called(1);
      });

      test('should fetch new token when cache is empty', () async {
        // Arrange
        final mockServer = await HttpServer.bind('localhost', 0);
        final serverUrl = 'http://localhost:${mockServer.port}';

        when(mockConfigService.getString('tokenServerURL'))
            .thenReturn(serverUrl);
        when(mockCacheService.getString('authToken'))
            .thenAnswer((_) async => null);

        mockServer.listen((request) async {
          final responseBody = jsonEncode({'Token': testToken});
          request.response
            ..statusCode = 200
            ..headers.contentType = ContentType.json
            ..write(responseBody);
          await request.response.close();
        });

        when(mockCacheService.setString(any, any)).thenAnswer((_) async {});

        // Act
        final result = await tokenService.getAuthToken();

        // Clean up
        await mockServer.close();

        // Assert
        expect(result, equals(testToken));
        verify(mockCacheService.getString('authToken')).called(1);
        verify(mockCacheService.setString('authToken', testToken)).called(1);
      });

      test('should fetch new token when cached token is empty string',
          () async {
        // Arrange
        final mockServer = await HttpServer.bind('localhost', 0);
        final serverUrl = 'http://localhost:${mockServer.port}';

        when(mockConfigService.getString('tokenServerURL'))
            .thenReturn(serverUrl);
        when(mockCacheService.getString('authToken'))
            .thenAnswer((_) async => '');

        mockServer.listen((request) async {
          final responseBody = jsonEncode({'Token': testToken});
          request.response
            ..statusCode = 200
            ..headers.contentType = ContentType.json
            ..write(responseBody);
          await request.response.close();
        });

        when(mockCacheService.setString(any, any)).thenAnswer((_) async {});

        // Act
        final result = await tokenService.getAuthToken();

        // Clean up
        await mockServer.close();

        // Assert
        expect(result, equals(testToken));
        verify(mockCacheService.setString('authToken', testToken)).called(1);
      });
    });

    group('clearToken', () {
      test('should clear token from cache', () async {
        // Arrange
        when(mockCacheService.remove('authToken')).thenAnswer((_) async {});

        // Act
        await tokenService.clearToken();

        // Assert
        verify(mockCacheService.remove('authToken')).called(1);
      });
    });

    group('JSON response parsing', () {
      test('should handle malformed JSON response', () async {
        // Arrange
        final mockServer = await HttpServer.bind('localhost', 0);
        final serverUrl = 'http://localhost:${mockServer.port}';

        when(mockConfigService.getString('tokenServerURL'))
            .thenReturn(serverUrl);

        mockServer.listen((request) async {
          request.response
            ..statusCode = 200
            ..write('invalid json');
          await request.response.close();
        });

        // Act
        final result = await tokenService.requestToken();

        // Clean up
        await mockServer.close();

        // Assert
        expect(result, equals(''));
        verifyNever(mockCacheService.setString(any, any));
      });

      test('should handle missing Token field in JSON response', () async {
        // Arrange
        final mockServer = await HttpServer.bind('localhost', 0);
        final serverUrl = 'http://localhost:${mockServer.port}';

        when(mockConfigService.getString('tokenServerURL'))
            .thenReturn(serverUrl);

        mockServer.listen((request) async {
          final responseBody =
              jsonEncode({'message': 'success', 'data': 'some data'});
          request.response
            ..statusCode = 200
            ..headers.contentType = ContentType.json
            ..write(responseBody);
          await request.response.close();
        });

        // Act
        final result = await tokenService.requestToken();

        // Clean up
        await mockServer.close();

        // Assert
        expect(result, equals(''));
      });
    });

    group('Request verification', () {
      test('should send POST request to correct endpoint', () async {
        // Arrange
        final mockServer = await HttpServer.bind('localhost', 0);
        final serverUrl = 'http://localhost:${mockServer.port}';

        when(mockConfigService.getString('tokenServerURL'))
            .thenReturn(serverUrl);

        String? receivedMethod;
        String? receivedPath;
        String? contentType;

        mockServer.listen((request) async {
          receivedMethod = request.method;
          receivedPath = request.uri.path;
          contentType = request.headers.contentType?.mimeType;

          final responseBody = jsonEncode({'Token': testToken});
          request.response
            ..statusCode = 200
            ..headers.contentType = ContentType.json
            ..write(responseBody);
          await request.response.close();
        });

        when(mockCacheService.setString(any, any)).thenAnswer((_) async {});

        // Act
        await tokenService.requestToken();

        // Give the server a moment to process
        await Future.delayed(const Duration(milliseconds: 100));

        // Clean up
        await mockServer.close();

        // Assert
        expect(receivedMethod, equals('POST'));
        expect(receivedPath, equals('/'));
        expect(contentType, equals('multipart/form-data'));
      });
    });
  });
}
