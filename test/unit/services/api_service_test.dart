import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:meinbssb/services/http_client.dart';
import 'package:meinbssb/services/image_service.dart';
import 'package:meinbssb/services/network_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'api_service_test.mocks.dart';

@GenerateMocks([
  HttpClient,
  ImageService,
  CacheService,
  NetworkService,
  FlutterSecureStorage,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ApiService apiService;
  late MockHttpClient mockHttpClient;
  late MockImageService mockImageService;
  late MockCacheService mockCacheService;
  late MockNetworkService mockNetworkService;
  late MockFlutterSecureStorage mockSecureStorage;

  const String testBaseIp = 'test.com';
  const String testPort = '8080';
  const int testServerTimeout = 5;

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
      baseIp: testBaseIp,
      port: testPort,
      serverTimeout: testServerTimeout,
    );
  });

  group('ApiService - register', () {
    test('should call httpClient.post with correct endpoint and data',
        () async {
      const String firstName = 'John';
      const String lastName = 'Doe';
      const String passNumber = '12345';
      const String email = 'john.doe@example.com';
      const String birthDate = '2000-01-01';
      const String zipCode = '12345';
      final expectedData = {
        'firstName': firstName,
        'lastName': lastName,
        'passNumber': passNumber,
        'email': email,
        'birthDate': birthDate,
        'zipCode': zipCode,
      };
      when(mockHttpClient.post('RegisterMyBSSB', expectedData))
          .thenAnswer((_) async => {'success': true});

      await apiService.register(
        firstName: firstName,
        lastName: lastName,
        passNumber: passNumber,
        email: email,
        birthDate: birthDate,
        zipCode: zipCode,
      );

      verify(mockHttpClient.post('RegisterMyBSSB', expectedData)).called(1);
    });

    test('should return the response from httpClient.post', () async {
      const testResponse = {'success': true, 'userId': 1};
      when(mockHttpClient.post(any, any)).thenAnswer((_) async => testResponse);

      final result = await apiService.register(
        firstName: 'test',
        lastName: 'test',
        passNumber: 'test',
        email: 'test',
        birthDate: 'test',
        zipCode: 'test',
      );

      expect(result, testResponse);
    });

    test('should return an empty map if httpClient.post throws exception',
        () async {
      when(mockHttpClient.post(any, any))
          .thenThrow(Exception('Test exception'));

      final result = await apiService.register(
        firstName: 'test',
        lastName: 'test',
        passNumber: 'test',
        email: 'test',
        birthDate: 'test',
        zipCode: 'test',
      );

      expect(result, {});
    });
  });

  group('ApiService - resetPassword', () {
    test('should call correct endpoint with passNumber', () async {
      const passNumber = '12345';
      when(
        mockHttpClient
            .post('PasswordReset/$passNumber', {'passNumber': passNumber}),
      ).thenAnswer((_) async => {'success': true});

      await apiService.resetPassword(passNumber);

      verify(
        mockHttpClient.post(
          'PasswordReset/$passNumber',
          {'passNumber': passNumber},
        ),
      ).called(1);
    });

    test('should throw NetworkException on error', () async {
      const passNumber = '12345';
      when(mockHttpClient.post(any, any)).thenThrow(Exception('Test error'));

      expect(
        () => apiService.resetPassword(passNumber),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('ApiService - fetchPassdaten', () {
    test('should call cacheAndRetrieveData with correct parameters', () async {
      const personId = 123;
      final mockResponse = {
        'PASSNUMMER': '123',
        'VEREINNR': '456',
        'NAMEN': 'Doe',
        'VORNAME': 'John',
      };

      when(mockNetworkService.getCacheExpirationDuration())
          .thenReturn(const Duration(minutes: 5));
      when(
        mockCacheService.cacheAndRetrieveData<Map<String, dynamic>>(
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await apiService.fetchPassdaten(personId);

      expect(result, mockResponse);
      verify(
        mockCacheService.cacheAndRetrieveData<Map<String, dynamic>>(
          'passdaten_$personId',
          any,
          any,
          any,
        ),
      ).called(1);
    });
  });
}
