import 'dart:async';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class KillSwitchService {
  KillSwitchService(this._remoteConfig);

  final FirebaseRemoteConfig _remoteConfig;

  static Future<KillSwitchService> create() async {
    final rc = FirebaseRemoteConfig.instance;
    await rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(minutes: 5),
      ),
    );
    await rc.setDefaults(const {
      'app_enabled': true,
      'kill_message_title': 'Wartung',
      'kill_message_body':
          'Die Anwendung ist vorübergehend deaktiviert. Bitte später erneut versuchen.',
    });
    // Initial fetch (failures ignored -> defaults)
    try {
      await rc.fetchAndActivate();
    } catch (_) {}
    return KillSwitchService(rc);
  }

  bool get isEnabled => _remoteConfig.getBool('app_enabled');
  String get title => _remoteConfig.getString('kill_message_title');
  String get body => _remoteConfig.getString('kill_message_body');

  Future<void> refresh() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (_) {}
  }
}
