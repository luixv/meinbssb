import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/splash_screen.dart';
import 'package:meinbssb/constants/ui_constants.dart';

void main() {
  group('SplashScreen', () {
    late VoidCallback mockOnFinish;

    setUp(() {
      mockOnFinish = () {};
    });

    Widget createSplashScreen() {
      return MaterialApp(
        home: SplashScreen(onFinish: mockOnFinish),
      );
    }

    testWidgets('should render with correct structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSplashScreen());

      // Verify Scaffold exists
      expect(find.byType(Scaffold), findsOneWidget);

      // Verify background color is white
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.white);

      // Verify Center widget exists
      expect(find.byType(Center), findsOneWidget);

      // Verify FadeTransition exists
      expect(find.byType(FadeTransition), findsOneWidget);

      // Verify Image.asset exists
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should display BSSB logo with correct properties',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSplashScreen());

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final image = tester.widget<Image>(imageFinder);
      expect(image.image, isA<AssetImage>());
      expect(
        (image.image as AssetImage).assetName,
        'assets/images/BSSB_Wappen.png',
      );

      // Verify logo size is 2x the UIConstants.logoSize
      expect(image.width, UIConstants.logoSize * 2);
      expect(image.height, UIConstants.logoSize * 2);
    });

    testWidgets('should start with opacity 0 and animate to 1',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSplashScreen());

      // Initially, the animation should be at 0 opacity
      final fadeTransition =
          tester.widget<FadeTransition>(find.byType(FadeTransition));
      expect(fadeTransition.opacity.value, 0.0);

      // Wait for all animations to complete
      await tester.pumpAndSettle();

      // After animation completes, opacity should be 1.0
      final updatedFadeTransition =
          tester.widget<FadeTransition>(find.byType(FadeTransition));
      expect(updatedFadeTransition.opacity.value, 1.0);
    });

    testWidgets('should call onFinish callback after animation completes',
        (WidgetTester tester) async {
      bool callbackCalled = false;
      void testOnFinish() {
        callbackCalled = true;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(onFinish: testOnFinish),
        ),
      );

      // Initially callback should not be called
      expect(callbackCalled, false);

      // Wait for all animations to complete
      await tester.pumpAndSettle();

      // Callback should be called after animation
      expect(callbackCalled, true);
    });

    testWidgets('should handle animation controller lifecycle correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSplashScreen());

      // Widget should be created without errors
      expect(find.byType(SplashScreen), findsOneWidget);

      // Dispose the widget
      await tester.pumpWidget(Container());

      // Should not throw any errors during disposal
      expect(tester.takeException(), isNull);
    });

    testWidgets('should use correct animation duration',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSplashScreen());

      // Test that the animation completes after the expected duration
      // by checking that the callback is called after multiple pumps
      bool callbackCalled = false;
      void testOnFinish() {
        callbackCalled = true;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(onFinish: testOnFinish),
        ),
      );

      // Pump less than 3 seconds - callback should not be called
      await tester.pump(const Duration(milliseconds: 2500));
      expect(callbackCalled, false);

      // Wait for all animations to complete - callback should be called
      await tester.pumpAndSettle();
      expect(callbackCalled, true);
    });

    testWidgets('should use easeIn curve for animation',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSplashScreen());

      final fadeTransition =
          tester.widget<FadeTransition>(find.byType(FadeTransition));
      final animation = fadeTransition.opacity;

      // Test that the animation uses easeIn curve by checking intermediate values
      await tester.pump(const Duration(milliseconds: 500));
      final midValue = animation.value;

      // With easeIn, the value should be less than 0.5 at 500ms (1/6 of total duration)
      expect(midValue, lessThan(0.5));
    });

    testWidgets('should handle rapid widget rebuilds gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSplashScreen());
      await tester.pump(const Duration(milliseconds: 100));

      // Rebuild widget multiple times
      await tester.pumpWidget(createSplashScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpWidget(createSplashScreen());

      // Should not throw any errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('should maintain correct widget structure during animation',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSplashScreen());

      // Check structure at different animation stages
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1500));
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should handle null onFinish callback gracefully',
        (WidgetTester tester) async {
      // This test ensures the widget doesn't crash if onFinish is null
      // Note: The widget requires onFinish, so we'll test with an empty function
      void emptyCallback() {}

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(onFinish: emptyCallback),
        ),
      );

      // Wait for animation to complete
      await tester.pump(const Duration(seconds: 3));

      // Should not throw any errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('should be responsive to different screen sizes',
        (WidgetTester tester) async {
      // Test with different screen sizes
      await tester.binding.setSurfaceSize(const Size(400, 600));
      await tester.pumpWidget(createSplashScreen());

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);

      // Test with larger screen
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(createSplashScreen());

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);

      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should handle widget disposal during animation',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSplashScreen());

      // Start animation
      await tester.pump(const Duration(milliseconds: 1000));

      // Dispose widget mid-animation
      await tester.pumpWidget(Container());

      // Should not throw any errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('should verify logo asset exists', (WidgetTester tester) async {
      await tester.pumpWidget(createSplashScreen());

      final imageFinder = find.byType(Image);
      final image = tester.widget<Image>(imageFinder);

      // Verify the asset path is correct
      expect(
        (image.image as AssetImage).assetName,
        'assets/images/BSSB_Wappen.png',
      );
    });
  });
}
