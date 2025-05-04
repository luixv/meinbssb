import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:meinbssb/services/http_client.dart';
import 'package:meinbssb/services/image_service.dart';
import 'package:meinbssb/services/network_service.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../screens/start_screen_test.dart';
import 'login_service_test.mocks.dart';

@GenerateMocks([
  HttpClient,
  ImageService,
  CacheService,
  NetworkService,
  FlutterSecureStorage,
  AuthService,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ApiService apiService;
  late MockConfigService mockConfigService;
  late MockHttpClient mockHttpClient;
  late MockImageService mockImageService;
  late MockCacheService mockCacheService;
  late MockNetworkService mockNetworkService;
  late MockFlutterSecureStorage mockSecureStorage;

  const int testWebLoginId = 27;
  const int testPersonId = 4711;

  setUp(() {
    mockConfigService = MockConfigService();
    mockHttpClient = MockHttpClient();
    mockImageService = MockImageService();
    mockCacheService = MockCacheService();
    mockNetworkService = MockNetworkService();
    mockSecureStorage = MockFlutterSecureStorage();

    apiService = ApiService(
      configService: mockConfigService,
      httpClient: mockHttpClient,
      imageService: mockImageService,
      cacheService: mockCacheService,
      networkService: mockNetworkService,
    );
  });

  group('Login Functionality', () {
    const String testUsername = 'testuser';
    const String testPassword = 'testpassword';

    test('should call httpClient.post with correct credentials', () async {
      final expectedData = {'email': testUsername, 'password': testPassword};
      when(mockHttpClient.post('LoginMyBSSB', expectedData)).thenAnswer(
        (_) async => {
          'ResultType': 1,
          'ResultMessage': 'MyBSSB Login Erfolgreich',
          'PersonID': testPersonId,
          'WebLoginID': testWebLoginId,
        },
      );

      await apiService.login(testUsername, testPassword);

      verify(mockHttpClient.post('LoginMyBSSB', expectedData)).called(1);
    });

    test('should return the failed login response on failed login', () async {
      final mockResponse = {
        'ResultType': 0,
        'ResultMessage': 'Invalid credentials',
      };
      when(mockHttpClient.post(any, any)).thenAnswer((_) async => mockResponse);

      final result = await apiService.login(testUsername, testPassword);

      expect(result, mockResponse); // Expect the entire map
    });

    test('should handle network errors during login', () async {
      when(mockHttpClient.post(any, any))
          .thenThrow(http.ClientException('Network error during login'));

      final result = await apiService.login(testUsername, testPassword);

      expect(result, {
        'ResultType': 0,
        'ResultMessage': 'Benutzername oder Passwort ist falsch',
      });
      verifyNever(
        mockSecureStorage.write(
          key: anyNamed('key'),
          value: anyNamed('value'),
        ),
      );
    });
  });
}
