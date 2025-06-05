import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_service_test.mocks.dart';

// Ensure the mock is generated for FlutterSecureStorage
@GenerateMocks([HttpClient, CacheService, NetworkService, FlutterSecureStorage])
void main() {
  late AuthService authService;
  late MockHttpClient mockHttpClient;
  late MockCacheService mockCacheService;
  late MockNetworkService mockNetworkService;
  late MockFlutterSecureStorage mockSecureStorage;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Initialize all mocks before each test
    mockHttpClient = MockHttpClient();
    mockCacheService = MockCacheService();
    mockNetworkService = MockNetworkService();
    mockSecureStorage = MockFlutterSecureStorage();

    // Create AuthService instance for each test, injecting all mocks
    authService = AuthService(
      httpClient: mockHttpClient,
      cacheService: mockCacheService,
      networkService: mockNetworkService,
      secureStorage: mockSecureStorage, // INJECT THE MOCK HERE
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
    when(mockCacheService.setCacheTimestamp()).thenAnswer((_) async => true);
    when(mockCacheService.getString(any)).thenAnswer((_) async => null);
    when(mockCacheService.getInt(any)).thenAnswer((_) async => null);

    // Default for NetworkService.getCacheExpirationDuration (can be overridden by specific tests)
    when(mockNetworkService.getCacheExpirationDuration())
        .thenReturn(const Duration(days: 1)); // Default to non-expired
  });

  // No tearDown needed for platform channel handler since it's removed from setUp.

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

        // Stub the successful online login
        when(
          mockHttpClient.getWithBody(
            'LoginMyBSSB',
            {'Email': email, 'Passwort': password},
          ),
        ).thenAnswer((_) async => expectedResponse);

        final result = await authService.login(email, password);

        expect(result, expectedResponse);
        verify(mockCacheService.setString('username', email)).called(1);
        verify(mockSecureStorage.write(key: 'password', value: password))
            .called(1);
        verify(mockCacheService.setInt('personId', 456)).called(1);
        verify(mockCacheService.setInt('webLoginId', 789)).called(1);
        verify(mockCacheService.setCacheTimestamp()).called(1);
        verify(
          mockHttpClient.getWithBody(
            'LoginMyBSSB',
            {'Email': email, 'Passwort': password},
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
        when(
          mockHttpClient.getWithBody(
            'LoginMyBSSB',
            {'Email': email, 'Passwort': password},
          ),
        ).thenAnswer((_) async => expectedResponse);

        final result = await authService.login(email, password);

        expect(result, expectedResponse);
        verify(
          mockHttpClient.getWithBody(
            'LoginMyBSSB',
            {'Email': email, 'Passwort': password},
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

        // Simulate network error for online login
        when(mockHttpClient.getWithBody(any, any)).thenThrow(
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

        verify(mockHttpClient.getWithBody(any, any)).called(1);
        verify(mockCacheService.getString('username')).called(1);
        verify(mockSecureStorage.read(key: 'password')).called(1);
      });

      test(
          'should return generic error message for other exceptions during online login',
          () async {
        const email = 'test@example.com';
        const password = 'password123';

        when(mockHttpClient.getWithBody(any, any))
            .thenThrow(Exception('Some other unexpected error'));

        final result = await authService.login(email, password);

        expect(result, {
          'ResultType': 0,
          'ResultMessage': 'Benutzername oder Passwort ist falsch',
        });
        verify(mockHttpClient.getWithBody(any, any)).called(1);
        verifyNever(mockCacheService.getString(any));
      });
    });

    group('resetPassword', () {
      test('should return reset password data on success', () async {
        const passNumber = '12345';
        final expectedResponse = {
          'ResultType': 1,
          'Message': 'Password reset successful',
        };
        final requestBody = {'passNumber': passNumber};
        when(mockHttpClient.post('PasswordReset/$passNumber', requestBody))
            .thenAnswer((_) async => expectedResponse);

        final result = await authService.resetPassword(passNumber);

        expect(result, expectedResponse);
        verify(mockHttpClient.post('PasswordReset/$passNumber', requestBody))
            .called(1);
      });

      test('should rethrow error on reset password failure', () async {
        const passNumber = '12345';
        final requestBody = {'passNumber': passNumber};
        when(mockHttpClient.post('PasswordReset/$passNumber', requestBody))
            .thenThrow(http.ClientException('Failed to reset password'));

        expect(
          () => authService.resetPassword(passNumber),
          throwsA(isA<http.ClientException>()),
        );
        verify(mockHttpClient.post('PasswordReset/$passNumber', requestBody))
            .called(1);
      });
    });

    group('logout', () {
      test('should clear all cached data on successful logout', () async {
        // No explicit stubs needed here as global mocks are fine
        // if no specific key/value is being asserted to be returned.
        // The default `thenAnswer((_) async => {})` and `thenAnswer((_) async => true)`
        // for secureStorage.delete and cacheService.remove are sufficient.

        await authService.logout();

        verify(mockCacheService.remove('username')).called(1);
        verify(mockSecureStorage.delete(key: 'password')).called(1);
        verify(mockCacheService.remove('personId')).called(1);
        verify(mockCacheService.remove('cacheTimestamp')).called(1);
      });

      test('should rethrow error on logout failure', () async {
        when(mockCacheService.remove('username'))
            .thenThrow(Exception('Failed to remove username'));

        expect(() => authService.logout(), throwsA(isA<Exception>()));
        verify(mockCacheService.remove('username')).called(1);
        verifyNever(mockSecureStorage.delete(key: anyNamed('key')));
        verifyNever(mockCacheService.remove('personId'));
      });
    });

    group('login (offline)', () {
      const String testUsername = 'testuser';
      const String testPassword = 'testpassword';
      const int cachedPersonId = 123;
      const int cachedWebloginId = 456;

      setUp(() {
        // Ensure online login attempt throws ClientException to trigger offline flow
        when(mockHttpClient.getWithBody(any, any)).thenThrow(
          http.ClientException('Network error during online login'),
        );

        // Stub offline cache data for successful offline login
        when(mockCacheService.getString('username'))
            .thenAnswer((_) async => testUsername); // Fixed to use testUsername
        when(mockSecureStorage.read(key: 'password'))
            .thenAnswer((_) async => testPassword); // Fixed to use testPassword
        when(mockCacheService.getInt('personId'))
            .thenAnswer((_) async => cachedPersonId);
        when(mockCacheService.getInt('webLoginId'))
            .thenAnswer((_) async => cachedWebloginId);
        when(mockCacheService.getInt('cacheTimestamp')).thenAnswer(
          (_) async => DateTime.now()
              .subtract(const Duration(minutes: 5))
              .millisecondsSinceEpoch,
        );
        // This is already globally set, but can be explicitly set here too if needed
        when(mockNetworkService.getCacheExpirationDuration())
            .thenReturn(const Duration(days: 1));
      });

      test(
          'should successfully login from cache if data is valid and not expired',
          () async {
        final result = await authService.login(testUsername, testPassword);

        verify(mockCacheService.getInt('cacheTimestamp')).called(1);
        expect(result, {
          'ResultType': 1,
          'PersonID': cachedPersonId,
          'WebLoginID': cachedWebloginId,
        });
      });

      test('should return failure if cached data is expired', () async {
        // Override the cacheTimestamp to be expired for this specific test
        when(mockCacheService.getInt('cacheTimestamp')).thenAnswer(
          (_) async => DateTime.now()
              .subtract(
                const Duration(
                  days: 2,
                ),
              ) // 2 days ago, and expiration is 1 day
              .millisecondsSinceEpoch,
        );
        when(mockNetworkService.getCacheExpirationDuration())
            .thenReturn(const Duration(days: 1)); // Still 1 day expiration

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
        when(mockCacheService.getInt('cacheTimestamp'))
            .thenAnswer((_) async => null);

        final result = await authService.login(testUsername, testPassword);

        expect(result, {
          'ResultType': 0,
          'ResultMessage':
              'Offline-Anmeldung fehlgeschlagen: Kein Cache oder falsches Passwort.',
        });
      });
    });
  });
}
