import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../services/logger_service.dart';

class AppException implements Exception {
  AppException(this.message, {this.code, this.stackTrace});
  final String message;
  final int? code;
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

class ErrorHandler {
  static void handleError(dynamic error, [StackTrace? stackTrace]) {
    if (error is http.ClientException) {
      LoggerService.logError('Network error: ${error.message}', stackTrace: stackTrace);
      throw AppException('Network error: ${error.message}', stackTrace: stackTrace);
    } else if (error is FormatException) {
      LoggerService.logError('Data format error: ${error.message}', stackTrace: stackTrace);
      throw AppException('Invalid data format', stackTrace: stackTrace);
    } else if (error is AppException) {
      LoggerService.logError(error.message, stackTrace: error.stackTrace ?? stackTrace);
      rethrow;
    } else {
      LoggerService.logError('Unexpected error: $error', stackTrace: stackTrace);
      throw AppException('An unexpected error occurred', stackTrace: stackTrace);
    }
  }

  static Future<T> handleAsyncError<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      handleError(e, stackTrace);
      rethrow;
    }
  }
} 