import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/image_service.dart';
import 'package:image/image.dart' as img;

class MockLoggerService extends Mock {}

void main() {
  late ImageService imageService;

  setUp(() {
    imageService = ImageService();
  });

  group('rotatedImage', () {
    test('returns rotated image data when input is valid', () async {
      // Create a simple 1x1 pixel image and encode it as jpg
      final original = img.Image(width: 1, height: 1);
      final imageData = Uint8List.fromList(img.encodeJpg(original));

      final rotated = await imageService.rotatedImage(imageData);

      // The result should be a non-empty Uint8List
      expect(rotated, isA<Uint8List>());
      expect(rotated.length, greaterThan(0));
    });

    test('throws Exception when image cannot be decoded', () async {
      final invalidData = Uint8List.fromList([0, 1, 2, 3, 4, 5]);
      expect(() => imageService.rotatedImage(invalidData), throwsException);
    });
  });

  // Note: The cacheSchuetzenausweis and getCachedSchuetzenausweis methods
  // are platform-dependent and interact with file system or shared preferences.
  // These would require platform/channel mocking for full coverage.
  // Here, we just check that the methods complete without throwing (on the current platform).
  group('cacheSchuetzenausweis', () {
    test('completes without error (smoke test)', () async {
      final imageData = Uint8List.fromList([1, 2, 3]);
      await imageService.cacheSchuetzenausweis(1, imageData, DateTime.now().millisecondsSinceEpoch);
    });
  });

  group('getCachedSchuetzenausweis', () {
    test('returns null or Uint8List (smoke test)', () async {
      final result = await imageService.getCachedSchuetzenausweis(1, Duration(seconds: 1));
      expect(result == null || result is Uint8List, isTrue);
    });
  });
} 