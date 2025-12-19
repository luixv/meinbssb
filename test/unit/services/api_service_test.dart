import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/passdaten_akzept_or_aktiv_data.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/bank_data.dart';
import 'package:meinbssb/models/bezirk_data.dart';
import 'package:meinbssb/models/contact_data.dart';
import 'package:meinbssb/models/disziplin_data.dart';
import 'package:meinbssb/models/fremde_verband_data.dart';
import 'package:meinbssb/models/gewinn_data.dart';
import 'package:meinbssb/models/pass_data_zve_data.dart';
import 'package:meinbssb/models/result_data.dart';

import 'package:meinbssb/models/schulung_data.dart';
import 'package:meinbssb/models/schulungsart_data.dart';
import 'package:meinbssb/models/schulungstermin_data.dart';
import 'package:meinbssb/models/verein_data.dart';

import 'package:meinbssb/models/zweitmitgliedschaft_data.dart';

import 'package:meinbssb/models/register_schulungen_teilnehmer_response_data.dart';
import 'package:meinbssb/models/schulungstermine_zusatzfelder_data.dart';

import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/services/core/image_service.dart';
import 'package:meinbssb/services/api/user_service.dart';
import 'package:meinbssb/services/api/training_service.dart';
import 'package:meinbssb/services/api/bank_service.dart';
import 'package:meinbssb/services/api/verein_service.dart';
import 'package:meinbssb/services/api/oktoberfest_service.dart';
import 'package:meinbssb/services/api/bezirk_service.dart';
import 'package:meinbssb/services/api/starting_rights_service.dart';
import 'package:meinbssb/services/api/rolls_and_rights_service.dart';
import 'package:meinbssb/services/api/workflow_service.dart';

import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/core/token_service.dart';
import 'package:meinbssb/services/core/postgrest_service.dart';
import 'package:meinbssb/services/core/email_service.dart';
import 'package:meinbssb/services/core/calendar_service.dart';

