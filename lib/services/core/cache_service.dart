// Project: Mein BSSB
// Filename: cache_service.dart
// Author: Luis Mandel / NTT DATA

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'config_service.dart';
import 'logger_service.dart';
import 'dart:async';

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
    // Ensure the decoded map is always Map<String, dynamic>
    return jsonDecode(jsonString) as Map<String, dynamic>;
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

  /// Clears cache entries that match a specific pattern
  Future<void> clearPattern(String pattern) async {
    final keys = _prefs.getKeys();
    int count = 0;
    for (String key in keys) {
      if (key.startsWith(_cacheKeyPrefix) && key.contains(pattern)) {
        await _prefs.remove(key);
        count++;
      }
    }
    LoggerService.logInfo(
      'Cleared $count cache entries matching pattern: $pattern',
    );
  }

  Future<bool> containsKey(String key) async {
    final exists = _prefs.containsKey(_cacheKeyPrefix + key);
    LoggerService.logInfo('Checked if key exists: $key, result: $exists');
    return exists;
  }

  Future<void> setCacheTimestampForKey(String key) async {
    await setInt('${key}_timestamp', DateTime.now().millisecondsSinceEpoch);
    LoggerService.logInfo('Set cache timestamp for key: $key');
  }

  Future<int?> getCacheTimestampForKey(String key) async {
    final value = await getInt('${key}_timestamp');
    LoggerService.logInfo(
      'Retrieved cache timestamp for key: $key, value: ${value ?? 'null'}',
    );
    return value;
  }

  Future<T> getCachedData<T>(
    String cacheKey,
    Future<T> Function() getCachedData,
  ) async {
    LoggerService.logInfo('Getting cached data for key: $cacheKey');
    return await getCachedData();
  }

  Future<T?> _retrieveCachedDataWithOnlineFlag<T>(
    String cacheKey,
    T Function(dynamic rawData) processCachedData,
    Duration validityDuration,
  ) async {
    final cachedJson = _prefs.getString(_cacheKeyPrefix + cacheKey);
    if (cachedJson != null) {
      final dynamic cachedRawData = jsonDecode(cachedJson);

      final keyTimestamp =
          await getCacheTimestampForKey(_cacheKeyPrefix + cacheKey);

      // Use ConfigService to get cache duration, fallback to validityDuration if config is not available
      final cacheExpirationHours =
          _configService.getInt('cacheExpirationHours');
      final effectiveValidityDuration = cacheExpirationHours != null
          ? Duration(hours: cacheExpirationHours)
          : validityDuration;

      if (keyTimestamp != null) {
        final expirationTime = DateTime.fromMillisecondsSinceEpoch(
          keyTimestamp,
        ).add(effectiveValidityDuration);
        if (DateTime.now().isBefore(expirationTime)) {
          LoggerService.logInfo(
            'Using cached data from SharedPreferences for key: $cacheKey',
          );
          final processedData = processCachedData(cachedRawData);

          if (processedData is Map<String, dynamic>) {
            return {...processedData, 'ONLINE': false} as T;
          } else if (processedData is List) {
            final List<Map<String, dynamic>> typedList = [];
            for (var item in processedData) {
              if (item is Map<dynamic, dynamic>) {
                typedList
                    .add(Map<String, dynamic>.from(item)..['ONLINE'] = false);
              } else {
                LoggerService.logWarning(
                  'Unexpected item type in cached list for key $cacheKey: ${item.runtimeType}',
                );
                return null;
              }
            }
            return typedList as T;
          } else {
            return processedData;
          }
        } else {
          LoggerService.logInfo('Cached data expired for key: $cacheKey');
          return null;
        }
      }
      final processedData = processCachedData(cachedRawData);
      if (processedData is Map<String, dynamic>) {
        return {...processedData, 'ONLINE': false} as T;
      } else if (processedData is List) {
        final List<Map<String, dynamic>> typedList = [];
        for (var item in processedData) {
          if (item is Map<dynamic, dynamic>) {
            typedList.add(Map<String, dynamic>.from(item)..['ONLINE'] = false);
          } else {
            LoggerService.logWarning(
              'Unexpected item type in cached list for key $cacheKey: ${item.runtimeType}',
            );
            return null;
          }
        }
        return typedList as T;
      }
      return processedData;
    }
    LoggerService.logInfo('No cached data found for key: $cacheKey');
    return null;
  }

  Future<T> cacheAndRetrieveData<T>(
    String cacheKey,
    Duration validityDuration,
    Future<T> Function() fetchData,
    T Function(dynamic response) processResponse,
  ) async {
    final stopwatch = Stopwatch()..start();

    // First, try to get cached data
    final cachedData = await _retrieveCachedDataWithOnlineFlag<T>(
      cacheKey,
      processResponse,
      validityDuration,
    );
    if (cachedData != null) {
      stopwatch.stop();
      LoggerService.logInfo(
          'Using cached data for $cacheKey (took ${stopwatch.elapsedMilliseconds}ms)',);
      return cachedData;
    }

    // If no valid cached data, make network request
    try {
      LoggerService.logInfo(
        'No valid cache found, attempting network request for $cacheKey',
      );
      final response = await fetchData();
      final processedData = processResponse(response);

      if (processedData != null) {
        dynamic dataToCache;
        if (processedData is Map<String, dynamic>) {
          dataToCache = {...processedData, 'ONLINE': true};
        } else if (processedData is List) {
          // Check if it's a list first
          // Ensure all elements are maps and convert them safely
          if (processedData.every((item) => item is Map<dynamic, dynamic>)) {
            // Explicitly convert each map to Map<String, dynamic>
            dataToCache = processedData.map((item) {
              return Map<String, dynamic>.from(item as Map<dynamic, dynamic>)
                ..['ONLINE'] = true;
            }).toList();
          } else {
            LoggerService.logError(
              'Unsupported list item type for caching with ONLINE flag: ${processedData.first.runtimeType} in list $cacheKey',
            );
            throw Exception(
              'Unsupported data type for caching: List<${processedData.first.runtimeType}>',
            );
          }
        } else {
          LoggerService.logError(
            'Unsupported data type for caching with ONLINE flag: ${processedData.runtimeType} (expected Map or List<Map>) for $cacheKey',
          );
          throw Exception(
            'Unsupported data type for caching: ${processedData.runtimeType}',
          );
        }

        if (dataToCache != null) {
          await _prefs.setString(
            _cacheKeyPrefix + cacheKey,
            jsonEncode(dataToCache),
          );
          await setCacheTimestampForKey(_cacheKeyPrefix + cacheKey);
          stopwatch.stop();
          LoggerService.logInfo(
              'Successfully cached fresh data for $cacheKey (took ${stopwatch.elapsedMilliseconds}ms)',);
          // Direct cast of dataToCache to T
          return dataToCache as T;
        }
      }
      LoggerService.logInfo('Network request returned null data for $cacheKey');
      throw Exception(
        'Network request returned no data.',
      );
    } on Exception catch (e) {
      LoggerService.logError('Network request failed for $cacheKey: $e');

      if (e.toString().contains('Unsupported data type for caching')) {
        rethrow;
      }

      // Try to get cached data again as fallback (in case it was added between our first check and now)
      final fallbackCachedData = await _retrieveCachedDataWithOnlineFlag<T>(
        cacheKey,
        processResponse,
        validityDuration,
      );
      if (fallbackCachedData != null) {
        stopwatch.stop();
        LoggerService.logInfo(
            'Using fallback cached data for $cacheKey (took ${stopwatch.elapsedMilliseconds}ms)',);
        return fallbackCachedData;
      }
      LoggerService.logWarning('No network and no valid cache for $cacheKey');
      throw Exception(
        'No network data and no valid cached data available.',
      );
    } catch (e) {
      LoggerService.logError('An unexpected error occurred for $cacheKey: $e');
      rethrow;
    }
  }
}
