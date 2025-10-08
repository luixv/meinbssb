import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class KillSwitchProvider extends ChangeNotifier {
  KillSwitchProvider({
    bool appEnabled = true, // <-- default to true. Switch to false for testing
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
      'app_enabled': false,
      'for_testing': 'bye bye',
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
    // Set minimum fetch interval to 0 for testing
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: Duration(seconds: 10),
        minimumFetchInterval: Duration(seconds: 0),
      ),
    );
    try {
      await remoteConfig.fetchAndActivate();
      await remoteConfig.activate();
    } catch (e, stack) {
      debugPrint('Remote Config fetchAndActivate/activate error: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }

    // Log all remote config values after activation
    remoteConfig.getAll().forEach((key, rcValue) {
      debugPrint('Remote Config key: $key, value: ${rcValue.asString()}');
    });

    _appEnabled = remoteConfig.getBool('app_enabled');
    debugPrint('Remote Config value for app_enabled: $_appEnabled');
    _message = remoteConfig.getString('kill_switch_message');
    notifyListeners();
  }
}
