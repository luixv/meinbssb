import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class KillSwitchProvider extends ChangeNotifier {
  KillSwitchProvider({
    bool appEnabled = true,
    String? message,
    bool skipRemoteConfig = false,
  }) : _appEnabled = appEnabled,
       _message = message {
    if (!skipRemoteConfig) {
      _fetchRemoteConfig();
    }
  }
  bool _appEnabled;
  String? _message;
  bool get appEnabled => _appEnabled;
  String? get message => _message;

  Future<void> _fetchRemoteConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    final defaults = <String, dynamic>{
      'app_enabled': true,
      'fortesting': 'bye bye',
    };
    // Log all keys and values before setting defaults
    defaults.forEach((key, value) {
      debugPrint('Remote Config default for $key ');
    });
    try {
      await remoteConfig.setDefaults(defaults);
    } catch (e, stack) {
      debugPrint('Remote Config setDefaults error: $e');
      debugPrint('Defaults map: $defaults');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
    try {
      await remoteConfig.fetchAndActivate();
    } catch (e, stack) {
      debugPrint('Remote Config fetchAndActivate error: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }

    _appEnabled = remoteConfig.getBool('app_enabled');
    _message = remoteConfig.getString('kill_switch_message');
    notifyListeners();

    remoteConfig.getAll().forEach((key, rcValue) {
      if (rcValue.source == ValueSource.valueStatic && rcValue.asInt() == 0) {
        debugPrint(
          'Remote Config parameter "$key" is missing or defaulted to 0!',
        );
      }
    });
  }
}
