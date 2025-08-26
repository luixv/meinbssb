import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/services/core/image_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:meinbssb/services/core/http_client.dart';

class FakeConnectivity {
  FakeConnectivity(this.results);
  final List<ConnectivityResult> results;
  Future<List<ConnectivityResult>> checkConnectivity() async => results;
}

class ThrowingConnectivity {
  Future<List<ConnectivityResult>> checkConnectivity() async {
    throw Exception('Connectivity error');
  }
}

class FakeHttpClient implements HttpClient {
  FakeHttpClient({this.bytes, this.shouldThrow = false});
  final Uint8List? bytes;
  final bool shouldThrow;

  @override
  String get baseUrl => '';

  @override
  int get serverTimeout => 30; // Should match the interface type

  @override
  Future<Uint8List> getBytes(String endpoint) async {
    if (shouldThrow) throw Exception('Network error');
    return bytes ?? Uint8List.fromList([1, 2, 3]);
  }

  @override
  Future<dynamic> get(String endpoint, {String? overrideBaseUrl}) {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> post(String endpoint, Map<String, dynamic> body,
      {String? overrideBaseUrl,}) {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> put(String endpoint, Map<String, dynamic> body,
      {String? overrideBaseUrl,}) {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> delete(String endpoint,
      {Map<String, dynamic>? body, String? overrideBaseUrl,}) {
    throw UnimplementedError();
  }
}

void main() {
  group('ImageService', () {
    test('isDeviceOnline returns true for wifi', () async {
      final service = ImageService(
        httpClient: FakeHttpClient(),
        connectivity: FakeConnectivity([ConnectivityResult.wifi]),
      );
      expect(await service.isDeviceOnline(), isTrue);
    });

    test('isDeviceOnline returns true for mobile', () async {
      final service = ImageService(
        httpClient: FakeHttpClient(),
        connectivity: FakeConnectivity([ConnectivityResult.mobile]),
      );
      expect(await service.isDeviceOnline(), isTrue);
    });

    test('isDeviceOnline returns false for none', () async {
      final service = ImageService(
        httpClient: FakeHttpClient(),
        connectivity: FakeConnectivity([]),
      );
      expect(await service.isDeviceOnline(), isFalse);
    });

    test('isDeviceOnline returns false if connectivity throws', () async {
      final service = ImageService(
        httpClient: FakeHttpClient(),
        connectivity: ThrowingConnectivity(),
      );
      expect(await service.isDeviceOnline(), isFalse);
    });

    test('fetchAndCacheSchuetzenausweis returns network image if online',
        () async {
      final imageData = Uint8List.fromList([10, 11, 12]);
      final service = ImageService(
        httpClient: FakeHttpClient(bytes: imageData),
        connectivity: FakeConnectivity([ConnectivityResult.wifi]),
      );
      final result = await service.fetchAndCacheSchuetzenausweis(
        100,
        const Duration(seconds: 10),
      );
      expect(result, imageData);
    });

    test('fetchAndCacheSchuetzenausweis returns cached image if offline',
        () async {
      final imageData = Uint8List.fromList([20, 21, 22]);
      final service = ImageService(
        httpClient: FakeHttpClient(bytes: Uint8List.fromList([99, 99, 99])),
        connectivity: FakeConnectivity([]),
        getCachedSchuetzenausweisFn: (id, validity) async => imageData,
      );
      final result = await service.fetchAndCacheSchuetzenausweis(
        101,
        const Duration(seconds: 10),
      );
      expect(result, imageData);
    });

    test('fetchAndCacheSchuetzenausweis returns cached image if fetch fails',
        () async {
      final imageData = Uint8List.fromList([30, 31, 32]);
      final service = ImageService(
        httpClient: FakeHttpClient(shouldThrow: true),
        connectivity: FakeConnectivity([ConnectivityResult.wifi]),
        getCachedSchuetzenausweisFn: (id, validity) async => imageData,
      );
      final result = await service.fetchAndCacheSchuetzenausweis(
        102,
        const Duration(seconds: 10),
      );
      expect(result, imageData);
    });

    test('fetchAndCacheSchuetzenausweis throws if no cache and fetch fails',
        () async {
      final service = ImageService(
        httpClient: FakeHttpClient(shouldThrow: true),
        connectivity: FakeConnectivity([ConnectivityResult.wifi]),
        getCachedSchuetzenausweisFn: (id, validity) async => null,
      );
      expect(
        () async => await service.fetchAndCacheSchuetzenausweis(
          103,
          const Duration(seconds: 10),
        ),
        throwsException,
      );
    });

    test('fetchAndCacheSchuetzenausweis throws if offline and no cache',
        () async {
      final service = ImageService(
        httpClient: FakeHttpClient(),
        connectivity: FakeConnectivity([]),
        getCachedSchuetzenausweisFn: (id, validity) async => null,
      );
      expect(
        () async => await service.fetchAndCacheSchuetzenausweis(
          104,
          const Duration(seconds: 10),
        ),
        throwsException,
      );
    });

    test(
        'cacheSchuetzenausweis and getCachedSchuetzenausweis roundtrip (smoke)',
        () async {
      final imageData = Uint8List.fromList([40, 41, 42]);
      const id = 105;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final service = ImageService(
        httpClient: FakeHttpClient(),
      );
      await service.cacheSchuetzenausweis(id, imageData, timestamp);
      final cached = await service.getCachedSchuetzenausweis(
        id,
        const Duration(seconds: 10),
      );
      expect(cached == null, isTrue);
    });
  });
}
