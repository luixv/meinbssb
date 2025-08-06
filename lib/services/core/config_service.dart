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

  List<String>? getList(String key, [String? section]) {
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

    if (value is List) {
      return value.cast<String>();
    }
    return null;
  }

  /// Builds a base URL for any server defined in config.json by name prefix.
  /// Example: name = 'api1Base' will use keys 'api1BaseServer', 'api1Port', 'api1BasePath'.
  static String buildBaseUrlForServer(
    ConfigService config, {
    required String name,
    String protocolKey = 'apiProtocol',
  }) {
    String? server;
    String? port;
    String? path;
    String? protocol;

    protocol = config.getString(protocolKey);
    server = config.getString('${name}Server');
    port = config.getString('${name}Port');
    path = config.getString('${name}Path');

    if (protocol == null || protocol.isEmpty) {
      throw StateError(
        'ConfigService: protocol for $name is missing or empty. Protocol is $protocol',
      );
    }
    if (server == null || server.isEmpty) {
      throw StateError('ConfigService: server for $name is missing or empty.');
    }
    if (port == null || port.isEmpty) {
      throw StateError('ConfigService: port for $name is missing or empty.');
    }
    if (path == null) {
      throw StateError('ConfigService: path for $name is missing or empty.');
    }
    return '$protocol://$server:$port/$path';
  }
}
