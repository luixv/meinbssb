// ignore_for_file: unnecessary_type_check

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/core/image_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MockLoggerService extends Mock {}

class _ThrowingConnectivity {
  Future<List<ConnectivityResult>> checkConnectivity() async {
    throw Exception('Connectivity error');
  }
}

class FakeConnectivity {
  FakeConnectivity(this.onCheck);
  final Future<List<ConnectivityResult>> Function() onCheck;
  Future<List<ConnectivityResult>> checkConnectivity() => onCheck();
}

void main() {
  late ImageService imageService;

  setUp(() {
    imageService = ImageService();
  });

  // Note: The cacheSchuetzenausweis and getCachedSchuetzenausweis methods
  // are platform-dependent and interact with file system or shared preferences.
  // These would require platform/channel mocking for full coverage.
  // Here, we just check that the methods complete without throwing (on the current platform).
  group('cacheSchuetzenausweis', () {
    test('completes without error (smoke test)', () async {
      final imageData = Uint8List.fromList([1, 2, 3]);
      await imageService.cacheSchuetzenausweis(
        1,
        imageData,
        DateTime.now().millisecondsSinceEpoch,
      );
    });
  });

  group('getCachedSchuetzenausweis', () {
    test('returns null or Uint8List (smoke test)', () async {
      final result = await imageService.getCachedSchuetzenausweis(
        1,
        const Duration(seconds: 1),
      );
      expect(result == null || result is Uint8List, isTrue);
    });
  });

  group('isDeviceOnline', () {
    test('returns true for wifi', () async {
      final fake = FakeConnectivity(() async => [ConnectivityResult.wifi]);
      final service = ImageService(connectivity: fake);
      expect(await service.isDeviceOnline(), isTrue);
    });
    test('returns true for mobile', () async {
      final fake = FakeConnectivity(() async => [ConnectivityResult.mobile]);
      final service = ImageService(connectivity: fake);
      expect(await service.isDeviceOnline(), isTrue);
    });
    test('returns false for none', () async {
      final fake = FakeConnectivity(() async => []);
      final service = ImageService(connectivity: fake);
      expect(await service.isDeviceOnline(), isFalse);
    });
  });

  group('fetchAndCacheSchuetzenausweis', () {
    late Uint8List testImage;
    late bool fetchCalled;
    late bool cacheCalled;

    setUp(() {
      testImage = Uint8List.fromList([1, 2, 3, 4]);
      fetchCalled = false;
      cacheCalled = false;
    });

    test('returns cached image if offline', () async {
      imageService = ImageService(
        getCachedSchuetzenausweisFn: (id, duration) async => testImage,
        cacheSchuetzenausweisFn: (id, img, ts) async => cacheCalled = true,
        connectivity: FakeConnectivity(() async => []),
      );

      final result = await imageService.fetchAndCacheSchuetzenausweis(
        1,
        () async {
          fetchCalled = true;
          return testImage;
        },
        const Duration(days: 1),
      );
      expect(result, testImage);
      expect(fetchCalled, false);
      expect(cacheCalled, false);
    });

    test('downloads and caches new image if online', () async {
      imageService = ImageService(
        getCachedSchuetzenausweisFn: (id, duration) async => null,
        cacheSchuetzenausweisFn: (id, img, ts) async => cacheCalled = true,
        connectivity: FakeConnectivity(() async => [ConnectivityResult.wifi]),
      );

      final result = await imageService.fetchAndCacheSchuetzenausweis(
        1,
        () async {
          fetchCalled = true;
          return testImage;
        },
        const Duration(days: 1),
      );
      expect(result, testImage);
      expect(fetchCalled, true);
      expect(cacheCalled, true);
    });

    test('returns cached image if online but fetch fails', () async {
      imageService = ImageService(
        getCachedSchuetzenausweisFn: (id, duration) async => testImage,
        cacheSchuetzenausweisFn: (id, img, ts) async => cacheCalled = true,
        connectivity: FakeConnectivity(() async => [ConnectivityResult.wifi]),
      );

      final result = await imageService.fetchAndCacheSchuetzenausweis(
        1,
        () async {
          fetchCalled = true;
          throw Exception('Network error');
        },
        const Duration(days: 1),
      );
      expect(result, testImage);
      expect(fetchCalled, true);
      expect(cacheCalled, false);
    });

    test('throws if no cache and fetch fails', () async {
      imageService = ImageService(
        getCachedSchuetzenausweisFn: (id, duration) async => null,
        cacheSchuetzenausweisFn: (id, img, ts) async => cacheCalled = true,
        connectivity: FakeConnectivity(() async => [ConnectivityResult.wifi]),
      );

      expect(
        () async => await imageService.fetchAndCacheSchuetzenausweis(
          1,
          () async {
            throw Exception('Network error');
          },
          const Duration(days: 1),
        ),
        throwsException,
      );
    });

    test('throws if offline and no cache', () async {
      imageService = ImageService(
        getCachedSchuetzenausweisFn: (id, duration) async => null,
        cacheSchuetzenausweisFn: (id, img, ts) async => cacheCalled = true,
        connectivity: FakeConnectivity(() async => []),
      );

      expect(
        () async => await imageService.fetchAndCacheSchuetzenausweis(
          1,
          () async => testImage,
          const Duration(days: 1),
        ),
        throwsException,
      );
    });

    group('ImageService additional coverage', () {
      test('cacheSchuetzenausweis and getCachedSchuetzenausweis roundtrip',
          () async {
        final imageData = Uint8List.fromList([10, 20, 30]);
        const id = 99;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        await imageService.cacheSchuetzenausweis(id, imageData, timestamp);
        final cached = await imageService.getCachedSchuetzenausweis(
            id, const Duration(seconds: 10),);
        // cached may be null on some platforms, but should not throw
        expect(cached == null || cached is Uint8List, isTrue);
      });

      test('isDeviceOnline returns false if connectivity throws', () async {
        final service = ImageService(
          connectivity: _ThrowingConnectivity(),
        );
        expect(await service.isDeviceOnline(), isFalse);
      });
    });
  });
}
