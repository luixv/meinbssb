// test/unit/services/cache_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:meinbssb/services/config_service.dart';

// Generate the mock for ConfigService
@GenerateNiceMocks([MockSpec<ConfigService>()])
import 'cache_service_test.mocks.dart';

void main() {
  late CacheService cacheService;
  late SharedPreferences prefs;
  late MockConfigService mockConfigService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    mockConfigService = MockConfigService();
    cacheService = CacheService(
      prefs: prefs,
      configService: mockConfigService,
    );
  });

  group('CacheService - Basic Operations', () {
    test('setString and getString', () async {
      await cacheService.setString('testKey', 'testValue');
      final result = await cacheService.getString('testKey');
      expect(result, 'testValue');
    });

    test('setJson and getJson', () async {
      final testJson = {'key': 'value'};
      await cacheService.setJson('testKey', testJson);
      final result = await cacheService.getJson('testKey');
      expect(result, testJson);
    });

    test('setInt and getInt', () async {
      await cacheService.setInt('testKey', 42);
      final result = await cacheService.getInt('testKey');
      expect(result, 42);
    });

    test('setBool and getBool', () async {
      await cacheService.setBool('testKey', true);
      final result = await cacheService.getBool('testKey');
      expect(result, true);
    });

    test('remove', () async {
      await cacheService.setString('testKey', 'testValue');
      await cacheService.remove('testKey');
      final result = await cacheService.getString('testKey');
      expect(result, null);
    });

    test('clear', () async {
      await cacheService.setString('testKey1', 'value1');
      await cacheService.setString('testKey2', 'value2');
      await cacheService.clear();
      expect(await cacheService.getString('testKey1'), null);
      expect(await cacheService.getString('testKey2'), null);
    });

    test('containsKey', () async {
      await cacheService.setString('testKey', 'testValue');
      expect(await cacheService.containsKey('testKey'), true);
      expect(await cacheService.containsKey('nonExistentKey'), false);
    });
  });

  group('CacheService - Cache Timestamp', () {
    test('setCacheTimestamp', () async {
      final beforeTimestamp = DateTime.now().millisecondsSinceEpoch;
      await cacheService.setCacheTimestamp();
      final timestamp = await cacheService.getInt('cacheTimestamp');
      final afterTimestamp = DateTime.now().millisecondsSinceEpoch;

      expect(timestamp, isNotNull);
      expect(timestamp! >= beforeTimestamp, true);
      expect(timestamp <= afterTimestamp, true);
    });
  });

  group('CacheService - Complex Operations', () {
    test('cacheAndRetrieveData - fresh data', () async {
      final testData = {'test': 'data'};
      when(mockConfigService.getInt('cacheExpirationHours')).thenReturn(24);

      final result =
          await cacheService.cacheAndRetrieveData<Map<String, dynamic>>(
        'testKey',
        const Duration(hours: 1),
        () async => testData,
        (response) => response as Map<String, dynamic>,
      );

      expect(result['data'], testData); // Corrected line
      final cachedData = await cacheService.getJson('testKey');
      expect(cachedData, testData);
    });

    test('cacheAndRetrieveData - expired cache', () async {
      final testData = {'test': 'data'};
      final newData = {'test': 'newData'};

      when(mockConfigService.getInt('cacheExpirationHours'))
          .thenReturn(0); // Immediate expiration

      // Cache initial data
      await cacheService.setJson('testKey', testData);
      await cacheService.setCacheTimestamp();

      // Wait a moment to ensure cache expires
      await Future.delayed(const Duration(milliseconds: 100));

      final result =
          await cacheService.cacheAndRetrieveData<Map<String, dynamic>>(
        'testKey',
        const Duration(hours: 1),
        () async => newData,
        (response) => response as Map<String, dynamic>,
      );

      expect(result['data'], newData); // Corrected line
    });

    test('cacheAndRetrieveData - fetch failure fallback to cache', () async {
      final testData = {'test': 'data'};

      when(mockConfigService.getInt('cacheExpirationHours')).thenReturn(24);

      // Cache initial data
      await cacheService.setJson('testKey', testData);
      await cacheService.setCacheTimestamp();

      final result =
          await cacheService.cacheAndRetrieveData<Map<String, dynamic>>(
        'testKey',
        const Duration(hours: 1),
        () async => throw Exception('Fetch failed'),
        (response) => response as Map<String, dynamic>,
      );

      expect(result['data'], testData); // Corrected line
    });
  });
}
