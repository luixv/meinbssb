// config_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';

class ConfigService {
  ConfigService._internal();
  static Map<String, dynamic>? _config;
  static ConfigService? _instance;

  static Future<ConfigService> load(String path) async {
    try {
      final String data = await rootBundle.loadString(path);
      _config = jsonDecode(data);
      _instance ??= ConfigService._internal();
      return _instance!;
    } catch (e) {
      _config = {};
      _instance ??= ConfigService._internal();
      return _instance!;
    }
  }

  static ConfigService get instance {
    if (_instance == null) {
      throw StateError(
        'ConfigService has not been loaded. Call ConfigService.load() first.',
      );
    }
    return _instance!;
  }

  // Public method to reset the singleton for testing
  static void reset() {
    _instance = null;
    _config = null;
  }

  int? getInt(String key, [String? section]) {
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

  String? getString(String key, [String? section]) {
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

  static String buildApiBaseUrl(
    ConfigService config, {
    String protocolKey = 'apiProtocol',
    String serverKey = 'api1BaseServer',
    String portKey = 'api1Port',
    String pathKey = 'api1BasePath',
  }) {
    final protocol = config.getString(protocolKey) ?? 'https';
    final server = config.getString(serverKey) ?? '';
    final port = config.getString(portKey) ?? '';
    final path = config.getString(pathKey) ?? '';
    return port.isNotEmpty
        ? '$protocol://$server:$port/$path'
        : '$protocol://$server/$path';
  }
}
