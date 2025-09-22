import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/services/core/config_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConfigService', () {
    const configJson = '''
    {
      "apiProtocol": "https",
      "apiBaseServer": "localhost",
      "apiBasePort": "8080",
      "apiBasePath": "api",
      "intValue": 42,
      "stringInt": "123",
      "stringValue": "hello",
      "boolTrue": true,
      "boolFalse": false,
      "stringTrue": "true",
      "stringFalse": "false",
      "listValue": ["a", "b", "c"],
      "section": {
        "intValue": 7,
        "stringInt": "77",
        "stringValue": "world",
        "boolTrue": true,
        "stringTrue": "true",
        "listValue": ["x", "y"]
      }
    }
    ''';

    setUp(() {
      ConfigService.reset();
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
              Uint8List.fromList(utf8.encode(configJson)).buffer,
            );
          }
          return null;
        },
      );
    });

    test('loads config and returns singleton', () async {
      final service = await ConfigService.load('assets/config.json');
      expect(service, isA<ConfigService>());
      expect(ConfigService.instance, same(service));
    });

    test('throws if instance is accessed before load', () {
      ConfigService.reset();
      expect(() => ConfigService.instance, throwsA(isA<StateError>()));
    });

    test('getInt returns int and parses string', () async {
      final service = await ConfigService.load('assets/config.json');
      expect(service.getInt('intValue'), 42);
      expect(service.getInt('stringInt'), 123);
      expect(service.getInt('intValue', 'section'), 7);
      expect(service.getInt('stringInt', 'section'), 77);
      expect(service.getInt('notfound'), isNull);
      expect(service.getInt('notfound', 'section'), isNull);
    });

    test('getString returns string values', () async {
      final service = await ConfigService.load('assets/config.json');
      expect(service.getString('stringValue'), 'hello');
      expect(service.getString('stringValue', 'section'), 'world');
      expect(service.getString('notfound'), isNull);
      expect(service.getString('notfound', 'section'), isNull);
    });

    test('getList returns list of strings', () async {
      final service = await ConfigService.load('assets/config.json');
      expect(service.getList('listValue'), ['a', 'b', 'c']);
      expect(service.getList('listValue', 'section'), ['x', 'y']);
      expect(service.getList('notfound'), isNull);
      expect(service.getList('notfound', 'section'), isNull);
    });

    test('getBool parses bool and string values', () async {
      final service = await ConfigService.load('assets/config.json');
      expect(service.getBool('boolTrue'), true);
      expect(service.getBool('boolFalse'), false);
      expect(service.getBool('stringTrue'), true);
      expect(service.getBool('stringFalse'), false);
      expect(service.getBool('boolTrue', 'section'), true);
      expect(service.getBool('stringTrue', 'section'), true);
      expect(service.getBool('notfound'), isNull);
      expect(service.getBool('notfound', 'section'), isNull);
    });

    test(
        'returns null for all getters if config is loaded but keys are missing',
        () async {
      ConfigService.reset();
      const emptyJson = '{}';
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
              Uint8List.fromList(utf8.encode(emptyJson)).buffer,
            );
          }
          return null;
        },
      );
      final service = await ConfigService.load('assets/config.json');
      expect(service.getInt('any'), isNull);
      expect(service.getString('any'), isNull);
      expect(service.getList('any'), isNull);
      expect(service.getBool('any'), isNull);
    });

    test('reset clears singleton and config', () async {
      final service = await ConfigService.load('assets/config.json');
      expect(ConfigService.instance, same(service));
      ConfigService.reset();
      expect(() => ConfigService.instance, throwsA(isA<StateError>()));
    });

    test('load returns empty config on error', () async {
      ConfigService.reset();
      final service = await ConfigService.load('notfound.json');
      expect(service, isA<ConfigService>());
      expect(service.getString('any'), isNull);
    });

    test('buildBaseUrlForServer builds correct URL', () async {
      final service = await ConfigService.load('assets/config.json');
      final url = ConfigService.buildBaseUrlForServer(service, name: 'apiBase');
      expect(url, 'https://localhost:8080/api');
    });

    test('buildBaseUrlForServer uses default protocol if missing', () async {
      await ConfigService.load('assets/config.json');
      ConfigService.reset();
      // Patch config to remove protocol
      const brokenJson = '''
      {
        "apiBaseServer": "localhost",
        "apiBasePort": "8080",
        "apiBasePath": "api"
      }
      ''';
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
              Uint8List.fromList(utf8.encode(brokenJson)).buffer,
            );
          }
          return null;
        },
      );
      final brokenService = await ConfigService.load('assets/config.json');
      expect(
        ConfigService.buildBaseUrlForServer(brokenService, name: 'apiBase'),
        'https://localhost:8080/api',
      );
    });
  });
}
