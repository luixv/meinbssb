import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/core/token_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/services/core/cache_service.dart';

// Generate mocks
@GenerateMocks([
  http.Client,
  TokenService,
  ConfigService,
  CacheService,
])
import 'http_client_test.mocks.dart';

void main() {
  group('HttpClient', () {
    late HttpClient httpClient;
    late MockClient mockHttpClient;
    late MockTokenService mockTokenService;
    late MockConfigService mockConfigService;
    late MockCacheService mockCacheService;

    const String baseUrl = 'https://api.example.com';
    const int serverTimeout = 30;
    const String authToken = 'test-auth-token';

    setUp(() {
      mockHttpClient = MockClient();
      mockTokenService = MockTokenService();
      mockConfigService = MockConfigService();
      mockCacheService = MockCacheService();

      httpClient = HttpClient(
        baseUrl: baseUrl,
        serverTimeout: serverTimeout,
        tokenService: mockTokenService,
        configService: mockConfigService,
        cacheService: mockCacheService,
        client: mockHttpClient,
      );

      // Default token service setup (can be overridden in specific tests)
      when(mockTokenService.getAuthToken()).thenAnswer((_) async => authToken);
    });

    group('POST requests', () {
      test('should make successful POST request', () async {
        // Arrange
        final responseBody = {'success': true, 'id': 123};
        final response = http.Response(
          jsonEncode(responseBody),
          200,
          request: http.Request('POST', Uri.parse('$baseUrl/users')),
        );

        when(
          mockHttpClient.post(
            Uri.parse('$baseUrl/users'),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: '{"name":"John","email":"john@example.example.com"}',
          ),
        ).thenAnswer((_) async => response);

        // Act
        final result = await httpClient.post('users', {
          'name': 'John',
          'email': 'john@example.example.com',
        });

        // Assert
        expect(result, equals(responseBody));
        verify(mockTokenService.getAuthToken()).called(1);
        verify(
          mockHttpClient.post(
            Uri.parse('$baseUrl/users'),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: '{"name":"John","email":"john@example.example.com"}',
          ),
        ).called(1);
      });

      test('should handle POST request with 204 status', () async {
        // Arrange
        final response = http.Response(
          '', // Empty body for 204
          204,
          request: http.Request('POST', Uri.parse('$baseUrl/users')),
        );

        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => response);

        // Act
        final result = await httpClient.post('users', {'name': 'John'});

        // Assert: Expect null for empty body with 204 status
        expect(result, isNull); // Changed from equals({}) to isNull
        verify(mockTokenService.getAuthToken()).called(1);
        verify(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1);
      });

      test('should retry POST request on 401 error', () async {
        // Arrange
        final unauthorizedResponse = http.Response('Unauthorized', 401);
        final successResponse = http.Response('{"success": true}', 200);
        const newToken = 'new-auth-token';

        // Use a counter for sequential responses from mockHttpClient
        int postCallCount = 0;
        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async {
          postCallCount++;
          if (postCallCount == 1) {
            return unauthorizedResponse;
          }
          return successResponse;
        });

        // Use a counter for sequential responses from mockTokenService
        int tokenGetCallCount = 0;
        when(mockTokenService.getAuthToken()).thenAnswer((_) async {
          tokenGetCallCount++;
          if (tokenGetCallCount == 1) {
            return authToken;
          }
          return newToken;
        });

        // Mock clearToken and requestToken to return Future<void> correctly
        when(mockTokenService.clearToken()).thenAnswer((_) async {});
        when(mockTokenService.requestToken()).thenAnswer((_) async => newToken);

        // Act
        final result = await httpClient.post('users', {'name': 'John'});

        // Assert
        expect(result, equals({'success': true}));
        verify(mockTokenService.clearToken()).called(1);
        verify(mockTokenService.requestToken()).called(1);
        verify(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(2);
        verify(mockTokenService.getAuthToken())
            .called(2); // Called twice, once for initial, once for retry
      });

      test('should throw exception when retry fails', () async {
        // Arrange
        final unauthorizedResponse = http.Response('Unauthorized', 401);

        // Use a counter for sequential responses from mockHttpClient
        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async {
          return unauthorizedResponse;
        });

        // Use a counter for sequential responses from mockTokenService
        int tokenGetCallCount = 0;
        when(mockTokenService.getAuthToken()).thenAnswer((_) async {
          tokenGetCallCount++;
          if (tokenGetCallCount == 1) {
            return authToken;
          }
          return 'mock_new_token'; // Doesn't matter, requestToken returns empty
        });

        when(mockTokenService.clearToken()).thenAnswer((_) async {});
        // Simulate token refresh failure
        when(mockTokenService.requestToken()).thenAnswer((_) async => '');

        // Act & Assert
        await expectLater(
          () => httpClient.post('users', {'name': 'John'}),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains(
                        'HttpClient: Token refresh failed for request: 401, body: Unauthorized',
                      ), // Updated predicate
            ),
          ),
        );

        // Verifications after the exception has been caught by expectLater
        verify(mockTokenService.getAuthToken()).called(1); // Initial call only
        verify(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1); // Only the initial POST call should happen
        verify(mockTokenService.clearToken()).called(1);
        verify(mockTokenService.requestToken()).called(1);
      });

      test('should throw exception on non-200/204/401/403 status codes',
          () async {
        // Arrange
        final response = http.Response('Server Error', 500);

        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => response);

        // Act & Assert
        await expectLater(
          () => httpClient.post('users', {'name': 'John'}),
          throwsA(isA<Exception>()),
        );

        // These should be called if httpClient.post is invoked
        verify(mockTokenService.getAuthToken()).called(1);
        verify(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1);
      });
    });

    group('PUT requests', () {
      test('should make successful PUT request', () async {
        // Arrange
        final responseBody = {'updated': true};
        final response = http.Response(jsonEncode(responseBody), 200);

        when(
          mockHttpClient.put(
            Uri.parse('$baseUrl/users/123'),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: '{"name":"Jane"}',
          ),
        ).thenAnswer((_) async => response);

        // Act
        final result = await httpClient.put('users/123', {'name': 'Jane'});

        // Assert
        expect(result, equals(responseBody));
        verify(mockTokenService.getAuthToken()).called(1);
        verify(
          mockHttpClient.put(
            Uri.parse('$baseUrl/users/123'),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: '{"name":"Jane"}',
          ),
        ).called(1);
      });
    });

    group('DELETE requests', () {
      test('should make successful DELETE request without body', () async {
        // Arrange
        final response = http.Response('', 204); // Empty body for 204

        when(
          mockHttpClient.delete(
            Uri.parse('$baseUrl/users/123'),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: null,
          ),
        ).thenAnswer((_) async => response);

        // Act
        final result = await httpClient.delete('users/123');

        // Assert: Expect null for empty body with 204 status
        expect(result, isNull); // Changed from equals({}) to isNull
        verify(mockTokenService.getAuthToken()).called(1);
        verify(
          mockHttpClient.delete(
            Uri.parse('$baseUrl/users/123'),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: null,
          ),
        ).called(1);
      });

      test('should make successful DELETE request with body', () async {
        // Arrange
        final responseBody = {'deleted': true};
        final response = http.Response(jsonEncode(responseBody), 200);

        when(
          mockHttpClient.delete(
            Uri.parse('$baseUrl/users/123'),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: '{"reason":"test"}',
          ),
        ).thenAnswer((_) async => response);

        // Act
        final result =
            await httpClient.delete('users/123', body: {'reason': 'test'});

        // Assert
        expect(result, equals(responseBody));
        verify(mockTokenService.getAuthToken()).called(1);
        verify(
          mockHttpClient.delete(
            Uri.parse('$baseUrl/users/123'),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: '{"reason":"test"}',
          ),
        ).called(1);
      });
    });

    group('GET requests', () {
      test('should make successful GET request', () async {
        // Arrange
        final responseBody = {'users': []};
        final response = http.Response(jsonEncode(responseBody), 200);

        when(
          mockHttpClient.get(
            Uri.parse('$baseUrl/users'),
            headers: {'Authorization': 'Bearer $authToken'},
          ),
        ).thenAnswer((_) async => response);

        // Act
        final result = await httpClient.get('users');

        // Assert
        expect(result, equals(responseBody));
        verify(mockTokenService.getAuthToken()).called(1);
        verify(
          mockHttpClient.get(
            Uri.parse('$baseUrl/users'),
            headers: {'Authorization': 'Bearer $authToken'},
          ),
        ).called(1);
      });

      test('should handle GET request timeout', () async {
        // Arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenThrow(
          TimeoutException('Request timeout', const Duration(seconds: 30)),
        );

        // Act & Assert
        await expectLater(
          () => httpClient.get('users'),
          throwsA(isA<TimeoutException>()),
        );
        // These should be called if httpClient.get is invoked
        verify(mockTokenService.getAuthToken()).called(1);
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
      });
    });

    group('GET bytes requests', () {
      test('should make successful GET bytes request', () async {
        // Arrange
        final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        final response = http.Response.bytes(bytes, 200);

        when(
          mockHttpClient.get(
            Uri.parse('$baseUrl/files/download/123'),
            headers: {'Authorization': 'Bearer $authToken'},
          ),
        ).thenAnswer((_) async => response);

        // Act
        final result = await httpClient.getBytes('files/download/123');

        // Assert
        expect(result, equals(bytes));
        verify(mockTokenService.getAuthToken()).called(1);
        verify(
          mockHttpClient.get(
            Uri.parse('$baseUrl/files/download/123'),
            headers: {'Authorization': 'Bearer $authToken'},
          ),
        ).called(1);
      });

      test(
          'should handle supported GET method in bytes request', // Renamed test
          () async {
        // Arrange: This test verifies that getBytes works normally for a GET.
        when(
          mockHttpClient.get(
            any,
            headers: anyNamed('headers'),
          ),
        ).thenAnswer(
          (_) async => http.Response.bytes(Uint8List(0), 200),
        ); // Stub the get call

        // Act & Assert
        await expectLater(
          () async {
            await httpClient.getBytes('files/download/123');
          },
          returnsNormally, // Expecting no exception here, as the method call is valid
        );
        // Add verifications for what actually happens during the call
        verify(mockTokenService.getAuthToken()).called(1);
        verify(
          mockHttpClient.get(
            Uri.parse('$baseUrl/files/download/123'),
            headers: {'Authorization': 'Bearer $authToken'},
          ),
        ).called(1);
      });

      test('should retry GET bytes request on 401 error', () async {
        // Arrange
        final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        final unauthorizedResponse = http.Response('Unauthorized', 401);
        final successResponse = http.Response.bytes(bytes, 200);
        const newToken = 'new-auth-token';

        // Use a counter for sequential responses from mockHttpClient
        int getCallCount = 0;
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async {
          getCallCount++;
          if (getCallCount == 1) {
            return unauthorizedResponse;
          }
          return successResponse;
        });

        // Use a counter for sequential responses from mockTokenService
        int tokenGetCallCount = 0;
        when(mockTokenService.getAuthToken()).thenAnswer((_) async {
          tokenGetCallCount++;
          if (tokenGetCallCount == 1) {
            return authToken;
          }
          return newToken;
        });

        // Mock clearToken and requestToken to return Future<void> correctly
        when(mockTokenService.clearToken()).thenAnswer((_) async {});
        when(mockTokenService.requestToken()).thenAnswer((_) async => newToken);

        // Act
        final result = await httpClient.getBytes('files/download/123');

        // Assert
        expect(result, equals(bytes));
        verify(mockTokenService.clearToken()).called(1);
        verify(mockTokenService.requestToken()).called(1);
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(2);
        verify(mockTokenService.getAuthToken()).called(2); // Called twice
      });

      test('should throw exception when bytes request fails', () async {
        // Arrange
        final response = http.Response('Not Found', 404);

        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        // Act & Assert
        await expectLater(
          () => httpClient.getBytes('files/download/123'),
          throwsA(isA<Exception>()),
        );
        // These should be called if httpClient.getBytes is invoked
        verify(mockTokenService.getAuthToken()).called(1);
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
      });
    });

    group('Error handling', () {
      test('should handle network errors', () async {
        // Arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        await expectLater(
          () => httpClient.get('users'),
          throwsA(isA<Exception>()),
        );
        // These should be called if httpClient.get is invoked
        verify(mockTokenService.getAuthToken()).called(1);
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
      });

      test('should handle JSON decode errors', () async {
        // Arrange
        final response = http.Response('invalid json', 200);

        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        // Act & Assert
        await expectLater(
          () => httpClient.get('users'),
          throwsA(isA<FormatException>()),
        );
        // These should be called if httpClient.get is invoked
        verify(mockTokenService.getAuthToken()).called(1);
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
      });

      test('should not retry after failed retry attempt', () async {
        // Arrange
        final unauthorizedResponse = http.Response('Unauthorized', 401);

        // Use a counter for sequential responses from mockHttpClient
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async {
          // Only one HTTP call is made because token refresh fails
          return unauthorizedResponse;
        });

        // Use a counter for sequential responses from mockTokenService
        int tokenGetCallCount = 0;
        when(mockTokenService.getAuthToken()).thenAnswer((_) async {
          tokenGetCallCount++;
          if (tokenGetCallCount == 1) {
            return authToken;
          }
          // This path should ideally not be hit if requestToken returns empty and throws.
          // However, for completeness of mocking, we ensure a different token is returned.
          // But the key is that requestToken() returns empty string.
          return 'mock_new_token';
        });

        when(mockTokenService.clearToken()).thenAnswer((_) async {});
        // Simulate token refresh failure
        when(mockTokenService.requestToken()).thenAnswer((_) async => '');

        // Act & Assert
        await expectLater(
          () => httpClient.get('users'),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains(
                        'HttpClient: Token refresh failed for request: 401, body: Unauthorized',
                      ), // Updated predicate
            ),
          ),
        );

        // Verify that the request was made once (original call only)
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
        // getAuthToken should be called only once for the initial request attempt,
        // because the token refresh fails before a second request can be made.
        verify(mockTokenService.getAuthToken()).called(1); // <-- CORRECTED TO 1
        verify(mockTokenService.clearToken()).called(1);
        verify(mockTokenService.requestToken()).called(1);
      });
    });

    group('Authorization handling', () {
      test('should add authorization header to all requests', () async {
        // Arrange
        final response = http.Response('{"success": true}', 200);

        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        // Act
        await httpClient.get('users');

        // Assert
        verify(mockTokenService.getAuthToken()).called(1);
        verify(
          mockHttpClient.get(
            any,
            headers: argThat(
              containsPair(
                'Authorization',
                'Bearer $authToken',
              ), // Using containsPair for map
              named: 'headers',
            ),
          ),
        ).called(1);
      });

      test('should handle 403 errors similar to 401', () async {
        // Arrange
        final forbiddenResponse = http.Response('Forbidden', 403);
        final successResponse = http.Response('{"success": true}', 200);
        const newToken = 'new-auth-token';

        // Use a counter for sequential responses from mockHttpClient
        int getCallCount = 0;
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async {
          getCallCount++;
          if (getCallCount == 1) {
            return forbiddenResponse;
          }
          return successResponse;
        });

        // Use a counter for sequential responses from mockTokenService
        int tokenGetCallCount = 0;
        when(mockTokenService.getAuthToken()).thenAnswer((_) async {
          tokenGetCallCount++;
          if (tokenGetCallCount == 1) {
            return authToken;
          }
          return newToken;
        });

        when(mockTokenService.clearToken()).thenAnswer((_) async {});
        when(mockTokenService.requestToken()).thenAnswer((_) async => newToken);

        // Act
        final result = await httpClient.get('users');

        // Assert
        expect(result, equals({'success': true}));
        verify(mockTokenService.clearToken()).called(1);
        verify(mockTokenService.requestToken()).called(1);
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(2);
        verify(mockTokenService.getAuthToken()).called(2); // Called twice
      });
    });

    group('URL construction', () {
      test('should construct correct URLs for endpoints', () async {
        // Arrange
        final response = http.Response('{"success": true}', 200);

        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        // Act
        await httpClient.get('users/123/profile');

        // Assert
        verify(mockTokenService.getAuthToken()).called(1);
        verify(
          mockHttpClient.get(
            Uri.parse('$baseUrl/users/123/profile'),
            headers: anyNamed('headers'),
          ),
        ).called(1);
      });
    });
  });
}
