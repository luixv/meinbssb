// test/unit/services/cache_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'dart:convert'; // Import jsonEncode for checking cached string
// Import for `predicate` if `which` is not available

// Generate the mock for ConfigService
@GenerateNiceMocks([MockSpec<ConfigService>()])
import 'cache_service_test.mocks.dart';

void main() {
  late CacheService cacheService;
  late SharedPreferences prefs;
  late MockConfigService mockConfigService;

  setUp(() async {
    // Clear SharedPreferences before each test
    // This is crucial to ensure tests are isolated
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
      // Set a non-cached key to ensure clear doesn't remove everything
      await prefs.setString('someOtherKey', 'someOtherValue');

      await cacheService.clear();
      expect(await cacheService.getString('testKey1'), null);
      expect(await cacheService.getString('testKey2'), null);
      // Verify the non-cached key is still there
      expect(prefs.getString('someOtherKey'), 'someOtherValue');
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

      // CORRECTED: Assert directly on the result map and the 'ONLINE' flag
      expect(result, isA<Map<String, dynamic>>());
      expect(result['test'], testData['test']);
      expect(result['ONLINE'], true);

      // Verify what's actually stored in cache
      final cachedString = prefs.getString('cache_testKey');
      expect(cachedString, isNotNull);
      final decodedCachedData =
          jsonDecode(cachedString!) as Map<String, dynamic>;
      expect(decodedCachedData['test'], testData['test']);
      expect(
        decodedCachedData['ONLINE'],
        true,
      ); // The cached data also includes 'ONLINE': true
    });

    test('cacheAndRetrieveData - expired cache', () async {
      final testData = {'test': 'data'};
      final newData = {'test': 'newData'};

      when(mockConfigService.getInt('cacheExpirationHours'))
          .thenReturn(0); // Immediate expiration

      // Cache initial data with ONLINE: true (as it would be if fetched from network)
      // Using setString for consistency with what's stored
      await cacheService.setString(
        'testKey',
        jsonEncode({...testData, 'ONLINE': true}),
      );
      await cacheService.setCacheTimestamp();

      // Wait a moment to ensure cache expires
      await Future.delayed(const Duration(milliseconds: 100));

      final result =
          await cacheService.cacheAndRetrieveData<Map<String, dynamic>>(
        'testKey',
        const Duration(
          hours: 1,
        ), // This duration is not directly used for expiration, the configService's value is.
        () async => newData, // This will be fetched because cache is expired
        (response) => response as Map<String, dynamic>,
      );

      // CORRECTED: Assert directly on the result map and the 'ONLINE' flag (from new data)
      expect(result, isA<Map<String, dynamic>>());
      expect(result['test'], newData['test']);
      expect(result['ONLINE'], true); // Fresh data will have ONLINE: true
    });

    test('cacheAndRetrieveData - fetch failure fallback to cache', () async {
      final testData = {'test': 'data'};

      when(mockConfigService.getInt('cacheExpirationHours')).thenReturn(24);

      // Cache initial data with ONLINE: true (as it would be if fetched from network)
      // Using setString for consistency with what's stored
      await cacheService.setString(
        'testKey',
        jsonEncode({...testData, 'ONLINE': true}),
      );
      await cacheService.setCacheTimestamp();

      final result =
          await cacheService.cacheAndRetrieveData<Map<String, dynamic>>(
        'testKey',
        const Duration(hours: 1),
        () async => throw Exception(
          'Simulated Fetch failed',
        ), // Simulate network failure
        (response) => response as Map<String, dynamic>,
      );

      // CORRECTED: Assert directly on the result map and the 'ONLINE' flag (from cached data)
      expect(result, isA<Map<String, dynamic>>());
      expect(result['test'], testData['test']);
      expect(result['ONLINE'], false); // Cached data will have ONLINE: false
    });

    // Test for when fetch returns data that causes `processedData` not to be a Map/List (but not null)
    // This test now expects the specific 'Unsupported data type for caching' exception.
    test(
        'cacheAndRetrieveData - fetch success but processed data is uncacheable type',
        () async {
      when(mockConfigService.getInt('cacheExpirationHours')).thenReturn(24);

      await expectLater(
        cacheService.cacheAndRetrieveData<String>(
          // T is String here to test uncacheable type
          'testKey',
          const Duration(hours: 1),
          () async => 'just_a_string', // fetchData returns a String
          (response) => response as String, // processResponse returns a String
        ),
        throwsA(
          predicate(
            (e) => e
                .toString()
                .contains('Unsupported data type for caching: String'),
          ),
        ),
      );
    });

    // Add a test for when fetch fails and no valid cache
    test('cacheAndRetrieveData - fetch failure and no valid cache', () async {
      when(mockConfigService.getInt('cacheExpirationHours'))
          .thenReturn(0); // Make cache expire immediately

      // Expect an exception because fetch fails and there's no valid cache
      await expectLater(
        cacheService.cacheAndRetrieveData<Map<String, dynamic>>(
          'testKey',
          const Duration(hours: 1),
          () async => throw Exception('Simulated Fetch failed'),
          (response) => response as Map<String, dynamic>,
        ),
        throwsA(
          predicate(
            (e) => e.toString().contains(
                  'No network data and no valid cached data available.',
                ),
          ),
        ),
      );
    });

    // Test for list of maps
    test('cacheAndRetrieveData - list of maps', () async {
      final testDataList = [
        {'id': 1, 'name': 'Item A'},
        {'id': 2, 'name': 'Item B'},
      ];
      when(mockConfigService.getInt('cacheExpirationHours')).thenReturn(24);

      final result =
          await cacheService.cacheAndRetrieveData<List<Map<String, dynamic>>>(
        'listKey',
        const Duration(hours: 1),
        () async => testDataList,
        (response) =>
            (response as List<dynamic>) // CORRECTED: Parentheses for cast
                .map((e) => e as Map<String, dynamic>)
                .toList(),
      );

      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.length, 2);
      expect(result[0]['name'], 'Item A');
      expect(result[0]['ONLINE'], true);
      expect(result[1]['name'], 'Item B');
      expect(result[1]['ONLINE'], true);

      final cachedString = prefs.getString('cache_listKey');
      expect(cachedString, isNotNull);
      final decodedCachedData = jsonDecode(cachedString!) as List<dynamic>;

      // CORRECTED: Explicitly convert items to Map<String, dynamic> for assertion
      // This is safer if jsonDecode sometimes yields Map<dynamic, dynamic> for inner maps
      final List<Map<String, dynamic>> actualCachedItems = decodedCachedData
          .map(
            (item) => Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
          )
          .toList();

      expect(actualCachedItems[0]['ONLINE'], true);
      expect(actualCachedItems[1]['ONLINE'], true);
    });

    // Test for list of maps with fallback
    test('cacheAndRetrieveData - list of maps fallback', () async {
      final testDataList = [
        {'id': 1, 'name': 'Item A'},
        {'id': 2, 'name': 'Item B'},
      ];
      when(mockConfigService.getInt('cacheExpirationHours')).thenReturn(24);

      // Pre-populate cache
      // CORRECTED: Using setString and jsonEncode for list
      await cacheService.setString(
        'listKey',
        jsonEncode(
          testDataList.map((item) => {...item, 'ONLINE': true}).toList(),
        ),
      );
      await cacheService.setCacheTimestamp();

      final result =
          await cacheService.cacheAndRetrieveData<List<Map<String, dynamic>>>(
        'listKey',
        const Duration(hours: 1),
        () async => throw Exception(
          'Network failed for list',
        ), // Simulate network failure
        (response) =>
            (response as List<dynamic>) // CORRECTED: Parentheses for cast
                .map((e) => e as Map<String, dynamic>)
                .toList(),
      );

      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.length, 2);
      expect(result[0]['name'], 'Item A');
      expect(result[0]['ONLINE'], false); // Should be false for cached data
      expect(result[1]['name'], 'Item B');
      expect(result[1]['ONLINE'], false); // Should be false for cached data
    });
  });
}
