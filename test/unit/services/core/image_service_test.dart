// ignore_for_file: unnecessary_type_check

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/core/image_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MockLoggerService extends Mock {}

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

  group('fetchAndCacheSchuetzenausweis', () {
    test('returns cached image if available', () async {
      final image = Uint8List.fromList([1, 2, 3]);
      final service = ImageService(
        getCachedSchuetzenausweisFn: (int _, Duration __) async => image,
      );
      final result = await service.fetchAndCacheSchuetzenausweis(
        1,
        () async => Uint8List.fromList([9, 9, 9]),
        const Duration(seconds: 1),
      );
      expect(result, image);
    });

    test('calls fetch and caches if no cache', () async {
      final image = Uint8List.fromList([4, 5, 6]);
      var fetchCalled = false;
      final service = ImageService(
        getCachedSchuetzenausweisFn: (int _, Duration __) async => null,
        cacheSchuetzenausweisFn: (int _, Uint8List img, int __) async {
          expect(img, image);
          fetchCalled = true;
        },
      );
      final result = await service.fetchAndCacheSchuetzenausweis(
        1,
        () async => image,
        const Duration(seconds: 1),
      );
      expect(result, image);
      expect(fetchCalled, isTrue);
    });

    test('falls back to expired cache if fetch fails', () async {
      final fallback = Uint8List.fromList([7, 8, 9]);
      final service = ImageService(
        getCachedSchuetzenausweisFn: (int _, Duration validity) async =>
            validity.inDays < 1000 ? null : fallback,
        cacheSchuetzenausweisFn: (int _, Uint8List __, int ___) async {
          throw Exception('Should not be called');
        },
      );
      final result = await service.fetchAndCacheSchuetzenausweis(
        1,
        () async => throw Exception('fail'),
        const Duration(seconds: 1),
      );
      expect(result, fallback);
    });

    test('throws if fetch fails and no cache', () async {
      final service = ImageService(
        getCachedSchuetzenausweisFn: (int _, Duration __) async => null,
        cacheSchuetzenausweisFn: (int _, Uint8List __, int ___) async {},
      );
      expect(
        () async => await service.fetchAndCacheSchuetzenausweis(
          1,
          () async => throw Exception('fail'),
          const Duration(seconds: 1),
        ),
        throwsException,
      );
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
}
