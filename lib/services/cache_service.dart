// cache_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'base_service.dart';

class CacheService extends BaseService {
  static const String _cacheKeyPrefix = 'cache_';

  Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKeyPrefix + key, value);
    logDebug('Cached string for key: $key');
  }

  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_cacheKeyPrefix + key);
    logDebug(
      'Retrieved string for key: $key, value: ${value != null ? 'exists' : 'null'}',
    );
    return value;
  }

  Future<void> setJson(String key, Map<String, dynamic> json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKeyPrefix + key, jsonEncode(json));
    logDebug('Cached JSON for key: $key');
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKeyPrefix + key);
    if (jsonString == null) {
      logDebug('No JSON found for key: $key');
      return null;
    }
    logDebug('Retrieved JSON for key: $key');
    return jsonDecode(jsonString);
  }

  Future<void> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cacheKeyPrefix + key, value);
    logDebug('Cached int for key: $key, value: $value');
  }

  Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_cacheKeyPrefix + key);
    logDebug('Retrieved int for key: $key, value: ${value ?? 'null'}');
    return value;
  }

  Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cacheKeyPrefix + key, value);
    logDebug('Cached bool for key: $key, value: $value');
  }

  Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(_cacheKeyPrefix + key);
    logDebug('Retrieved bool for key: $key, value: ${value ?? 'null'}');
    return value;
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKeyPrefix + key);
    logDebug('Removed cache for key: $key');
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    int count = 0;
    for (String key in keys) {
      if (key.startsWith(_cacheKeyPrefix)) {
        await prefs.remove(key);
        count++;
      }
    }
    logDebug('Cleared $count cache entries');
  }

  Future<bool> containsKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final exists = prefs.containsKey(_cacheKeyPrefix + key);
    logDebug('Checked if key exists: $key, result: $exists');
    return exists;
  }

  Future<void> setCacheTimestamp() async {
    await setInt('cacheTimestamp', DateTime.now().millisecondsSinceEpoch);
    logDebug('Set cache timestamp');
  }

  Future<T> getCachedData<T>(
    String cacheKey,
    Future<T> Function() getCachedData,
  ) async {
    logDebug('Getting cached data for key: $cacheKey');
    return await getCachedData();
  }

  Future<T> cacheAndRetrieveData<T>(
    String cacheKey,
    Duration validityDuration,
    Future<T> Function() fetchData,
    T Function(dynamic response) processResponse,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    Future<T> retrieveCachedData() async {
      return getCachedData(cacheKey, () async {
        final cachedJson = prefs.getString(cacheKey);
        if (cachedJson != null) {
          final cachedData = jsonDecode(cachedJson);
          final globalTimestamp = await getInt('cacheTimestamp');

          if (globalTimestamp != null) {
            final expirationTime = DateTime.fromMillisecondsSinceEpoch(
              globalTimestamp,
            ).add(validityDuration);
            if (DateTime.now().isBefore(expirationTime)) {
              logDebug(
                'Using cached data from SharedPreferences for key: $cacheKey',
              );
              return cachedData as T;
            } else {
              logDebug('Cached data expired for key: $cacheKey');
              return null as T;
            }
          }
        }
        logDebug('No cached data found for key: $cacheKey');
        return null as T;
      });
    }

    try {
      logDebug('Fetching fresh data for key: $cacheKey');
      final response = await fetchData();
      final processedData = processResponse(response);

      if (processedData != null) {
        await prefs.setString(cacheKey, jsonEncode(processedData));
        await setCacheTimestamp();
        logDebug('Successfully cached fresh data for key: $cacheKey');
        return processedData;
      } else {
        logDebug(
          'Processed data is null, retrieving cached data for key: $cacheKey',
        );
        return await retrieveCachedData();
      }
    } catch (e) {
      logError('Error fetching data for key: $cacheKey', e);
      logDebug('Retrieving cached data due to error for key: $cacheKey');
      return await retrieveCachedData();
    }
  }
}
