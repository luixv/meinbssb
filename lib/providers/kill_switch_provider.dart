import 'package:package_info_plus/package_info_plus.dart';
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

  /// Returns true if currentVersion < minimumRequiredVersion
  bool _isUpdateRequired(
    String currentVersion,
    String? minimumRequiredVersion,
  ) {
    if (minimumRequiredVersion == null || minimumRequiredVersion.isEmpty) {
      return false;
    }
    // Split version strings by non-digit/period characters
    final cv = currentVersion.split(RegExp(r'[^0-9.]')).first;
    final mv = minimumRequiredVersion.split(RegExp(r'[^0-9.]')).first;
    final cvParts = cv.split('.').map(int.tryParse).toList();
    final mvParts = mv.split('.').map(int.tryParse).toList();
    for (int i = 0; i < mvParts.length; i++) {
      final c = (i < cvParts.length && cvParts[i] != null) ? cvParts[i]! : 0;
      final m = mvParts[i] ?? 0;
      if (c < m) return true;
      if (c > m) return false;
    }
    return false;
  }

  bool _updateRequired = false;
  bool get updateRequired => _updateRequired;

  bool _appEnabled;
  String? _killSwitchMessage;
  String? _minimumRequiredVersion;

  bool get appEnabled => _appEnabled;
  String? get message => _killSwitchMessage;
  String? get minimumRequiredVersion => _minimumRequiredVersion;

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
    // Use the injected remoteConfig instance

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
      _minimumRequiredVersion = remoteConfig.getString(
        'minimum_required_version',
      );
      debugPrint('Fetched minimum_required_version: $_minimumRequiredVersion');

      // Compare with current app version
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;
      debugPrint('Current app version: $currentVersion');
      _updateRequired = _isUpdateRequired(
        currentVersion,
        _minimumRequiredVersion,
      );
      debugPrint('Update required: $_updateRequired');

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
