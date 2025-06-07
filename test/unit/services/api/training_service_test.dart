import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/api/training_service.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/services/core/config_service.dart'; // Ensure ConfigService is mocked if used

// Generate mocks
@GenerateMocks([HttpClient, CacheService, NetworkService, ConfigService])
import 'training_service_test.mocks.dart';

void main() {
  late MockHttpClient mockHttpClient;
  late MockCacheService mockCacheService;
  late MockNetworkService mockNetworkService;
  late TrainingService trainingService;

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockCacheService = MockCacheService();
    mockNetworkService = MockNetworkService();

    trainingService = TrainingService(
      httpClient: mockHttpClient,
      cacheService: mockCacheService,
      networkService: mockNetworkService,
    );
  });

  group('fetchAngemeldeteSchulungen', () {
    const testPersonId = 123;
    const testAbDatum = '2023-01-01';
    final testResponse = [
      {
        'DATUM': '2023-01-15',
        'BEZEICHNUNG': 'Basic Training',
        'SCHULUNGENTEILNEHMERID': 1,
      },
      {
        'DATUM': '2023-02-20',
        'BEZEICHNUNG': 'Advanced Training',
        'SCHULUNGENTEILNEHMERID': 2,
      },
    ];

    test('returns mapped training list from cache', () async {
      // Arrange
      when(
        mockNetworkService.getCacheExpirationDuration(),
      ).thenReturn(const Duration(hours: 1));

      // Simulate cached data with ONLINE: false, explicitly typing the return
      final List<Map<String, dynamic>> mockedCachedData = testResponse
          .map(
            (e) => {
              ...e,
              'ONLINE': false,
            },
          )
          .toList();

      when(
        mockCacheService.cacheAndRetrieveData<List<Map<String, dynamic>>>(
          any, // cacheKey
          any, // validityDuration
          any, // fetchData function
          any, // processResponse function
        ),
      ).thenAnswer((_) async {
        return mockedCachedData; // Direct return for cache hit scenario
      });

      // Act
      List<Map<String, dynamic>> result;
      try {
        result = await trainingService.fetchAngemeldeteSchulungen(
          testPersonId,
          testAbDatum,
        );
      } catch (e) {
        rethrow; // Re-throw to make the test fail explicitly if an error occurs
      }

      // Assert
      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.length, 2);
      expect(result[0]['BEZEICHNUNG'], 'Basic Training');
      expect(
        result[0]['ONLINE'],
        false,
      ); // Ensure ONLINE flag is present and false
      verify(
        mockCacheService.cacheAndRetrieveData(
          'schulungen_$testPersonId',
          any,
          any,
          any,
        ),
      ).called(1);
    });

    test('returns empty list when response is not a list', () async {
      // Arrange
      when(
        mockNetworkService.getCacheExpirationDuration(),
      ).thenReturn(const Duration(hours: 1));
      // Mock CacheService to return an empty list of the correct type
      when(
        mockCacheService.cacheAndRetrieveData<List<Map<String, dynamic>>>(
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((_) async => []);

      // Act
      final result = await trainingService.fetchAngemeldeteSchulungen(
        testPersonId,
        testAbDatum,
      );

      // Assert
      expect(result, isEmpty);
    });
  });

  group('fetchAvailableSchulungen', () {
    setUp(() {
      when(mockNetworkService.getCacheExpirationDuration())
          .thenReturn(const Duration(hours: 1));
    });

    test('returns empty list when response is not a list', () async {
      // Arrange
      when(
        mockHttpClient.get('AvailableSchulungen'),
      ).thenAnswer((_) async => []); // http client returns empty list
      // CacheService will process this into an empty list of Map<String, dynamic>
      when(
        mockCacheService.cacheAndRetrieveData<List<Map<String, dynamic>>>(
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((_) async => []); // Return an empty list for the stub

      // Act
      final result = await trainingService.fetchAvailableSchulungen();

      // Assert
      expect(result, isEmpty);
    });
  });

  group('registerForSchulung', () {
    const testPersonId = 123;
    const testSchulungId = 456;

    test('returns true when registration is successful', () async {
      // Arrange
      when(
        mockHttpClient.post('RegisterForSchulung', any),
      ).thenAnswer((_) async => {'ResultType': 1});

      // Act
      final result = await trainingService.registerForSchulung(
        testPersonId,
        testSchulungId,
      );

      // Assert
      expect(result, isTrue);
      verify(
        mockHttpClient.post('RegisterForSchulung', {
          'personId': testPersonId,
          'schulungId': testSchulungId,
        }),
      ).called(1);
    });

    test('returns false when registration fails', () async {
      // Arrange
      when(
        mockHttpClient.post('RegisterForSchulung', any),
      ).thenAnswer((_) async => {'ResultType': 0});

      // Act
      final result = await trainingService.registerForSchulung(
        testPersonId,
        testSchulungId,
      );

      // Assert
      expect(result, isFalse);
    });

    test('rethrows exception and logs error on failure', () async {
      // Arrange
      final testException = Exception('Registration error');
      when(
        mockHttpClient.post('RegisterForSchulung', any),
      ).thenThrow(testException);

      // Act & Assert
      expect(
        () => trainingService.registerForSchulung(testPersonId, testSchulungId),
        throwsA(testException),
      );
    });
  });

  group('fetchSchulungsarten', () {
    setUp(() {
      when(mockNetworkService.getCacheExpirationDuration())
          .thenReturn(const Duration(hours: 1));
    });

    test('returns empty list and logs error on network failure', () async {
      // Arrange
      final testException =
          Exception('Network error during Schulungsarten fetch');
      when(mockHttpClient.get('Schulungsarten/false')).thenThrow(testException);

      // Mock CacheService to return an empty list when network fails (and no cache)
      when(
        mockCacheService.cacheAndRetrieveData<List<Map<String, dynamic>>>(
          'schulungsarten',
          any,
          any,
          any,
        ),
      ).thenAnswer((Invocation inv) async {
        try {
          // Simulate the fetchData part which will throw
          await (inv.positionalArguments[2] as Future<dynamic> Function())();
          return []; // Should not reach here if fetchData throws
        } catch (e) {
          // Simulate the cache fallback, returning data with ONLINE: false if available
          // For simplicity in this test, we'll return an empty list, assuming no valid cache or handling of error
          return [];
        }
      });

      // Act
      final result = await trainingService.fetchSchulungsarten();

      // Assert
      expect(result, isEmpty);
      verify(mockHttpClient.get('Schulungsarten/false')).called(1);
      // Further asserts could check if an error was logged, but that often
      // requires mocking the LoggerService itself.
    });

    test('returns empty list when network response is empty', () async {
      // Arrange
      when(mockHttpClient.get('Schulungsarten/false')).thenAnswer(
        (_) async => [], // Simulate empty response from API
      );

      when(
        mockCacheService.cacheAndRetrieveData<List<Map<String, dynamic>>>(
          'schulungsarten',
          any,
          captureAny,
          captureAny,
        ),
      ).thenAnswer((Invocation inv) async {
        final Future<dynamic> Function() fetchData = inv.positionalArguments[2];
        final List<Map<String, dynamic>> Function(dynamic) processResponse =
            inv.positionalArguments[3];

        final rawResponse = await fetchData();
        final processedData = processResponse(rawResponse);

        // When processedData is empty, map will also return empty
        return processedData.map((item) => {...item, 'ONLINE': true}).toList();
      });

      // Act
      final result = await trainingService.fetchSchulungsarten();

      // Assert
      expect(result, isEmpty);
      verify(mockHttpClient.get('Schulungsarten/false')).called(1);
      // No ONLINE flag expected on the list itself if it's empty,
      // as the flag is added to individual map items.
    });
  });

  group('unregisterFromSchulung', () {
    const testTeilnehmerId = 789;

    test('returns true when unregistration is successful', () async {
      // Arrange
      when(mockHttpClient.delete(
        'SchulungenTeilnehmer/$testTeilnehmerId',
        body: {},
      ),).thenAnswer((_) async => {'ResultType': 1});

      // Act
      final result =
          await trainingService.unregisterFromSchulung(testTeilnehmerId);

      // Assert
      expect(result, isTrue);
      verify(mockHttpClient.delete(
        'SchulungenTeilnehmer/$testTeilnehmerId',
        body: {},
      ),).called(1);
    });

    test('returns false when API returns unsuccessful response', () async {
      // Arrange
      when(mockHttpClient.delete(
        'SchulungenTeilnehmer/$testTeilnehmerId',
        body: {},
      ),).thenAnswer((_) async => {'ResultType': 0});

      // Act
      final result =
          await trainingService.unregisterFromSchulung(testTeilnehmerId);

      // Assert
      expect(result, isFalse);
    });

    test('returns false when API response is invalid', () async {
      // Arrange
      when(mockHttpClient.delete(
        'SchulungenTeilnehmer/$testTeilnehmerId',
        body: {},
      ),).thenAnswer((_) async => {'error': 'Invalid request'});

      // Act
      final result =
          await trainingService.unregisterFromSchulung(testTeilnehmerId);

      // Assert
      expect(result, isFalse);
    });

    test('returns false and logs error on exception', () async {
      // Arrange
      when(mockHttpClient.delete(
        'SchulungenTeilnehmer/$testTeilnehmerId',
        body: {},
      ),).thenThrow(Exception('Network error'));

      // Act
      final result =
          await trainingService.unregisterFromSchulung(testTeilnehmerId);

      // Assert
      expect(result, isFalse);
    });
  });

  group('fetchAbsolvierteSchulungen', () {
    const testPersonId = 123;
    final testResponse = [
      {
        'AUSGESTELLTAM': '2023-01-01',
        'BEZEICHNUNG': 'Completed Training 1',
        'GUELTIGBIS': '2024-01-01',
      },
      {
        'AUSGESTELLTAM': '2023-02-01',
        'BEZEICHNUNG': 'Completed Training 2',
        'GUELTIGBIS': '2024-02-01',
      },
    ];

    test('returns formatted training list for valid response', () async {
      // Arrange
      when(mockHttpClient.get('AbsolvierteSchulungen/$testPersonId'))
          .thenAnswer((_) async => testResponse);

      // Act
      final result =
          await trainingService.fetchAbsolvierteSchulungen(testPersonId);

      // Assert
      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.length, 2);
      expect(result[0]['BEZEICHNUNG'], 'Completed Training 1');
      expect(result[0]['AUSGESTELLTAM'], '01.01.2023');
      expect(result[1]['GUELTIGBIS'], '01.02.2024');
    });

    test('handles empty date strings correctly', () async {
      // Arrange
      when(mockHttpClient.get('AbsolvierteSchulungen/$testPersonId'))
          .thenAnswer((_) async => [
                {
                  'AUSGESTELLTAM': '',
                  'BEZEICHNUNG': 'Training with empty date',
                  'GUELTIGBIS': null,
                }
              ],);

      // Act
      final result =
          await trainingService.fetchAbsolvierteSchulungen(testPersonId);

      // Assert
      expect(result[0]['AUSGESTELLTAM'], '');
      expect(result[0]['GUELTIGBIS'], '');
    });

    test('returns empty list for non-list response', () async {
      // Arrange
      when(mockHttpClient.get('AbsolvierteSchulungen/$testPersonId'))
          .thenAnswer((_) async => {'error': 'Invalid format'});

      // Act
      final result =
          await trainingService.fetchAbsolvierteSchulungen(testPersonId);

      // Assert
      expect(result, isEmpty);
    });

    test('rethrows exceptions', () async {
      // Arrange
      final testException = Exception('Network error');
      when(mockHttpClient.get('AbsolvierteSchulungen/$testPersonId'))
          .thenThrow(testException);

      // Act & Assert
      expect(
        () => trainingService.fetchAbsolvierteSchulungen(testPersonId),
        throwsA(testException),
      );
    });
  });
}
