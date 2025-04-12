import 'dart:convert';
import 'package:flutter/services.dart';

class ConfigService {
  static Map<String, dynamic>? _config;

  static Future<void> load(String path) async {
    try {
      final String data = await rootBundle.loadString(path);
      _config = jsonDecode(data);
    } catch (e) {
      _config = {}; // Initialize to an empty map on error
    }
  }

  static int? getInt(String key, [String? section]) {
    if (_config == null) return null;

    dynamic value;
    if (section != null &&
        section.isNotEmpty &&
        _config!.containsKey(section) &&
        _config![section] is Map) {
      value = _config![section][key];
    } else {
      value = _config![key];
    }

    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static String? getString(String key, [String? section]) {
    if (_config == null) return null;

    dynamic value;
    if (section != null &&
        section.isNotEmpty &&
        _config!.containsKey(section) &&
        _config![section] is Map) {
      value = _config![section][key];
    } else {
      value = _config![key];
    }

    if (value is String) {
      return value;
    }
    return null;
  }
}
