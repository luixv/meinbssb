import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/api/training_service.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/services/core/network_service.dart';

@GenerateMocks([
  HttpClient,
  CacheService,
  NetworkService,
])
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

  tearDown(() {
    reset(mockHttpClient);
    reset(mockCacheService);
    reset(mockNetworkService);
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

    test('returns mapped training list from network', () async {
      when(mockNetworkService.getCacheExpirationDuration())
          .thenReturn(const Duration(hours: 1));

      when(
        mockCacheService.cacheAndRetrieveData<List<Map<String, dynamic>>>(
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((invocation) async {
        final fetchData =
            invocation.positionalArguments[2] as Future<dynamic> Function();
        final response = await fetchData();
        return (response as List)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      });

      when(
        mockHttpClient.get('AngemeldeteSchulungen/$testPersonId/$testAbDatum'),
      ).thenAnswer((_) async => testResponse);

      final result = await trainingService.fetchAngemeldeteSchulungen(
        testPersonId,
        testAbDatum,
      );

      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.length, 2);
      expect(result[0]['BEZEICHNUNG'], 'Basic Training');
      expect(result[0]['SCHULUNGENTEILNEHMERID'], 1);
    });

    test('handles null SCHULUNGENTEILNEHMERID through public API', () async {
      const testPersonId = 123;
      const testAbDatum = '2023-01-01';

      when(mockNetworkService.getCacheExpirationDuration())
          .thenReturn(const Duration(hours: 1));

      // Mock the HTTP client to return data with null SCHULUNGENTEILNEHMERID
      when(
        mockHttpClient.get('AngemeldeteSchulungen/$testPersonId/$testAbDatum'),
      ).thenAnswer(
        (_) async => [
          {
            'DATUM': '2023-01-15',
            'BEZEICHNUNG': 'Training',
            'SCHULUNGENTEILNEHMERID': null,
          }
        ],
      );

      // Mock cache service to pass through the fetch function
      when(
        mockCacheService.cacheAndRetrieveData<List<Map<String, dynamic>>>(
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((invocation) async {
        final fetchData =
            invocation.positionalArguments[2] as Future<dynamic> Function();
        final processResponse =
            invocation.positionalArguments[3] as dynamic Function(dynamic);
        final response = await fetchData();
        return processResponse(response);
      });

      final result = await trainingService.fetchAngemeldeteSchulungen(
        testPersonId,
        testAbDatum,
      );

      expect(result[0]['SCHULUNGENTEILNEHMERID'], 0);
    });
  });

  group('fetchAvailableSchulungen', () {
    test('returns empty list for non-list response', () async {
      when(mockHttpClient.get('AvailableSchulungen'))
          .thenAnswer((_) async => {'error': 'Invalid format'});

      final result = await trainingService.fetchAvailableSchulungen();

      expect(result, isEmpty);
    });
  });

  group('fetchSchulungsarten', () {
    test('handles all fields correctly through public API', () async {
      final testResponse = [
        {
          'SCHULUNGSARTID': 1,
          'BEZEICHNUNG': 'Type 1',
          'TYP': 'Basic',
          'KOSTEN': 100.0,
          'UE': 8,
          'OMKATEGORIEID': 2,
          'RECHNUNGAN': 'Account',
          'VERPFLEGUNGSKOSTEN': 50.0,
          'UEBERNACHTUNGSKOSTEN': 200.0,
          'LEHRMATERIALKOSTEN': 30.0,
          'LEHRGANGSINHALT': 'Content',
          'LEHRGANGSINHALTHTML': '<p>Content</p>',
          'WEBGRUPPE': 'Group',
          'FUERVERLAENGERUNGEN': 'Extensions',
        }
      ];

      when(mockHttpClient.get('Schulungsarten/false'))
          .thenAnswer((_) async => testResponse);

      final result = await trainingService.fetchSchulungsarten();

      expect(result.length, 1);
      expect(result[0]['BEZEICHNUNG'], 'Type 1');
      expect(result[0]['LEHRGANGSINHALTHTML'], '<p>Content</p>');
    });
  });

  group('fetchAbsolvierteSchulungen', () {
    const testPersonId = 123;

    test('handles invalid date strings through public API', () async {
      when(mockHttpClient.get('AbsolvierteSchulungen/$testPersonId'))
          .thenAnswer(
        (_) async => [
          {
            'AUSGESTELLTAM': 'invalid-date',
            'BEZEICHNUNG': 'Training',
            'GUELTIGBIS': 'another-invalid-date',
          }
        ],
      );

      final result =
          await trainingService.fetchAbsolvierteSchulungen(testPersonId);

      expect(result[0]['AUSGESTELLTAM'], 'invalid-date');
      expect(result[0]['GUELTIGBIS'], 'another-invalid-date');
    });
  });

  // Other test groups remain the same as in previous version...
  group('registerForSchulung', () {
    const testPersonId = 123;
    const testSchulungId = 456;

    test('returns true when registration is successful', () async {
      when(mockHttpClient.post('RegisterForSchulung', any))
          .thenAnswer((_) async => {'ResultType': 1});

      final result = await trainingService.registerForSchulung(
        testPersonId,
        testSchulungId,
      );

      expect(result, isTrue);
    });

    test('rethrows exception and logs error on failure', () async {
      final testException = Exception('Registration error');
      when(mockHttpClient.post('RegisterForSchulung', any))
          .thenThrow(testException);

      expect(
        () => trainingService.registerForSchulung(testPersonId, testSchulungId),
        throwsA(testException),
      );
    });
  });

  group('unregisterFromSchulung', () {
    group('fetchVereine', () {
      test('returns mapped vereine list from API', () async {
        final testResponse = [
          {
            'VEREINID': 1,
            'GAUID': 101,
            'GAUNR': 'GAU01',
            'VEREINNR': 'V001',
            'VEREINNAME': 'Test Verein',
            'LAT': 48.1351,
            'LON': 11.5820,
            'GEOCODEQUELLE': 'Google',
          }
        ];

        when(mockHttpClient.get('Vereine'))
            .thenAnswer((_) async => testResponse);

        final result = await trainingService.fetchVereine();

        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, 1);
        expect(result[0]['VEREINNAME'], 'Test Verein');
        expect(result[0]['LAT'], 48.1351);
        verify(mockHttpClient.get('Vereine')).called(1);
      });

      test('returns empty list when API returns non-list response', () async {
        when(mockHttpClient.get('Vereine'))
            .thenAnswer((_) async => {'error': 'Invalid data'});

        final result = await trainingService.fetchVereine();

        expect(result, isEmpty);
        verify(mockHttpClient.get('Vereine')).called(1);
      });

      test('returns empty list and logs error when exception occurs', () async {
        when(mockHttpClient.get('Vereine'))
            .thenThrow(Exception('Network error'));

        final result = await trainingService.fetchVereine();

        expect(result, isEmpty);
        verify(mockHttpClient.get('Vereine')).called(1);
      });

      test('handles partial data correctly', () async {
        final testResponse = [
          {
            'VEREINID': 2,
            'VEREINNAME': 'Partial Data Club',
            // Missing other fields
          }
        ];

        when(mockHttpClient.get('Vereine'))
            .thenAnswer((_) async => testResponse);

        final result = await trainingService.fetchVereine();

        expect(result.length, 1);
        expect(result[0]['VEREINNAME'], 'Partial Data Club');
        expect(result[0]['GAUID'],
            isNull,); // Should handle missing fields gracefully
      });
    });

    const testTeilnehmerId = 789;

    test('returns true when unregistration is successful', () async {
      when(
        mockHttpClient.delete(
          'SchulungenTeilnehmer/$testTeilnehmerId',
          body: {},
        ),
      ).thenAnswer((_) async => {'result': true});

      final result =
          await trainingService.unregisterFromSchulung(testTeilnehmerId);

      expect(result, isTrue);
    });

    test('returns false and logs error on exception', () async {
      when(
        mockHttpClient.delete(
          'SchulungenTeilnehmer/$testTeilnehmerId',
          body: {},
        ),
      ).thenThrow(Exception('Network error'));

      final result =
          await trainingService.unregisterFromSchulung(testTeilnehmerId);

      expect(result, isFalse);
    });
  });
}
