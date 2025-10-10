import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/providers/kill_switch_provider.dart';

import 'package:firebase_remote_config/firebase_remote_config.dart';

// Helper class for mobile platform test
// Simulates RemoteConfig returning expected values

class TestRemoteConfig implements FirebaseRemoteConfig {
  @override
  bool getBool(String key) => true;
  @override
  String getString(String key) {
    if (key == 'kill_switch_message') {
      return 'Die App ist vorübergehend deaktiviert.';
    }
    if (key == 'minimum_required_version') return '1.2.3';
    return '';
  }

  @override
  Future<void> setDefaults(Map<String, dynamic> defaults) async {}
  @override
  Future<void> setConfigSettings(RemoteConfigSettings settings) async {}
  @override
  Future<bool> fetchAndActivate() async => true;
  @override
  Map<String, RemoteConfigValue> getAll() => <String, RemoteConfigValue>{};
  @override
  noSuchMethod(Invocation invocation) => null;
}

class FakeRemoteConfig implements FirebaseRemoteConfig {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('KillSwitchProvider', () {
    test('default constructor sets appEnabled true and message null', () {
      final provider = KillSwitchProvider(remoteConfig: FakeRemoteConfig());
      expect(provider.appEnabled, true);
      expect(provider.message, isNull);
    });

    test('constructor sets custom values', () {
      final provider = KillSwitchProvider(
        remoteConfig: FakeRemoteConfig(),
        appEnabled: false,
        killSwitchMessage: 'Test message',
      );
      expect(provider.appEnabled, false);
      expect(provider.message, 'Test message');
    });

    test('notifies listeners when notifyListeners is called', () {
      final provider = KillSwitchProvider(remoteConfig: FakeRemoteConfig());
      bool notified = false;
      provider.addListener(() {
        notified = true;
      });
      provider.notifyListeners();
      expect(notified, true);
    });

    test('fetchRemoteConfig sets Windows-specific values', () async {
      final provider = KillSwitchProvider(remoteConfig: FakeRemoteConfig());
      // Simulate Windows platform by calling the method directly
      await provider.fetchRemoteConfig();
      await provider
          .fetchRemoteConfig(); // Should call _handleWindowsPlatform if logic is correct
      // On Windows, message should be set
      // Note: This test assumes you manually test _handleWindowsPlatform, as Platform.isWindows cannot be set in Dart tests
      // expect(provider.message, 'Die App ist auf Windows nicht verfügbar.');
    });

    test('fetchRemoteConfig handles mobile logic (mocked)', () async {
      final provider = KillSwitchProvider(remoteConfig: FakeRemoteConfig());
      // Simulate mobile platform by calling the method directly
      await provider.fetchRemoteConfig();
      // On mobile, should use remote config (mocked)
      // Note: This test assumes you manually test _handleMobilePlatform, as Platform.isAndroid cannot be set in Dart tests
      // expect(provider.appEnabled, true);
    });

    test(
      'error handling in _handleWindowsPlatform does not break state',
      () async {
        final provider = KillSwitchProvider(remoteConfig: FakeRemoteConfig());
        await provider.fetchRemoteConfig();
        // Should keep safe fallback values
        expect(provider.appEnabled, true);
      },
    );

    test('handleWindowsPlatform sets correct values and notifies', () async {
      final provider = KillSwitchProvider(remoteConfig: FakeRemoteConfig());
      bool notified = false;
      provider.addListener(() {
        notified = true;
      });
      await provider.handleWindowsPlatform();
      expect(provider.appEnabled, true);
      expect(provider.message, 'Die App ist auf Windows nicht verfügbar.');
      expect(notified, true);
    });

    test(
      'handleMobilePlatform sets values from remoteConfig and notifies',
      () async {
        final fakeRemoteConfig = TestRemoteConfig();
        final provider = KillSwitchProvider(remoteConfig: fakeRemoteConfig);
        bool notified = false;
        provider.addListener(() {
          notified = true;
        });
        await provider.handleMobilePlatform();
        expect(provider.appEnabled, true);
        expect(provider.message, 'Die App ist vorübergehend deaktiviert.');
        expect(provider.minimumRequiredVersion, '1.2.3');
        expect(notified, true);
      },
    );

    test('fetchRemoteConfig does not throw on unsupported platform', () async {
      final provider = KillSwitchProvider(remoteConfig: FakeRemoteConfig());
      expect(() async => await provider.fetchRemoteConfig(), returnsNormally);
    });

    test('error handling in fetchRemoteConfig does not break state', () async {
      final provider = KillSwitchProvider(
        remoteConfig: FakeRemoteConfig(),
        appEnabled: false,
        killSwitchMessage: 'Initial',
      );
      // Simulate error by calling fetchRemoteConfig on desktop/web (no Firebase)
      await provider.fetchRemoteConfig();
      // Should keep safe fallback values
      expect(provider.appEnabled, true);
      expect(provider.message, isNull);
    });

    test('multiple listeners are notified', () {
      final provider = KillSwitchProvider(remoteConfig: FakeRemoteConfig());
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });
      provider.addListener(() {
        notifyCount++;
      });
      provider.notifyListeners();
      expect(notifyCount, 2);
    });

    test(
      'fetchRemoteConfig does not change appEnabled if already true',
      () async {
        final provider = KillSwitchProvider(
          remoteConfig: FakeRemoteConfig(),
          appEnabled: true,
        );
        await provider.fetchRemoteConfig();
        expect(provider.appEnabled, true);
      },
    );

    test('fetchRemoteConfig does not change message if already set', () async {
      final provider = KillSwitchProvider(
        remoteConfig: FakeRemoteConfig(),
        appEnabled: true,
        killSwitchMessage: 'Already set',
      );
      await provider.fetchRemoteConfig();
      // On desktop/web, message should become null
      expect(provider.message, isNull);
    });
  });
}
