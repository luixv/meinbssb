import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/bank_data.dart';
import 'package:meinbssb/models/contact.dart';
import 'package:meinbssb/models/schulung.dart';
import 'package:meinbssb/models/schulungsart.dart';
import 'package:meinbssb/models/schulungstermin.dart';
import 'package:meinbssb/models/disziplin.dart';
import 'package:meinbssb/models/verein.dart';
import 'package:meinbssb/models/fremde_verband.dart';
import 'package:meinbssb/models/pass_data_zve.dart';
import 'package:meinbssb/models/zweitmitgliedschaft_data.dart';
import 'package:meinbssb/models/register_schulungen_teilnehmer_response.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/services/core/image_service.dart';
import 'package:meinbssb/services/api/user_service.dart';
import 'package:meinbssb/services/api/training_service.dart';
import 'package:meinbssb/services/api/bank_service.dart';
import 'package:meinbssb/services/api/verein_service.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/core/token_service.dart';

@GenerateMocks([
  AuthService,
  ConfigService,
  CacheService,
  NetworkService,
  ImageService,
  UserService,
  TrainingService,
  BankService,
  VereinService,
  TokenService,
])
import 'api_service_test.mocks.dart';

void main() {
  late ApiService apiService;
  late MockAuthService mockAuthService;
  late MockConfigService mockConfigService;
  late MockCacheService mockCacheService;
  late MockNetworkService mockNetworkService;
  late MockImageService mockImageService;
  late MockUserService mockUserService;
  late MockTrainingService mockTrainingService;
  late MockBankService mockBankService;
  late MockVereinService mockVereinService;
  late MockTokenService mockTokenService;
  late HttpClient httpClient;

  setUp(() {
    mockAuthService = MockAuthService();
    mockConfigService = MockConfigService();
    mockCacheService = MockCacheService();
    mockNetworkService = MockNetworkService();
    mockImageService = MockImageService();
    mockUserService = MockUserService();
    mockTrainingService = MockTrainingService();
    mockBankService = MockBankService();
    mockVereinService = MockVereinService();
    mockTokenService = MockTokenService();

    httpClient = HttpClient(
      baseUrl: 'http://test.com',
      serverTimeout: 30,
      tokenService: mockTokenService,
      configService: mockConfigService,
      cacheService: mockCacheService,
    );

    apiService = ApiService(
      authService: mockAuthService,
      configService: mockConfigService,
      cacheService: mockCacheService,
      networkService: mockNetworkService,
      imageService: mockImageService,
      userService: mockUserService,
      trainingService: mockTrainingService,
      bankService: mockBankService,
      vereinService: mockVereinService,
      httpClient: httpClient,
    );
  });

  group('ApiService', () {
    group('Network Service Tests', () {
      test('hasInternet returns true when network is available', () async {
        when(mockNetworkService.hasInternet()).thenAnswer((_) async => true);

        final result = await apiService.hasInternet();
        expect(result, isTrue);
        verify(mockNetworkService.hasInternet()).called(1);
      });

      test('hasInternet returns false when network is unavailable', () async {
        when(mockNetworkService.hasInternet()).thenAnswer((_) async => false);

        final result = await apiService.hasInternet();
        expect(result, isFalse);
        verify(mockNetworkService.hasInternet()).called(1);
      });

      test('getCacheExpirationDuration returns correct duration', () {
        const expectedDuration = Duration(hours: 2);
        when(mockNetworkService.getCacheExpirationDuration())
            .thenReturn(expectedDuration);

        final result = apiService.getCacheExpirationDuration();
        expect(result, equals(expectedDuration));
        verify(mockNetworkService.getCacheExpirationDuration()).called(1);
      });
    });

    group('Auth Service Tests', () {
      test('login returns success response on valid credentials', () async {
        final expectedResponse = {
          'ResultType': 1,
          'PersonID': 123,
          'WebLoginID': 456,
        };
        when(mockAuthService.login(any, any))
            .thenAnswer((_) async => expectedResponse);

        final result = await apiService.login('test@example.com', 'password');
        expect(result, equals(expectedResponse));
        verify(mockAuthService.login('test@example.com', 'password')).called(1);
      });

      test('login returns error response on NetworkException', () async {
        when(mockAuthService.login(any, any))
            .thenThrow(NetworkException('Network error'));

        final result = await apiService.login('test@example.com', 'password');
        expect(result['ResultType'], equals(0));
        expect(
          result['ResultMessage'],
          equals('Benutzername oder Passwort ist falsch'),
        );
        verify(mockAuthService.login('test@example.com', 'password')).called(1);
      });

      test('login returns error response on general exception', () async {
        when(mockAuthService.login(any, any))
            .thenThrow(Exception('General error'));

        final result = await apiService.login('test@example.com', 'password');
        expect(result['ResultType'], equals(0));
        expect(
          result['ResultMessage'],
          equals('Benutzername oder Passwort ist falsch'),
        );
        verify(mockAuthService.login('test@example.com', 'password')).called(1);
      });

      test('register delegates to auth service', () async {
        final expectedResponse = {'ResultType': 1, 'ResultMessage': 'Success'};
        when(
          mockAuthService.register(
            firstName: anyNamed('firstName'),
            lastName: anyNamed('lastName'),
            passNumber: anyNamed('passNumber'),
            email: anyNamed('email'),
            birthDate: anyNamed('birthDate'),
            zipCode: anyNamed('zipCode'),
            personId: anyNamed('personId'),
          ),
        ).thenAnswer((_) async => expectedResponse);

        final result = await apiService.register(
          firstName: 'John',
          lastName: 'Doe',
          passNumber: '12345678',
          email: 'john@example.com',
          birthDate: '01.01.1990',
          zipCode: '12345',
          personId: 'testId',
        );

        expect(result, equals(expectedResponse));
        verify(
          mockAuthService.register(
            firstName: 'John',
            lastName: 'Doe',
            passNumber: '12345678',
            email: 'john@example.com',
            birthDate: '01.01.1990',
            zipCode: '12345',
            personId: 'testId',
          ),
        ).called(1);
      });

      test('passwordReset delegates to auth service', () async {
        final expectedResponse = {'ResultType': 1, 'ResultMessage': 'Success'};
        when(mockAuthService.passwordReset(any))
            .thenAnswer((_) async => expectedResponse);

        final result = await apiService.passwordReset('12345678');
        expect(result, equals(expectedResponse));
        verify(mockAuthService.passwordReset('12345678')).called(1);
      });

      test('changePassword delegates to auth service', () async {
        final expectedResponse = {'ResultType': 1, 'ResultMessage': 'Success'};
        when(mockAuthService.changePassword(any, any))
            .thenAnswer((_) async => expectedResponse);

        final result = await apiService.changePassword(123, 'newPassword');
        expect(result, equals(expectedResponse));
        verify(mockAuthService.changePassword(123, 'newPassword')).called(1);
      });

      test('findePersonID2 delegates to auth service', () async {
        when(mockAuthService.findePersonID2(any, any))
            .thenAnswer((_) async => true);

        final result = await apiService.findePersonID2('Doe', '12345678');
        expect(result, isTrue);
        verify(mockAuthService.findePersonID2('Doe', '12345678')).called(1);
      });
    });

    group('User Service Tests', () {
      test('fetchPassdaten returns UserData on successful API call', () async {
        const testUserData = UserData(
          personId: 439287,
          webLoginId: 13901,
          passnummer: '40100709',
          vereinNr: 401051,
          namen: 'Schürz',
          vorname: 'Lukas',
          vereinName: 'Feuerschützen Kühbach',
          passdatenId: 2000009155,
          mitgliedschaftId: 439287,
          strasse: 'Aichacher Strasse 21',
          plz: '86574',
          ort: 'Alsmoos',
        );

        when(mockUserService.fetchPassdaten(any))
            .thenAnswer((_) async => testUserData);

        final result = await apiService.fetchPassdaten(439287);
        expect(result, equals(testUserData));
        verify(mockUserService.fetchPassdaten(439287)).called(1);
      });

      test('fetchPassdaten throws exception on API error', () async {
        when(mockUserService.fetchPassdaten(any))
            .thenThrow(Exception('API error'));

        expect(() => apiService.fetchPassdaten(439287), throwsException);
        verify(mockUserService.fetchPassdaten(439287)).called(1);
      });

      test('fetchPassdatenZVE delegates to user service', () async {
        final expectedData = [
          PassDataZVE(
            passdatenZvId: 1,
            zvVereinId: 1,
            vVereinNr: 1,
            gauId: 1,
            bezirkId: 1,
            disziAusblenden: 0,
            ersaetzendurchId: 0,
            zvMitgliedschaftId: 1,
            disziplinId: 1,
          ),
        ];
        when(mockUserService.fetchPassdatenZVE(any, any))
            .thenAnswer((_) async => expectedData);

        final result = await apiService.fetchPassdatenZVE(1, 123);
        expect(result, equals(expectedData));
        verify(mockUserService.fetchPassdatenZVE(1, 123)).called(1);
      });

      test('updateKritischeFelderUndAdresse delegates to user service',
          () async {
        const testUserData = UserData(
          personId: 123,
          webLoginId: 456,
          passnummer: '12345678',
          vereinNr: 789,
          namen: 'Test',
          vorname: 'User',
          vereinName: 'Test Club',
          passdatenId: 1,
          mitgliedschaftId: 1,
        );

        when(mockUserService.updateKritischeFelderUndAdresse(any))
            .thenAnswer((_) async => true);

        final result =
            await apiService.updateKritischeFelderUndAdresse(testUserData);
        expect(result, isTrue);
        verify(mockUserService.updateKritischeFelderUndAdresse(testUserData))
            .called(1);
      });

      test('fetchZweitmitgliedschaften delegates to user service', () async {
        final expectedData = [
          ZweitmitgliedschaftData(
            vereinId: 1,
            vereinNr: 1,
            vereinName: 'Test',
            eintrittVerein: DateTime.now(),
          ),
        ];
        when(mockUserService.fetchZweitmitgliedschaften(any))
            .thenAnswer((_) async => expectedData);

        final result = await apiService.fetchZweitmitgliedschaften(123);
        expect(result, equals(expectedData));
        verify(mockUserService.fetchZweitmitgliedschaften(123)).called(1);
      });

      test('fetchKontakte delegates to user service', () async {
        final expectedData = [
          {'id': 1, 'type': 'email', 'value': 'test@example.com'},
        ];
        when(mockUserService.fetchKontakte(any))
            .thenAnswer((_) async => expectedData);

        final result = await apiService.fetchKontakte(123);
        expect(result, equals(expectedData));
        verify(mockUserService.fetchKontakte(123)).called(1);
      });

      test('addKontakt delegates to user service', () async {
        const contact =
            Contact(id: 1, personId: 123, type: 1, value: 'test@example.com');
        when(mockUserService.addKontakt(any)).thenAnswer((_) async => true);

        final result = await apiService.addKontakt(contact);
        expect(result, isTrue);
        verify(mockUserService.addKontakt(contact)).called(1);
      });

      test('deleteKontakt delegates to user service', () async {
        const contact =
            Contact(id: 1, personId: 123, type: 1, value: 'test@example.com');
        when(mockUserService.deleteKontakt(any)).thenAnswer((_) async => true);

        final result = await apiService.deleteKontakt(contact);
        expect(result, isTrue);
        verify(mockUserService.deleteKontakt(contact)).called(1);
      });
    });

    group('Training Service Tests', () {
      test('fetchAbsolvierteSchulungen delegates to training service',
          () async {
        final expectedData = [
          const Schulung(
            id: 1,
            bezeichnung: 'Test Training',
            datum: '2024-01-01',
            ausgestelltAm: '2024-01-01',
            teilnehmerId: 1,
            schulungsartId: 1,
            schulungsartBezeichnung: 'Test',
            schulungsartKurzbezeichnung: 'Test',
            schulungsartBeschreibung: 'Test',
            maxTeilnehmer: 10,
            anzahlTeilnehmer: 5,
            ort: 'Test',
            uhrzeit: '10:00',
            dauer: '2h',
            preis: '50€',
            zielgruppe: 'All',
            voraussetzungen: 'None',
            inhalt: 'Test content',
            lehrgangsinhaltHtml: '<p>Test</p>',
            abschluss: 'Certificate',
            anmerkungen: 'Test notes',
            isOnline: false,
            link: '',
            status: 'Active',
            gueltigBis: '2024-12-31',
          ),
        ];
        when(mockTrainingService.fetchAbsolvierteSchulungen(any))
            .thenAnswer((_) async => expectedData);

        final result = await apiService.fetchAbsolvierteSchulungen(123);
        expect(result, equals(expectedData));
        verify(mockTrainingService.fetchAbsolvierteSchulungen(123)).called(1);
      });

      test('fetchSchulungsarten delegates to training service', () async {
        final expectedData = [
          const Schulungsart(
            schulungsartId: 1,
            bezeichnung: 'Test Type',
            typ: 1,
            kosten: 50.0,
            ue: 2,
            omKategorieId: 1,
            rechnungAn: 1,
            verpflegungskosten: 10.0,
            uebernachtungskosten: 20.0,
            lehrmaterialkosten: 5.0,
            lehrgangsinhalt: 'Test content',
            lehrgangsinhaltHtml: '<p>Test</p>',
            webGruppe: 1,
            fuerVerlaengerungen: false,
          ),
        ];
        when(mockTrainingService.fetchSchulungsarten())
            .thenAnswer((_) async => expectedData);

        final result = await apiService.fetchSchulungsarten();
        expect(result, equals(expectedData));
        verify(mockTrainingService.fetchSchulungsarten()).called(1);
      });

      test('fetchAngemeldeteSchulungen delegates to training service',
          () async {
        final expectedData = [
          Schulungstermin(
            schulungsterminId: 1,
            schulungsartId: 1,
            schulungsTeilnehmerId: 12345,
            datum: DateTime.now(),
            bemerkung: 'Test',
            kosten: 50.0,
            ort: 'Test',
            lehrgangsleiter: 'Test',
            verpflegungskosten: 10.0,
            uebernachtungskosten: 20.0,
            lehrmaterialkosten: 5.0,
            lehrgangsinhalt: 'Test content',
            maxTeilnehmer: 10,
            webVeroeffentlichenAm: '2024-01-01',
            anmeldungenGesperrt: false,
            status: 1,
            datumBis: '2024-01-01',
            lehrgangsinhaltHtml: '<p>Test</p>',
            lehrgangsleiter2: '',
            lehrgangsleiter3: '',
            lehrgangsleiter4: '',
            lehrgangsleiterTel: '',
            lehrgangsleiter2Tel: '',
            lehrgangsleiter3Tel: '',
            lehrgangsleiter4Tel: '',
            lehrgangsleiterMail: '',
            lehrgangsleiter2Mail: '',
            lehrgangsleiter3Mail: '',
            lehrgangsleiter4Mail: '',
            anmeldeStopp: '',
            abmeldeStopp: '',
            geloescht: false,
            stornoGrund: '',
            webGruppe: 1,
            veranstaltungsBezirk: 1,
            fuerVerlaengerungen: false,
            anmeldeErlaubt: 1,
            verbandsInternPasswort: '',
            bezeichnung: 'Test Termin',
            angemeldeteTeilnehmer: 5,
          ),
        ];
        when(mockTrainingService.fetchAngemeldeteSchulungen(any, any))
            .thenAnswer((_) async => expectedData);

        final result =
            await apiService.fetchAngemeldeteSchulungen(123, '2024-01-01');
        expect(result, equals(expectedData));
        verify(
          mockTrainingService.fetchAngemeldeteSchulungen(
            123,
            '2024-01-01',
          ),
        ).called(1);
      });

      test('fetchSchulungstermine delegates to training service', () async {
        final expectedData = [
          Schulungstermin(
            schulungsterminId: 1,
            schulungsartId: 1,
            schulungsTeilnehmerId: 12345,
            datum: DateTime.now(),
            bemerkung: 'Test',
            kosten: 50.0,
            ort: 'Test',
            lehrgangsleiter: 'Test',
            verpflegungskosten: 10.0,
            uebernachtungskosten: 20.0,
            lehrmaterialkosten: 5.0,
            lehrgangsinhalt: 'Test content',
            maxTeilnehmer: 10,
            webVeroeffentlichenAm: '2024-01-01',
            anmeldungenGesperrt: false,
            status: 1,
            datumBis: '2024-01-01',
            lehrgangsinhaltHtml: '<p>Test</p>',
            lehrgangsleiter2: '',
            lehrgangsleiter3: '',
            lehrgangsleiter4: '',
            lehrgangsleiterTel: '',
            lehrgangsleiter2Tel: '',
            lehrgangsleiter3Tel: '',
            lehrgangsleiter4Tel: '',
            lehrgangsleiterMail: '',
            lehrgangsleiter2Mail: '',
            lehrgangsleiter3Mail: '',
            lehrgangsleiter4Mail: '',
            anmeldeStopp: '',
            abmeldeStopp: '',
            geloescht: false,
            stornoGrund: '',
            webGruppe: 1,
            veranstaltungsBezirk: 1,
            fuerVerlaengerungen: false,
            anmeldeErlaubt: 1,
            verbandsInternPasswort: '',
            bezeichnung: 'Test Termin',
            angemeldeteTeilnehmer: 5,
          ),
        ];
        when(mockTrainingService.fetchSchulungstermine(
          any,
          any,
          any,
          any,
        ),).thenAnswer((_) async => expectedData);

        final result = await apiService.fetchSchulungstermine(
          '2024-01-01',
          '1',
          '1',
          'true',
        );
        expect(result, equals(expectedData));
        verify(mockTrainingService.fetchSchulungstermine(
          '2024-01-01',
          '1',
          '1',
          'true',
        ),).called(1);
      });

      test('unregisterFromSchulung delegates to training service', () async {
        when(mockTrainingService.unregisterFromSchulung(any))
            .thenAnswer((_) async => true);

        final result = await apiService.unregisterFromSchulung(123);
        expect(result, isTrue);
        verify(mockTrainingService.unregisterFromSchulung(123)).called(1);
      });

      test('registerFromSchulung delegates to training service', () async {
        when(mockTrainingService.registerForSchulung(any, any))
            .thenAnswer((_) async => true);

        final result = await apiService.registerFromSchulung(123, 456);
        expect(result, isTrue);
        verify(mockTrainingService.registerForSchulung(123, 456)).called(1);
      });

      test('fetchDisziplinen delegates to training service', () async {
        final expectedData = [
          const Disziplin(
            disziplinId: 1,
            disziplinNr: '1',
            disziplin: 'Test Disziplin',
          ),
        ];
        when(mockTrainingService.fetchDisziplinen())
            .thenAnswer((_) async => expectedData);

        final result = await apiService.fetchDisziplinen();
        expect(result, equals(expectedData));
        verify(mockTrainingService.fetchDisziplinen()).called(1);
      });

      test('registerSchulungenTeilnehmer delegates to training service',
          () async {
        final expectedResponse = RegisterSchulungenTeilnehmerResponse(
          msg: 'Success',
          platz: 1,
          maxPlaetze: 10,
        );
        const testUserData = UserData(
          personId: 123,
          webLoginId: 456,
          passnummer: '12345678',
          vereinNr: 789,
          namen: 'Test',
          vorname: 'User',
          vereinName: 'Test Club',
          passdatenId: 1,
          mitgliedschaftId: 1,
        );
        const testBankData = BankData(
          id: 1,
          webloginId: 456,
          kontoinhaber: 'Test User',
          iban: 'DE89370400440532013000',
          bic: 'DEUTDEBBXXX',
          mandatSeq: 1,
        );

        when(
          mockTrainingService.registerSchulungenTeilnehmer(
            schulungTerminId: anyNamed('schulungTerminId'),
            user: anyNamed('user'),
            email: anyNamed('email'),
            telefon: anyNamed('telefon'),
            bankData: anyNamed('bankData'),
            felderArray: anyNamed('felderArray'),
          ),
        ).thenAnswer((_) async => expectedResponse);

        final result = await apiService.registerSchulungenTeilnehmer(
          schulungTerminId: 1,
          user: testUserData,
          email: 'test@example.com',
          telefon: '123456789',
          bankData: testBankData,
          felderArray: [
            {'field': 'value'},
          ],
        );

        expect(result, equals(expectedResponse));
        verify(
          mockTrainingService.registerSchulungenTeilnehmer(
            schulungTerminId: 1,
            user: testUserData,
            email: 'test@example.com',
            telefon: '123456789',
            bankData: testBankData,
            felderArray: [
              {'field': 'value'},
            ],
          ),
        ).called(1);
      });
    });

    group('Verein Service Tests', () {
      test('fetchVereine delegates to verein service', () async {
        final expectedData = [
          const Verein(
            id: 1,
            vereinsNr: '1',
            name: 'Test Verein',
          ),
        ];
        when(mockVereinService.fetchVereine())
            .thenAnswer((_) async => expectedData);

        final result = await apiService.fetchVereine();
        expect(result, equals(expectedData));
        verify(mockVereinService.fetchVereine()).called(1);
      });

      test('fetchVerein delegates to verein service', () async {
        final expectedData = [
          const Verein(
            id: 1,
            vereinsNr: '1',
            name: 'Test Verein',
          ),
        ];
        when(mockVereinService.fetchVerein(any))
            .thenAnswer((_) async => expectedData);

        final result = await apiService.fetchVerein(123);
        expect(result, equals(expectedData));
        verify(mockVereinService.fetchVerein(123)).called(1);
      });

      test('fetchFremdeVerbaende delegates to verein service', () async {
        final expectedData = [
          FremdeVerband(
            vereinId: 1,
            vereinNr: 1,
            vereinName: 'Test Verband',
          ),
        ];
        when(mockVereinService.fetchFremdeVerbaende())
            .thenAnswer((_) async => expectedData);

        final result = await apiService.fetchFremdeVerbaende(123);
        expect(result, equals(expectedData));
        verify(mockVereinService.fetchFremdeVerbaende()).called(1);
      });
    });

    group('Cache Clearing Tests', () {
      test('clearSchulungenCache delegates to training service', () async {
        when(mockTrainingService.clearSchulungenCache(any))
            .thenAnswer((_) async {});

        await apiService.clearSchulungenCache(123);
        verify(mockTrainingService.clearSchulungenCache(123)).called(1);
      });

      test('clearAllSchulungenCache delegates to training service', () async {
        when(mockTrainingService.clearAllSchulungenCache())
            .thenAnswer((_) async {});

        await apiService.clearAllSchulungenCache();
        verify(mockTrainingService.clearAllSchulungenCache()).called(1);
      });

      test('clearPassdatenCache delegates to user service', () async {
        when(mockUserService.clearPassdatenCache(any)).thenAnswer((_) async {});

        await apiService.clearPassdatenCache(123);
        verify(mockUserService.clearPassdatenCache(123)).called(1);
      });

      test('clearAllPassdatenCache delegates to user service', () async {
        when(mockUserService.clearAllPassdatenCache()).thenAnswer((_) async {});

        await apiService.clearAllPassdatenCache();
        verify(mockUserService.clearAllPassdatenCache()).called(1);
      });

      test('clearDisziplinenCache delegates to training service', () async {
        when(mockTrainingService.clearDisziplinenCache())
            .thenAnswer((_) async {});

        await apiService.clearDisziplinenCache();
        verify(mockTrainingService.clearDisziplinenCache()).called(1);
      });
    });

    group('Schuetzenausweis Tests', () {
      test('fetchSchuetzenausweis returns Uint8List on successful API call',
          () async {
        final testData = Uint8List.fromList([1, 2, 3]);
        when(mockNetworkService.getCacheExpirationDuration())
            .thenReturn(const Duration(hours: 1));
        when(
          mockImageService.fetchAndCacheSchuetzenausweis(
            any,
            any,
            any,
          ),
        ).thenAnswer((_) async => testData);

        final result = await apiService.fetchSchuetzenausweis(439287);
        expect(result, equals(testData));
        verify(
          mockImageService.fetchAndCacheSchuetzenausweis(
            439287,
            any,
            any,
          ),
        ).called(1);
      });

      test('fetchSchuetzenausweis throws exception on API error', () async {
        when(mockNetworkService.getCacheExpirationDuration())
            .thenReturn(const Duration(hours: 1));
        when(
          mockImageService.fetchAndCacheSchuetzenausweis(
            any,
            any,
            any,
          ),
        ).thenThrow(Exception('API error'));

        expect(() => apiService.fetchSchuetzenausweis(439287), throwsException);
        verify(
          mockImageService.fetchAndCacheSchuetzenausweis(
            439287,
            any,
            any,
          ),
        ).called(1);
      });
    });

    group('Bank Service Tests', () {
      test('fetchBankData returns list of BankData on successful API call',
          () async {
        final testBankData = [
          BankData(
            id: 1,
            webloginId: 13901,
            kontoinhaber: 'Test User',
            iban: 'DE89370400440532013000',
            bic: 'DEUTDEBBXXX',
            bankName: 'Test Bank',
            mandatNr: 'M123456',
            mandatName: 'Test Mandate',
            mandatSeq: 1,
            letzteNutzung: DateTime.now(),
          ),
        ];

        when(mockUserService.fetchBankData(13901))
            .thenAnswer((_) async => testBankData);

        final result = await apiService.fetchBankData(13901);
        expect(result, equals(testBankData));
        verify(mockUserService.fetchBankData(13901)).called(1);
      });

      test('fetchBankData throws exception on API error', () async {
        when(mockUserService.fetchBankData(13901))
            .thenThrow(Exception('API error'));

        expect(() => apiService.fetchBankData(13901), throwsException);
        verify(mockUserService.fetchBankData(13901)).called(1);
      });

      test('registerBankData returns true on successful registration',
          () async {
        final testBankData = BankData(
          id: 1,
          webloginId: 13901,
          kontoinhaber: 'Test User',
          iban: 'DE89370400440532013000',
          bic: 'DEUTDEBBXXX',
          bankName: 'Test Bank',
          mandatNr: 'M123456',
          mandatName: 'Test Mandate',
          mandatSeq: 1,
          letzteNutzung: DateTime.now(),
        );

        when(mockBankService.registerBankData(any))
            .thenAnswer((_) async => true);

        final result = await apiService.registerBankData(testBankData);
        expect(result, isTrue);
        verify(mockBankService.registerBankData(testBankData)).called(1);
      });

      test('registerBankData throws exception on API error', () async {
        final testBankData = BankData(
          id: 1,
          webloginId: 13901,
          kontoinhaber: 'Test User',
          iban: 'DE89370400440532013000',
          bic: 'DEUTDEBBXXX',
          bankName: 'Test Bank',
          mandatNr: 'M123456',
          mandatName: 'Test Mandate',
          mandatSeq: 1,
          letzteNutzung: DateTime.now(),
        );

        when(mockBankService.registerBankData(any))
            .thenThrow(Exception('API error'));

        expect(
          () => apiService.registerBankData(testBankData),
          throwsException,
        );
        verify(mockBankService.registerBankData(testBankData)).called(1);
      });

      test('deleteBankData returns true on successful deletion', () async {
        final testBankData = BankData(
          id: 1,
          webloginId: 13901,
          kontoinhaber: 'Test User',
          iban: 'DE89370400440532013000',
          bic: 'DEUTDEBBXXX',
          bankName: 'Test Bank',
          mandatNr: 'M123456',
          mandatName: 'Test Mandate',
          mandatSeq: 1,
          letzteNutzung: DateTime.now(),
        );

        when(mockBankService.deleteBankData(any)).thenAnswer((_) async => true);

        final result = await apiService.deleteBankData(testBankData);
        expect(result, isTrue);
        verify(mockBankService.deleteBankData(testBankData)).called(1);
      });

      test('deleteBankData throws exception on API error', () async {
        final testBankData = BankData(
          id: 1,
          webloginId: 13901,
          kontoinhaber: 'Test User',
          iban: 'DE89370400440532013000',
          bic: 'DEUTDEBBXXX',
          bankName: 'Test Bank',
          mandatNr: 'M123456',
          mandatName: 'Test Mandate',
          mandatSeq: 1,
          letzteNutzung: DateTime.now(),
        );

        when(mockBankService.deleteBankData(any))
            .thenThrow(Exception('API error'));

        expect(() => apiService.deleteBankData(testBankData), throwsException);
        verify(mockBankService.deleteBankData(testBankData)).called(1);
      });
    });
  });
}
