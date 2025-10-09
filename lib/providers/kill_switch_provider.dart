import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_core/firebase_core.dart';

class KillSwitchProvider extends ChangeNotifier {
  KillSwitchProvider({
    bool appEnabled = true, // <-- default to true. Switch to false for testing
    String? message,
    bool skipRemoteConfig = false,
  }) : _appEnabled = appEnabled,
       _message = message {
    if (!skipRemoteConfig) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchRemoteConfig();
      });
    }
  }
  bool _appEnabled;
  String? _message;
  bool get appEnabled => _appEnabled;
  String? get message => _message;

  Future<void> _fetchRemoteConfig() async {
    // Debug: print the Firebase projectId
    debugPrint('Firebase projectId: ${Firebase.app().options.projectId}');
    final remoteConfig = FirebaseRemoteConfig.instance;

    try {
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: Duration(seconds: 30),
          minimumFetchInterval: Duration(seconds: 10),
        ),
      );

      await remoteConfig.setDefaults({
        'app_enabled': true,
        'kill_switch_message': 'App temporarily disabled.',
      });

      _appEnabled = remoteConfig.getBool('app_enabled');
      _message = remoteConfig.getString('kill_switch_message');

      notifyListeners();

      await remoteConfig.fetchAndActivate();
    } catch (e, stack) {
      debugPrint('Exception during FirebaseRemoteConfig.instance: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }

    Map<String, RemoteConfigValue> remoteKeyValue = remoteConfig.getAll();

    // Debug: print all remote config values immediately after instance creation
    debugPrint('--- Remote Config values after instance creation ---');

    remoteKeyValue.forEach((key, rcValue) {
      debugPrint('Remote Config key: $key, value: ${rcValue.asString()}');
    });

    final defaults = <String, dynamic>{
      'app_enabled': false,
      'for_testing': 'bye bye',
    };
    // Log all keys and values before setting defaults
    defaults.forEach((key, value) {
      debugPrint('Default Config value for $key: $value');
    });
    try {
      await remoteConfig.setDefaults(defaults);
    } catch (e, stack) {
      debugPrint('Remote Config setDefaults error: $e');
      debugPrint('Defaults map: $defaults');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
    debugPrint('fetchTimeout: ${Duration(minutes: 1).inMilliseconds}');
    debugPrint('minimumFetchInterval: ${Duration(hours: 1).inMilliseconds}');

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
