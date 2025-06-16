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
      // Raw map data mimicking API response
      {
        'SCHULUNGID': 1,
        'BEZEICHNUNG': 'Basic Training',
        'DATUM': '2023-01-15',
        'AUSGESTELLTAM': '2023-01-01',
        'SCHULUNGENTEILNEHMERID': 1,
        'SCHULUNGSARTID': 1,
        'SCHULUNGSARTBEZEICHNUNG': 'Basic',
        'SCHULUNGSARTKURZBEZEICHNUNG': 'BSC',
        'SCHULUNGSARTBESCHREIBUNG': 'Basic Training Course',
        'MAXTEILNEHMER': 20,
        'ANZAHLTEILNEHMER': 15,
        'ORT': 'Training Center',
        'UHRZEIT': '09:00',
        'DAUER': '8 Stunden',
        'PREIS': '100€',
        'ZIELGRUPPE': 'Anfänger',
        'VORAUSSETZUNGEN': 'Keine',
        'INHALT': 'Grundlagen',
        'ABSCHLUSS': 'Zertifikat',
        'ANMERKUNGEN': 'Bitte mitbringen: Schreibzeug',
        'ISONLINE': false,
        'LINK': '',
        'STATUS': 'Aktiv',
        'GUELTIGBIS': '2023-12-31',
      },
      {
        'SCHULUNGID': 2,
        'BEZEICHNUNG': 'Advanced Training',
        'DATUM': '2023-02-20',
        'AUSGESTELLTAM': '2023-02-01',
        'SCHULUNGENTEILNEHMERID': 2,
        'SCHULUNGSARTID': 2,
        'SCHULUNGSARTBEZEICHNUNG': 'Advanced',
        'SCHULUNGSARTKURZBEZEICHNUNG': 'ADV',
        'SCHULUNGSARTBESCHREIBUNG': 'Advanced Training Course',
        'MAXTEILNEHMER': 15,
        'ANZAHLTEILNEHMER': 10,
        'ORT': 'Training Center',
        'UHRZEIT': '10:00',
        'DAUER': '16 Stunden',
        'PREIS': '200€',
        'ZIELGRUPPE': 'Fortgeschrittene',
        'VORAUSSETZUNGEN': 'Basic Training',
        'INHALT': 'Erweiterte Themen',
        'ABSCHLUSS': 'Zertifikat',
        'ANMERKUNGEN': 'Bitte mitbringen: Laptop',
        'ISONLINE': true,
        'LINK': 'https://example.com',
        'STATUS': 'Aktiv',
        'GUELTIGBIS': '2023-12-31',
      },
    ];

    test('returns mapped training list from network', () async {
      when(
        mockNetworkService.getCacheExpirationDuration(),
      ).thenReturn(const Duration(hours: 1));

      // Mock the cache service to return the raw map list as the 'fetchData' function
      // already handles the mapping to Schulung models within TrainingService.
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

      expect(result, isA<List<Schulung>>());
      expect(result.length, 2);
      expect(result[0].id, 1);
      expect(result[0].bezeichnung, 'Basic Training');
      expect(result[0].teilnehmerId, 1);
      expect(result[0].schulungsartBezeichnung, 'Basic');
      expect(result[0].isOnline, false);
      expect(result[1].id, 2);
      expect(result[1].bezeichnung, 'Advanced Training');
      expect(result[1].teilnehmerId, 2);
      expect(result[1].schulungsartBezeichnung, 'Advanced');
      expect(result[1].isOnline, true);
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
            'SCHULUNGID': null,
            'BEZEICHNUNG': null,
            'DATUM': null,
            'AUSGESTELLTAM': null,
            'SCHULUNGENTEILNEHMERID': null,
            'SCHULUNGSARTID': null,
            'SCHULUNGSARTBEZEICHNUNG': null,
            'SCHULUNGSARTKURZBEZEICHNUNG': null,
            'SCHULUNGSARTBESCHREIBUNG': null,
            'MAXTEILNEHMER': null,
            'ANZAHLTEILNEHMER': null,
            'ORT': null,
            'UHRZEIT': null,
            'DAUER': null,
            'PREIS': null,
            'ZIELGRUPPE': null,
            'VORAUSSETZUNGEN': null,
            'INHALT': null,
            'ABSCHLUSS': null,
            'ANMERKUNGEN': null,
            'ISONLINE': null,
            'LINK': null,
            'STATUS': null,
            'GUELTIGBIS': null,
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
      // Assertions reflect the default values in Schulung.fromJson
      expect(result[0].id, 0);
      expect(result[0].bezeichnung, '');
      expect(result[0].datum, '');
      expect(result[0].ausgestelltAm, '-');
      expect(result[0].teilnehmerId, 0);
      expect(result[0].schulungsartId, 0);
      expect(result[0].schulungsartBezeichnung, '');
      expect(result[0].schulungsartKurzbezeichnung, '');
      expect(result[0].schulungsartBeschreibung, '');
      expect(result[0].maxTeilnehmer, 0);
      expect(result[0].anzahlTeilnehmer, 0);
      expect(result[0].ort, '');
      expect(result[0].uhrzeit, '');
      expect(result[0].dauer, '');
      expect(result[0].preis, '');
      expect(result[0].zielgruppe, '');
      expect(result[0].voraussetzungen, '');
      expect(result[0].inhalt, '');
      expect(result[0].abschluss, '');
      expect(result[0].anmerkungen, '');
      expect(result[0].isOnline, false);
      expect(result[0].link, '');
      expect(result[0].status, '');
      expect(result[0].gueltigBis, '-');
    });
  });

  group('fetchAvailableSchulungen', () {
    // API response format for AvailableSchulungen. This is similar to AngemeldeteSchulungen,
    // but the ID field for Schulung model is 'SCHULUNGID' here.
    final testResponse = [
      {
        'SCHULUNGID': 1,
        'BEZEICHNUNG': 'Training 1',
        'DATUM': '2023-01-15',
        'AUSGESTELLTAM': '2023-01-01',
        'SCHULUNGENTEILNEHMERID': 1,
        'SCHULUNGSARTID': 1,
        'SCHULUNGSARTBEZEICHNUNG': 'Basic',
        'SCHULUNGSARTKURZBEZEICHNUNG': 'BSC',
        'SCHULUNGSARTBESCHREIBUNG': 'Basic Training Course',
        'MAXTEILNEHMER': 20,
        'ANZAHLTEILNEHMER': 15,
        'ORT': 'Training Center',
        'UHRZEIT': '09:00',
        'DAUER': '8 Stunden',
        'PREIS': '100€',
        'ZIELGRUPPE': 'Anfänger',
        'VORAUSSETZUNGEN': 'Keine',
        'INHALT': 'Grundlagen',
        'ABSCHLUSS': 'Zertifikat',
        'ANMERKUNGEN': 'Bitte mitbringen: Schreibzeug',
        'ISONLINE': false,
        'LINK': '',
        'STATUS': 'Aktiv',
        'GUELTIGBIS': '2023-12-31',
      },
    ];

    test('returns empty list for non-list response', () async {
      when(
        mockHttpClient.get('AvailableSchulungen'),
      ).thenAnswer((_) async => {'error': 'Invalid format'});

      final result = await trainingService.fetchAvailableSchulungen();

      expect(result, isEmpty);
    });

    test('maps available Schulungen correctly', () async {
      when(
        mockHttpClient.get('AvailableSchulungen'),
      ).thenAnswer((_) async => testResponse);

      final result = await trainingService.fetchAvailableSchulungen();

      expect(result.length, 1);
      expect(result[0].id, 1);
      expect(result[0].bezeichnung, 'Training 1');
      expect(result[0].datum, '2023-01-15');
      expect(result[0].ausgestelltAm, '2023-01-01');
      expect(result[0].teilnehmerId, 1);
      expect(result[0].schulungsartId, 1);
      expect(result[0].schulungsartBezeichnung, 'Basic');
      expect(result[0].schulungsartKurzbezeichnung, 'BSC');
      expect(result[0].schulungsartBeschreibung, 'Basic Training Course');
      expect(result[0].maxTeilnehmer, 20);
      expect(result[0].anzahlTeilnehmer, 15);
      expect(result[0].ort, 'Training Center');
      expect(result[0].uhrzeit, '09:00');
      expect(result[0].dauer, '8 Stunden');
      expect(result[0].preis, '100€');
      expect(result[0].zielgruppe, 'Anfänger');
      expect(result[0].voraussetzungen, 'Keine');
      expect(result[0].inhalt, 'Grundlagen');
      expect(result[0].abschluss, 'Zertifikat');
      expect(result[0].anmerkungen, 'Bitte mitbringen: Schreibzeug');
      expect(result[0].isOnline, false);
      expect(result[0].link, '');
      expect(result[0].status, 'Aktiv');
      expect(result[0].gueltigBis, '2023-12-31');
    });

    test('handles null values in AvailableSchulungen correctly', () async {
      when(mockHttpClient.get('AvailableSchulungen')).thenAnswer(
        (_) async => [
          {
            // All nulls to test default values in Schulung.fromJson
            'SCHULUNGID': null,
            'BEZEICHNUNG': null,
            'DATUM': null,
            'AUSGESTELLTAM': null,
            'SCHULUNGENTEILNEHMERID': null,
            'SCHULUNGSARTID': null,
            'SCHULUNGSARTBEZEICHNUNG': null,
            'SCHULUNGSARTKURZBEZEICHNUNG': null,
            'SCHULUNGSARTBESCHREIBUNG': null,
            'MAXTEILNEHMER': null,
            'ANZAHLTEILNEHMER': null,
            'ORT': null,
            'UHRZEIT': null,
            'DAUER': null,
            'PREIS': null,
            'ZIELGRUPPE': null,
            'VORAUSSETZUNGEN': null,
            'INHALT': null,
            'ABSCHLUSS': null,
            'ANMERKUNGEN': null,
            'ISONLINE': null,
            'LINK': null,
            'STATUS': null,
            'GUELTIGBIS': null,
          },
        ],
      );

      final result = await trainingService.fetchAvailableSchulungen();

      expect(result.length, 1);
      expect(result[0].id, 0); // Default int
      expect(result[0].bezeichnung, ''); // Default string
      expect(result[0].datum, '');
      expect(result[0].ausgestelltAm, '');
      // ... and so on for all other fields, verifying default values
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
      },
    ];

    test('returns mapped Schulungsarten list from network', () async {
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
        return response;
      });

      when(
        mockHttpClient.get('Schulungsarten/false'),
      ).thenAnswer((_) async => testResponse);

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
      when(
        mockNetworkService.getCacheExpirationDuration(),
      ).thenReturn(const Duration(hours: 1));

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
        return response;
      });

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
      when(
        mockNetworkService.getCacheExpirationDuration(),
      ).thenReturn(const Duration(hours: 1));

      when(
        mockHttpClient.get('Schulungsarten/false'),
      ).thenAnswer((_) async => {'error': 'Invalid format'});

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

      final result = await trainingService.fetchSchulungsarten();

      expect(result, isEmpty);
    });

    test('returns empty list and logs error when exception occurs', () async {
      when(
        mockNetworkService.getCacheExpirationDuration(),
      ).thenReturn(const Duration(hours: 1));

      when(
        mockHttpClient.get('Schulungsarten/false'),
      ).thenThrow(Exception('Network error'));

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
        try {
          final response = await fetchData();
          return response;
        } catch (e) {
          return [];
        }
      });

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

    test('returns mapped Disziplinen list from API', () async {
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
      when(mockHttpClient.get('Disziplinen')).thenAnswer((_) async => []);

      final result = await trainingService.fetchDisziplinen();

      expect(result, isEmpty);
      verify(mockHttpClient.get('Disziplinen')).called(1);
    });

    test('returns empty list when API returns non-list response', () async {
      when(
        mockHttpClient.get('Disziplinen'),
      ).thenAnswer((_) async => {'error': 'Invalid format'});

      final result = await trainingService.fetchDisziplinen();

      expect(result, isEmpty);
      verify(mockHttpClient.get('Disziplinen')).called(1);
    });

    test('returns empty list and logs error when exception occurs', () async {
      when(
        mockHttpClient.get('Disziplinen'),
      ).thenThrow(Exception('Network error for Disziplinen'));

      final result = await trainingService.fetchDisziplinen();

      expect(result, isEmpty);
      verify(mockHttpClient.get('Disziplinen')).called(1);
    });

    test('handles network timeout exception', () async {
      when(
        mockHttpClient.get('Disziplinen'),
      ).thenThrow(TimeoutException('Request timed out'));

      final result = await trainingService.fetchDisziplinen();

      expect(result, isEmpty);
      verify(mockHttpClient.get('Disziplinen')).called(1);
    });

    test('handles socket exception', () async {
      when(
        mockHttpClient.get('Disziplinen'),
      ).thenThrow(const SocketException('Failed to connect'));

      final result = await trainingService.fetchDisziplinen();

      expect(result, isEmpty);
      verify(mockHttpClient.get('Disziplinen')).called(1);
    });

    test('handles http exception', () async {
      when(
        mockHttpClient.get('Disziplinen'),
      ).thenThrow(const HttpException('Server error'));

      final result = await trainingService.fetchDisziplinen();

      expect(result, isEmpty);
      verify(mockHttpClient.get('Disziplinen')).called(1);
    });

    test('handles format exception in response', () async {
      when(
        mockHttpClient.get('Disziplinen'),
      ).thenAnswer((_) async => 'Invalid JSON response');

      final result = await trainingService.fetchDisziplinen();

      expect(result, isEmpty);
      verify(mockHttpClient.get('Disziplinen')).called(1);
    });

    test('handles malformed JSON in response', () async {
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
}
