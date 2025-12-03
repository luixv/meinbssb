import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/constants/messages.dart';
import 'package:http/http.dart' as http;
import 'package:meinbssb/services/core/config_service.dart';

import '../../helpers/test_mocks.mocks.dart';

void main() {
  late AuthService authService;
  late MockHttpClient mockHttpClient;
  late MockCacheService mockCacheService;
  late MockNetworkService mockNetworkService;
  late MockFlutterSecureStorage mockSecureStorage;
  late MockConfigService mockConfigService;
  late MockPostgrestService mockPostgrestService;
  late MockEmailService mockEmailService;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockCacheService = MockCacheService();
    mockNetworkService = MockNetworkService();
    mockConfigService = MockConfigService();
    mockPostgrestService = MockPostgrestService();
    mockEmailService = MockEmailService();
    mockSecureStorage = MockFlutterSecureStorage();

    authService = AuthService(
      httpClient: mockHttpClient,
      cacheService: mockCacheService,
      networkService: mockNetworkService,
      configService: mockConfigService,
      postgrestService: mockPostgrestService,
      emailService: mockEmailService,
      secureStorage: mockSecureStorage,
    );

    when(
      mockSecureStorage.read(key: anyNamed('key')),
    ).thenAnswer((_) async => '');
    when(
      mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')),
    ).thenAnswer((_) async => {});
    when(
      mockSecureStorage.delete(key: anyNamed('key')),
    ).thenAnswer((_) async => {});

    when(mockCacheService.setString(any, any)).thenAnswer((_) async => true);
    when(mockCacheService.setInt(any, any)).thenAnswer((_) async => true);
    when(mockCacheService.remove(any)).thenAnswer((_) async => true);
    when(
      mockCacheService.setCacheTimestampForKey(any),
    ).thenAnswer((_) async => true);
    when(mockCacheService.getString(any)).thenAnswer((_) async => '');
    when(mockCacheService.getInt(any)).thenAnswer((_) async => null);

    when(
      mockNetworkService.getCacheExpirationDuration(),
    ).thenReturn(const Duration(days: 1));

    when(
      mockCacheService.getCacheTimestampForKey(any),
    ).thenAnswer((_) async => DateTime.now().millisecondsSinceEpoch);
    when(mockHttpClient.get(any)).thenAnswer((_) async => {});
    when(
      mockHttpClient.post(
        any,
        any,
        overrideBaseUrl: anyNamed('overrideBaseUrl'),
      ),
    ).thenAnswer((_) async => {});

    when(mockConfigService.getString('apiProtocol', any)).thenReturn('https');
    when(
      mockConfigService.getString('api1BaseServer', any),
    ).thenReturn('webintern.bssb.bayern');
    when(mockConfigService.getString('api1BasePort', any)).thenReturn('56400');
    when(
      mockConfigService.getString('api1BasePath', any),
    ).thenReturn('rest/zmi/api1');
    when(
      mockConfigService.getString('webServer', any),
    ).thenReturn('meintest.bssb.de');
    when(mockConfigService.getString('webPort', any)).thenReturn('443');
    when(mockConfigService.getString('webPath', any)).thenReturn('');

    when(
      mockPostgrestService.getUserByPassNumber(any),
    ).thenAnswer((_) async => null);
    when(
      mockPostgrestService.createUser(
        firstName: anyNamed('firstName'),
        lastName: anyNamed('lastName'),
        email: anyNamed('email'),
        passNumber: anyNamed('passNumber'),
        verificationToken: anyNamed('verificationToken'),
        personId: anyNamed('personId'),
      ),
    ).thenAnswer((_) async => <String, dynamic>{});
    when(mockPostgrestService.verifyUser(any)).thenAnswer((_) async => true);

    when(
      mockEmailService.getFromEmail(),
    ).thenAnswer((_) async => 'noreply@bssb.bayern');
    when(
      mockEmailService.getRegistrationSubject(),
    ).thenAnswer((_) async => 'Registration');
    when(
      mockEmailService.getRegistrationContent(),
    ).thenAnswer((_) async => 'Registration content');
    when(
      mockEmailService.sendEmail(
        sender: anyNamed('sender'),
        recipient: anyNamed('recipient'),
        subject: anyNamed('subject'),
        htmlBody: anyNamed('htmlBody'),
      ),
    ).thenAnswer(
      (_) async => <String, dynamic>{
        'ResultType': 1,
        'ResultMessage': 'Email sent successfully',
      },
    );
    when(
      mockEmailService.sendAccountCreationNotifications(any, any),
    ).thenAnswer((_) async => <String, dynamic>{});
    when(
      mockEmailService.getEmailAddressesByPersonId(any),
    ).thenAnswer((_) async => ['john.doe@example.com']);
  });

  group('AuthService', () {
    group('register', () {
      test('should return registration data on success', () async {
        const firstName = 'John';
        const lastName = 'Doe';
        const passNumber = '12345';
        const email = 'john.doe@example.com';
        const personId = '439287';

        when(
          mockPostgrestService.getUserByPassNumber(passNumber),
        ).thenAnswer((_) async => null);

        when(
          mockPostgrestService.getUserByEmail(email),
        ).thenAnswer((_) async => null);

        when(
          mockPostgrestService.createUser(
            firstName: anyNamed('firstName'),
            lastName: anyNamed('lastName'),
            email: anyNamed('email'),
            passNumber: anyNamed('passNumber'),
            verificationToken: anyNamed('verificationToken'),
            personId: anyNamed('personId'),
          ),
        ).thenAnswer(
          (_) async => <String, dynamic>{
            'id': 1,
            'firstname': firstName,
            'lastname': lastName,
            'email': email,
            'pass_number': passNumber,
            'person_id': personId,
          },
        );

        final result = await authService.register(
          firstName: firstName,
          lastName: lastName,
          passNumber: passNumber,
          email: email,
          personId: personId,
        );

        expect(result['ResultType'], 1);

        verify(
          mockPostgrestService.createUser(
            firstName: firstName,
            lastName: lastName,
            email: email,
            passNumber: passNumber,
            verificationToken: anyNamed('verificationToken'),
            personId: personId,
          ),
        ).called(1);
      });

      test(
        'should handle registration failure when user creation fails',
        () async {
          const firstName = 'John';
          const lastName = 'Doe';
          const passNumber = '12345';
          const email = 'john.doe@example.com';
          const personId = '439287';

          when(
            mockPostgrestService.getUserByPassNumber(passNumber),
          ).thenAnswer((_) async => null);

          when(
            mockPostgrestService.getUserByEmail(email),
          ).thenAnswer((_) async => null);

          when(
            mockPostgrestService.createUser(
              firstName: anyNamed('firstName'),
              lastName: anyNamed('lastName'),
              email: anyNamed('email'),
              passNumber: anyNamed('passNumber'),
              verificationToken: anyNamed('verificationToken'),
              personId: anyNamed('personId'),
            ),
          ).thenThrow(Exception('Database error'));

          final result = await authService.register(
            firstName: firstName,
            lastName: lastName,
            passNumber: passNumber,
            email: email,
            personId: personId,
          );

          expect(result['ResultType'], 0);
          expect(result['ResultMessage'], Messages.registrationDataStoreFailed);
        },
      );

      test('should handle existing verified user', () async {
        const firstName = 'John';
        const lastName = 'Doe';
        const passNumber = '12345';
        const email = 'john.doe@example.com';
        const personId = '439287';

        when(mockPostgrestService.getUserByPassNumber(passNumber)).thenAnswer(
          (_) async => {
            'id': 1,
            'is_verified': true,
            'created_at': DateTime.now().toIso8601String(),
          },
        );

        when(
          mockPostgrestService.createUser(
            firstName: anyNamed('firstName'),
            lastName: anyNamed('lastName'),
            email: anyNamed('email'),
            passNumber: anyNamed('passNumber'),
            verificationToken: anyNamed('verificationToken'),
            personId: anyNamed('personId'),
          ),
        ).thenThrow(Exception('User already exists'));

        final result = await authService.register(
          firstName: firstName,
          lastName: lastName,
          passNumber: passNumber,
          email: email,
          personId: personId,
        );

        expect(result['ResultType'], 0);
        expect(result['ResultMessage'], Messages.registrationDataStoreFailed);
      });
    });

    group('login (online)', () {
      test(
        'should return success and cache data on successful login',
        () async {
          const email = 'test@example.com';
          const password = 'password123';
          final expectedResponse = {
            'ResultType': 1,
            'PersonID': 456,
            'WebLoginID': 789,
            'ResultMessage': 'Success',
          };

          when(
            mockHttpClient.post(
              'LoginMeinBSSBApp',
              any,
              overrideBaseUrl: anyNamed('overrideBaseUrl'),
            ),
          ).thenAnswer((_) async => expectedResponse);

          final result = await authService.login(email, password);

          expect(result, expectedResponse);
          verify(mockCacheService.setString('username', email)).called(1);
          verify(
            mockSecureStorage.write(key: 'password', value: password),
          ).called(1);
          verify(mockCacheService.setInt('personId', 456)).called(1);
          verify(mockCacheService.setInt('webLoginId', 789)).called(1);
          verify(
            mockCacheService.setCacheTimestampForKey('username'),
          ).called(1);
          verify(
            mockCacheService.setCacheTimestampForKey('personId'),
          ).called(1);
          verify(
            mockCacheService.setCacheTimestampForKey('webLoginId'),
          ).called(1);
          verify(
            mockHttpClient.post(
              'LoginMeinBSSBApp',
              any,
              overrideBaseUrl: anyNamed('overrideBaseUrl'),
            ),
          ).called(1);
        },
      );

      test('should return error on server login failure', () async {
        const email = 'test@example.com';
        const password = 'password123';
        final expectedResponse = {
          'ResultType': 0,
          'ResultMessage': 'Invalid credentials',
        };

        when(
          mockHttpClient.post(
            'LoginMeinBSSBApp',
            any,
            overrideBaseUrl: anyNamed('overrideBaseUrl'),
          ),
        ).thenAnswer((_) async => expectedResponse);

        final result = await authService.login(email, password);

        expect(result, expectedResponse);
        verify(
          mockHttpClient.post(
            'LoginMeinBSSBApp',
            any,
            overrideBaseUrl: anyNamed('overrideBaseUrl'),
          ),
        ).called(1);
        verifyNever(mockCacheService.setString(any, any));
        verifyNever(
          mockSecureStorage.write(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        );
      });

      test(
        'should handle http.ClientException and attempt offline login',
        () async {
          const email = 'test@example.com';
          const password = 'password123';
          const cachedPersonId = 123;
          const cachedWebloginId = 456;

          when(
            mockHttpClient.post(
              any,
              any,
              overrideBaseUrl: anyNamed('overrideBaseUrl'),
            ),
          ).thenThrow(
            http.ClientException('Network error during online login'),
          );

          when(
            mockCacheService.getString('username'),
          ).thenAnswer((_) async => email);
          when(
            mockSecureStorage.read(key: 'password'),
          ).thenAnswer((_) async => password);
          when(
            mockCacheService.getInt('personId'),
          ).thenAnswer((_) async => cachedPersonId);
          when(
            mockCacheService.getInt('webLoginId'),
          ).thenAnswer((_) async => cachedWebloginId);
          when(mockCacheService.getInt('cacheTimestamp')).thenAnswer(
            (_) async =>
                DateTime.now()
                    .subtract(const Duration(minutes: 5))
                    .millisecondsSinceEpoch,
          );
          when(
            mockNetworkService.getCacheExpirationDuration(),
          ).thenReturn(const Duration(days: 1));

          final result = await authService.login(email, password);

          expect(result, {
            'ResultType': 1,
            'PersonID': cachedPersonId,
            'WebLoginID': cachedWebloginId,
          });

          verify(
            mockHttpClient.post(
              any,
              any,
              overrideBaseUrl: anyNamed('overrideBaseUrl'),
            ),
          ).called(1);
          verify(mockCacheService.getString('username')).called(
            2,
          ); // Called once to check if cached data exists, once in offline login
          verify(mockSecureStorage.read(key: 'password')).called(1);
        },
      );

      test(
        'should return generic error message for other exceptions during online login',
        () async {
          const email = 'test@example.com';
          const password = 'password123';

          when(
            mockHttpClient.post(
              any,
              any,
              overrideBaseUrl: anyNamed('overrideBaseUrl'),
            ),
          ).thenThrow(Exception('Some other unexpected error'));

          final result = await authService.login(email, password);

          expect(result, {
            'ResultType': 0,
            'ResultMessage':
                'Anmeldung fehlgeschlagen: Exception: Some other unexpected error',
          });
          verify(
            mockHttpClient.post(
              any,
              any,
              overrideBaseUrl: anyNamed('overrideBaseUrl'),
            ),
          ).called(1);
          verifyNever(mockCacheService.getString(any));
        },
      );
    });
    group('login (offline)', () {
      const String testUsername = 'testuser';
      const String testPassword = 'testpassword';
      const int cachedPersonId = 123;
      const int cachedWebloginId = 456;

      setUp(() {
        when(
          mockHttpClient.post(
            any,
            any,
            overrideBaseUrl: anyNamed('overrideBaseUrl'),
          ),
        ).thenThrow(http.ClientException('Network error during online login'));

        when(
          mockCacheService.getString('username'),
        ).thenAnswer((_) async => testUsername);
        when(
          mockSecureStorage.read(key: 'password'),
        ).thenAnswer((_) async => testPassword);
        when(
          mockCacheService.getInt('personId'),
        ).thenAnswer((_) async => cachedPersonId);
        when(
          mockCacheService.getInt('webLoginId'),
        ).thenAnswer((_) async => cachedWebloginId);
        final now = DateTime.now().millisecondsSinceEpoch;
        when(
          mockCacheService.getCacheTimestampForKey('username'),
        ).thenAnswer((_) async => now);
        when(
          mockCacheService.getCacheTimestampForKey('personId'),
        ).thenAnswer((_) async => now);
        when(
          mockCacheService.getCacheTimestampForKey('webLoginId'),
        ).thenAnswer((_) async => now);
        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(days: 1));
      });

      test(
        'should successfully login from cache if data is valid and not expired',
        () async {
          final result = await authService.login(testUsername, testPassword);
          expect(result, {
            'ResultType': 1,
            'PersonID': cachedPersonId,
            'WebLoginID': cachedWebloginId,
          });
        },
      );

      test('should return failure if cached data is expired', () async {
        final expired =
            DateTime.now()
                .subtract(const Duration(days: 2))
                .millisecondsSinceEpoch;
        when(
          mockCacheService.getCacheTimestampForKey('username'),
        ).thenAnswer((_) async => expired);
        when(
          mockCacheService.getCacheTimestampForKey('personId'),
        ).thenAnswer((_) async => expired);
        when(
          mockCacheService.getCacheTimestampForKey('webLoginId'),
        ).thenAnswer((_) async => expired);
        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(days: 1));

        final result = await authService.login(testUsername, testPassword);

        expect(result, {
          'ResultType': 0,
          'ResultMessage':
              'Die Cache Daten sind abgelaufen. Bitte melden Sie sich erneut an.',
        });
      });

      test(
        'should return failure if cached username or password does not match',
        () async {
          when(
            mockCacheService.getString('username'),
          ).thenAnswer((_) async => 'wrong_user');
          final now = DateTime.now().millisecondsSinceEpoch;
          when(
            mockCacheService.getCacheTimestampForKey('username'),
          ).thenAnswer((_) async => now);
          when(
            mockCacheService.getCacheTimestampForKey('personId'),
          ).thenAnswer((_) async => now);
          when(
            mockCacheService.getCacheTimestampForKey('webLoginId'),
          ).thenAnswer((_) async => now);

          final result = await authService.login(testUsername, testPassword);

          expect(result, {
            'ResultType': 0,
            'ResultMessage':
                'Offline-Anmeldung fehlgeschlagen: Kein Cache oder falsches Passwort.',
          });
        },
      );

      test('should return failure if no cached data is available', () async {
        // Simulate http.ClientException (network error)
        when(
          mockHttpClient.post(
            any,
            any,
            overrideBaseUrl: anyNamed('overrideBaseUrl'),
          ),
        ).thenThrow(http.ClientException('Network error during online login'));

        // No cached data available
        when(
          mockCacheService.getString('username'),
        ).thenAnswer((_) async => null);
        when(
          mockSecureStorage.read(key: anyNamed('key')),
        ).thenAnswer((_) async => null);
        when(mockCacheService.getInt(any)).thenAnswer((_) async => null);
        when(
          mockCacheService.getCacheTimestampForKey(any),
        ).thenAnswer((_) async => null);

        final result = await authService.login(testUsername, testPassword);

        expect(result, {
          'ResultType': 0,
          'ResultMessage':
              'Netzwerkfehler: Network error during online login. Bitte überprüfen Sie Ihre Internetverbindung.',
        });
      });
    });

    group('Change password', () {
      test('should return response data on success', () async {
        const personId = 123;
        const newPassword = 'newSecret123';
        final expectedResponse = {
          'ResultType': 1,
          'Message': 'Password changed successfully',
        };
        final requestBody = {'PersonID': personId, 'PasswortNeu': newPassword};
        when(
          mockHttpClient.put('MyBSSBPasswortAendern', requestBody),
        ).thenAnswer((_) async => expectedResponse);

        final result = await authService.myBSSBPasswortAendern(
          personId,
          newPassword,
        );

        expect(result, expectedResponse);
        verify(
          mockHttpClient.put('MyBSSBPasswortAendern', requestBody),
        ).called(1);
      });

      test('should return error response on server failure', () async {
        const personId = 123;
        const newPassword = 'newSecret123';
        final expectedResponse = {
          'ResultType': 0,
          'Message': 'Password change failed',
        };
        final requestBody = {'PersonID': personId, 'PasswortNeu': newPassword};
        when(
          mockHttpClient.put('MyBSSBPasswortAendern', requestBody),
        ).thenAnswer((_) async => expectedResponse);

        final result = await authService.myBSSBPasswortAendern(
          personId,
          newPassword,
        );

        expect(result, expectedResponse);
        verify(
          mockHttpClient.put('MyBSSBPasswortAendern', requestBody),
        ).called(1);
      });

      test('should handle unexpected server response format', () async {
        const personId = 123;
        const newPassword = 'newSecret123';
        final requestBody = {'PersonID': personId, 'PasswortNeu': newPassword};
        when(
          mockHttpClient.put('MyBSSBPasswortAendern', requestBody),
        ).thenAnswer((_) async => 'Invalid response format');

        final result = await authService.myBSSBPasswortAendern(
          personId,
          newPassword,
        );

        expect(result, {});
        verify(
          mockHttpClient.put('MyBSSBPasswortAendern', requestBody),
        ).called(1);
      });
    });

    group('FindePersonID2', () {
      setUp(() {
        when(
          mockConfigService.getString('apiProtocol', any),
        ).thenReturn('https');
        when(
          mockConfigService.getString('api1BaseServer', any),
        ).thenReturn('webintern.bssb.bayern');
        when(
          mockConfigService.getString('api1BasePort', any),
        ).thenReturn('56400');
        when(
          mockConfigService.getString('api1BasePath', any),
        ).thenReturn('rest/zmi/api1');
      });

      test('returns PERSONID if person is found', () async {
        when(
          mockHttpClient.get('FindePersonID2/John/40101205'),
        ).thenAnswer(
          (_) async => [
            {
              'NAMEN': 'Doe',
              'VORNAME': 'John',
              'PERSONID': 439287,
              'TITEL': '',
              'GESCHLECHT': true,
              'STRASSE': 'Test Street',
              'PLZ': '12345',
              'ORT': 'Test City',
            },
          ],
        );
        final result = await authService.findePersonID2('John', '40101205');
        expect(result, 439287);
      });

      test('returns 0 if list is empty', () async {
        when(
          mockHttpClient.get('FindePersonID2/NoName/00000000'),
        ).thenAnswer((_) async => []);
        final result = await authService.findePersonID2('NoName', '00000000');
        expect(result, 0);
      });

      test('returns 0 if PERSONID is null', () async {
        when(
          mockHttpClient.get('FindePersonID2/John/40101205'),
        ).thenAnswer(
          (_) async => [
            {
              'NAMEN': 'Doe',
              'VORNAME': 'John',
              'PERSONID': null,
            },
          ],
        );
        final result = await authService.findePersonID2('John', '40101205');
        expect(result, 0);
      });

      test('returns 0 if PERSONID is 0', () async {
        when(
          mockHttpClient.get('FindePersonID2/John/40101205'),
        ).thenAnswer(
          (_) async => [
            {
              'NAMEN': 'Doe',
              'VORNAME': 'John',
              'PERSONID': 0,
            },
          ],
        );
        final result = await authService.findePersonID2('John', '40101205');
        expect(result, 0);
      });

      test('returns 0 if response is not a List', () async {
        when(
          mockHttpClient.get('FindePersonID2/John/40101205'),
        ).thenAnswer((_) async => {'PERSONID': 439287});
        final result = await authService.findePersonID2('John', '40101205');
        expect(result, 0);
      });

      test('returns 0 if person is not a Map', () async {
        when(
          mockHttpClient.get('FindePersonID2/John/40101205'),
        ).thenAnswer((_) async => ['invalid']);
        final result = await authService.findePersonID2('John', '40101205');
        expect(result, 0);
      });

      test('returns 0 on exception', () async {
        when(
          mockHttpClient.get('FindePersonID2/Error/99999999'),
        ).thenThrow(Exception('fail'));
        final result = await authService.findePersonID2('Error', '99999999');
        expect(result, 0);
      });

      test('handles empty strings correctly', () async {
        when(
          mockHttpClient.get('FindePersonID2//'),
        ).thenAnswer((_) async => []);
        final result = await authService.findePersonID2('', '');
        expect(result, 0);
      });
    });

    group('findePersonIDSimple', () {
      setUp(() {
        when(
          mockConfigService.getString('apiProtocol', any),
        ).thenReturn('https');
        when(
          mockConfigService.getString('api1BaseServer', any),
        ).thenReturn('webintern.bssb.bayern');
        when(
          mockConfigService.getString('api1BasePort', any),
        ).thenReturn('56400');
        when(
          mockConfigService.getString('api1BasePath', any),
        ).thenReturn('rest/zmi/api1');
      });

      test('returns PERSONID if person is found', () async {
        final expectedBaseUrl = ConfigService.buildBaseUrlForServer(
          mockConfigService,
          name: 'api1Base',
        );
        when(
          mockHttpClient.get(
            'FindePersonID/Mustermann/Max/40101205',
            overrideBaseUrl: expectedBaseUrl,
          ),
        ).thenAnswer(
          (_) async => [
            {
              'NAMEN': 'Mustermann',
              'VORNAME': 'Max',
              'PERSONID': 439287,
              'TITEL': '',
              'GESCHLECHT': true,
              'STRASSE': 'Test Street',
              'PLZ': '12345',
              'ORT': 'Test City',
            },
          ],
        );
        final result = await authService.findePersonIDSimple('Max', 'Mustermann', '40101205');
        expect(result, 439287);
      });

      test('returns 0 if list is empty', () async {
        final expectedBaseUrl = ConfigService.buildBaseUrlForServer(
          mockConfigService,
          name: 'api1Base',
        );
        when(
          mockHttpClient.get(
            'FindePersonID/NoName/NoFirst/00000000',
            overrideBaseUrl: expectedBaseUrl,
          ),
        ).thenAnswer((_) async => []);
        final result = await authService.findePersonIDSimple('NoFirst', 'NoName', '00000000');
        expect(result, 0);
      });

      test('returns 0 if PERSONID is null', () async {
        final expectedBaseUrl = ConfigService.buildBaseUrlForServer(
          mockConfigService,
          name: 'api1Base',
        );
        when(
          mockHttpClient.get(
            'FindePersonID/Mustermann/Max/40101205',
            overrideBaseUrl: expectedBaseUrl,
          ),
        ).thenAnswer(
          (_) async => [
            {
              'NAMEN': 'Mustermann',
              'VORNAME': 'Max',
              'PERSONID': null,
            },
          ],
        );
        final result = await authService.findePersonIDSimple('Max', 'Mustermann', '40101205');
        expect(result, 0);
      });

      test('returns 0 if PERSONID is 0', () async {
        final expectedBaseUrl = ConfigService.buildBaseUrlForServer(
          mockConfigService,
          name: 'api1Base',
        );
        when(
          mockHttpClient.get(
            'FindePersonID/Mustermann/Max/40101205',
            overrideBaseUrl: expectedBaseUrl,
          ),
        ).thenAnswer(
          (_) async => [
            {
              'NAMEN': 'Mustermann',
              'VORNAME': 'Max',
              'PERSONID': 0,
            },
          ],
        );
        final result = await authService.findePersonIDSimple('Max', 'Mustermann', '40101205');
        expect(result, 0);
      });

      test('returns 0 if response is not a List', () async {
        final expectedBaseUrl = ConfigService.buildBaseUrlForServer(
          mockConfigService,
          name: 'api1Base',
        );
        when(
          mockHttpClient.get(
            'FindePersonID/Mustermann/Max/40101205',
            overrideBaseUrl: expectedBaseUrl,
          ),
        ).thenAnswer((_) async => {'PERSONID': 439287});
        final result = await authService.findePersonIDSimple('Max', 'Mustermann', '40101205');
        expect(result, 0);
      });

      test('returns 0 if person is not a Map', () async {
        final expectedBaseUrl = ConfigService.buildBaseUrlForServer(
          mockConfigService,
          name: 'api1Base',
        );
        when(
          mockHttpClient.get(
            'FindePersonID/Mustermann/Max/40101205',
            overrideBaseUrl: expectedBaseUrl,
          ),
        ).thenAnswer((_) async => ['invalid']);
        final result = await authService.findePersonIDSimple('Max', 'Mustermann', '40101205');
        expect(result, 0);
      });

      test('returns 0 on exception', () async {
        final expectedBaseUrl = ConfigService.buildBaseUrlForServer(
          mockConfigService,
          name: 'api1Base',
        );
        when(
          mockHttpClient.get(
            'FindePersonID/Error/Error/99999999',
            overrideBaseUrl: expectedBaseUrl,
          ),
        ).thenThrow(Exception('fail'));
        final result = await authService.findePersonIDSimple('Error', 'Error', '99999999');
        expect(result, 0);
      });

      test('handles empty strings correctly', () async {
        final expectedBaseUrl = ConfigService.buildBaseUrlForServer(
          mockConfigService,
          name: 'api1Base',
        );
        when(
          mockHttpClient.get(
            'FindePersonID///',
            overrideBaseUrl: expectedBaseUrl,
          ),
        ).thenAnswer((_) async => []);
        final result = await authService.findePersonIDSimple('', '', '');
        expect(result, 0);
      });
    });

    group('fetchLoginEmail', () {
      setUp(() async {
        TestWidgetsFlutterBinding.ensureInitialized();
        when(
          mockConfigService.getString('apiProtocol', any),
        ).thenReturn('https');
        when(
          mockConfigService.getString('api1BaseServer', any),
        ).thenReturn('webintern.bssb.bayern');
        when(
          mockConfigService.getString('api1BasePort', any),
        ).thenReturn('56400');
        when(
          mockConfigService.getString('api1BasePath', any),
        ).thenReturn('rest/zmi/api1');
      });

      test('returns LOGINMAIL when present in response', () async {
        const passnummer = '40101205';
        const expectedEmail = '';
        final expectedBaseUrl = ConfigService.buildBaseUrlForServer(
          mockConfigService,
          name: 'api1Base',
        );
        when(
          mockHttpClient.get(
            'LoginEmail/$passnummer',
            overrideBaseUrl: expectedBaseUrl,
          ),
        ).thenAnswer(
          (_) async => [
            {'LOGINMAIL': expectedEmail},
          ],
        );

        final result = await authService.fetchLoginEmail(passnummer);
        expect(result, expectedEmail);
      });

      test('returns empty string when response is empty', () async {
        const passnummer = '40101205';
        final expectedBaseUrl = ConfigService.buildBaseUrlForServer(
          mockConfigService,
          name: 'api1Base',
        );
        when(
          mockHttpClient.get(
            'FindeLoginMail/$passnummer',
            overrideBaseUrl: expectedBaseUrl,
          ),
        ).thenAnswer((_) async => []);

        final result = await authService.fetchLoginEmail(passnummer);
        expect(result, '');
      });

      test('returns empty string when LOGINMAIL is missing', () async {
        const passnummer = '40101205';
        final expectedBaseUrl = ConfigService.buildBaseUrlForServer(
          mockConfigService,
          name: 'api1Base',
        );
        when(
          mockHttpClient.get(
            'FindeLoginMail/$passnummer',
            overrideBaseUrl: expectedBaseUrl,
          ),
        ).thenAnswer((_) async => [{}]);

        final result = await authService.fetchLoginEmail(passnummer);
        expect(result, '');
      });
    });

    test('generateVerificationToken returns a 44-char base64 string', () {
      final token = authService.generateVerificationToken();
      expect(token, isA<String>());
      expect(token.length, 44);
    });

    group('finalizeRegistration', () {
      test('should verify user and send notification on success', () async {
        when(mockHttpClient.post(any, any)).thenAnswer(
          (_) async => [
            {'RESULTTYPE': 1},
          ],
        );
        when(
          mockPostgrestService.verifyUser(any),
        ).thenAnswer((_) async => true);
        when(
          mockEmailService.sendAccountCreationNotifications(any, any),
        ).thenAnswer((_) async => true);

        final result = await authService.finalizeRegistration(
          email: 'a@b.de',
          password: 'pw',
          token: 'tok',
          personId: '1',
          passNumber: '123',
        );
        expect(result, isA<List>());
        verify(mockPostgrestService.verifyUser('tok')).called(1);
        verify(
          mockEmailService.sendAccountCreationNotifications('1', 'a@b.de'),
        ).called(1);
      });

      test('should return error map on exception', () async {
        when(mockHttpClient.post(any, any)).thenThrow(Exception('fail'));
        final result = await authService.finalizeRegistration(
          email: 'a@b.de',
          password: 'pw',
          token: 'tok',
          personId: '1',
          passNumber: '123',
        );
        expect(result['ResultType'], 0);
        expect(result['ResultMessage'], Messages.accountCreationFailed);
      });
    });

    group('logout', () {
      test('should log info on logout', () async {
        await authService.logout();
      });
    });

    group('getPersonIDByPassnummer', () {
      test('returns personId as string if found', () async {
        when(
          mockHttpClient.get(any, overrideBaseUrl: anyNamed('overrideBaseUrl')),
        ).thenAnswer(
          (_) async => [
            {'PERSONID': 42},
          ],
        );
        final result = await authService.getPersonIDByPassnummer('123');
        expect(result, '42');
      });

      test('returns "0" if not found', () async {
        when(
          mockHttpClient.get(any, overrideBaseUrl: anyNamed('overrideBaseUrl')),
        ).thenAnswer((_) async => []);
        final result = await authService.getPersonIDByPassnummer('123');
        expect(result, '0');
      });

      test('returns "0" on error', () async {
        reset(mockHttpClient);
        final expectedBaseUrl = ConfigService.buildBaseUrlForServer(
          mockConfigService,
          name: 'api1Base',
        );
        when(
          mockHttpClient.get('PersonID/123', overrideBaseUrl: expectedBaseUrl),
        ).thenThrow(Exception('fail'));
        final result = await authService.getPersonIDByPassnummer('123');
        expect(result, '0');
      });
    });

    group('getPassDatenByPersonId', () {
      test('returns first map if found', () async {
        reset(mockHttpClient);
        // Add these lines to fix the MissingStubError:
        when(
          mockConfigService.getString('apiBaseServer', null),
        ).thenReturn('webintern.bssb.bayern');
        when(
          mockConfigService.getString('apiBasePort', null),
        ).thenReturn('56400');
        when(
          mockConfigService.getString('apiBasePath', null),
        ).thenReturn('rest/zmi/api1');

        when(
          mockHttpClient.get(any, overrideBaseUrl: anyNamed('overrideBaseUrl')),
        ).thenAnswer(
          (_) async => [
            {'foo': 'bar'},
          ],
        );
        final result = await authService.getPassDatenByPersonId('1');
        expect(result, {'foo': 'bar'});
      });

      test('returns empty map if not found', () async {
        reset(mockHttpClient);
        when(
          mockConfigService.getString('apiBaseServer', null),
        ).thenReturn('webintern.bssb.bayern');
        when(
          mockConfigService.getString('apiBasePort', null),
        ).thenReturn('56400');
        when(
          mockConfigService.getString('apiBasePath', null),
        ).thenReturn('rest/zmi/api1');

        when(
          mockHttpClient.get(any, overrideBaseUrl: anyNamed('overrideBaseUrl')),
        ).thenAnswer((_) async => []);
        final result = await authService.getPassDatenByPersonId('1');
        expect(result, {});
      });

      test('returns empty map on error', () async {
        reset(mockHttpClient);
        when(
          mockConfigService.getString('apiBaseServer', null),
        ).thenReturn('webintern.bssb.bayern');
        when(
          mockConfigService.getString('apiBasePort', null),
        ).thenReturn('56400');
        when(
          mockConfigService.getString('apiBasePath', null),
        ).thenReturn('rest/zmi/api1');

        when(
          mockHttpClient.get(any, overrideBaseUrl: anyNamed('overrideBaseUrl')),
        ).thenThrow(Exception('fail'));
        final result = await authService.getPassDatenByPersonId('1');
        expect(result, {});
      });
    });

    group('findePersonID', () {
      test('returns personId as string if found', () async {
        reset(mockHttpClient);
        when(
          mockConfigService.getString('apiBaseServer', null),
        ).thenReturn('webintern.bssb.bayern');
        when(
          mockConfigService.getString('apiBasePort', null),
        ).thenReturn('56400');
        when(
          mockConfigService.getString('apiBasePath', null),
        ).thenReturn('rest/zmi/api1');

        when(
          mockHttpClient.get(any, overrideBaseUrl: anyNamed('overrideBaseUrl')),
        ).thenAnswer(
          (_) async => [
            {'PERSONID': 99},
          ],
        );
        final result = await authService.findePersonID(
          'Doe',
          'John',
          '1990-01-01',
          '123',
          '10001',
        );
        expect(result, '99');
      });

      test('returns "0" if not found', () async {
        reset(mockHttpClient);
        when(
          mockConfigService.getString('apiBaseServer', null),
        ).thenReturn('webintern.bssb.bayern');
        when(
          mockConfigService.getString('apiBasePort', null),
        ).thenReturn('56400');
        when(
          mockConfigService.getString('apiBasePath', null),
        ).thenReturn('rest/zmi/api1');

        when(
          mockHttpClient.get(any, overrideBaseUrl: anyNamed('overrideBaseUrl')),
        ).thenAnswer((_) async => []);
        final result = await authService.findePersonID(
          'Doe',
          'John',
          '1990-01-01',
          '123',
          '10001',
        );
        expect(result, '0');
      });

      test('returns "0" on error', () async {
        reset(mockHttpClient);
        when(
          mockConfigService.getString('apiBaseServer', null),
        ).thenReturn('webintern.bssb.bayern');
        when(
          mockConfigService.getString('apiBasePort', null),
        ).thenReturn('56400');
        when(
          mockConfigService.getString('apiBasePath', null),
        ).thenReturn('rest/zmi/api1');

        when(
          mockHttpClient.get(any, overrideBaseUrl: anyNamed('overrideBaseUrl')),
        ).thenThrow(Exception('fail'));
        final result = await authService.findePersonID(
          'Doe',
          'John',
          '1990-01-01',
          '123',
          '10001',
        );
        expect(result, '0');
      });

      test('handles invalid birthDate gracefully', () async {
        reset(mockHttpClient);
        when(
          mockConfigService.getString('apiBaseServer', null),
        ).thenReturn('webintern.bssb.bayern');
        when(
          mockConfigService.getString('apiBasePort', null),
        ).thenReturn('56400');
        when(
          mockConfigService.getString('apiBasePath', null),
        ).thenReturn('rest/zmi/api1');

        when(
          mockHttpClient.get(any, overrideBaseUrl: anyNamed('overrideBaseUrl')),
        ).thenAnswer(
          (_) async => [
            {'PERSONID': 88},
          ],
        );
        final result = await authService.findePersonID(
          'Doe',
          'John',
          'notadate',
          '123',
          '10001',
        );
        expect(result, '88');
      });
    });

    group('resetPasswordStep1', () {
      test('returns success if email and reset entry created', () async {
        reset(mockHttpClient);
        when(
          mockConfigService.getString('apiBaseServer', null),
        ).thenReturn('webintern.bssb.bayern');
        when(
          mockConfigService.getString('apiBasePort', null),
        ).thenReturn('56400');
        when(
          mockConfigService.getString('apiBasePath', null),
        ).thenReturn('rest/zmi/api1');

        when(
          mockHttpClient.get(any, overrideBaseUrl: anyNamed('overrideBaseUrl')),
        ).thenAnswer(
          (_) async => [
            {'PERSONID': 1},
          ],
        );
        // Mock dependencies for getPassDatenByPersonId
        when(
          mockHttpClient.get(any, overrideBaseUrl: anyNamed('overrideBaseUrl')),
        ).thenAnswer(
          (_) async => [
            {'foo': 'bar'},
          ],
        );
        when(
          mockEmailService.getEmailAddressesByPersonId(any),
        ).thenAnswer((_) async => ['a@b.de']);
        when(
          mockPostgrestService.getLatestPasswordResetForPerson(any),
        ).thenAnswer((_) async => null);
        when(
          mockEmailService.sendPasswordResetNotifications(any, any, any),
        ).thenAnswer((_) async => true);
        when(
          mockPostgrestService.createPasswordResetEntry(
            personId: anyNamed('personId'),
            verificationToken: anyNamed('verificationToken'),
          ),
        ).thenAnswer((_) async => true);

        final result = await authService.resetPasswordStep1('123');
        expect(result['ResultType'], 1);
      });

      test('returns error if no email found', () async {
        when(mockCacheService.getString(any)).thenAnswer((_) async => '');
        when(
          mockSecureStorage.read(key: anyNamed('key')),
        ).thenAnswer((_) async => '');
        when(
          mockHttpClient.get(any, overrideBaseUrl: anyNamed('overrideBaseUrl')),
        ).thenAnswer(
          (_) async => [
            {'PERSONID': 1},
          ],
        );
        when(
          mockEmailService.getEmailAddressesByPersonId(any),
        ).thenAnswer((_) async => []);
        final result = await authService.resetPasswordStep1('123');
        expect(result['ResultType'], 99);
      });

      test('returns error if reset requested within 24h', () async {
        // Mock getPersonIDByPassnummer
        when(
          mockHttpClient.get(any, overrideBaseUrl: anyNamed('overrideBaseUrl')),
        ).thenAnswer(
          (_) async => [
            {'PERSONID': 1},
          ],
        );
        // Mock getPassDatenByPersonId
        when(
          mockHttpClient.get(any, overrideBaseUrl: anyNamed('overrideBaseUrl')),
        ).thenAnswer(
          (_) async => [
            {'foo': 'bar'},
          ],
        );
        when(
          mockEmailService.getEmailAddressesByPersonId(any),
        ).thenAnswer((_) async => ['a@b.de']);
        when(
          mockPostgrestService.getLatestPasswordResetForPerson(any),
        ).thenAnswer(
          (_) async => {'created_at': DateTime.now().toIso8601String()},
        );

        final result = await authService.resetPasswordStep1('123');
        expect(result['ResultType'], 98);
      });

      test('returns error on exception', () async {
        when(
          mockHttpClient.get(any, overrideBaseUrl: anyNamed('overrideBaseUrl')),
        ).thenThrow(Exception('fail'));
        final result = await authService.resetPasswordStep1('123');
        expect(result['ResultType'], 97);
      });
    });

    group('resetPasswordStep2', () {
      test('returns success if server responds with result true', () async {
        when(
          mockHttpClient.put(any, any),
        ).thenAnswer((_) async => {'result': true});
        when(
          mockPostgrestService.markPasswordResetEntryUsed(
            verificationToken: anyNamed('verificationToken'),
          ),
        ).thenAnswer((_) async => true);
        final result = await authService.resetPasswordStep2('token', '1', 'pw');
        expect(result['success'], true);
      });

      test('returns error if server responds with result false', () async {
        when(
          mockHttpClient.put(any, any),
        ).thenAnswer((_) async => {'result': false});
        final result = await authService.resetPasswordStep2('token', '1', 'pw');
        expect(result['success'], false);
      });

      test('returns error if server responds with unexpected format', () async {
        when(mockHttpClient.put(any, any)).thenAnswer((_) async => {});
        final result = await authService.resetPasswordStep2('token', '1', 'pw');
        expect(result['success'], false);
      });

      test('returns error on exception', () async {
        when(mockHttpClient.put(any, any)).thenThrow(Exception('fail'));
        final result = await authService.resetPasswordStep2('token', '1', 'pw');
        expect(result['success'], false);
      });
    });
  });
}
