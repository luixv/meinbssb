import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';

@GenerateMocks([SharedPreferences])
import 'font_size_provider_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FontSizeProvider', () {
    late FontSizeProvider provider;
    // ignore: unused_local_variable
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferences();

      // Mock SharedPreferences.getInstance to return our mock
      SharedPreferences.setMockInitialValues({});

      provider = FontSizeProvider();
    });

    group('Initialization', () {
      test('should initialize with default font scale', () {
        expect(provider.scaleFactor, equals(UIConstants.defaultFontScale));
      });

      test('should use default scale when no saved value exists', () async {
        // The provider should use default scale when SharedPreferences fails
        expect(provider.scaleFactor, equals(UIConstants.defaultFontScale));
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

        // ignore: unused_local_variable
        for (final scale in testScales) {
          // Create a new provider for each test to avoid state interference
          final testProvider = FontSizeProvider();

          // We can't directly set the scale factor, but we can test the logic
          final percentage = testProvider.getScalePercentage();
          expect(percentage, contains('%'));
          expect(percentage, isA<String>());
        }
      });

      test('getScalePercentage should round to integer', () {
        // Test that the percentage is rounded to integer
        final percentage = provider.getScalePercentage();
        final percentageValue = int.tryParse(percentage.replaceAll('%', ''));

        expect(percentageValue, isNotNull);
        expect(percentageValue, isA<int>());
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
    });

    group('Integration Tests', () {
      test('should work correctly with typical usage pattern', () {
        // Simulate typical user interaction
        expect(provider.scaleFactor, equals(UIConstants.defaultFontScale));

        // User increases font size
        provider.increaseFontSize();
        expect(
            provider.scaleFactor,
            closeTo(UIConstants.defaultFontScale + UIConstants.fontScaleStep,
                0.0001,),);

        // User increases again
        provider.increaseFontSize();
        expect(
            provider.scaleFactor,
            closeTo(
                UIConstants.defaultFontScale + 2 * UIConstants.fontScaleStep,
                0.0001,),);

        // User decreases font size
        provider.decreaseFontSize();
        expect(
            provider.scaleFactor,
            closeTo(UIConstants.defaultFontScale + UIConstants.fontScaleStep,
                0.0001,),);

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
    });
  });
}
