import 'dart:typed_data';

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

  const String testBaseIp = 'test.com';
  const String testPort = '8080';
  const int testServerTimeout = 5;

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockImageService = MockImageService();
    mockCacheService = MockCacheService();
    mockNetworkService = MockNetworkService();

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

  group('ApiService - fetchPassdatenZVE', () {
    test('should call cacheAndRetrieveData with correct parameters', () async {
      const personId = 123;
      const passdatenId = 456; // Add the missing passdatenId
      final mockResponse = {
        'ZVEID': 'ZVE123',
        'Lizenznummer': 'L456',
      };

      when(mockNetworkService.getCacheExpirationDuration())
          .thenReturn(const Duration(days: 30));
      when(
        mockCacheService.cacheAndRetrieveData<List<dynamic>>(
          // Note the List<dynamic> here, based on the _map...Response
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer(
        (_) async => [mockResponse],
      ); // Mocking a List containing the map

      final result = await apiService.fetchPassdatenZVE(
        passdatenId,
        personId,
      ); // Pass both arguments

      expect(result, [mockResponse]); // Expect a List containing the map
      verify(
        mockCacheService.cacheAndRetrieveData<List<dynamic>>(
          'passdatenzve_${passdatenId}_$personId',
          any,
          any,
          any,
        ),
      ).called(1);
    });
  });

  group('ApiService - fetchAngemeldeteSchulungen', () {
    test('should call cacheAndRetrieveData with correct parameters', () async {
      const personId = 123;
      const abDatum = '2025-01-01';
      final mockResponse = [
        {'Titel': 'Schulung 1', 'Datum': '2025-06-01'},
        {'Titel': 'Schulung 2', 'Datum': '2025-07-15'},
      ];

      when(mockNetworkService.getCacheExpirationDuration())
          .thenReturn(const Duration(hours: 12));
      when(
        mockCacheService.cacheAndRetrieveData<List<dynamic>>(
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((_) async => mockResponse);

      final result =
          await apiService.fetchAngemeldeteSchulungen(personId, abDatum);

      expect(result, mockResponse);
      verify(
        mockCacheService.cacheAndRetrieveData<List<dynamic>>(
          'schulungen_$personId',
          any,
          any,
          any,
        ),
      ).called(1);
    });
  });

  group('ApiService - fetchZweitmitgliedschaften', () {
    test('should call cacheAndRetrieveData with correct parameters', () async {
      const personId = 123;
      final mockResponse = [
        {'Verein': 'Verein A', 'Sektion': 'Bogen'},
        {'Verein': 'Verein C', 'Sektion': 'Gewehr'},
      ];

      when(mockNetworkService.getCacheExpirationDuration())
          .thenReturn(const Duration(days: 7));
      when(
        mockCacheService.cacheAndRetrieveData<List<dynamic>>(
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await apiService.fetchZweitmitgliedschaften(personId);

      expect(result, mockResponse);
      verify(
        mockCacheService.cacheAndRetrieveData<List<dynamic>>(
          'zweitmitgliedschaften_$personId',
          any,
          any,
          any,
        ),
      ).called(1);
    });
  });

  group('ApiService - fetchPassdatenZVE', () {
    test('should call cacheAndRetrieveData with correct parameters', () async {
      const personId = 123;
      const passdatenId = 456;
      final mockResponse = {
        'ZVEID': 'ZVE123',
        'Lizenznummer': 'L456',
      };

      when(mockNetworkService.getCacheExpirationDuration())
          .thenReturn(const Duration(days: 30));
      when(
        mockCacheService.cacheAndRetrieveData<List<dynamic>>(
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((_) async => [mockResponse]);

      final result = await apiService.fetchPassdatenZVE(passdatenId, personId);

      expect(result, [mockResponse]);
      verify(
        mockCacheService.cacheAndRetrieveData<List<dynamic>>(
          'passdatenzve_${passdatenId}_$personId',
          any,
          any,
          any,
        ),
      ).called(1);
    });
  });

  group('ApiService - fetchSchuetzenausweis', () {
    const int personId = 789;
    final Uint8List mockImageData = Uint8List.fromList([1, 2, 3]);
    final Uint8List mockRotatedImageData = Uint8List.fromList([3, 2, 1]);
    const Duration cacheDuration = Duration(minutes: 30);

    setUp(() {
      // Clear previous interactions
      reset(mockImageService);
      reset(mockHttpClient);

      when(mockNetworkService.getCacheExpirationDuration())
          .thenReturn(cacheDuration);
    });

    test('should return cached image if available', () async {
      // Mock setup with explicit type casting
      when(mockImageService.getCachedSchuetzenausweis(any, any))
          .thenAnswer((_) => Future<Uint8List?>.value(mockImageData));

      when(mockImageService.rotatedImage(any))
          .thenAnswer((_) async => mockRotatedImageData);

      final result = await apiService.fetchSchuetzenausweis(personId);

      expect(result, mockRotatedImageData);
      verify(
        mockImageService.getCachedSchuetzenausweis(personId, cacheDuration),
      );
      verify(mockImageService.rotatedImage(mockImageData));
      verifyNever(mockHttpClient.getBytes(any));
    });

    test('should fetch from network when no cached image', () async {
      // Explicit null return with proper type
      when(mockImageService.getCachedSchuetzenausweis(any, any))
          .thenAnswer((_) => Future<Uint8List?>.value(null));
      when(mockHttpClient.getBytes(any))
          .thenAnswer((_) => Future.value(mockImageData));
      when(mockImageService.rotatedImage(any))
          .thenAnswer((_) async => mockRotatedImageData);
      when(mockImageService.cacheSchuetzenausweis(any, any, any))
          .thenAnswer((_) => Future.value());

      final result = await apiService.fetchSchuetzenausweis(personId);

      expect(result, mockRotatedImageData);
      verify(mockHttpClient.getBytes('Schuetzenausweis/JPG/$personId'));
      verify(
        mockImageService.cacheSchuetzenausweis(
          personId,
          mockImageData,
          any,
        ),
      );
    });

    test('should handle network errors', () async {
      when(mockImageService.getCachedSchuetzenausweis(any, any))
          .thenAnswer((_) => Future<Uint8List?>.value(null));
      when(mockHttpClient.getBytes(any))
          .thenThrow(http.ClientException('Network error'));

      expect(
        () => apiService.fetchSchuetzenausweis(personId),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
