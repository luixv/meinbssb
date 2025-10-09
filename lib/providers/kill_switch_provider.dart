import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class KillSwitchProvider extends ChangeNotifier {
  KillSwitchProvider({bool appEnabled = true, String? killSwitchMessage})
    : _appEnabled = appEnabled,
      _killSwitchMessage = killSwitchMessage;

  bool _appEnabled;
  String? _killSwitchMessage;

  bool get appEnabled => _appEnabled;
  String? get message => _killSwitchMessage;

  /// Fetch and activate remote config safely.
  /// Uses Firebase Remote Config on mobile, fallback values on desktop.
  Future<void> fetchRemoteConfig() async {
    // ----------------------------
    // Fallback for non-mobile platforms
    // ----------------------------
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      _appEnabled = true; // safe default
      _killSwitchMessage = null;
      notifyListeners();
      return;
    }

    // ----------------------------
    // Mobile: initialize Remote Config
    // ----------------------------
    final remoteConfig = FirebaseRemoteConfig.instance;

    // Force platform initialization (avoids null integer crash)
    try {
      remoteConfig.getAll();
    } catch (e, st) {
      debugPrint('⚠️ Warning: getAll() initialization failed: $e');
      debugPrint('$st');
    }

    // Set defaults
    try {
      await remoteConfig.setDefaults(<String, dynamic>{
        'app_enabled': true,
        'kill_switch_message': 'Die App ist vorübergehend deaktiviert.',
      });
      debugPrint('Defaults applied.');
    } catch (e, st) {
      debugPrint('❌ Error setting defaults: $e');
      debugPrint('$st');
    }

    // Set safe RemoteConfigSettings
    try {
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 30),
          minimumFetchInterval: const Duration(
            seconds: 10,
          ), // short for testing
        ),
      );
      debugPrint('RemoteConfigSettings applied.');
    } catch (e, st) {
      debugPrint('❌ Error setting config settings: $e');
      debugPrint('$st');
    }

    // Fetch and activate remote values
    try {
      final activated = await remoteConfig.fetchAndActivate();
      debugPrint(
        'Remote Config fetchAndActivate completed. Activated: $activated',
      );

      _appEnabled = remoteConfig.getBool('app_enabled');
      _killSwitchMessage = remoteConfig.getString('kill_switch_message');

      debugPrint(
        '✅ Remote Config fetch success: appEnabled=$_appEnabled, message=$_killSwitchMessage',
      );
      notifyListeners();
    } catch (e, st) {
      debugPrint('❌ Exception during fetchAndActivate: $e');
      debugPrint('$st');

      // Keep existing values as fallback
      _appEnabled = _appEnabled;
      _killSwitchMessage = _killSwitchMessage;
      notifyListeners();
    }
  }
}
