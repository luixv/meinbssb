import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/services/core/postgrest_service.dart';
import 'package:meinbssb/services/core/email_service.dart';

import '../../helpers/test_mocks.mocks.dart';

// Add this fallback mock if the generated one is missing
class MockPostgrestService extends Mock implements PostgrestService {}

// Ensure the mock is generated for FlutterSecureStorage
@GenerateMocks([
  HttpClient,
  CacheService,
  NetworkService,
  FlutterSecureStorage,
  ConfigService,
  EmailService,
])
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
    // Initialize all mocks before each test
    mockHttpClient = MockHttpClient();
    mockCacheService = MockCacheService();
    mockNetworkService = MockNetworkService();
    mockConfigService = MockConfigService();
    mockPostgrestService = MockPostgrestService();
    mockEmailService = MockEmailService();

    // Create AuthService instance for each test, injecting all mocks
    authService = AuthService(
      httpClient: mockHttpClient,
      cacheService: mockCacheService,
      networkService: mockNetworkService,
      configService: mockConfigService,
      secureStorage: mockSecureStorage,
      postgrestService: mockPostgrestService,
      emailService: mockEmailService,
    );

    when(mockSecureStorage.read(key: anyNamed('key')))
        .thenAnswer((_) async => null);
    when(
      mockSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      ),
    ).thenAnswer((_) async => {});
    when(mockSecureStorage.delete(key: anyNamed('key')))
        .thenAnswer((_) async => {});

    // --- Global Stubs for CacheService methods ---
    // These ensure common cache operations don't throw MissingStubError
    when(mockCacheService.setString(any, any)).thenAnswer((_) async => true);
    when(mockCacheService.setInt(any, any)).thenAnswer((_) async => true);
    when(mockCacheService.remove(any)).thenAnswer((_) async => true);
    when(mockCacheService.setCacheTimestampForKey('username'))
        .thenAnswer((_) async => true);
    when(mockCacheService.setCacheTimestampForKey('personId'))
        .thenAnswer((_) async => true);
    when(mockCacheService.setCacheTimestampForKey('webLoginId'))
        .thenAnswer((_) async => true);
    when(mockCacheService.getString(any)).thenAnswer((_) async => null);
    when(mockCacheService.getInt(any)).thenAnswer((_) async => null);

    // Default for NetworkService.getCacheExpirationDuration (can be overridden by specific tests)
    when(mockNetworkService.getCacheExpirationDuration())
        .thenReturn(const Duration(days: 1)); // Default to non-expired

    when(mockCacheService.getCacheTimestampForKey('username'))
        .thenAnswer((_) async => DateTime.now().millisecondsSinceEpoch);
    when(mockCacheService.getCacheTimestampForKey('personId'))
        .thenAnswer((_) async => DateTime.now().millisecondsSinceEpoch);
    when(mockCacheService.getCacheTimestampForKey('webLoginId'))
        .thenAnswer((_) async => DateTime.now().millisecondsSinceEpoch);
    when(mockHttpClient.get(any)).thenAnswer((_) async => {});
    when(
      mockHttpClient.post(
        any,
        any,
        overrideBaseUrl: anyNamed('overrideBaseUrl'),
      ),
    ).thenAnswer((_) async => {});

    when(mockConfigService.getString('apiProtocol', any)).thenReturn('https');
    when(mockConfigService.getString('api1BaseServer', any))
        .thenReturn('webintern.bssb.bayern');
    when(mockConfigService.getString('api1BasePort', any)).thenReturn('56400');
    when(mockConfigService.getString('api1BasePath', any))
        .thenReturn('rest/zmi/api1');

    // Default behavior for PostgrestService
    when(mockPostgrestService.getUserByPassNumber(any))
        .thenAnswer((_) async => null);
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

    // Default behavior for EmailService
    when(mockEmailService.sendAccountCreationNotifications(any, any))
        .thenAnswer((_) async => <String, dynamic>{});
  });

  group('AuthService', () {
    group('register', () {
      test('should return registration data on success', () async {
        const firstName = 'John';
        const lastName = 'Doe';
        const passNumber = '12345';
        const email = 'john.doe@example.com';
        const birthDate = '1990-01-01';
        const zipCode = '10001';
        const expectedPersonId = '123';
        const personId = '439287';

        when(
          mockHttpClient.get(
            'FindePersonID/$lastName/$firstName/$birthDate/$passNumber/$zipCode',
          ),
        ).thenAnswer((_) async => {'PERSONID': int.parse(expectedPersonId)});

        when(mockHttpClient.get('FindeMailadressen/$expectedPersonId'))
            .thenAnswer(
          (_) async => [
            {'LOGINMAIL': email, 'MAILADRESSEN': 'another@example.com'},
          ],
        );

        final registrationBody = {
          'PersonId': expectedPersonId,
          'Email': email,
          'Passwort': '',
        };
        final expectedResponse = {'ResultType': 1, 'PersonID': 123};
        when(mockHttpClient.post('RegisterMyBSSB', registrationBody))
            .thenAnswer((_) async => expectedResponse);

        final result = await authService.register(
          firstName: firstName,
          lastName: lastName,
          passNumber: passNumber,
          email: email,
          birthDate: birthDate,
          zipCode: zipCode,
          personId: personId,
        );

        expect(result, expectedResponse);
        verify(
          mockHttpClient.get(
            'FindePersonID/$lastName/$firstName/$birthDate/$passNumber/$zipCode',
          ),
        ).called(1);
        verify(mockHttpClient.get('FindeMailadressen/$expectedPersonId'))
            .called(1);
        verify(mockHttpClient.post('RegisterMyBSSB', registrationBody))
            .called(1);
      });

      test('should rethrow error on registration failure from person ID lookup',
          () async {
        const firstName = 'John';
        const lastName = 'Doe';
        const passNumber = '12345';
        const email = 'john.doe@example.com';
        const birthDate = '1990-01-01';
        const zipCode = '10001';
        const personId = '439287';

        when(mockHttpClient.get(any))
            .thenThrow(http.ClientException('Failed to find person ID'));

        expect(
          () => authService.register(
            firstName: firstName,
            lastName: lastName,
            passNumber: passNumber,
            email: email,
            birthDate: birthDate,
            zipCode: zipCode,
            personId: personId,
          ),
          throwsA(isA<http.ClientException>()),
        );
        verify(
          mockHttpClient.get(
            'FindePersonID/$lastName/$firstName/$birthDate/$passNumber/$zipCode',
          ),
        ).called(1);
        verifyNever(mockHttpClient.get('FindeMailadressen/any'));
        verifyNever(mockHttpClient.post(any, any));
      });

      test(
          'should call post and return failure if email address check logic leads to it',
          () async {
        const firstName = 'John';
        const lastName = 'Doe';
        const passNumber = '12345';
        const email = 'john.doe@example.com';
        const birthDate = '1990-01-01';
        const zipCode = '10001';
        const expectedPersonId = '123';
        const personId = '439287';

        when(
          mockHttpClient.get(
            'FindePersonID/$lastName/$firstName/$birthDate/$passNumber/$zipCode',
          ),
        ).thenAnswer((_) async => {'PERSONID': int.parse(expectedPersonId)});

        // Simulate _findeMailadressen returning an email that doesn't match the input email
        // With the current AuthService logic, this will still lead to the post call.
        when(mockHttpClient.get('FindeMailadressen/$expectedPersonId'))
            .thenAnswer(
          (_) async => [
            {
              'LOGINMAIL': 'different@example.com',
              'MAILADRESSEN': 'another@example.com',
            }
          ],
        );

        // Stub the final registration POST call to return a failure,
        // as the email check inside AuthService is flawed and won't prevent the POST.
        final registrationBody = {
          'PersonId': expectedPersonId,
          'Email': email,
          'Passwort': '',
        };
        final expectedFailureResponse = {
          'ResultType': 0,
          'ResultMessage': 'Email mismatch or invalid',
        };
        when(mockHttpClient.post('RegisterMyBSSB', registrationBody))
            .thenAnswer((_) async => expectedFailureResponse);

        final result = await authService.register(
          firstName: firstName,
          lastName: lastName,
          passNumber: passNumber,
          email: email,
          birthDate: birthDate,
          zipCode: zipCode,
          personId: personId,
        );

        expect(result, expectedFailureResponse); // Expect failure from post
        verify(
          mockHttpClient.get(
            'FindePersonID/$lastName/$firstName/$birthDate/$passNumber/$zipCode',
          ),
        ).called(1);
        verify(mockHttpClient.get('FindeMailadressen/$expectedPersonId'))
            .called(1);
        verify(mockHttpClient.post('RegisterMyBSSB', registrationBody))
            .called(1); // Post is called
      });
    });

    group('login (online)', () {
      test('should return success and cache data on successful login',
          () async {
        const email = 'test@example.com';
        const password = 'password123';
        final expectedResponse = {
          'ResultType': 1,
          'PersonID': 456,
          'WebLoginID': 789,
          'ResultMessage': 'Success',
        };

        // Stub the successful online login - AuthService uses POST, not GET
        when(
          mockHttpClient.post(
            'LoginMyBSSB',
            any,
            overrideBaseUrl: anyNamed('overrideBaseUrl'),
          ),
        ).thenAnswer((_) async => expectedResponse);

        final result = await authService.login(email, password);

        expect(result, expectedResponse);
        verify(mockCacheService.setString('username', email)).called(1);
        verify(mockSecureStorage.write(key: 'password', value: password))
            .called(1);
        verify(mockCacheService.setInt('personId', 456)).called(1);
        verify(mockCacheService.setInt('webLoginId', 789)).called(1);
        verify(mockCacheService.setCacheTimestampForKey('username')).called(1);
        verify(mockCacheService.setCacheTimestampForKey('personId')).called(1);
        verify(mockCacheService.setCacheTimestampForKey('webLoginId'))
            .called(1);
        verify(
          mockHttpClient.post(
            'LoginMyBSSB',
            any,
            overrideBaseUrl: anyNamed('overrideBaseUrl'),
          ),
        ).called(1);
      });

      test('should return error on server login failure', () async {
        const email = 'test@example.com';
        const password = 'password123';
        final expectedResponse = {
          'ResultType': 0,
          'ResultMessage': 'Invalid credentials',
        };

        // AuthService uses POST, not GET
        when(
          mockHttpClient.post(
            'LoginMyBSSB',
            any,
            overrideBaseUrl: anyNamed('overrideBaseUrl'),
          ),
        ).thenAnswer((_) async => expectedResponse);

        final result = await authService.login(email, password);

        expect(result, expectedResponse);
        verify(
          mockHttpClient.post(
            'LoginMyBSSB',
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

      test('should handle http.ClientException and attempt offline login',
          () async {
        const email = 'test@example.com';
        const password = 'password123';
        const cachedPersonId = 123;
        const cachedWebloginId = 456;

        // Simulate network error for online login - AuthService uses POST
        when(
          mockHttpClient.post(
            any,
            any,
            overrideBaseUrl: anyNamed('overrideBaseUrl'),
          ),
        ).thenThrow(
          http.ClientException('Network error during online login'),
        );

        // Stub offline cache data for successful offline login
        when(mockCacheService.getString('username'))
            .thenAnswer((_) async => email);
        when(mockSecureStorage.read(key: 'password'))
            .thenAnswer((_) async => password);
        when(mockCacheService.getInt('personId'))
            .thenAnswer((_) async => cachedPersonId);
        when(mockCacheService.getInt('webLoginId'))
            .thenAnswer((_) async => cachedWebloginId);
        when(mockCacheService.getInt('cacheTimestamp')).thenAnswer(
          (_) async => DateTime.now()
              .subtract(const Duration(minutes: 5))
              .millisecondsSinceEpoch,
        );
        when(mockNetworkService.getCacheExpirationDuration())
            .thenReturn(const Duration(days: 1)); // Cache not expired

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
        verify(mockCacheService.getString('username')).called(1);
        verify(mockSecureStorage.read(key: 'password')).called(1);
      });

      test(
          'should return generic error message for other exceptions during online login',
          () async {
        const email = 'test@example.com';
        const password = 'password123';

        // AuthService uses POST, not GET
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
          'ResultMessage': 'Benutzername oder Passwort ist falsch',
        });
        verify(
          mockHttpClient.post(
            any,
            any,
            overrideBaseUrl: anyNamed('overrideBaseUrl'),
          ),
        ).called(1);
        verifyNever(mockCacheService.getString(any));
      });
    });
    group('login (offline)', () {
      const String testUsername = 'testuser';
      const String testPassword = 'testpassword';
      const int cachedPersonId = 123;
      const int cachedWebloginId = 456;

      setUp(() {
        // Ensure online login attempt throws ClientException to trigger offline flow
        when(
          mockHttpClient.post(
            any,
            any,
            overrideBaseUrl: anyNamed('overrideBaseUrl'),
          ),
        ).thenThrow(
          http.ClientException('Network error during online login'),
        );

        // Stub offline cache data for successful offline login
        when(mockCacheService.getString('username'))
            .thenAnswer((_) async => testUsername);
        when(mockSecureStorage.read(key: 'password'))
            .thenAnswer((_) async => testPassword);
        when(mockCacheService.getInt('personId'))
            .thenAnswer((_) async => cachedPersonId);
        when(mockCacheService.getInt('webLoginId'))
            .thenAnswer((_) async => cachedWebloginId);
        // Per-key timestamp stubs for valid login
        final now = DateTime.now().millisecondsSinceEpoch;
        when(mockCacheService.getCacheTimestampForKey('username'))
            .thenAnswer((_) async => now);
        when(mockCacheService.getCacheTimestampForKey('personId'))
            .thenAnswer((_) async => now);
        when(mockCacheService.getCacheTimestampForKey('webLoginId'))
            .thenAnswer((_) async => now);
        when(mockNetworkService.getCacheExpirationDuration())
            .thenReturn(const Duration(days: 1));
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
      });

      test('should return failure if cached data is expired', () async {
        // Expired timestamp for all keys
        final expired = DateTime.now()
            .subtract(const Duration(days: 2))
            .millisecondsSinceEpoch;
        when(mockCacheService.getCacheTimestampForKey('username'))
            .thenAnswer((_) async => expired);
        when(mockCacheService.getCacheTimestampForKey('personId'))
            .thenAnswer((_) async => expired);
        when(mockCacheService.getCacheTimestampForKey('webLoginId'))
            .thenAnswer((_) async => expired);
        when(mockNetworkService.getCacheExpirationDuration())
            .thenReturn(const Duration(days: 1));

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
        // Override cached username to not match
        when(mockCacheService.getString('username'))
            .thenAnswer((_) async => 'wrong_user');
        // Valid timestamps
        final now = DateTime.now().millisecondsSinceEpoch;
        when(mockCacheService.getCacheTimestampForKey('username'))
            .thenAnswer((_) async => now);
        when(mockCacheService.getCacheTimestampForKey('personId'))
            .thenAnswer((_) async => now);
        when(mockCacheService.getCacheTimestampForKey('webLoginId'))
            .thenAnswer((_) async => now);

        final result = await authService.login(testUsername, testPassword);

        expect(result, {
          'ResultType': 0,
          'ResultMessage':
              'Offline-Anmeldung fehlgeschlagen: Kein Cache oder falsches Passwort.',
        });
      });

      test('should return failure if no cached data is available', () async {
        // Set all relevant cached values to null for this test
        when(mockCacheService.getString('username'))
            .thenAnswer((_) async => null);
        when(mockSecureStorage.read(key: 'password'))
            .thenAnswer((_) async => null);
        when(mockCacheService.getInt('personId')).thenAnswer((_) async => null);
        when(mockCacheService.getInt('webLoginId'))
            .thenAnswer((_) async => null);
        // Null timestamps for all keys
        when(mockCacheService.getCacheTimestampForKey('username'))
            .thenAnswer((_) async => null);
        when(mockCacheService.getCacheTimestampForKey('personId'))
            .thenAnswer((_) async => null);
        when(mockCacheService.getCacheTimestampForKey('webLoginId'))
            .thenAnswer((_) async => null);

        final result = await authService.login(testUsername, testPassword);

        expect(result, {
          'ResultType': 0,
          'ResultMessage':
              'Offline-Anmeldung fehlgeschlagen: Kein Cache oder falsches Passwort.',
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
        final requestBody = {
          'PersonID': personId,
          'PasswortNeu': newPassword,
        };
        when(mockHttpClient.put('MyBSSBPasswortAendern', requestBody))
            .thenAnswer((_) async => expectedResponse);

        final result = await authService.changePassword(personId, newPassword);

        expect(result, expectedResponse);
        verify(mockHttpClient.put('MyBSSBPasswortAendern', requestBody))
            .called(1);
      });

      test('should return error response on server failure', () async {
        const personId = 123;
        const newPassword = 'newSecret123';
        final expectedResponse = {
          'ResultType': 0,
          'Message': 'Password change failed',
        };
        final requestBody = {
          'PersonID': personId,
          'PasswortNeu': newPassword,
        };
        when(mockHttpClient.put('MyBSSBPasswortAendern', requestBody))
            .thenAnswer((_) async => expectedResponse);

        final result = await authService.changePassword(personId, newPassword);

        expect(result, expectedResponse);
        verify(mockHttpClient.put('MyBSSBPasswortAendern', requestBody))
            .called(1);
      });

      test('should handle unexpected server response format', () async {
        const personId = 123;
        const newPassword = 'newSecret123';
        final requestBody = {
          'PersonID': personId,
          'PasswortNeu': newPassword,
        };
        when(mockHttpClient.put('MyBSSBPasswortAendern', requestBody))
            .thenAnswer((_) async => 'Invalid response format');

        final result = await authService.changePassword(personId, newPassword);

        expect(result, {});
        verify(mockHttpClient.put('MyBSSBPasswortAendern', requestBody))
            .called(1);
      });
    });

    group('FindePersonID2', () {
      test('returns true if list is not empty', () async {
        when(mockHttpClient.get('FindePersonID2/Rizoudis/40101205')).thenAnswer(
          (_) async => [
            {
              'NAMEN': 'Rizoudis',
              'VORNAME': 'Konstantinos',
              'PERSONID': 439287,
              'TITEL': '',
              'GESCHLECHT': true,
              'STRASSE': 'Aichacher',
              'PLZ': '86574',
              'ORT': 'Alsmoos',
            }
          ],
        );
        final result = await authService.findePersonID2('Rizoudis', '40101205');
        expect(result, 439287);
      });

      test('returns false if list is empty', () async {
        when(mockHttpClient.get('FindePersonID2/NoName/00000000'))
            .thenAnswer((_) async => []);
        final result = await authService.findePersonID2('NoName', '00000000');
        expect(result, 0);
      });

      test('returns false on exception', () async {
        when(mockHttpClient.get('FindePersonID2/Error/99999999'))
            .thenThrow(Exception('fail'));
        final result = await authService.findePersonID2('Error', '99999999');
        expect(result, 0);
      });
    });

    group('fetchLoginEmail', () {
      setUp(() async {
        TestWidgetsFlutterBinding.ensureInitialized();
        // Stub config values for base URL construction
        when(mockConfigService.getString('apiProtocol', any))
            .thenReturn('https');
        when(mockConfigService.getString('api1BaseServer', any))
            .thenReturn('webintern.bssb.bayern');
        when(mockConfigService.getString('api1Port', any)).thenReturn('56400');
        when(mockConfigService.getString('api1BasePath', any))
            .thenReturn('rest/zmi/api1');
      });

      test('returns LOGINMAIL when present in response', () async {
        const passnummer = '40101205';
        const expectedEmail = 'kostas@rizoudis1.de';
        final expectedBaseUrl = ConfigService.buildBaseUrlForServer(
          mockConfigService,
          name: 'api1Base',
        );
        when(
          mockHttpClient.get(
            'FindeLoginMail/$passnummer',
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
  });
}
