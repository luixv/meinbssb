import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/config_service.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:meinbssb/services/http_client.dart';
import 'package:meinbssb/services/image_service.dart';
import 'package:meinbssb/services/network_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/api/training_service.dart';
import 'package:meinbssb/services/api/user_service.dart';
import 'api_service_test.mocks.dart';

@GenerateMocks([
  ConfigService,
  HttpClient,
  ImageService,
  CacheService,
  NetworkService,
  FlutterSecureStorage,
  AuthService,
  TrainingService,
  UserService,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ApiService apiService;
  late MockHttpClient mockHttpClient;
  late MockImageService mockImageService;
  late MockCacheService mockCacheService;
  late MockNetworkService mockNetworkService;
  late MockConfigService mockConfigService;
  late MockAuthService mockAuthService;
  late MockTrainingService mockTrainingService;
  late MockUserService mockUserService;

  setUp(() {
    mockConfigService = MockConfigService();
    mockHttpClient = MockHttpClient();
    mockImageService = MockImageService();
    mockCacheService = MockCacheService();
    mockNetworkService = MockNetworkService();
    mockAuthService = MockAuthService();
    mockTrainingService = MockTrainingService();
    mockUserService = MockUserService();

    apiService = ApiService(
      configService: mockConfigService,
      httpClient: mockHttpClient,
      imageService: mockImageService,
      cacheService: mockCacheService,
      networkService: mockNetworkService,
      authService: mockAuthService,
      trainingService: mockTrainingService,
      userService: mockUserService,
    );
  });

  group('ApiService - register', () {
    // ... (rest of your register tests - no changes needed here)
  });

  group('ApiService - login', () {
    // ... (rest of your login tests - no changes needed here)
  });

  group('ApiService - resetPassword', () {
    // ... (rest of your resetPassword tests - no changes needed here)
  });

  group('ApiService - fetchPassdaten', () {
    const int testPersonId = 123;
    const Map<String, dynamic> testResponse = {'VORNAME': 'Test'};

    test('calls userService.fetchPassdaten with personId', () async {
      when(mockUserService.fetchPassdaten(testPersonId))
          .thenAnswer((_) async => testResponse);

      await apiService.fetchPassdaten(testPersonId);

      verify(mockUserService.fetchPassdaten(testPersonId)).called(1);
    });

    test('returns the response from userService.fetchPassdaten', () async {
      when(mockUserService.fetchPassdaten(testPersonId))
          .thenAnswer((_) async => testResponse);

      final result = await apiService.fetchPassdaten(testPersonId);

      expect(result, testResponse);
    });
  });

  group('ApiService - fetchSchuetzenausweis', () {
    // ... (rest of your fetchSchuetzenausweis tests - no changes needed here)
  });

  group('ApiService - fetchAngemeldeteSchulungen', () {
    // ... (rest of your fetchAngemeldeteSchulungen tests - no changes needed here)
  });

  group('ApiService - fetchZweitmitgliedschaften', () {
    // ... (rest of your fetchZweitmitgliedschaften tests - no changes needed here)
  });

  group('ApiService - fetchPassdatenZVE', () {
    const int testPassdatenId = 456;
    const int testPersonId = 123;
    final List<dynamic> testResponse = [
      {'ZVEID': 'ZVE123'},
    ];

    test('calls userService.fetchPassdatenZVE with passdatenId and personId',
        () async {
      when(mockUserService.fetchPassdatenZVE(testPassdatenId, testPersonId))
          .thenAnswer((_) async => testResponse);

      await apiService.fetchPassdatenZVE(testPassdatenId, testPersonId);

      verify(mockUserService.fetchPassdatenZVE(testPassdatenId, testPersonId))
          .called(1);
    });

    test('returns the response from userService.fetchPassdatenZVE', () async {
      when(mockUserService.fetchPassdatenZVE(testPassdatenId, testPersonId))
          .thenAnswer((_) async => testResponse);

      final result =
          await apiService.fetchPassdatenZVE(testPassdatenId, testPersonId);

      expect(result, testResponse);
    });
  });
}
