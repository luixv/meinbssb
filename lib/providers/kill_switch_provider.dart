import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class KillSwitchProvider extends ChangeNotifier {
  KillSwitchProvider({
    required this.remoteConfig,
    bool appEnabled = true,
    String? killSwitchMessage,
  }) : _appEnabled = appEnabled,
       _killSwitchMessage = killSwitchMessage;
  final FirebaseRemoteConfig remoteConfig;

  bool _appEnabled;
  String? _killSwitchMessage;
  String? _minimumRequiredVersion;

  bool get appEnabled => _appEnabled;
  String? get message => _killSwitchMessage;
  String? get minimumRequiredVersion => _minimumRequiredVersion;

  /// Fetch and activate remote config safely.
  /// Uses Firebase Remote Config on mobile, fallback values on desktop.
  Future<void> fetchRemoteConfig() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      await handleNonMobilePlatform();
      return;
    }
    if (Platform.isWindows) {
      await handleWindowsPlatform();
      return;
    }
    await handleMobilePlatform();
  }

  Future<void> handleNonMobilePlatform() async {
    _appEnabled = true; // safe default
    _killSwitchMessage = null;
    notifyListeners();
  }

  Future<void> handleWindowsPlatform() async {
    // You can customize Windows-specific logic here
    _appEnabled = true; // or false, depending on your requirements
    _killSwitchMessage = 'Die App ist auf Windows nicht verfügbar.';
    notifyListeners();
  }

  Future<void> handleMobilePlatform() async {
    // Use the injected remoteConfig instance

    try {
      await remoteConfig.setDefaults(<String, dynamic>{
        'app_enabled': true,
        'kill_switch_message': 'Die App ist vorübergehend deaktiviert.',
      });
    } catch (e, st) {
      debugPrint('❌ Error setting defaults: $e');
      debugPrint('$st');
    }

    try {
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 30),
          minimumFetchInterval: const Duration(seconds: 10),
        ),
      );
    } catch (e, st) {
      debugPrint('❌ Error setting config settings: $e');
      debugPrint('$st');
    }

    try {
      _appEnabled = remoteConfig.getBool('app_enabled');
      _killSwitchMessage = remoteConfig.getString('kill_switch_message');
      _minimumRequiredVersion = remoteConfig.getString(
        'minimum_required_version',
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
