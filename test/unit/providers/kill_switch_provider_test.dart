import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/providers/kill_switch_provider.dart';

void main() {
  group('KillSwitchProvider', () {
    test('default constructor sets appEnabled true and message null', () {
      final provider = KillSwitchProvider();
      expect(provider.appEnabled, true);
      expect(provider.message, isNull);
    });

    test('constructor sets custom values', () {
      final provider = KillSwitchProvider(
        appEnabled: false,
        killSwitchMessage: 'Test message',
      );
      expect(provider.appEnabled, false);
      expect(provider.message, 'Test message');
    });

    test('notifies listeners when notifyListeners is called', () {
      final provider = KillSwitchProvider();
      bool notified = false;
      provider.addListener(() {
        notified = true;
      });
      provider.notifyListeners();
      expect(notified, true);
    });

    test('fetchRemoteConfig sets fallback values on desktop/web', () async {
      final provider = KillSwitchProvider();
      await provider.fetchRemoteConfig();
      // On desktop/web, should fallback to safe defaults
      expect(provider.appEnabled, true);
      expect(provider.message, isNull);
    });
  });
}
