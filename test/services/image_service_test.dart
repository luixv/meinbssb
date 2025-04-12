import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:convert';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart'
    as path_provider_interface; // Import with alias

import 'package:meinbssb/services/image_service.dart';

// Mock dependencies
class MockSharedPreferences extends Mock implements SharedPreferences {}

// Mock for PathProvider
class MockPathProvider extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => 'test_documents';

  @override
  Future<String?> getApplicationSupportPath() async => null;
  @override
  Future<String?> getDownloadsPath() async => null;
  @override
  Future<List<String>?> getExternalCachePaths() async => null;
  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async => null;
  @override
  Future<String?> getLibraryPath() async => null;
  @override
  Future<String?> getTemporaryPath() async => null;
}

// Mock for the Image class from the image package
class MockImage extends Mock implements img.Image {}

void main() {
  group('ImageService', () {
    late ImageService imageService;
    late MockSharedPreferences mockSharedPreferences;
    late MockPathProvider mockPathProvider;

    const int testPersonId = 123;
    final Uint8List testImageData = Uint8List.fromList([0, 1, 2, 3]);
    const int testTimestamp = 1678886400000; // Example timestamp
    final Duration testValidity = Duration(days: 7);
    const String testBase64Image = 'AQID';
    final Uint8List testRotatedImageData = Uint8List.fromList([
      4,
      5,
      6,
    ]); // Mock rotated data

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      SharedPreferences.setMockInitialValues({});
      mockPathProvider = MockPathProvider();
      path_provider_interface.PathProviderPlatform.instance =
          mockPathProvider; // Correct way to set the mock
      imageService = ImageService();
    });

    group('cacheSchuetzenausweis', () {
      test('should cache image on web', () async {
        debugDefaultTargetPlatformOverride =
            TargetPlatform.android; // Simulate non-web
        debugDefaultTargetPlatformOverride =
            null; // Reset to default (allows kIsWeb to be true in tests)

        when(
          mockSharedPreferences.setString(
            'image_$testPersonId.jpg',
            base64Encode(testImageData),
          ),
        ).thenAnswer((_) async => true);
        when(
          mockSharedPreferences.setInt(
            'image_${testPersonId}_timestamp',
            testTimestamp,
          ),
        ).thenAnswer((_) async => true);

        await imageService.cacheSchuetzenausweis(
          testPersonId,
          testImageData,
          testTimestamp,
        );

        verify(
          mockSharedPreferences.setString(
            'image_$testPersonId.jpg',
            base64Encode(testImageData),
          ),
        ).called(1);
        verify(
          mockSharedPreferences.setInt(
            'image_${testPersonId}_timestamp',
            testTimestamp,
          ),
        ).called(1);
      });

      test('should cache image on mobile/desktop', () async {
        when(
          mockPathProvider.getApplicationDocumentsPath(),
        ).thenAnswer((_) async => 'test_documents');
        when(
          mockSharedPreferences.setInt(
            'image_${testPersonId}_timestamp',
            testTimestamp,
          ),
        ).thenAnswer((_) async => true);

        await imageService.cacheSchuetzenausweis(
          testPersonId,
          testImageData,
          testTimestamp,
        );

        final file = File('test_documents/image_$testPersonId.jpg');
        expect(await file.exists(), isTrue);
        expect(await file.readAsBytes(), testImageData);
        verify(
          mockSharedPreferences.setInt(
            'image_${testPersonId}_timestamp',
            testTimestamp,
          ),
        ).called(1);
      });
    });

    test('rotatedImage should rotate and encode the image', () async {
      // Mock the image decoding and encoding
      final mockImage = MockImage();
      when(img.decodeImage(testImageData)).thenReturn(mockImage);
      when(img.copyRotate(mockImage, angle: 270)).thenReturn(mockImage);
      when(img.encodeJpg(mockImage)).thenReturn(testRotatedImageData);

      final rotated = await imageService.rotatedImage(testImageData);

      expect(rotated, testRotatedImageData);
      verify(img.decodeImage(testImageData)).called(1);
      verify(img.copyRotate(mockImage, angle: 270)).called(1);
      verify(img.encodeJpg(mockImage)).called(1);
    });

    group('getCachedSchuetzenausweis', () {
      test('should retrieve cached image from web if valid', () async {
        debugDefaultTargetPlatformOverride =
            TargetPlatform.android; // Simulate non-web
        debugDefaultTargetPlatformOverride = null; // Reset

        when(
          mockSharedPreferences.getInt('image_${testPersonId}_timestamp'),
        ).thenReturn(testTimestamp);
        when(
          mockSharedPreferences.getString('image_$testPersonId.jpg'),
        ).thenReturn(testBase64Image);

        final cachedImage = await imageService.getCachedSchuetzenausweis(
          testPersonId,
          testValidity,
        );

        expect(cachedImage, Uint8List.fromList(base64Decode(testBase64Image)));
        verify(
          mockSharedPreferences.getInt('image_${testPersonId}_timestamp'),
        ).called(1);
        verify(
          mockSharedPreferences.getString('image_$testPersonId.jpg'),
        ).called(1);
      });

      test('should return null from web if cache is expired', () async {
        final expiredTimestamp =
            DateTime.now()
                .subtract(testValidity)
                .subtract(Duration(seconds: 1))
                .millisecondsSinceEpoch;
        when(
          mockSharedPreferences.getInt('image_${testPersonId}_timestamp'),
        ).thenReturn(expiredTimestamp);
        when(
          mockSharedPreferences.getString('image_$testPersonId.jpg'),
        ).thenReturn(testBase64Image);

        final cachedImage = await imageService.getCachedSchuetzenausweis(
          testPersonId,
          testValidity,
        );

        expect(cachedImage, null);
        verify(
          mockSharedPreferences.getInt('image_${testPersonId}_timestamp'),
        ).called(1);
      });

      test(
        'should retrieve cached image from mobile/desktop if valid',
        () async {
          when(
            mockPathProvider.getApplicationDocumentsPath(),
          ).thenAnswer((_) async => 'test_documents');
          final file = await File(
            'test_documents/image_$testPersonId.jpg',
          ).create(recursive: true);
          await file.writeAsBytes(testImageData);

          final cachedImage = await imageService.getCachedSchuetzenausweis(
            testPersonId,
            testValidity,
          );

          expect(cachedImage, testImageData);
        },
      );

      test(
        'should return null from mobile/desktop if cache is expired',
        () async {
          when(
            mockPathProvider.getApplicationDocumentsPath(),
          ).thenAnswer((_) async => 'test_documents');
          final file = await File(
            'test_documents/image_$testPersonId.jpg',
          ).create(recursive: true);
          final pastTime = DateTime.now()
              .subtract(testValidity)
              .subtract(Duration(seconds: 1));
          await file.setLastModified(pastTime);

          final cachedImage = await imageService.getCachedSchuetzenausweis(
            testPersonId,
            testValidity,
          );

          expect(cachedImage, null);
        },
      );

      test(
        'should return null from mobile/desktop if file does not exist',
        () async {
          when(
            mockPathProvider.getApplicationDocumentsPath(),
          ).thenAnswer((_) async => 'test_documents');
          final file = File('test_documents/image_$testPersonId.jpg');
          if (await file.exists()) {
            await file.delete();
          }

          final cachedImage = await imageService.getCachedSchuetzenausweis(
            testPersonId,
            testValidity,
          );

          expect(cachedImage, null);
        },
      );
    });
  });
}
