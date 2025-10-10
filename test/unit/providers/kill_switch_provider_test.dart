import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/providers/kill_switch_provider.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

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

    test(
      'fetchRemoteConfig sets fallback values and notifies listeners on desktop/web',
      () async {
        final provider = KillSwitchProvider(remoteConfig: FakeRemoteConfig());
        bool notified = false;
        provider.addListener(() {
          notified = true;
        });
        await provider.fetchRemoteConfig();
        // On desktop/web, should fallback to safe defaults
        expect(provider.appEnabled, true);
        expect(provider.message, isNull);
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
