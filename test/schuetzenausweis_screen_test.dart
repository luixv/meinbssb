import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/schuetzenausweis_screen.dart'; // Update this import path

// Generate mocks for the http client
@GenerateMocks([http.Client])
import 'schuetzenausweis_screen_test.mocks.dart';

void main() {
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
  });

  group('SchuetzenausweisScreen Tests', () {
    testWidgets('Initialization and Loading State', (WidgetTester tester) async {
      // Mock the HTTP response
      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response.bytes([], 200), // Simulate a successful image response
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: SchuetzenausweisScreen(
            personId: 1,
            userData: {'PERSONID': 1},
          ),
        ),
      );

      // Verify the loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Error State', (WidgetTester tester) async {
      // Mock an HTTP error response
      when(mockClient.get(any)).thenThrow(Exception('Failed to load image'));

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: SchuetzenausweisScreen(
            personId: 1,
            userData: {'PERSONID': 1},
          ),
        ),
      );

      // Wait for the FutureBuilder to complete
      await tester.pump();

      // Verify the error message is displayed
      expect(find.textContaining('Failed to load image'), findsOneWidget);
    });

    testWidgets('Success State', (WidgetTester tester) async {
      // Mock a successful HTTP response with image data
      final imageBytes = [0x89, 0x50, 0x4E, 0x47]; // Example PNG header
      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response.bytes(imageBytes, 200),
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: SchuetzenausweisScreen(
            personId: 1,
            userData: {'PERSONID': 1},
          ),
        ),
      );

      // Wait for the FutureBuilder to complete
      await tester.pump();

      // Verify the image is displayed
      expect(find.byType(Image), findsOneWidget);
    });
  });
}