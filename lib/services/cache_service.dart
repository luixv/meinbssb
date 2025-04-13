// Project: Mein BSSB
// Filename: cache_service.dart
// Author: Luis Mandel / NTT DATA

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '/services/base_service.dart';
import '/services/config_service.dart';

class CacheService extends BaseService {
  static const String _cacheKeyPrefix = 'cache_';
  final SharedPreferences _prefs;
  final ConfigService _configService;

  CacheService({
    required SharedPreferences prefs,
    required ConfigService configService,
  }) : _prefs = prefs,
       _configService = configService;

  Future<void> setString(String key, String value) async {
    await _prefs.setString(_cacheKeyPrefix + key, value);
    logDebug('Cached string for key: $key');
  }

  Future<String?> getString(String key) async {
    final value = _prefs.getString(_cacheKeyPrefix + key);
    logDebug(
      'Retrieved string for key: $key, value: ${value != null ? 'exists' : 'null'}',
    );
    return value;
  }

  Future<void> setJson(String key, Map<String, dynamic> json) async {
    await _prefs.setString(_cacheKeyPrefix + key, jsonEncode(json));
    logDebug('Cached JSON for key: $key');
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    final jsonString = _prefs.getString(_cacheKeyPrefix + key);
    if (jsonString == null) {
      logDebug('No JSON found for key: $key');
      return null;
    }
    logDebug('Retrieved JSON for key: $key');
    return jsonDecode(jsonString);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(_cacheKeyPrefix + key, value);
    logDebug('Cached int for key: $key, value: $value');
  }

  Future<int?> getInt(String key) async {
    final value = _prefs.getInt(_cacheKeyPrefix + key);
    logDebug('Retrieved int for key: $key, value: ${value ?? 'null'}');
    return value;
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(_cacheKeyPrefix + key, value);
    logDebug('Cached bool for key: $key, value: $value');
  }

  Future<bool?> getBool(String key) async {
    final value = _prefs.getBool(_cacheKeyPrefix + key);
    logDebug('Retrieved bool for key: $key, value: ${value ?? 'null'}');
    return value;
  }

  Future<void> remove(String key) async {
    await _prefs.remove(_cacheKeyPrefix + key);
    logDebug('Removed cache for key: $key');
  }

  Future<void> clear() async {
    final keys = _prefs.getKeys();
    int count = 0;
    for (String key in keys) {
      if (key.startsWith(_cacheKeyPrefix)) {
        await _prefs.remove(key);
        count++;
      }
    }
    logDebug('Cleared $count cache entries');
  }

  Future<bool> containsKey(String key) async {
    final exists = _prefs.containsKey(_cacheKeyPrefix + key);
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
    Future<T> retrieveCachedData() async {
      return getCachedData(cacheKey, () async {
        final cachedJson = _prefs.getString(cacheKey);
        if (cachedJson != null) {
          final cachedData = jsonDecode(cachedJson);
          final globalTimestamp = await getInt('cacheTimestamp');
          final cacheExpirationHours =
              _configService.getInt('cacheExpirationHours') ?? 24;
          final validityDurationConfig = Duration(hours: cacheExpirationHours);

          if (globalTimestamp != null) {
            final expirationTime = DateTime.fromMillisecondsSinceEpoch(
              globalTimestamp,
            ).add(validityDurationConfig); // Use config-based duration
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
        await _prefs.setString(cacheKey, jsonEncode(processedData));
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
