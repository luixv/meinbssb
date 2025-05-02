import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:meinbssb/services/api/api_service.dart';
import 'package:meinbssb/services/http_client.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:meinbssb/services/network_service.dart';
import 'package:meinbssb/services/image_service.dart';
import 'package:http/http.dart' as http;

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
      baseIp: '127.0.0.1',
      port: '8080',
      serverTimeout: 5,
    );
  });

  group('fetchPassdaten', () {
    test('returns mapped pass data on success', () async {
      const personId = 1;
      final apiResponse = {
        'PASSNUMMER': '12345',
        'VEREINNR': '67890',
        'NAMEN': 'Mustermann',
        'VORNAME': 'Max',
        'TITEL': 'Dr.',
        'GEBURTSDATUM': '1990-01-01',
        'GESCHLECHT': 'M',
        'VEREINNAME': 'Testverein',
        'PASSDATENID': 101,
        'MITGLIEDSCHAFTID': 202,
        'PERSONID': personId,
      };
      final expectedResult = {
        'PASSNUMMER': '12345',
        'VEREINNR': '67890',
        'NAMEN': 'Mustermann',
        'VORNAME': 'Max',
        'TITEL': 'Dr.',
        'GEBURTSDATUM': '1990-01-01',
        'GESCHLECHT': 'M',
        'VEREINNAME': 'Testverein',
        'PASSDATENID': 101,
        'MITGLIEDSCHAFTID': 202,
        'PERSONID': personId,
      };

      when(mockNetworkService.getCacheExpirationDuration())
          .thenReturn(const Duration(days: 7));
      when(mockHttpClient.get('Passdaten/$personId'))
          .thenAnswer((_) async => apiResponse);
      when(
        mockCacheService.cacheAndRetrieveData(
          'passdaten_$personId',
          const Duration(days: 7),
          any, // Use any for the fetch function
          any, // Use any for the process function.
        ),
      ).thenAnswer((Invocation invocation) async {
        // Simulate the caching behavior.
        final fetchFunction = invocation.positionalArguments[2]
            as Future<Map<String, dynamic>>
                Function(); // Specify the correct return type
        final processFunction = invocation.positionalArguments[3]
            as Map<String, dynamic> Function(dynamic);
        final fetchedData =
            await fetchFunction(); // Await the result of the fetch
        return processFunction(fetchedData); // Process and return
      });

      final result = await apiService.fetchPassdaten(personId);

      expect(result, expectedResult);
      verify(mockNetworkService.getCacheExpirationDuration()).called(1);
      verify(mockHttpClient.get('Passdaten/$personId')).called(1);
      verify(
        mockCacheService.cacheAndRetrieveData(
          'passdaten_$personId',
          const Duration(days: 7),
          any,
          any,
        ),
      ).called(1);
    });

    test('throws and logs error on failure', () async {
      const personId = 1;
      when(mockNetworkService.getCacheExpirationDuration())
          .thenReturn(const Duration(days: 7));
      when(mockHttpClient.get('Passdaten/$personId'))
          .thenThrow(http.ClientException('Failed to fetch pass data'));
      when(
        mockCacheService.cacheAndRetrieveData(
          'passdaten_$personId',
          const Duration(days: 7),
          any,
          any,
        ),
      ).thenAnswer((Invocation invocation) async {
        // Add this stub
        final fetchFunction = invocation.positionalArguments[2]
            as Future<Map<String, dynamic>> Function();
        try {
          await fetchFunction(); // Await the failing fetch
        } catch (e) {
          if (e is http.ClientException) {
            rethrow; // Re-throw the ClientException
          }
          // Optionally handle or rethrow other exceptions if needed.
        }
        return <String,
            dynamic>{}; // Return a valid map, Doesn't matter what is returned
      });

      expect(
        () => apiService.fetchPassdaten(personId),
        throwsA(isA<http.ClientException>()),
      );
      verify(mockHttpClient.get('Passdaten/$personId')).called(1);
    });
  });

  group('fetchPassdatenZVE', () {
    test('returns mapped ZVE data on success', () async {
      const passdatenId = 101;
      const personId = 1;
      final apiResponse = [
        {
          'DISZIPLINNR': 501,
          'VEREINNAME': 'Schützenverein A',
          'DISZIPLIN': 'Luftgewehr',
        },
        {
          'DISZIPLINNR': 502,
          'VEREINNAME': 'Schützenverein B',
          'DISZIPLIN': 'Luftpistole',
        },
      ];
      final expectedResult = [
        {
          'DISZIPLINNR': 501,
          'VEREINNAME': 'Schützenverein A',
          'DISZIPLIN': 'Luftgewehr',
        },
        {
          'DISZIPLINNR': 502,
          'VEREINNAME': 'Schützenverein B',
          'DISZIPLIN': 'Luftpistole',
        },
      ];

      when(mockNetworkService.getCacheExpirationDuration())
          .thenReturn(const Duration(days: 7));
      when(mockHttpClient.get('PassdatenZVE/$passdatenId/$personId'))
          .thenAnswer((_) async => apiResponse);
      when(
        mockCacheService.cacheAndRetrieveData(
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((Invocation invocation) async {
        final fetchFunction = invocation.positionalArguments[2]
            as Future<List<dynamic>> Function();
        final processFunction = invocation.positionalArguments[3]
            as List<dynamic> Function(dynamic);
        final fetchedData = await fetchFunction();
        return processFunction(fetchedData);
      });

      final result = await apiService.fetchPassdatenZVE(passdatenId, personId);

      expect(result, expectedResult);
      verify(mockNetworkService.getCacheExpirationDuration()).called(1);
      verify(mockHttpClient.get('PassdatenZVE/$passdatenId/$personId'))
          .called(1);
      verify(
        mockCacheService.cacheAndRetrieveData(
          any,
          any,
          any,
          any,
        ),
      ).called(1);
    });

    test('throws error on failure', () async {
      const passdatenId = 101;
      const personId = 1;
      when(mockNetworkService.getCacheExpirationDuration())
          .thenReturn(const Duration(days: 7));
      when(mockHttpClient.get('PassdatenZVE/$passdatenId/$personId'))
          .thenThrow(http.ClientException('Failed to fetch ZVE data'));
      when(
        mockCacheService.cacheAndRetrieveData(
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((Invocation invocation) async {
        final fetchFunction = invocation.positionalArguments[2]
            as Future<List<dynamic>> Function();
        try {
          await fetchFunction();
        } catch (e) {
          if (e is http.ClientException) {
            rethrow;
          }
        }
        return <dynamic>[];
      });

      expect(
        () => apiService.fetchPassdatenZVE(passdatenId, personId),
        throwsA(isA<http.ClientException>()),
      );
      verify(mockHttpClient.get('PassdatenZVE/$passdatenId/$personId'))
          .called(1);
    });
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
      when(mockHttpClient.get('UserData/$username'))
          .thenAnswer((_) async => response);

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
      when(mockHttpClient.get('UserData/$username'))
          .thenThrow(Exception('Network error'));

      expect(() => apiService.fetchUserData(username), throwsException);
      verify(mockHttpClient.get('UserData/$username')).called(1);
    });
  });

  group('updateUserData', () {
    test('returns true when update is successful', () async {
      const personId = 1;
      final userData = {'EMAIL': 'new@example.com'};
      when(mockHttpClient.post('UpdateUserData', any))
          .thenAnswer((_) async => {'ResultType': 1});

      final result = await apiService.updateUserData(personId, userData);

      expect(result, isTrue);
      verify(
        mockHttpClient.post('UpdateUserData', {
          'personId': personId,
          ...userData,
        }),
      ).called(1);
    });

    test('returns false when update fails', () async {
      const personId = 1;
      final userData = {'EMAIL': 'fail@example.com'};
      when(mockHttpClient.post('UpdateUserData', any))
          .thenAnswer((_) async => {'ResultType': 0});

      final result = await apiService.updateUserData(personId, userData);

      expect(result, isFalse);
    });

    test('throws and logs error on exception', () async {
      const personId = 1;
      final userData = {'EMAIL': 'fail@example.com'};
      when(mockHttpClient.post('UpdateUserData', any))
          .thenThrow(Exception('Network error'));

      expect(
        () => apiService.updateUserData(personId, userData),
        throwsException,
      );
    });
  });
}
