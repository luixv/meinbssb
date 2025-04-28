import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:meinbssb/services/api/api_service.dart';
import 'package:meinbssb/services/http_client.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:meinbssb/services/network_service.dart';
import 'package:meinbssb/services/image_service.dart';

import 'api_service_test.mocks.dart';

@GenerateMocks([HttpClient, CacheService, NetworkService, ImageService])
void main() {
  late ApiService apiService;
  late MockHttpClient mockHttpClient;
  late MockCacheService mockCacheService;
  late MockNetworkService mockNetworkService;
  late MockImageService mockImageService;

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockCacheService = MockCacheService();
    mockNetworkService = MockNetworkService();
    mockImageService = MockImageService();

    apiService = ApiService(
      httpClient: mockHttpClient,
      cacheService: mockCacheService,
      networkService: mockNetworkService,
      imageService: mockImageService,
    );
  });

  group('fetchUserData', () {
    test('returns mapped user data on success', () async {
      const username = 'testuser';
      final response = {
        'PERSONID': 1,
        'USERNAME': 'testuser',
        'EMAIL': 'test@example.com',
        'FIRSTNAME': 'Test',
        'LASTNAME': 'User',
      };
      when(mockHttpClient.get('UserData/$username')).thenAnswer((_) async => response);

      final result = await apiService.fetchUserData(username);

      expect(result, {
        'PERSONID': 1,
        'USERNAME': 'testuser',
        'EMAIL': 'test@example.com',
        'FIRSTNAME': 'Test',
        'LASTNAME': 'User',
      });
      verify(mockHttpClient.get('UserData/$username')).called(1);
    });

    test('throws and logs error on failure', () async {
      const username = 'testuser';
      when(mockHttpClient.get('UserData/$username')).thenThrow(Exception('Network error'));

      expect(() => apiService.fetchUserData(username), throwsException);
      verify(mockHttpClient.get('UserData/$username')).called(1);
    });
  });

  group('updateUserData', () {
    test('returns true when update is successful', () async {
      const personId = 1;
      final userData = {'EMAIL': 'new@example.com'};
      when(mockHttpClient.post('UpdateUserData', any)).thenAnswer((_) async => {'ResultType': 1});

      final result = await apiService.updateUserData(personId, userData);

      expect(result, isTrue);
      verify(mockHttpClient.post('UpdateUserData', {
        'personId': personId,
        ...userData,
      })).called(1);
    });

    test('returns false when update fails', () async {
      const personId = 1;
      final userData = {'EMAIL': 'fail@example.com'};
      when(mockHttpClient.post('UpdateUserData', any)).thenAnswer((_) async => {'ResultType': 0});

      final result = await apiService.updateUserData(personId, userData);

      expect(result, isFalse);
    });

    test('throws and logs error on exception', () async {
      const personId = 1;
      final userData = {'EMAIL': 'fail@example.com'};
      when(mockHttpClient.post('UpdateUserData', any)).thenThrow(Exception('Network error'));

      expect(() => apiService.updateUserData(personId, userData), throwsException);
    });
  });

} 