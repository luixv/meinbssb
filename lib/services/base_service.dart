import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'cache_service.dart';
import 'http_client.dart';
import 'logger_service.dart';

abstract class BaseService {
  BaseService({
    required this.httpClient,
    required this.cacheService,
  });

  final HttpClient httpClient;
  final CacheService cacheService;

  Future<T> handleResponse<T>({
    required Future<dynamic> Function() request,
    required T Function(dynamic) mapper,
    String? cacheKey,
    Duration? cacheDuration,
  }) async {
    try {
      if (cacheKey != null && cacheDuration != null) {
        return await cacheService.cacheAndRetrieveData<T>(
          cacheKey,
          cacheDuration,
          request,
          mapper,
        );
      }

      final response = await request();
      return mapper(response);
    } on http.ClientException catch (e) {
      LoggerService.logError('Network error: ${e.message}');
      rethrow;
    } catch (e) {
      LoggerService.logError('Unexpected error: $e');
      rethrow;
    }
  }

  Future<Uint8List> handleImageResponse({
    required Future<Uint8List> Function() request,
    required String cacheKey,
    required Duration cacheDuration,
  }) async {
    try {
      final cachedData = await cacheService.getBytes(cacheKey);
      if (cachedData != null) {
        LoggerService.logInfo('Using cached data for $cacheKey');
        return cachedData;
      }

      final response = await request();
      await cacheService.setBytes(cacheKey, response);
      return response;
    } on http.ClientException catch (e) {
      LoggerService.logError('Network error: ${e.message}');
      rethrow;
    } catch (e) {
      LoggerService.logError('Unexpected error: $e');
      rethrow;
    }
  }
} 