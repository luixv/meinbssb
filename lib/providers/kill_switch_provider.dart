import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class KillSwitchProvider extends ChangeNotifier {
  // Constructor only sets initial values, no async calls here
  KillSwitchProvider({bool appEnabled = true, String? message})
    : _appEnabled = appEnabled,
      _message = message;

  bool _appEnabled;
  String? _message;
  bool get appEnabled => _appEnabled;
  String? get message => _message;

  // Made public so AppInitializer can call it explicitly
  Future<void> fetchRemoteConfig() async {
    debugPrint(
      '✅ KillSwitchProvider.fetchRemoteConfig() STARTING... Again and again',
    );

    final remoteConfig = FirebaseRemoteConfig.instance;

    // 1. Set Defaults immediately. This guarantees local values are available.
    await remoteConfig.setDefaults(const <String, dynamic>{
      'app_enabled': true,
      'kill_switch_message': 'App temporarily disabled.',
    });

    // *** CRITICAL FIX: Aggressive 1-second delay for full native settling ***
    // This delay is strategically placed BEFORE the error-prone setConfigSettings
    // to give the native Firebase environment ample time to initialize.
    await Future<void>.delayed(const Duration(milliseconds: 1000));

    const int maxRetries = 5;
    const Duration retryDelay = Duration(milliseconds: 150);

    // 2. Retry Loop for setConfigSettings
    // This handles residual, less severe race conditions for the settings application.
    for (int i = 0; i < maxRetries; i++) {
      try {
        await remoteConfig.setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: const Duration(seconds: 30),
            // Setting minimumFetchInterval to Duration.zero is ideal for a kill switch check on startup.
            minimumFetchInterval: Duration.zero,
          ),
        );
        debugPrint(
          '✅ Remote Config settings successfully applied on attempt ${i + 1}.',
        );
        // Success! Break the loop and proceed to fetch.
        break;
      } on TypeError catch (e) {
        if (i < maxRetries - 1) {
          debugPrint(
            '⚠️ Set Config Settings failed with known TypeError ($e). Retrying in ${retryDelay.inMilliseconds}ms...',
          );
          await Future<void>.delayed(retryDelay);
        } else {
          // Last attempt failed, log a critical error and continue without new settings
          debugPrint(
            '❌ CRITICAL: Set Config Settings failed after $maxRetries attempts. Proceeding with defaults for fetch.',
          );
        }
      } catch (e) {
        // Handle any other unexpected error during settings (non-TypeError)
        debugPrint('❌ Unexpected error during setConfigSettings: $e');
        break;
      }
    }

    // 3. Fetch and Activate
    try {
      await remoteConfig.fetchAndActivate();

      // 4. Read Values and Notify
      _appEnabled = remoteConfig.getBool('app_enabled');
      _message = remoteConfig.getString('kill_switch_message');

      debugPrint('✅ Remote Config fetch success. App Enabled: $_appEnabled');
      notifyListeners();
    } catch (e) {
      debugPrint(
        '❌ Exception during fetchAndActivate (Config not updated): $e',
      );
      // If fetch fails, the app continues to run with the defaults set in step 1.
    }
  }
}
