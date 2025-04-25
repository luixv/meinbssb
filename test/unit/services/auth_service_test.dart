// test/unit/services/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:meinbssb/services/http_client.dart';
import 'package:meinbssb/services/network_service.dart';
import 'auth_service_test.mocks.dart';

// First, create an abstract class that includes the getter
abstract class NetworkServiceWithGetter implements NetworkService {
  bool get isConnected;
}

@GenerateMocks([
  HttpClient,
  CacheService,
  NetworkServiceWithGetter, // Use this instead of NetworkService
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthService authService;
  late MockHttpClient mockHttpClient;
  late MockCacheService mockCacheService;
  late MockNetworkServiceWithGetter mockNetworkService;
  
  // Setup mock for FlutterSecureStorage platform channel
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final stored = <String, String>{};

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockCacheService = MockCacheService();
    mockNetworkService = MockNetworkServiceWithGetter();

    // Setup platform channel mock
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'read':
            final key = methodCall.arguments['key'] as String;
            return stored[key];
          case 'write':
            final key = methodCall.arguments['key'] as String;
            final value = methodCall.arguments['value'] as String;
            stored[key] = value;
            return null;
          case 'delete':
            final key = methodCall.arguments['key'] as String;
            stored.remove(key);
            return null;
          default:
            return null;
        }
      },
    );

    authService = AuthService(
      httpClient: mockHttpClient,
      cacheService: mockCacheService,
      networkService: mockNetworkService,
    );

    // Clear stored data before each test
    stored.clear();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      null,
    );
  });

  group('AuthService - Registration', () {
    final registrationData = {
      'firstName': 'John',
      'lastName': 'Doe',
      'passNumber': '12345',
      'email': 'john.doe@example.com',
      'birthDate': '1990-01-01',
      'zipCode': '12345',
    };

    test('successful registration', () async {
      when(mockHttpClient.post('RegisterMyBSSB', any))
          .thenAnswer((_) async => {'ResultType': 1, 'ResultMessage': 'Success'});

      final result = await authService.register(
        firstName: registrationData['firstName']!,
        lastName: registrationData['lastName']!,
        passNumber: registrationData['passNumber']!,
        email: registrationData['email']!,
        birthDate: registrationData['birthDate']!,
        zipCode: registrationData['zipCode']!,
      );

      expect(result['ResultType'], 1);
      expect(result['ResultMessage'], 'Success');
      verify(mockHttpClient.post('RegisterMyBSSB', registrationData)).called(1);
    });
  });

  group('AuthService - Login', () {
    const email = 'test@example.com';
    const password = 'password123';
    const personId = 12345;

    test('successful online login', () async {
      final expectedLoginData = {
        'email': email,
        'password': password,
      };
      final loginResponse = {
        'ResultType': 1,
        'PersonID': personId,
        'ResultMessage': 'Success',
      };
      
      when(mockNetworkService.isConnected).thenReturn(true);
      when(mockHttpClient.post(
        'LoginMyBSSB',
        expectedLoginData,
      )).thenAnswer((_) async => loginResponse);
      
      when(mockCacheService.setString(any, any)).thenAnswer((_) async => null);
      when(mockCacheService.setInt(any, any)).thenAnswer((_) async => null);
      when(mockCacheService.setCacheTimestamp()).thenAnswer((_) async => null);

      final result = await authService.login(email, password);

      expect(result, equals(loginResponse));
      verify(mockCacheService.setString('username', email)).called(1);
      verify(mockCacheService.setInt('personId', personId)).called(1);
      verify(mockCacheService.setCacheTimestamp()).called(1);
      verify(mockHttpClient.post(
        'LoginMyBSSB',
        expectedLoginData,
      )).called(1);
      expect(stored['password'], equals(password));
    });

    test('failed login with invalid credentials', () async {
      final expectedLoginData = {
        'email': email,
        'password': password,
      };
      final errorResponse = {
        'ResultType': 0,
        'ResultMessage': 'Benutzername oder Passwort ist falsch',
      };

      when(mockNetworkService.isConnected).thenReturn(true);
      when(mockHttpClient.post(
        'LoginMyBSSB',
        expectedLoginData,
      )).thenAnswer((_) async => errorResponse);

      final result = await authService.login(email, password);

      expect(result['ResultType'], 0);
      expect(result['ResultMessage'], 'Benutzername oder Passwort ist falsch');
      verifyNever(mockCacheService.setString(any, any));
      verifyNever(mockCacheService.setInt(any, any));
      verify(mockHttpClient.post(
        'LoginMyBSSB',
        expectedLoginData,
      )).called(1);
      expect(stored['password'], isNull);
    });

    test('login with network error', () async {
      final expectedLoginData = {
        'email': email,
        'password': password,
      };

      when(mockNetworkService.isConnected).thenReturn(false);
      stored['password'] = password;
      when(mockCacheService.getString('username')).thenAnswer((_) async => email);
      when(mockCacheService.getInt('personId'))
          .thenAnswer((_) async => personId);
      when(mockCacheService.getInt('cacheTimestamp'))
          .thenAnswer((_) async => DateTime.now().millisecondsSinceEpoch);
      when(mockNetworkService.getCacheExpirationDuration())
          .thenReturn(const Duration(days: 30));

      when(mockHttpClient.post(
        'LoginMyBSSB',
        expectedLoginData,
      )).thenThrow(http.ClientException('Connection refused'));

      final result = await authService.login(email, password);

      expect(result['ResultType'], 1);
      expect(result['PersonID'], personId);
      verify(mockCacheService.getString('username')).called(1);
      verify(mockNetworkService.getCacheExpirationDuration()).called(1);
    });
  });

  group('AuthService - Password Reset', () {
    const passNumber = '12345';

    test('successful password reset', () async {
      when(mockHttpClient.post('PasswordReset/$passNumber', any))
          .thenAnswer((_) async => {'ResultType': 1, 'ResultMessage': 'Success'});

      final result = await authService.resetPassword(passNumber);

      expect(result['ResultType'], 1);
      expect(result['ResultMessage'], 'Success');
    });

    test('failed password reset', () async {
      when(mockHttpClient.post('PasswordReset/$passNumber', any))
          .thenThrow(Exception('Reset failed'));

      expect(() => authService.resetPassword(passNumber), throwsException);
    });
  });

  group('AuthService - Logout', () {
    test('successful logout', () async {
      stored['password'] = 'somepassword'; // Simulate stored password
      when(mockCacheService.remove(any)).thenAnswer((_) async => null);

      await authService.logout();

      verify(mockCacheService.remove('username')).called(1);
      verify(mockCacheService.remove('personId')).called(1);
      verify(mockCacheService.remove('cacheTimestamp')).called(1);
      expect(stored['password'], isNull); // Verify password was removed
    });

    test('failed logout', () async {
      when(mockCacheService.remove(any)).thenThrow(Exception('Logout failed'));

      expect(() => authService.logout(), throwsException);
    });
  });
}