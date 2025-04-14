import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/http_client.dart';
import 'package:meinbssb/services/image_service.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:meinbssb/services/network_service.dart';
import 'api_service_test.mocks.dart';

@GenerateMocks([
  HttpClient,
  ImageService,
  CacheService,
  NetworkService,
  FlutterSecureStorage,
])
void main() {
  late ApiService apiService;
  late MockHttpClient mockHttpClient;
  late MockImageService mockImageService;
  late MockCacheService mockCacheService;
  late MockNetworkService mockNetworkService;
  late MockFlutterSecureStorage mockSecureStorage;

  const String baseIp = '127.0.0.1';
  const String port = '8080';
  const int serverTimeout = 30;

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockImageService = MockImageService();
    mockCacheService = MockCacheService();
    mockNetworkService = MockNetworkService();
    mockSecureStorage = MockFlutterSecureStorage();

    apiService = ApiService(
      httpClient: mockHttpClient,
      imageService: mockImageService,
      cacheService: mockCacheService,
      networkService: mockNetworkService,
      baseIp: baseIp,
      port: port,
      serverTimeout: serverTimeout,
    );
  });

  group('ApiService Tests', () {
    group('Network Status', () {
      test('hasInternet returns network service status', () async {
        when(mockNetworkService.hasInternet()).thenAnswer((_) async => true);
        expect(await apiService.hasInternet(), true);
      });

      test('getCacheExpirationDuration returns network service duration', () {
        const duration = Duration(minutes: 5);
        when(mockNetworkService.getCacheExpirationDuration())
            .thenReturn(duration);
        expect(apiService.getCacheExpirationDuration(), duration);
      });
    });

    group('Registration', () {
      test('successful registration returns response', () async {
        final response = {'status': 'success'};
        when(mockHttpClient.post('RegisterMyBSSB', any))
            .thenAnswer((_) async => response);

        final result = await apiService.register(
          firstName: 'John',
          lastName: 'Doe',
          passNumber: '12345',
          email: 'john@example.com',
          birthDate: '1990-01-01',
          zipCode: '12345',
        );

        expect(result, response);
      });

      test('registration with invalid response returns empty map', () async {
        when(mockHttpClient.post('RegisterMyBSSB', any))
            .thenAnswer((_) async => 'invalid response');

        final result = await apiService.register(
          firstName: 'John',
          lastName: 'Doe',
          passNumber: '12345',
          email: 'john@example.com',
          birthDate: '1990-01-01',
          zipCode: '12345',
        );

        expect(result, {});
      });
    });

    group('Login', () {
      test('successful login caches user data', () async {
        final response = {
          'ResultType': 1,
          'PersonID': 123,
          'ResultMessage': 'Success',
        };
        when(mockHttpClient.post('LoginMyBSSB', any))
            .thenAnswer((_) async => response);
        when(mockCacheService.setString('username', any))
            .thenAnswer((_) async => true);
        when(mockSecureStorage.write(key: 'password', value: any))
            .thenAnswer((_) async => true);
        when(mockCacheService.setInt('personId', any))
            .thenAnswer((_) async => true);
        when(mockCacheService.setCacheTimestamp())
            .thenAnswer((_) async => true);

        final result = await apiService.login('test@example.com', 'password');

        expect(result, response);
        verify(mockCacheService.setString('username', 'test@example.com')).called(1);
        verify(mockSecureStorage.write(key: 'password', value: 'password')).called(1);
        verify(mockCacheService.setInt('personId', 123)).called(1);
        verify(mockCacheService.setCacheTimestamp()).called(1);
      });

      test('failed login returns error response', () async {
        final response = {
          'ResultType': 0,
          'ResultMessage': 'Invalid credentials',
        };
        when(mockHttpClient.post('LoginMyBSSB', any))
            .thenAnswer((_) async => response);

        final result = await apiService.login('test@example.com', 'wrongpassword');

        expect(result, response);
        verifyNever(mockCacheService.setString(any, any));
        verifyNever(mockSecureStorage.write(key: any, value: any));
      });

      test('offline login with valid cache succeeds', () async {
        when(mockHttpClient.post('LoginMyBSSB', any))
            .thenThrow(http.ClientException('Connection refused'));
        when(mockCacheService.getString('username'))
            .thenAnswer((_) async => 'test@example.com');
        when(mockSecureStorage.read(key: 'password'))
            .thenAnswer((_) async => 'password');
        when(mockCacheService.getInt('personId'))
            .thenAnswer((_) async => 123);
        when(mockCacheService.getInt('cacheTimestamp'))
            .thenAnswer((_) async => DateTime.now().millisecondsSinceEpoch);
        when(mockNetworkService.getCacheExpirationDuration())
            .thenReturn(const Duration(hours: 1));

        final result = await apiService.login('test@example.com', 'password');

        expect(result, {
          'ResultType': 1,
          'PersonID': 123,
        });
      });
    });

    group('Password Reset', () {
      test('successful password reset returns response', () async {
        final response = {'status': 'success'};
        when(mockHttpClient.post('PasswordReset/12345', any))
            .thenAnswer((_) async => response);

        final result = await apiService.resetPassword('12345');

        expect(result, response);
      });

      test('network error during password reset throws NetworkException', () async {
        when(mockHttpClient.post('PasswordReset/12345', any))
            .thenThrow(http.ClientException('Connection refused'));

        expect(
          () => apiService.resetPassword('12345'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('Passdaten', () {
      test('successful passdaten fetch returns mapped response', () async {
        final response = {
          'PASSNUMMER': '12345',
          'VEREINNR': '67890',
          'NAMEN': 'Doe',
          'VORNAME': 'John',
          'TITEL': 'Mr.',
          'GEBURTSDATUM': '1990-01-01',
          'GESCHLECHT': 'M',
          'VEREINNAME': 'Test Club',
          'PASSDATENID': 1,
          'MITGLIEDSCHAFTID': 2,
          'PERSONID': 3,
        };
        when(mockHttpClient.get('Passdaten/123'))
            .thenAnswer((_) async => response);

        final result = await apiService.fetchPassdaten(123);

        expect(result, response);
      });

      test('invalid passdaten response returns empty map', () async {
        when(mockHttpClient.get('Passdaten/123'))
            .thenAnswer((_) async => 'invalid response');

        final result = await apiService.fetchPassdaten(123);

        expect(result, {});
      });
    });

    group('Schuetzenausweis', () {
      test('successful schuetzenausweis fetch returns rotated image', () async {
        final imageData = [1, 2, 3, 4];
        final rotatedImage = [4, 3, 2, 1];
        when(mockImageService.getCachedSchuetzenausweis(any, any))
            .thenAnswer((_) async => null);
        when(mockHttpClient.getBytes('Schuetzenausweis/JPG/123'))
            .thenAnswer((_) async => imageData);
        when(mockImageService.cacheSchuetzenausweis(any, any, any))
            .thenAnswer((_) async => true);
        when(mockImageService.rotatedImage(imageData))
            .thenReturn(rotatedImage);

        final result = await apiService.fetchSchuetzenausweis(123);

        expect(result, rotatedImage);
      });

      test('uses cached schuetzenausweis when available', () async {
        final cachedImage = [1, 2, 3, 4];
        final rotatedImage = [4, 3, 2, 1];
        when(mockImageService.getCachedSchuetzenausweis(any, any))
            .thenAnswer((_) async => cachedImage);
        when(mockImageService.rotatedImage(cachedImage))
            .thenReturn(rotatedImage);

        final result = await apiService.fetchSchuetzenausweis(123);

        expect(result, rotatedImage);
        verifyNever(mockHttpClient.getBytes(any));
      });
    });
  });
} 