// Project: Mein BSSB
// Filename: cache_service.dart
// Author: Luis Mandel / NTT DATA

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '/services/config_service.dart';
import '/services/logger_service.dart';

class CacheService {
  CacheService({
    required SharedPreferences prefs,
    required ConfigService configService,
  })  : _prefs = prefs,
        _configService = configService;
  static const String _cacheKeyPrefix = 'cache_';
  final SharedPreferences _prefs;
  final ConfigService _configService;

  Future<void> setString(String key, String value) async {
    await _prefs.setString(_cacheKeyPrefix + key, value);
    LoggerService.logInfo('Cached string for key: $key');
  }

  Future<String?> getString(String key) async {
    final value = _prefs.getString(_cacheKeyPrefix + key);
    LoggerService.logInfo(
      'Retrieved string for key: $key, value: ${value != null ? 'exists' : 'null'}',
    );
    return value;
  }

  Future<void> setJson(String key, Map<String, dynamic> json) async {
    await _prefs.setString(_cacheKeyPrefix + key, jsonEncode(json));
    LoggerService.logInfo('Cached JSON for key: $key');
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    final jsonString = _prefs.getString(_cacheKeyPrefix + key);
    if (jsonString == null) {
      LoggerService.logInfo('No JSON found for key: $key');
      return null;
    }
    LoggerService.logInfo('Retrieved JSON for key: $key');
    return jsonDecode(jsonString);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(_cacheKeyPrefix + key, value);
    LoggerService.logInfo('Cached int for key: $key, value: $value');
  }

  Future<int?> getInt(String key) async {
    final value = _prefs.getInt(_cacheKeyPrefix + key);
    LoggerService.logInfo(
      'Retrieved int for key: $key, value: ${value ?? 'null'}',
    );
    return value;
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(_cacheKeyPrefix + key, value);
    LoggerService.logInfo('Cached bool for key: $key, value: $value');
  }

  Future<bool?> getBool(String key) async {
    final value = _prefs.getBool(_cacheKeyPrefix + key);
    LoggerService.logInfo(
      'Retrieved bool for key: $key, value: ${value ?? 'null'}',
    );
    return value;
  }

  Future<void> remove(String key) async {
    await _prefs.remove(_cacheKeyPrefix + key);
    LoggerService.logInfo('Removed cache for key: $key');
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
    LoggerService.logInfo('Cleared $count cache entries');
  }

  Future<bool> containsKey(String key) async {
    final exists = _prefs.containsKey(_cacheKeyPrefix + key);
    LoggerService.logInfo('Checked if key exists: $key, result: $exists');
    return exists;
  }

  Future<void> setCacheTimestamp() async {
    await setInt('cacheTimestamp', DateTime.now().millisecondsSinceEpoch);
    LoggerService.logInfo('Set cache timestamp');
  }

  Future<T> getCachedData<T>(
    String cacheKey,
    Future<T> Function() getCachedData,
  ) async {
    LoggerService.logInfo('Getting cached data for key: $cacheKey');
    return await getCachedData();
  }

  Future<Map<String, dynamic>> _retrieveCachedDataWithOnlineFlag(
      String cacheKey,) async {
    final cachedJson = _prefs.getString(_cacheKeyPrefix + cacheKey);
    if (cachedJson != null) {
      final cachedData = jsonDecode(cachedJson);
      final globalTimestamp = await getInt('cacheTimestamp');
      final cacheExpirationHours =
          _configService.getInt('cacheExpirationHours') ?? 24;
      final validityDurationConfig = Duration(hours: cacheExpirationHours);

      if (globalTimestamp != null) {
        final expirationTime = DateTime.fromMillisecondsSinceEpoch(
          globalTimestamp,
        ).add(validityDurationConfig);
        if (DateTime.now().isBefore(expirationTime)) {
          LoggerService.logInfo(
            'Using cached data from SharedPreferences for key: $cacheKey',
          );
          return {'data': cachedData, 'ONLINE': false};
        } else {
          LoggerService.logInfo('Cached data expired for key: $cacheKey');
          return {'data': null, 'ONLINE': false}; // Indicate expired
        }
      }
      return {
        'data': cachedData,
        'ONLINE': false,
      }; // No timestamp, assume valid
    }
    LoggerService.logInfo('No cached data found for key: $cacheKey');
    return {'data': null, 'ONLINE': false};
  }

  Future<Map<String, dynamic>> cacheAndRetrieveData<T>(
    String cacheKey,
    Duration validityDuration,
    Future<T> Function() fetchData,
    T Function(dynamic response) processResponse,
  ) async {
    final cachedResult = await _retrieveCachedDataWithOnlineFlag(cacheKey);
    if (cachedResult['data'] != null) {
      return cachedResult; // Return the map with data and ONLINE: false
    }

    try {
      LoggerService.logInfo('Fetching fresh data for key: $cacheKey');
      final response = await fetchData();
      final processedData = processResponse(response);

      if (processedData != null) {
        await _prefs.setString(
          _cacheKeyPrefix + cacheKey,
          jsonEncode(processedData),
        ); // Use the prefixed key
        await setCacheTimestamp();
        LoggerService.logInfo(
          'Successfully cached fresh data for key: $cacheKey',
        );
        return {'data': processedData, 'ONLINE': true};
      } else {
        LoggerService.logInfo(
          'Processed data is null, returning expired/null cache for key: $cacheKey',
        );
        return cachedResult; // Return the expired/null cache with ONLINE: false
      }
    } catch (e) {
      LoggerService.logError('Error fetching data for key: $cacheKey: $e');
      LoggerService.logInfo(
        'Returning cached data due to error for key: $cacheKey',
      );
      return cachedResult; // Return the cached data (might be null) with ONLINE: false
    }
  }
}
