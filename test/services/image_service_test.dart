import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:meinbssb/services/image_service.dart';
import 'image_service_test.mocks.dart';

@GenerateMocks([
  SharedPreferences,
  Directory,
  File,
  FileStat,
])
void main() {
  late ImageService imageService;
  late MockSharedPreferences mockPrefs;
  late MockDirectory mockDirectory;
  late MockFile mockFile;
  late MockFileStat mockFileStat;

  const int personId = 123;
  final Uint8List imageData = Uint8List.fromList([1, 2, 3, 4]);
  final int timestamp = DateTime.now().millisecondsSinceEpoch;
  final Duration validity = const Duration(hours: 1);

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockDirectory = MockDirectory();
    mockFile = MockFile();
    mockFileStat = MockFileStat();
    imageService = ImageService();
  });

  group('Image Rotation Tests', () {
    test('successful image rotation returns rotated image', () async {
      final originalImage = img.Image(100, 100);
      final rotatedImage = img.copyRotate(originalImage, angle: 270);
      final rotatedImageData = img.encodeJpg(rotatedImage);

      final result = await imageService.rotatedImage(
        Uint8List.fromList(img.encodeJpg(originalImage)),
      );

      expect(result, Uint8List.fromList(rotatedImageData));
    });

    test('invalid image data throws exception', () async {
      final invalidImageData = Uint8List.fromList([1, 2, 3]); // Not a valid image

      expect(
        () => imageService.rotatedImage(invalidImageData),
        throwsException,
      );
    });
  });

  group('Web Implementation Tests', () {
    setUp(() {
      // Mock kIsWeb to true for web tests
      TestWidgetsFlutterBinding.ensureInitialized();
      (TestWidgetsFlutterBinding.instance as TestWidgetsFlutterBinding)
          .window
          .debugOverrideDevicePixelRatio = 1.0;
    });

    test('successful web image caching', () async {
      when(mockPrefs.setString('image_$personId.jpg', any))
          .thenAnswer((_) async => true);
      when(mockPrefs.setInt('image_${personId}_timestamp', any))
          .thenAnswer((_) async => true);
      SharedPreferences.setMockInitialValues({});

      await imageService.cacheSchuetzenausweis(personId, imageData, timestamp);

      verify(mockPrefs.setString('image_$personId.jpg', any)).called(1);
      verify(mockPrefs.setInt('image_${personId}_timestamp', any)).called(1);
    });

    test('successful web image retrieval', () async {
      final base64Image = base64Encode(imageData);
      when(mockPrefs.getInt('image_${personId}_timestamp'))
          .thenReturn(timestamp);
      when(mockPrefs.getString('image_$personId.jpg'))
          .thenReturn(base64Image);
      SharedPreferences.setMockInitialValues({
        'image_${personId}_timestamp': timestamp,
        'image_$personId.jpg': base64Image,
      });

      final result = await imageService.getCachedSchuetzenausweis(
        personId,
        validity,
      );

      expect(result, imageData);
    });

    test('web image retrieval with expired cache returns null', () async {
      final expiredTimestamp = timestamp - (validity.inMilliseconds + 1000);
      when(mockPrefs.getInt('image_${personId}_timestamp'))
          .thenReturn(expiredTimestamp);
      SharedPreferences.setMockInitialValues({
        'image_${personId}_timestamp': expiredTimestamp,
      });

      final result = await imageService.getCachedSchuetzenausweis(
        personId,
        validity,
      );

      expect(result, null);
    });
  });

  group('Mobile/Desktop Implementation Tests', () {
    setUp(() {
      // Mock kIsWeb to false for mobile/desktop tests
      TestWidgetsFlutterBinding.ensureInitialized();
      (TestWidgetsFlutterBinding.instance as TestWidgetsFlutterBinding)
          .window
          .debugOverrideDevicePixelRatio = 0.0;
    });

    test('successful mobile/desktop image caching', () async {
      when(mockDirectory.path).thenReturn('/test/directory');
      when(mockFile.writeAsBytes(any)).thenAnswer((_) async => mockFile);
      when(mockPrefs.setInt('image_${personId}_timestamp', any))
          .thenAnswer((_) async => true);
      when(getApplicationDocumentsDirectory())
          .thenAnswer((_) async => mockDirectory);
      when(mockFile.exists()).thenAnswer((_) async => true);
      when(mockFile.stat()).thenAnswer((_) async => mockFileStat);
      when(mockFileStat.modified)
          .thenReturn(DateTime.now());

      await imageService.cacheSchuetzenausweis(personId, imageData, timestamp);

      verify(mockFile.writeAsBytes(imageData)).called(1);
      verify(mockPrefs.setInt('image_${personId}_timestamp', any)).called(1);
    });

    test('successful mobile/desktop image retrieval', () async {
      when(mockDirectory.path).thenReturn('/test/directory');
      when(mockFile.exists()).thenAnswer((_) async => true);
      when(mockFile.stat()).thenAnswer((_) async => mockFileStat);
      when(mockFileStat.modified)
          .thenReturn(DateTime.now());
      when(mockFile.readAsBytes()).thenAnswer((_) async => imageData);
      when(getApplicationDocumentsDirectory())
          .thenAnswer((_) async => mockDirectory);

      final result = await imageService.getCachedSchuetzenausweis(
        personId,
        validity,
      );

      expect(result, imageData);
    });

    test('mobile/desktop image retrieval with expired cache returns null', () async {
      when(mockDirectory.path).thenReturn('/test/directory');
      when(mockFile.exists()).thenAnswer((_) async => true);
      when(mockFile.stat()).thenAnswer((_) async => mockFileStat);
      when(mockFileStat.modified)
          .thenReturn(DateTime.now().subtract(validity + const Duration(seconds: 1)));
      when(getApplicationDocumentsDirectory())
          .thenAnswer((_) async => mockDirectory);

      final result = await imageService.getCachedSchuetzenausweis(
        personId,
        validity,
      );

      expect(result, null);
    });

    test('mobile/desktop image retrieval for non-existent file returns null', () async {
      when(mockDirectory.path).thenReturn('/test/directory');
      when(mockFile.exists()).thenAnswer((_) async => false);
      when(getApplicationDocumentsDirectory())
          .thenAnswer((_) async => mockDirectory);

      final result = await imageService.getCachedSchuetzenausweis(
        personId,
        validity,
      );

      expect(result, null);
    });
  });
} 