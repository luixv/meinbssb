import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:meinbssb/services/http_client.dart';
import 'package:meinbssb/services/network_service.dart';

import 'auth_service_test.mocks.dart';

// Generate mocks for the dependencies of AuthService
@GenerateMocks([
  HttpClient,
  CacheService,
  NetworkService,
]) // Remove FlutterSecureStorage from here
void main() {
  late AuthService authService;
  late MockHttpClient mockHttpClient;
  late MockCacheService mockCacheService;
  late MockNetworkService mockNetworkService;
  // late MockFlutterSecureStorage mockSecureStorage; // Remove this line

  // Initialize the binding *outside* of setUp, at the beginning of main.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Set up the mocks *within* setUp.  This is crucial.
    mockHttpClient = MockHttpClient();
    mockCacheService = MockCacheService();
    mockNetworkService = MockNetworkService();
    // mockSecureStorage = MockFlutterSecureStorage(); // Remove this line
    authService = AuthService(
      httpClient: mockHttpClient,
      cacheService: mockCacheService,
      networkService: mockNetworkService,
      // secureStorage: mockSecureStorage,  // Remove this line. AuthService no longer takes secureStorage.
    );
  });

  group('AuthService', () {
    group('register', () {
      test('should return registration data on success', () async {
        // Arrange
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

        // Act
        final result = await authService.register(
          firstName: registrationData['firstName']!,
          lastName: registrationData['lastName']!,
          passNumber: registrationData['passNumber']!,
          email: registrationData['email']!,
          birthDate: registrationData['birthDate']!,
          zipCode: registrationData['zipCode']!,
        );

        // Assert
        expect(result, expectedResponse);
        verify(
          mockHttpClient.post('RegisterMyBSSB', registrationData),
        ).called(1);
      });

      test('should rethrow error on registration failure', () async {
        // Arrange
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

        // Act & Assert
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

    group('login', () {
      test('should return error on server login failure', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        final expectedResponse = {
          'ResultType': 0,
          'ResultMessage': 'Invalid credentials',
        };
        when(
          mockHttpClient.post('LoginMyBSSB', {
            'email': email,
            'password': password,
          }),
        ).thenAnswer((_) async => expectedResponse);

        // Act
        final result = await authService.login(email, password);

        // Assert
        expect(result, expectedResponse);
        verify(
          mockHttpClient.post('LoginMyBSSB', {
            'email': email,
            'password': password,
          }),
        ).called(1);
      });
    });

    group('resetPassword', () {
      test('should return reset password data on success', () async {
        // Arrange
        const passNumber = '12345';
        final expectedResponse = {
          'ResultType': 1,
          'Message': 'Password reset successful',
        };
        when(
          mockHttpClient.post('PasswordReset/$passNumber', {
            'passNumber': passNumber,
          }),
        ).thenAnswer((_) async => expectedResponse);

        // Act
        final result = await authService.resetPassword(passNumber);

        // Assert
        expect(result, expectedResponse);
        verify(
          mockHttpClient.post('PasswordReset/$passNumber', {
            'passNumber': passNumber,
          }),
        ).called(1);
      });

      test('should rethrow error on reset password failure', () async {
        // Arrange
        const passNumber = '12345';
        when(
          mockHttpClient.post('PasswordReset/$passNumber', {
            'passNumber': passNumber,
          }),
        ).thenThrow(http.ClientException('Failed to reset password'));

        // Act & Assert
        expect(
          () => authService.resetPassword(passNumber),
          throwsA(isA<http.ClientException>()),
        );
        verify(
          mockHttpClient.post('PasswordReset/$passNumber', {
            'passNumber': passNumber,
          }),
        ).called(1);
      });
    });

    group('logout', () {
      test('should rethrow error on logout failure', () async {
        // Arrange
        when(
          mockCacheService.remove('username'),
        ).thenThrow(Exception('Failed to remove username'));

        // Act & Assert
        expect(() => authService.logout(), throwsA(isA<Exception>()));
        verify(mockCacheService.remove('username')).called(1);
      });
    });
  });
}
