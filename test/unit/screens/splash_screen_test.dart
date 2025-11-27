import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/splash_screen.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/models/bezirk_data.dart';
import 'package:meinbssb/models/disziplin_data.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';

// Generate mocks
@GenerateMocks([ApiService])
import 'splash_screen_test.mocks.dart';

void main() {
  group('SplashScreen', () {
    late VoidCallback mockOnFinish;
    late MockApiService mockApiService;

    setUp(() {
      mockOnFinish = () {};
      mockApiService = MockApiService();
    });

    Widget createSplashScreen({VoidCallback? onFinish}) {
      return MaterialApp(
        home: Provider<ApiService>(
          create: (_) => mockApiService,
          child: SplashScreen(onFinish: onFinish ?? mockOnFinish),
        ),
      );
    }

    testWidgets('should display BSSB logo with correct properties', (
      WidgetTester tester,
    ) async {
      when(
        mockApiService.fetchBezirkeforSearch(),
      ).thenAnswer((_) async => <BezirkSearchTriple>[]);
      when(
        mockApiService.fetchDisziplinen(),
      ).thenAnswer((_) async => <Disziplin>[]);

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
    testWidgets('should call onFinish callback after animation completes', (
      WidgetTester tester,
    ) async {
      when(
        mockApiService.fetchBezirkeforSearch(),
      ).thenAnswer((_) async => <BezirkSearchTriple>[]);
      when(
        mockApiService.fetchDisziplinen(),
      ).thenAnswer((_) async => <Disziplin>[]);

      bool callbackCalled = false;
      void testOnFinish() {
        callbackCalled = true;
      }

      await tester.pumpWidget(createSplashScreen(onFinish: testOnFinish));

      // Initially callback should not be called
      expect(callbackCalled, false);

      // Wait for all animations to complete
      await tester.pumpAndSettle();

      // Callback should be called after animation
      expect(callbackCalled, true);
    });

    testWidgets('should handle animation controller lifecycle correctly', (
      WidgetTester tester,
    ) async {
      when(
        mockApiService.fetchBezirkeforSearch(),
      ).thenAnswer((_) async => <BezirkSearchTriple>[]);
      when(
        mockApiService.fetchDisziplinen(),
      ).thenAnswer((_) async => <Disziplin>[]);

      await tester.pumpWidget(createSplashScreen());

      // Widget should be created without errors
      expect(find.byType(SplashScreen), findsOneWidget);

      // Dispose the widget
      await tester.pumpWidget(Container());

      // Should not throw any errors during disposal
      expect(tester.takeException(), isNull);
    });

    testWidgets('should use correct animation duration', (
      WidgetTester tester,
    ) async {
      when(
        mockApiService.fetchBezirkeforSearch(),
      ).thenAnswer((_) async => <BezirkSearchTriple>[]);
      when(
        mockApiService.fetchDisziplinen(),
      ).thenAnswer((_) async => <Disziplin>[]);

      bool callbackCalled = false;
      void testOnFinish() {
        callbackCalled = true;
      }

      await tester.pumpWidget(createSplashScreen(onFinish: testOnFinish));

      // Pump less than 3 seconds - callback should not be called
      await tester.pump(const Duration(milliseconds: 2500));
      expect(callbackCalled, false);

      // Wait for all animations to complete - callback should be called
      await tester.pumpAndSettle();
      expect(callbackCalled, true);
    });

    testWidgets('should handle rapid widget rebuilds gracefully', (
      WidgetTester tester,
    ) async {
      when(
        mockApiService.fetchBezirkeforSearch(),
      ).thenAnswer((_) async => <BezirkSearchTriple>[]);
      when(
        mockApiService.fetchDisziplinen(),
      ).thenAnswer((_) async => <Disziplin>[]);

      await tester.pumpWidget(createSplashScreen());
      await tester.pump(const Duration(milliseconds: 100));

      // Rebuild widget multiple times
      await tester.pumpWidget(createSplashScreen());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpWidget(createSplashScreen());

      // Should not throw any errors
      expect(tester.takeException(), isNull);
    });
    testWidgets('should handle empty callback gracefully', (
      WidgetTester tester,
    ) async {
      when(
        mockApiService.fetchBezirkeforSearch(),
      ).thenAnswer((_) async => <BezirkSearchTriple>[]);
      when(
        mockApiService.fetchDisziplinen(),
      ).thenAnswer((_) async => <Disziplin>[]);

      void emptyCallback() {}

      await tester.pumpWidget(createSplashScreen(onFinish: emptyCallback));

      // Wait for animation to complete
      await tester.pump(const Duration(seconds: 3));

      // Should not throw any errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('should be responsive to different screen sizes', (
      WidgetTester tester,
    ) async {
      when(
        mockApiService.fetchBezirkeforSearch(),
      ).thenAnswer((_) async => <BezirkSearchTriple>[]);
      when(
        mockApiService.fetchDisziplinen(),
      ).thenAnswer((_) async => <Disziplin>[]);

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

    testWidgets('should handle widget disposal during animation', (
      WidgetTester tester,
    ) async {
      when(
        mockApiService.fetchBezirkeforSearch(),
      ).thenAnswer((_) async => <BezirkSearchTriple>[]);
      when(
        mockApiService.fetchDisziplinen(),
      ).thenAnswer((_) async => <Disziplin>[]);

      await tester.pumpWidget(createSplashScreen());

      // Start animation
      await tester.pump(const Duration(milliseconds: 1000));

      // Dispose widget mid-animation
      await tester.pumpWidget(Container());

      // Should not throw any errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('should verify logo asset exists', (WidgetTester tester) async {
      when(
        mockApiService.fetchBezirkeforSearch(),
      ).thenAnswer((_) async => <BezirkSearchTriple>[]);
      when(
        mockApiService.fetchDisziplinen(),
      ).thenAnswer((_) async => <Disziplin>[]);

      await tester.pumpWidget(createSplashScreen());

      final imageFinder = find.byType(Image);
      final image = tester.widget<Image>(imageFinder);

      // Verify the asset path is correct
      expect(
        (image.image as AssetImage).assetName,
        'assets/images/BSSB_Wappen.png',
      );
    });

    testWidgets('should call API service methods during initialization', (
      WidgetTester tester,
    ) async {
      when(
        mockApiService.fetchBezirkeforSearch(),
      ).thenAnswer((_) async => <BezirkSearchTriple>[]);
      when(
        mockApiService.fetchDisziplinen(),
      ).thenAnswer((_) async => <Disziplin>[]);

      await tester.pumpWidget(createSplashScreen());

      // Verify that the API methods were called
      verify(mockApiService.fetchBezirkeforSearch()).called(1);
      verify(mockApiService.fetchDisziplinen()).called(1);
    });
  });
}
