// cache_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class CacheService {
  static const String _cacheKeyPrefix = 'cache_';

  Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKeyPrefix + key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cacheKeyPrefix + key);
  }

  Future<void> setJson(String key, Map<String, dynamic> json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKeyPrefix + key, jsonEncode(json));
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKeyPrefix + key);
    if (jsonString == null) {
      return null;
    }
    return jsonDecode(jsonString);
  }

  Future<void> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cacheKeyPrefix + key, value);
  }

  Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_cacheKeyPrefix + key);
  }

  Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cacheKeyPrefix + key, value);
  }

  Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_cacheKeyPrefix + key);
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKeyPrefix + key);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith(_cacheKeyPrefix)) {
        await prefs.remove(key);
      }
    }
  }

  Future<bool> containsKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_cacheKeyPrefix + key);
  }

  Future<void> setCacheTimestamp() async {
    await setInt('cacheTimestamp', DateTime.now().millisecondsSinceEpoch);
  }

  Future<T> getCachedData<T>(
    String cacheKey,
    Future<T> Function() getCachedData,
  ) async {
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
      // Renamed to retrieveCachedData
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
              debugPrint('Using cached data from SharedPreferences.');
              return cachedData as T;
            } else {
              debugPrint('Cached data expired.');
              return null as T;
            }
          }
        }
        return null as T;
      });
    }

    try {
      final response = await fetchData();
      final processedData = processResponse(response);

      if (processedData != null) {
        await prefs.setString(cacheKey, jsonEncode(processedData));
        await setCacheTimestamp();
        return processedData;
      } else {
        return await retrieveCachedData(); // Corrected function name
      }
    } catch (e) {
      debugPrint('An error occurred: $e. Retrieving cached data.');
      return await retrieveCachedData(); // Corrected function name
    }
  }
}
