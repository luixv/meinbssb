import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/services/api_service.dart'
    as api_service_alias; // Alias to avoid conflict with the class under test
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/core/image_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/api/training_service.dart';
import 'package:meinbssb/services/api/user_service.dart';
import 'package:meinbssb/services/api/bank_service.dart';
import 'api_service_test.mocks.dart';

@GenerateMocks([
  ConfigService,
  HttpClient,
  ImageService,
  CacheService,
  NetworkService,
  FlutterSecureStorage, // Although not directly used in ApiService, often part of auth flow
  AuthService,
  TrainingService,
  UserService,
  BankService,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late api_service_alias.ApiService apiService;
  late MockConfigService mockConfigService;
  late MockHttpClient mockHttpClient;
  late MockImageService mockImageService;
  late MockCacheService mockCacheService;
  late MockNetworkService mockNetworkService;
  late MockAuthService mockAuthService;
  late MockTrainingService mockTrainingService;
  late MockUserService mockUserService;
  late MockBankService mockBankService;

  setUp(() {
    mockConfigService = MockConfigService();
    mockHttpClient = MockHttpClient();
    mockImageService = MockImageService();
    mockCacheService = MockCacheService();
    mockNetworkService = MockNetworkService();
    mockAuthService = MockAuthService();
    mockTrainingService = MockTrainingService();
    mockUserService = MockUserService();
    mockBankService = MockBankService();

    // Add this line to set a default stub for getCacheExpirationDuration
    when(mockNetworkService.getCacheExpirationDuration())
        .thenReturn(const Duration(hours: 1)); // Provide a default duration

    apiService = api_service_alias.ApiService(
      configService: mockConfigService,
      httpClient: mockHttpClient,
      imageService: mockImageService,
      cacheService: mockCacheService,
      networkService: mockNetworkService,
      authService: mockAuthService,
      trainingService: mockTrainingService,
      userService: mockUserService,
      bankService: mockBankService,
    );
  });

  group('ApiService - Network and Cache Utilities', () {
    test('hasInternet calls networkService.hasInternet', () async {
      when(mockNetworkService.hasInternet()).thenAnswer((_) async => true);
      final result = await apiService.hasInternet();
      expect(result, true);
      verify(mockNetworkService.hasInternet()).called(1);
    });

    test(
        'getCacheExpirationDuration calls networkService.getCacheExpirationDuration',
        () {
      const duration = Duration(hours: 2);
      when(mockNetworkService.getCacheExpirationDuration())
          .thenReturn(duration);
      final result = apiService.getCacheExpirationDuration();
      expect(result, duration);
      verify(mockNetworkService.getCacheExpirationDuration()).called(1);
    });
  });

  group('ApiService - AuthService Delegation', () {
    test('register calls authService.register', () async {
      when(
        mockAuthService.register(
          firstName: anyNamed('firstName'),
          lastName: anyNamed('lastName'),
          passNumber: anyNamed('passNumber'),
          email: anyNamed('email'),
          birthDate: anyNamed('birthDate'),
          zipCode: anyNamed('zipCode'),
        ),
      ).thenAnswer((_) async => {'ResultType': 1});

      await apiService.register(
        firstName: 'John',
        lastName: 'Doe',
        passNumber: '12345678',
        email: 'john.doe@example.com',
        birthDate: '2000-01-01',
        zipCode: '12345',
      );

      verify(
        mockAuthService.register(
          firstName: 'John',
          lastName: 'Doe',
          passNumber: '12345678',
          email: 'john.doe@example.com',
          birthDate: '2000-01-01',
          zipCode: '12345',
        ),
      ).called(1);
    });

    test('login calls authService.login on success', () async {
      when(mockAuthService.login('testuser', 'testpass'))
          .thenAnswer((_) async => {'ResultType': 1, 'Token': 'abc'});

      final result = await apiService.login('testuser', 'testpass');

      expect(result, {'ResultType': 1, 'Token': 'abc'});
      verify(mockAuthService.login('testuser', 'testpass')).called(1);
    });

    test('login handles NetworkException from authService.login', () async {
      when(mockAuthService.login('testuser', 'wrongpass'))
          .thenThrow(api_service_alias.NetworkException('Network error'));

      final result = await apiService.login('testuser', 'wrongpass');

      expect(result['ResultType'], 0);
      expect(result['ResultMessage'], 'Benutzername oder Passwort ist falsch');
      verify(mockAuthService.login('testuser', 'wrongpass')).called(1);
    });

    test('login handles generic Exception from authService.login', () async {
      when(mockAuthService.login('testuser', 'anotherwrongpass'))
          .thenThrow(Exception('Some other error'));

      final result = await apiService.login('testuser', 'anotherwrongpass');

      expect(result['ResultType'], 0);
      expect(result['ResultMessage'], 'Benutzername oder Passwort ist falsch');
      verify(mockAuthService.login('testuser', 'anotherwrongpass')).called(1);
    });

    test('resetPassword calls authService.resetPassword', () async {
      when(mockAuthService.resetPassword('12345678'))
          .thenAnswer((_) async => {'ResultType': 1});

      final result = await apiService.resetPassword('12345678');

      expect(result, {'ResultType': 1});
      verify(mockAuthService.resetPassword('12345678')).called(1);
    });
  });

  group('ApiService - UserService Delegation', () {
    const int testPersonId = 123;
    const Map<String, dynamic> testPassdatenResponse = {'VORNAME': 'Test'};
    final List<dynamic> testPassdatenZVEResponse = [
      {'ZVEID': 'ZVE123'},
    ];
    final List<dynamic> testZweitmitgliedschaftenResponse = [
      {'ID': 1, 'Name': 'Club A'},
    ];
    final List<Map<String, dynamic>> testKontakteResponse = [
      {'KontaktId': 1, 'Typ': 1, 'Wert': 'test@example.com'},
    ];

    test('fetchPassdaten calls userService.fetchPassdaten with personId',
        () async {
      when(mockUserService.fetchPassdaten(testPersonId))
          .thenAnswer((_) async => testPassdatenResponse);

      final result = await apiService.fetchPassdaten(testPersonId);

      expect(result, testPassdatenResponse);
      verify(mockUserService.fetchPassdaten(testPersonId)).called(1);
    });

    test(
        'fetchPassdatenZVE calls userService.fetchPassdatenZVE with passdatenId and personId',
        () async {
      const int testPassdatenId = 456;
      when(mockUserService.fetchPassdatenZVE(testPassdatenId, testPersonId))
          .thenAnswer((_) async => testPassdatenZVEResponse);

      final result =
          await apiService.fetchPassdatenZVE(testPassdatenId, testPersonId);

      expect(result, testPassdatenZVEResponse);
      verify(mockUserService.fetchPassdatenZVE(testPassdatenId, testPersonId))
          .called(1);
    });

    test(
        'updateKritischeFelderUndAdresse calls userService.updateKritischeFelderUndAdresse',
        () async {
      when(
        mockUserService.updateKritischeFelderUndAdresse(
          any,
          any,
          any,
          any,
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((_) async => true);

      final result = await apiService.updateKritischeFelderUndAdresse(
        testPersonId,
        'Dr.',
        'Doe',
        'John',
        1,
        'Main St',
        '12345',
        'City',
      );

      expect(result, true);
      verify(
        mockUserService.updateKritischeFelderUndAdresse(
          testPersonId,
          'Dr.',
          'Doe',
          'John',
          1,
          'Main St',
          '12345',
          'City',
        ),
      ).called(1);
    });

    test(
        'fetchZweitmitgliedschaften calls userService.fetchZweitmitgliedschaften',
        () async {
      when(mockUserService.fetchZweitmitgliedschaften(testPersonId))
          .thenAnswer((_) async => testZweitmitgliedschaftenResponse);

      final result = await apiService.fetchZweitmitgliedschaften(testPersonId);

      expect(result, testZweitmitgliedschaftenResponse);
      verify(mockUserService.fetchZweitmitgliedschaften(testPersonId))
          .called(1);
    });

    test('fetchKontakte calls userService.fetchKontakte', () async {
      when(mockUserService.fetchKontakte(testPersonId))
          .thenAnswer((_) async => testKontakteResponse);

      final result = await apiService.fetchKontakte(testPersonId);

      expect(result, testKontakteResponse);
      verify(mockUserService.fetchKontakte(testPersonId)).called(1);
    });

    test('addKontakt calls userService.addKontakt', () async {
      when(mockUserService.addKontakt(testPersonId, 1, 'new@example.com'))
          .thenAnswer((_) async => true);

      final result =
          await apiService.addKontakt(testPersonId, 1, 'new@example.com');

      expect(result, true);
      verify(mockUserService.addKontakt(testPersonId, 1, 'new@example.com'))
          .called(1);
    });

    test('deleteKontakt calls userService.deleteKontakt', () async {
      when(mockUserService.deleteKontakt(testPersonId, 1, 1))
          .thenAnswer((_) async => true);

      final result = await apiService.deleteKontakt(testPersonId, 1, 1);

      expect(result, true);
      verify(mockUserService.deleteKontakt(testPersonId, 1, 1)).called(1);
    });
  });

  group('ApiService - ImageService Delegation', () {
    const int testPersonId = 123;
    final Uint8List testImageData = Uint8List.fromList([1, 2, 3, 4]);

    test(
        'fetchSchuetzenausweis calls imageService.fetchAndCacheSchuetzenausweis',
        () async {
      when(
        mockImageService.fetchAndCacheSchuetzenausweis(
          testPersonId,
          any, // fetchData function
          any, // validityDuration
        ),
      ).thenAnswer((_) async => testImageData);

      final result = await apiService.fetchSchuetzenausweis(testPersonId);

      expect(result, testImageData);
      verify(
        mockImageService.fetchAndCacheSchuetzenausweis(
          testPersonId,
          any,
          any,
        ),
      ).called(1);
    });
  });

  group('ApiService - TrainingService Delegation', () {
    const int testPersonId = 123;
    const String testAbDatum = '2023-01-01';
    const int testSchulungId = 456;
    const int testSchulungenTeilnehmerID = 789;

    // Updated to List<Map<String, dynamic>>
    final List<Map<String, dynamic>> testSchulungenList = [
      {'BEZEICHNUNG': 'Schulung A', 'ONLINE': true},
    ];
    // Updated to List<Map<String, dynamic>>
    final List<Map<String, dynamic>> testSchulungsartenList = [
      {'BEZEICHNUNG': 'Art A', 'ONLINE': true},
    ];

    test(
        'fetchAbsolvierteSchulungen calls trainingService.fetchAbsolvierteSchulungen',
        () async {
      when(mockTrainingService.fetchAbsolvierteSchulungen(testPersonId))
          .thenAnswer((_) async => testSchulungenList);

      final result = await apiService.fetchAbsolvierteSeminare(testPersonId);

      expect(result, testSchulungenList);
      verify(mockTrainingService.fetchAbsolvierteSchulungen(testPersonId))
          .called(1);
    });

    test('fetchSchulungsarten calls trainingService.fetchSchulungsarten',
        () async {
      when(mockTrainingService.fetchSchulungsarten())
          .thenAnswer((_) async => testSchulungsartenList);

      final result = await apiService.fetchSchulungsarten();

      expect(result, testSchulungsartenList);
      verify(mockTrainingService.fetchSchulungsarten()).called(1);
    });

    test(
        'fetchAngemeldeteSchulungen calls trainingService.fetchAngemeldeteSchulungen',
        () async {
      when(
        mockTrainingService.fetchAngemeldeteSchulungen(
          testPersonId,
          testAbDatum,
        ),
      ).thenAnswer((_) async => testSchulungenList);

      final result = await apiService.fetchAngemeldeteSchulungen(
        testPersonId,
        testAbDatum,
      );

      expect(result, testSchulungenList);
      verify(
        mockTrainingService.fetchAngemeldeteSchulungen(
          testPersonId,
          testAbDatum,
        ),
      ).called(1);
    });

    test(
        'fetchAvailableSchulungen calls trainingService.fetchAvailableSchulungen',
        () async {
      when(mockTrainingService.fetchAvailableSchulungen())
          .thenAnswer((_) async => testSchulungenList);

      final result = await apiService.fetchAvailableSchulungen();

      expect(result, testSchulungenList);
      verify(mockTrainingService.fetchAvailableSchulungen()).called(1);
    });

    test('unregisterFromSchulung calls trainingService.unregisterFromSchulung',
        () async {
      when(
        mockTrainingService.unregisterFromSchulung(testSchulungenTeilnehmerID),
      ).thenAnswer((_) async => true);

      final result =
          await apiService.unregisterFromSchulung(testSchulungenTeilnehmerID);

      expect(result, true);
      verify(
        mockTrainingService.unregisterFromSchulung(testSchulungenTeilnehmerID),
      ).called(1);
    });

    test('registerFromSchulung calls trainingService.registerForSchulung',
        () async {
      when(
        mockTrainingService.registerForSchulung(
          testPersonId,
          testSchulungId,
        ),
      ).thenAnswer((_) async => true);

      final result =
          await apiService.registerFromSchulung(testPersonId, testSchulungId);

      expect(result, true);
      verify(
        mockTrainingService.registerForSchulung(
          testPersonId,
          testSchulungId,
        ),
      ).called(1);
    });
  });

  group('ApiService - BankService Delegation', () {
    const int testWebloginId = 987;
    final Map<String, dynamic> testBankDatenResponse = {
      'IBAN': 'DE123',
      'ONLINE': true,
    };

    test('fetchBankdaten calls bankService.fetchBankdaten', () async {
      when(mockBankService.fetchBankdaten(testWebloginId))
          .thenAnswer((_) async => testBankDatenResponse);

      final result = await apiService.fetchBankdaten(testWebloginId);

      expect(result, testBankDatenResponse);
      verify(mockBankService.fetchBankdaten(testWebloginId)).called(1);
    });

    test('registerBankdaten calls bankService.registerBankdaten', () async {
      when(
        mockBankService.registerBankdaten(
          testWebloginId,
          'Holder Name',
          'DE12345',
          'BICXYZ',
        ),
      ).thenAnswer((_) async => {'BankdatenWebID': 1});

      final result = await apiService.registerBankdaten(
        testWebloginId,
        'Holder Name',
        'DE12345',
        'BICXYZ',
      );

      expect(result, {'BankdatenWebID': 1});
      verify(
        mockBankService.registerBankdaten(
          testWebloginId,
          'Holder Name',
          'DE12345',
          'BICXYZ',
        ),
      ).called(1);
    });

    test('deleteBankdaten calls bankService.deleteBankdaten', () async {
      when(mockBankService.deleteBankdaten(testWebloginId))
          .thenAnswer((_) async => true);

      final result = await apiService.deleteBankdaten(testWebloginId);

      expect(result, true);
      verify(mockBankService.deleteBankdaten(testWebloginId)).called(1);
    });
  });
}
