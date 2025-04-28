import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:meinbssb/services/api/api_service.dart';
import 'package:meinbssb/services/http_client.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:meinbssb/services/network_service.dart';
import 'package:meinbssb/services/image_service.dart';
import 'package:meinbssb/services/api/user_service.dart';
import 'package:meinbssb/services/api/training_service.dart';

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

  group('delegation to UserService', () {
    late MockUserService mockUserService;

    setUp(() {
      mockUserService = MockUserService();
      apiService = ApiService(
        httpClient: mockHttpClient,
        cacheService: mockCacheService,
        networkService: mockNetworkService,
        imageService: mockImageService,
        userService: mockUserService,
      );
    });

    test('fetchPassdaten delegates to UserService', () async {
      const personId = 42;
      final expected = {'foo': 'bar'};
      when(mockUserService.fetchPassdaten(personId)).thenAnswer((_) async => expected);

      final result = await apiService.fetchPassdaten(personId);

      expect(result, expected);
      verify(mockUserService.fetchPassdaten(personId)).called(1);
    });

    test('fetchZweitmitgliedschaften delegates to UserService', () async {
      const personId = 42;
      final expected = [1, 2, 3];
      when(mockUserService.fetchZweitmitgliedschaften(personId)).thenAnswer((_) async => expected);

      final result = await apiService.fetchZweitmitgliedschaften(personId);

      expect(result, expected);
      verify(mockUserService.fetchZweitmitgliedschaften(personId)).called(1);
    });

    test('fetchPassdatenZVE delegates to UserService', () async {
      const passdatenId = 1;
      const personId = 42;
      final expected = ['a', 'b'];
      when(mockUserService.fetchPassdatenZVE(passdatenId, personId)).thenAnswer((_) async => expected);

      final result = await apiService.fetchPassdatenZVE(passdatenId, personId);

      expect(result, expected);
      verify(mockUserService.fetchPassdatenZVE(passdatenId, personId)).called(1);
    });
  });

  group('delegation to TrainingService', () {
    late MockTrainingService mockTrainingService;

    setUp(() {
      mockTrainingService = MockTrainingService();
      apiService = ApiService(
        httpClient: mockHttpClient,
        cacheService: mockCacheService,
        networkService: mockNetworkService,
        imageService: mockImageService,
        trainingService: mockTrainingService,
      );
    });

    test('fetchAngemeldeteSchulungen delegates to TrainingService', () async {
      const personId = 42;
      const abDatum = '2024-01-01';
      final expected = [1, 2];
      when(mockTrainingService.fetchAngemeldeteSchulungen(personId, abDatum)).thenAnswer((_) async => expected);

      final result = await apiService.fetchAngemeldeteSchulungen(personId, abDatum);

      expect(result, expected);
      verify(mockTrainingService.fetchAngemeldeteSchulungen(personId, abDatum)).called(1);
    });

    test('fetchAvailableSchulungen delegates to TrainingService', () async {
      final expected = ['foo', 'bar'];
      when(mockTrainingService.fetchAvailableSchulungen()).thenAnswer((_) async => expected);

      final result = await apiService.fetchAvailableSchulungen();

      expect(result, expected);
      verify(mockTrainingService.fetchAvailableSchulungen()).called(1);
    });

    test('registerForSchulung delegates to TrainingService', () async {
      const personId = 42;
      const schulungId = 99;
      when(mockTrainingService.registerForSchulung(personId, schulungId)).thenAnswer((_) async => true);

      final result = await apiService.registerForSchulung(personId, schulungId);

      expect(result, isTrue);
      verify(mockTrainingService.registerForSchulung(personId, schulungId)).called(1);
    });
  });
} 