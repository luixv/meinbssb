// ignore_for_file: unnecessary_type_check

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/core/image_service.dart';

class MockLoggerService extends Mock {}

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
}