import 'package:meinbssb/models/person_data.dart';
import 'package:meinbssb/models/beduerfnisse_auswahl_typ_data.dart';
import 'package:meinbssb/models/beduerfnisse_auswahl_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_status_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_data.dart';

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
  HttpClient,
  PostgrestService,
  EmailService,
  OktoberfestService,
  CalendarService,
  BezirkService,
  StartingRightsService,
  RollsAndRights,
  WorkflowService,
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
  late MockPostgrestService mockPostgrestService;
  late MockEmailService mockEmailService;
  late MockOktoberfestService mockOktoberfestService;
  late MockCalendarService mockCalendarService;
  late MockBezirkService mockBezirkService;
  late MockStartingRightsService mockStartingRightsService;
  late MockRollsAndRights mockRollsAndRights;
  late MockWorkflowService mockWorkflowService;

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
    mockPostgrestService = MockPostgrestService();
    mockEmailService = MockEmailService();
    mockOktoberfestService = MockOktoberfestService();
    mockCalendarService = MockCalendarService();
    mockBezirkService = MockBezirkService();
    mockStartingRightsService = MockStartingRightsService();
    mockRollsAndRights = MockRollsAndRights();
    mockWorkflowService = MockWorkflowService();

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
      postgrestService: mockPostgrestService,
      emailService: mockEmailService,
      oktoberfestService: mockOktoberfestService,
      calendarService: mockCalendarService,
      bezirkService: mockBezirkService,
      startingRightsService: mockStartingRightsService,
      rollsAndRights: mockRollsAndRights,
      workflowService: mockWorkflowService,
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
        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(expectedDuration);

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
        when(
          mockAuthService.login(any, any),
        ).thenAnswer((_) async => expectedResponse);

        final result = await apiService.login('test@example.com', 'password');
        expect(result, equals(expectedResponse));
        verify(mockAuthService.login('test@example.com', 'password')).called(1);
      });

      test('login returns error response on NetworkException', () async {
        when(
          mockAuthService.login(any, any),
        ).thenThrow(NetworkException('Network error'));

        final result = await apiService.login('test@example.com', 'password');
        expect(result['ResultType'], equals(0));
        expect(
          result['ResultMessage'],
          equals('Benutzername oder Passwort ist falsch'),
        );
        verify(mockAuthService.login('test@example.com', 'password')).called(1);
      });

      test('login returns error response on general exception', () async {
        when(
          mockAuthService.login(any, any),
        ).thenThrow(Exception('General error'));

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
            personId: anyNamed('personId'),
          ),
        ).thenAnswer((_) async => expectedResponse);

        final result = await apiService.register(
          firstName: 'John',
          lastName: 'Doe',
          passNumber: '12345678',
          email: 'john@example.com',
          personId: 'testId',
        );

        expect(result, equals(expectedResponse));
        verify(
          mockAuthService.register(
            firstName: 'John',
            lastName: 'Doe',
            passNumber: '12345678',
            email: 'john@example.com',
            personId: 'testId',
          ),
        ).called(1);
      });

      test('passwordReset delegates to auth service', () async {
        final expectedResponse = {'ResultType': 1, 'ResultMessage': 'Success'};
        when(
          mockAuthService.resetPasswordStep1(any),
        ).thenAnswer((_) async => expectedResponse);

        final result = await apiService.passwordReset('12345678');
        expect(result, equals(expectedResponse));
        verify(mockAuthService.resetPasswordStep1('12345678')).called(1);
      });

      test('changePassword delegates to auth service', () async {
        final expectedResponse = {'ResultType': 1, 'ResultMessage': 'Success'};
        when(
          mockAuthService.myBSSBPasswortAendern(any, any),
        ).thenAnswer((_) async => expectedResponse);

        final result = await apiService.myBSSBPasswortAendern(
          123,
          'newPassword',
        );
        expect(result, equals(expectedResponse));
        verify(
          mockAuthService.myBSSBPasswortAendern(123, 'newPassword'),
        ).called(1);
      });

      test('findePersonID2 delegates to auth service', () async {
        when(
          mockAuthService.findePersonID2(any, any),
        ).thenAnswer((_) async => 439287);

        final result = await apiService.findePersonID2('Doe', '12345678');
        expect(result, equals(439287));
        verify(mockAuthService.findePersonID2('Doe', '12345678')).called(1);
      });

      test('findePersonIDSimple delegates to auth service', () async {
        when(
          mockAuthService.findePersonIDSimple(any, any, any),
        ).thenAnswer((_) async => 439287);

        final result = await apiService.findePersonIDSimple(
          'Max',
          'Mustermann',
          '12345678',
        );
        expect(result, equals(439287));
        verify(
          mockAuthService.findePersonIDSimple('Max', 'Mustermann', '12345678'),
        ).called(1);
      });

      test('findeLoginMail returns email when account exists', () async {
        const passNumber = '12345678';
        const expectedEmail = 'test@example.com';

        when(
          mockAuthService.fetchLoginEmail(any),
        ).thenAnswer((_) async => expectedEmail);

        final result = await apiService.findeLoginMail(passNumber);
        expect(result, equals(expectedEmail));
        verify(mockAuthService.fetchLoginEmail(passNumber)).called(1);
      });

      test(
        'findeLoginMail returns empty string when no account exists',
        () async {
          const passNumber = '87654321';

          when(
            mockAuthService.fetchLoginEmail(any),
          ).thenAnswer((_) async => '');

          final result = await apiService.findeLoginMail(passNumber);
          expect(result, equals(''));
          verify(mockAuthService.fetchLoginEmail(passNumber)).called(1);
        },
      );

      test('findeLoginMail handles errors gracefully', () async {
        const passNumber = '99999999';

        when(
          mockAuthService.fetchLoginEmail(any),
        ).thenThrow(Exception('API error'));

        expect(() => apiService.findeLoginMail(passNumber), throwsException);
        verify(mockAuthService.fetchLoginEmail(passNumber)).called(1);
      });
    });

    group('User Service Tests', () {
      group('deleteMeinBSSBLogin', () {
        late ApiService apiService;
        late MockUserService mockUserService;
        late MockCacheService mockCacheService;
        late MockConfigService mockConfigService;
        setUp(() {
          mockUserService = MockUserService();
          mockCacheService = MockCacheService();
          mockConfigService = MockConfigService();
          apiService = ApiService(
            authService: MockAuthService(),
            configService: mockConfigService,
            cacheService: mockCacheService,
            networkService: MockNetworkService(),
            imageService: MockImageService(),
            userService: mockUserService,
            trainingService: MockTrainingService(),
            bankService: MockBankService(),
            vereinService: MockVereinService(),
            httpClient: MockHttpClient(),
            postgrestService: MockPostgrestService(),
            emailService: MockEmailService(),
            oktoberfestService: MockOktoberfestService(),
            calendarService: MockCalendarService(),
            bezirkService: MockBezirkService(),
            startingRightsService: MockStartingRightsService(),
            rollsAndRights: MockRollsAndRights(),
            workflowService: MockWorkflowService(),
          );
        });

        test(
          'returns true when UserService.deleteMeinBSSBLogin returns true',
          () async {
            when(
              mockCacheService.getString('username'),
            ).thenAnswer((_) async => 'test@example.com');
            when(
              mockUserService.deleteMeinBSSBLogin(123, 'test@example.com'),
            ).thenAnswer((_) async => true);
            final result = await apiService.deleteMeinBSSBLogin(123);
            expect(result, isTrue);
            verify(
              mockUserService.deleteMeinBSSBLogin(123, 'test@example.com'),
            ).called(1);
          },
        );

        test(
          'returns false when UserService.deleteMeinBSSBLogin returns false',
          () async {
            when(
              mockCacheService.getString('username'),
            ).thenAnswer((_) async => 'test@example.com');
            when(
              mockUserService.deleteMeinBSSBLogin(123, 'test@example.com'),
            ).thenAnswer((_) async => false);
            final result = await apiService.deleteMeinBSSBLogin(123);
            expect(result, isFalse);
            verify(
              mockUserService.deleteMeinBSSBLogin(123, 'test@example.com'),
            ).called(1);
          },
        );

        test('throws ArgumentError when cached username is null', () async {
          when(
            mockCacheService.getString('username'),
          ).thenAnswer((_) async => null);
          expect(
            () => apiService.deleteMeinBSSBLogin(123),
            throwsA(isA<ArgumentError>()),
          );
        });
      });
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

        when(
          mockUserService.fetchPassdaten(any),
        ).thenAnswer((_) async => testUserData);

        final result = await apiService.fetchPassdaten(439287);
        expect(result, equals(testUserData));
        verify(mockUserService.fetchPassdaten(439287)).called(1);
      });

      test('fetchPassdaten throws exception on API error', () async {
        when(
          mockUserService.fetchPassdaten(any),
        ).thenThrow(Exception('API error'));

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
        when(
          mockUserService.fetchPassdatenZVE(any, any),
        ).thenAnswer((_) async => expectedData);

        final result = await apiService.fetchPassdatenZVE(1, 123);
        expect(result, equals(expectedData));
        verify(mockUserService.fetchPassdatenZVE(1, 123)).called(1);
      });

      test(
        'updateKritischeFelderUndAdresse delegates to user service',
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

          when(
            mockUserService.updateKritischeFelderUndAdresse(any),
          ).thenAnswer((_) async => true);

          final result = await apiService.updateKritischeFelderUndAdresse(
            testUserData,
          );
          expect(result, isTrue);
          verify(
            mockUserService.updateKritischeFelderUndAdresse(testUserData),
          ).called(1);
        },
      );

      test('fetchZweitmitgliedschaften delegates to user service', () async {
        final expectedData = [
          ZweitmitgliedschaftData(
            vereinId: 1,
            vereinNr: 1,
            vereinName: 'Test',
            eintrittVerein: DateTime.now(),
          ),
        ];
        when(
          mockUserService.fetchZweitmitgliedschaften(any),
        ).thenAnswer((_) async => expectedData);

        final result = await apiService.fetchZweitmitgliedschaften(123);
        expect(result, equals(expectedData));
        verify(mockUserService.fetchZweitmitgliedschaften(123)).called(1);
      });

      test('fetchKontakte delegates to user service', () async {
        final expectedData = [
          {'id': 1, 'type': 'email', 'value': 'test@example.com'},
        ];
        when(
          mockUserService.fetchKontakte(any),
        ).thenAnswer((_) async => expectedData);

        final result = await apiService.fetchKontakte(123);
        expect(result, equals(expectedData));
        verify(mockUserService.fetchKontakte(123)).called(1);
      });

      test('addKontakt delegates to user service', () async {
        const contact = Contact(
          id: 1,
          personId: 123,
          type: 1,
          value: 'test@example.com',
        );
        when(mockUserService.addKontakt(any)).thenAnswer((_) async => true);

        final result = await apiService.addKontakt(contact);
        expect(result, isTrue);
        verify(mockUserService.addKontakt(contact)).called(1);
      });

      test('deleteKontakt delegates to user service', () async {
        const contact = Contact(
          id: 1,
          personId: 123,
          type: 1,
          value: 'test@example.com',
        );
        when(mockUserService.deleteKontakt(any)).thenAnswer((_) async => true);

        final result = await apiService.deleteKontakt(contact);
        expect(result, isTrue);
        verify(mockUserService.deleteKontakt(contact)).called(1);
      });

      test(
        'fetchPassdatenAkzeptierterOderAktiverPass delegates to user service and returns correct data',
        () async {
          const testPersonId = 123;
          final expectedData = PassdatenAkzeptOrAktiv(
            passdatenId: 1,
            passStatus: 2,
            passStatusText: 'Aktiv',
            digitalerPass: 1,
            personId: testPersonId,
            erstVereinId: 10,
            evVereinNr: 20,
            evVereinName: 'Testverein',
            passNummer: '987654',
            erstelltAm: DateTime.parse('2023-01-01T00:00:00.000Z'),
            erstelltVon: 'admin',
            zves: const [],
          );
          when(
            mockUserService.fetchPassdatenAkzeptierterOderAktiverPass(any),
          ).thenAnswer((_) async => expectedData);

          final result = await apiService
              .fetchPassdatenAkzeptierterOderAktiverPass(testPersonId);
          expect(result, equals(expectedData));
          verify(
            mockUserService.fetchPassdatenAkzeptierterOderAktiverPass(
              testPersonId,
            ),
          ).called(1);
        },
      );

      test(
        'fetchZweitmitgliedschaftenZVE delegates to user service and returns expected data',
        () async {
          final expectedData = [
            ZweitmitgliedschaftData(
              vereinId: 1,
              vereinNr: 1,
              vereinName: 'Testverein',
              eintrittVerein: DateTime(2024, 1, 1),
            ),
          ];
          when(
            mockUserService.fetchZweitmitgliedschaftenZVE(any, any),
          ).thenAnswer((_) async => expectedData);

          final result = await apiService.fetchZweitmitgliedschaftenZVE(123, 1);
          expect(result, equals(expectedData));
          verify(
            mockUserService.fetchZweitmitgliedschaftenZVE(123, 1),
          ).called(1);
        },
      );

      test(
        'fetchZweitmitgliedschaftenZVE returns empty list on empty response',
        () async {
          when(
            mockUserService.fetchZweitmitgliedschaftenZVE(any, any),
          ).thenAnswer((_) async => <ZweitmitgliedschaftData>[]);

          final result = await apiService.fetchZweitmitgliedschaftenZVE(123, 1);
          expect(result, isEmpty);
          verify(
            mockUserService.fetchZweitmitgliedschaftenZVE(123, 1),
          ).called(1);
        },
      );

      test(
        'fetchZweitmitgliedschaftenZVE propagates unexpected error',
        () async {
          when(
            mockUserService.fetchZweitmitgliedschaftenZVE(any, any),
          ).thenThrow(ArgumentError('Unexpected argument'));

          expect(
            () => apiService.fetchZweitmitgliedschaftenZVE(123, 1),
            throwsArgumentError,
          );
          verify(
            mockUserService.fetchZweitmitgliedschaftenZVE(123, 1),
          ).called(1);
        },
      );
    });

    group('Training Service Tests', () {
      test(
        'fetchSchulungstermin delegates to training service and returns expected data',
        () async {
          final expectedData = Schulungstermin(
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
            fuerVuelVerlaengerungen: false,
            anmeldeErlaubt: 1,
            verbandsInternPasswort: '',
            bezeichnung: 'Test Termin',
            angemeldeteTeilnehmer: 5,
          );
          when(
            mockTrainingService.fetchSchulungstermin(any),
          ).thenAnswer((_) async => expectedData);

          final result = await apiService.fetchSchulungstermin('1');
          expect(result, equals(expectedData));
          verify(mockTrainingService.fetchSchulungstermin('1')).called(1);
        },
      );

      test(
        'fetchAbsolvierteSchulungen delegates to training service',
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
          when(
            mockTrainingService.fetchAbsolvierteSchulungen(any),
          ).thenAnswer((_) async => expectedData);

          final result = await apiService.fetchAbsolvierteSchulungen(123);
          expect(result, equals(expectedData));
          verify(mockTrainingService.fetchAbsolvierteSchulungen(123)).called(1);
        },
      );

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
        when(
          mockTrainingService.fetchSchulungsarten(),
        ).thenAnswer((_) async => expectedData);

        final result = await apiService.fetchSchulungsarten();
        expect(result, equals(expectedData));
        verify(mockTrainingService.fetchSchulungsarten()).called(1);
      });

      test(
        'fetchAngemeldeteSchulungen delegates to training service',
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
              fuerVuelVerlaengerungen: false,
              anmeldeErlaubt: 1,
              verbandsInternPasswort: '',
              bezeichnung: 'Test Termin',
              angemeldeteTeilnehmer: 5,
            ),
          ];
          when(
            mockTrainingService.fetchAngemeldeteSchulungen(any, any),
          ).thenAnswer((_) async => expectedData);

          final result = await apiService.fetchAngemeldeteSchulungen(
            123,
            '2024-01-01',
          );
          expect(result, equals(expectedData));
          verify(
            mockTrainingService.fetchAngemeldeteSchulungen(123, '2024-01-01'),
          ).called(1);
        },
      );

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
            fuerVuelVerlaengerungen: false,
            anmeldeErlaubt: 1,
            verbandsInternPasswort: '',
            bezeichnung: 'Test Termin',
            angemeldeteTeilnehmer: 5,
          ),
        ];
        when(
          mockTrainingService.fetchSchulungstermine(any, any, any, any, any),
        ).thenAnswer((_) async => expectedData);

        final result = await apiService.fetchSchulungstermine(
          '2024-01-01',
          '1',
          '1',
          'true',
          'true',
        );
        expect(result, equals(expectedData));
        verify(
          mockTrainingService.fetchSchulungstermine(
            '2024-01-01',
            '1',
            '1',
            'true',
            'true',
          ),
        ).called(1);
      });

      test('unregisterFromSchulung delegates to training service', () async {
        when(
          mockTrainingService.unregisterFromSchulung(any),
        ).thenAnswer((_) async => true);

        final result = await apiService.unregisterFromSchulung(123);
        expect(result, isTrue);
        verify(mockTrainingService.unregisterFromSchulung(123)).called(1);
      });

      test('registerFromSchulung delegates to training service', () async {
        when(
          mockTrainingService.registerForSchulung(any, any),
        ).thenAnswer((_) async => true);

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
        when(
          mockTrainingService.fetchDisziplinen(),
        ).thenAnswer((_) async => expectedData);

        final result = await apiService.fetchDisziplinen();
        expect(result, equals(expectedData));
        verify(mockTrainingService.fetchDisziplinen()).called(1);
      });

      test(
        'registerSchulungenTeilnehmer delegates to training service',
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
              angemeldetUeber: anyNamed('angemeldetUeber'),
              angemeldetUeberEmail: anyNamed('angemeldetUeberEmail'),
              angemeldetUeberTelefon: anyNamed('angemeldetUeberTelefon'),
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
            angemeldetUeber: 'Test User',
            angemeldetUeberEmail: 'registrar@example.com',
            angemeldetUeberTelefon: '987654321',
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
              angemeldetUeber: 'Test User',
              angemeldetUeberEmail: 'registrar@example.com',
              angemeldetUeberTelefon: '987654321',
            ),
          ).called(1);
        },
      );

      test(
        'fetchSchulungstermineZusatzfelder returns mapped list on valid response',
        () async {
          final expectedList = [
            const SchulungstermineZusatzfelder(
              schulungstermineFeldId: 1,
              schulungsterminId: 876,
              feldbezeichnung: 'Feld A',
            ),
            const SchulungstermineZusatzfelder(
              schulungstermineFeldId: 2,
              schulungsterminId: 876,
              feldbezeichnung: 'Feld B',
            ),
          ];
          when(
            mockTrainingService.fetchSchulungstermineZusatzfelder(876),
          ).thenAnswer((_) async => expectedList);

          final result = await apiService.fetchSchulungstermineZusatzfelder(
            876,
          );
          expect(result, equals(expectedList));
          verify(
            mockTrainingService.fetchSchulungstermineZusatzfelder(876),
          ).called(1);
        },
      );

      test(
        'fetchSchulungstermineZusatzfelder returns empty list on empty response',
        () async {
          when(
            mockTrainingService.fetchSchulungstermineZusatzfelder(876),
          ).thenAnswer((_) async => []);
          final result = await apiService.fetchSchulungstermineZusatzfelder(
            876,
          );
          expect(result, isEmpty);
          verify(
            mockTrainingService.fetchSchulungstermineZusatzfelder(876),
          ).called(1);
        },
      );

      test('fetchSchulungstermineZusatzfelder throws on exception', () async {
        when(
          mockTrainingService.fetchSchulungstermineZusatzfelder(876),
        ).thenThrow(Exception('API error'));
        expect(
          () => apiService.fetchSchulungstermineZusatzfelder(876),
          throwsException,
        );
        verify(
          mockTrainingService.fetchSchulungstermineZusatzfelder(876),
        ).called(1);
      });

      test(
        'fetchSchulungstermineZusatzfelder handles different schulungsterminId',
        () async {
          final expectedList = [
            const SchulungstermineZusatzfelder(
              schulungstermineFeldId: 10,
              schulungsterminId: 999,
              feldbezeichnung: 'Custom Field',
            ),
          ];
          when(
            mockTrainingService.fetchSchulungstermineZusatzfelder(999),
          ).thenAnswer((_) async => expectedList);

          final result = await apiService.fetchSchulungstermineZusatzfelder(
            999,
          );
          expect(result, equals(expectedList));
          expect(result.first.schulungsterminId, equals(999));
          verify(
            mockTrainingService.fetchSchulungstermineZusatzfelder(999),
          ).called(1);
        },
      );

      test(
        'fetchSchulungstermineZusatzfelder handles multiple fields with different types',
        () async {
          final expectedList = [
            const SchulungstermineZusatzfelder(
              schulungstermineFeldId: 1,
              schulungsterminId: 500,
              feldbezeichnung: 'Text Field',
            ),
            const SchulungstermineZusatzfelder(
              schulungstermineFeldId: 2,
              schulungsterminId: 500,
              feldbezeichnung: 'Number Field',
            ),
            const SchulungstermineZusatzfelder(
              schulungstermineFeldId: 3,
              schulungsterminId: 500,
              feldbezeichnung: 'Date Field',
            ),
            const SchulungstermineZusatzfelder(
              schulungstermineFeldId: 4,
              schulungsterminId: 500,
              feldbezeichnung: 'Boolean Field',
            ),
          ];
          when(
            mockTrainingService.fetchSchulungstermineZusatzfelder(500),
          ).thenAnswer((_) async => expectedList);

          final result = await apiService.fetchSchulungstermineZusatzfelder(
            500,
          );
          expect(result, equals(expectedList));
          expect(result.length, equals(4));
          expect(
            result.map((e) => e.feldbezeichnung).toList(),
            containsAll([
              'Text Field',
              'Number Field',
              'Date Field',
              'Boolean Field',
            ]),
          );
          verify(
            mockTrainingService.fetchSchulungstermineZusatzfelder(500),
          ).called(1);
        },
      );

      test(
        'fetchSchulungstermineZusatzfelder throws NetworkException',
        () async {
          when(
            mockTrainingService.fetchSchulungstermineZusatzfelder(876),
          ).thenThrow(NetworkException('Network connection failed'));
          expect(
            () => apiService.fetchSchulungstermineZusatzfelder(876),
            throwsA(isA<NetworkException>()),
          );
          verify(
            mockTrainingService.fetchSchulungstermineZusatzfelder(876),
          ).called(1);
        },
      );

      test(
        'fetchSchulungstermineZusatzfelder throws FormatException',
        () async {
          when(
            mockTrainingService.fetchSchulungstermineZusatzfelder(876),
          ).thenThrow(const FormatException('Invalid data format'));
          expect(
            () => apiService.fetchSchulungstermineZusatzfelder(876),
            throwsA(isA<FormatException>()),
          );
          verify(
            mockTrainingService.fetchSchulungstermineZusatzfelder(876),
          ).called(1);
        },
      );

      test(
        'fetchSchulungstermineZusatzfelder handles large dataset correctly',
        () async {
          // Generate a large list of additional fields
          final expectedList = List.generate(
            100,
            (index) => SchulungstermineZusatzfelder(
              schulungstermineFeldId: index + 1,
              schulungsterminId: 876,
              feldbezeichnung: 'Field ${index + 1}',
            ),
          );
          when(
            mockTrainingService.fetchSchulungstermineZusatzfelder(876),
          ).thenAnswer((_) async => expectedList);

          final result = await apiService.fetchSchulungstermineZusatzfelder(
            876,
          );
          expect(result, equals(expectedList));
          expect(result.length, equals(100));
          expect(result.first.feldbezeichnung, equals('Field 1'));
          expect(result.last.feldbezeichnung, equals('Field 100'));
          verify(
            mockTrainingService.fetchSchulungstermineZusatzfelder(876),
          ).called(1);
        },
      );

      test(
        'fetchSchulungstermineZusatzfelder handles zero schulungsterminId',
        () async {
          final expectedList = [
            const SchulungstermineZusatzfelder(
              schulungstermineFeldId: 1,
              schulungsterminId: 0,
              feldbezeichnung: 'Default Field',
            ),
          ];
          when(
            mockTrainingService.fetchSchulungstermineZusatzfelder(0),
          ).thenAnswer((_) async => expectedList);

          final result = await apiService.fetchSchulungstermineZusatzfelder(0);
          expect(result, equals(expectedList));
          expect(result.first.schulungsterminId, equals(0));
          verify(
            mockTrainingService.fetchSchulungstermineZusatzfelder(0),
          ).called(1);
        },
      );

      test(
        'fetchSchulungstermineZusatzfelder handles negative schulungsterminId',
        () async {
          when(
            mockTrainingService.fetchSchulungstermineZusatzfelder(-1),
          ).thenAnswer((_) async => []);

          final result = await apiService.fetchSchulungstermineZusatzfelder(-1);
          expect(result, isEmpty);
          verify(
            mockTrainingService.fetchSchulungstermineZusatzfelder(-1),
          ).called(1);
        },
      );

      test(
        'fetchSchulungstermineZusatzfelder validates field IDs are unique',
        () async {
          final expectedList = [
            const SchulungstermineZusatzfelder(
              schulungstermineFeldId: 1,
              schulungsterminId: 876,
              feldbezeichnung: 'Field A',
            ),
            const SchulungstermineZusatzfelder(
              schulungstermineFeldId: 2,
              schulungsterminId: 876,
              feldbezeichnung: 'Field B',
            ),
            const SchulungstermineZusatzfelder(
              schulungstermineFeldId: 3,
              schulungsterminId: 876,
              feldbezeichnung: 'Field C',
            ),
          ];
          when(
            mockTrainingService.fetchSchulungstermineZusatzfelder(876),
          ).thenAnswer((_) async => expectedList);

          final result = await apiService.fetchSchulungstermineZusatzfelder(
            876,
          );
          expect(result, equals(expectedList));

          // Validate that all field IDs are unique
          final fieldIds = result.map((e) => e.schulungstermineFeldId).toList();
          final uniqueFieldIds = fieldIds.toSet().toList();
          expect(fieldIds.length, equals(uniqueFieldIds.length));

          verify(
            mockTrainingService.fetchSchulungstermineZusatzfelder(876),
          ).called(1);
        },
      );

      test(
        'fetchSchulungstermineZusatzfelder handles fields with special characters',
        () async {
          final expectedList = [
            const SchulungstermineZusatzfelder(
              schulungstermineFeldId: 1,
              schulungsterminId: 876,
              feldbezeichnung: 'Feld mit Umlauten: äöüß',
            ),
            const SchulungstermineZusatzfelder(
              schulungstermineFeldId: 2,
              schulungsterminId: 876,
              feldbezeichnung: 'Field with symbols: @#\$%^&*()',
            ),
            const SchulungstermineZusatzfelder(
              schulungstermineFeldId: 3,
              schulungsterminId: 876,
              feldbezeichnung: 'Unicode: 🎯📚💻',
            ),
          ];
          when(
            mockTrainingService.fetchSchulungstermineZusatzfelder(876),
          ).thenAnswer((_) async => expectedList);

          final result = await apiService.fetchSchulungstermineZusatzfelder(
            876,
          );
          expect(result, equals(expectedList));
          expect(result[0].feldbezeichnung, contains('äöüß'));
          expect(result[1].feldbezeichnung, contains('@#\$%'));
          expect(result[2].feldbezeichnung, contains('🎯'));
          verify(
            mockTrainingService.fetchSchulungstermineZusatzfelder(876),
          ).called(1);
        },
      );

      test(
        'fetchSchulungstermineZusatzfelder handles very long field names',
        () async {
          final longFieldName = 'A' * 500; // Very long field name
          final expectedList = [
            SchulungstermineZusatzfelder(
              schulungstermineFeldId: 1,
              schulungsterminId: 876,
              feldbezeichnung: longFieldName,
            ),
          ];
          when(
            mockTrainingService.fetchSchulungstermineZusatzfelder(876),
          ).thenAnswer((_) async => expectedList);

          final result = await apiService.fetchSchulungstermineZusatzfelder(
            876,
          );
          expect(result, equals(expectedList));
          expect(result.first.feldbezeichnung.length, equals(500));
          verify(
            mockTrainingService.fetchSchulungstermineZusatzfelder(876),
          ).called(1);
        },
      );

      test(
        'fetchSchulungstermineZusatzfelder handles timeout exception',
        () async {
          when(
            mockTrainingService.fetchSchulungstermineZusatzfelder(876),
          ).thenThrow(
            TimeoutException('Request timeout', const Duration(seconds: 30)),
          );
          expect(
            () => apiService.fetchSchulungstermineZusatzfelder(876),
            throwsA(isA<TimeoutException>()),
          );
          verify(
            mockTrainingService.fetchSchulungstermineZusatzfelder(876),
          ).called(1);
        },
      );

      group('isRegisterForThisSchulung', () {
        test(
          'delegates to training service and returns true when registration found',
          () async {
            when(
              mockTrainingService.isRegisterForThisSchulung(
                argThat(equals(123)),
                argThat(equals(456)),
              ),
            ).thenAnswer((_) async => true);

            final result = await apiService.isRegisterForThisSchulung(123, 456);

            expect(result, isTrue);
            verify(
              mockTrainingService.isRegisterForThisSchulung(123, 456),
            ).called(1);
          },
        );

        test(
          'delegates to training service and returns false when no registration found',
          () async {
            when(
              mockTrainingService.isRegisterForThisSchulung(
                argThat(equals(789)),
                argThat(equals(101)),
              ),
            ).thenAnswer((_) async => false);

            final result = await apiService.isRegisterForThisSchulung(789, 101);

            expect(result, isFalse);
            verify(
              mockTrainingService.isRegisterForThisSchulung(789, 101),
            ).called(1);
          },
        );

        test('propagates exception when training service throws', () async {
          when(
            mockTrainingService.isRegisterForThisSchulung(
              argThat(equals(111)),
              argThat(equals(222)),
            ),
          ).thenThrow(Exception('Database connection failed'));

          expect(
            () => apiService.isRegisterForThisSchulung(111, 222),
            throwsException,
          );

          verify(
            mockTrainingService.isRegisterForThisSchulung(111, 222),
          ).called(1);
        });
      });
    });

    group('Verein Service Tests', () {
      test('fetchVereine delegates to verein service', () async {
        final expectedData = [
          const Verein(id: 1, vereinsNr: 1, name: 'Test Verein'),
        ];
        when(
          mockVereinService.fetchVereine(),
        ).thenAnswer((_) async => expectedData);

        final result = await apiService.fetchVereine();
        expect(result, equals(expectedData));
        verify(mockVereinService.fetchVereine()).called(1);
      });

      test('fetchVerein delegates to verein service', () async {
        final expectedData = [
          const Verein(id: 1, vereinsNr: 1, name: 'Test Verein'),
        ];
        when(
          mockVereinService.fetchVerein(any),
        ).thenAnswer((_) async => expectedData);

        final result = await apiService.fetchVerein(123);
        expect(result, equals(expectedData));
        verify(mockVereinService.fetchVerein(123)).called(1);
      });

      test('fetchFremdeVerbaende delegates to verein service', () async {
        final expectedData = [
          FremdeVerband(vereinId: 1, vereinNr: 1, vereinName: 'Test Verband'),
        ];
        when(
          mockVereinService.fetchFremdeVerbaende(),
        ).thenAnswer((_) async => expectedData);

        final result = await apiService.fetchFremdeVerbaende(123);
        expect(result, equals(expectedData));
        verify(mockVereinService.fetchFremdeVerbaende()).called(1);
      });
    });

    group('Cache Clearing Tests', () {
      test('clearSchulungenCache delegates to training service', () async {
        when(
          mockTrainingService.clearSchulungenCache(any),
        ).thenAnswer((_) async {});
        await apiService.clearSchulungenCache(123);
        verify(mockTrainingService.clearSchulungenCache(123)).called(1);
      });

      test('clearAllSchulungenCache delegates to training service', () async {
        when(
          mockTrainingService.clearAllSchulungenCache(),
        ).thenAnswer((_) async {});

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
        when(
          mockTrainingService.clearDisziplinenCache(),
        ).thenAnswer((_) async {});

        await apiService.clearDisziplinenCache();
        verify(mockTrainingService.clearDisziplinenCache()).called(1);
      });
    });

    group('Schuetzenausweis Tests', () {
      test(
        'fetchSchuetzenausweis returns Uint8List on successful API call',
        () async {
          final testData = Uint8List.fromList([1, 2, 3]);
          when(
            mockNetworkService.getCacheExpirationDuration(),
          ).thenReturn(const Duration(hours: 1));
          when(
            mockImageService.fetchAndCacheSchuetzenausweis(any, any),
          ).thenAnswer((_) async => testData);

          final result = await apiService.fetchSchuetzenausweis(439287);
          expect(result, equals(testData));
          verify(
            mockImageService.fetchAndCacheSchuetzenausweis(439287, any),
          ).called(1);
        },
      );

      test('fetchSchuetzenausweis throws exception on API error', () async {
        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));
        when(
          mockImageService.fetchAndCacheSchuetzenausweis(any, any),
        ).thenThrow(Exception('API error'));

        expect(() => apiService.fetchSchuetzenausweis(439287), throwsException);
        verify(
          mockImageService.fetchAndCacheSchuetzenausweis(439287, any),
        ).called(1);
      });
    });

    group('fetchAdresseVonPersonID', () {
      late ApiService apiService;
      late MockUserService mockUserService;
      setUp(() {
        mockUserService = MockUserService();
        apiService = ApiService(
          configService: MockConfigService(),
          httpClient: MockHttpClient(),
          imageService: MockImageService(),
          cacheService: MockCacheService(),
          networkService: MockNetworkService(),
          trainingService: MockTrainingService(),
          userService: mockUserService,
          authService: MockAuthService(),
          bankService: MockBankService(),
          vereinService: MockVereinService(),
          postgrestService: MockPostgrestService(),
          emailService: MockEmailService(),
          oktoberfestService: MockOktoberfestService(),
          calendarService: MockCalendarService(),
          bezirkService: MockBezirkService(),
          startingRightsService: MockStartingRightsService(),
          rollsAndRights: MockRollsAndRights(),
          workflowService: MockWorkflowService(),
        );
      });

      test('returns List<Person> from userService', () async {
        const testPersonId = 439287;
        final testPersons = [
          Person(
            personId: 439287,
            namen: 'Rizoudis',
            vorname: 'Kostas',
            geschlecht: true,
            geburtsdatum: DateTime.parse('1955-07-16T00:00:00.000+02:00'),
            passnummer: '40100709',
            strasse: 'Eisenacherstr 9',
            plz: '80804',
            ort: 'München',
          ),
        ];
        when(
          mockUserService.fetchAdresseVonPersonID(testPersonId),
        ).thenAnswer((_) async => testPersons);
        final result = await apiService.fetchAdresseVonPersonID(testPersonId);
        expect(result, isA<List<Person>>());
        expect(result.length, 1);
        expect(result.first.namen, 'Rizoudis');
      });
    });

    group('PostgrestService Tests', () {
      test('uploadProfilePhoto delegates to postgrest service', () async {
        final photoBytes = [1, 2, 3, 4, 5];
        when(
          mockPostgrestService.uploadProfilePhoto('123', photoBytes),
        ).thenAnswer((_) async => true);

        final result = await apiService.uploadProfilePhoto('123', photoBytes);
        expect(result, isTrue);
        verify(
          mockPostgrestService.uploadProfilePhoto('123', photoBytes),
        ).called(1);
      });

      test('uploadProfilePhoto returns false on failure', () async {
        final photoBytes = [1, 2, 3, 4, 5];
        when(
          mockPostgrestService.uploadProfilePhoto('456', photoBytes),
        ).thenAnswer((_) async => false);

        final result = await apiService.uploadProfilePhoto('456', photoBytes);
        expect(result, isFalse);
        verify(
          mockPostgrestService.uploadProfilePhoto('456', photoBytes),
        ).called(1);
      });

      test('deleteProfilePhoto delegates to postgrest service', () async {
        when(
          mockPostgrestService.deleteProfilePhoto('123'),
        ).thenAnswer((_) async => true);

        final result = await apiService.deleteProfilePhoto('123');
        expect(result, isTrue);
        verify(mockPostgrestService.deleteProfilePhoto('123')).called(1);
      });

      test('deleteProfilePhoto returns false on failure', () async {
        when(
          mockPostgrestService.deleteProfilePhoto('456'),
        ).thenAnswer((_) async => false);

        final result = await apiService.deleteProfilePhoto('456');
        expect(result, isFalse);
        verify(mockPostgrestService.deleteProfilePhoto('456')).called(1);
      });

      test('getProfilePhoto returns photo bytes on successful call', () async {
        final expectedPhotoBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        when(
          mockPostgrestService.getProfilePhoto('123'),
        ).thenAnswer((_) async => expectedPhotoBytes);

        final result = await apiService.getProfilePhoto('123');
        expect(result, equals(expectedPhotoBytes));
        expect(result, isA<Uint8List>());
        verify(mockPostgrestService.getProfilePhoto('123')).called(1);
      });

      test('getProfilePhoto returns null when no photo exists', () async {
        when(
          mockPostgrestService.getProfilePhoto('456'),
        ).thenAnswer((_) async => null);

        final result = await apiService.getProfilePhoto('456');
        expect(result, isNull);
        verify(mockPostgrestService.getProfilePhoto('456')).called(1);
      });

      test('getProfilePhoto throws exception on API error', () async {
        when(
          mockPostgrestService.getProfilePhoto('789'),
        ).thenThrow(Exception('Database error'));

        expect(() => apiService.getProfilePhoto('789'), throwsException);
        verify(mockPostgrestService.getProfilePhoto('789')).called(1);
      });

      test('getProfilePhoto handles different user IDs correctly', () async {
        final photoBytes1 = Uint8List.fromList([1, 2, 3]);
        final photoBytes2 = Uint8List.fromList([4, 5, 6]);

        when(
          mockPostgrestService.getProfilePhoto('user1'),
        ).thenAnswer((_) async => photoBytes1);
        when(
          mockPostgrestService.getProfilePhoto('user2'),
        ).thenAnswer((_) async => photoBytes2);

        final result1 = await apiService.getProfilePhoto('user1');
        final result2 = await apiService.getProfilePhoto('user2');

        expect(result1, equals(photoBytes1));
        expect(result2, equals(photoBytes2));
        verify(mockPostgrestService.getProfilePhoto('user1')).called(1);
        verify(mockPostgrestService.getProfilePhoto('user2')).called(1);
      });

      test('createUser delegates to postgrest service', () async {
        final expectedUser = {
          'id': 1,
          'firstname': 'John',
          'lastname': 'Doe',
          'email': 'john@example.com',
        };
        when(
          mockPostgrestService.createUser(
            firstName: anyNamed('firstName'),
            lastName: anyNamed('lastName'),
            email: anyNamed('email'),
            passNumber: anyNamed('passNumber'),
            personId: anyNamed('personId'),
            verificationToken: anyNamed('verificationToken'),
          ),
        ).thenAnswer((_) async => expectedUser);

        final result = await apiService.createUser(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          passNumber: '12345678',
          personId: '123',
          verificationToken: 'token123',
        );

        expect(result, equals(expectedUser));
        verify(
          mockPostgrestService.createUser(
            firstName: 'John',
            lastName: 'Doe',
            email: 'john@example.com',
            passNumber: '12345678',
            personId: '123',
            verificationToken: 'token123',
          ),
        ).called(1);
      });

      test('getUserByEmail delegates to postgrest service', () async {
        final expectedUser = {'id': 1, 'email': 'test@example.com'};
        when(
          mockPostgrestService.getUserByEmail('test@example.com'),
        ).thenAnswer((_) async => expectedUser);

        final result = await apiService.getUserByEmail('test@example.com');
        expect(result, equals(expectedUser));
        verify(
          mockPostgrestService.getUserByEmail('test@example.com'),
        ).called(1);
      });

      test('getUserByPassNumber delegates to postgrest service', () async {
        final expectedUser = {'id': 1, 'pass_number': '12345678'};
        when(
          mockPostgrestService.getUserByPassNumber('12345678'),
        ).thenAnswer((_) async => expectedUser);

        final result = await apiService.getUserByPassNumber('12345678');
        expect(result, equals(expectedUser));
        verify(mockPostgrestService.getUserByPassNumber('12345678')).called(1);
      });

      test('verifyUser delegates to postgrest service', () async {
        when(
          mockPostgrestService.verifyUser('token123'),
        ).thenAnswer((_) async => true);

        final result = await apiService.verifyUser('token123');
        expect(result, isTrue);
        verify(mockPostgrestService.verifyUser('token123')).called(1);
      });

      test('deleteUserRegistration delegates to postgrest service', () async {
        when(
          mockPostgrestService.deleteUserRegistration(123),
        ).thenAnswer((_) async => true);

        final result = await apiService.deleteUserRegistration(123);
        expect(result, isTrue);
        verify(mockPostgrestService.deleteUserRegistration(123)).called(1);
      });

      test(
        'getUserByVerificationToken delegates to postgrest service',
        () async {
          final expectedUser = {'id': 1, 'verification_token': 'token123'};
          when(
            mockPostgrestService.getUserByVerificationToken('token123'),
          ).thenAnswer((_) async => expectedUser);

          final result = await apiService.getUserByVerificationToken(
            'token123',
          );
          expect(result, equals(expectedUser));
          verify(
            mockPostgrestService.getUserByVerificationToken('token123'),
          ).called(1);
        },
      );

      test(
        'add delegates to postgrest service and returns expected user',
        () async {
          final expectedUser = {
            'id': 1,
            'personId': '123',
            'email': 'test@example.com',
          };
          when(
            mockPostgrestService.getUserByPersonId('123'),
          ).thenAnswer((_) async => expectedUser);

          final result = await apiService.getUserByPersonId('123');
          expect(result, equals(expectedUser));
          verify(mockPostgrestService.getUserByPersonId('123')).called(1);
        },
      );

      test('getUserByPersonId returns null when user not found', () async {
        when(
          mockPostgrestService.getUserByPersonId('456'),
        ).thenAnswer((_) async => null);

        final result = await apiService.getUserByPersonId('456');
        expect(result, isNull);
        verify(mockPostgrestService.getUserByPersonId('456')).called(1);
      });

      test('getUserByPersonId throws exception on error', () async {
        when(
          mockPostgrestService.getUserByPersonId('789'),
        ).thenThrow(Exception('Database error'));

        expect(() => apiService.getUserByPersonId('789'), throwsException);
        verify(mockPostgrestService.getUserByPersonId('789')).called(1);
      });
    });

    group('Bezirk Service Tests', () {
      test('fetchBezirkeforSearch delegates to bezirk service', () async {
        final expectedData = [
          const BezirkSearchTriple(
            bezirkId: 1,
            bezirkNr: 1,
            bezirkName: 'TestBezirk',
          ),
        ];
        when(
          mockBezirkService.fetchBezirkeforSearch(),
        ).thenAnswer((_) async => expectedData);

        final result = await apiService.fetchBezirkeforSearch();
        expect(result, equals(expectedData));
        verify(mockBezirkService.fetchBezirkeforSearch()).called(1);
      });

      test('fetchBezirk delegates to bezirk service', () async {
        const expectedBezirk = Bezirk(
          bezirkId: 2,
          bezirkNr: 2,
          bezirkName: 'Bezirk2',
        );
        when(
          mockBezirkService.fetchBezirk(any),
        ).thenAnswer((_) async => [expectedBezirk]);

        final result = await apiService.fetchBezirk(2);
        expect(result, equals([expectedBezirk]));
        verify(mockBezirkService.fetchBezirk(2)).called(1);
      });

      test('fetchBezirke delegates to bezirk service', () async {
        final expectedList = [
          const Bezirk(bezirkId: 3, bezirkNr: 3, bezirkName: 'Bezirk3'),
          const Bezirk(bezirkId: 4, bezirkNr: 4, bezirkName: 'Bezirk4'),
        ];
        when(
          mockBezirkService.fetchBezirke(),
        ).thenAnswer((_) async => expectedList);

        final result = await apiService.fetchBezirke();
        expect(result, equals(expectedList));
        verify(mockBezirkService.fetchBezirke()).called(1);
      });
    });

    group('Email Validation', () {
      test(
        'createEmailValidationEntry delegates to postgrest service',
        () async {
          when(
            mockPostgrestService.createEmailValidationEntry(
              personId: anyNamed('personId'),
              email: anyNamed('email'),
              emailType: anyNamed('emailType'),
              verificationToken: anyNamed('verificationToken'),
            ),
          ).thenAnswer((_) async {});

          await apiService.createEmailValidationEntry(
            personId: '123',
            email: 'test@example.com',
            emailType: 'private',
            verificationToken: 'token123',
          );

          verify(
            mockPostgrestService.createEmailValidationEntry(
              personId: '123',
              email: 'test@example.com',
              emailType: 'private',
              verificationToken: 'token123',
            ),
          ).called(1);
        },
      );

      test(
        'getEmailValidationByToken delegates to postgrest service',
        () async {
          final expectedEntry = {
            'id': 1,
            'person_id': '123',
            'email': 'test@example.com',
            'emailtype': 'private',
            'verification_token': 'token123',
            'validated': false,
          };
          when(
            mockPostgrestService.getEmailValidationByToken('token123'),
          ).thenAnswer((_) async => expectedEntry);

          final result = await apiService.getEmailValidationByToken('token123');
          expect(result, equals(expectedEntry));
          verify(
            mockPostgrestService.getEmailValidationByToken('token123'),
          ).called(1);
        },
      );

      test('getEmailValidationByToken returns null when not found', () async {
        when(
          mockPostgrestService.getEmailValidationByToken('token123'),
        ).thenAnswer((_) async => null);

        final result = await apiService.getEmailValidationByToken('token123');
        expect(result, isNull);
        verify(
          mockPostgrestService.getEmailValidationByToken('token123'),
        ).called(1);
      });

      test(
        'markEmailValidationAsValidated delegates to postgrest service',
        () async {
          when(
            mockPostgrestService.markEmailValidationAsValidated('token123'),
          ).thenAnswer((_) async => true);

          final result = await apiService.markEmailValidationAsValidated(
            'token123',
          );
          expect(result, isTrue);
          verify(
            mockPostgrestService.markEmailValidationAsValidated('token123'),
          ).called(1);
        },
      );

      test('markEmailValidationAsValidated returns false on error', () async {
        when(
          mockPostgrestService.markEmailValidationAsValidated('token123'),
        ).thenAnswer((_) async => false);

        final result = await apiService.markEmailValidationAsValidated(
          'token123',
        );
        expect(result, isFalse);
        verify(
          mockPostgrestService.markEmailValidationAsValidated('token123'),
        ).called(1);
      });

      test(
        'sendEmailValidationNotifications sends notifications successfully',
        () async {
          when(
            mockEmailService.sendEmailValidationNotifications(
              personId: anyNamed('personId'),
              email: anyNamed('email'),
              firstName: anyNamed('firstName'),
              lastName: anyNamed('lastName'),
              title: anyNamed('title'),
              emailType: anyNamed('emailType'),
              verificationToken: anyNamed('verificationToken'),
            ),
          ).thenAnswer((_) async {});

          await apiService.sendEmailValidationNotifications(
            personId: '123',
            email: 'test@example.com',
            firstName: 'John',
            lastName: 'Doe',
            title: 'Dr.',
            emailType: 'private',
            verificationToken: 'token123',
          );

          verify(
            mockEmailService.sendEmailValidationNotifications(
              personId: '123',
              email: 'test@example.com',
              firstName: 'John',
              lastName: 'Doe',
              title: 'Dr.',
              emailType: 'private',
              verificationToken: 'token123',
            ),
          ).called(1);
        },
      );
    });

    group('IBAN and BIC Validation', () {
      test('validateIBAN returns true for valid IBAN', () {
        expect(apiService.validateIBAN('DE89370400440532013000'), isTrue);
      });

      test('validateIBAN returns false for invalid IBAN', () {
        expect(apiService.validateIBAN('INVALID'), isFalse);
      });

      test('validateBIC returns null for valid BIC', () {
        expect(apiService.validateBIC('DEUTDEBBXXX'), isNull);
      });

      test('validateBIC returns error string for invalid BIC', () {
        expect(apiService.validateBIC('INVALID'), isNotNull);
      });
    });

    group('Email Service Tests', () {
      test('getFromEmail delegates to emailService', () async {
        when(
          mockEmailService.getFromEmail(),
        ).thenAnswer((_) async => 'test@example.com');
        final result = await apiService.getFromEmail();
        expect(result, 'test@example.com');
        verify(mockEmailService.getFromEmail()).called(1);
      });

      test('sendEmail delegates to emailService', () async {
        final expected = {'success': true};
        when(
          mockEmailService.sendEmail(
            sender: anyNamed('sender'),
            recipient: anyNamed('recipient'),
            subject: anyNamed('subject'),
            htmlBody: anyNamed('htmlBody'),
            emailId: anyNamed('emailId'),
          ),
        ).thenAnswer((_) async => expected);

        final result = await apiService.sendEmail(
          from: 'from@example.com',
          recipient: 'to@example.com',
          subject: 'Test',
          htmlBody: '<p>Test</p>',
          emailId: 1,
        );
        expect(result, expected);
      });

      test('sendSchulungAbmeldungEmail delegates to emailService', () async {
        when(
          mockEmailService.sendSchulungAbmeldungEmail(
            personId: anyNamed('personId'),
            schulungName: anyNamed('schulungName'),
            schulungDate: anyNamed('schulungDate'),
            firstName: anyNamed('firstName'),
            lastName: anyNamed('lastName'),
          ),
        ).thenAnswer((_) async {});

        await apiService.sendSchulungAbmeldungEmail(
          personId: '1',
          schulungName: 'Test',
          schulungDate: '2024-01-01',
          firstName: 'Max',
          lastName: 'Mustermann',
        );
        verify(
          mockEmailService.sendSchulungAbmeldungEmail(
            personId: '1',
            schulungName: 'Test',
            schulungDate: '2024-01-01',
            firstName: 'Max',
            lastName: 'Mustermann',
          ),
        ).called(1);
      });
    });

    group('BSSB App Passantrag', () {
      test(
        'bssbAppPassantrag delegates to userService and returns expected result',
        () async {
          const expectedResponse = true;
          final zves = <Map<String, dynamic>>[
            {'VEREINID': 1, 'DISZIPLINID': 42},
          ];
          const passdatenId = 2;
          const personId = 3;
          const erstVereinId = 4;
          const digitalerPass = 1;
          const antragsTyp = 2;

          when(
            mockUserService.bssbAppPassantrag(
              zves,
              passdatenId,
              personId,
              erstVereinId,
              digitalerPass,
              antragsTyp,
            ),
          ).thenAnswer((_) async => expectedResponse);

          final result = await apiService.bssbAppPassantrag(
            zves,
            passdatenId,
            personId,
            erstVereinId,
            digitalerPass,
            antragsTyp,
          );

          expect(result, equals(expectedResponse));
          verify(
            mockUserService.bssbAppPassantrag(
              zves,
              passdatenId,
              personId,
              erstVereinId,
              digitalerPass,
              antragsTyp,
            ),
          ).called(1);
        },
      );
    });

    group('Bank Service Tests', () {
      test(
        'fetchBankData delegates to bankService and returns expected data',
        () async {
          final expectedData = [
            const BankData(
              id: 1,
              webloginId: 123,
              kontoinhaber: 'Max Mustermann',
              iban: 'DE89370400440532013000',
              bic: 'DEUTDEBBXXX',
              mandatSeq: 1,
            ),
          ];
          when(
            mockBankService.fetchBankdatenMyBSSB(any),
          ).thenAnswer((_) async => expectedData);

          final result = await apiService.fetchBankdatenMyBSSB(123);
          expect(result, equals(expectedData));
          verify(mockBankService.fetchBankdatenMyBSSB(123)).called(1);
        },
      );

      test(
        'registerBankData delegates to bankService and returns true',
        () async {
          const bankData = BankData(
            id: 1,
            webloginId: 123,
            kontoinhaber: 'Max Mustermann',
            iban: 'DE89370400440532013000',
            bic: 'DEUTDEBBXXX',
            mandatSeq: 1,
          );
          when(
            mockBankService.registerBankData(any),
          ).thenAnswer((_) async => true);

          final result = await apiService.registerBankData(bankData);
          expect(result, isTrue);
          verify(mockBankService.registerBankData(bankData)).called(1);
        },
      );

      test(
        'deleteBankData delegates to bankService and returns true',
        () async {
          const bankData = BankData(
            id: 1,
            webloginId: 123,
            kontoinhaber: 'Max Mustermann',
            iban: 'DE89370400440532013000',
            bic: 'DEUTDEBBXXX',
            mandatSeq: 1,
          );
          when(
            mockBankService.deleteBankData(any),
          ).thenAnswer((_) async => true);

          final result = await apiService.deleteBankData(bankData);
          expect(result, isTrue);
          verify(mockBankService.deleteBankData(bankData)).called(1);
        },
      );
    });

    group('OktoberfestService Tests', () {
      test(
        'fetchResults delegates to oktoberfestService and returns expected data',
        () async {
          final expectedResults = [
            const Result(
              wettbewerb: 'Wettbewerb A',
              platz: 1,
              gesamt: 100,
              postfix: 'A',
            ),
          ];
          when(
            mockOktoberfestService.fetchResults(
              passnummer: anyNamed('passnummer'),
              configService: anyNamed('configService'),
            ),
          ).thenAnswer((_) async => expectedResults);

          final result = await apiService.fetchResults('123456');
          expect(result, equals(expectedResults));
          verify(
            mockOktoberfestService.fetchResults(
              passnummer: '123456',
              configService: mockConfigService,
            ),
          ).called(1);
        },
      );

      test(
        'fetchGewinne delegates to oktoberfestService and returns expected data',
        () async {
          final expectedGewinne = [
            const Gewinn(
              gewinnId: 1,
              jahr: 2024,
              isSachpreis: false,
              geldpreis: 50,
              sachpreis: 'Sachpreis A',
              wettbewerb: 'Wettbewerb A',
              abgerufenAm: '2024-09-24',
              platz: 1,
            ),
          ];
          when(
            mockOktoberfestService.fetchGewinne(
              jahr: anyNamed('jahr'),
              passnummer: anyNamed('passnummer'),
              configService: anyNamed('configService'),
            ),
          ).thenAnswer((_) async => expectedGewinne);

          final result = await apiService.fetchGewinne(2024, '123456');
          expect(result, equals(expectedGewinne));
          verify(
            mockOktoberfestService.fetchGewinne(
              jahr: 2024,
              passnummer: '123456',
              configService: mockConfigService,
            ),
          ).called(1);
        },
      );
    });

    group('bed_auswahl_typ Service Tests', () {
      test('createBedAuswahlTyp delegates to postgrest service', () async {
        final expectedResult = BeduerfnisseAuswahlTyp(
          id: 1,
          kuerzel: 'WA',
          beschreibung: 'Waffenart',
        );
        when(
          mockPostgrestService.createBedAuswahlTyp(
            kuerzel: anyNamed('kuerzel'),
            beschreibung: anyNamed('beschreibung'),
          ),
        ).thenAnswer((_) async => expectedResult);

        final result = await apiService.createBedAuswahlTyp(
          kuerzel: 'WA',
          beschreibung: 'Waffenart',
        );

        expect(result, equals(expectedResult));
        verify(
          mockPostgrestService.createBedAuswahlTyp(
            kuerzel: 'WA',
            beschreibung: 'Waffenart',
          ),
        ).called(1);
      });

      test('getBedAuswahlTypen delegates to postgrest service', () async {
        final expectedList = [
          BeduerfnisseAuswahlTyp(
            id: 1,
            kuerzel: 'WA',
            beschreibung: 'Waffenart',
          ),
          BeduerfnisseAuswahlTyp(
            id: 2,
            kuerzel: 'DI',
            beschreibung: 'Disziplin',
          ),
        ];
        when(
          mockPostgrestService.getBedAuswahlTypen(),
        ).thenAnswer((_) async => expectedList);

        final result = await apiService.getBedAuswahlTypen();
        expect(result, equals(expectedList));
        verify(mockPostgrestService.getBedAuswahlTypen()).called(1);
      });

      test('getBedAuswahlTypById delegates to postgrest service', () async {
        final expectedType = BeduerfnisseAuswahlTyp(
          id: 1,
          kuerzel: 'WA',
          beschreibung: 'Waffenart',
        );
        when(
          mockPostgrestService.getBedAuswahlTypById(1),
        ).thenAnswer((_) async => expectedType);

        final result = await apiService.getBedAuswahlTypById(1);
        expect(result, equals(expectedType));
        verify(mockPostgrestService.getBedAuswahlTypById(1)).called(1);
      });

      test('updateBedAuswahlTyp delegates to postgrest service', () async {
        when(
          mockPostgrestService.updateBedAuswahlTyp(1, {
            'beschreibung': 'Weapon Type',
          }),
        ).thenAnswer((_) async => true);

        final result = await apiService.updateBedAuswahlTyp(1, {
          'beschreibung': 'Weapon Type',
        });
        expect(result, isTrue);
        verify(
          mockPostgrestService.updateBedAuswahlTyp(1, {
            'beschreibung': 'Weapon Type',
          }),
        ).called(1);
      });

      test('deleteBedAuswahlTyp delegates to postgrest service', () async {
        when(
          mockPostgrestService.deleteBedAuswahlTyp(1),
        ).thenAnswer((_) async => true);

        final result = await apiService.deleteBedAuswahlTyp(1);
        expect(result, isTrue);
        verify(mockPostgrestService.deleteBedAuswahlTyp(1)).called(1);
      });
    });

    group('bed_auswahl Service Tests', () {
      test('createBedAuswahl delegates to postgrest service', () async {
        final expectedResult = BeduerfnisseAuswahl(
          id: 1,
          typId: 1,
          kuerzel: 'PIS',
          beschreibung: 'Pistole',
        );
        when(
          mockPostgrestService.createBedAuswahl(
            typId: anyNamed('typId'),
            kuerzel: anyNamed('kuerzel'),
            beschreibung: anyNamed('beschreibung'),
          ),
        ).thenAnswer((_) async => expectedResult);

        final result = await apiService.createBedAuswahl(
          typId: 1,
          kuerzel: 'PIS',
          beschreibung: 'Pistole',
        );

        expect(result, equals(expectedResult));
        verify(
          mockPostgrestService.createBedAuswahl(
            typId: 1,
            kuerzel: 'PIS',
            beschreibung: 'Pistole',
          ),
        ).called(1);
      });

      test('getBedAuswahlList delegates to postgrest service', () async {
        final expectedList = [
          BeduerfnisseAuswahl(
            id: 1,
            typId: 1,
            kuerzel: 'PIS',
            beschreibung: 'Pistole',
          ),
          BeduerfnisseAuswahl(
            id: 2,
            typId: 1,
            kuerzel: 'REV',
            beschreibung: 'Revolver',
          ),
        ];
        when(
          mockPostgrestService.getBedAuswahlList(),
        ).thenAnswer((_) async => expectedList);

        final result = await apiService.getBedAuswahlList();
        expect(result, equals(expectedList));
        verify(mockPostgrestService.getBedAuswahlList()).called(1);
      });

      test('getBedAuswahlByTypId delegates to postgrest service', () async {
        final expectedList = [
          BeduerfnisseAuswahl(
            id: 1,
            typId: 1,
            kuerzel: 'PIS',
            beschreibung: 'Pistole',
          ),
        ];
        when(
          mockPostgrestService.getBedAuswahlByTypId(1),
        ).thenAnswer((_) async => expectedList);

        final result = await apiService.getBedAuswahlByTypId(1);
        expect(result, equals(expectedList));
        verify(mockPostgrestService.getBedAuswahlByTypId(1)).called(1);
      });

      test('getBedAuswahlById delegates to postgrest service', () async {
        final expectedItem = BeduerfnisseAuswahl(
          id: 1,
          typId: 1,
          kuerzel: 'PIS',
          beschreibung: 'Pistole',
        );
        when(
          mockPostgrestService.getBedAuswahlById(1),
        ).thenAnswer((_) async => expectedItem);

        final result = await apiService.getBedAuswahlById(1);
        expect(result, equals(expectedItem));
        verify(mockPostgrestService.getBedAuswahlById(1)).called(1);
      });

      test('updateBedAuswahl delegates to postgrest service', () async {
        when(
          mockPostgrestService.updateBedAuswahl(1, {'beschreibung': 'Handgun'}),
        ).thenAnswer((_) async => true);

        final result = await apiService.updateBedAuswahl(1, {
          'beschreibung': 'Handgun',
        });
        expect(result, isTrue);
        verify(
          mockPostgrestService.updateBedAuswahl(1, {'beschreibung': 'Handgun'}),
        ).called(1);
      });

      test('deleteBedAuswahl delegates to postgrest service', () async {
        when(
          mockPostgrestService.deleteBedAuswahl(1),
        ).thenAnswer((_) async => true);

        final result = await apiService.deleteBedAuswahl(1);
        expect(result, isTrue);
        verify(mockPostgrestService.deleteBedAuswahl(1)).called(1);
      });
    });

    group('bed_datei Service Tests', () {
      test('createBedDatei delegates to postgrest service', () async {
        final fileBytes = [1, 2, 3, 4, 5];
        final expectedResult = {
          'id': 1,
          'antragsnummer': 'A123',
          'dateiname': 'doc.pdf',
        };
        when(
          mockPostgrestService.createBedDatei(
            antragsnummer: anyNamed('antragsnummer'),
            dateiname: anyNamed('dateiname'),
            fileBytes: anyNamed('fileBytes'),
          ),
        ).thenAnswer((_) async => expectedResult);

        final result = await apiService.createBedDatei(
          antragsnummer: 'A123',
          dateiname: 'doc.pdf',
          fileBytes: fileBytes,
        );

        expect(result, equals(expectedResult));
        verify(
          mockPostgrestService.createBedDatei(
            antragsnummer: 'A123',
            dateiname: 'doc.pdf',
            fileBytes: fileBytes,
          ),
        ).called(1);
      });

      test(
        'getBedDateiByAntragsnummer delegates to postgrest service',
        () async {
          final expectedList = [
            {'id': 1, 'antragsnummer': 'A123', 'dateiname': 'doc1.pdf'},
            {'id': 2, 'antragsnummer': 'A123', 'dateiname': 'doc2.pdf'},
          ];
          when(
            mockPostgrestService.getBedDateiByAntragsnummer('A123'),
          ).thenAnswer((_) async => expectedList);

          final result = await apiService.getBedDateiByAntragsnummer('A123');
          expect(result, equals(expectedList));
          verify(
            mockPostgrestService.getBedDateiByAntragsnummer('A123'),
          ).called(1);
        },
      );

      test('getBedDateiById delegates to postgrest service', () async {
        final expectedFile = {
          'id': 1,
          'antragsnummer': 'A123',
          'dateiname': 'doc.pdf',
        };
        when(
          mockPostgrestService.getBedDateiById(1),
        ).thenAnswer((_) async => expectedFile);

        final result = await apiService.getBedDateiById(1);
        expect(result, equals(expectedFile));
        verify(mockPostgrestService.getBedDateiById(1)).called(1);
      });

      test('updateBedDatei delegates to postgrest service', () async {
        when(
          mockPostgrestService.updateBedDatei(1, {'dateiname': 'new.pdf'}),
        ).thenAnswer((_) async => true);

        final result = await apiService.updateBedDatei(1, {
          'dateiname': 'new.pdf',
        });
        expect(result, isTrue);
        verify(
          mockPostgrestService.updateBedDatei(1, {'dateiname': 'new.pdf'}),
        ).called(1);
      });

      test('deleteBedDatei delegates to postgrest service', () async {
        when(
          mockPostgrestService.deleteBedDatei(1),
        ).thenAnswer((_) async => true);

        final result = await apiService.deleteBedDatei(1);
        expect(result, isTrue);
        verify(mockPostgrestService.deleteBedDatei(1)).called(1);
      });
    });

    group('bed_sport Service Tests', () {
      test('createBedSport delegates to postgrest service', () async {
        final expectedResult = {
          'id': 1,
          'antragsnummer': 'A123',
          'schiessdatum': '2024-01-01',
          'waffenart_id': 1,
          'disziplin_id': 2,
          'training': true,
        };
        when(
          mockPostgrestService.createBedSport(
            antragsnummer: anyNamed('antragsnummer'),
            schiessdatum: anyNamed('schiessdatum'),
            waffenartId: anyNamed('waffenartId'),
            disziplinId: anyNamed('disziplinId'),
            training: anyNamed('training'),
            wettkampfartId: anyNamed('wettkampfartId'),
            wettkampfergebnis: anyNamed('wettkampfergebnis'),
          ),
        ).thenAnswer((_) async => expectedResult);

        final result = await apiService.createBedSport(
          antragsnummer: 'A123',
          schiessdatum: '2024-01-01',
          waffenartId: 1,
          disziplinId: 2,
          training: true,
        );

        expect(result, equals(expectedResult));
        verify(
          mockPostgrestService.createBedSport(
            antragsnummer: 'A123',
            schiessdatum: '2024-01-01',
            waffenartId: 1,
            disziplinId: 2,
            training: true,
            wettkampfartId: null,
            wettkampfergebnis: null,
          ),
        ).called(1);
      });

      test(
        'createBedSport with optional parameters delegates to postgrest service',
        () async {
          final expectedResult = {
            'id': 1,
            'antragsnummer': 'A123',
            'wettkampfart_id': 5,
            'wettkampfergebnis': 95.5,
          };
          when(
            mockPostgrestService.createBedSport(
              antragsnummer: anyNamed('antragsnummer'),
              schiessdatum: anyNamed('schiessdatum'),
              waffenartId: anyNamed('waffenartId'),
              disziplinId: anyNamed('disziplinId'),
              training: anyNamed('training'),
              wettkampfartId: anyNamed('wettkampfartId'),
              wettkampfergebnis: anyNamed('wettkampfergebnis'),
            ),
          ).thenAnswer((_) async => expectedResult);

          final result = await apiService.createBedSport(
            antragsnummer: 'A123',
            schiessdatum: '2024-01-01',
            waffenartId: 1,
            disziplinId: 2,
            training: false,
            wettkampfartId: 5,
            wettkampfergebnis: 95.5,
          );

          expect(result, equals(expectedResult));
          verify(
            mockPostgrestService.createBedSport(
              antragsnummer: 'A123',
              schiessdatum: '2024-01-01',
              waffenartId: 1,
              disziplinId: 2,
              training: false,
              wettkampfartId: 5,
              wettkampfergebnis: 95.5,
            ),
          ).called(1);
        },
      );

      test(
        'getBedSportByAntragsnummer delegates to postgrest service',
        () async {
          final expectedList = [
            {'id': 1, 'antragsnummer': 'A123', 'training': true},
            {'id': 2, 'antragsnummer': 'A123', 'training': false},
          ];
          when(
            mockPostgrestService.getBedSportByAntragsnummer('A123'),
          ).thenAnswer((_) async => expectedList);

          final result = await apiService.getBedSportByAntragsnummer('A123');
          expect(result, equals(expectedList));
          verify(
            mockPostgrestService.getBedSportByAntragsnummer('A123'),
          ).called(1);
        },
      );

      test('getBedSportById delegates to postgrest service', () async {
        final expectedRecord = {
          'id': 1,
          'antragsnummer': 'A123',
          'training': true,
        };
        when(
          mockPostgrestService.getBedSportById(1),
        ).thenAnswer((_) async => expectedRecord);

        final result = await apiService.getBedSportById(1);
        expect(result, equals(expectedRecord));
        verify(mockPostgrestService.getBedSportById(1)).called(1);
      });

      test('updateBedSport delegates to postgrest service', () async {
        when(
          mockPostgrestService.updateBedSport(1, {'training': false}),
        ).thenAnswer((_) async => true);

        final result = await apiService.updateBedSport(1, {'training': false});
        expect(result, isTrue);
        verify(
          mockPostgrestService.updateBedSport(1, {'training': false}),
        ).called(1);
      });

      test('deleteBedSport delegates to postgrest service', () async {
        when(
          mockPostgrestService.deleteBedSport(1),
        ).thenAnswer((_) async => true);

        final result = await apiService.deleteBedSport(1);
        expect(result, isTrue);
        verify(mockPostgrestService.deleteBedSport(1)).called(1);
      });
    });

    group('bed_waffe_besitz Service Tests', () {
      test('createBedWaffeBesitz delegates to postgrest service', () async {
        final expectedResult = {
          'id': 1,
          'antragsnummer': 'A123',
          'wbk_nr': 'WBK001',
          'lfd_wbk': '001',
          'waffenart_id': 1,
          'kaliber_id': 2,
          'kompensator': false,
        };
        when(
          mockPostgrestService.createBedWaffeBesitz(
            antragsnummer: anyNamed('antragsnummer'),
            wbkNr: anyNamed('wbkNr'),
            lfdWbk: anyNamed('lfdWbk'),
            waffenartId: anyNamed('waffenartId'),
            hersteller: anyNamed('hersteller'),
            kaliberId: anyNamed('kaliberId'),
            lauflaengeId: anyNamed('lauflaengeId'),
            gewicht: anyNamed('gewicht'),
            kompensator: anyNamed('kompensator'),
            beduerfnisgrundId: anyNamed('beduerfnisgrundId'),
            verbandId: anyNamed('verbandId'),
            bemerkung: anyNamed('bemerkung'),
          ),
        ).thenAnswer((_) async => expectedResult);

        final result = await apiService.createBedWaffeBesitz(
          antragsnummer: 'A123',
          wbkNr: 'WBK001',
          lfdWbk: '001',
          waffenartId: 1,
          kaliberId: 2,
          kompensator: false,
        );

        expect(result, equals(expectedResult));
        verify(
          mockPostgrestService.createBedWaffeBesitz(
            antragsnummer: 'A123',
            wbkNr: 'WBK001',
            lfdWbk: '001',
            waffenartId: 1,
            hersteller: null,
            kaliberId: 2,
            lauflaengeId: null,
            gewicht: null,
            kompensator: false,
            beduerfnisgrundId: null,
            verbandId: null,
            bemerkung: null,
          ),
        ).called(1);
      });

      test(
        'createBedWaffeBesitz with optional parameters delegates to postgrest service',
        () async {
          final expectedResult = {
            'id': 1,
            'antragsnummer': 'A123',
            'hersteller': 'TestManufacturer',
            'gewicht': '1.5kg',
            'bemerkung': 'Test note',
          };
          when(
            mockPostgrestService.createBedWaffeBesitz(
              antragsnummer: anyNamed('antragsnummer'),
              wbkNr: anyNamed('wbkNr'),
              lfdWbk: anyNamed('lfdWbk'),
              waffenartId: anyNamed('waffenartId'),
              hersteller: anyNamed('hersteller'),
              kaliberId: anyNamed('kaliberId'),
              lauflaengeId: anyNamed('lauflaengeId'),
              gewicht: anyNamed('gewicht'),
              kompensator: anyNamed('kompensator'),
              beduerfnisgrundId: anyNamed('beduerfnisgrundId'),
              verbandId: anyNamed('verbandId'),
              bemerkung: anyNamed('bemerkung'),
            ),
          ).thenAnswer((_) async => expectedResult);

          final result = await apiService.createBedWaffeBesitz(
            antragsnummer: 'A123',
            wbkNr: 'WBK001',
            lfdWbk: '001',
            waffenartId: 1,
            hersteller: 'TestManufacturer',
            kaliberId: 2,
            gewicht: '1.5kg',
            kompensator: false,
            bemerkung: 'Test note',
          );

          expect(result, equals(expectedResult));
          verify(
            mockPostgrestService.createBedWaffeBesitz(
              antragsnummer: 'A123',
              wbkNr: 'WBK001',
              lfdWbk: '001',
              waffenartId: 1,
              hersteller: 'TestManufacturer',
              kaliberId: 2,
              lauflaengeId: null,
              gewicht: '1.5kg',
              kompensator: false,
              beduerfnisgrundId: null,
              verbandId: null,
              bemerkung: 'Test note',
            ),
          ).called(1);
        },
      );

      test(
        'getBedWaffeBesitzByAntragsnummer delegates to postgrest service',
        () async {
          final expectedList = [
            {'id': 1, 'antragsnummer': 'A123', 'wbk_nr': 'WBK001'},
            {'id': 2, 'antragsnummer': 'A123', 'wbk_nr': 'WBK002'},
          ];
          when(
            mockPostgrestService.getBedWaffeBesitzByAntragsnummer('A123'),
          ).thenAnswer((_) async => expectedList);

          final result = await apiService.getBedWaffeBesitzByAntragsnummer(
            'A123',
          );
          expect(result, equals(expectedList));
          verify(
            mockPostgrestService.getBedWaffeBesitzByAntragsnummer('A123'),
          ).called(1);
        },
      );

      test('getBedWaffeBesitzById delegates to postgrest service', () async {
        final expectedWeapon = {
          'id': 1,
          'antragsnummer': 'A123',
          'wbk_nr': 'WBK001',
        };
        when(
          mockPostgrestService.getBedWaffeBesitzById(1),
        ).thenAnswer((_) async => expectedWeapon);

        final result = await apiService.getBedWaffeBesitzById(1);
        expect(result, equals(expectedWeapon));
        verify(mockPostgrestService.getBedWaffeBesitzById(1)).called(1);
      });

      test('updateBedWaffeBesitz delegates to postgrest service', () async {
        when(
          mockPostgrestService.updateBedWaffeBesitz(1, {'kompensator': true}),
        ).thenAnswer((_) async => true);

        final result = await apiService.updateBedWaffeBesitz(1, {
          'kompensator': true,
        });
        expect(result, isTrue);
        verify(
          mockPostgrestService.updateBedWaffeBesitz(1, {'kompensator': true}),
        ).called(1);
      });

      test('deleteBedWaffeBesitz delegates to postgrest service', () async {
        when(
          mockPostgrestService.deleteBedWaffeBesitz(1),
        ).thenAnswer((_) async => true);

        final result = await apiService.deleteBedWaffeBesitz(1);
        expect(result, isTrue);
        verify(mockPostgrestService.deleteBedWaffeBesitz(1)).called(1);
      });
    });

    group('bed_antrag_status Service Tests', () {
      test('createBedAntragStatus delegates to postgrest service', () async {
        final expectedResult = BeduerfnisseAntragStatus(
          id: 1,
          status: 'offen',
          beschreibung: 'Antrag eingegangen',
        );
        when(
          mockPostgrestService.createBedAntragStatus(
            status: anyNamed('status'),
            beschreibung: anyNamed('beschreibung'),
          ),
        ).thenAnswer((_) async => expectedResult);

        final result = await apiService.createBedAntragStatus(
          status: 'offen',
          beschreibung: 'Antrag eingegangen',
        );

        expect(result, equals(expectedResult));
        verify(
          mockPostgrestService.createBedAntragStatus(
            status: 'offen',
            beschreibung: 'Antrag eingegangen',
          ),
        ).called(1);
      });

      test('getBedAntragStatusList delegates to postgrest service', () async {
        final expectedList = [
          BeduerfnisseAntragStatus(
            id: 1,
            status: 'offen',
            beschreibung: 'Antrag eingegangen',
          ),
          BeduerfnisseAntragStatus(
            id: 2,
            status: 'bearbeitung',
            beschreibung: 'In Bearbeitung',
          ),
        ];
        when(
          mockPostgrestService.getBedAntragStatusList(),
        ).thenAnswer((_) async => expectedList);

        final result = await apiService.getBedAntragStatusList();
        expect(result, equals(expectedList));
        verify(mockPostgrestService.getBedAntragStatusList()).called(1);
      });

      test('getBedAntragStatusById delegates to postgrest service', () async {
        final expectedStatus = BeduerfnisseAntragStatus(
          id: 1,
          status: 'offen',
          beschreibung: 'Antrag eingegangen',
        );
        when(
          mockPostgrestService.getBedAntragStatusById(1),
        ).thenAnswer((_) async => expectedStatus);

        final result = await apiService.getBedAntragStatusById(1);
        expect(result, equals(expectedStatus));
        verify(mockPostgrestService.getBedAntragStatusById(1)).called(1);
      });

      test(
        'getBedAntragStatusByStatus delegates to postgrest service',
        () async {
          final expectedStatus = BeduerfnisseAntragStatus(
            id: 1,
            status: 'offen',
            beschreibung: 'Antrag eingegangen',
          );
          when(
            mockPostgrestService.getBedAntragStatusByStatus('offen'),
          ).thenAnswer((_) async => expectedStatus);

          final result = await apiService.getBedAntragStatusByStatus('offen');
          expect(result, equals(expectedStatus));
          verify(
            mockPostgrestService.getBedAntragStatusByStatus('offen'),
          ).called(1);
        },
      );

      test('updateBedAntragStatus delegates to postgrest service', () async {
        when(
          mockPostgrestService.updateBedAntragStatus(1, {
            'beschreibung': 'Updated',
          }),
        ).thenAnswer((_) async => true);

        final result = await apiService.updateBedAntragStatus(1, {
          'beschreibung': 'Updated',
        });
        expect(result, isTrue);
        verify(
          mockPostgrestService.updateBedAntragStatus(1, {
            'beschreibung': 'Updated',
          }),
        ).called(1);
      });

      test('deleteBedAntragStatus delegates to postgrest service', () async {
        when(
          mockPostgrestService.deleteBedAntragStatus(1),
        ).thenAnswer((_) async => true);

        final result = await apiService.deleteBedAntragStatus(1);
        expect(result, isTrue);
        verify(mockPostgrestService.deleteBedAntragStatus(1)).called(1);
      });
    });

    group('bed_antrag Service Tests', () {
      test('createBedAntrag delegates to postgrest service', () async {
        const testUserData = UserData(
          personId: 100,
          webLoginId: 123,
          passnummer: '12345678',
          vereinNr: 401051,
          namen: 'Testuser',
          vorname: 'Test',
          vereinName: 'Test Club',
          passdatenId: 1,
          mitgliedschaftId: 100,
          email: 'test@example.com',
        );

        final expectedResult = BeduerfnisseAntrag(
          id: 1,
          antragsnummer: 'A123',
          personId: 100,
          statusId: BeduerfnisAntragStatus.entwurf,
        );
        when(
          mockPostgrestService.createBedAntrag(
            antragsnummer: anyNamed('antragsnummer'),
            personId: anyNamed('personId'),
            statusId: anyNamed('statusId'),
            wbkNeu: anyNamed('wbkNeu'),
            wbkArt: anyNamed('wbkArt'),
            beduerfnisart: anyNamed('beduerfnisart'),
            anzahlWaffen: anyNamed('anzahlWaffen'),
            vereinGenehmigt: anyNamed('vereinGenehmigt'),
            email: anyNamed('email'),
            bankdaten: anyNamed('bankdaten'),
            abbuchungErfolgt: anyNamed('abbuchungErfolgt'),
            bemerkung: anyNamed('bemerkung'),
          ),
        ).thenAnswer((_) async => expectedResult);

        final result = await apiService.createBedAntrag(
          antragsnummer: 'A123',
          personId: 100,
          statusId: BeduerfnisAntragStatus.entwurf,
          email: 'test.antrag@example.com',
        );

        expect(result, equals(expectedResult));
        verify(
          mockPostgrestService.createBedAntrag(
            antragsnummer: 'A123',
            personId: 100,
            statusId: BeduerfnisAntragStatus.entwurf,
            wbkNeu: null,
            wbkArt: null,
            beduerfnisart: null,
            anzahlWaffen: null,
            vereinGenehmigt: null,
            email: 'test.antrag@example.com',
            bankdaten: null,
            abbuchungErfolgt: null,
            bemerkung: null,
          ),
        ).called(1);
      });

      test('getBedAntragList delegates to postgrest service', () async {
        final expectedList = [
          BeduerfnisseAntrag(id: 1, antragsnummer: 'A123', personId: 100),
          BeduerfnisseAntrag(id: 2, antragsnummer: 'A124', personId: 101),
        ];
        when(
          mockPostgrestService.getBedAntragList(),
        ).thenAnswer((_) async => expectedList);

        final result = await apiService.getBedAntragList();
        expect(result, equals(expectedList));
        verify(mockPostgrestService.getBedAntragList()).called(1);
      });

      test(
        'getBedAntragByAntragsnummer delegates to postgrest service',
        () async {
          final expectedList = [
            BeduerfnisseAntrag(id: 1, antragsnummer: 'A123', personId: 100),
          ];
          when(
            mockPostgrestService.getBedAntragByAntragsnummer('A123'),
          ).thenAnswer((_) async => expectedList);

          final result = await apiService.getBedAntragByAntragsnummer('A123');
          expect(result, equals(expectedList));
          verify(
            mockPostgrestService.getBedAntragByAntragsnummer('A123'),
          ).called(1);
        },
      );

      test('getBedAntragByPersonId delegates to postgrest service', () async {
        final expectedList = [
          BeduerfnisseAntrag(id: 1, antragsnummer: 'A123', personId: 100),
        ];
        when(
          mockPostgrestService.getBedAntragByPersonId(100),
        ).thenAnswer((_) async => expectedList);

        final result = await apiService.getBedAntragByPersonId(100);
        expect(result, equals(expectedList));
        verify(mockPostgrestService.getBedAntragByPersonId(100)).called(1);
      });

      test('getBedAntragByStatusId delegates to postgrest service', () async {
        final expectedList = [
          BeduerfnisseAntrag(
            id: 1,
            antragsnummer: 'A123',
            personId: 100,
            statusId: BeduerfnisAntragStatus.entwurf,
          ),
        ];
        when(
          mockPostgrestService.getBedAntragByStatusId(1),
        ).thenAnswer((_) async => expectedList);

        final result = await apiService.getBedAntragByStatusId(1);
        expect(result, equals(expectedList));
        verify(mockPostgrestService.getBedAntragByStatusId(1)).called(1);
      });

      test('getBedAntragById delegates to postgrest service', () async {
        final expectedAntrag = BeduerfnisseAntrag(
          id: 1,
          antragsnummer: 'A123',
          personId: 100,
        );
        when(
          mockPostgrestService.getBedAntragById(1),
        ).thenAnswer((_) async => expectedAntrag);

        final result = await apiService.getBedAntragById(1);
        expect(result, equals(expectedAntrag));
        verify(mockPostgrestService.getBedAntragById(1)).called(1);
      });

      test('updateBedAntrag delegates to postgrest service', () async {
        when(
          mockPostgrestService.updateBedAntrag(1, {'verein_genehmigt': true}),
        ).thenAnswer((_) async => true);

        final result = await apiService.updateBedAntrag(1, {
          'verein_genehmigt': true,
        });
        expect(result, isTrue);
        verify(
          mockPostgrestService.updateBedAntrag(1, {'verein_genehmigt': true}),
        ).called(1);
      });

      test('deleteBedAntrag delegates to postgrest service', () async {
        when(
          mockPostgrestService.deleteBedAntrag(1),
        ).thenAnswer((_) async => true);

        final result = await apiService.deleteBedAntrag(1);
        expect(result, isTrue);
        verify(mockPostgrestService.deleteBedAntrag(1)).called(1);
      });
    });
  });
}
