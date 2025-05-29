import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/api/training_service.dart';
import 'package:meinbssb/services/http_client.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:meinbssb/services/network_service.dart';
import 'package:meinbssb/services/config_service.dart'; // Ensure ConfigService is mocked if used

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
        // Debugging print
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

      // Debugging print

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
    final testResponse = [
      {
        'SCHULUNGID': 1,
        'BEZEICHNUNG': 'Basic Training',
        'DATUM': '2023-01-15',
        'ORT': 'Munich',
        'MAXTEILNEHMER': 20,
        'TEILNEHMER': 15,
      },
      {
        'SCHULUNGID': 2,
        'BEZEICHNUNG': 'Advanced Training',
        'DATUM': '2023-02-20',
        'ORT': 'Berlin',
        'MAXTEILNEHMER': 15,
        'TEILNEHMER': 10,
      },
    ];

    setUp(() {
      when(mockNetworkService.getCacheExpirationDuration())
          .thenReturn(const Duration(hours: 1));
    });

    test('returns mapped available trainings', () async {
      // Arrange
      when(mockHttpClient.get('AvailableSchulungen')).thenAnswer(
        (_) async => testResponse,
      ); // HTTP client returns raw data

      // Mock cacheAndRetrieveData to *execute* the fetchData and processResponse functions
      // to simulate a network fetch returning fresh data.
      when(
        mockCacheService.cacheAndRetrieveData<List<Map<String, dynamic>>>(
          'available_schulungen', // Match the key
          any, // validityDuration
          captureAny, // capture fetchData (index 2)
          captureAny, // capture processResponse (index 3)
        ),
      ).thenAnswer((Invocation inv) async {
        final Future<List<Map<String, dynamic>>> Function() fetchData =
            inv.positionalArguments[2];
        final List<Map<String, dynamic>> Function(dynamic) processResponse =
            inv.positionalArguments[3];

        // Simulate CacheService's internal logic: fetch, process, and add ONLINE flag
        final rawResponse =
            await fetchData(); // This will call mockHttpClient.get
        final processedData = processResponse(
          rawResponse,
        ); // This will call _mapAvailableSchulungenResponse

        // Ensure the processed data is a List<Map<String, dynamic>> and add ONLINE: true
        return processedData.map((item) => {...item, 'ONLINE': true}).toList();
      });

      // Act
      List<Map<String, dynamic>> result;
      try {
        result = await trainingService.fetchAvailableSchulungen();
      } catch (e) {
        rethrow; // Re-throw to make the test fail explicitly if an error occurs
      }

      // Debugging print

      // Assert
      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.length, 2);
      expect(result[0]['BEZEICHNUNG'], 'Basic Training');
      expect(result[0]['ORT'], 'Munich');
      expect(result[0]['ONLINE'], true); // Expect ONLINE true from fresh fetch
      verify(mockHttpClient.get('AvailableSchulungen')).called(1);
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
}
