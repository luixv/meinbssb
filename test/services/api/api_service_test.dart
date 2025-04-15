import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;

import '/services/api/api_service.dart';
import '/services/api/user_service.dart';
import '/services/api/training_service.dart';
import '/services/cache_service.dart';
import '/services/http_client.dart';
import '/services/network_service.dart';

@GenerateNiceMocks([
  MockSpec<HttpClient>(),
  MockSpec<CacheService>(),
  MockSpec<NetworkService>(),
  MockSpec<UserService>(),
  MockSpec<TrainingService>(),
])
import 'api_service_test.mocks.dart';

void main() {
  late ApiService apiService;
  late MockHttpClient mockHttpClient;
  late MockCacheService mockCacheService;
  late MockNetworkService mockNetworkService;
  late MockUserService mockUserService;
  late MockTrainingService mockTrainingService;

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockCacheService = MockCacheService();
    mockNetworkService = MockNetworkService();
    mockUserService = MockUserService();
    mockTrainingService = MockTrainingService();

    apiService = ApiService(
      httpClient: mockHttpClient,
      cacheService: mockCacheService,
      networkService: mockNetworkService,
    );
  });

  group('User Data Operations', () {
    test('fetchUserData returns mapped user data', () async {
      final mockResponse = {
        'PERSONID': 1,
        'USERNAME': 'testuser',
        'EMAIL': 'test@example.com',
        'FIRSTNAME': 'Test',
        'LASTNAME': 'User',
      };

      when(mockHttpClient.get('UserData/testuser'))
          .thenAnswer((_) async => mockResponse);

      final result = await apiService.fetchUserData('testuser');

      expect(result, {
        'PERSONID': 1,
        'USERNAME': 'testuser',
        'EMAIL': 'test@example.com',
        'FIRSTNAME': 'Test',
        'LASTNAME': 'User',
      });
    });

    test('updateUserData returns true on success', () async {
      final mockResponse = {'ResultType': 1};
      final userData = {
        'EMAIL': 'new@example.com',
        'FIRSTNAME': 'New',
        'LASTNAME': 'Name',
      };

      when(mockHttpClient.post(
        'UpdateUserData',
        {
          'personId': 1,
          ...userData,
        },
      )).thenAnswer((_) async => mockResponse);

      final result = await apiService.updateUserData(1, userData);
      expect(result, true);
    });
  });

  group('Passdaten Operations', () {
    test('fetchPassdaten delegates to UserService', () async {
      final mockResponse = {
        'PASSNUMMER': '123',
        'VEREINNR': '456',
        'NAMEN': 'Test',
        'VORNAME': 'User',
      };

      when(mockUserService.fetchPassdaten(1))
          .thenAnswer((_) async => mockResponse);

      final result = await apiService.fetchPassdaten(1);
      expect(result, mockResponse);
    });

    test('fetchZweitmitgliedschaften delegates to UserService', () async {
      final mockResponse = [
        {'VEREINID': 1, 'VEREINNAME': 'Club 1'},
        {'VEREINID': 2, 'VEREINNAME': 'Club 2'},
      ];

      when(mockUserService.fetchZweitmitgliedschaften(1))
          .thenAnswer((_) async => mockResponse);

      final result = await apiService.fetchZweitmitgliedschaften(1);
      expect(result, mockResponse);
    });

    test('fetchPassdatenZVE delegates to UserService', () async {
      final mockResponse = [
        {'DISZIPLINNR': 1, 'DISZIPLIN': 'Sport 1', 'VEREINNAME': 'Club 1'},
        {'DISZIPLINNR': 2, 'DISZIPLIN': 'Sport 2', 'VEREINNAME': 'Club 2'},
      ];

      when(mockUserService.fetchPassdatenZVE(1, 1))
          .thenAnswer((_) async => mockResponse);

      final result = await apiService.fetchPassdatenZVE(1, 1);
      expect(result, mockResponse);
    });
  });

  group('Training Operations', () {
    test('fetchAngemeldeteSchulungen delegates to TrainingService', () async {
      final mockResponse = [
        {
          'DATUM': '2024-01-01',
          'BEZEICHNUNG': 'Training 1',
          'SCHULUNGENTEILNEHMERID': 1,
        },
      ];

      when(mockTrainingService.fetchAngemeldeteSchulungen(1, '2024-01-01'))
          .thenAnswer((_) async => mockResponse);

      final result = await apiService.fetchAngemeldeteSchulungen(1, '2024-01-01');
      expect(result, mockResponse);
    });

    test('fetchAvailableSchulungen delegates to TrainingService', () async {
      final mockResponse = [
        {
          'SCHULUNGID': 1,
          'BEZEICHNUNG': 'Available Training',
          'DATUM': '2024-02-01',
          'ORT': 'Location',
          'MAXTEILNEHMER': 10,
          'TEILNEHMER': 5,
        },
      ];

      when(mockTrainingService.fetchAvailableSchulungen())
          .thenAnswer((_) async => mockResponse);

      final result = await apiService.fetchAvailableSchulungen();
      expect(result, mockResponse);
    });

    test('registerForSchulung delegates to TrainingService', () async {
      when(mockTrainingService.registerForSchulung(1, 1))
          .thenAnswer((_) async => true);

      final result = await apiService.registerForSchulung(1, 1);
      expect(result, true);
    });
  });
} 