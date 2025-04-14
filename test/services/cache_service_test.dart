import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meinbssb/services/cache_service.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late CacheService cacheService;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    cacheService = CacheService(mockPrefs);
  });

  group('CacheService Tests', () {
    test('cacheResponse stores data with expiry time', () async {
      const testKey = 'test_key';
      const testData = {'test': 'data'};
      const cacheDuration = Duration(hours: 1);
      
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
      
      await cacheService.cacheResponse(testKey, testData, cacheDuration: cacheDuration);
      
      verify(mockPrefs.setString(
        'api_cache_$testKey',
        any,
      )).called(1);
    });

    test('getCachedResponse returns null for non-existent key', () async {
      const testKey = 'non_existent_key';
      
      when(mockPrefs.getString(any)).thenReturn(null);
      
      final result = await cacheService.getCachedResponse(testKey);
      
      expect(result, null);
    });

    test('getCachedResponse returns null for expired cache', () async {
      const testKey = 'expired_key';
      final expiredTime = DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch;
      
      when(mockPrefs.getString(any)).thenReturn(
        '{"data":{"test":"data"},"expiry":$expiredTime}',
      );
      when(mockPrefs.remove(any)).thenAnswer((_) async => true);
      
      final result = await cacheService.getCachedResponse(testKey);
      
      expect(result, null);
      verify(mockPrefs.remove('api_cache_$testKey')).called(1);
    });

    test('getCachedResponse returns cached data for valid cache', () async {
      const testKey = 'valid_key';
      final validTime = DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch;
      const testData = {'test': 'data'};
      
      when(mockPrefs.getString(any)).thenReturn(
        '{"data":{"test":"data"},"expiry":$validTime}',
      );
      
      final result = await cacheService.getCachedResponse(testKey);
      
      expect(result, testData);
    });

    test('clearCache removes all cache entries', () async {
      final cacheKeys = ['api_cache_key1', 'api_cache_key2'];
      
      when(mockPrefs.getKeys()).thenReturn(cacheKeys.toSet());
      when(mockPrefs.remove(any)).thenAnswer((_) async => true);
      
      await cacheService.clearCache();
      
      verify(mockPrefs.remove('api_cache_key1')).called(1);
      verify(mockPrefs.remove('api_cache_key2')).called(1);
    });

    test('removeCachedResponse removes specific cache entry', () async {
      const testKey = 'test_key';
      
      when(mockPrefs.remove(any)).thenAnswer((_) async => true);
      
      await cacheService.removeCachedResponse(testKey);
      
      verify(mockPrefs.remove('api_cache_$testKey')).called(1);
    });
  });
} 