import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

import 'package:meinbssb/screens//schuetzenausweis_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/screens/app_menu.dart';

// Create a Mock for ApiService
class MockApiService extends Mock implements ApiService {
  @override
  Future<Uint8List> fetchSchuetzenausweis(int? personId) async {
    return super.noSuchMethod(
      Invocation.method(#fetchSchuetzenausweis, [personId]),
      returnValue: Future<Uint8List>.value(Uint8List(0)),
      returnValueForMissingStub: Future<Uint8List>.value(Uint8List(0)),
    );
  }
}

void main() {
  late MockApiService mockApiService;
  const testPersonId = 123;
  final testUserData = <String, dynamic>{'name': 'Test User'};

  setUp(() {
    mockApiService = MockApiService();
  });

  Widget createSchuetzenausweisScreen() {
    return MaterialApp(
      home: Provider<ApiService>(
        create: (context) => mockApiService,
        child: SchuetzenausweisScreen(
          personId: testPersonId,
          userData: testUserData,
        ),
      ),
    );
  }

  group('SchuetzenausweisScreen', () {
    testWidgets('renders title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createSchuetzenausweisScreen());
      expect(find.text('Digitaler Schützenausweis'), findsOneWidget);
    });

    testWidgets('renders AppMenu in AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(createSchuetzenausweisScreen());
      expect(find.byType(AppMenu), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator while fetching data',
        (WidgetTester tester) async {
      when(mockApiService.fetchSchuetzenausweis(any)).thenAnswer((_) async {
        await Future.delayed(
          const Duration(milliseconds: 100),
        ); // Simulate loading
        return Uint8List.fromList([
          137,
          80,
          78,
          71,
          13,
          10,
          26,
          10,
          0,
          0,
          0,
          13,
          73,
          72,
          68,
          82,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          1,
          8,
          6,
          0,
          0,
          0,
          31,
          21,
          196,
          137,
          0,
          0,
          0,
          10,
          73,
          68,
          65,
          84,
          8,
          29,
          99,
          24,
          0,
          0,
          0,
          6,
          0,
          3,
          88,
          100,
          173,
          152,
          0,
          0,
          0,
          0,
          73,
          69,
          78,
          68,
          174,
          66,
          96,
          130,
        ]); // Minimal valid PNG
      });

      await tester.pumpWidget(createSchuetzenausweisScreen());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(); // Wait for loading to complete
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('renders Image.memory when data is successfully fetched',
        (WidgetTester tester) async {
      final testImageData = Uint8List.fromList([
        137,
        80,
        78,
        71,
        13,
        10,
        26,
        10,
        0,
        0,
        0,
        13,
        73,
        72,
        68,
        82,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        1,
        8,
        6,
        0,
        0,
        0,
        31,
        21,
        196,
        137,
        0,
        0,
        0,
        10,
        73,
        68,
        65,
        84,
        8,
        29,
        99,
        24,
        0,
        0,
        0,
        6,
        0,
        3,
        88,
        100,
        173,
        152,
        0,
        0,
        0,
        0,
        73,
        69,
        78,
        68,
        174,
        66,
        96,
        130,
      ]); // Minimal valid PNG
      when(mockApiService.fetchSchuetzenausweis(testPersonId))
          .thenAnswer((_) async => testImageData);

      await tester.pumpWidget(createSchuetzenausweisScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      final imageWidget = tester.widget<Image>(find.byType(Image));
      expect((imageWidget.image as MemoryImage).bytes, testImageData);
    });

    testWidgets(
        'renders error message when fetchSchuetzenausweis fails with Exception',
        (WidgetTester tester) async {
      const testErrorMessage = 'Failed to load image';
      when(mockApiService.fetchSchuetzenausweis(testPersonId))
          .thenThrow(Exception(testErrorMessage));

      await tester.pumpWidget(createSchuetzenausweisScreen());
      await tester.pumpAndSettle();

      expect(find.text('Error: $testErrorMessage'), findsOneWidget);
      expect(find.byType(Text), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets(
        'renders custom error message when fetchSchuetzenausweis fails with "Exception: Custom Error"',
        (WidgetTester tester) async {
      const testErrorMessage = 'Custom Error';
      when(mockApiService.fetchSchuetzenausweis(testPersonId))
          .thenThrow(Exception('Exception: $testErrorMessage'));

      await tester.pumpWidget(createSchuetzenausweisScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining(testErrorMessage), findsOneWidget);
      expect(find.byType(Text), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(Image), findsNothing);
    });
  });
}
