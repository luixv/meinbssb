import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/api/training_service.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/models/schulung_data.dart';
import 'package:meinbssb/models/disziplin_data.dart';
import 'package:meinbssb/models/schulungstermin_data.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/bank_data.dart';
import 'package:meinbssb/models/schulungstermine_zusatzfelder_data.dart';

import 'dart:async';
import 'dart:io';

@GenerateMocks([HttpClient, CacheService, NetworkService, ConfigService])
import 'training_service_test.mocks.dart';

// TEST SETUP PATTERN: Always create mockHttpClient first, then pass it to TrainingService in setUp. Do not recreate or reassign either after setUp. Register all when(...).thenAnswer(...) mocks inside each test, after setUp.
void main() {
  late MockHttpClient mockHttpClient;
  late MockCacheService mockCacheService;
  late MockNetworkService mockNetworkService;
  // Remove MockConfigService if not used by TrainingService
  late MockConfigService mockConfigService;
  late TrainingService trainingService;

  setUpAll(() async {
    ConfigService.reset();
    await ConfigService.load('assets/config.json');
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockCacheService = MockCacheService();
    mockNetworkService = MockNetworkService();
    mockConfigService = MockConfigService();

    trainingService = TrainingService(
      httpClient: mockHttpClient,
      cacheService: mockCacheService,
      networkService: mockNetworkService,
      configService: mockConfigService,
    );

    when(mockConfigService.getString('apiProtocol', any)).thenReturn('https');
    when(mockConfigService.getString('api1BaseServer', any))
        .thenReturn('webintern.bssb.bayern');
    when(mockConfigService.getString('api1BasePort', any)).thenReturn('56400');
    when(mockConfigService.getString('api1BasePath', any))
        .thenReturn('rest/zmi/api1');
  });

  tearDown(() {
    reset(mockHttpClient);
    reset(mockCacheService);
    reset(mockNetworkService);
    // reset(mockConfigService); // Only reset if used in TrainingService
  });

  group('fetchAngemeldeteSchulungen', () {
    const testPersonId = 123;
    const testAbDatum = '2023-01-01';
    final testResponse = [
      // Raw map data mimicking API response for Schulungstermin
      {
        'SCHULUNGENTERMINID': 1,
        'SCHULUNGSARTID': 1,
        'DATUM': '2023-01-15T00:00:00.000',
        'BEMERKUNG': 'Bemerkung',
        'KOSTEN': 100.0,
        'ORT': 'Ort',
        'LEHRGANGSLEITER': 'Leiter',
        'VERPFLEGUNGSKOSTEN': 10.0,
        'UEBERNACHTUNGSKOSTEN': 20.0,
        'LEHRMATERIALKOSTEN': 5.0,
        'LEHRGANGSINHALT': 'Inhalt',
        'MAXTEILNEHMER': 20,
        'WEBVEROEFFENTLICHENAM': '2023-01-01',
        'ANMELDUNGENGESPERRT': false,
        'STATUS': 1,
        'DATUMBIS': '2023-01-16',
        'LEHRGANGSINHALTHTML': '<p>HTML</p>',
        'LEHRGANGSLEITER2': '',
        'LEHRGANGSLEITER3': '',
        'LEHRGANGSLEITER4': '',
        'LEHRGANGSLEITERTEL': '',
        'LEHRGANGSLEITER2TEL': '',
        'LEHRGANGSLEITER3TEL': '',
        'LEHRGANGSLEITER4TEL': '',
        'LEHRGANGSLEITERMAIL': '',
        'LEHRGANGSLEITER2MAIL': '',
        'LEHRGANGSLEITER3MAIL': '',
        'LEHRGANGSLEITER4MAIL': '',
        'ANMELDESTOPP': '',
        'ABMELDESTOPP': '',
        'GELOESCHT': false,
        'STORNOGRUND': '',
        'WEBGRUPPE': 1,
        'VERANSTALTUNGSBEZIRK': 1,
        'FUERVERLAENGERUNGEN': false,
        'ANMELDENERLAUBT': 1,
        'VERBANDSINTERNPASSWORT': '',
        'BEZEICHNUNG': 'Test Termin',
        'ANGEMELDETETEILNEHMER': 5,
      },
    ];

    test('returns mapped training list from network', () async {
      when(
        mockNetworkService.getCacheExpirationDuration(),
      ).thenReturn(const Duration(hours: 1));

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
        return response; // Return the raw list of maps
      });

      when(
        mockHttpClient.get('AngemeldeteSchulungen/$testPersonId/$testAbDatum'),
      ).thenAnswer((_) async => testResponse);

      final result = await trainingService.fetchAngemeldeteSchulungen(
        testPersonId,
        testAbDatum,
      );

      expect(result, isA<List<Schulungstermin>>());
      expect(result.length, 1);
      expect(result[0].schulungsterminId, 1);
      expect(result[0].bezeichnung, 'Test Termin');
      expect(result[0].angemeldeteTeilnehmer, 5);
    });

    test('handles null values correctly', () async {
      when(
        mockNetworkService.getCacheExpirationDuration(),
      ).thenReturn(const Duration(hours: 1));

      when(
        mockHttpClient.get('AngemeldeteSchulungen/$testPersonId/$testAbDatum'),
      ).thenAnswer(
        (_) async => [
          {
            'SCHULUNGENTERMINID': null,
            'SCHULUNGSARTID': null,
            'DATUM': null,
            'BEMERKUNG': null,
            'KOSTEN': null,
            'ORT': null,
            'LEHRGANGSLEITER': null,
            'VERPFLEGUNGSKOSTEN': null,
            'UEBERNACHTUNGSKOSTEN': null,
            'LEHRMATERIALKOSTEN': null,
            'LEHRGANGSINHALT': null,
            'MAXTEILNEHMER': null,
            'WEBVEROEFFENTLICHENAM': null,
            'ANMELDUNGENGESPERRT': null,
            'STATUS': null,
            'DATUMBIS': null,
            'LEHRGANGSINHALTHTML': null,
            'LEHRGANGSLEITER2': null,
            'LEHRGANGSLEITER3': null,
            'LEHRGANGSLEITER4': null,
            'LEHRGANGSLEITERTEL': null,
            'LEHRGANGSLEITER2TEL': null,
            'LEHRGANGSLEITER3TEL': null,
            'LEHRGANGSLEITER4TEL': null,
            'LEHRGANGSLEITERMAIL': null,
            'LEHRGANGSLEITER2MAIL': null,
            'LEHRGANGSLEITER3MAIL': null,
            'LEHRGANGSLEITER4MAIL': null,
            'ANMELDESTOPP': null,
            'ABMELDESTOPP': null,
            'GELOESCHT': null,
            'STORNOGRUND': null,
            'WEBGRUPPE': null,
            'VERANSTALTUNGSBEZIRK': null,
            'FUERVERLAENGERUNGEN': null,
            'ANMELDENERLAUBT': null,
            'VERBANDSINTERNPASSWORT': null,
            'BEZEICHNUNG': null,
            'ANGEMELDETETEILNEHMER': null,
          },
        ],
      );

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
        return response; // Return the raw list of maps
      });

      final result = await trainingService.fetchAngemeldeteSchulungen(
        testPersonId,
        testAbDatum,
      );

      expect(result.length, 1);
      // Assertions reflect the default values in Schulungstermin.fromJson
      expect(result[0].schulungsterminId, 0);
      expect(result[0].bezeichnung, '');
      expect(result[0].datum, DateTime(1970, 1, 1));
      expect(result[0].bemerkung, '');
      expect(result[0].kosten, 0.0);
      expect(result[0].ort, '');
      expect(result[0].lehrgangsleiter, '');
      expect(result[0].verpflegungskosten, 0.0);
      expect(result[0].uebernachtungskosten, 0.0);
      expect(result[0].lehrmaterialkosten, 0.0);
      expect(result[0].lehrgangsinhalt, '');
      expect(result[0].lehrgangsinhaltHtml, '');
      expect(result[0].maxTeilnehmer, 0);
      expect(result[0].webVeroeffentlichenAm, '');
      expect(result[0].anmeldungenGesperrt, false);
      expect(result[0].status, 0);
      expect(result[0].datumBis, '');
      expect(result[0].angemeldeteTeilnehmer, 0);
    });

    test('fetchAngemeldeteSchulungen returns empty list for non-list response',
        () async {
      when(mockNetworkService.getCacheExpirationDuration())
          .thenReturn(const Duration(hours: 1));
      when(mockHttpClient.get('AngemeldeteSchulungen/123/2023-01-01'))
          .thenAnswer((_) async => 'notalist');
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
        return response;
      });

      final result =
          await trainingService.fetchAngemeldeteSchulungen(123, '2023-01-01');
      expect(result, isEmpty);
    });

    test('fetchAngemeldeteSchulungen skips non-map items in response',
        () async {
      when(mockNetworkService.getCacheExpirationDuration())
          .thenReturn(const Duration(hours: 1));
      when(mockHttpClient.get('AngemeldeteSchulungen/123/2023-01-01'))
          .thenAnswer((_) async => [123, 'string', null]);
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
        return response;
      });

      final result =
          await trainingService.fetchAngemeldeteSchulungen(123, '2023-01-01');
      expect(result, isEmpty);
    });
  });
  group('fetchSchulungsarten', () {
    test('returns mapped Schulungsarten list from network', () async {
      when(mockConfigService.getString('apiProtocol', any)).thenReturn('https');
      when(mockConfigService.getString('api1BaseServer', any))
          .thenReturn('webintern.bssb.bayern');
      when(mockConfigService.getString('api1BasePort', any))
          .thenReturn('56400');
      when(mockConfigService.getString('api1BasePath', any))
          .thenReturn('rest/zmi/api1');
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer(
        (_) async => List.generate(
          41,
          (i) => {
            'SCHULUNGSARTID': i + 1,
            'BEZEICHNUNG': 'Art${i + 1}',
            'TYP': 6,
            'KOSTEN': 0.0,
            'UE': 0,
            'OMKATEGORIEID': 1,
            'RECHNUNGAN': 1,
            'VERPFLEGUNGSKOSTEN': 0.0,
            'UEBERNACHTUNGSKOSTEN': 0.0,
            'LEHRMATERIALKOSTEN': 0.0,
            'LEHRGANGSINHALT': '',
            'LEHRGANGSINHALTHTML': '',
            'WEBGRUPPE': 3,
            'FUERVERLAENGERUNGEN': false,
          },
        ),
      );
      final result = await trainingService.fetchSchulungsarten();
      expect(result.length, 41);
    });

    test('handles null values correctly', () async {
      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer(
        (_) async => [
          {
            'SCHULUNGSARTID': null,
            'BEZEICHNUNG': null,
            'TYP': null,
            'KOSTEN': null,
            'UE': null,
            'OMKATEGORIEID': null,
            'RECHNUNGAN': null,
            'VERPFLEGUNGSKOSTEN': null,
            'UEBERNACHTUNGSKOSTEN': null,
            'LEHRMATERIALKOSTEN': null,
            'LEHRGANGSINHALT': null,
            'LEHRGANGSINHALTHTML': null,
            'WEBGRUPPE': null,
            'FUERVERLAENGERUNGEN': null,
          }
        ],
      );
      final result = await trainingService.fetchSchulungsarten();
      expect(result.length, 1);
    });

    test('returns empty list when API returns non-list response', () async {
      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => {'error': 'Invalid format'});

      final result = await trainingService.fetchSchulungsarten();

      expect(result, isEmpty);
    });

    test('returns empty list and logs error when exception occurs', () async {
      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenThrow(Exception('Network error'));

      final result = await trainingService.fetchSchulungsarten();

      expect(result, isEmpty);
    });

    test('fetchSchulungsarten skips non-map and malformed items', () async {
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer(
        (_) async => [
          123,
          'string',
          null,
          {
            'SCHULUNGSARTID': 1,
            'BEZEICHNUNG': 'Valid',
            'TYP': 1,
            'KOSTEN': 0.0,
            'UE': 1,
            'OMKATEGORIEID': 1,
            'RECHNUNGAN': 1,
            'VERPFLEGUNGSKOSTEN': 0.0,
            'UEBERNACHTUNGSKOSTEN': 0.0,
            'LEHRMATERIALKOSTEN': 0.0,
            'LEHRGANGSINHALT': '',
            'LEHRGANGSINHALTHTML': '',
            'WEBGRUPPE': 1,
            'FUERVERLAENGERUNGEN': false,
          }
        ],
      );
      final result = await trainingService.fetchSchulungsarten();
      expect(result.length, 1);
      expect(result[0].bezeichnung, 'Valid');
    });
  });

  group('fetchAbsolvierteSchulungen', () {
    const testPersonId = 123;

    test('maps absolvierte Schulungen correctly and formats dates', () async {
      // API response for AbsolvierteSchulungen
      final testResponse = [
        {
          'SCHULUNGID': 101, // Assuming there's an ID for AbsolvierteSchulungen
          'AUSGESTELLTAM': '2023-01-15T00:00:00', // Example ISO date format
          'BEZEICHNUNG': 'Schulung A',
          'GUELTIGBIS': '2024-01-15T00:00:00', // Example ISO date format
          // Other fields are expected to be null/defaulted in Schulung.fromJson
        },
        {
          'SCHULUNGID': 102,
          'AUSGESTELLTAM': '2022-11-05T00:00:00',
          'BEZEICHNUNG': 'Schulung B',
          'GUELTIGBIS': '2023-11-05T00:00:00',
        },
      ];

      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => testResponse);

      final result = await trainingService.fetchAbsolvierteSchulungen(
        testPersonId,
      );

      expect(result, isA<List<Schulung>>());
      expect(result.length, 2);

      expect(result[0].id, 101);
      expect(result[0].bezeichnung, 'Schulung A');
      expect(result[0].ausgestelltAm, '2023-01-15T00:00:00');
      expect(result[0].gueltigBis, '2024-01-15T00:00:00');
      // Other fields should be their default values
      expect(
        result[0].datum,
        '',
      ); // As DATUM field is not typically in AbsolvierteSchulungen
      expect(result[0].isOnline, false);

      expect(result[1].id, 102);
      expect(result[1].bezeichnung, 'Schulung B');
      expect(result[1].ausgestelltAm, '2022-11-05T00:00:00');
      expect(result[1].gueltigBis, '2023-11-05T00:00:00');
    });

    test('handles invalid date strings in AbsolvierteSchulungen', () async {
      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer(
        (_) async => [
          {
            'SCHULUNGID': 201,
            'AUSGESTELLTAM': 'invalid-date-format',
            'BEZEICHNUNG': 'Bad Date Schulung',
            'GUELTIGBIS': 'another-bad-date',
          },
        ],
      );

      final result = await trainingService.fetchAbsolvierteSchulungen(
        testPersonId,
      );

      expect(result.length, 1);
      expect(result[0].bezeichnung, 'Bad Date Schulung');
      // Expect the original invalid string if parsing fails
      expect(result[0].ausgestelltAm, 'invalid-date-format');
      expect(result[0].gueltigBis, 'another-bad-date');
    });

    test(
      'returns empty list for non-list response for AbsolvierteSchulungen',
      () async {
        ConfigService.buildBaseUrlForServer(
          mockConfigService,
          name: 'api1Base',
        );
        when(
          mockHttpClient.get(
            any,
            overrideBaseUrl: anyNamed('overrideBaseUrl'),
          ),
        ).thenAnswer((_) async => {'error': 'Not a list'});

        final result = await trainingService.fetchAbsolvierteSchulungen(
          testPersonId,
        );

        expect(result, isEmpty);
      },
    );

    test('handles null values for AbsolvierteSchulungen', () async {
      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer(
        (_) async => [
          {
            'SCHULUNGID': null,
            'AUSGESTELLTAM': null,
            'BEZEICHNUNG': null,
            'GUELTIGBIS': null,
          },
        ],
      );

      final result = await trainingService.fetchAbsolvierteSchulungen(
        testPersonId,
      );

      expect(result.length, 1);
      expect(result[0].id, 0);
      expect(result[0].bezeichnung, '');
      expect(result[0].ausgestelltAm, '');
      expect(result[0].gueltigBis, '');
    });

    test('fetchAbsolvierteSchulungen skips non-map and malformed items',
        () async {
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer(
        (_) async => [
          123,
          'string',
          null,
          {'SCHULUNGID': 1, 'BEZEICHNUNG': 'Valid'},
        ],
      );
      final result = await trainingService.fetchAbsolvierteSchulungen(123);
      expect(result.length, 1);
      expect(result[0].bezeichnung, 'Valid');
    });
  });

  group('fetchDisziplinen', () {
    final testResponse = [
      {'DISZIPLINID': 1, 'DISZIPLINNR': '1.10', 'DISZIPLIN': 'Luftgewehr'},
      {'DISZIPLINID': 2, 'DISZIPLINNR': '1.11', 'DISZIPLIN': 'Kleinkaliber'},
    ];

    test('returns mapped Disziplinen list from network', () async {
      when(
        mockNetworkService.getCacheExpirationDuration(),
      ).thenReturn(const Duration(hours: 1));

      // Mock the cache service to return the raw map list as the 'fetchData' function
      // already handles the mapping to Disziplin models within TrainingService.
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
        return response; // Return the raw list of maps
      });

      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => testResponse);

      final result = await trainingService.fetchDisziplinen();

      expect(result, isA<List<Disziplin>>());
      expect(result.length, 2);
      expect(result[0].disziplin, 'Luftgewehr');
      expect(result[1].disziplinNr, '1.11');
      verify(mockHttpClient.get(any)).called(1);
    });

    test('returns empty list when API returns an empty list', () async {
      when(
        mockNetworkService.getCacheExpirationDuration(),
      ).thenReturn(const Duration(hours: 1));

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
        return response; // Return the raw list of maps
      });

      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => []);

      final result = await trainingService.fetchDisziplinen();

      expect(result, isEmpty);
      verify(mockHttpClient.get(any)).called(1);
    });

    test('returns empty list when API returns non-list response', () async {
      when(
        mockNetworkService.getCacheExpirationDuration(),
      ).thenReturn(const Duration(hours: 1));

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
        return response; // Return the raw list of maps
      });

      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => {'error': 'Invalid format'});

      final result = await trainingService.fetchDisziplinen();

      expect(result, isEmpty);
      verify(mockHttpClient.get(any)).called(1);
    });

    test('returns empty list and logs error when exception occurs', () async {
      when(
        mockNetworkService.getCacheExpirationDuration(),
      ).thenReturn(const Duration(hours: 1));

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
        return response; // Return the raw list of maps
      });

      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenThrow(Exception('Network error for Disziplinen'));

      final result = await trainingService.fetchDisziplinen();

      expect(result, isEmpty);
      verify(mockHttpClient.get(any)).called(1);
    });

    test('handles network timeout exception', () async {
      when(
        mockNetworkService.getCacheExpirationDuration(),
      ).thenReturn(const Duration(hours: 1));

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
        return response; // Return the raw list of maps
      });

      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenThrow(TimeoutException('Request timed out'));

      final result = await trainingService.fetchDisziplinen();

      expect(result, isEmpty);
      verify(mockHttpClient.get(any)).called(1);
    });

    test('handles socket exception', () async {
      when(
        mockNetworkService.getCacheExpirationDuration(),
      ).thenReturn(const Duration(hours: 1));

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
        return response; // Return the raw list of maps
      });

      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenThrow(const SocketException('Failed to connect'));

      final result = await trainingService.fetchDisziplinen();

      expect(result, isEmpty);
      verify(mockHttpClient.get(any)).called(1);
    });

    test('handles http exception', () async {
      when(
        mockNetworkService.getCacheExpirationDuration(),
      ).thenReturn(const Duration(hours: 1));

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
        return response; // Return the raw list of maps
      });

      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenThrow(const HttpException('Server error'));

      final result = await trainingService.fetchDisziplinen();

      expect(result, isEmpty);
      verify(mockHttpClient.get(any)).called(1);
    });

    test('handles format exception in response', () async {
      when(
        mockNetworkService.getCacheExpirationDuration(),
      ).thenReturn(const Duration(hours: 1));

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
        return response; // Return the raw list of maps
      });

      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => 'Invalid JSON response');

      final result = await trainingService.fetchDisziplinen();

      expect(result, isEmpty);
      verify(mockHttpClient.get(any)).called(1);
    });

    test('handles malformed JSON in response', () async {
      when(
        mockNetworkService.getCacheExpirationDuration(),
      ).thenReturn(const Duration(hours: 1));

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
        return response; // Return the raw list of maps
      });

      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer(
        (_) async => [
          {'DISZIPLINID': 'invalid', 'DISZIPLIN': 123},
        ],
      );

      final result = await trainingService.fetchDisziplinen();

      expect(result, isEmpty);
      verify(mockHttpClient.get(any)).called(1);
    });

    test('handles partial Disziplinen data correctly', () async {
      when(
        mockNetworkService.getCacheExpirationDuration(),
      ).thenReturn(const Duration(hours: 1));

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
        return response; // Return the raw list of maps
      });

      final partialResponse = [
        {'DISZIPLINID': 3, 'DISZIPLIN': 'Pistole (Partial)'},
        // Missing DISZIPLINNR
      ];

      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => partialResponse);

      final result = await trainingService.fetchDisziplinen();

      expect(result.length, 1);
      expect(result[0].disziplin, 'Pistole (Partial)');
      expect(result[0].disziplinNr, isNull); // Should be null if missing
      verify(mockHttpClient.get(any)).called(1);
    });
  });

  group('clearDisziplinenCache', () {
    test('clears disziplinen cache successfully', () async {
      when(mockCacheService.remove('disziplinen')).thenAnswer((_) async {});

      await trainingService.clearDisziplinenCache();

      verify(mockCacheService.remove('disziplinen')).called(1);
    });

    test('handles error when clearing cache fails', () async {
      when(mockCacheService.remove('disziplinen'))
          .thenThrow(Exception('Cache clear error'));

      // Should not throw
      await trainingService.clearDisziplinenCache();

      verify(mockCacheService.remove('disziplinen')).called(1);
    });
  });

  group('registerForSchulung', () {
    const testPersonId = 123;
    const testSchulungId = 456;

    test('returns true when registration is successful', () async {
      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.post(
          any,
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => {'ResultType': 1});

      final result = await trainingService.registerForSchulung(
        testPersonId,
        testSchulungId,
      );

      expect(result, isTrue);
    });

    test('returns false and logs error on failure', () async {
      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.post(
          any,
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenThrow(Exception('Registration error'));

      final result = await trainingService.registerForSchulung(
        testPersonId,
        testSchulungId,
      );

      expect(result, isFalse);
    });

    test('handles network timeout during registration', () async {
      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.post(
          any,
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenThrow(TimeoutException('Request timed out'));

      final result = await trainingService.registerForSchulung(
        testPersonId,
        testSchulungId,
      );

      expect(result, isFalse);
    });

    test('handles server error response', () async {
      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.post(
          any,
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer(
        (_) async => {'ResultType': 0, 'ResultMessage': 'Server error'},
      );

      final result = await trainingService.registerForSchulung(
        testPersonId,
        testSchulungId,
      );

      expect(result, isFalse);
    });

    test('handles invalid response format', () async {
      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.post(
          any,
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => {'invalid': 'response'});

      final result = await trainingService.registerForSchulung(
        testPersonId,
        testSchulungId,
      );

      expect(result, isFalse);
    });
  });

  group('unregisterFromSchulung', () {
    const testTeilnehmerId = 789;

    test('returns true when unregistration is successful', () async {
      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.delete(
          any,
          body: anyNamed('body'),
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => {'result': true});

      final result = await trainingService.unregisterFromSchulung(
        testTeilnehmerId,
      );

      expect(result, isTrue);
    });

    test('returns false and logs error on exception', () async {
      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.delete(
          any,
          body: anyNamed('body'),
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenThrow(Exception('Network error'));

      final result = await trainingService.unregisterFromSchulung(
        testTeilnehmerId,
      );

      expect(result, isFalse);
    });

    test('handles network timeout during unregistration', () async {
      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.delete(
          any,
          body: anyNamed('body'),
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenThrow(TimeoutException('Request timed out'));

      final result = await trainingService.unregisterFromSchulung(
        testTeilnehmerId,
      );

      expect(result, isFalse);
    });

    test('handles server error response', () async {
      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.delete(
          any,
          body: anyNamed('body'),
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => {'result': false, 'error': 'Server error'});

      final result = await trainingService.unregisterFromSchulung(
        testTeilnehmerId,
      );

      expect(result, isFalse);
    });

    test('handles invalid response format', () async {
      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.delete(
          any,
          body: anyNamed('body'),
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => {'invalid': 'response'});

      final result = await trainingService.unregisterFromSchulung(
        testTeilnehmerId,
      );

      expect(result, isFalse);
    });
  });

  group('fetchSchulungstermine', () {
    setUp(() {
      // Register the catch-all mock after mockHttpClient is created
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((invocation) async {
        throw Exception(
          invocation.positionalArguments[0],
        );
      });
      // Mock configService for fetchSchulungstermine
      when(mockConfigService.getString('apiProtocol')).thenReturn('https');
      when(mockConfigService.getString('api1BaseServer'))
          .thenReturn('localhost');
      when(mockConfigService.getString('api1Port')).thenReturn('1234');
      when(mockConfigService.getString('api1BasePath')).thenReturn('api');
    });

    test('fetchSchulungstermine maps valid Schulungstermine response correctly',
        () async {
      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.get(
          argThat(contains('Schulungstermine/15.08.2025')),
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async {
        return [
          {
            'SCHULUNGENTERMINID': 42,
            'STATUS': 1,
            'WEBVEROEFFENTLICHENAM': '',
            'BEZEICHNUNG': 'Test Termin',
            'DATUM': '2025-08-15T00:00:00.000+02:00',
          },
        ];
      });
      final result = await trainingService.fetchSchulungstermine(
        '15.08.2025',
        '1',
        '1',
        'true',
        'true',
      );
      expect(result.length, 1);
      expect(result[0].schulungsterminId, 42);
      expect(result[0].status, 1);
      expect(result[0].webVeroeffentlichenAm, '');
    });

    test('fetchSchulungstermine handles null/missing fields with defaults',
        () async {
      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.get(
          argThat(contains('Schulungstermine/01.01.2030')),
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async {
        return [
          {
            // 'SCHULUNGENTERMINID': null, // omit to test defaulting
            // 'STATUS': null, // omit to test defaulting
            'WEBVEROEFFENTLICHENAM': '',
            'BEZEICHNUNG': 'Minimal Termin',
            'DATUM': '2030-01-01T00:00:00.000+02:00',
          },
        ];
      });
      final result = await trainingService.fetchSchulungstermine(
        '01.01.2030',
        '*',
        '*',
        '*',
        '*',
      );
      expect(result.length, 1);
      final s = result[0];
      expect(s.schulungsterminId, 0);
      expect(s.status, 0);
      expect(s.webVeroeffentlichenAm, '');
    });

    test(
        'fetchSchulungstermine filters out results with status == 2 or not published',
        () async {
      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.get(
          argThat(contains('Schulungstermine/01.01.2099')),
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async {
        return [
          {
            'SCHULUNGENTERMINID': 1,
            'STATUS': 1,
            'WEBVEROEFFENTLICHENAM': '', // should be included
            'BEZEICHNUNG': 'Valid',
            'DATUM': '2099-01-01T00:00:00.000+02:00',
          },
          {
            'SCHULUNGENTERMINID': 2,
            'STATUS': 2,
            'WEBVEROEFFENTLICHENAM': '', // should be filtered out
            'BEZEICHNUNG': 'Status2',
            'DATUM': '2099-01-01T00:00:00.000+02:00',
          },
          {
            'SCHULUNGENTERMINID': 3,
            'STATUS': 1,
            'WEBVEROEFFENTLICHENAM':
                '2999-01-01T00:00:00.000', // future date, should be filtered out
            'BEZEICHNUNG': 'Future',
            'DATUM': '2999-01-01T00:00:00.000+02:00',
          },
        ];
      });
      final result = await trainingService.fetchSchulungstermine(
        '01.01.2099',
        '*',
        '*',
        '*',
        '*',
      );
      expect(
        result,
        contains(
          predicate(
            (t) =>
                t is Schulungstermin &&
                t.status == 1 &&
                t.webVeroeffentlichenAm == '' &&
                t.bezeichnung == 'Valid',
          ),
        ),
      );
      expect(result.length, 1);
    });
  });

  group('fetchSchulungstermin', () {
    test('returns a Schulungstermine object for a valid response', () async {
      const schulungenTerminID = '42';
      final mockResponse = {
        'SCHULUNGENTERMINID': 42,
        'SCHULUNGSARTID': 1,
        'DATUM': '2024-07-01T10:00:00.000',
        'BEMERKUNG': 'Bemerkung',
        'KOSTEN': 100.0,
        'ORT': 'Musterstadt',
        'LEHRGANGSLEITER': 'Herr Lehrer',
        'VERPFLEGUNGSKOSTEN': 10.0,
        'UEBERNACHTUNGSKOSTEN': 20.0,
        'LEHRMATERIALKOSTEN': 5.0,
        'LEHRGANGSINHALT': 'Inhalt',
        'MAXTEILNEHMER': 30,
        'WEBVEROEFFENTLICHENAM': '2024-06-01T00:00:00.000',
        'ANMELDUNGENGESPERRT': false,
        'STATUS': 1,
        'DATUMBIS': '2024-07-02T10:00:00.000',
        'LEHRGANGSINHALTHTML': '<p>Inhalt</p>',
        'LEHRGANGSLEITER2': '',
        'LEHRGANGSLEITER3': '',
        'LEHRGANGSLEITER4': '',
        'LEHRGANGSLEITERTEL': '',
        'LEHRGANGSLEITER2TEL': '',
        'LEHRGANGSLEITER3TEL': '',
        'LEHRGANGSLEITER4TEL': '',
        'LEHRGANGSLEITERMAIL': '',
        'LEHRGANGSLEITER2MAIL': '',
        'LEHRGANGSLEITER3MAIL': '',
        'LEHRGANGSLEITER4MAIL': '',
        'ANMELDESTOPP': '',
        'ABMELDESTOPP': '',
        'GELOESCHT': false,
        'STORNOGRUND': '',
        'WEBGRUPPE': 1,
        'VERANSTALTUNGSBEZIRK': 2,
        'FUERVERLAENGERUNGEN': false,
        'ANMELDENERLAUBT': 1,
        'VERBANDSINTERNPASSWORT': '',
        'BEZEICHNUNG': 'Test Schulung',
        'ANGEMELDETETEILNEHMER': 10,
      };
      when(mockConfigService.getString('apiProtocol')).thenReturn('https');
      when(mockConfigService.getString('api1BaseServer'))
          .thenReturn('example.com');
      when(mockConfigService.getString('api1Port')).thenReturn('1234');
      when(mockConfigService.getString('api1BasePath')).thenReturn('api');
      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result =
          await trainingService.fetchSchulungstermin(schulungenTerminID);

      expect(result, isNotNull);
      expect(result!.schulungsterminId, 42);
      expect(result.bezeichnung, 'Test Schulung');
      expect(result.ort, 'Musterstadt');
      expect(result.kosten, 100.0);
    });

    test('returns null for invalid response', () async {
      const schulungenTerminID = '99';
      when(mockConfigService.getString('apiProtocol')).thenReturn('https');
      when(mockConfigService.getString('api1BaseServer'))
          .thenReturn('example.com');
      when(mockConfigService.getString('api1Port')).thenReturn('1234');
      when(mockConfigService.getString('api1BasePath')).thenReturn('api');
      ConfigService.buildBaseUrlForServer(
        mockConfigService,
        name: 'api1Base',
      );
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => 'unexpected');

      final result =
          await trainingService.fetchSchulungstermin(schulungenTerminID);
      expect(result, isNull);
    });

    test('fetchSchulungstermin returns null for empty list response', () async {
      when(mockConfigService.getString('apiProtocol')).thenReturn('https');
      when(mockConfigService.getString('api1BaseServer'))
          .thenReturn('example.com');
      when(mockConfigService.getString('api1Port')).thenReturn('1234');
      when(mockConfigService.getString('api1BasePath')).thenReturn('api');
      ConfigService.buildBaseUrlForServer(mockConfigService, name: 'api1Base');
      when(
        mockHttpClient.get(any, overrideBaseUrl: anyNamed('overrideBaseUrl')),
      ).thenAnswer((_) async => []);
      final result = await trainingService.fetchSchulungstermin('999');
      expect(result, isNull);
    });

    test('fetchSchulungstermin returns null for list with non-map', () async {
      when(mockConfigService.getString('apiProtocol')).thenReturn('https');
      when(mockConfigService.getString('api1BaseServer'))
          .thenReturn('example.com');
      when(mockConfigService.getString('api1Port')).thenReturn('1234');
      when(mockConfigService.getString('api1BasePath')).thenReturn('api');
      ConfigService.buildBaseUrlForServer(mockConfigService, name: 'api1Base');
      when(
        mockHttpClient.get(any, overrideBaseUrl: anyNamed('overrideBaseUrl')),
      ).thenAnswer((_) async => [123]);
      final result = await trainingService.fetchSchulungstermin('999');
      expect(result, isNull);
    });
  });

  group('Cache clearing', () {
    test('clearSchulungenCache removes the correct cache key', () async {
      const personId = 123;
      when(mockCacheService.remove('schulungen_123'))
          .thenAnswer((_) async => true);
      await trainingService.clearSchulungenCache(personId);
      verify(mockCacheService.remove('schulungen_123')).called(1);
    });

    test('clearAllSchulungenCache calls clearPattern with schulungen_',
        () async {
      when(mockCacheService.clearPattern('schulungen_'))
          .thenAnswer((_) async => true);
      await trainingService.clearAllSchulungenCache();
      verify(mockCacheService.clearPattern('schulungen_')).called(1);
    });

    test('clearDisziplinenCache removes the correct cache key', () async {
      when(mockCacheService.remove('disziplinen'))
          .thenAnswer((_) async => true);
      await trainingService.clearDisziplinenCache();
      verify(mockCacheService.remove('disziplinen')).called(1);
    });
  });

  group('registerSchulungenTeilnehmer', () {
    test('registerSchulungenTeilnehmer rethrows on error', () async {
      const user = UserData(
        personId: 1,
        webLoginId: 1,
        namen: 'Test',
        vorname: 'Test',
        passnummer: '123',
        vereinNr: 1,
        vereinName: '',
        passdatenId: 0,
        mitgliedschaftId: 0,
      );
      const bank = BankData(
        id: 1,
        webloginId: 1,
        kontoinhaber: '',
        bankName: '',
        iban: '',
        bic: '',
        mandatNr: '',
        mandatName: '',
        mandatSeq: 0,
      );
      when(mockHttpClient.post(any, any)).thenThrow(Exception('fail'));
      expect(
        () => trainingService.registerSchulungenTeilnehmer(
          schulungTerminId: 1,
          user: user,
          email: 'a@b.de',
          telefon: '123',
          bankData: bank,
          felderArray: [],
        ),
        throwsException,
      );
    });
  });

  group('mapSchulungstermineZusatzfelderResponse', () {
    late TrainingService trainingService;

    setUp(() {
      trainingService = TrainingService(
        httpClient: MockHttpClient(),
        cacheService: MockCacheService(),
        networkService: MockNetworkService(),
        configService: MockConfigService(),
      );
    });

    test('returns mapped list on valid response', () {
      final response = [
        {
          'SCHULUNGENTERMINEFELDID': 1,
          'SCHULUNGENTERMINID': 876,
          'FELDBEZEICHNUNG': 'Feld A',
        },
        {
          'SCHULUNGENTERMINEFELDID': 2,
          'SCHULUNGENTERMINID': 876,
          'FELDBEZEICHNUNG': 'Feld B',
        }
      ];
      final result =
          trainingService.mapSchulungstermineZusatzfelderResponse(response);
      expect(result, isA<List<SchulungstermineZusatzfelder>>());
      expect(result.length, 2);
      expect(result[0].schulungstermineFeldId, 1);
      expect(result[0].feldbezeichnung, 'Feld A');
      expect(result[1].schulungstermineFeldId, 2);
      expect(result[1].feldbezeichnung, 'Feld B');
    });

    test('returns empty list on empty response', () {
      final result =
          trainingService.mapSchulungstermineZusatzfelderResponse([]);
      expect(result, isEmpty);
    });

    test('returns empty list on non-list response', () {
      final result = trainingService
          .mapSchulungstermineZusatzfelderResponse({'unexpected': 'object'});
      expect(result, isEmpty);
    });

    test('returns empty list if item is not a map', () {
      final result = trainingService
          .mapSchulungstermineZusatzfelderResponse([123, null, 'string']);
      expect(result, isEmpty);
    });
  });
}
