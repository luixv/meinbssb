import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/providers/kill_switch_provider.dart';

void main() {
  group('KillSwitchProvider', () {
    test('defaults to appEnabled true and null message', () {
      final provider = KillSwitchProvider();
      expect(provider.appEnabled, true);
      expect(provider.message, isNull);
    });

    test('can set initial values via constructor', () {
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
  });
}
