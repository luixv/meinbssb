import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:meinbssb/services/http_client.dart';
import 'package:meinbssb/services/image_service.dart';
import 'package:meinbssb/services/network_service.dart';

// Generate mocks
@GenerateMocks([HttpClient, ImageService, CacheService, NetworkService])
import 'api_service_test.mocks.dart';

void main() {
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
      // Test data
      const firstName = 'John';
      const lastName = 'Doe';
      const passNumber = '12345';
      const email = 'john.doe@example.com';
      const birthDate = '2000-01-01';
      const zipCode = '12345';

      final expectedData = {
        'firstName': firstName,
        'lastName': lastName,
        'passNumber': passNumber,
        'email': email,
        'birthDate': birthDate,
        'zipCode': zipCode,
      };

      // Mock response
      when(mockHttpClient.post('RegisterMyBSSB', expectedData))
          .thenAnswer((_) async => {'success': true});

      // Call method
      await apiService.register(
        firstName: firstName,
        lastName: lastName,
        passNumber: passNumber,
        email: email,
        birthDate: birthDate,
        zipCode: zipCode,
      );

      // Verify
      verify(mockHttpClient.post('RegisterMyBSSB', expectedData)).called(1);
    });

    test('should return response from httpClient.post', () async {
      // Test data
      const testResponse = {'success': true, 'userId': 1};

      // Mock with explicit types
      when(
        mockHttpClient.post(
          argThat(isA<String>()),
          argThat(isA<Map<String, dynamic>>()),
        ),
      ).thenAnswer((_) async => testResponse);

      // Call method
      final result = await apiService.register(
        firstName: 'test',
        lastName: 'test',
        passNumber: 'test',
        email: 'test',
        birthDate: 'test',
        zipCode: 'test',
      );

      // Verify
      expect(result, testResponse);
    });

    test('should return empty map on exception', () async {
      // Mock exception
      when(mockHttpClient.post(
        argThat(isA<String>()),
        argThat(isA<Map<String, dynamic>>()),
      ),).thenThrow(Exception('Test error'));

      // Call method
      final result = await apiService.register(
        firstName: 'test',
        lastName: 'test',
        passNumber: 'test',
        email: 'test',
        birthDate: 'test',
        zipCode: 'test',
      );

      // Verify
      expect(result, {});
    });
  });
}
