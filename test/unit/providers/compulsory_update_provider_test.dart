import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/providers/compulsory_update_provider.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseRemoteConfig extends Mock implements FirebaseRemoteConfig {}

void main() {
  group('CompulsoryUpdateProvider', () {
    test('default state: updateRequired is false, message is null', () {
      final mockRemoteConfig = MockFirebaseRemoteConfig();
      when(() => mockRemoteConfig.getString(any())).thenReturn('');
      final provider = CompulsoryUpdateProvider(remoteConfig: mockRemoteConfig);
      expect(provider.updateRequired, false);
      expect(provider.updateMessage, isNull);
    });

    test('test-only setters work', () {
      final mockRemoteConfig = MockFirebaseRemoteConfig();
      when(() => mockRemoteConfig.getString(any())).thenReturn('');
      final provider = CompulsoryUpdateProvider(remoteConfig: mockRemoteConfig);
      provider.testUpdateRequired = true;
      provider.testUpdateMessage = 'Forced update';
      expect(provider.updateRequired, true);
      expect(provider.updateMessage, 'Forced update');
    });

    test('isUpdateRequired returns true for lower version', () {
      final mockRemoteConfig = MockFirebaseRemoteConfig();
      when(() => mockRemoteConfig.getString(any())).thenReturn('');
      final provider = CompulsoryUpdateProvider(remoteConfig: mockRemoteConfig);
      expect(provider.updateRequired, false);
      final result = provider.isUpdateRequired('1.0.0', '2.0.0');
      expect(result, true);
    });

    test('isUpdateRequired returns false for equal or higher version', () {
      final mockRemoteConfig = MockFirebaseRemoteConfig();
      when(() => mockRemoteConfig.getString(any())).thenReturn('');
      final provider = CompulsoryUpdateProvider(remoteConfig: mockRemoteConfig);
      expect(provider.isUpdateRequired('2.0.0', '2.0.0'), false);
      expect(provider.isUpdateRequired('3.0.0', '2.0.0'), false);
    });
  });
}
