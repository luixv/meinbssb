import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:meinbssb/services/api/user_service.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:meinbssb/services/http_client.dart';
import 'package:meinbssb/services/network_service.dart';

import 'user_service_test.mocks.dart';

// Generate mocks for the dependencies of UserService
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
          // Arrange
          const personId = 123;
          final cachedResponse = {
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
          };
          final expectedResult = {
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
            'ONLINE': false, // Default when cached
          };
          when(
            mockCacheService.cacheAndRetrieveData<Map<String, dynamic>>(
              'passdaten_$personId',
              any,
              any,
              any,
            ),
          ).thenAnswer((_) async => {'data': cachedResponse, 'ONLINE': false});

          // Act
          final result = await userService.fetchPassdaten(personId);

          // Assert
          expect(result, expectedResult);
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
          // Arrange
          const personId = 123;
          final apiResponse = {
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
          };
          final expectedResult = {
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
            'ONLINE': true,
          };
          when(
            mockCacheService.cacheAndRetrieveData<Map<String, dynamic>>(
              'passdaten_$personId',
              any,
              any,
              any,
            ),
          ).thenAnswer((invocation) async {
            final fetchFunction = invocation.positionalArguments[2]
                as Future<Map<String, dynamic>> Function();
            final response = await fetchFunction();
            return {'data': response, 'ONLINE': true};
          });
          when(
            mockHttpClient.get('Passdaten/$personId'),
          ).thenAnswer((_) async => apiResponse);
          when(
            mockNetworkService.getCacheExpirationDuration(),
          ).thenReturn(const Duration(days: 7));

          // Act
          final result = await userService.fetchPassdaten(personId);

          // Assert
          expect(result, expectedResult);
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
        // Arrange
        const personId = 123;
        when(
          mockHttpClient.get('Passdaten/$personId'),
        ).thenAnswer((_) async => <String, dynamic>{});
        when(
          mockCacheService.cacheAndRetrieveData<Map<String, dynamic>>(
            'passdaten_$personId',
            any,
            any,
            any,
          ),
        ).thenAnswer((invocation) async {
          final fetchFunction = invocation.positionalArguments[2]
              as Future<Map<String, dynamic>> Function();
          final response = await fetchFunction();
          return {'data': response, 'ONLINE': true};
        });

        // Act
        final result = await userService.fetchPassdaten(personId);

        // Assert
        expect(result, {'ONLINE': true});
      });
    });

    group('fetchZweitmitgliedschaften', () {
      test(
        'should return mapped zweitmitgliedschaften data from cache when available',
        () async {
          // Arrange
          const personId = 123;
          final cachedResponse = [
            {'VEREINID': 101, 'VEREINNAME': 'Club Alpha'},
            {'VEREINID': 102, 'VEREINNAME': 'Club Beta'},
          ];
          final expectedResult = [
            {'VEREINID': 101, 'VEREINNAME': 'Club Alpha', 'ONLINE': false},
            {'VEREINID': 102, 'VEREINNAME': 'Club Beta', 'ONLINE': false},
          ];
          when(
            mockCacheService.cacheAndRetrieveData<List<dynamic>>(
              'zweitmitgliedschaften_$personId',
              any,
              any,
              any,
            ),
          ).thenAnswer((_) async => {'data': cachedResponse, 'ONLINE': false});

          // Act
          final result = await userService.fetchZweitmitgliedschaften(personId);

          // Assert
          expect(result, expectedResult);
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
          // Arrange
          const personId = 123;
          final apiResponse = [
            {'VEREINID': 201, 'VEREINNAME': 'Club Gamma'},
            {'VEREINID': 202, 'VEREINNAME': 'Club Delta'},
          ];
          final expectedResult = [
            {'VEREINID': 201, 'VEREINNAME': 'Club Gamma', 'ONLINE': true},
            {'VEREINID': 202, 'VEREINNAME': 'Club Delta', 'ONLINE': true},
          ];
          when(
            mockCacheService.cacheAndRetrieveData<List<dynamic>>(
              'zweitmitgliedschaften_$personId',
              any,
              any,
              any,
            ),
          ).thenAnswer((invocation) async {
            final fetchFunction = invocation.positionalArguments[2]
                as Future<List<dynamic>> Function();
            final response = await fetchFunction();
            return {'data': response, 'ONLINE': true};
          });
          when(
            mockHttpClient.get('Zweitmitgliedschaften/$personId'),
          ).thenAnswer((_) async => apiResponse);
          when(
            mockNetworkService.getCacheExpirationDuration(),
          ).thenReturn(const Duration(days: 7));

          // Act
          final result = await userService.fetchZweitmitgliedschaften(personId);

          // Assert
          expect(result, expectedResult);
          verify(
            mockHttpClient.get('Zweitmitgliedschaften/$personId'),
          ).called(1);
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
        // Arrange
        const personId = 123;
        final apiResponse = [];
        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
            'zweitmitgliedschaften_$personId',
            any,
            any,
            any,
          ),
        ).thenAnswer((invocation) async {
          final fetchFunction = invocation.positionalArguments[2]
              as Future<List<dynamic>> Function();
          final response = await fetchFunction();
          return {'data': response, 'ONLINE': true};
        });
        when(
          mockHttpClient.get('Zweitmitgliedschaften/$personId'),
        ).thenAnswer((_) async => apiResponse);

        // Act
        final result = await userService.fetchZweitmitgliedschaften(personId);

        // Assert
        expect(result, []);
      });
    });

    group('fetchPassdatenZVE', () {
      test(
        'should return mapped pass data ZVE from cache when available',
        () async {
          // Arrange
          const passdatenId = 1;
          const personId = 123;
          final cachedResponse = [
            {
              'DISZIPLINNR': 1,
              'DISZIPLIN': 'Discipline A',
              'VEREINNAME': 'Club 1',
            },
            {
              'DISZIPLINNR': 2,
              'DISZIPLIN': 'Discipline B',
              'VEREINNAME': 'Club 2',
            },
          ];
          final expectedResult = [
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
          ).thenAnswer((_) async => {'data': cachedResponse, 'ONLINE': false});

          // Act
          final result = await userService.fetchPassdatenZVE(
            passdatenId,
            personId,
          );

          // Assert
          expect(result, expectedResult);
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
          // Arrange
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
          final expectedResult = [
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
            final fetchFunction = invocation.positionalArguments[2]
                as Future<List<dynamic>> Function();
            final response = await fetchFunction();
            return {'data': response, 'ONLINE': true};
          });
          when(
            mockHttpClient.get('PassdatenZVE/$passdatenId/$personId'),
          ).thenAnswer((_) async => apiResponse);
          when(
            mockNetworkService.getCacheExpirationDuration(),
          ).thenReturn(const Duration(days: 7));

          // Act
          final result = await userService.fetchPassdatenZVE(
            passdatenId,
            personId,
          );

          // Assert
          expect(result, expectedResult);
          verify(
            mockHttpClient.get('PassdatenZVE/$passdatenId/$personId'),
          ).called(1);
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
        // Arrange
        const passdatenId = 1;
        const personId = 123;
        final apiResponse = [];
        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
            'passdaten_zve_$passdatenId',
            any,
            any,
            any,
          ),
        ).thenAnswer((invocation) async {
          final fetchFunction = invocation.positionalArguments[2]
              as Future<List<dynamic>> Function();
          final response = await fetchFunction();
          return {'data': response, 'ONLINE': true};
        });
        when(
          mockHttpClient.get('PassdatenZVE/$passdatenId/$personId'),
        ).thenAnswer((_) async => apiResponse);

        // Act
        final result = await userService.fetchPassdatenZVE(
          passdatenId,
          personId,
        );

        // Assert
        expect(result, []);
      });
    });
  });
}
