import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/core/image_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/api/training_service.dart';
import 'package:meinbssb/services/api/user_service.dart';
import 'package:meinbssb/services/api/bank_service.dart';
import 'package:meinbssb/services/api/verein_service.dart';
import 'package:meinbssb/services/api/oktoberfest_service.dart';

import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/services/core/postgrest_service.dart';
import 'package:meinbssb/services/core/email_service.dart';
import 'package:meinbssb/services/core/calendar_service.dart';
import 'package:meinbssb/exceptions/network_exception.dart' as network_ex;

import 'login_service_test.mocks.dart';

@GenerateMocks([
  HttpClient,
  ImageService,
  CacheService,
  NetworkService,
  FlutterSecureStorage,
  AuthService,
  ConfigService,
  TrainingService,
  UserService,
  BankService,
  VereinService,
  PostgrestService,
  EmailService,
  OktoberfestService,
  CalendarService,
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
  late MockAuthService mockAuthService;
  late MockTrainingService mockTrainingService;
  late MockUserService mockUserService;
  late MockBankService mockBankService;
  late MockVereinService mockVereinService;
  late MockPostgrestService mockPostgrestService;
  late MockEmailService mockEmailService;
  late MockOktoberfestService mockOktoberfestService;
  late MockCalendarService mockCalendarService;

  const int testWebLoginId = 27;
  const int testPersonId = 4711;

  setUp(() {
    mockConfigService = MockConfigService();
    mockHttpClient = MockHttpClient();
    mockImageService = MockImageService();
    mockCacheService = MockCacheService();
    mockNetworkService = MockNetworkService();
    mockSecureStorage = MockFlutterSecureStorage();
    mockAuthService = MockAuthService();
    mockTrainingService = MockTrainingService();
    mockUserService = MockUserService();
    mockBankService = MockBankService();
    mockVereinService = MockVereinService();
    mockPostgrestService = MockPostgrestService();
    mockEmailService = MockEmailService();
    mockOktoberfestService = MockOktoberfestService();

    mockCalendarService = MockCalendarService();

    apiService = ApiService(
      configService: mockConfigService,
      httpClient: mockHttpClient,
      imageService: mockImageService,
      cacheService: mockCacheService,
      networkService: mockNetworkService,
      authService: mockAuthService,
      trainingService: mockTrainingService,
      userService: mockUserService,
      bankService: mockBankService,
      vereinService: mockVereinService,
      postgrestService: mockPostgrestService,
      emailService: mockEmailService,
      oktoberfestService: mockOktoberfestService,
      calendarService: mockCalendarService,
    );
  });

  group('Login Functionality', () {
    const String testUsername = 'testuser';
    const String testPassword = 'testpassword';
    const Map<String, dynamic> successfulLoginResponse = {
      'ResultType': 1,
      'ResultMessage': 'MyBSSB Login Erfolgreich',
      'PersonID': testPersonId,
      'WebLoginID': testWebLoginId,
    };
    const Map<String, dynamic> failedLoginResponse = {
      'ResultType': 0,
      'ResultMessage': 'Invalid credentials',
    };
    const Map<String, dynamic> networkErrorResponse = {
      'ResultType': 0,
      'ResultMessage': 'Benutzername oder Passwort ist falsch',
    };

    test('should call authService.login with correct credentials', () async {
      when(mockAuthService.login(testUsername, testPassword))
          .thenAnswer((_) async => successfulLoginResponse);

      await apiService.login(testUsername, testPassword);

      verify(mockAuthService.login(testUsername, testPassword)).called(1);
      verifyNever(mockHttpClient.post(any, any));
    });

    test('should return the failed login response on failed login', () async {
      when(mockAuthService.login(testUsername, testPassword))
          .thenAnswer((_) async => failedLoginResponse);

      final result = await apiService.login(testUsername, testPassword);

      expect(result, failedLoginResponse);
      verifyNever(
        mockSecureStorage.write(
          key: anyNamed('key'),
          value: anyNamed('value'),
        ),
      );
    });

    test('should handle network errors during login', () async {
      when(mockAuthService.login(testUsername, testPassword))
          .thenThrow(network_ex.NetworkException());

      final result = await apiService.login(testUsername, testPassword);

      expect(result, networkErrorResponse);
      verifyNever(
        mockSecureStorage.write(
          key: anyNamed('key'),
          value: anyNamed('value'),
        ),
      );
    });
  });
}
