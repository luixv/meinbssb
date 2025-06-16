import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/bank_data.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/services/core/image_service.dart';
import 'package:meinbssb/services/api/user_service.dart';
import 'package:meinbssb/services/api/training_service.dart';
import 'package:meinbssb/services/api/bank_service.dart';
import 'package:meinbssb/services/api/verein_service.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/core/token_service.dart';

@GenerateMocks([
  AuthService,
  ConfigService,
  CacheService,
  NetworkService,
  ImageService,
  UserService,
  TrainingService,
  BankService,
  VereinService,
  TokenService,
])
import 'api_service_test.mocks.dart';

void main() {
  late ApiService apiService;
  late MockAuthService mockAuthService;
  late MockConfigService mockConfigService;
  late MockCacheService mockCacheService;
  late MockNetworkService mockNetworkService;
  late MockImageService mockImageService;
  late MockUserService mockUserService;
  late MockTrainingService mockTrainingService;
  late MockBankService mockBankService;
  late MockVereinService mockVereinService;
  late MockTokenService mockTokenService;
  late HttpClient httpClient;

  setUp(() {
    mockAuthService = MockAuthService();
    mockConfigService = MockConfigService();
    mockCacheService = MockCacheService();
    mockNetworkService = MockNetworkService();
    mockImageService = MockImageService();
    mockUserService = MockUserService();
    mockTrainingService = MockTrainingService();
    mockBankService = MockBankService();
    mockVereinService = MockVereinService();
    mockTokenService = MockTokenService();

    httpClient = HttpClient(
      baseUrl: 'http://test.com',
      serverTimeout: 30,
      tokenService: mockTokenService,
      configService: mockConfigService,
      cacheService: mockCacheService,
    );

    apiService = ApiService(
      authService: mockAuthService,
      configService: mockConfigService,
      cacheService: mockCacheService,
      networkService: mockNetworkService,
      imageService: mockImageService,
      userService: mockUserService,
      trainingService: mockTrainingService,
      bankService: mockBankService,
      vereinService: mockVereinService,
      httpClient: httpClient,
    );
  });

  group('ApiService', () {
    group('User Data Tests', () {
      test('fetchPassdaten returns UserData on successful API call', () async {
        const testUserData = UserData(
          personId: 439287,
          webLoginId: 13901,
          passnummer: '40100709',
          vereinNr: 401051,
          namen: 'Schürz',
          vorname: 'Lukas',
          vereinName: 'Feuerschützen Kühbach',
          passdatenId: 2000009155,
          mitgliedschaftId: 439287,
          strasse: 'Aichacher Strasse 21',
          plz: '86574',
          ort: 'Alsmoos',
        );

        when(mockUserService.fetchPassdaten(any))
            .thenAnswer((_) async => testUserData);

        final result = await apiService.fetchPassdaten(439287);
        expect(result, equals(testUserData));
        verify(mockUserService.fetchPassdaten(439287)).called(1);
      });

      test('fetchPassdaten throws exception on API error', () async {
        when(mockUserService.fetchPassdaten(any))
            .thenThrow(Exception('API error'));

        expect(() => apiService.fetchPassdaten(439287), throwsException);
        verify(mockUserService.fetchPassdaten(439287)).called(1);
      });
    });

    group('Schuetzenausweis Tests', () {
      test('fetchSchuetzenausweis returns Uint8List on successful API call',
          () async {
        final testData = Uint8List.fromList([1, 2, 3]);
        when(mockNetworkService.getCacheExpirationDuration())
            .thenReturn(const Duration(hours: 1));
        when(
          mockImageService.fetchAndCacheSchuetzenausweis(
            any,
            any,
            any,
          ),
        ).thenAnswer((_) async => testData);

        final result = await apiService.fetchSchuetzenausweis(439287);
        expect(result, equals(testData));
        verify(
          mockImageService.fetchAndCacheSchuetzenausweis(
            439287,
            any,
            any,
          ),
        ).called(1);
      });

      test('fetchSchuetzenausweis throws exception on API error', () async {
        when(mockNetworkService.getCacheExpirationDuration())
            .thenReturn(const Duration(hours: 1));
        when(
          mockImageService.fetchAndCacheSchuetzenausweis(
            any,
            any,
            any,
          ),
        ).thenThrow(Exception('API error'));

        expect(() => apiService.fetchSchuetzenausweis(439287), throwsException);
        verify(
          mockImageService.fetchAndCacheSchuetzenausweis(
            439287,
            any,
            any,
          ),
        ).called(1);
      });
    });

    group('Bank Service Tests', () {
      test('fetchBankData returns list of BankData on successful API call',
          () async {
        final testBankData = [
          BankData(
            id: 1,
            webloginId: 13901,
            kontoinhaber: 'Test User',
            iban: 'DE89370400440532013000',
            bic: 'DEUTDEBBXXX',
            bankName: 'Test Bank',
            mandatNr: 'M123456',
            mandatName: 'Test Mandate',
            mandatSeq: 1,
            letzteNutzung: DateTime.now(),
          ),
        ];

        when(mockBankService.fetchBankData(any))
            .thenAnswer((_) async => testBankData);

        final result = await apiService.fetchBankData(13901);
        expect(result, equals(testBankData));
        verify(mockBankService.fetchBankData(13901)).called(1);
      });

      test('fetchBankData throws exception on API error', () async {
        when(mockBankService.fetchBankData(any))
            .thenThrow(Exception('API error'));

        expect(() => apiService.fetchBankData(13901), throwsException);
        verify(mockBankService.fetchBankData(13901)).called(1);
      });

      test('registerBankData returns true on successful registration',
          () async {
        final testBankData = BankData(
          id: 1,
          webloginId: 13901,
          kontoinhaber: 'Test User',
          iban: 'DE89370400440532013000',
          bic: 'DEUTDEBBXXX',
          bankName: 'Test Bank',
          mandatNr: 'M123456',
          mandatName: 'Test Mandate',
          mandatSeq: 1,
          letzteNutzung: DateTime.now(),
        );

        when(mockBankService.registerBankData(any))
            .thenAnswer((_) async => true);

        final result = await apiService.registerBankData(testBankData);
        expect(result, isTrue);
        verify(mockBankService.registerBankData(testBankData)).called(1);
      });

      test('registerBankData throws exception on API error', () async {
        final testBankData = BankData(
          id: 1,
          webloginId: 13901,
          kontoinhaber: 'Test User',
          iban: 'DE89370400440532013000',
          bic: 'DEUTDEBBXXX',
          bankName: 'Test Bank',
          mandatNr: 'M123456',
          mandatName: 'Test Mandate',
          mandatSeq: 1,
          letzteNutzung: DateTime.now(),
        );

        when(mockBankService.registerBankData(any))
            .thenThrow(Exception('API error'));

        expect(
          () => apiService.registerBankData(testBankData),
          throwsException,
        );
        verify(mockBankService.registerBankData(testBankData)).called(1);
      });

      test('deleteBankData returns true on successful deletion', () async {
        final testBankData = BankData(
          id: 1,
          webloginId: 13901,
          kontoinhaber: 'Test User',
          iban: 'DE89370400440532013000',
          bic: 'DEUTDEBBXXX',
          bankName: 'Test Bank',
          mandatNr: 'M123456',
          mandatName: 'Test Mandate',
          mandatSeq: 1,
          letzteNutzung: DateTime.now(),
        );

        when(mockBankService.deleteBankData(any)).thenAnswer((_) async => true);

        final result = await apiService.deleteBankData(testBankData);
        expect(result, isTrue);
        verify(mockBankService.deleteBankData(testBankData)).called(1);
      });

      test('deleteBankData throws exception on API error', () async {
        final testBankData = BankData(
          id: 1,
          webloginId: 13901,
          kontoinhaber: 'Test User',
          iban: 'DE89370400440532013000',
          bic: 'DEUTDEBBXXX',
          bankName: 'Test Bank',
          mandatNr: 'M123456',
          mandatName: 'Test Mandate',
          mandatSeq: 1,
          letzteNutzung: DateTime.now(),
        );

        when(mockBankService.deleteBankData(any))
            .thenThrow(Exception('API error'));

        expect(() => apiService.deleteBankData(testBankData), throwsException);
        verify(mockBankService.deleteBankData(testBankData)).called(1);
      });
    });
  });
}
