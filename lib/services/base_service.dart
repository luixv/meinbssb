// Project: Mein BSSB
// Filename: base_service.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/foundation.dart';

/// Base service class that provides common functionality for all services
abstract class BaseService {
  /// Log a debug message
  void logDebug(String message) {
    debugPrint(message);
  }

  /// Log an error message
  void logError(String message, [dynamic error]) {
    debugPrint('ERROR: $message');
    if (error != null) {
      debugPrint('Details: $error');
    }
  }

  /// Check if a value is null or empty
  bool isNullOrEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return false;
  }
}
