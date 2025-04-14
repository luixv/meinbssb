import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
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
  TestWidgetsFlutterBinding.ensureInitialized();

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

  tearDown(() {
    reset(mockHttpClient);
    reset(mockImageService);
    reset(mockCacheService);
    reset(mockNetworkService);
    reset(mockSecureStorage);
  });

  group('ApiService Tests', () {
    group('Network Status', () {
      test('hasInternet returns network service status', () async {
        when(mockNetworkService.hasInternet()).thenAnswer((_) async => true);
        expect(await apiService.hasInternet(), true);
      });

      test('getCacheExpirationDuration returns network service duration', () {
        const duration = Duration(minutes: 5);
        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(duration);
        expect(apiService.getCacheExpirationDuration(), duration);
      });
    });

    group('Registration', () {
      test('successful registration returns response', () async {
        final response = {'status': 'success'};
        when(
          mockHttpClient.post('RegisterMyBSSB', any),
        ).thenAnswer((_) async => response);

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
        when(
          mockHttpClient.post('RegisterMyBSSB', any),
        ).thenAnswer((_) async => 'invalid response');

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

    group('Passdaten', () {
      setUp(() {
        when(
          mockNetworkService.getCacheExpirationDuration(),
        ).thenReturn(const Duration(hours: 1));
      });

      test('successful passdaten fetch returns mapped response', () async {
        final rawResponse = {
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
        when(
          mockCacheService.cacheAndRetrieveData<Map<String, dynamic>>(
            'passdaten_123',
            const Duration(hours: 1),
            any,
            any,
          ),
        ).thenAnswer((invocation) async {
          final Future<Map<String, dynamic>> Function() fetchData =
              invocation.positionalArguments[2];
          when(
            mockHttpClient.get('Passdaten/123'),
          ).thenAnswer((_) async => rawResponse);
          return await fetchData();
        });

        final result = await apiService.fetchPassdaten(123);

        expect(result, rawResponse);
      });

      test('invalid passdaten response returns empty map', () async {
        when(
          mockCacheService.cacheAndRetrieveData<Map<String, dynamic>>(
            'passdaten_123',
            const Duration(hours: 1),
            any,
            any,
          ),
        ).thenAnswer((invocation) async {
          when(
            mockHttpClient.get('Passdaten/123'),
          ).thenAnswer((_) async => 'invalid response');
          return <String, dynamic>{};
        });

        final result = await apiService.fetchPassdaten(123);

        expect(result, {});
      });
    });
  });
}
