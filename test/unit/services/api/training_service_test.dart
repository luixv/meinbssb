import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/api/training_service.dart';
import 'package:meinbssb/services/http_client.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:meinbssb/services/network_service.dart';
import 'package:meinbssb/services/config_service.dart';

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
      when(
        mockCacheService.cacheAndRetrieveData<Map<String, dynamic>>(
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((_) async => {'data': testResponse});

      // Act
      final result = await trainingService.fetchAngemeldeteSchulungen(
        testPersonId,
        testAbDatum,
      );

      // Assert
      expect(result, isA<List<dynamic>>());
      expect(result.length, 2);
      expect(result[0]['BEZEICHNUNG'], 'Basic Training');
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
      when(
        mockCacheService.cacheAndRetrieveData<Map<String, dynamic>>(
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((_) async => {'data': []});

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
      when(
        mockCacheService.cacheAndRetrieveData<Map<String, dynamic>>(
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((_) async => {'data': testResponse}); // Add this stub
    });

    test('returns mapped available trainings', () async {
      // Arrange
      when(mockNetworkService.getCacheExpirationDuration())
          .thenReturn(const Duration(hours: 1));
      when(
        mockCacheService.cacheAndRetrieveData<Map<String, dynamic>>(
          'available_schulungen', // Match the key
          any,
          any,
          any,
        ),
      ).thenAnswer((_) async {
        // Simulate a cache miss or expired cache by returning null for cached data
        // and then returning the testResponse when the fetch function is called.
        final fetchFunction =
            // ignore: no_wildcard_variable_uses
            _.positionalArguments[2] as Future<List<dynamic>> Function()?;
        return {'data': await fetchFunction?.call() ?? []};
      });
      when(mockHttpClient.get('AvailableSchulungen'))
          .thenAnswer((_) async => testResponse);

      // Act
      final result = await trainingService.fetchAvailableSchulungen();

      // Assert
      expect(result, isA<List<dynamic>>());
      expect(result.length, 2);
      expect(result[0]['BEZEICHNUNG'], 'Basic Training');
      expect(result[0]['ORT'], 'Munich');
      verify(mockHttpClient.get('AvailableSchulungen')).called(1);
    });

    test('returns empty list when response is not a list', () async {
      // Arrange
      when(
        mockHttpClient.get('AvailableSchulungen'),
      ).thenAnswer((_) async => []);
      when(
        mockCacheService.cacheAndRetrieveData<Map<String, dynamic>>(
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer(
        (_) async => {'data': []},
      ); // Add this stub for the empty list case

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
