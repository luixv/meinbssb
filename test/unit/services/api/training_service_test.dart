import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/api/training_service.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/models/schulung.dart'; // Import the Schulung model
import 'package:meinbssb/models/disziplin.dart';
import 'package:meinbssb/models/schulungsart.dart';
import 'package:meinbssb/models/schulungstermin.dart';
// Import for date formatting
import 'dart:async';
import 'dart:io';

@GenerateMocks([HttpClient, CacheService, NetworkService])
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
  });
  group('fetchSchulungsarten', () {
    final testResponse = [
      {
        'SCHULUNGSARTID': 41,
        'BEZEICHNUNG': 'Vereinsmanager C, Aufbauphase, Qualifizierungskurs',
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
      }
    ];

    test('returns mapped Schulungsarten list from network', () async {
      when(mockHttpClient.get('Schulungsarten/false'))
          .thenAnswer((_) async => testResponse);

      final result = await trainingService.fetchSchulungsarten();

      expect(result, isA<List<Schulungsart>>());
      expect(result.length, 1);
      expect(result[0].schulungsartId, 41);
      expect(
        result[0].bezeichnung,
        'Vereinsmanager C, Aufbauphase, Qualifizierungskurs',
      );
      expect(result[0].typ, 6);
      expect(result[0].kosten, 0.0);
      expect(result[0].ue, 0);
      expect(result[0].omKategorieId, 1);
      expect(result[0].rechnungAn, 1);
      expect(result[0].verpflegungskosten, 0.0);
      expect(result[0].uebernachtungskosten, 0.0);
      expect(result[0].lehrmaterialkosten, 0.0);
      expect(result[0].lehrgangsinhalt, '');
      expect(result[0].lehrgangsinhaltHtml, '');
      expect(result[0].webGruppe, 3);
      expect(result[0].fuerVerlaengerungen, false);
    });

    test('handles null values correctly', () async {
      when(mockHttpClient.get('Schulungsarten/false')).thenAnswer(
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
      expect(result[0].schulungsartId, 0);
      expect(result[0].bezeichnung, '');
      expect(result[0].typ, 0);
      expect(result[0].kosten, 0.0);
      expect(result[0].ue, 0);
      expect(result[0].omKategorieId, 0);
      expect(result[0].rechnungAn, 0);
      expect(result[0].verpflegungskosten, 0.0);
      expect(result[0].uebernachtungskosten, 0.0);
      expect(result[0].lehrmaterialkosten, 0.0);
      expect(result[0].lehrgangsinhalt, '');
      expect(result[0].lehrgangsinhaltHtml, '');
      expect(result[0].webGruppe, 0);
      expect(result[0].fuerVerlaengerungen, false);
    });

    test('returns empty list when API returns non-list response', () async {
      when(mockHttpClient.get('Schulungsarten/false'))
          .thenAnswer((_) async => {'error': 'Invalid format'});

      final result = await trainingService.fetchSchulungsarten();

      expect(result, isEmpty);
    });

    test('returns empty list and logs error when exception occurs', () async {
      when(mockHttpClient.get('Schulungsarten/false'))
          .thenThrow(Exception('Network error'));

      final result = await trainingService.fetchSchulungsarten();

      expect(result, isEmpty);
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

      when(
        mockHttpClient.get('AbsolvierteSchulungen/$testPersonId'),
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
      when(
        mockHttpClient.get('AbsolvierteSchulungen/$testPersonId'),
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
        when(
          mockHttpClient.get('AbsolvierteSchulungen/$testPersonId'),
        ).thenAnswer((_) async => {'error': 'Not a list'});

        final result = await trainingService.fetchAbsolvierteSchulungen(
          testPersonId,
        );

        expect(result, isEmpty);
      },
    );

    test('handles null values for AbsolvierteSchulungen', () async {
      when(
        mockHttpClient.get('AbsolvierteSchulungen/$testPersonId'),
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

      when(
        mockHttpClient.get('Disziplinen'),
      ).thenAnswer((_) async => testResponse);

      final result = await trainingService.fetchDisziplinen();

      expect(result, isA<List<Disziplin>>());
      expect(result.length, 2);
      expect(result[0].disziplin, 'Luftgewehr');
      expect(result[1].disziplinNr, '1.11');
      verify(mockHttpClient.get('Disziplinen')).called(1);
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

      when(mockHttpClient.get('Disziplinen')).thenAnswer((_) async => []);

      final result = await trainingService.fetchDisziplinen();

      expect(result, isEmpty);
      verify(mockHttpClient.get('Disziplinen')).called(1);
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

      when(
        mockHttpClient.get('Disziplinen'),
      ).thenAnswer((_) async => {'error': 'Invalid format'});

      final result = await trainingService.fetchDisziplinen();

      expect(result, isEmpty);
      verify(mockHttpClient.get('Disziplinen')).called(1);
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

      when(
        mockHttpClient.get('Disziplinen'),
      ).thenThrow(Exception('Network error for Disziplinen'));

      final result = await trainingService.fetchDisziplinen();

      expect(result, isEmpty);
      verify(mockHttpClient.get('Disziplinen')).called(1);
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

      when(
        mockHttpClient.get('Disziplinen'),
      ).thenThrow(TimeoutException('Request timed out'));

      final result = await trainingService.fetchDisziplinen();

      expect(result, isEmpty);
      verify(mockHttpClient.get('Disziplinen')).called(1);
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

      when(
        mockHttpClient.get('Disziplinen'),
      ).thenThrow(const SocketException('Failed to connect'));

      final result = await trainingService.fetchDisziplinen();

      expect(result, isEmpty);
      verify(mockHttpClient.get('Disziplinen')).called(1);
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

      when(
        mockHttpClient.get('Disziplinen'),
      ).thenThrow(const HttpException('Server error'));

      final result = await trainingService.fetchDisziplinen();

      expect(result, isEmpty);
      verify(mockHttpClient.get('Disziplinen')).called(1);
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

      when(
        mockHttpClient.get('Disziplinen'),
      ).thenAnswer((_) async => 'Invalid JSON response');

      final result = await trainingService.fetchDisziplinen();

      expect(result, isEmpty);
      verify(mockHttpClient.get('Disziplinen')).called(1);
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

      when(mockHttpClient.get('Disziplinen')).thenAnswer(
        (_) async => [
          {'DISZIPLINID': 'invalid', 'DISZIPLIN': 123},
        ],
      );

      final result = await trainingService.fetchDisziplinen();

      expect(result, isEmpty);
      verify(mockHttpClient.get('Disziplinen')).called(1);
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

      when(
        mockHttpClient.get('Disziplinen'),
      ).thenAnswer((_) async => partialResponse);

      final result = await trainingService.fetchDisziplinen();

      expect(result.length, 1);
      expect(result[0].disziplin, 'Pistole (Partial)');
      expect(result[0].disziplinNr, isNull); // Should be null if missing
      verify(mockHttpClient.get('Disziplinen')).called(1);
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
      when(
        mockHttpClient.post('RegisterForSchulung', any),
      ).thenAnswer((_) async => {'ResultType': 1});

      final result = await trainingService.registerForSchulung(
        testPersonId,
        testSchulungId,
      );

      expect(result, isTrue);
    });

    test('returns false and logs error on failure', () async {
      when(
        mockHttpClient.post('RegisterForSchulung', any),
      ).thenThrow(Exception('Registration error'));

      final result = await trainingService.registerForSchulung(
        testPersonId,
        testSchulungId,
      );

      expect(result, isFalse);
    });

    test('handles network timeout during registration', () async {
      when(
        mockHttpClient.post('RegisterForSchulung', any),
      ).thenThrow(TimeoutException('Request timed out'));

      final result = await trainingService.registerForSchulung(
        testPersonId,
        testSchulungId,
      );

      expect(result, isFalse);
    });

    test('handles server error response', () async {
      when(mockHttpClient.post('RegisterForSchulung', any)).thenAnswer(
        (_) async => {'ResultType': 0, 'ResultMessage': 'Server error'},
      );

      final result = await trainingService.registerForSchulung(
        testPersonId,
        testSchulungId,
      );

      expect(result, isFalse);
    });

    test('handles invalid response format', () async {
      when(
        mockHttpClient.post('RegisterForSchulung', any),
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
      when(
        mockHttpClient.delete(
          'SchulungenTeilnehmer/$testTeilnehmerId',
          body: {},
        ),
      ).thenAnswer((_) async => {'result': true});

      final result = await trainingService.unregisterFromSchulung(
        testTeilnehmerId,
      );

      expect(result, isTrue);
    });

    test('returns false and logs error on exception', () async {
      when(
        mockHttpClient.delete(
          'SchulungenTeilnehmer/$testTeilnehmerId',
          body: {},
        ),
      ).thenThrow(Exception('Network error'));

      final result = await trainingService.unregisterFromSchulung(
        testTeilnehmerId,
      );

      expect(result, isFalse);
    });

    test('handles network timeout during unregistration', () async {
      when(
        mockHttpClient.delete(
          'SchulungenTeilnehmer/$testTeilnehmerId',
          body: {},
        ),
      ).thenThrow(TimeoutException('Request timed out'));

      final result = await trainingService.unregisterFromSchulung(
        testTeilnehmerId,
      );

      expect(result, isFalse);
    });

    test('handles server error response', () async {
      when(
        mockHttpClient.delete(
          'SchulungenTeilnehmer/$testTeilnehmerId',
          body: {},
        ),
      ).thenAnswer((_) async => {'result': false, 'error': 'Server error'});

      final result = await trainingService.unregisterFromSchulung(
        testTeilnehmerId,
      );

      expect(result, isFalse);
    });

    test('handles invalid response format', () async {
      when(
        mockHttpClient.delete(
          'SchulungenTeilnehmer/$testTeilnehmerId',
          body: {},
        ),
      ).thenAnswer((_) async => {'invalid': 'response'});

      final result = await trainingService.unregisterFromSchulung(
        testTeilnehmerId,
      );

      expect(result, isFalse);
    });
  });

  group('fetchSchulungstermine', () {
    test('maps valid Schulungstermine response correctly', () async {
      when(mockHttpClient.get('Schulungstermine/15.08.2025/false')).thenAnswer(
        (_) async => [
          {
            'SCHULUNGENTERMINID': 42,
            'SCHULUNGSARTID': 7,
            'DATUM': '2025-08-15T00:00:00.000+02:00',
            'BEMERKUNG': 'Hinweis',
            'KOSTEN': 99.99,
            'ORT': 'München',
            'LEHRGANGSLEITER': 'Herr Mustermann',
            'MAXTEILNEHMER': 50,
            'ANGEMELDETETEILNEHMER': 10,
            'LEHRGANGSINHALT': 'Inhalt Text',
            'LEHRGANGSINHALTHTML': '<b>HTML Inhalt</b>',
            'STATUS': 1,
            'DATUMBIS': '2025-08-16T00:00:00.000+02:00',
            'VERPFLEGUNGSKOSTEN': 0.0,
            'UEBERNACHTUNGSKOSTEN': 0.0,
            'LEHRMATERIALKOSTEN': 0.0,
            'WEBVEROEFFENTLICHENAM': '',
            'ANMELDUNGENGESPERRT': false,
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
            'WEBGRUPPE': 0,
            'VERANSTALTUNGSBEZIRK': 0,
            'FUERVERLAENGERUNGEN': false,
            'ANMELDENERLAUBT': 0,
            'VERBANDSINTERNPASSWORT': '',
            'BEZEICHNUNG': 'Test',
          },
          {
            // Should be filtered out: status == 2
            'SCHULUNGENTERMINID': 99,
            'SCHULUNGSARTID': 7,
            'DATUM': '2025-08-15T00:00:00.000+02:00',
            'BEMERKUNG': 'Hinweis',
            'KOSTEN': 99.99,
            'ORT': 'München',
            'LEHRGANGSLEITER': 'Herr Mustermann',
            'MAXTEILNEHMER': 50,
            'ANGEMELDETETEILNEHMER': 10,
            'LEHRGANGSINHALT': 'Inhalt Text',
            'LEHRGANGSINHALTHTML': '<b>HTML Inhalt</b>',
            'STATUS': 2,
            'DATUMBIS': '2025-08-16T00:00:00.000+02:00',
            'VERPFLEGUNGSKOSTEN': 0.0,
            'UEBERNACHTUNGSKOSTEN': 0.0,
            'LEHRMATERIALKOSTEN': 0.0,
            'WEBVEROEFFENTLICHENAM': '',
            'ANMELDUNGENGESPERRT': false,
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
            'WEBGRUPPE': 0,
            'VERANSTALTUNGSBEZIRK': 0,
            'FUERVERLAENGERUNGEN': false,
            'ANMELDENERLAUBT': 0,
            'VERBANDSINTERNPASSWORT': '',
            'BEZEICHNUNG': 'Test',
          },
        ],
      );
      final result = await trainingService.fetchSchulungstermine('15.08.2025');
      expect(result.length, 1);
      final s = result[0];
      expect(s.schulungsterminId, 42);
      expect(s.schulungsartId, 7);
      expect(s.datum, DateTime.parse('2025-08-15T00:00:00.000+02:00'));
      expect(s.ort, 'München');
      expect(s.maxTeilnehmer, 50);
      expect(s.angemeldeteTeilnehmer, 10);
      expect(s.lehrgangsinhalt, 'Inhalt Text');
      expect(s.lehrgangsinhaltHtml, '<b>HTML Inhalt</b>');
      expect(s.status, 1);
      expect(s.datumBis, '2025-08-16T00:00:00.000+02:00');
    });

    test('handles null/missing fields with defaults', () async {
      when(mockHttpClient.get('Schulungstermine/01.01.2030/false')).thenAnswer(
        (_) async => [
          {
            'SCHULUNGENTERMINID': null,
            'SCHULUNGSARTID': null,
            'DATUM': null,
            'BEMERKUNG': null,
            'KOSTEN': null,
            'ORT': null,
            'MAXTEILNEHMER': null,
            'ANGEMELDETETEILNEHMER': null,
            'LEHRGANGSINHALT': null,
            'LEHRGANGSINHALTHTML': null,
            'STATUS': null,
            'DATUMBIS': null,
            'VERPFLEGUNGSKOSTEN': null,
            'UEBERNACHTUNGSKOSTEN': null,
            'LEHRMATERIALKOSTEN': null,
            'WEBVEROEFFENTLICHENAM': null,
            'ANMELDUNGENGESPERRT': null,
            'LEHRGANGSLEITER': null,
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
          },
        ],
      );
      final result = await trainingService.fetchSchulungstermine('01.01.2030');
      expect(result.length, 1);
      final s = result[0];
      expect(s.schulungsterminId, 0);
      expect(s.schulungsartId, 0);
      expect(s.datum, DateTime(1970, 1, 1));
      expect(s.ort, '');
      expect(s.maxTeilnehmer, 0);
      expect(s.angemeldeteTeilnehmer, 0);
      expect(s.lehrgangsinhalt, '');
      expect(s.lehrgangsinhaltHtml, '');
      expect(s.status, 0);
      expect(s.datumBis, '');
    });

    test('returns empty list for non-list response', () async {
      when(mockHttpClient.get('Schulungstermine/01.01.2040/false'))
          .thenAnswer((_) async => {'error': 'not a list'});
      final result = await trainingService.fetchSchulungstermine('01.01.2040');
      expect(result, isEmpty);
    });

    test('returns empty list and logs error on exception', () async {
      when(mockHttpClient.get('Schulungstermine/01.01.2050/false'))
          .thenThrow(Exception('Network error'));
      final result = await trainingService.fetchSchulungstermine('01.01.2050');
      expect(result, isEmpty);
    });

    test('filters out results with status == 2 or not published', () async {
      final now = DateTime.now();
      final futureDate = now.add(const Duration(days: 10));
      final pastDate = now.subtract(const Duration(days: 10));
      final testResponse = [
        // Should be included: status!=2, webVeroeffentlichenAm empty
        {
          'SCHULUNGENTERMINID': 1,
          'SCHULUNGSARTID': 1,
          'DATUM': futureDate.toIso8601String(),
          'BEMERKUNG': '',
          'KOSTEN': 10.0,
          'ORT': 'Ort1',
          'LEHRGANGSLEITER': '',
          'VERPFLEGUNGSKOSTEN': 0.0,
          'UEBERNACHTUNGSKOSTEN': 0.0,
          'LEHRMATERIALKOSTEN': 0.0,
          'LEHRGANGSINHALT': '',
          'MAXTEILNEHMER': 10,
          'WEBVEROEFFENTLICHENAM': '',
          'ANMELDUNGENGESPERRT': false,
          'STATUS': 1,
          'DATUMBIS': '',
          'LEHRGANGSINHALTHTML': '',
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
          'WEBGRUPPE': 0,
          'VERANSTALTUNGSBEZIRK': 0,
          'FUERVERLAENGERUNGEN': false,
          'ANMELDENERLAUBT': 0,
          'VERBANDSINTERNPASSWORT': '',
          'BEZEICHNUNG': 'A',
          'ANGEMELDETETEILNEHMER': 0,
        },
        // Should be included: status!=2, now after webVeroeffentlichenAm
        {
          'SCHULUNGENTERMINID': 2,
          'SCHULUNGSARTID': 1,
          'DATUM': futureDate.toIso8601String(),
          'BEMERKUNG': '',
          'KOSTEN': 10.0,
          'ORT': 'Ort2',
          'LEHRGANGSLEITER': '',
          'VERPFLEGUNGSKOSTEN': 0.0,
          'UEBERNACHTUNGSKOSTEN': 0.0,
          'LEHRMATERIALKOSTEN': 0.0,
          'LEHRGANGSINHALT': '',
          'MAXTEILNEHMER': 10,
          'WEBVEROEFFENTLICHENAM': pastDate.toIso8601String(),
          'ANMELDUNGENGESPERRT': false,
          'STATUS': 1,
          'DATUMBIS': '',
          'LEHRGANGSINHALTHTML': '',
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
          'WEBGRUPPE': 0,
          'VERANSTALTUNGSBEZIRK': 0,
          'FUERVERLAENGERUNGEN': false,
          'ANMELDENERLAUBT': 0,
          'VERBANDSINTERNPASSWORT': '',
          'BEZEICHNUNG': 'B',
          'ANGEMELDETETEILNEHMER': 0,
        },
        // Should be filtered out: status == 2
        {
          'SCHULUNGENTERMINID': 3,
          'SCHULUNGSARTID': 1,
          'DATUM': futureDate.toIso8601String(),
          'BEMERKUNG': '',
          'KOSTEN': 10.0,
          'ORT': 'Ort3',
          'LEHRGANGSLEITER': '',
          'VERPFLEGUNGSKOSTEN': 0.0,
          'UEBERNACHTUNGSKOSTEN': 0.0,
          'LEHRMATERIALKOSTEN': 0.0,
          'LEHRGANGSINHALT': '',
          'MAXTEILNEHMER': 10,
          'WEBVEROEFFENTLICHENAM': '',
          'ANMELDUNGENGESPERRT': false,
          'STATUS': 2,
          'DATUMBIS': '',
          'LEHRGANGSINHALTHTML': '',
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
          'WEBGRUPPE': 0,
          'VERANSTALTUNGSBEZIRK': 0,
          'FUERVERLAENGERUNGEN': false,
          'ANMELDENERLAUBT': 0,
          'VERBANDSINTERNPASSWORT': '',
          'BEZEICHNUNG': 'C',
          'ANGEMELDETETEILNEHMER': 0,
        },
        // Should be filtered out: status!=2, but now before webVeroeffentlichenAm
        {
          'SCHULUNGENTERMINID': 4,
          'SCHULUNGSARTID': 1,
          'DATUM': futureDate.toIso8601String(),
          'BEMERKUNG': '',
          'KOSTEN': 10.0,
          'ORT': 'Ort4',
          'LEHRGANGSLEITER': '',
          'VERPFLEGUNGSKOSTEN': 0.0,
          'UEBERNACHTUNGSKOSTEN': 0.0,
          'LEHRMATERIALKOSTEN': 0.0,
          'LEHRGANGSINHALT': '',
          'MAXTEILNEHMER': 10,
          'WEBVEROEFFENTLICHENAM': futureDate.toIso8601String(),
          'ANMELDUNGENGESPERRT': false,
          'STATUS': 1,
          'DATUMBIS': '',
          'LEHRGANGSINHALTHTML': '',
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
          'WEBGRUPPE': 0,
          'VERANSTALTUNGSBEZIRK': 0,
          'FUERVERLAENGERUNGEN': false,
          'ANMELDENERLAUBT': 0,
          'VERBANDSINTERNPASSWORT': '',
          'BEZEICHNUNG': 'D',
          'ANGEMELDETETEILNEHMER': 0,
        },
      ];
      when(mockHttpClient.get('Schulungstermine/01.01.2099/false'))
          .thenAnswer((_) async => testResponse);
      final result = await trainingService.fetchSchulungstermine('01.01.2099');
      final ids = result.map((e) => e.schulungsterminId).toList();
      expect(ids, containsAll([1, 2]));
      expect(ids, isNot(contains(3)));
      expect(ids, isNot(contains(4)));
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
      when(mockHttpClient.get('Schulungstermin/$schulungenTerminID'))
          .thenAnswer((_) async => mockResponse);

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
      when(mockHttpClient.get('Schulungstermin/$schulungenTerminID'))
          .thenAnswer((_) async => 'unexpected');

      final result =
          await trainingService.fetchSchulungstermin(schulungenTerminID);
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
  });
}
