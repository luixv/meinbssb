import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:meinbssb/services/core/token_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/services/core/cache_service.dart';

// Use GenerateMocks for the services you want to mock
@GenerateMocks([ConfigService, CacheService, http.Client])
import 'token_service_test.mocks.dart';

void main() {
  late MockConfigService mockConfigService;
  late MockCacheService mockCacheService;
  late MockClient mockHttpClient;
  late TokenService tokenService;

  setUp(() {
    mockConfigService = MockConfigService();
    mockCacheService = MockCacheService();
    mockHttpClient = MockClient();

    tokenService = TokenService(
      configService: mockConfigService,
      cacheService: mockCacheService,
      client: mockHttpClient,
    );
  });

  group('TokenService', () {
    test('requestToken fetches and caches token successfully', () async {
      // Arrange
      when(mockConfigService.getString('tokenServerURL'))
          .thenReturn('https://dummy.token.url');
      when(mockConfigService.getString('usernameWebUser')).thenReturn('user1');
      when(mockConfigService.getString('passwordWebUser')).thenReturn('pass1');

      final responseBody = jsonEncode({'Token': 'faketoken123'});
      final streamedResponse = http.StreamedResponse(
        Stream.value(utf8.encode(responseBody)),
        200,
      );

      // mockHttpClient.send expects BaseRequest, so use argThat(isA<http.BaseRequest>())
      when(mockHttpClient.send(argThat(isA<http.BaseRequest>())))
          .thenAnswer((_) async => streamedResponse);

      when(mockCacheService.setString(any, any)).thenAnswer((_) async {});

      // Act
      final token = await tokenService.requestToken();

      // Assert
      expect(token, 'faketoken123');
      verify(mockCacheService.setString('authToken', 'faketoken123')).called(1);
      verify(mockHttpClient.send(argThat(isA<http.BaseRequest>()))).called(1);
    });

    test('requestToken returns empty string on non-200 response', () async {
      when(mockConfigService.getString('tokenServerURL'))
          .thenReturn('https://dummy.token.url');
      when(mockConfigService.getString('usernameWebUser')).thenReturn('user1');
      when(mockConfigService.getString('passwordWebUser')).thenReturn('pass1');

      final streamedResponse = http.StreamedResponse(
        Stream.value(utf8.encode('Unauthorized')),
        401,
      );

      when(mockHttpClient.send(any)).thenAnswer((_) async => streamedResponse);

      final token = await tokenService.requestToken();

      expect(token, '');
      verify(mockHttpClient.send(any)).called(1);
      verifyNever(mockCacheService.setString(any, any));
    });

    test('getAuthToken returns cached token if available', () async {
      when(mockCacheService.getString('authToken'))
          .thenAnswer((_) async => 'cachedtoken');

      final token = await tokenService.getAuthToken();

      expect(token, 'cachedtoken');
      verify(mockCacheService.getString('authToken')).called(1);
      verifyNever(mockHttpClient.send(any));
    });

    test('getAuthToken fetches token if cache is empty', () async {
      when(mockCacheService.getString('authToken')).thenAnswer((_) async => '');
      when(mockConfigService.getString('tokenServerURL'))
          .thenReturn('https://dummy.token.url');
      when(mockConfigService.getString('usernameWebUser')).thenReturn('user1');
      when(mockConfigService.getString('passwordWebUser')).thenReturn('pass1');

      final responseBody = jsonEncode({'Token': 'newtoken123'});
      final streamedResponse = http.StreamedResponse(
        Stream.value(utf8.encode(responseBody)),
        200,
      );

      when(mockHttpClient.send(any)).thenAnswer((_) async => streamedResponse);
      when(mockCacheService.setString(any, any)).thenAnswer((_) async {});

      final token = await tokenService.getAuthToken();

      expect(token, 'newtoken123');
      verify(mockCacheService.getString('authToken')).called(1);
      verify(mockHttpClient.send(any)).called(1);
      verify(mockCacheService.setString('authToken', 'newtoken123')).called(1);
    });

    test('clearToken calls cacheService.remove', () async {
      when(mockCacheService.remove('authToken')).thenAnswer((_) async {});

      await tokenService.clearToken();

      verify(mockCacheService.remove('authToken')).called(1);
    });
  });
}
