import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:meinbssb/services/api/user_service.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:meinbssb/services/http_client.dart';
import 'package:meinbssb/services/network_service.dart';

import 'user_service_test.mocks.dart';

@GenerateMocks([HttpClient, CacheService, NetworkService])
void main() {
  group('UserService', () {
    late UserService userService;
    late MockHttpClient mockHttpClient;
    late MockCacheService mockCacheService;
    late MockNetworkService mockNetworkService;

    setUp(() {
      mockHttpClient = MockHttpClient();
      mockCacheService = MockCacheService();
      mockNetworkService = MockNetworkService();

      when(mockNetworkService.getCacheExpirationDuration()).thenReturn(
        const Duration(days: 7),
      );

      userService = UserService(
        httpClient: mockHttpClient,
        cacheService: mockCacheService,
        networkService: mockNetworkService,
      );
    });

    group('fetchPassdaten', () {
      test(
        'should return mapped pass data from cache when available',
        () async {
          const personId = 123;

          final expectedFlatData = {
            'PASSNUMMER': '12345',
            'VEREINNR': 67890,
            'NAMEN': 'Doe',
            'VORNAME': 'John',
            'TITEL': 'Mr.',
            'GEBURTSDATUM': '1990-01-01',
            'GESCHLECHT': 'M',
            'VEREINNAME': 'Test Club',
            'PASSDATENID': 1,
            'MITGLIEDSCHAFTID': 2,
            'PERSONID': personId,
            'STRASSE': null,
            'PLZ': null,
            'ORT': null,
            'ONLINE': false,
          };

          when(
            mockCacheService.cacheAndRetrieveData<Map<String, dynamic>>(
              'passdaten_$personId',
              any,
              any,
              any,
            ),
          ).thenAnswer(
            (_) async => expectedFlatData,
          );

          final result = await userService.fetchPassdaten(personId);

          expect(result, expectedFlatData);
          verify(
            mockCacheService.cacheAndRetrieveData<Map<String, dynamic>>(
              'passdaten_$personId',
              any,
              any,
              any,
            ),
          ).called(1);
          verifyNever(mockHttpClient.get('Passdaten/$personId'));
        },
      );

      test(
        'should fetch, map, cache, and return data when not in cache',
        () async {
          const personId = 123;
          final apiResponse = [
            // API might return a list even for a single item
            {
              'PASSNUMMER': '54321',
              'VEREINNR': 98765,
              'NAMEN': 'Smith',
              'VORNAME': 'Jane',
              'TITEL': 'Ms.',
              'GEBURTSDATUM': '1995-05-05',
              'GESCHLECHT': 'F',
              'VEREINNAME': 'Another Club',
              'PASSDATENID': 3,
              'MITGLIEDSCHAFTID': 4,
              'PERSONID': personId,
            }
          ];

          final expectedFlatData = {
            'PASSNUMMER': '54321',
            'VEREINNR': 98765,
            'NAMEN': 'Smith',
            'VORNAME': 'Jane',
            'TITEL': 'Ms.',
            'GEBURTSDATUM': '1995-05-05',
            'GESCHLECHT': 'F',
            'VEREINNAME': 'Another Club',
            'PASSDATENID': 3,
            'MITGLIEDSCHAFTID': 4,
            'PERSONID': personId,
            'STRASSE': null,
            'PLZ': null,
            'ORT': null,
            'ONLINE': true,
          };

          when(
            mockHttpClient.get('Passdaten/$personId'),
          ).thenAnswer((_) async => apiResponse);

          when(
            mockCacheService.cacheAndRetrieveData<Map<String, dynamic>>(
              'passdaten_$personId',
              any, // duration
              any, // fetchData function
              any, // processResponse function
            ),
          ).thenAnswer((invocation) async {
            final fetchData =
                invocation.positionalArguments[2] as Future<dynamic> Function();
            final processResponse = invocation.positionalArguments[3]
                as Map<String, dynamic> Function(dynamic);

            final rawResponse = await fetchData();
            final processed = processResponse(rawResponse);

            return {...processed, 'ONLINE': true};
          });

          final result = await userService.fetchPassdaten(personId);

          expect(result, expectedFlatData);
          verify(mockHttpClient.get('Passdaten/$personId')).called(1);
          verify(
            mockCacheService.cacheAndRetrieveData<Map<String, dynamic>>(
              'passdaten_$personId',
              any,
              any,
              any,
            ),
          ).called(1);
        },
      );

      test('should return empty map on empty response', () async {
        const personId = 123;
        final apiResponse = <dynamic>[];

        when(
          mockCacheService.cacheAndRetrieveData<Map<String, dynamic>>(
            'passdaten_$personId',
            any,
            any,
            any,
          ),
        ).thenAnswer((invocation) async {
          final fetchData =
              invocation.positionalArguments[2] as Future<dynamic> Function();
          final processResponse = invocation.positionalArguments[3]
              as Map<String, dynamic> Function(dynamic);

          final rawResponse = await fetchData();
          final mappedResponse = processResponse(rawResponse);

          if (mappedResponse.isEmpty) {
            return {'ONLINE': true};
          }
          return {...mappedResponse, 'ONLINE': true};
        });

        when(
          mockHttpClient.get('Passdaten/$personId'),
        ).thenAnswer((_) async => apiResponse);

        final result = await userService.fetchPassdaten(personId);

        expect(result, {'ONLINE': true});
        verify(mockHttpClient.get('Passdaten/$personId')).called(1);
      });

      test('should return empty map and log error on network failure',
          () async {
        const personId = 123;
        // Simulate CacheService returning an empty map, indicating no data was retrieved
        when(
          mockCacheService.cacheAndRetrieveData<Map<String, dynamic>>(
            'passdaten_$personId',
            any,
            any,
            any,
          ),
        ).thenAnswer((_) async => {});

        final result = await userService.fetchPassdaten(personId);

        expect(result, {});
        verify(
          mockCacheService.cacheAndRetrieveData<Map<String, dynamic>>(
            'passdaten_$personId',
            any,
            any,
            any,
          ),
        ).called(1);
        verifyNever(mockHttpClient.get(any));
      });
    });

    // ================== For Zweitmitgliedschaften ====================

    group('fetchZweitmitgliedschaften', () {
      test(
        'should return mapped zweitmitgliedschaften data from cache when available',
        () async {
          const personId = 123;
          final expectedFlatData = [
            {
              'VEREINID': 101,
              'VEREINNAME': 'Club Alpha',
              'EINTRITTVEREIN': '2020-01-01',
              'ONLINE': false,
            },
            {
              'VEREINID': 102,
              'VEREINNAME': 'Club Beta',
              'EINTRITTVEREIN': '2021-02-02',
              'ONLINE': false,
            },
          ];

          when(
            mockCacheService.cacheAndRetrieveData<List<dynamic>>(
              'zweitmitgliedschaften_$personId',
              any,
              any,
              any,
            ),
          ).thenAnswer(
            (_) async => expectedFlatData,
          );

          final result = await userService.fetchZweitmitgliedschaften(personId);

          expect(result, expectedFlatData);
          verify(
            mockCacheService.cacheAndRetrieveData<List<dynamic>>(
              'zweitmitgliedschaften_$personId',
              any,
              any,
              any,
            ),
          ).called(1);
          verifyNever(mockHttpClient.get('Zweitmitgliedschaften/$personId'));
        },
      );

      test(
        'should fetch, map, cache, and return data when not in cache',
        () async {
          const personId = 123;
          final apiResponse = [
            {
              'VEREINID': 201,
              'VEREINNAME': 'Club Gamma',
              'EINTRITTVEREIN': '2022-03-03',
            },
            {
              'VEREINID': 202,
              'VEREINNAME': 'Club Delta',
              'EINTRITTVEREIN': '2023-04-04',
            },
          ];
          final expectedFlatData = [
            {
              'VEREINID': 201,
              'VEREINNAME': 'Club Gamma',
              'EINTRITTVEREIN': '2022-03-03',
              'ONLINE': true,
            },
            {
              'VEREINID': 202,
              'VEREINNAME': 'Club Delta',
              'EINTRITTVEREIN': '2023-04-04',
              'ONLINE': true,
            },
          ];

          when(
            mockCacheService.cacheAndRetrieveData<List<dynamic>>(
              'zweitmitgliedschaften_$personId',
              any,
              any,
              any,
            ),
          ).thenAnswer((invocation) async {
            final fetchData =
                invocation.positionalArguments[2] as Future<dynamic> Function();
            final processResponse = invocation.positionalArguments[3]
                as List<dynamic> Function(dynamic);

            final rawResponse = await fetchData();
            final processed = processResponse(rawResponse);

            return processed.map((item) => {...item, 'ONLINE': true}).toList();
          });

          when(
            mockHttpClient.get('Zweitmitgliedschaften/$personId'),
          ).thenAnswer((_) async => apiResponse);

          final result = await userService.fetchZweitmitgliedschaften(personId);

          expect(result, expectedFlatData);
          verify(mockHttpClient.get('Zweitmitgliedschaften/$personId'))
              .called(1);
          verify(
            mockCacheService.cacheAndRetrieveData<List<dynamic>>(
              'zweitmitgliedschaften_$personId',
              any,
              any,
              any,
            ),
          ).called(1);
        },
      );

      test('should return empty list on empty response', () async {
        const personId = 123;
        final apiResponse = <dynamic>[];

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
            'zweitmitgliedschaften_$personId',
            any,
            any,
            any,
          ),
        ).thenAnswer((invocation) async {
          final fetchData =
              invocation.positionalArguments[2] as Future<dynamic> Function();
          final processResponse = invocation.positionalArguments[3]
              as List<dynamic> Function(dynamic);

          final rawResponse = await fetchData();
          final mappedResponse = processResponse(rawResponse);

          return mappedResponse;
        });

        when(
          mockHttpClient.get('Zweitmitgliedschaften/$personId'),
        ).thenAnswer((_) async => apiResponse);

        final result = await userService.fetchZweitmitgliedschaften(personId);

        expect(result, []);
        verify(mockHttpClient.get('Zweitmitgliedschaften/$personId')).called(1);
      });

      test('should return empty list and log error on network failure',
          () async {
        const personId = 123;
        // Simulate CacheService returning an empty list
        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
            'zweitmitgliedschaften_$personId',
            any,
            any,
            any,
          ),
        ).thenAnswer((_) async => []);

        final result = await userService.fetchZweitmitgliedschaften(personId);

        expect(result, []);
        verify(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
            'zweitmitgliedschaften_$personId',
            any,
            any,
            any,
          ),
        ).called(1);
        verifyNever(mockHttpClient.get(any));
      });
    });

    // ================== For PassdatenZVE ====================

    group('fetchPassdatenZVE', () {
      test(
        'should return mapped pass data ZVE from cache when available',
        () async {
          const passdatenId = 1;
          const personId = 123;
          final expectedFlatData = [
            {
              'DISZIPLINNR': 1,
              'DISZIPLIN': 'Discipline A',
              'VEREINNAME': 'Club 1',
              'ONLINE': false,
            },
            {
              'DISZIPLINNR': 2,
              'DISZIPLIN': 'Discipline B',
              'VEREINNAME': 'Club 2',
              'ONLINE': false,
            },
          ];

          when(
            mockCacheService.cacheAndRetrieveData<List<dynamic>>(
              'passdaten_zve_$passdatenId',
              any,
              any,
              any,
            ),
          ).thenAnswer(
            (_) async => expectedFlatData,
          );

          final result =
              await userService.fetchPassdatenZVE(passdatenId, personId);

          expect(result, expectedFlatData);
          verify(
            mockCacheService.cacheAndRetrieveData<List<dynamic>>(
              'passdaten_zve_$passdatenId',
              any,
              any,
              any,
            ),
          ).called(1);
          verifyNever(
            mockHttpClient.get('PassdatenZVE/$passdatenId/$personId'),
          );
        },
      );

      test(
        'should fetch, map, cache, and return data when not in cache',
        () async {
          const passdatenId = 1;
          const personId = 123;
          final apiResponse = [
            {
              'DISZIPLINNR': 3,
              'DISZIPLIN': 'Discipline C',
              'VEREINNAME': 'Club 3',
            },
            {
              'DISZIPLINNR': 4,
              'DISZIPLIN': 'Discipline D',
              'VEREINNAME': 'Club 4',
            },
          ];
          final expectedFlatData = [
            {
              'DISZIPLINNR': 3,
              'DISZIPLIN': 'Discipline C',
              'VEREINNAME': 'Club 3',
              'ONLINE': true,
            },
            {
              'DISZIPLINNR': 4,
              'DISZIPLIN': 'Discipline D',
              'VEREINNAME': 'Club 4',
              'ONLINE': true,
            },
          ];

          when(
            mockCacheService.cacheAndRetrieveData<List<dynamic>>(
              'passdaten_zve_$passdatenId',
              any,
              any,
              any,
            ),
          ).thenAnswer((invocation) async {
            final fetchData =
                invocation.positionalArguments[2] as Future<dynamic> Function();
            final processResponse = invocation.positionalArguments[3]
                as List<dynamic> Function(dynamic);

            final rawResponse = await fetchData();
            final processed = processResponse(rawResponse);

            return processed.map((item) => {...item, 'ONLINE': true}).toList();
          });

          when(
            mockHttpClient.get('PassdatenZVE/$passdatenId/$personId'),
          ).thenAnswer((_) async => apiResponse);

          final result =
              await userService.fetchPassdatenZVE(passdatenId, personId);

          expect(result, expectedFlatData);
          verify(mockHttpClient.get('PassdatenZVE/$passdatenId/$personId'))
              .called(1);
          verify(
            mockCacheService.cacheAndRetrieveData<List<dynamic>>(
              'passdaten_zve_$passdatenId',
              any,
              any,
              any,
            ),
          ).called(1);
        },
      );

      test('should return empty list on empty response', () async {
        const passdatenId = 1;
        const personId = 123;
        final apiResponse = <dynamic>[];

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
            'passdaten_zve_$passdatenId',
            any,
            any,
            any,
          ),
        ).thenAnswer((invocation) async {
          final fetchData =
              invocation.positionalArguments[2] as Future<dynamic> Function();
          final processResponse = invocation.positionalArguments[3]
              as List<dynamic> Function(dynamic);

          final rawResponse = await fetchData();
          final mappedResponse = processResponse(rawResponse);

          return mappedResponse;
        });

        when(
          mockHttpClient.get('PassdatenZVE/$passdatenId/$personId'),
        ).thenAnswer((_) async => apiResponse);

        final result =
            await userService.fetchPassdatenZVE(passdatenId, personId);

        expect(result, []);
        verify(mockHttpClient.get('PassdatenZVE/$passdatenId/$personId'))
            .called(1);
      });

      test('should return empty list and log error on network failure',
          () async {
        const passdatenId = 1;
        const personId = 123;
        // Simulate CacheService returning an empty list
        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
            'passdaten_zve_$passdatenId',
            any,
            any,
            any,
          ),
        ).thenAnswer((_) async => []);

        final result =
            await userService.fetchPassdatenZVE(passdatenId, personId);

        expect(result, []);
        verify(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
            'passdaten_zve_$passdatenId',
            any,
            any,
            any,
          ),
        ).called(1);
        verifyNever(mockHttpClient.get(any));
      });
    });

    group('updateKritischeFelderUndAdresse', () {
      test('should return true on successful update', () async {
        when(mockHttpClient.put(any, any))
            .thenAnswer((_) async => {'result': true});

        final result = await userService.updateKritischeFelderUndAdresse(
          1,
          'Mr.',
          'Test',
          'User',
          1,
          'Street 1',
          '12345',
          'City',
        );

        expect(result, isTrue);
        verify(
          mockHttpClient.put(
            'KritischeFelderUndAdresse',
            {
              'PersonID': 1,
              'Titel': 'Mr.',
              'Namen': 'Test',
              'Vorname': 'User',
              'Geschlecht': 1,
              'Strasse': 'Street 1',
              'PLZ': '12345',
              'Ort': 'City',
            },
          ),
        ).called(1);
      });

      test('should return false on failed update (API result false)', () async {
        when(mockHttpClient.put(any, any))
            .thenAnswer((_) async => {'result': false});

        final result = await userService.updateKritischeFelderUndAdresse(
          1,
          'Mr.',
          'Test',
          'User',
          1,
          'Street 1',
          '12345',
          'City',
        );

        expect(result, isFalse);
      });

      test('should return false on exception during update', () async {
        when(mockHttpClient.put(any, any))
            .thenThrow(Exception('Network error'));

        final result = await userService.updateKritischeFelderUndAdresse(
          1,
          'Mr.',
          'Test',
          'User',
          1,
          'Street 1',
          '12345',
          'City',
        );

        expect(result, isFalse);
      });
    });

    group('addKontakt', () {
      test('should return true on successful contact add', () async {
        // Assuming addKontakt expects {'ResultType': 1} for success
        when(mockHttpClient.post(any, any))
            .thenAnswer((_) async => {'result': true});

        final result = await userService.addKontakt(1, 4, 'test@example.com');

        expect(result, isTrue);
        verify(
          mockHttpClient.post(
            'KontaktHinzufuegen',
            {'PersonID': 1, 'KontaktTyp': 4, 'Kontakt': 'test@example.com'},
          ),
        ).called(1);
      });

      test('should return false on failed contact add (API ResultType not 1)',
          () async {
        when(mockHttpClient.post(any, any))
            .thenAnswer((_) async => {'ResultType': 0});

        final result = await userService.addKontakt(1, 4, 'test@example.com');

        expect(result, isFalse);
      });

      test('should return false on exception during contact add', () async {
        when(mockHttpClient.post(any, any))
            .thenThrow(Exception('Network error'));

        final result = await userService.addKontakt(1, 4, 'test@example.com');

        expect(result, isFalse);
      });
    });

    group('deleteKontakt', () {
      test('should return true on successful contact delete', () async {
        when(mockHttpClient.put(any, any))
            .thenAnswer((_) async => {'result': true});

        final result = await userService.deleteKontakt(1, 10, 4);

        expect(result, isTrue);
        verify(
          mockHttpClient.put(
            'KontaktAendern',
            {'PersonID': 1, 'KontaktID': 10, 'KontaktTyp': 4, 'Kontakt': ''},
          ),
        ).called(1);
      });

      test('should return false on failed contact delete (API result false)',
          () async {
        when(mockHttpClient.put(any, any))
            .thenAnswer((_) async => {'result': false});

        final result = await userService.deleteKontakt(1, 10, 4);

        expect(result, isFalse);
      });

      test('should return false on exception during contact delete', () async {
        when(mockHttpClient.put(any, any))
            .thenThrow(Exception('Network error'));

        final result = await userService.deleteKontakt(1, 10, 4);

        expect(result, isFalse);
      });
    });

    group('fetchKontakte', () {
      test('should return mapped contacts on successful fetch', () async {
        final apiResponse = [
          {'KONTAKTTYP': 1, 'KONTAKTID': 1, 'KONTAKT': '123-456-7890'},
          {'KONTAKTTYP': 4, 'KONTAKTID': 2, 'KONTAKT': 'private@example.com'},
          {'KONTAKTTYP': 5, 'KONTAKTID': 3, 'KONTAKT': '987-654-3210'},
          {'KONTAKTTYP': 8, 'KONTAKTID': 4, 'KONTAKT': 'business@example.com'},
        ];

        when(mockHttpClient.get('Kontakte/1'))
            .thenAnswer((_) async => apiResponse);

        final result = await userService.fetchKontakte(1);

        expect(result, [
          {
            'category': 'Privat',
            'contacts': [
              {
                'type': 'Telefonnummer Privat',
                'value': '123-456-7890',
                'kontaktId': 1,
                'rawKontaktTyp': 1,
              },
              {
                'type': 'E-Mail Privat',
                'value': 'private@example.com',
                'kontaktId': 2,
                'rawKontaktTyp': 4,
              },
            ],
          },
          {
            'category': 'Geschäftlich',
            'contacts': [
              {
                'type': 'Telefonnummer Geschäftlich',
                'value': '987-654-3210',
                'kontaktId': 3,
                'rawKontaktTyp': 5,
              },
              {
                'type': 'E-Mail Geschäftlich',
                'value': 'business@example.com',
                'kontaktId': 4,
                'rawKontaktTyp': 8,
              },
            ],
          },
        ]);
        verify(mockHttpClient.get('Kontakte/1')).called(1);
      });

      test('should return empty list on empty response', () async {
        when(mockHttpClient.get('Kontakte/1')).thenAnswer((_) async => []);

        final result = await userService.fetchKontakte(1);

        expect(result, [
          {'category': 'Privat', 'contacts': []},
          {'category': 'Geschäftlich', 'contacts': []},
        ]);
      });

      test('should return empty list on non-list response', () async {
        when(mockHttpClient.get('Kontakte/1'))
            .thenAnswer((_) async => {'error': 'not a list'});

        final result = await userService.fetchKontakte(1);

        expect(result, [
          {'category': 'Privat', 'contacts': []},
          {'category': 'Geschäftlich', 'contacts': []},
        ]);
      });

      test('should return structured empty list on network error', () async {
        when(mockHttpClient.get('Kontakte/1'))
            .thenThrow(Exception('Network error'));

        final result = await userService.fetchKontakte(1);

        expect(result, [
          {'category': 'Privat', 'contacts': []},
          {'category': 'Geschäftlich', 'contacts': []},
        ]);
        verify(mockHttpClient.get('Kontakte/1')).called(1);
      });
    });
  });
}
