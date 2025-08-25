import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/api/verein_service.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/models/verein_data.dart';
import 'package:meinbssb/models/fremde_verband_data.dart';

@GenerateMocks([
  HttpClient,
])
import 'verein_service_test.mocks.dart';

void main() {
  late MockHttpClient mockHttpClient;
  late VereinService vereinService;

  setUp(() {
    mockHttpClient = MockHttpClient();
    vereinService = VereinService(httpClient: mockHttpClient);
  });

  tearDown(() {
    reset(mockHttpClient);
  });

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

      when(mockHttpClient.get('Vereine')).thenAnswer((_) async => testResponse);

      final result = await vereinService.fetchVereine();

      expect(result, isA<List<Verein>>());
      expect(result.length, 1);
      expect(result[0].id, 1);
      expect(result[0].name, 'Test Verein');
      expect(result[0].lat, 48.1351);
      expect(result[0].lon, 11.5820);
      verify(mockHttpClient.get('Vereine')).called(1);
    });

    test('returns empty list when API returns non-list response', () async {
      when(mockHttpClient.get('Vereine'))
          .thenAnswer((_) async => {'error': 'Invalid data'});

      final result = await vereinService.fetchVereine();

      expect(result, isEmpty);
      verify(mockHttpClient.get('Vereine')).called(1);
    });

    test('returns empty list and logs error when exception occurs', () async {
      when(mockHttpClient.get('Vereine')).thenThrow(Exception('Network error'));

      final result = await vereinService.fetchVereine();

      expect(result, isEmpty);
      verify(mockHttpClient.get('Vereine')).called(1);
    });

    test('handles partial data correctly', () async {
      final testResponse = [
        {
          'VEREINID': 2,
          'VEREINNR': 'V002',
          'VEREINNAME': 'Partial Data Club',
          // Missing other fields
        }
      ];

      when(mockHttpClient.get('Vereine')).thenAnswer((_) async => testResponse);

      final result = await vereinService.fetchVereine();

      expect(result.length, 1);
      expect(result[0].name, 'Partial Data Club');
      expect(
        result[0].gauId,
        isNull,
      ); // Should handle missing fields gracefully
    });

    test('filters out invalid items', () async {
      final testResponse = [
        {
          'VEREINID': 1,
          'VEREINNR': 'V001',
          'VEREINNAME': 'Valid Club',
        },
        'Invalid item', // Non-map item
        {
          'VEREINNAME': 'Missing ID', // Missing required field
        },
      ];

      when(mockHttpClient.get('Vereine')).thenAnswer((_) async => testResponse);

      final result = await vereinService.fetchVereine();

      expect(result.length, 1);
      expect(result[0].name, 'Valid Club');
    });
  });

  group('fetchVerein', () {
    const testVereinsNr = 12345;

    test('returns mapped verein details from API', () async {
      final testResponse = [
        {
          'VEREINID': 1,
          'VEREINNR': 'V001',
          'VEREINNAME': 'Test Verein',
          'STRASSE': 'Teststraße 1',
          'PLZ': '12345',
          'ORT': 'Musterstadt',
          'TELEFON': '0123456789',
          'EMAIL': 'test@verein.de',
          'HOMEPAGE': 'https://verein.de',
          'OEFFNUNGSZEITEN': 'Mo-Fr 10-18',
          'NAMEN': 'Mustermann',
          'VORNAME': 'Max',
          'P_STRASSE': 'Poststraße 1',
          'P_PLZ': '54321',
          'P_ORT': 'Poststadt',
          'P_EMAIL': 'post@test.de',
          'GAUID': 101,
          'GAUNR': 'GAU01',
          'GAUNAME': 'Test Gau',
          'BEZIRKID': 201,
          'BEZIRKNR': 'BZ01',
          'BEZIRKNAME': 'Test Bezirk',
          'LAT': 48.1351,
          'LON': 11.5820,
          'GEOCODEQUELLE': 'Google',
          'FACEBOOK': 'fb.com/test',
          'INSTAGRAM': 'insta.com/test',
          'XTWITTER': 'x.com/test',
          'TIKTOK': 'tiktok.com/test',
          'TWITCH': 'twitch.com/test',
          'ANZAHLMITGLIEDER': 100,
        }
      ];

      when(mockHttpClient.get('Verein/$testVereinsNr'))
          .thenAnswer((_) async => testResponse);

      final result = await vereinService.fetchVerein(testVereinsNr);

      expect(result, isA<List<Verein>>());
      expect(result.length, 1);
      expect(result[0].id, 1);
      expect(result[0].name, 'Test Verein');
      expect(result[0].email, 'test@verein.de');
      expect(result[0].anzahlMitglieder, 100);
      verify(mockHttpClient.get('Verein/$testVereinsNr')).called(1);
    });

    test('returns empty list when API returns empty response', () async {
      when(mockHttpClient.get('Verein/$testVereinsNr'))
          .thenAnswer((_) async => []);

      final result = await vereinService.fetchVerein(testVereinsNr);

      expect(result, isEmpty);
      verify(mockHttpClient.get('Verein/$testVereinsNr')).called(1);
    });

    test('returns empty list when API returns non-list response', () async {
      when(mockHttpClient.get('Verein/$testVereinsNr'))
          .thenAnswer((_) async => {'error': 'Not found'});

      final result = await vereinService.fetchVerein(testVereinsNr);

      expect(result, isEmpty);
      verify(mockHttpClient.get('Verein/$testVereinsNr')).called(1);
    });

    test('handles partial data gracefully', () async {
      final testResponse = [
        {
          'VEREINID': 2,
          'VEREINNR': 'V002',
          'VEREINNAME': 'Partial Data Club',
          // Missing many fields
        }
      ];

      when(mockHttpClient.get('Verein/$testVereinsNr'))
          .thenAnswer((_) async => testResponse);

      final result = await vereinService.fetchVerein(testVereinsNr);

      expect(result.length, 1);
      expect(result[0].name, 'Partial Data Club');
      expect(result[0].email, isNull); // Missing field should be null
    });

    test('returns empty list and logs error when exception occurs', () async {
      when(mockHttpClient.get('Verein/$testVereinsNr'))
          .thenThrow(Exception('Network error'));

      final result = await vereinService.fetchVerein(testVereinsNr);

      expect(result, isEmpty);
      verify(mockHttpClient.get('Verein/$testVereinsNr')).called(1);
    });

    test('handles invalid vereinsNr parameter', () async {
      const invalidVereinsNr = 0;

      final result = await vereinService.fetchVerein(invalidVereinsNr);

      expect(result, isEmpty);
      verify(mockHttpClient.get('Verein/$invalidVereinsNr')).called(1);
    });

    test('filters out invalid items in response', () async {
      final testResponse = [
        {
          'VEREINID': 1,
          'VEREINNR': 'V001',
          'VEREINNAME': 'Valid Club',
        },
        'Invalid item', // Non-map item
        {
          'VEREINNAME': 'Missing ID', // Missing required field
        },
      ];

      when(mockHttpClient.get('Verein/$testVereinsNr'))
          .thenAnswer((_) async => testResponse);

      final result = await vereinService.fetchVerein(testVereinsNr);

      expect(result.length, 1);
      expect(result[0].name, 'Valid Club');
    });
  });

  group('fetchFremdeVerbaende', () {
    test('returns mapped fremde verbaende list from API', () async {
      final testResponse = [
        {
          'VEREINID': 4777,
          'VEREINNR': 999901,
          'VEREINNAME': 'Badischer SB',
        },
        {
          'VEREINID': 4778,
          'VEREINNR': 999902,
          'VEREINNAME': 'Württembergischer SB',
        },
      ];

      when(mockHttpClient.get('FremdeVerbaende'))
          .thenAnswer((_) async => testResponse);

      final result = await vereinService.fetchFremdeVerbaende();

      expect(result, isA<List<FremdeVerband>>());
      expect(result.length, 2);
      expect(result[0].vereinId, 4777);
      expect(result[0].vereinNr, 999901);
      expect(result[0].vereinName, 'Badischer SB');
      expect(result[1].vereinId, 4778);
      expect(result[1].vereinNr, 999902);
      expect(result[1].vereinName, 'Württembergischer SB');
      verify(mockHttpClient.get('FremdeVerbaende')).called(1);
    });

    test('returns empty list when API returns non-list response', () async {
      when(mockHttpClient.get('FremdeVerbaende'))
          .thenAnswer((_) async => {'error': 'Invalid data'});

      final result = await vereinService.fetchFremdeVerbaende();

      expect(result, isEmpty);
      verify(mockHttpClient.get('FremdeVerbaende')).called(1);
    });

    test('returns empty list and logs error when exception occurs', () async {
      when(mockHttpClient.get('FremdeVerbaende'))
          .thenThrow(Exception('Network error'));

      final result = await vereinService.fetchFremdeVerbaende();

      expect(result, isEmpty);
      verify(mockHttpClient.get('FremdeVerbaende')).called(1);
    });

    test('handles invalid items in response', () async {
      final testResponse = [
        {
          'VEREINID': 4777,
          'VEREINNR': 999901,
          'VEREINNAME': 'Badischer SB',
        },
        'Invalid item', // Non-map item
        {
          'VEREINNAME': 'Missing ID', // Missing required field
        },
      ];

      when(mockHttpClient.get('FremdeVerbaende'))
          .thenAnswer((_) async => testResponse);

      final result = await vereinService.fetchFremdeVerbaende();

      expect(result.length, 1);
      expect(result[0].vereinName, 'Badischer SB');
    });

    test('handles items with invalid field types', () async {
      final testResponse = [
        {
          'VEREINID': 4777,
          'VEREINNR': 999901,
          'VEREINNAME': 'Badischer SB',
        },
        {
          'VEREINID': 'not_an_integer',
          'VEREINNR': 999902,
          'VEREINNAME': 'Württembergischer SB',
        },
      ];

      when(mockHttpClient.get('FremdeVerbaende'))
          .thenAnswer((_) async => testResponse);

      final result = await vereinService.fetchFremdeVerbaende();

      expect(result.length, 1);
      expect(result[0].vereinName, 'Badischer SB');
    });
  });
}
