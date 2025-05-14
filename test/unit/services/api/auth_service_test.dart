import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:meinbssb/services/http_client.dart';
import 'package:meinbssb/services/network_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([HttpClient, CacheService, NetworkService, FlutterSecureStorage])
void main() {
  late AuthService authService;
  late MockHttpClient mockHttpClient;
  late MockCacheService mockCacheService;
  late MockNetworkService mockNetworkService;
  late MockFlutterSecureStorage mockSecureStorage;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    mockHttpClient = MockHttpClient();
    mockCacheService = MockCacheService();
    mockNetworkService = MockNetworkService();
    mockSecureStorage = MockFlutterSecureStorage();
    authService = AuthService(
      httpClient: mockHttpClient,
      cacheService: mockCacheService,
      networkService: mockNetworkService,
    );
    when(mockSecureStorage.read(key: anyNamed('key'))).thenAnswer(
      (_) async => null,
    ); // Default to null if not specifically stubbed
  });

  group('AuthService', () {
    group('register', () {
      test('should return registration data on success', () async {
        const registrationData = {
          'firstName': 'John',
          'lastName': 'Doe',
          'passNumber': '12345',
          'email': 'john.doe@example.com',
          'birthDate': '1990-01-01',
          'zipCode': '10001',
        };
        final expectedResponse = {'ResultType': 1, 'PersonID': 123};
        when(
          mockHttpClient.post('RegisterMyBSSB', registrationData),
        ).thenAnswer((_) async => expectedResponse);

        final result = await authService.register(
          firstName: registrationData['firstName']!,
          lastName: registrationData['lastName']!,
          passNumber: registrationData['passNumber']!,
          email: registrationData['email']!,
          birthDate: registrationData['birthDate']!,
          zipCode: registrationData['zipCode']!,
        );

        expect(result, expectedResponse);
        verify(
          mockHttpClient.post('RegisterMyBSSB', registrationData),
        ).called(1);
      });

      test('should rethrow error on registration failure', () async {
        const registrationData = {
          'firstName': 'John',
          'lastName': 'Doe',
          'passNumber': '12345',
          'email': 'john.doe@example.com',
          'birthDate': '1990-01-01',
          'zipCode': '10001',
        };
        when(
          mockHttpClient.post('RegisterMyBSSB', registrationData),
        ).thenThrow(http.ClientException('Failed to register'));

        expect(
          () => authService.register(
            firstName: registrationData['firstName']!,
            lastName: registrationData['lastName']!,
            passNumber: registrationData['passNumber']!,
            email: registrationData['email']!,
            birthDate: registrationData['birthDate']!,
            zipCode: registrationData['zipCode']!,
          ),
          throwsA(isA<http.ClientException>()),
        );
        verify(
          mockHttpClient.post('RegisterMyBSSB', registrationData),
        ).called(1);
      });
    });

    group('login (online)', () {
      test('should return error on server login failure', () async {
        const email = 'test@example.com';
        const password = 'password123';
        final expectedResponse = {
          'ResultType': 0,
          'ResultMessage': 'Invalid credentials',
        };
        when(
          mockHttpClient
              .post('LoginMyBSSB', {'email': email, 'password': password}),
        ).thenAnswer((_) async => expectedResponse);

        final result = await authService.login(email, password);

        expect(result, expectedResponse);
        verify(
          mockHttpClient
              .post('LoginMyBSSB', {'email': email, 'password': password}),
        ).called(1);
      });
    });

    group('resetPassword', () {
      test('should return reset password data on success', () async {
        const passNumber = '12345';
        final expectedResponse = {
          'ResultType': 1,
          'Message': 'Password reset successful',
        };
        when(
          mockHttpClient
              .post('PasswordReset/$passNumber', {'passNumber': passNumber}),
        ).thenAnswer((_) async => expectedResponse);

        final result = await authService.resetPassword(passNumber);

        expect(result, expectedResponse);
        verify(
          mockHttpClient
              .post('PasswordReset/$passNumber', {'passNumber': passNumber}),
        ).called(1);
      });

      test('should rethrow error on reset password failure', () async {
        const passNumber = '12345';
        when(
          mockHttpClient
              .post('PasswordReset/$passNumber', {'passNumber': passNumber}),
        ).thenThrow(http.ClientException('Failed to reset password'));

        expect(
          () => authService.resetPassword(passNumber),
          throwsA(isA<http.ClientException>()),
        );
        verify(
          mockHttpClient
              .post('PasswordReset/$passNumber', {'passNumber': passNumber}),
        ).called(1);
      });
    });

    group('logout', () {
      test('should rethrow error on logout failure', () async {
        when(
          mockCacheService.remove('username'),
        ).thenThrow(Exception('Failed to remove username'));

        expect(() => authService.logout(), throwsA(isA<Exception>()));
        verify(mockCacheService.remove('username')).called(1);
      });
    });

    group('login (offline)', () {
      const String testUsername = 'testuser';
      const String testPassword = 'testpassword';
      const int cachedPersonId = 123;

      setUp(() {
        when(mockHttpClient.post(any, any))
            .thenThrow(http.ClientException('Network error'));

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async {
            if (call.method == 'read' && call.arguments['key'] == 'password') {
              return testPassword;
            }
            return null;
          },
        );

        when(mockCacheService.getString('username'))
            .thenAnswer((_) async => testUsername);
        when(mockCacheService.getInt('personId'))
            .thenAnswer((_) async => cachedPersonId);
        when(mockCacheService.getInt('cacheTimestamp')).thenAnswer(
          (_) async => DateTime.now()
              .subtract(const Duration(minutes: 5))
              .millisecondsSinceEpoch,
        );
      });

      test(
        'should successfully login from cache if data is valid and not expired',
        () async {
          when(mockNetworkService.getCacheExpirationDuration())
              .thenReturn(const Duration(days: 1)); // Not expired

          final result = await authService.login(testUsername, testPassword);

          // Let's also verify that the cache timestamp was retrieved
          verify(mockCacheService.getInt('cacheTimestamp')).called(1);

          expect(result, {'ResultType': 1, 'PersonID': cachedPersonId});
        },
      );

      test('should return failure if cached data is expired', () async {
        when(mockNetworkService.getCacheExpirationDuration())
            .thenReturn(const Duration(minutes: -1)); // Expired

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
          when(mockCacheService.getString('username'))
              .thenAnswer((_) async => 'wrong_user');
          when(mockNetworkService.getCacheExpirationDuration()) // ADD THIS STUB
              .thenReturn(
            const Duration(
              days: 1,
            ),
          ); // Assume non-expired for this scenario

          final result = await authService.login(testUsername, testPassword);

          expect(result, {
            'ResultType': 0,
            'ResultMessage':
                'Offline-Anmeldung fehlgeschlagen: Kein Cache oder falsches Passwort.',
          });
        },
      );

      test('should return failure if no cached data is available', () async {
        when(mockCacheService.getString('username'))
            .thenAnswer((_) async => null);
        when(mockCacheService.getInt('personId')).thenAnswer((_) async => null);
        when(mockCacheService.getInt('cacheTimestamp'))
            .thenAnswer((_) async => null);
        when(mockNetworkService.getCacheExpirationDuration()) // ADD THIS STUB
            .thenReturn(
          const Duration(
            days: 1,
          ),
        ); // Assume non-expired for this scenario

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
