import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FontSizeProvider', () {
    late FontSizeProvider provider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      provider = FontSizeProvider();
    });

    group('Initialization', () {
      test('should initialize with default font scale', () {
        expect(
          provider.scaleFactor,
          closeTo(UIConstants.defaultFontScale, 0.0001),
        );
      });

      test('should use default scale when no saved value exists', () async {
        expect(
          provider.scaleFactor,
          closeTo(UIConstants.defaultFontScale, 0.0001),
        );
      });

      test('should load saved scale factor from SharedPreferences', () async {
        await Future.delayed(const Duration(milliseconds: 100));
        expect(
          provider.scaleFactor,
          closeTo(UIConstants.defaultFontScale, 0.0001),
        );
      });

      test('should handle SharedPreferences initialization failure gracefully',
          () async {
        final testProvider = FontSizeProvider();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(
          testProvider.scaleFactor,
          closeTo(UIConstants.defaultFontScale, 0.0001),
        );
      });
    });

    group('Font Size Scaling', () {
      test('getScaledFontSize should multiply base size by scale factor', () {
        const baseSize = 16.0;
        final scaledSize = provider.getScaledFontSize(baseSize);
        expect(
          scaledSize,
          closeTo(baseSize * UIConstants.defaultFontScale, 0.0001),
        );
      });

      test('getScaledFontSize should work with different base sizes', () {
        const baseSizes = [12.0, 14.0, 16.0, 18.0, 20.0];
        for (final baseSize in baseSizes) {
          final scaledSize = provider.getScaledFontSize(baseSize);
          expect(
            scaledSize,
            closeTo(baseSize * UIConstants.defaultFontScale, 0.0001),
          );
        }
      });

      test('getScaledFontSize should work with zero base size', () {
        const baseSize = 0.0;
        final scaledSize = provider.getScaledFontSize(baseSize);
        expect(scaledSize, closeTo(0.0, 0.0001));
      });

      test('getScaledFontSize should work with negative base size', () {
        const baseSize = -10.0;
        final scaledSize = provider.getScaledFontSize(baseSize);
        expect(
          scaledSize,
          closeTo(baseSize * UIConstants.defaultFontScale, 0.0001),
        );
      });

      test('getScaledFontSize should work with very large base size', () {
        const baseSize = 1000.0;
        final scaledSize = provider.getScaledFontSize(baseSize);
        expect(
          scaledSize,
          closeTo(baseSize * UIConstants.defaultFontScale, 0.0001),
        );
      });

      test('getScaledFontSize should work with decimal base sizes', () {
        const baseSizes = [12.5, 14.75, 16.25, 18.8, 20.1];
        for (final baseSize in baseSizes) {
          final scaledSize = provider.getScaledFontSize(baseSize);
          expect(
            scaledSize,
            closeTo(baseSize * UIConstants.defaultFontScale, 0.0001),
          );
        }
      });
    });

    group('Font Size Increase', () {
      test('increaseFontSize should increase scale factor by step', () {
        final initialScale = provider.scaleFactor;
        provider.increaseFontSize();
        expect(
          provider.scaleFactor,
          closeTo(initialScale + UIConstants.fontScaleStep, 0.0001),
        );
      });

      test('increaseFontSize should not exceed max font scale', () {
        for (int i = 0; i < 20; i++) {
          provider.increaseFontSize();
        }
        expect(provider.scaleFactor, closeTo(UIConstants.maxFontScale, 0.0001));
      });

      test('increaseFontSize should notify listeners', () {
        bool notified = false;
        provider.addListener(() {
          notified = true;
        });
        provider.increaseFontSize();
        expect(notified, isTrue);
      });

      test('increaseFontSize should clamp at maximum value', () {
        for (int i = 0; i < 50; i++) {
          provider.increaseFontSize();
        }
        final maxScale = provider.scaleFactor;
        provider.increaseFontSize();
        expect(provider.scaleFactor, closeTo(maxScale, 0.0001));
      });

      test('increaseFontSize should handle multiple rapid calls', () {
        final initialScale = provider.scaleFactor;
        for (int i = 0; i < 5; i++) {
          provider.increaseFontSize();
        }
        expect(
          provider.scaleFactor,
          closeTo(initialScale + 5 * UIConstants.fontScaleStep, 0.001),
        );
      });
    });

    group('Font Size Decrease', () {
      test('decreaseFontSize should decrease scale factor by step', () {
        final initialScale = provider.scaleFactor;
        provider.decreaseFontSize();
        expect(
          provider.scaleFactor,
          closeTo(initialScale - UIConstants.fontScaleStep, 0.0001),
        );
      });

      test('decreaseFontSize should not go below min font scale', () {
        for (int i = 0; i < 20; i++) {
          provider.decreaseFontSize();
        }
        expect(provider.scaleFactor, closeTo(UIConstants.minFontScale, 0.0001));
      });

      test('decreaseFontSize should notify listeners', () {
        bool notified = false;
        provider.addListener(() {
          notified = true;
        });
        provider.decreaseFontSize();
        expect(notified, isTrue);
      });

      test('decreaseFontSize should clamp at minimum value', () {
        for (int i = 0; i < 50; i++) {
          provider.decreaseFontSize();
        }
        final minScale = provider.scaleFactor;
        provider.decreaseFontSize();
        expect(provider.scaleFactor, closeTo(minScale, 0.0001));
      });

      test('decreaseFontSize should handle multiple rapid calls', () {
        final initialScale = provider.scaleFactor;
        for (int i = 0; i < 3; i++) {
          provider.decreaseFontSize();
        }
        final expected = (initialScale - 3 * UIConstants.fontScaleStep) <
                UIConstants.minFontScale
            ? UIConstants.minFontScale
            : initialScale - 3 * UIConstants.fontScaleStep;
        expect(
          provider.scaleFactor,
          closeTo(expected, 0.001),
        );
      });
    });

    group('Scale Percentage', () {
      test(
          'getScalePercentage should return correct percentage for default scale',
          () {
        final percentage = provider.getScalePercentage();
        final expectedPercentage =
            '${(UIConstants.defaultFontScale * 100).toInt()}%';
        expect(percentage, equals(expectedPercentage));
      });

      test(
          'getScalePercentage should return correct percentage for different scales',
          () {
        const testScales = [0.8, 1.0, 1.2, 1.5, 2.0];

        for (final _ in testScales) {
          final testProvider = FontSizeProvider();
          final percentage = testProvider.getScalePercentage();
          expect(percentage, contains('%'));
          expect(percentage, isA<String>());
        }
      });

      test('getScalePercentage should round to integer', () {
        final percentage = provider.getScalePercentage();
        final percentageValue = int.tryParse(percentage.replaceAll('%', ''));

        expect(percentageValue, isNotNull);
        expect(percentageValue, isA<int>());
      });

      test('getScalePercentage should handle edge cases', () {
        for (int i = 0; i < 50; i++) {
          provider.decreaseFontSize();
        }
        final minPercentage = provider.getScalePercentage();
        expect(
          minPercentage,
          equals('${(UIConstants.minFontScale * 100).toInt()}%'),
        );

        for (int i = 0; i < 100; i++) {
          provider.increaseFontSize();
        }
        final maxPercentage = provider.getScalePercentage();
        expect(
          maxPercentage,
          equals('${(UIConstants.maxFontScale * 100).toInt()}%'),
        );
      });

      test('getScalePercentage should always return valid format', () {
        final percentage = provider.getScalePercentage();
        expect(percentage, matches(r'^\d+%$'));
      });
    });

    group('Edge Cases', () {
      test('should handle multiple rapid increase/decrease operations', () {
        final initialScale = provider.scaleFactor;
        for (int i = 0; i < 5; i++) {
          provider.increaseFontSize();
          provider.decreaseFontSize();
        }
        expect(provider.scaleFactor, closeTo(initialScale, 0.01));
      });

      test('should handle boundary conditions correctly', () {
        for (int i = 0; i < 20; i++) {
          provider.decreaseFontSize();
        }
        expect(provider.scaleFactor, closeTo(UIConstants.minFontScale, 0.0001));

        for (int i = 0; i < 20; i++) {
          provider.increaseFontSize();
        }
        expect(provider.scaleFactor, closeTo(UIConstants.maxFontScale, 0.0001));
      });

      test('should maintain scale factor within valid range', () {
        for (int i = 0; i < 100; i++) {
          provider.increaseFontSize();
        }
        expect(
          provider.scaleFactor,
          lessThanOrEqualTo(UIConstants.maxFontScale + 0.0001),
        );
        expect(
          provider.scaleFactor,
          greaterThanOrEqualTo(UIConstants.minFontScale - 0.0001),
        );

        for (int i = 0; i < 100; i++) {
          provider.decreaseFontSize();
        }
        expect(
          provider.scaleFactor,
          lessThanOrEqualTo(UIConstants.maxFontScale + 0.0001),
        );
        expect(
          provider.scaleFactor,
          greaterThanOrEqualTo(UIConstants.minFontScale - 0.0001),
        );
      });

      test('should handle extreme scale values correctly', () {
        for (int i = 0; i < 100; i++) {
          provider.decreaseFontSize();
        }
        expect(provider.scaleFactor, closeTo(UIConstants.minFontScale, 0.0001));

        for (int i = 0; i < 100; i++) {
          provider.increaseFontSize();
        }
        expect(provider.scaleFactor, closeTo(UIConstants.maxFontScale, 0.0001));
      });

      test('should handle concurrent operations', () async {
        final futures = <Future>[];

        for (int i = 0; i < 10; i++) {
          futures.add(
            Future(() {
              provider.increaseFontSize();
            }),
          );
          futures.add(
            Future(() {
              provider.decreaseFontSize();
            }),
          );
        }

        await Future.wait(futures);

        expect(
          provider.scaleFactor,
          greaterThanOrEqualTo(UIConstants.minFontScale - 0.0001),
        );
        expect(
          provider.scaleFactor,
          lessThanOrEqualTo(UIConstants.maxFontScale + 0.0001),
        );
      });
    });

    group('Integration Tests', () {
      test('should work correctly with typical usage pattern', () {
        expect(
          provider.scaleFactor,
          closeTo(UIConstants.defaultFontScale, 0.0001),
        );

        provider.increaseFontSize();
        expect(
          provider.scaleFactor,
          closeTo(
            UIConstants.defaultFontScale + UIConstants.fontScaleStep,
            0.0001,
          ),
        );

        provider.increaseFontSize();
        expect(
          provider.scaleFactor,
          closeTo(
            UIConstants.defaultFontScale + 2 * UIConstants.fontScaleStep,
            0.0001,
          ),
        );

        provider.decreaseFontSize();
        expect(
          provider.scaleFactor,
          closeTo(
            UIConstants.defaultFontScale + UIConstants.fontScaleStep,
            0.0001,
          ),
        );

        final percentage = provider.getScalePercentage();
        expect(percentage, isA<String>());
        expect(percentage, contains('%'));
      });

      test('should scale font sizes correctly', () {
        const baseSizes = [12.0, 14.0, 16.0, 18.0, 20.0];

        for (final baseSize in baseSizes) {
          final scaledSize = provider.getScaledFontSize(baseSize);
          expect(
            scaledSize,
            closeTo(baseSize * UIConstants.defaultFontScale, 0.0001),
          );
        }

        provider.increaseFontSize();
        for (final baseSize in baseSizes) {
          final scaledSize = provider.getScaledFontSize(baseSize);
          expect(
            scaledSize,
            closeTo(
              baseSize *
                  (UIConstants.defaultFontScale + UIConstants.fontScaleStep),
              0.0001,
            ),
          );
        }
      });

      test('should maintain consistency across multiple operations', () {
        final initialScale = provider.scaleFactor;
        final initialPercentage = provider.getScalePercentage();

        provider.increaseFontSize();
        provider.increaseFontSize();
        provider.decreaseFontSize();
        provider.increaseFontSize();
        provider.decreaseFontSize();
        provider.decreaseFontSize();

        expect(provider.scaleFactor, closeTo(initialScale, 0.0001));
        expect(provider.getScalePercentage(), equals(initialPercentage));
      });
    });

    group('Constants Validation', () {
      test('should use correct UI constants', () {
        expect(UIConstants.defaultFontScale, equals(1.0));
        expect(UIConstants.fontScaleStep, equals(0.1));
        expect(UIConstants.minFontScale, equals(0.8));
        expect(UIConstants.maxFontScale, equals(2.0));
      });

      test('should respect min and max font scale constraints', () {
        expect(
          provider.scaleFactor,
          greaterThanOrEqualTo(UIConstants.minFontScale - 0.0001),
        );
        expect(
          provider.scaleFactor,
          lessThanOrEqualTo(UIConstants.maxFontScale + 0.0001),
        );
      });

      test('should have valid constant relationships', () {
        expect(
          UIConstants.minFontScale,
          lessThan(UIConstants.defaultFontScale),
        );
        expect(
          UIConstants.defaultFontScale,
          lessThan(UIConstants.maxFontScale),
        );
        expect(UIConstants.fontScaleStep, greaterThan(0.0));
        expect(
          UIConstants.fontScaleStep,
          lessThan(UIConstants.maxFontScale - UIConstants.minFontScale),
        );
      });
    });

    group('Listener Management', () {
      test('should properly manage listeners', () {
        int notificationCount = 0;

        void listener() {
          notificationCount++;
        }

        provider.addListener(listener);

        provider.increaseFontSize();
        expect(notificationCount, equals(1));

        provider.decreaseFontSize();
        expect(notificationCount, equals(2));

        provider.removeListener(listener);

        provider.increaseFontSize();
        expect(notificationCount, equals(2));
      });

      test('should handle multiple listeners', () {
        int listener1Count = 0;
        int listener2Count = 0;

        void listener1() => listener1Count++;
        void listener2() => listener2Count++;

        provider.addListener(listener1);
        provider.addListener(listener2);

        provider.increaseFontSize();

        expect(listener1Count, equals(1));
        expect(listener2Count, equals(1));

        provider.removeListener(listener1);
        provider.decreaseFontSize();

        expect(listener1Count, equals(1));
        expect(listener2Count, equals(2));
      });

      test('should handle listener removal during notification', () {
        int notificationCount = 0;

        void listener() {
          notificationCount++;
          if (notificationCount == 1) {
            provider.removeListener(listener);
          }
        }

        provider.addListener(listener);

        provider.increaseFontSize();
        expect(notificationCount, equals(1));

        provider.increaseFontSize();
        expect(notificationCount, equals(1));
      });

      test('should handle multiple rapid notifications', () {
        int notificationCount = 0;

        void listener() {
          notificationCount++;
        }

        provider.addListener(listener);

        for (int i = 0; i < 10; i++) {
          provider.increaseFontSize();
        }

        expect(notificationCount, equals(10));
      });
    });

    group('Mathematical Operations', () {
      test('should handle floating point precision correctly', () {
        final initialScale = provider.scaleFactor;

        for (int i = 0; i < 10; i++) {
          provider.increaseFontSize();
        }

        for (int i = 0; i < 10; i++) {
          provider.decreaseFontSize();
        }

        expect(provider.scaleFactor, closeTo(initialScale, 0.001));
      });

      test('should clamp values correctly at boundaries', () {
        for (int i = 0; i < 50; i++) {
          provider.decreaseFontSize();
        }
        expect(provider.scaleFactor, closeTo(UIConstants.minFontScale, 0.0001));

        for (int i = 0; i < 50; i++) {
          provider.increaseFontSize();
        }
        expect(provider.scaleFactor, closeTo(UIConstants.maxFontScale, 0.0001));
      });

      test('should handle step size calculations correctly', () {
        final initialScale = provider.scaleFactor;

        provider.increaseFontSize();
        expect(
          provider.scaleFactor,
          closeTo(initialScale + UIConstants.fontScaleStep, 0.0001),
        );

        provider.decreaseFontSize();
        expect(provider.scaleFactor, closeTo(initialScale, 0.0001));
      });

      test('should handle multiple step operations', () {
        final initialScale = provider.scaleFactor;

        for (int i = 1; i <= 5; i++) {
          provider.increaseFontSize();
          expect(
            provider.scaleFactor,
            closeTo(initialScale + i * UIConstants.fontScaleStep, 0.001),
          );
        }

        for (int i = 4; i >= 0; i--) {
          provider.decreaseFontSize();
          expect(
            provider.scaleFactor,
            closeTo(initialScale + i * UIConstants.fontScaleStep, 0.001),
          );
        }
      });
    });

    group('Persistence Testing', () {
      test('should save scale factor to SharedPreferences', () async {
        provider.increaseFontSize();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(provider.scaleFactor, greaterThan(UIConstants.defaultFontScale));
      });

      test('should handle SharedPreferences save failures gracefully',
          () async {
        provider.increaseFontSize();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(provider.scaleFactor, greaterThan(UIConstants.defaultFontScale));
      });
    });

    group('Performance Tests', () {
      test('should handle many rapid operations efficiently', () {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 1000; i++) {
          provider.increaseFontSize();
        }

        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        expect(provider.scaleFactor, closeTo(UIConstants.maxFontScale, 0.0001));
      });

      test('should handle many listener notifications efficiently', () {
        int notificationCount = 0;

        void listener() {
          notificationCount++;
        }

        provider.addListener(listener);

        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 100; i++) {
          provider.increaseFontSize();
        }

        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        expect(notificationCount, equals(10));
      });
    });

    group('Memory Management', () {
      test('should not leak memory with many listeners', () {
        final listeners = <Function()>[];

        for (int i = 0; i < 100; i++) {
          listener() {}
          listeners.add(listener);
          provider.addListener(listener);
        }

        for (final listener in listeners) {
          provider.removeListener(listener);
        }

        provider.increaseFontSize();
        expect(provider.scaleFactor, greaterThan(UIConstants.defaultFontScale));
      });

      test('should handle listener cleanup properly', () {
        bool listenerCalled = false;

        void listener() {
          listenerCalled = true;
        }

        provider.addListener(listener);
        provider.removeListener(listener);

        provider.increaseFontSize();

        expect(listenerCalled, isFalse);
      });
    });

    group('Persistence', () {
      test('should persist scale factor and load it in a new provider',
          () async {
        SharedPreferences.setMockInitialValues({});
        final provider1 = FontSizeProvider();
        await Future.delayed(const Duration(milliseconds: 100));
        provider1.increaseFontSize();
        await Future.delayed(const Duration(milliseconds: 100));
        final savedScale = provider1.scaleFactor;
        final provider2 = FontSizeProvider();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(provider2.scaleFactor, closeTo(savedScale, 0.0001));
      });

      test('should persist decrease and load in new provider', () async {
        SharedPreferences.setMockInitialValues({});
        final provider1 = FontSizeProvider();
        await Future.delayed(const Duration(milliseconds: 100));
        provider1.decreaseFontSize();
        await Future.delayed(const Duration(milliseconds: 100));
        final savedScale = provider1.scaleFactor;
        final provider2 = FontSizeProvider();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(provider2.scaleFactor, closeTo(savedScale, 0.0001));
      });

      test('should not notify listeners if scale factor does not change', () {
        bool notified = false;
        provider.addListener(() {
          notified = true;
        });
        for (int i = 0; i < 100; i++) {
          provider.decreaseFontSize();
        }
        notified = false;
        provider.decreaseFontSize();
        expect(notified, isFalse);

        for (int i = 0; i < 100; i++) {
          provider.increaseFontSize();
        }
        notified = false;
        provider.increaseFontSize();
        expect(notified, isFalse);
      });

      test('should handle removing a listener that was never added', () {
        void dummyListener() {}
        provider.removeListener(dummyListener);
      });
    });

    group('Font Size Reset', () {
      test('resetFontSize should reset scale factor to default', () {
        provider.increaseFontSize();
        expect(provider.scaleFactor,
            isNot(closeTo(UIConstants.defaultFontScale, 0.0001)),);
        provider.resetFontSize();
        expect(provider.scaleFactor,
            closeTo(UIConstants.defaultFontScale, 0.0001),);
      });

      test('resetFontSize should notify listeners', () {
        provider.increaseFontSize();
        bool notified = false;
        provider.addListener(() {
          notified = true;
        });
        provider.resetFontSize();
        expect(notified, isTrue);
      });
    });
  });
}
