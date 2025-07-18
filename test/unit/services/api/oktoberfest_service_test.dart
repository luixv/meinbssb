import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/services/api/oktoberfest_service.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/models/gewinn.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'oktoberfest_service_test.mocks.dart';

@GenerateMocks([HttpClient, ConfigService])
void main() {
  late MockHttpClient mockHttpClient;
  late MockConfigService mockConfigService;
  late OktoberfestService service;

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockConfigService = MockConfigService();
    service = OktoberfestService(httpClient: mockHttpClient);
  });

  group('OktoberfestService.fetchGewinne', () {
    const int testJahr = 2024;
    const String testPassnummer = '12345';
    final testGewinnJson = {
      'GEWINNID': 1,
      'JAHR': 2024,
      'TRADITION': true,
      'ISSACHPREIS': false,
      'GELDPREIS': 10,
      'SACHPREIS': 'Medaille',
      'WETTBEWERB': 'Test',
      'ABGERUFENAM': '2024-01-01',
      'PLATZ': 1,
    };
    final testGewinn = Gewinn.fromJson(testGewinnJson);

    setUp(() {
      when(mockConfigService.getString(any, any)).thenReturn('dummy');
    });

    test('returns list of Gewinn when response is a List', () async {
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => [testGewinnJson]);
      final result = await service.fetchGewinne(
        jahr: testJahr,
        passnummer: testPassnummer,
        configService: mockConfigService,
      );
      expect(result, isA<List<Gewinn>>());
      expect(result.length, 1);
      expect(result.first.gewinnId, testGewinn.gewinnId);
    });

    test('returns list with one Gewinn when response is a Map', () async {
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => testGewinnJson);
      final result = await service.fetchGewinne(
        jahr: testJahr,
        passnummer: testPassnummer,
        configService: mockConfigService,
      );
      expect(result, isA<List<Gewinn>>());
      expect(result.length, 1);
      expect(result.first.gewinnId, testGewinn.gewinnId);
    });

    test('returns empty list for unexpected response type', () async {
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => 'unexpected');
      final result = await service.fetchGewinne(
        jahr: testJahr,
        passnummer: testPassnummer,
        configService: mockConfigService,
      );
      expect(result, isEmpty);
    });

    test('returns empty list on exception', () async {
      when(
        mockHttpClient.get(
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenThrow(Exception('network error'));
      final result = await service.fetchGewinne(
        jahr: testJahr,
        passnummer: testPassnummer,
        configService: mockConfigService,
      );
      expect(result, isEmpty);
    });
  });

  group('OktoberfestService.gewinneAbrufen', () {
    const iban = 'DE00000';
    const passnummer = '70100100';
    final gewinnIDs = [50, 185];
    final requestBody = {
      'GewinnIDs': gewinnIDs,
      'IBAN': iban,
      'Passnummer': int.parse(passnummer),
    };

    setUp(() {
      when(mockConfigService.getString(any, any)).thenReturn('dummy');
    });

    test('returns true when response is {"result": true}', () async {
      when(
        mockHttpClient.post(
          any,
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => {'result': true});
      final result = await service.gewinneAbrufen(
        gewinnIDs: gewinnIDs,
        iban: iban,
        passnummer: passnummer,
        configService: mockConfigService,
      );
      expect(result, isTrue);
    });

    test('returns false and logs error when response contains Error', () async {
      final errorResponse = {
        'Error': [
          'Gewinnabruf konnte nicht durchgeführt werden. GewinnID: 185',
        ],
      };
      when(
        mockHttpClient.post(
          any,
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => errorResponse);
      final result = await service.gewinneAbrufen(
        gewinnIDs: gewinnIDs,
        iban: iban,
        passnummer: passnummer,
        configService: mockConfigService,
      );
      expect(result, isFalse);
      // LoggerService.logError should be called (not directly testable)
    });

    test('returns false and logs warning for unexpected response type',
        () async {
      when(
        mockHttpClient.post(
          any,
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => 'unexpected');
      final result = await service.gewinneAbrufen(
        gewinnIDs: gewinnIDs,
        iban: iban,
        passnummer: passnummer,
        configService: mockConfigService,
      );
      expect(result, isFalse);
      // LoggerService.logWarning should be called (not directly testable)
    });

    test('returns false and logs error on exception', () async {
      when(
        mockHttpClient.post(
          any,
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenThrow(Exception('network error'));
      final result = await service.gewinneAbrufen(
        gewinnIDs: gewinnIDs,
        iban: iban,
        passnummer: passnummer,
        configService: mockConfigService,
      );
      expect(result, isFalse);
      // LoggerService.logError should be called (not directly testable)
    });

    test('sends correct body to HttpClient', () async {
      when(
        mockHttpClient.post(
          any,
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => {'result': true});
      await service.gewinneAbrufen(
        gewinnIDs: gewinnIDs,
        iban: iban,
        passnummer: passnummer,
        configService: mockConfigService,
      );
      verify(
        mockHttpClient.post(
          'GewinneAbrufen',
          requestBody,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).called(1);
    });
  });
}
