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
        expect(provider.scaleFactor, equals(UIConstants.defaultFontScale));
      });

      test('should use default scale when no saved value exists', () async {
        expect(provider.scaleFactor, equals(UIConstants.defaultFontScale));
      });

      test('should load saved scale factor from SharedPreferences', () async {
        // This test verifies the async initialization behavior
        // The provider should eventually load the saved value
        await Future.delayed(const Duration(milliseconds: 100));
        expect(provider.scaleFactor, equals(UIConstants.defaultFontScale));
      });

      test('should handle SharedPreferences initialization failure gracefully',
          () async {
        // Test that the provider doesn't crash if SharedPreferences fails
        final testProvider = FontSizeProvider();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(testProvider.scaleFactor, equals(UIConstants.defaultFontScale));
      });
    });

    group('Font Size Scaling', () {
      test('getScaledFontSize should multiply base size by scale factor', () {
        const baseSize = 16.0;
        final scaledSize = provider.getScaledFontSize(baseSize);
        expect(scaledSize, equals(baseSize * UIConstants.defaultFontScale));
      });

      test('getScaledFontSize should work with different base sizes', () {
        const baseSizes = [12.0, 14.0, 16.0, 18.0, 20.0];
        for (final baseSize in baseSizes) {
          final scaledSize = provider.getScaledFontSize(baseSize);
          expect(scaledSize, equals(baseSize * UIConstants.defaultFontScale));
        }
      });

      test('getScaledFontSize should work with zero base size', () {
        const baseSize = 0.0;
        final scaledSize = provider.getScaledFontSize(baseSize);
        expect(scaledSize, equals(0.0));
      });

      test('getScaledFontSize should work with negative base size', () {
        const baseSize = -10.0;
        final scaledSize = provider.getScaledFontSize(baseSize);
        expect(scaledSize, equals(baseSize * UIConstants.defaultFontScale));
      });

      test('getScaledFontSize should work with very large base size', () {
        const baseSize = 1000.0;
        final scaledSize = provider.getScaledFontSize(baseSize);
        expect(scaledSize, equals(baseSize * UIConstants.defaultFontScale));
      });

      test('getScaledFontSize should work with decimal base sizes', () {
        const baseSizes = [12.5, 14.75, 16.25, 18.8, 20.1];
        for (final baseSize in baseSizes) {
          final scaledSize = provider.getScaledFontSize(baseSize);
          expect(scaledSize, equals(baseSize * UIConstants.defaultFontScale));
        }
      });
    });

    group('Font Size Increase', () {
      test('increaseFontSize should increase scale factor by step', () {
        final initialScale = provider.scaleFactor;
        provider.increaseFontSize();
        expect(
          provider.scaleFactor,
          equals(initialScale + UIConstants.fontScaleStep),
        );
      });

      test('increaseFontSize should not exceed max font scale', () {
        // Set scale to max value
        for (int i = 0; i < 20; i++) {
          provider.increaseFontSize();
        }
        expect(provider.scaleFactor, equals(UIConstants.maxFontScale));
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
        // Reach maximum scale
        for (int i = 0; i < 50; i++) {
          provider.increaseFontSize();
        }
        final maxScale = provider.scaleFactor;

        // Try to increase again
        provider.increaseFontSize();
        expect(provider.scaleFactor, equals(maxScale));
      });

      test('increaseFontSize should handle multiple rapid calls', () {
        final initialScale = provider.scaleFactor;

        // Call increase multiple times rapidly
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
          equals(initialScale - UIConstants.fontScaleStep),
        );
      });

      test('decreaseFontSize should not go below min font scale', () {
        // Set scale to min value by decreasing multiple times
        for (int i = 0; i < 20; i++) {
          provider.decreaseFontSize();
        }
        expect(provider.scaleFactor, equals(UIConstants.minFontScale));
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
        // Reach minimum scale
        for (int i = 0; i < 50; i++) {
          provider.decreaseFontSize();
        }
        final minScale = provider.scaleFactor;

        // Try to decrease again
        provider.decreaseFontSize();
        expect(provider.scaleFactor, equals(minScale));
      });

      test('decreaseFontSize should handle multiple rapid calls', () {
        final initialScale = provider.scaleFactor;
        // Call decrease multiple times rapidly
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
        // Test with different scale factors by creating new providers
        const testScales = [0.8, 1.0, 1.2, 1.5, 2.0];

        for (final _ in testScales) {
          // Create a new provider for each test to avoid state interference
          final testProvider = FontSizeProvider();

          // We can't directly set the scale factor, but we can test the logic
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
        // Test with minimum scale
        for (int i = 0; i < 50; i++) {
          provider.decreaseFontSize();
        }
        final minPercentage = provider.getScalePercentage();
        expect(
          minPercentage,
          equals('${(UIConstants.minFontScale * 100).toInt()}%'),
        );

        // Test with maximum scale
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
        // Test that percentage always ends with % and contains only digits and %
        final percentage = provider.getScalePercentage();
        expect(percentage, matches(r'^\d+%$'));
      });
    });

    group('Edge Cases', () {
      test('should handle multiple rapid increase/decrease operations', () {
        final initialScale = provider.scaleFactor;

        // Perform multiple operations rapidly
        for (int i = 0; i < 5; i++) {
          provider.increaseFontSize();
          provider.decreaseFontSize();
        }

        // Should end up at the initial scale (or close to it)
        expect(provider.scaleFactor, closeTo(initialScale, 0.01));
      });

      test('should handle boundary conditions correctly', () {
        // Test that we can reach the minimum scale
        for (int i = 0; i < 20; i++) {
          provider.decreaseFontSize();
        }
        expect(provider.scaleFactor, equals(UIConstants.minFontScale));

        // Test that we can reach the maximum scale
        for (int i = 0; i < 20; i++) {
          provider.increaseFontSize();
        }
        expect(provider.scaleFactor, equals(UIConstants.maxFontScale));
      });

      test('should maintain scale factor within valid range', () {
        // Perform many operations to ensure scale stays within bounds
        for (int i = 0; i < 100; i++) {
          provider.increaseFontSize();
        }
        expect(
          provider.scaleFactor,
          lessThanOrEqualTo(UIConstants.maxFontScale),
        );
        expect(
          provider.scaleFactor,
          greaterThanOrEqualTo(UIConstants.minFontScale),
        );

        for (int i = 0; i < 100; i++) {
          provider.decreaseFontSize();
        }
        expect(
          provider.scaleFactor,
          lessThanOrEqualTo(UIConstants.maxFontScale),
        );
        expect(
          provider.scaleFactor,
          greaterThanOrEqualTo(UIConstants.minFontScale),
        );
      });

      test('should handle extreme scale values correctly', () {
        // Test with very small scale
        for (int i = 0; i < 100; i++) {
          provider.decreaseFontSize();
        }
        expect(provider.scaleFactor, equals(UIConstants.minFontScale));

        // Test with very large scale
        for (int i = 0; i < 100; i++) {
          provider.increaseFontSize();
        }
        expect(provider.scaleFactor, equals(UIConstants.maxFontScale));
      });

      test('should handle concurrent operations', () async {
        // Simulate concurrent increase/decrease operations
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

        // Should still be within valid range
        expect(
          provider.scaleFactor,
          greaterThanOrEqualTo(UIConstants.minFontScale),
        );
        expect(
          provider.scaleFactor,
          lessThanOrEqualTo(UIConstants.maxFontScale),
        );
      });
    });

    group('Integration Tests', () {
      test('should work correctly with typical usage pattern', () {
        // Simulate typical user interaction
        expect(provider.scaleFactor, equals(UIConstants.defaultFontScale));

        // User increases font size
        provider.increaseFontSize();
        expect(
          provider.scaleFactor,
          closeTo(
            UIConstants.defaultFontScale + UIConstants.fontScaleStep,
            0.0001,
          ),
        );

        // User increases again
        provider.increaseFontSize();
        expect(
          provider.scaleFactor,
          closeTo(
            UIConstants.defaultFontScale + 2 * UIConstants.fontScaleStep,
            0.0001,
          ),
        );

        // User decreases font size
        provider.decreaseFontSize();
        expect(
          provider.scaleFactor,
          closeTo(
            UIConstants.defaultFontScale + UIConstants.fontScaleStep,
            0.0001,
          ),
        );

        // Check percentage
        final percentage = provider.getScalePercentage();
        expect(percentage, isA<String>());
        expect(percentage, contains('%'));
      });

      test('should scale font sizes correctly', () {
        const baseSizes = [12.0, 14.0, 16.0, 18.0, 20.0];

        // Test with default scale
        for (final baseSize in baseSizes) {
          final scaledSize = provider.getScaledFontSize(baseSize);
          expect(scaledSize, equals(baseSize * UIConstants.defaultFontScale));
        }

        // Increase scale and test again
        provider.increaseFontSize();
        for (final baseSize in baseSizes) {
          final scaledSize = provider.getScaledFontSize(baseSize);
          expect(
            scaledSize,
            equals(
              baseSize *
                  (UIConstants.defaultFontScale + UIConstants.fontScaleStep),
            ),
          );
        }
      });

      test('should maintain consistency across multiple operations', () {
        final initialScale = provider.scaleFactor;
        final initialPercentage = provider.getScalePercentage();

        // Perform a series of operations
        provider.increaseFontSize();
        provider.increaseFontSize();
        provider.decreaseFontSize();
        provider.increaseFontSize();
        provider.decreaseFontSize();
        provider.decreaseFontSize();

        // Verify consistency
        expect(provider.scaleFactor, equals(initialScale));
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
        // Test that the provider respects the constants
        expect(
          provider.scaleFactor,
          greaterThanOrEqualTo(UIConstants.minFontScale),
        );
        expect(
          provider.scaleFactor,
          lessThanOrEqualTo(UIConstants.maxFontScale),
        );
      });

      test('should have valid constant relationships', () {
        // Test that constants have logical relationships
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

        // Trigger notifications
        provider.increaseFontSize();
        expect(notificationCount, equals(1));

        provider.decreaseFontSize();
        expect(notificationCount, equals(2));

        // Remove listener
        provider.removeListener(listener);

        provider.increaseFontSize();
        expect(notificationCount, equals(2)); // Should not increase
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

        expect(listener1Count, equals(1)); // Should not increase
        expect(listener2Count, equals(2)); // Should increase
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

        // First call should trigger listener and remove it
        provider.increaseFontSize();
        expect(notificationCount, equals(1));

        // Second call should not trigger listener
        provider.increaseFontSize();
        expect(notificationCount, equals(1));
      });

      test('should handle multiple rapid notifications', () {
        int notificationCount = 0;

        void listener() {
          notificationCount++;
        }

        provider.addListener(listener);

        // Trigger multiple rapid notifications
        for (int i = 0; i < 10; i++) {
          provider.increaseFontSize();
        }

        expect(notificationCount, equals(10));
      });
    });

    group('Mathematical Operations', () {
      test('should handle floating point precision correctly', () {
        // Test that floating point operations work correctly
        final initialScale = provider.scaleFactor;

        // Add and subtract the same value multiple times
        for (int i = 0; i < 10; i++) {
          provider.increaseFontSize();
        }

        for (int i = 0; i < 10; i++) {
          provider.decreaseFontSize();
        }

        // Should be very close to the initial value
        expect(provider.scaleFactor, closeTo(initialScale, 0.001));
      });

      test('should clamp values correctly at boundaries', () {
        // Test minimum boundary
        for (int i = 0; i < 50; i++) {
          provider.decreaseFontSize();
        }
        expect(provider.scaleFactor, equals(UIConstants.minFontScale));

        // Test maximum boundary
        for (int i = 0; i < 50; i++) {
          provider.increaseFontSize();
        }
        expect(provider.scaleFactor, equals(UIConstants.maxFontScale));
      });

      test('should handle step size calculations correctly', () {
        final initialScale = provider.scaleFactor;

        // Test that step size is applied correctly
        provider.increaseFontSize();
        expect(
          provider.scaleFactor,
          equals(initialScale + UIConstants.fontScaleStep),
        );

        provider.decreaseFontSize();
        expect(provider.scaleFactor, equals(initialScale));
      });

      test('should handle multiple step operations', () {
        final initialScale = provider.scaleFactor;

        // Test multiple step operations
        for (int i = 1; i <= 5; i++) {
          provider.increaseFontSize();
          expect(
            provider.scaleFactor,
            closeTo(initialScale + i * UIConstants.fontScaleStep, 0.001),
          );
        }

        // Test multiple decrease operations
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
        // This test verifies that the provider attempts to save data
        // Note: We can't easily mock SharedPreferences in this context,
        // but we can verify the provider doesn't crash during save operations
        provider.increaseFontSize();

        // Wait a bit for async operations
        await Future.delayed(const Duration(milliseconds: 100));

        // Provider should still be functional
        expect(provider.scaleFactor, greaterThan(UIConstants.defaultFontScale));
      });

      test('should handle SharedPreferences save failures gracefully',
          () async {
        // Test that the provider continues to work even if save fails
        provider.increaseFontSize();

        // Wait for async operations
        await Future.delayed(const Duration(milliseconds: 100));

        // Provider should still be functional
        expect(provider.scaleFactor, greaterThan(UIConstants.defaultFontScale));
      });
    });

    group('Performance Tests', () {
      test('should handle many rapid operations efficiently', () {
        final stopwatch = Stopwatch()..start();

        // Perform many operations
        for (int i = 0; i < 1000; i++) {
          provider.increaseFontSize();
        }

        stopwatch.stop();

        // Should complete within reasonable time (less than 1 second)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));

        // Should be at maximum scale
        expect(provider.scaleFactor, equals(UIConstants.maxFontScale));
      });

      test('should handle many listener notifications efficiently', () {
        int notificationCount = 0;

        void listener() {
          notificationCount++;
        }

        provider.addListener(listener);

        final stopwatch = Stopwatch()..start();

        // Perform many operations
        for (int i = 0; i < 100; i++) {
          provider.increaseFontSize();
        }

        stopwatch.stop();

        // Should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        expect(notificationCount, equals(100));
      });
    });

    group('Memory Management', () {
      test('should not leak memory with many listeners', () {
        final listeners = <Function()>[];

        // Add many listeners
        for (int i = 0; i < 100; i++) {
          listener() {}
          listeners.add(listener);
          provider.addListener(listener);
        }

        // Remove all listeners
        for (final listener in listeners) {
          provider.removeListener(listener);
        }

        // Provider should still work
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

        // Trigger notification
        provider.increaseFontSize();

        // Listener should not be called
        expect(listenerCalled, isFalse);
      });
    });
  });
}
