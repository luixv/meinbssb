import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:meinbssb/services/api/user_service.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/models/contact.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/person.dart';

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
        when(mockNetworkService.getCacheExpirationDuration())
            .thenReturn(const Duration(hours: 1));

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

        when(mockHttpClient.get('Passdaten/$testPersonId'))
            .thenAnswer((_) async => [testResponse]);

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
        when(mockNetworkService.getCacheExpirationDuration())
            .thenReturn(const Duration(hours: 1));

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

        when(mockHttpClient.get('Passdaten/$testPersonId'))
            .thenAnswer((_) async => []);

        final result = await userService.fetchPassdaten(testPersonId);

        expect(result, isNull);
      });

      test('handles error response', () async {
        when(mockNetworkService.getCacheExpirationDuration())
            .thenReturn(const Duration(hours: 1));

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

        when(mockNetworkService.getCacheExpirationDuration())
            .thenReturn(const Duration(hours: 1));

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

        when(mockHttpClient.get('Zweitmitgliedschaften/$testPersonId'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result =
            await userService.fetchZweitmitgliedschaften(testPersonId);

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
        when(mockNetworkService.getCacheExpirationDuration())
            .thenReturn(const Duration(hours: 1));

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

        when(mockHttpClient.get('Zweitmitgliedschaften/$testPersonId'))
            .thenAnswer((_) async => []);

        final result =
            await userService.fetchZweitmitgliedschaften(testPersonId);

        expect(result, isA<List<dynamic>>());
        expect(result, isEmpty);
      });

      test('handles error response', () async {
        when(mockNetworkService.getCacheExpirationDuration())
            .thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
            any,
            any,
            any,
            any,
          ),
        ).thenThrow(Exception('Network error'));

        final result =
            await userService.fetchZweitmitgliedschaften(testPersonId);

        expect(result, isA<List<dynamic>>());
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
            'DISZIPLIN': [
              {
                'DISZIPLINID': 94,
                'DISZIPLINNR': 'R.1',
                'DISZIPLIN': 'RWK Luftpistole',
              }
            ],
            'DISZIPLINID': 94,
          }
        ];

        when(mockNetworkService.getCacheExpirationDuration())
            .thenReturn(const Duration(hours: 1));

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

        when(mockHttpClient.get('PassdatenZVE/$testPassdatenId/$testPersonId'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result =
            await userService.fetchPassdatenZVE(testPassdatenId, testPersonId);

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
        expect(result[0].disziplin.length, 1);
        expect(result[0].disziplin[0].disziplin, 'RWK Luftpistole');
        expect(result[0].disziplin[0].disziplinNr, 'R.1');
        expect(result[0].disziplinId, 94);
      });

      test('handles empty response', () async {
        when(mockNetworkService.getCacheExpirationDuration())
            .thenReturn(const Duration(hours: 1));

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

        when(mockHttpClient.get('PassdatenZVE/$testPassdatenId/$testPersonId'))
            .thenAnswer((_) async => []);

        final result =
            await userService.fetchPassdatenZVE(testPassdatenId, testPersonId);

        expect(result, isA<List<dynamic>>());
        expect(result, isEmpty);
      });

      test('handles error response', () async {
        when(mockNetworkService.getCacheExpirationDuration())
            .thenReturn(const Duration(hours: 1));

        when(
          mockCacheService.cacheAndRetrieveData<List<dynamic>>(
            any,
            any,
            any,
            any,
          ),
        ).thenThrow(Exception('Network error'));

        final result =
            await userService.fetchPassdatenZVE(testPassdatenId, testPersonId);

        expect(result, isA<List<dynamic>>());
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

        final result =
            await userService.updateKritischeFelderUndAdresse(testUserData);

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
        when(mockHttpClient.put('KritischeFelderUndAdresse', any))
            .thenAnswer((_) async => {'result': false});

        final result =
            await userService.updateKritischeFelderUndAdresse(testUserData);

        expect(result, isFalse);
      });

      test('returns false on network error', () async {
        when(mockHttpClient.put('KritischeFelderUndAdresse', any))
            .thenThrow(Exception('Network error'));

        final result =
            await userService.updateKritischeFelderUndAdresse(testUserData);

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

        when(mockHttpClient.post(any, any))
            .thenAnswer((_) async => {'result': true});

        final result = await userService.addKontakt(contact);

        expect(result, isTrue);
        verify(
          mockHttpClient.post(
            'KontaktHinzufuegen',
            {
              'PersonID': contact.personId,
              'KontaktTyp': contact.type,
              'Kontakt': contact.value,
            },
          ),
        ).called(1);
      });

      test('should return false on failed contact add (API ResultType not 1)',
          () async {
        const contact = Contact(
          id: 0,
          personId: 1,
          type: 4,
          value: 'test@example.com',
        );

        when(mockHttpClient.post(any, any))
            .thenAnswer((_) async => {'result': false});

        final result = await userService.addKontakt(contact);

        expect(result, isFalse);
      });

      test('should return false on exception during contact add', () async {
        const contact = Contact(
          id: 0,
          personId: 1,
          type: 4,
          value: 'test@example.com',
        );

        when(mockHttpClient.post(any, any))
            .thenThrow(Exception('Network error'));

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

        when(mockHttpClient.put(any, any))
            .thenAnswer((_) async => {'result': true});

        final result = await userService.deleteKontakt(contact);

        expect(result, isTrue);
        verify(
          mockHttpClient.put(
            'KontaktAendern',
            {
              'PersonID': contact.personId,
              'KontaktID': contact.id,
              'KontaktTyp': contact.type,
              'Kontakt': '', // Empty contact value to indicate deletion
            },
          ),
        ).called(1);
      });

      test('should return false on failed contact delete (API result false)',
          () async {
        const contact = Contact(
          id: 10,
          personId: 1,
          type: 4,
          value: 'test@example.com',
        );

        when(mockHttpClient.put(any, any))
            .thenAnswer((_) async => {'result': false});

        final result = await userService.deleteKontakt(contact);

        expect(result, isFalse);
      });

      test('should return false on exception during contact delete', () async {
        const contact = Contact(
          id: 10,
          personId: 1,
          type: 4,
          value: 'test@example.com',
        );

        when(mockHttpClient.put(any, any))
            .thenThrow(Exception('Network error'));

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

        when(mockHttpClient.put(any, any))
            .thenAnswer((_) async => {'result': true});

        final result = await userService.updateKontakt(contact);

        expect(result, isTrue);
        verify(
          mockHttpClient.put(
            'KontaktAendern',
            contact.toJson(),
          ),
        ).called(1);
      });

      test('should return false on failed contact update (API result false)',
          () async {
        const contact = Contact(
          id: 10,
          personId: 1,
          type: 4,
          value: 'updated@example.com',
        );

        when(mockHttpClient.put(any, any))
            .thenAnswer((_) async => {'result': false});

        final result = await userService.updateKontakt(contact);

        expect(result, isFalse);
      });

      test('should return false on exception during contact update', () async {
        const contact = Contact(
          id: 10,
          personId: 1,
          type: 4,
          value: 'updated@example.com',
        );

        when(mockHttpClient.put(any, any))
            .thenThrow(Exception('Network error'));

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

        when(mockHttpClient.get('Kontakte/123'))
            .thenAnswer((_) async => apiResponse);

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
          {
            'category': 'Geschäftlich',
            'contacts': [],
          },
        ]);
      });

      test('should handle empty response', () async {
        when(mockHttpClient.get('Kontakte/123')).thenAnswer((_) async => []);

        final result = await userService.fetchKontakte(123);

        expect(result, [
          {
            'category': 'Privat',
            'contacts': [],
          },
          {
            'category': 'Geschäftlich',
            'contacts': [],
          },
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
          {
            'invalid': 'data',
          },
        ];

        when(mockHttpClient.get('Kontakte/123'))
            .thenAnswer((_) async => apiResponse);

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
          {
            'category': 'Geschäftlich',
            'contacts': [],
          },
        ]);
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
        when(mockHttpClient.get('AdresseVonPersonID/$testPersonId'))
            .thenAnswer((_) async => testResponse);

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
        when(mockHttpClient.get('AdresseVonPersonID/$testPersonId'))
            .thenAnswer((_) async => []);

        final result = await userService.fetchAdresseVonPersonID(testPersonId);
        expect(result, isEmpty);
      });

      test('handles error response', () async {
        when(mockHttpClient.get('AdresseVonPersonID/$testPersonId'))
            .thenThrow(Exception('Network error'));

        final result = await userService.fetchAdresseVonPersonID(testPersonId);
        expect(result, isEmpty);
      });
    });

    group('Cache clearing', () {
      test('clearPassdatenCache removes the correct cache key', () async {
        const personId = 123;
        when(mockCacheService.remove('passdaten_123'))
            .thenAnswer((_) async => true);
        await userService.clearPassdatenCache(personId);
        verify(mockCacheService.remove('passdaten_123')).called(1);
      });

      test('clearAllPassdatenCache calls clearPattern with passdaten_',
          () async {
        when(mockCacheService.clearPattern('passdaten_'))
            .thenAnswer((_) async => true);
        await userService.clearAllPassdatenCache();
        verify(mockCacheService.clearPattern('passdaten_')).called(1);
      });
    });
  });
}
