import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:convert'; // Import dart:convert for utf8

// Create a mock for RootBundle
class MockRootBundle extends Mock
    implements AssetBundle {} // Implement AssetBundle, not RootBundle

void main() {
  // Initialize binding before all tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConfigService', () {
    const testJson = '''
    {
      "apiBaseServer": "127.0.0.1",
      "apiBasePort": "3001",
      "serverTimeout": 8,
      "cacheExpirationHours": "24",
      "smtpSettings": {
        "host": "smtp.dummyserver.com",
        "username": "mySmtpUsername",
        "password": "mySmtpPassword",
        "fromEmail": "dummyemail@de.bssb.meinbssb",
        "registrationSubject": "registration to BSSB",
        "registrationContent": "user registered"
      },
      "appTheme": {
        "logoName": "assets/images/myBSSB-logo.png"
      }
    }
    ''';

    setUp(() {
      // Reset the singleton between tests using the public method
      ConfigService.reset();
      // Set up the mock RootBundle for the test
      TestWidgetsFlutterBinding.ensureInitialized()
          .defaultBinaryMessenger
          .setMockMessageHandler(
        'flutter/assets',
        (ByteData? message) async {
          final buffer = message!.buffer;
          final bytes =
              buffer.asUint8List(message.offsetInBytes, message.lengthInBytes);
          final String path = utf8.decode(bytes);
          if (path == 'assets/config.json') {
            return ByteData.view(
              Uint8List.fromList(utf8.encode(testJson)).buffer,
            );
          }
          return null;
        },
      );
    });

    test('should correctly parse and return config values', () async {
      // Load the config
      final service = await ConfigService.load('assets/config.json');

      // Test top-level values
      expect(service.getString('apiBaseServer'), '127.0.0.1');
      expect(service.getString('apiBasePort'), '3001');
      expect(service.getInt('serverTimeout'), 8);
      expect(service.getString('cacheExpirationHours'), '24');

      // Test nested SMTP settings
      expect(service.getString('host', 'smtpSettings'), 'smtp.dummyserver.com');
      expect(service.getString('username', 'smtpSettings'), 'mySmtpUsername');
      expect(
        service.getString('fromEmail', 'smtpSettings'),
        'dummyemail@de.bssb.meinbssb',
      );

      // Test nested app theme
      expect(
        service.getString('logoName', 'appTheme'),
        'assets/images/myBSSB-logo.png',
      );
    });

    test('should return correct data types', () async {
      final service = await ConfigService.load('assets/config.json');

      // Verify data types
      expect(service.getString('apiBaseServer'), isA<String>());
      expect(service.getString('apiBasePort'), isA<String>());
      expect(service.getInt('serverTimeout'), isA<int>());
      expect(service.getString('cacheExpirationHours'), isA<String>());

      // Verify nested data types
      expect(service.getString('host', 'smtpSettings'), isA<String>());
      expect(service.getString('logoName', 'appTheme'), isA<String>());
    });
  });
}
