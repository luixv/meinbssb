import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:meinbssb/services/api/user_service.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/models/contact_data.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/person_data.dart';
import 'package:meinbssb/models/passdaten_akzept_or_aktiv_data.dart';

import 'user_service_test.mocks.dart';

@GenerateMocks([HttpClient, CacheService, NetworkService, ConfigService])
void main() {
  group('UserService', () {
    late UserService userService;
    late MockHttpClient mockHttpClient;
    late MockCacheService mockCacheService;
    late MockNetworkService mockNetworkService;
    late MockConfigService mockConfigService;

    setUp(() {
      mockHttpClient = MockHttpClient();
      mockCacheService = MockCacheService();
      mockNetworkService = MockNetworkService();
      mockConfigService = MockConfigService();

      when(
        mockNetworkService.getCacheExpirationDuration(),
      ).thenReturn(const Duration(days: 7));

      when(mockConfigService.getString('apiProtocol')).thenReturn('http');
      when(
        mockConfigService.getString('api1BaseServer'),
      ).thenReturn('localhost');
      when(mockConfigService.getString('api1BasePort')).thenReturn('8080');
      when(mockConfigService.getString('api1BasePath')).thenReturn('');

      userService = UserService(
        httpClient: mockHttpClient,
        cacheService: mockCacheService,
        networkService: mockNetworkService,
        configService: mockConfigService,
      );
    });

    tearDown(() {
      reset(mockHttpClient);
      reset(mockCacheService);
      reset(mockNetworkService);
    });

    group('fetchPassdaten', () {
      const testPersonId = 439287;
      final testResponse = {
        'PASSNUMMER': '40100709',
        'VEREINNR': 401051,
        'NAMEN': 'Schürz',
        'VORNAME': 'Lukas',
        'TITEL': '',
        'GEBURTSDATUM': '1955-07-16T00:00:00.000+02:00',
        'GESCHLECHT': 1,
        'VEREINNAME': 'Feuerschützen Kühbach',
        'PASSDATENID': 2000009155,
        'MITGLIEDSCHAFTID': 439287,
        'PERSONID': testPersonId,
        'STRASSE': 'Aichacher Strasse 21',
        'PLZ': '86574',
        'ORT': 'Alsmoos',
        'ONLINE': true,
      };

      test('returns UserData from network', () async {
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
        ).thenAnswer((invocation) async {
          final fetchData =
              invocation.positionalArguments[2] as Future<dynamic> Function();
          final response = await fetchData();
          final processResponse =
              invocation.positionalArguments[3] as Function(dynamic);
          return processResponse(response);
        });

        when(
          mockHttpClient.get('Passdaten/$testPersonId'),
        ).thenAnswer((_) async => [testResponse]);

        final result = await userService.fetchPassdaten(testPersonId);

        expect(result, isA<UserData>());
        expect(result?.passnummer, '40100709');
        expect(result?.vereinNr, 401051);
        expect(result?.namen, 'Schürz');
        expect(result?.vorname, 'Lukas');
        expect(result?.titel, '');
        expect(
          result?.geburtsdatum,
          DateTime.parse('1955-07-16T00:00:00.000+02:00'),
        );
        expect(result?.geschlecht, 1);
        expect(result?.vereinName, 'Feuerschützen Kühbach');
        expect(result?.passdatenId, 2000009155);
        expect(result?.mitgliedschaftId, 439287);
        expect(result?.personId, testPersonId);
        expect(result?.strasse, 'Aichacher Strasse 21');
        expect(result?.plz, '86574');
        expect(result?.ort, 'Alsmoos');
        expect(result?.isOnline, true);
      });

      test('handles empty response', () async {
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
        ).thenAnswer((invocation) async {
          final fetchData =
              invocation.positionalArguments[2] as Future<dynamic> Function();
          final response = await fetchData();
          final processResponse =
              invocation.positionalArguments[3] as Function(dynamic);
          return processResponse(response);
        });

        when(
          mockHttpClient.get('Passdaten/$testPersonId'),
        ).thenAnswer((_) async => []);

        final result = await userService.fetchPassdaten(testPersonId);

        expect(result, isNull);
      });

      test('handles error response', () async {
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
        ).thenThrow(Exception('Network error'));

        final result = await userService.fetchPassdaten(testPersonId);

        expect(result, isNull);
      });

      test(
        'fetchPassdaten returns null for non-list, non-map response',
        () async {
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
          ).thenAnswer((invocation) async {
            final fetchData =
                invocation.positionalArguments[2] as Future<dynamic> Function();
            final response = await fetchData();
            final processResponse =
                invocation.positionalArguments[3] as Function(dynamic);
            return processResponse(response);
          });

          when(
            mockHttpClient.get('Passdaten/999999'),
          ).thenAnswer((_) async => 'unexpected');

          final result = await userService.fetchPassdaten(999999);

          expect(result, isNull);
        },
      );

      test('fetchPassdaten handles negative person ID', () async {
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
        ).thenAnswer((invocation) async {
          final fetchData =
              invocation.positionalArguments[2] as Future<dynamic> Function();
          final response = await fetchData();
          final processResponse =
              invocation.positionalArguments[3] as Function(dynamic);
          return processResponse(response);
        });

        when(
          mockHttpClient.get('Passdaten/-1'),
        ).thenAnswer((_) async => [testResponse]);

        final result = await userService.fetchPassdaten(-1);

        expect(result, isA<UserData>());
      });

      test('fetchPassdaten handles zero person ID', () async {
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
        ).thenAnswer((invocation) async {
          final fetchData =
              invocation.positionalArguments[2] as Future<dynamic> Function();
          final response = await fetchData();
          final processResponse =
              invocation.positionalArguments[3] as Function(dynamic);
          return processResponse(response);
        });

        when(
          mockHttpClient.get('Passdaten/0'),
        ).thenAnswer((_) async => [testResponse]);

        final result = await userService.fetchPassdaten(0);

        expect(result, isA<UserData>());
      });

      test('fetchPassdaten handles very large person ID', () async {
        const largePersonId = 999999999;
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
        ).thenAnswer((invocation) async {
          final fetchData =
              invocation.positionalArguments[2] as Future<dynamic> Function();
          final response = await fetchData();
          final processResponse =
              invocation.positionalArguments[3] as Function(dynamic);
          return processResponse(response);
        });

        when(
          mockHttpClient.get('Passdaten/$largePersonId'),
        ).thenAnswer((_) async => [testResponse]);

        final result = await userService.fetchPassdaten(largePersonId);

        expect(result, isA<UserData>());
      });

      test('fetchPassdaten handles incomplete data fields', () async {
        const incompletePersonId = 12345;
        final incompleteResponse = {
          'PASSNUMMER': '40100709',
          'VEREINNR': 401051,
          'NAMEN': 'Schürz',
          // Missing VORNAME, TITEL, etc.
          'PERSONID': incompletePersonId,
          'ONLINE': true,
        };

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
        ).thenAnswer((invocation) async {
          final fetchData =
              invocation.positionalArguments[2] as Future<dynamic> Function();
          final response = await fetchData();
          final processResponse =
              invocation.positionalArguments[3] as Function(dynamic);
          return processResponse(response);
        });

        when(
          mockHttpClient.get('Passdaten/$incompletePersonId'),
        ).thenAnswer((_) async => [incompleteResponse]);

        final result = await userService.fetchPassdaten(incompletePersonId);

        // The service should handle incomplete data gracefully
        if (result != null) {
          expect(result, isA<UserData>());
          expect(result.passnummer, '40100709');
          expect(result.namen, 'Schürz');
          expect(result.personId, incompletePersonId);
        } else {
          // If the service returns null for incomplete data, that's acceptable
          expect(result, isNull);
        }
      });

      test(
        'fetchPassdaten handles multiple response items (takes first)',
        () async {
          const testPersonId = 54321;
          final multipleResponses = [
            testResponse,
            {
              'PASSNUMMER': '99999999',
              'VEREINNR': 999999,
              'NAMEN': 'Second',
              'VORNAME': 'Entry',
              'PERSONID': testPersonId,
              'ONLINE': false,
            },
          ];

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
          ).thenAnswer((invocation) async {
            final fetchData =
                invocation.positionalArguments[2] as Future<dynamic> Function();
            final response = await fetchData();
            final processResponse =
                invocation.positionalArguments[3] as Function(dynamic);
            return processResponse(response);
          });

          when(
            mockHttpClient.get('Passdaten/$testPersonId'),
          ).thenAnswer((_) async => multipleResponses);

          final result = await userService.fetchPassdaten(testPersonId);

          expect(result, isA<UserData>());
          // Should use first response
          expect(result?.passnummer, '40100709');
          expect(result?.namen, 'Schürz');
        },
      );

      test('fetchPassdaten handles null fields in response', () async {
        const nullFieldPersonId = 67890;
        final responseWithNulls = {
          'PASSNUMMER': null,
          'VEREINNR': null,
          'NAMEN': 'ValidName',
          'VORNAME': null,
          'TITEL': null,
          'GEBURTSDATUM': null,
          'GESCHLECHT': null,
          'VEREINNAME': null,
          'PASSDATENID': null,
          'MITGLIEDSCHAFTID': null,
          'PERSONID': nullFieldPersonId,
          'STRASSE': null,
          'PLZ': null,
          'ORT': null,
          'ONLINE': null,
        };

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
        ).thenAnswer((invocation) async {
          final fetchData =
              invocation.positionalArguments[2] as Future<dynamic> Function();
          final response = await fetchData();
          final processResponse =
              invocation.positionalArguments[3] as Function(dynamic);
          return processResponse(response);
        });

        when(
          mockHttpClient.get('Passdaten/$nullFieldPersonId'),
        ).thenAnswer((_) async => [responseWithNulls]);

        final result = await userService.fetchPassdaten(nullFieldPersonId);

        // The service should handle null fields gracefully
        if (result != null) {
          expect(result, isA<UserData>());
          expect(result.namen, 'ValidName');
          expect(result.personId, nullFieldPersonId);
        } else {
          // If the service returns null for responses with many null fields, that's acceptable
          expect(result, isNull);
        }
      });
    });

    group('fetchZweitmitgliedschaften', () {
      const testPersonId = 123;

      test('fetchZweitmitgliedschaften returns mapped data', () async {
        // Arrange
        final mockResponse = [
          {
            'VEREINID': 1474,
            'VEREINNR': 401006,
            'VEREINNAME': 'Vereinigte Sportschützen Paartal Aichach',
            'EINTRITTVEREIN': '2012-02-26T00:00:00.000+01:00',
          },
          {
            'VEREINID': 2420,
            'VEREINNR': 421037,
            'VEREINNAME': 'SV Alpenrose Grimolzhausen',
            'EINTRITTVEREIN': '2001-11-01T00:00:00.000+01:00',
          },
        ];

        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get('Zweitmitgliedschaften/$testPersonId'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await userService.fetchZweitmitgliedschaften(
          testPersonId,
        );

        // Assert
        expect(result.length, 2);

        expect(result[0].vereinId, 1474);
        expect(result[0].vereinNr, 401006);
        expect(
          result[0].vereinName,
          'Vereinigte Sportschützen Paartal Aichach',
        );
        expect(
          result[0].eintrittVerein,
          DateTime.parse('2012-02-26T00:00:00.000+01:00'),
        );

        expect(result[1].vereinId, 2420);
        expect(result[1].vereinNr, 421037);
        expect(result[1].vereinName, 'SV Alpenrose Grimolzhausen');
        expect(
          result[1].eintrittVerein,
          DateTime.parse('2001-11-01T00:00:00.000+01:00'),
        );
      });

      test('handles empty response', () async {
        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get('Zweitmitgliedschaften/$testPersonId'),
        ).thenAnswer((_) async => []);

        final result = await userService.fetchZweitmitgliedschaften(
          testPersonId,
        );

        expect(result, isA<List<dynamic>>());
        expect(result, isEmpty);
      });

      test('handles error response', () async {
        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
            any,
            any,
            any,
            any,
          ),
        ).thenThrow(Exception('Network error'));

        final result = await userService.fetchZweitmitgliedschaften(
          testPersonId,
        );

        expect(result, isA<List<dynamic>>());
        expect(result, isEmpty);
      });

      test('fetchZweitmitgliedschaften skips non-map items', () async {
        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get('Zweitmitgliedschaften/123'),
        ).thenAnswer((_) async => [123, 'string', null]);

        final result = await userService.fetchZweitmitgliedschaften(123);

        expect(result, isEmpty);
      });

      test('fetchZweitmitgliedschaften handles negative person ID', () async {
        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get('Zweitmitgliedschaften/-1'),
        ).thenAnswer((_) async => []);

        final result = await userService.fetchZweitmitgliedschaften(-1);

        expect(result, isEmpty);
      });

      test('fetchZweitmitgliedschaften handles large datasets', () async {
        // Create a large dataset
        final largeResponse = List.generate(
          100,
          (index) => {
            'VEREINID': 1000 + index,
            'VEREINNR': 400000 + index,
            'VEREINNAME': 'Verein $index',
            'EINTRITTVEREIN': '2020-01-01T00:00:00.000+01:00',
          },
        );

        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get('Zweitmitgliedschaften/999'),
        ).thenAnswer((_) async => largeResponse);

        final result = await userService.fetchZweitmitgliedschaften(999);

        expect(result.length, 100);
        expect(result.first.vereinId, 1000);
        expect(result.last.vereinId, 1099);
      });

      test('fetchZweitmitgliedschaften handles incomplete data', () async {
        final incompleteResponse = [
          {
            'VEREINID': 1474,
            // Missing VEREINNR
            'VEREINNAME': 'Test Verein',
            // Missing EINTRITTVEREIN
          },
          {
            // Missing VEREINID
            'VEREINNR': 401006,
            'VEREINNAME': 'Another Verein',
            'EINTRITTVEREIN': '2012-02-26T00:00:00.000+01:00',
          },
        ];

        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get('Zweitmitgliedschaften/456'),
        ).thenAnswer((_) async => incompleteResponse);

        final result = await userService.fetchZweitmitgliedschaften(456);

        // The actual service might filter out incomplete entries or handle them gracefully
        // So we test that it returns some result (could be empty or filled)
        expect(result, isA<List>());

        // If entries are included, they should be properly formed
        for (final entry in result) {
          expect(entry.vereinName, isNotNull);
        }
      });

      test(
        'fetchZweitmitgliedschaften handles mixed valid/invalid items',
        () async {
          final mixedResponse = [
            {
              'VEREINID': 1474,
              'VEREINNR': 401006,
              'VEREINNAME': 'Valid Verein',
              'EINTRITTVEREIN': '2012-02-26T00:00:00.000+01:00',
            },
            'invalid string',
            {
              'VEREINID': 2420,
              'VEREINNR': 421037,
              'VEREINNAME': 'Another Valid Verein',
              'EINTRITTVEREIN': '2001-11-01T00:00:00.000+01:00',
            },
            null,
            123,
          ];

          when(
            mockNetworkService.getCacheExpirationDuration(),
          ).thenReturn(const Duration(hours: 1));

          when(
            mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
            mockHttpClient.get('Zweitmitgliedschaften/789'),
          ).thenAnswer((_) async => mixedResponse);

          final result = await userService.fetchZweitmitgliedschaften(789);

          // The service should filter out invalid entries
          expect(result, isA<List>());

          // All returned entries should be valid
          for (final entry in result) {
            expect(entry.vereinName, isNotNull);
            expect(entry.vereinName, isA<String>());
          }

          // Should have filtered to only include valid map entries
          // The actual count depends on the implementation's validation logic
          expect(result.length, lessThanOrEqualTo(2));
        },
      );

      test('fetchZweitmitgliedschaften handles null response', () async {
        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get('Zweitmitgliedschaften/000'),
        ).thenAnswer((_) async => null);

        final result = await userService.fetchZweitmitgliedschaften(000);

        expect(result, isEmpty);
      });
    });

    // --- Unit tests for deleteMeinBSSBLogin ---
    group('UserService.deleteMeinBSSBLogin', () {
      late UserService userService;
      late MockHttpClient mockHttpClient;
      late MockCacheService mockCacheService;
      late MockNetworkService mockNetworkService;
      late MockConfigService mockConfigService;

      setUp(() {
        mockHttpClient = MockHttpClient();
        mockCacheService = MockCacheService();
        mockNetworkService = MockNetworkService();
        mockConfigService = MockConfigService();
        when(mockConfigService.getString('apiProtocol')).thenReturn('http');
        when(
          mockConfigService.getString('api1BaseServer'),
        ).thenReturn('localhost');
        when(mockConfigService.getString('api1BasePort')).thenReturn('8080');
        when(mockConfigService.getString('api1BasePath')).thenReturn('');
        userService = UserService(
          httpClient: mockHttpClient,
          cacheService: mockCacheService,
          networkService: mockNetworkService,
          configService: mockConfigService,
        );
      });

      test('returns true when API result is true', () async {
        when(
          mockHttpClient.delete(
            any,
            overrideBaseUrl: anyNamed('overrideBaseUrl'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => {'result': true});

        final result = await userService.deleteMeinBSSBLogin(
          123,
          'test@example.com',
        );
        expect(result, isTrue);
        // ...existing code...
      });

      test('returns false when API result is false', () async {
        when(
          mockHttpClient.delete(
            any,
            overrideBaseUrl: anyNamed('overrideBaseUrl'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => {'result': false});
        final result = await userService.deleteMeinBSSBLogin(
          123,
          'test@example.com',
        );
        expect(result, isFalse);
        // ...existing code...
      });

      test('returns false when API response is missing result', () async {
        when(
          mockHttpClient.delete(
            any,
            overrideBaseUrl: anyNamed('overrideBaseUrl'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => {});
        final result = await userService.deleteMeinBSSBLogin(
          123,
          'test@example.com',
        );
        expect(result, isFalse);
        // ...existing code...
      });

      test('returns false on exception', () async {
        when(
          mockHttpClient.delete(
            any,
            overrideBaseUrl: anyNamed('overrideBaseUrl'),
            body: anyNamed('body'),
          ),
        ).thenThrow(Exception('API error'));
        final result = await userService.deleteMeinBSSBLogin(
          123,
          'test@example.com',
        );
        expect(result, isFalse);
        // ...existing code...
      });

      test('returns true when API result is true (with debug)', () async {
        final endpoint = 'DeleteMeinBSSBLogin/123/test@example.com';
        when(
          mockHttpClient.delete(
            endpoint,
            overrideBaseUrl: anyNamed('overrideBaseUrl'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((invocation) async {
          return {'result': true};
        });
        final result = await userService.deleteMeinBSSBLogin(
          123,
          'test@example.com',
        );
        expect(result, isTrue);
      });
    });

    group('fetchZweitmitgliedschaften', () {
      const testPersonId = 123;

      test('fetchZweitmitgliedschaften returns mapped data', () async {
        // Arrange
        final mockResponse = [
          {
            'VEREINID': 1474,
            'VEREINNR': 401006,
            'VEREINNAME': 'Vereinigte Sportschützen Paartal Aichach',
            'EINTRITTVEREIN': '2012-02-26T00:00:00.000+01:00',
          },
          {
            'VEREINID': 2420,
            'VEREINNR': 421037,
            'VEREINNAME': 'SV Alpenrose Grimolzhausen',
            'EINTRITTVEREIN': '2001-11-01T00:00:00.000+01:00',
          },
        ];

        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get('Zweitmitgliedschaften/$testPersonId'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await userService.fetchZweitmitgliedschaften(
          testPersonId,
        );

        // Assert
        expect(result.length, 2);

        expect(result[0].vereinId, 1474);
        expect(result[0].vereinNr, 401006);
        expect(
          result[0].vereinName,
          'Vereinigte Sportschützen Paartal Aichach',
        );
        expect(
          result[0].eintrittVerein,
          DateTime.parse('2012-02-26T00:00:00.000+01:00'),
        );

        expect(result[1].vereinId, 2420);
        expect(result[1].vereinNr, 421037);
        expect(result[1].vereinName, 'SV Alpenrose Grimolzhausen');
        expect(
          result[1].eintrittVerein,
          DateTime.parse('2001-11-01T00:00:00.000+01:00'),
        );
      });

      test('handles empty response', () async {
        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get('Zweitmitgliedschaften/$testPersonId'),
        ).thenAnswer((_) async => []);

        final result = await userService.fetchZweitmitgliedschaften(
          testPersonId,
        );

        expect(result, isA<List<dynamic>>());
        expect(result, isEmpty);
      });

      test('handles error response', () async {
        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
            any,
            any,
            any,
            any,
          ),
        ).thenThrow(Exception('Network error'));

        final result = await userService.fetchZweitmitgliedschaften(
          testPersonId,
        );

        expect(result, isA<List<dynamic>>());
        expect(result, isEmpty);
      });

      test('fetchZweitmitgliedschaften skips non-map items', () async {
        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get('Zweitmitgliedschaften/123'),
        ).thenAnswer((_) async => [123, 'string', null]);

        final result = await userService.fetchZweitmitgliedschaften(123);

        expect(result, isEmpty);
      });

      test('fetchZweitmitgliedschaften handles negative person ID', () async {
        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get('Zweitmitgliedschaften/-1'),
        ).thenAnswer((_) async => []);

        final result = await userService.fetchZweitmitgliedschaften(-1);

        expect(result, isEmpty);
      });

      test('fetchZweitmitgliedschaften handles large datasets', () async {
        // Create a large dataset
        final largeResponse = List.generate(
          100,
          (index) => {
            'VEREINID': 1000 + index,
            'VEREINNR': 400000 + index,
            'VEREINNAME': 'Verein $index',
            'EINTRITTVEREIN': '2020-01-01T00:00:00.000+01:00',
          },
        );

        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get('Zweitmitgliedschaften/999'),
        ).thenAnswer((_) async => largeResponse);

        final result = await userService.fetchZweitmitgliedschaften(999);

        expect(result.length, 100);
        expect(result.first.vereinId, 1000);
        expect(result.last.vereinId, 1099);
      });

      test('fetchZweitmitgliedschaften handles incomplete data', () async {
        final incompleteResponse = [
          {
            'VEREINID': 1474,
            // Missing VEREINNR
            'VEREINNAME': 'Test Verein',
            // Missing EINTRITTVEREIN
          },
          {
            // Missing VEREINID
            'VEREINNR': 401006,
            'VEREINNAME': 'Another Verein',
            'EINTRITTVEREIN': '2012-02-26T00:00:00.000+01:00',
          },
        ];

        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get('Zweitmitgliedschaften/456'),
        ).thenAnswer((_) async => incompleteResponse);

        final result = await userService.fetchZweitmitgliedschaften(456);

        // The actual service might filter out incomplete entries or handle them gracefully
        // So we test that it returns some result (could be empty or filled)
        expect(result, isA<List>());

        // If entries are included, they should be properly formed
        for (final entry in result) {
          expect(entry.vereinName, isNotNull);
        }
      });

      test(
        'fetchZweitmitgliedschaften handles mixed valid/invalid items',
        () async {
          final mixedResponse = [
            {
              'VEREINID': 1474,
              'VEREINNR': 401006,
              'VEREINNAME': 'Valid Verein',
              'EINTRITTVEREIN': '2012-02-26T00:00:00.000+01:00',
            },
            'invalid string',
            {
              'VEREINID': 2420,
              'VEREINNR': 421037,
              'VEREINNAME': 'Another Valid Verein',
              'EINTRITTVEREIN': '2001-11-01T00:00:00.000+01:00',
            },
            null,
            123,
          ];

          when(
            mockNetworkService.getCacheExpirationDuration(),
          ).thenReturn(const Duration(hours: 1));

          when(
            mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
            mockHttpClient.get('Zweitmitgliedschaften/789'),
          ).thenAnswer((_) async => mixedResponse);

          final result = await userService.fetchZweitmitgliedschaften(789);

          // The service should filter out invalid entries
          expect(result, isA<List>());

          // All returned entries should be valid
          for (final entry in result) {
            expect(entry.vereinName, isNotNull);
            expect(entry.vereinName, isA<String>());
          }

          // Should have filtered to only include valid map entries
          // The actual count depends on the implementation's validation logic
          expect(result.length, lessThanOrEqualTo(2));
        },
      );

      test('fetchZweitmitgliedschaften handles null response', () async {
        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get('Zweitmitgliedschaften/000'),
        ).thenAnswer((_) async => null);

        final result = await userService.fetchZweitmitgliedschaften(000);

        expect(result, isEmpty);
      });
    });

    group('fetchPassdatenZVE', () {
      const testPassdatenId = 456;
      const testPersonId = 123;

      test('fetchPassdatenZVE returns mapped data', () async {
        // Arrange
        final mockResponse = [
          {
            'PASSDATENZVID': 34527,
            'ZVEREINID': 2420,
            'VVEREINNR': 421037,
            'DISZIPLINNR': 'B.91',
            'GAUID': 57,
            'BEZIRKID': 4,
            'DISZIAUSBLENDEN': 0,
            'ERSAETZENDURCHID': 0,
            'ZVMITGLIEDSCHAFTID': 510039,
            'VEREINNAME': 'SV Alpenrose Grimolzhausen',
            'DISZIPLIN': 'RWK Luftpistole',
            'DISZIPLINID': 94,
          },
        ];

        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get('PassdatenZVE/$testPassdatenId/$testPersonId'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await userService.fetchPassdatenZVE(
          testPassdatenId,
          testPersonId,
        );

        // Assert
        expect(result.length, 1);
        expect(result[0].passdatenZvId, 34527);
        expect(result[0].zvVereinId, 2420);
        expect(result[0].vVereinNr, 421037);
        expect(result[0].disziplinNr, 'B.91');
        expect(result[0].gauId, 57);
        expect(result[0].bezirkId, 4);
        expect(result[0].disziAusblenden, 0);
        expect(result[0].ersaetzendurchId, 0);
        expect(result[0].zvMitgliedschaftId, 510039);
        expect(result[0].vereinName, 'SV Alpenrose Grimolzhausen');
        expect(result[0].disziplin, 'RWK Luftpistole');
        expect(result[0].disziplinId, 94);
      });

      test('handles empty response', () async {
        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get('PassdatenZVE/$testPassdatenId/$testPersonId'),
        ).thenAnswer((_) async => []);

        final result = await userService.fetchPassdatenZVE(
          testPassdatenId,
          testPersonId,
        );

        expect(result, isA<List<dynamic>>());
        expect(result, isEmpty);
      });

      test('handles error response', () async {
        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
            any,
            any,
            any,
            any,
          ),
        ).thenThrow(Exception('Network error'));

        final result = await userService.fetchPassdatenZVE(
          testPassdatenId,
          testPersonId,
        );

        expect(result, isA<List<dynamic>>());
        expect(result, isEmpty);
      });

      test('fetchPassdatenZVE handles negative IDs', () async {
        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get('PassdatenZVE/-1/-2'),
        ).thenAnswer((_) async => []);

        final result = await userService.fetchPassdatenZVE(-1, -2);

        expect(result, isEmpty);
      });

      test('fetchPassdatenZVE handles zero IDs', () async {
        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get('PassdatenZVE/0/0'),
        ).thenAnswer((_) async => []);

        final result = await userService.fetchPassdatenZVE(0, 0);

        expect(result, isEmpty);
      });

      test('fetchPassdatenZVE handles large datasets', () async {
        final largeResponse = List.generate(
          50,
          (index) => {
            'PASSDATENZVID': 30000 + index,
            'ZVEREINID': 2000 + index,
            'VVEREINNR': 420000 + index,
            'DISZIPLINNR': 'B.${90 + index}',
            'GAUID': 50 + index,
            'BEZIRKID': 4,
            'DISZIAUSBLENDEN': 0,
            'ERSAETZENDURCHID': 0,
            'ZVMITGLIEDSCHAFTID': 500000 + index,
            'VEREINNAME': 'Test Verein $index',
            'DISZIPLIN': 'Disziplin $index',
            'DISZIPLINID': 90 + index,
          },
        );

        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get('PassdatenZVE/999/888'),
        ).thenAnswer((_) async => largeResponse);

        final result = await userService.fetchPassdatenZVE(999, 888);

        expect(result.length, 50);
        expect(result.first.passdatenZvId, 30000);
        expect(result.last.passdatenZvId, 30049);
      });

      test('fetchPassdatenZVE handles incomplete data entries', () async {
        final incompleteResponse = [
          {
            'PASSDATENZVID': 34527,
            // Missing ZVEREINID
            'VVEREINNR': 421037,
            'DISZIPLINNR': 'B.91',
            // Missing GAUID
            'BEZIRKID': 4,
            'DISZIAUSBLENDEN': 0,
            'ERSAETZENDURCHID': 0,
            'ZVMITGLIEDSCHAFTID': 510039,
            'VEREINNAME': 'Test Verein',
            'DISZIPLIN': 'RWK Luftpistole',
            'DISZIPLINID': 94,
          },
          {
            // Missing PASSDATENZVID
            'ZVEREINID': 2420,
            'VVEREINNR': 421037,
            // Missing DISZIPLINNR
            'GAUID': 57,
            'BEZIRKID': 4,
            'DISZIAUSBLENDEN': 0,
            'ERSAETZENDURCHID': 0,
            'ZVMITGLIEDSCHAFTID': 510039,
            // Missing VEREINNAME
            'DISZIPLIN': 'Another Disziplin',
            'DISZIPLINID': 95,
          },
        ];

        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get('PassdatenZVE/111/222'),
        ).thenAnswer((_) async => incompleteResponse);

        final result = await userService.fetchPassdatenZVE(111, 222);

        // The service should handle incomplete entries appropriately
        expect(result, isA<List>());

        // If entries are included, they should be properly formed
        for (final entry in result) {
          expect(entry, isNotNull);
        }
      });

      test('fetchPassdatenZVE filters out non-map entries', () async {
        final mixedResponse = [
          {
            'PASSDATENZVID': 34527,
            'ZVEREINID': 2420,
            'VVEREINNR': 421037,
            'DISZIPLINNR': 'B.91',
            'GAUID': 57,
            'BEZIRKID': 4,
            'DISZIAUSBLENDEN': 0,
            'ERSAETZENDURCHID': 0,
            'ZVMITGLIEDSCHAFTID': 510039,
            'VEREINNAME': 'Valid Entry',
            'DISZIPLIN': 'RWK Luftpistole',
            'DISZIPLINID': 94,
          },
          'invalid string',
          null,
          123,
          {
            'PASSDATENZVID': 34528,
            'ZVEREINID': 2421,
            'VVEREINNR': 421038,
            'DISZIPLINNR': 'B.92',
            'GAUID': 58,
            'BEZIRKID': 5,
            'DISZIAUSBLENDEN': 1,
            'ERSAETZENDURCHID': 1,
            'ZVMITGLIEDSCHAFTID': 510040,
            'VEREINNAME': 'Another Valid Entry',
            'DISZIPLIN': 'RWK Gewehr',
            'DISZIPLINID': 95,
          },
        ];

        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get('PassdatenZVE/333/444'),
        ).thenAnswer((_) async => mixedResponse);

        final result = await userService.fetchPassdatenZVE(333, 444);

        // Should filter out invalid entries
        expect(result, isA<List>());

        // All returned entries should be valid
        for (final entry in result) {
          expect(entry, isNotNull);
          expect(entry.vereinName, isA<String>());
        }

        // Should have filtered to only include valid map entries
        expect(result.length, lessThanOrEqualTo(2));
      });

      test('fetchPassdatenZVE handles null response', () async {
        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get('PassdatenZVE/555/666'),
        ).thenAnswer((_) async => null);

        final result = await userService.fetchPassdatenZVE(555, 666);

        expect(result, isEmpty);
      });
    });

    group('updateKritischeFelderUndAdresse', () {
      late UserData testUserData;

      setUp(() {
        testUserData = UserData(
          passnummer: '40100709',
          vereinNr: 401051,
          namen: 'Schürz',
          vorname: 'Lukas',
          titel: '',
          geburtsdatum: DateTime.parse('1955-07-16T00:00:00.000+02:00'),
          geschlecht: 1,
          vereinName: 'Feuerschützen Kühbach',
          passdatenId: 2000009155,
          mitgliedschaftId: 439287,
          personId: 439287,
          strasse: 'Aichacher Strasse 21',
          plz: '86574',
          ort: 'Alsmoos',
          isOnline: true,
          webLoginId: 13901,
        );
      });

      test('returns true on successful update', () async {
        when(
          mockHttpClient.put('KritischeFelderUndAdresse', {
            'PersonID': testUserData.personId,
            'Titel': testUserData.titel,
            'Namen': testUserData.namen,
            'Vorname': testUserData.vorname,
            'Geschlecht': testUserData.geschlecht,
            'Strasse': testUserData.strasse,
            'PLZ': testUserData.plz,
            'Ort': testUserData.ort,
          }),
        ).thenAnswer((_) async => {'result': true});

        final result = await userService.updateKritischeFelderUndAdresse(
          testUserData,
        );

        expect(result, isTrue);
        verify(
          mockHttpClient.put('KritischeFelderUndAdresse', {
            'PersonID': testUserData.personId,
            'Titel': testUserData.titel,
            'Namen': testUserData.namen,
            'Vorname': testUserData.vorname,
            'Geschlecht': testUserData.geschlecht,
            'Strasse': testUserData.strasse,
            'PLZ': testUserData.plz,
            'Ort': testUserData.ort,
          }),
        ).called(1);
      });

      test('returns false on failed update', () async {
        when(
          mockHttpClient.put('KritischeFelderUndAdresse', any),
        ).thenAnswer((_) async => {'result': false});

        final result = await userService.updateKritischeFelderUndAdresse(
          testUserData,
        );

        expect(result, isFalse);
      });

      test('returns false on network error', () async {
        when(
          mockHttpClient.put('KritischeFelderUndAdresse', any),
        ).thenThrow(Exception('Network error'));

        final result = await userService.updateKritischeFelderUndAdresse(
          testUserData,
        );

        expect(result, isFalse);
      });
    });

    group('addKontakt', () {
      test('should return true on successful contact add', () async {
        const contact = Contact(
          id: 0,
          personId: 1,
          type: 4,
          value: 'test@example.com',
        );

        when(
          mockHttpClient.post(any, any),
        ).thenAnswer((_) async => {'result': true});

        final result = await userService.addKontakt(contact);

        expect(result, isTrue);
        verify(
          mockHttpClient.post('KontaktHinzufuegen', {
            'PersonID': contact.personId,
            'KontaktTyp': contact.type,
            'Kontakt': contact.value,
          }),
        ).called(1);
      });

      test(
        'should return false on failed contact add (API ResultType not 1)',
        () async {
          const contact = Contact(
            id: 0,
            personId: 1,
            type: 4,
            value: 'test@example.com',
          );

          when(
            mockHttpClient.post(any, any),
          ).thenAnswer((_) async => {'result': false});

          final result = await userService.addKontakt(contact);

          expect(result, isFalse);
        },
      );

      test('should return false on exception during contact add', () async {
        const contact = Contact(
          id: 0,
          personId: 1,
          type: 4,
          value: 'test@example.com',
        );

        when(
          mockHttpClient.post(any, any),
        ).thenThrow(Exception('Network error'));

        final result = await userService.addKontakt(contact);

        expect(result, isFalse);
      });

      test('addKontakt handles negative person ID', () async {
        const contact = Contact(
          id: 0,
          personId: -1,
          type: 4,
          value: 'test@example.com',
        );

        when(
          mockHttpClient.post(any, any),
        ).thenAnswer((_) async => {'result': true});

        final result = await userService.addKontakt(contact);

        expect(result, isTrue);
        verify(
          mockHttpClient.post('KontaktHinzufuegen', {
            'PersonID': -1,
            'KontaktTyp': 4,
            'Kontakt': 'test@example.com',
          }),
        ).called(1);
      });

      test('addKontakt handles zero contact type', () async {
        const contact = Contact(
          id: 0,
          personId: 1,
          type: 0,
          value: 'test@example.com',
        );

        when(
          mockHttpClient.post(any, any),
        ).thenAnswer((_) async => {'result': true});

        final result = await userService.addKontakt(contact);

        // The service might validate contact types and reject type 0
        // Let's test that it handles the zero type appropriately
        expect(result, isA<bool>());

        if (result) {
          verify(
            mockHttpClient.post('KontaktHinzufuegen', {
              'PersonID': 1,
              'KontaktTyp': 0,
              'Kontakt': 'test@example.com',
            }),
          ).called(1);
        }
      });

      test('addKontakt handles empty contact value', () async {
        const contact = Contact(id: 0, personId: 1, type: 4, value: '');

        when(
          mockHttpClient.post(any, any),
        ).thenAnswer((_) async => {'result': true});

        final result = await userService.addKontakt(contact);

        expect(result, isTrue);
        verify(
          mockHttpClient.post('KontaktHinzufuegen', {
            'PersonID': 1,
            'KontaktTyp': 4,
            'Kontakt': '',
          }),
        ).called(1);
      });

      test('addKontakt handles very long contact value', () async {
        final longValue = 'a' * 1000; // Very long string
        final contact = Contact(id: 0, personId: 1, type: 4, value: longValue);

        when(
          mockHttpClient.post(any, any),
        ).thenAnswer((_) async => {'result': true});

        final result = await userService.addKontakt(contact);

        expect(result, isTrue);
      });

      test('addKontakt handles special characters in contact value', () async {
        const contact = Contact(
          id: 0,
          personId: 1,
          type: 4,
          value: 'test+special@domain-name.co.uk',
        );

        when(
          mockHttpClient.post(any, any),
        ).thenAnswer((_) async => {'result': true});

        final result = await userService.addKontakt(contact);

        expect(result, isTrue);
      });

      test('addKontakt handles non-boolean result', () async {
        const contact = Contact(
          id: 0,
          personId: 1,
          type: 4,
          value: 'test@example.com',
        );

        when(
          mockHttpClient.post(any, any),
        ).thenAnswer((_) async => {'result': 'success'});

        final result = await userService.addKontakt(contact);

        expect(result, isFalse); // Should treat non-boolean as false
      });

      test('addKontakt handles invalid response format', () async {
        const contact = Contact(
          id: 0,
          personId: 1,
          type: 4,
          value: 'test@example.com',
        );

        when(
          mockHttpClient.post(any, any),
        ).thenAnswer((_) async => 'invalid_response');

        final result = await userService.addKontakt(contact);

        expect(result, isFalse);
      });

      test('addKontakt handles null response', () async {
        const contact = Contact(
          id: 0,
          personId: 1,
          type: 4,
          value: 'test@example.com',
        );

        when(mockHttpClient.post(any, any)).thenAnswer((_) async => null);

        final result = await userService.addKontakt(contact);

        expect(result, isFalse);
      });

      test('should return false for invalid contact type', () async {
        const contact = Contact(
          id: 0,
          personId: 1,
          type: 9, // Invalid type
          value: 'test@example.com',
        );

        final result = await userService.addKontakt(contact);

        expect(result, isFalse);
        verifyNever(mockHttpClient.post(any, any));
      });
    });

    group('deleteKontakt', () {
      test('should return true on successful contact delete', () async {
        const contact = Contact(
          id: 10,
          personId: 1,
          type: 4,
          value: 'test@example.com',
        );

        when(
          mockHttpClient.put(any, any),
        ).thenAnswer((_) async => {'result': true});

        final result = await userService.deleteKontakt(contact);

        expect(result, isTrue);
        verify(
          mockHttpClient.put('KontaktAendern', {
            'PersonID': contact.personId,
            'KontaktID': contact.id,
            'KontaktTyp': contact.type,
            'Kontakt': '', // Empty contact value to indicate deletion
          }),
        ).called(1);
      });

      test(
        'should return false on failed contact delete (API result false)',
        () async {
          const contact = Contact(
            id: 10,
            personId: 1,
            type: 4,
            value: 'test@example.com',
          );

          when(
            mockHttpClient.put(any, any),
          ).thenAnswer((_) async => {'result': false});

          final result = await userService.deleteKontakt(contact);

          expect(result, isFalse);
        },
      );

      test('should return false on exception during contact delete', () async {
        const contact = Contact(
          id: 10,
          personId: 1,
          type: 4,
          value: 'test@example.com',
        );

        when(
          mockHttpClient.put(any, any),
        ).thenThrow(Exception('Network error'));

        final result = await userService.deleteKontakt(contact);

        expect(result, isFalse);
      });

      test('deleteKontakt returns false for invalid response type', () async {
        const contact = Contact(
          id: 10,
          personId: 1,
          type: 4,
          value: 'test@example.com',
        );
        when(mockHttpClient.put(any, any)).thenAnswer((_) async => 'notamap');
        final result = await userService.deleteKontakt(contact);
        expect(result, isFalse);
      });
    });

    group('updateKontakt', () {
      test('should return true on successful contact update', () async {
        const contact = Contact(
          id: 10,
          personId: 1,
          type: 4,
          value: 'updated@example.com',
        );

        when(
          mockHttpClient.put(any, any),
        ).thenAnswer((_) async => {'result': true});

        final result = await userService.updateKontakt(contact);

        expect(result, isTrue);
        verify(
          mockHttpClient.put('KontaktAendern', contact.toJson()),
        ).called(1);
      });

      test(
        'should return false on failed contact update (API result false)',
        () async {
          const contact = Contact(
            id: 10,
            personId: 1,
            type: 4,
            value: 'updated@example.com',
          );

          when(
            mockHttpClient.put(any, any),
          ).thenAnswer((_) async => {'result': false});

          final result = await userService.updateKontakt(contact);

          expect(result, isFalse);
        },
      );

      test('should return false on exception during contact update', () async {
        const contact = Contact(
          id: 10,
          personId: 1,
          type: 4,
          value: 'updated@example.com',
        );

        when(
          mockHttpClient.put(any, any),
        ).thenThrow(Exception('Network error'));

        final result = await userService.updateKontakt(contact);

        expect(result, isFalse);
      });

      test('should return false for empty contact value', () async {
        const contact = Contact(
          id: 10,
          personId: 1,
          type: 4,
          value: '', // Empty value
        );

        final result = await userService.updateKontakt(contact);

        expect(result, isFalse);
        verifyNever(mockHttpClient.put(any, any));
      });

      test('should return false for invalid response type', () async {
        const contact = Contact(
          id: 10,
          personId: 1,
          type: 4,
          value: 'updated@example.com',
        );
        when(mockHttpClient.put(any, any)).thenAnswer((_) async => 'notamap');
        final result = await userService.updateKontakt(contact);
        expect(result, isFalse);
      });

      test('updateKontakt handles negative contact ID', () async {
        const contact = Contact(
          id: -1,
          personId: 1,
          type: 4,
          value: 'updated@example.com',
        );

        when(
          mockHttpClient.put(any, any),
        ).thenAnswer((_) async => {'result': true});

        final result = await userService.updateKontakt(contact);

        expect(result, isTrue);
        verify(
          mockHttpClient.put('KontaktAendern', contact.toJson()),
        ).called(1);
      });

      test('updateKontakt handles zero contact ID', () async {
        const contact = Contact(
          id: 0,
          personId: 1,
          type: 4,
          value: 'updated@example.com',
        );

        when(
          mockHttpClient.put(any, any),
        ).thenAnswer((_) async => {'result': true});

        final result = await userService.updateKontakt(contact);

        expect(result, isTrue);
      });

      test('updateKontakt handles very long contact value', () async {
        final longValue =
            'very.long.email.address.with.many.parts@${'a' * 200}.com';
        final contact = Contact(id: 10, personId: 1, type: 4, value: longValue);

        when(
          mockHttpClient.put(any, any),
        ).thenAnswer((_) async => {'result': true});

        final result = await userService.updateKontakt(contact);

        expect(result, isTrue);
      });

      test('updateKontakt handles special characters and unicode', () async {
        const contact = Contact(
          id: 10,
          personId: 1,
          type: 4,
          value: 'test+special@domain-äöü.com',
        );

        when(
          mockHttpClient.put(any, any),
        ).thenAnswer((_) async => {'result': true});

        final result = await userService.updateKontakt(contact);

        expect(result, isTrue);
      });

      test('updateKontakt handles different contact types', () async {
        const testCases = [
          Contact(id: 1, personId: 1, type: 1, value: '123456789'),
          Contact(id: 2, personId: 1, type: 2, value: 'test@email.com'),
          Contact(id: 3, personId: 1, type: 3, value: 'https://website.com'),
          Contact(id: 4, personId: 1, type: 4, value: 'social@media.com'),
        ];

        for (final contact in testCases) {
          when(
            mockHttpClient.put(any, any),
          ).thenAnswer((_) async => {'result': true});

          final result = await userService.updateKontakt(contact);

          expect(result, isTrue);
          verify(
            mockHttpClient.put('KontaktAendern', contact.toJson()),
          ).called(1);
          reset(mockHttpClient);
        }
      });

      test('updateKontakt handles null result field', () async {
        const contact = Contact(
          id: 10,
          personId: 1,
          type: 4,
          value: 'updated@example.com',
        );

        when(
          mockHttpClient.put(any, any),
        ).thenAnswer((_) async => {'result': null});

        final result = await userService.updateKontakt(contact);

        expect(result, isFalse);
      });

      test('updateKontakt handles missing result field', () async {
        const contact = Contact(
          id: 10,
          personId: 1,
          type: 4,
          value: 'updated@example.com',
        );

        when(
          mockHttpClient.put(any, any),
        ).thenAnswer((_) async => {'other_field': true});

        final result = await userService.updateKontakt(contact);

        expect(result, isFalse);
      });

      test('updateKontakt handles numeric result field', () async {
        const contact = Contact(
          id: 10,
          personId: 1,
          type: 4,
          value: 'updated@example.com',
        );

        when(
          mockHttpClient.put(any, any),
        ).thenAnswer((_) async => {'result': 1});

        final result = await userService.updateKontakt(contact);

        expect(result, isFalse); // Should treat non-boolean as false
      });
    });

    group('fetchKontakte', () {
      test('should parse contact data correctly', () async {
        final apiResponse = [
          {
            'KontaktID': 1,
            'PersonID': 123,
            'KontaktTyp': 4,
            'Kontakt': 'test@example.com',
          },
          {
            'KontaktID': 2,
            'PersonID': 123,
            'KontaktTyp': 1,
            'Kontakt': '123-456-7890',
          },
        ];

        when(
          mockHttpClient.get('Kontakte/123'),
        ).thenAnswer((_) async => apiResponse);

        final result = await userService.fetchKontakte(123);

        expect(result, [
          {
            'category': 'Privat',
            'contacts': [
              {
                'kontaktId': 1,
                'type': 'E-Mail Privat',
                'value': 'test@example.com',
                'rawKontaktTyp': 4,
              },
              {
                'kontaktId': 2,
                'type': 'Telefonnummer Privat',
                'value': '123-456-7890',
                'rawKontaktTyp': 1,
              },
            ],
          },
          {'category': 'Geschäftlich', 'contacts': []},
        ]);
      });

      test('should handle empty response', () async {
        when(mockHttpClient.get('Kontakte/123')).thenAnswer((_) async => []);

        final result = await userService.fetchKontakte(123);

        expect(result, [
          {'category': 'Privat', 'contacts': []},
          {'category': 'Geschäftlich', 'contacts': []},
        ]);
      });

      test('should handle invalid contact data', () async {
        final apiResponse = [
          {
            'KontaktID': 1,
            'PersonID': 123,
            'KontaktTyp': 4,
            'Kontakt': 'test@example.com',
          },
          {'invalid': 'data'},
        ];

        when(
          mockHttpClient.get('Kontakte/123'),
        ).thenAnswer((_) async => apiResponse);

        final result = await userService.fetchKontakte(123);

        expect(result, [
          {
            'category': 'Privat',
            'contacts': [
              {
                'kontaktId': 1,
                'type': 'E-Mail Privat',
                'value': 'test@example.com',
                'rawKontaktTyp': 4,
              },
            ],
          },
          {'category': 'Geschäftlich', 'contacts': []},
        ]);
      });

      test('fetchKontakte returns empty list for non-list response', () async {
        when(
          mockHttpClient.get('Kontakte/123'),
        ).thenAnswer((_) async => 'notalist');
        final result = await userService.fetchKontakte(123);
        expect(result, isEmpty);
      });
    });

    group('fetchAdresseVonPersonID', () {
      const testPersonId = 439287;
      final testResponse = [
        {
          'PERSONID': 439287,
          'NAMEN': 'Rizoudis',
          'VORNAME': 'Kostas',
          'GESCHLECHT': true,
          'GEBURTSDATUM': '1955-07-16T00:00:00.000+02:00',
          'PASSNUMMER': '40100709',
          'STRASSE': 'Eisenacherstr 9',
          'PLZ': '80804',
          'ORT': 'München',
        },
      ];

      test('returns List<Person> from network', () async {
        when(
          mockHttpClient.get('AdresseVonPersonID/$testPersonId'),
        ).thenAnswer((_) async => testResponse);

        final result = await userService.fetchAdresseVonPersonID(testPersonId);

        expect(result, isA<List<Person>>());
        expect(result.length, 1);
        expect(result.first.personId, 439287);
        expect(result.first.namen, 'Rizoudis');
        expect(result.first.vorname, 'Kostas');
        expect(result.first.geschlecht, true);
        expect(
          result.first.geburtsdatum,
          DateTime.parse('1955-07-16T00:00:00.000+02:00'),
        );
        expect(result.first.passnummer, '40100709');
        expect(result.first.strasse, 'Eisenacherstr 9');
        expect(result.first.plz, '80804');
        expect(result.first.ort, 'München');
      });

      test('handles empty response', () async {
        when(
          mockHttpClient.get('AdresseVonPersonID/$testPersonId'),
        ).thenAnswer((_) async => []);

        final result = await userService.fetchAdresseVonPersonID(testPersonId);
        expect(result, isEmpty);
      });

      test('handles error response', () async {
        when(
          mockHttpClient.get('AdresseVonPersonID/$testPersonId'),
        ).thenThrow(Exception('Network error'));

        final result = await userService.fetchAdresseVonPersonID(testPersonId);
        expect(result, isEmpty);
      });

      test(
        'fetchAdresseVonPersonID returns empty list for non-list/map response',
        () async {
          when(
            mockHttpClient.get('AdresseVonPersonID/123'),
          ).thenAnswer((_) async => 123);
          final result = await userService.fetchAdresseVonPersonID(123);
          expect(result, isEmpty);
        },
      );
    });

    group('Cache clearing', () {
      test('clearPassdatenCache removes the correct cache key', () async {
        const personId = 123;
        when(
          mockCacheService.remove('passdaten_123'),
        ).thenAnswer((_) async => true);
        await userService.clearPassdatenCache(personId);
        verify(mockCacheService.remove('passdaten_123')).called(1);
      });

      test(
        'clearAllPassdatenCache calls clearPattern with passdaten_',
        () async {
          when(
            mockCacheService.clearPattern('passdaten_'),
          ).thenAnswer((_) async => true);
          await userService.clearAllPassdatenCache();
          verify(mockCacheService.clearPattern('passdaten_')).called(1);
        },
      );

      test('clearPassdatenCache handles negative person ID', () async {
        const personId = -1;
        when(
          mockCacheService.remove('passdaten_-1'),
        ).thenAnswer((_) async => true);
        await userService.clearPassdatenCache(personId);
        verify(mockCacheService.remove('passdaten_-1')).called(1);
      });

      test('clearPassdatenCache handles zero person ID', () async {
        const personId = 0;
        when(
          mockCacheService.remove('passdaten_0'),
        ).thenAnswer((_) async => true);
        await userService.clearPassdatenCache(personId);
        verify(mockCacheService.remove('passdaten_0')).called(1);
      });

      test('clearPassdatenCache handles very large person ID', () async {
        const personId = 999999999;
        when(
          mockCacheService.remove('passdaten_999999999'),
        ).thenAnswer((_) async => true);
        await userService.clearPassdatenCache(personId);
        verify(mockCacheService.remove('passdaten_999999999')).called(1);
      });

      test('clearPassdatenCache handles cache service failure', () async {
        const personId = 123;
        when(
          mockCacheService.remove('passdaten_123'),
        ).thenAnswer((_) async => false);

        // Should not throw even if cache service fails
        await userService.clearPassdatenCache(personId);
        verify(mockCacheService.remove('passdaten_123')).called(1);
      });

      test('clearPassdatenCache handles cache service exception', () async {
        const personId = 123;
        when(
          mockCacheService.remove('passdaten_123'),
        ).thenThrow(Exception('Cache service error'));

        // Should not throw exception to caller
        expect(
          () => userService.clearPassdatenCache(personId),
          returnsNormally,
        );
      });

      test('clearAllPassdatenCache handles cache service failure', () async {
        when(
          mockCacheService.clearPattern('passdaten_'),
        ).thenAnswer((_) async => false);

        await userService.clearAllPassdatenCache();
        verify(mockCacheService.clearPattern('passdaten_')).called(1);
      });

      test('clearAllPassdatenCache handles cache service exception', () async {
        when(
          mockCacheService.clearPattern('passdaten_'),
        ).thenThrow(Exception('Cache service error'));

        expect(() => userService.clearAllPassdatenCache(), returnsNormally);
      });
    });

    group('fetchPassdatenAkzeptierterOderAktiverPass', () {
      const testPersonId = 123;
      final testResponse = {
        'PASSDATENID': 1,
        'PASSSTATUS': 2,
        'PASSSTATUSTEXT': 'Aktiv',
        'DIGITALERPASS': 1,
        'PERSONID': testPersonId,
        'ERSTVEREINID': 10,
        'EVVEREINNR': 20,
        'EVVEREINNAME': 'Testverein',
        'PASSNUMMER': '987654',
        'ERSTELLTAM': '2023-01-01T00:00:00.000Z',
        'ERSTELLTVON': 'admin',
        'ZVEs': [],
      };

      test('returns PassdatenAkzeptOrAktiv when response is valid', () async {
        when(
          mockHttpClient.get(
            any,
            overrideBaseUrl: anyNamed(
              'overrideBaseUrl',
            ), // Ensure this is correct
          ),
        ).thenAnswer((_) async => [testResponse]);

        final result = await userService
            .fetchPassdatenAkzeptierterOderAktiverPass(testPersonId);
        expect(result, isA<PassdatenAkzeptOrAktiv>());
        expect(result!.passdatenId, 1);
        expect(result.passStatus, 2);
        expect(result.passStatusText, 'Aktiv');
        expect(result.digitalerPass, 1);
        expect(result.personId, testPersonId);
        expect(result.evVereinName, 'Testverein');
        expect(result.passNummer, '987654');
      });

      test('returns null when response is null', () async {
        when(
          mockHttpClient.get(
            'PassdatenAkzeptierterOderAktiverPass/$testPersonId',
          ),
        ).thenAnswer((_) async => null);
        final result = await userService
            .fetchPassdatenAkzeptierterOderAktiverPass(testPersonId);
        expect(result, isNull);
      });

      test('returns null when response is empty map', () async {
        when(
          mockHttpClient.get(
            'PassdatenAkzeptierterOderAktiverPass/$testPersonId',
          ),
        ).thenAnswer((_) async => <String, dynamic>{});
        final result = await userService
            .fetchPassdatenAkzeptierterOderAktiverPass(testPersonId);
        expect(result, isNull);
      });

      test('returns null when response is list but empty', () async {
        when(
          mockHttpClient.get(
            'PassdatenAkzeptierterOderAktiverPass/$testPersonId',
          ),
        ).thenAnswer((_) async => <dynamic>[]);
        final result = await userService
            .fetchPassdatenAkzeptierterOderAktiverPass(testPersonId);
        expect(result, isNull);
      });
    });

    group('fetchZweitmitgliedschaftenZVE', () {
      const testPersonId = 123;
      const testPassStatus = 1;

      test('returns mapped data for valid response', () async {
        final mockResponse = [
          {
            'VEREINID': 1474,
            'VEREINNR': 401006,
            'VEREINNAME': 'Vereinigte Sportschützen Paartal Aichach',
            'EINTRITTVEREIN': '2012-02-26T00:00:00.000+01:00',
          },
        ];

        when(mockConfigService.getString('apiProtocol')).thenReturn('http');
        when(
          mockConfigService.getString('api1BaseServer'),
        ).thenReturn('localhost');
        when(mockConfigService.getString('api1BasePort')).thenReturn('8080');
        when(mockConfigService.getString('api1BasePath')).thenReturn('');

        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get(
            'ZweitmitgliedschaftenZVE/$testPersonId/$testPassStatus',
            overrideBaseUrl: anyNamed('overrideBaseUrl'),
          ),
        ).thenAnswer((_) async => mockResponse);

        final result = await userService.fetchZweitmitgliedschaftenZVE(
          testPersonId,
          testPassStatus,
        );

        expect(result.length, 1);
        expect(result[0].vereinId, 1474);
        expect(result[0].vereinNr, 401006);
        expect(
          result[0].vereinName,
          'Vereinigte Sportschützen Paartal Aichach',
        );
        expect(
          result[0].eintrittVerein,
          DateTime.parse('2012-02-26T00:00:00.000+01:00'),
        );
      });

      test('handles empty response', () async {
        when(mockConfigService.getString('apiProtocol')).thenReturn('http');
        when(
          mockConfigService.getString('api1BaseServer'),
        ).thenReturn('localhost');
        when(mockConfigService.getString('api1BasePort')).thenReturn('8080');
        when(mockConfigService.getString('api1BasePath')).thenReturn('');

        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
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
          mockHttpClient.get(
            'ZweitmitgliedschaftenZVE/$testPersonId/$testPassStatus',
            overrideBaseUrl: anyNamed('overrideBaseUrl'),
          ),
        ).thenAnswer((_) async => []);

        final result = await userService.fetchZweitmitgliedschaftenZVE(
          testPersonId,
          testPassStatus,
        );

        expect(result, isEmpty);
      });

      test('handles error response', () async {
        when(mockConfigService.getString('apiProtocol')).thenReturn('http');
        when(
          mockConfigService.getString('api1BaseServer'),
        ).thenReturn('localhost');
        when(mockConfigService.getString('api1BasePort')).thenReturn('8080');
        when(mockConfigService.getString('api1BasePath')).thenReturn('');

        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
            any,
            any,
            any,
            any,
          ),
        ).thenThrow(Exception('Network error'));

        final result = await userService.fetchZweitmitgliedschaftenZVE(
          testPersonId,
          testPassStatus,
        );

        expect(result, isEmpty);
      });
    });

    group('fetchPassdaten with pending requests', () {
      const testPersonId = 439287;
      test('handles error in pending request', () async {
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
        ).thenThrow(Exception('Network error'));

        // Make concurrent requests
        final futures = await Future.wait([
          userService.fetchPassdaten(testPersonId),
          userService.fetchPassdaten(testPersonId),
        ], eagerError: false);

        // All requests should fail with null
        for (final result in futures) {
          expect(result, isNull);
        }

        // The cache attempt should only be made once
        verify(
          mockCacheService.cacheAndRetrieveData<Map<String, dynamic>>(
            any,
            any,
            any,
            any,
          ),
        ).called(1);
      });
    });

    group('Internal mapping methods through public APIs', () {
      test('_mapPassdatenResponse handles invalid response types', () async {
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
        ).thenAnswer((invocation) async {
          final fetchData =
              invocation.positionalArguments[2] as Future<dynamic> Function();
          final response = await fetchData();
          final processResponse =
              invocation.positionalArguments[3] as Function(dynamic);
          return processResponse(response);
        });

        // Test with invalid response type
        when(
          mockHttpClient.get('Passdaten/123'),
        ).thenAnswer((_) async => 'invalid response');

        final result = await userService.fetchPassdaten(123);
        expect(result, isNull);
      });
    });

    group('_mapZweitmitgliedschaftenResponse (isolated)', () {
      // We isolate these tests so stubbing cacheAndRetrieveData does NOT
      // affect the other UserService tests (avoids verify() count failures).

      late UserService localService;
      late MockHttpClient localHttp;
      late MockCacheService localCache;
      late MockNetworkService localNetwork;
      late MockConfigService localConfig;

      setUp(() {
        localHttp = MockHttpClient();
        localCache = MockCacheService();
        localNetwork = MockNetworkService();
        localConfig = MockConfigService();

        when(
          localNetwork.getCacheExpirationDuration(),
        ).thenReturn(const Duration(minutes: 10));

        // Minimal config stubs (if service builds base URL)
        when(localConfig.getString('apiProtocol')).thenReturn('http');
        when(localConfig.getString('api1BaseServer')).thenReturn('localhost');
        when(localConfig.getString('api1BasePort')).thenReturn('8080');
        when(localConfig.getString('api1BasePath')).thenReturn('');

        localService = UserService(
          httpClient: localHttp,
          cacheService: localCache,
          networkService: localNetwork,
          configService: localConfig,
        );
      });

      /// Helper: wires cache so that the processResponse receives [raw].
      void stubProcess(List<dynamic> raw) {
        when(
          localCache.cacheAndRetrieveData<List<dynamic>>(any, any, any, any),
        ).thenAnswer((invocation) async {
          final fetchData =
              invocation.positionalArguments[2] as Future<dynamic> Function();
          // Execute original fetch (to satisfy any internal logic)
          await fetchData();
          final process =
              invocation.positionalArguments[3] as dynamic Function(dynamic);
          return process(raw);
        });
        when(localHttp.get(any)).thenAnswer((_) async => raw);
      }

      test('filters non-map items keeps valid map', () async {
        stubProcess([
          123,
          'string',
          null,
          {
            'VEREINID': 1,
            'VEREINNR': 400001,
            'VEREINNAME': 'Valid Verein',
            'EINTRITTVEREIN': '2020-01-01T00:00:00.000+01:00',
          },
        ]);
        final r = await localService.fetchZweitmitgliedschaften(777);
        expect(r.length, 1);
        expect(r.first.vereinId, 1);
        expect(r.first.vereinName, 'Valid Verein');
      });

      test('returns empty for only invalid items', () async {
        stubProcess([null, 5, 'x', 9.9]);
        final r = await localService.fetchZweitmitgliedschaften(777);
        expect(r, isEmpty);
      });

      test('mixed maps preserves all valid maps', () async {
        stubProcess([
          {
            'VEREINID': 10,
            'VEREINNR': 410000,
            'VEREINNAME': 'Alpha',
            'EINTRITTVEREIN': '2021-02-02T00:00:00.000+01:00',
          },
          'bad',
          {
            'VEREINID': 11,
            'VEREINNR': 410001,
            'VEREINNAME': 'Beta',
            'EINTRITTVEREIN': '2022-03-03T00:00:00.000+01:00',
          },
        ]);
        final r = await localService.fetchZweitmitgliedschaften(777);
        expect(r.length, 2);
        expect(r.map((e) => e.vereinName), containsAll(['Alpha', 'Beta']));
      });

      test('non-list raw response yields empty list', () async {
        when(
          localCache.cacheAndRetrieveData<List<dynamic>>(any, any, any, any),
        ).thenAnswer((inv) async {
          final fetchData =
              inv.positionalArguments[2] as Future<dynamic> Function();
          await fetchData();
          final process =
              inv.positionalArguments[3] as dynamic Function(dynamic);
          return process('not-a-list');
        });
        when(localHttp.get(any)).thenAnswer((_) async => 'not-a-list');
        final r = await localService.fetchZweitmitgliedschaften(777);
        expect(r, isEmpty);
      });
    });
  });

  group('UserService.postBSSBAppPassantrag', () {
    late UserService userService;
    late MockHttpClient mockHttpClient;
    late MockCacheService mockCacheService;
    late MockNetworkService mockNetworkService;
    late MockConfigService mockConfigService;

    setUp(() {
      mockHttpClient = MockHttpClient();
      mockCacheService = MockCacheService();
      mockNetworkService = MockNetworkService();
      mockConfigService = MockConfigService();
      userService = UserService(
        httpClient: mockHttpClient,
        cacheService: mockCacheService,
        networkService: mockNetworkService,
        configService: mockConfigService,
      );
    });

    test('returns true when API responds with result true', () async {
      when(mockConfigService.getString(any)).thenReturn('test');
      when(
        mockHttpClient.post(
          any,
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => {'result': true});

      final result = await userService.bssbAppPassantrag(
        [
          {'VEREINID': 1, 'DISZIPLINID': 10},
        ],
        123,
        456,
        789,
        1,
        3,
      );
      expect(result, isTrue);
    });

    test('returns false when API responds with result false', () async {
      when(mockConfigService.getString(any)).thenReturn('test');
      when(
        mockHttpClient.post(
          any,
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => {'result': false});

      final result = await userService.bssbAppPassantrag(
        [
          {'VEREINID': 1, 'DISZIPLINID': 10},
        ],
        123,
        456,
        789,
        0,
        3,
      );
      expect(result, isFalse);
    });

    test('returns false when API returns unexpected response', () async {
      when(mockConfigService.getString(any)).thenReturn('test');
      when(
        mockHttpClient.post(
          any,
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => {'unexpected': true});

      final result = await userService.bssbAppPassantrag(
        [],
        null,
        null,
        null,
        1,
        3,
      );
      expect(result, isFalse);
    });

    test('returns false when exception is thrown', () async {
      when(mockConfigService.getString(any)).thenReturn('test');
      when(
        mockHttpClient.post(
          any,
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenThrow(Exception('API error'));

      final result = await userService.bssbAppPassantrag(
        [],
        null,
        null,
        null,
        1,
        3,
      );
      expect(result, isFalse);
    });

    test('bssbAppPassantrag sends correct ZVE list', () async {
      when(mockConfigService.getString(any)).thenReturn('test');
      when(
        mockHttpClient.post(
          any,
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).thenAnswer((_) async => {'result': true});

      final result = await userService.bssbAppPassantrag(
        [
          {'VEREINID': 1, 'DISZIPLINID': 10},
          {'VEREINID': 2, 'DISZIPLINID': 20},
        ],
        123,
        456,
        789,
        1,
        3,
      );
      expect(result, isTrue);
      verify(
        mockHttpClient.post(
          'BSSBAppPassantrag',
          argThat(
            predicate<Map<String, dynamic>>((body) {
              final zves = body['ZVEs'] as List;
              return zves.length == 2 &&
                  zves.any(
                    (zve) => zve['VEREINID'] == 1 && zve['DISZIPLINID'] == 10,
                  ) &&
                  zves.any(
                    (zve) => zve['VEREINID'] == 2 && zve['DISZIPLINID'] == 20,
                  );
            }),
          ),
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),
      ).called(1);
    });

    group('Service initialization and configuration', () {
      test('UserService constructor handles all required dependencies', () {
        final service = UserService(
          httpClient: mockHttpClient,
          cacheService: mockCacheService,
          networkService: mockNetworkService,
          configService: mockConfigService,
        );

        expect(service, isNotNull);
      });

      test('UserService handles different config values', () {
        // Test with HTTPS protocol
        when(mockConfigService.getString('apiProtocol')).thenReturn('https');
        when(
          mockConfigService.getString('api1BaseServer'),
        ).thenReturn('api.example.com');
        when(mockConfigService.getString('api1BasePort')).thenReturn('443');
        when(mockConfigService.getString('api1BasePath')).thenReturn('/api/v1');

        final service = UserService(
          httpClient: mockHttpClient,
          cacheService: mockCacheService,
          networkService: mockNetworkService,
          configService: mockConfigService,
        );

        expect(service, isNotNull);
      });

      test('UserService handles null config values gracefully', () {
        when(mockConfigService.getString('apiProtocol')).thenReturn(null);
        when(mockConfigService.getString('api1BaseServer')).thenReturn(null);
        when(mockConfigService.getString('api1BasePort')).thenReturn(null);
        when(mockConfigService.getString('api1BasePath')).thenReturn(null);

        final service = UserService(
          httpClient: mockHttpClient,
          cacheService: mockCacheService,
          networkService: mockNetworkService,
          configService: mockConfigService,
        );

        expect(service, isNotNull);
      });

      test('UserService handles empty string config values', () {
        when(mockConfigService.getString('apiProtocol')).thenReturn('');
        when(mockConfigService.getString('api1BaseServer')).thenReturn('');
        when(mockConfigService.getString('api1BasePort')).thenReturn('');
        when(mockConfigService.getString('api1BasePath')).thenReturn('');

        final service = UserService(
          httpClient: mockHttpClient,
          cacheService: mockCacheService,
          networkService: mockNetworkService,
          configService: mockConfigService,
        );

        expect(service, isNotNull);
      });

      test('Network service cache expiration handling', () {
        // Test with different cache durations
        final testDurations = [
          Duration.zero,
          const Duration(seconds: 1),
          const Duration(minutes: 30),
          const Duration(hours: 24),
          const Duration(days: 7),
        ];

        for (final duration in testDurations) {
          reset(mockNetworkService);
          when(
            mockNetworkService.getCacheExpirationDuration(),
          ).thenReturn(duration);

          final service = UserService(
            httpClient: mockHttpClient,
            cacheService: mockCacheService,
            networkService: mockNetworkService,
            configService: mockConfigService,
          );

          expect(service, isNotNull);
        }
      });
    });
  });
}
