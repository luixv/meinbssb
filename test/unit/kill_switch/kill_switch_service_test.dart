import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:meinbssb/services/kill_switch/kill_switch_service.dart';

// NOTE: For a pure unit test you would mock FirebaseRemoteConfig.
// This is a placeholder demonstrating the interface.

class _FakeRemoteConfig implements FirebaseRemoteConfig {
  bool enabled = true;
  final _vals = <String, Object?>{};
  @override
  bool getBool(String key) {
    if (key == 'app_enabled') return enabled;
    return (_vals[key] as bool?) ?? false;
  }

  @override
  String getString(String key) => (_vals[key] as String?) ?? '';
  // Implement only used members with noSuchMethod fallback:
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('KillSwitchService reads values', () {
    final fake = _FakeRemoteConfig();
    fake.enabled = false;
    final service = KillSwitchService(fake);
    expect(service.isEnabled, isFalse);
  });
}
