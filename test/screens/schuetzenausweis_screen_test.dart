import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/schuetzenausweis_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'schuetzenausweis_screen_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApiService;
  final Uint8List mockImageData = Uint8List.fromList([1, 2, 3, 4]);
  final Map<String, dynamic> mockUserData = {
    'PERSONID': 123,
    'NAMEN': 'Doe',
    'VORNAME': 'John',
  };

  setUp(() {
    mockApiService = MockApiService();
  });

  Widget createSchuetzenausweisScreen() {
    return MaterialApp(
      home: Provider<ApiService>.value(
        value: mockApiService,
        child: SchuetzenausweisScreen(
          personId: 123,
          userData: mockUserData,
        ),
      ),
    );
  }

  group('SchuetzenausweisScreen Tests', () {
    testWidgets('renders all required elements', (WidgetTester tester) async {
      when(mockApiService.fetchSchuetzenausweis(any))
          .thenAnswer((_) async => mockImageData);

      await tester.pumpWidget(createSchuetzenausweisScreen());

      expect(find.text('Digitaler Schützenausweis'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(AppMenu), findsOneWidget);
    });

    testWidgets('shows loading indicator while fetching image', (WidgetTester tester) async {
      when(mockApiService.fetchSchuetzenausweis(any))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return mockImageData;
      });

      await tester.pumpWidget(createSchuetzenausweisScreen());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays image when data is available', (WidgetTester tester) async {
      when(mockApiService.fetchSchuetzenausweis(any))
          .thenAnswer((_) async => mockImageData);

      await tester.pumpWidget(createSchuetzenausweisScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('shows error message when image fetch fails', (WidgetTester tester) async {
      when(mockApiService.fetchSchuetzenausweis(any))
          .thenThrow(Exception('Failed to fetch image'));

      await tester.pumpWidget(createSchuetzenausweisScreen());
      await tester.pumpAndSettle();

      expect(find.text('Error: Failed to fetch image'), findsOneWidget);
    });

    testWidgets('shows no data message when image is null', (WidgetTester tester) async {
      when(mockApiService.fetchSchuetzenausweis(any))
          .thenAnswer((_) async => Uint8List(0));

      await tester.pumpWidget(createSchuetzenausweisScreen());
      await tester.pumpAndSettle();

      expect(find.text('No image data available'), findsOneWidget);
    });

    testWidgets('app menu is present and functional', (WidgetTester tester) async {
      when(mockApiService.fetchSchuetzenausweis(any))
          .thenAnswer((_) async => mockImageData);

      await tester.pumpWidget(createSchuetzenausweisScreen());
      await tester.pumpAndSettle();

      expect(find.byType(AppMenu), findsOneWidget);
      await tester.tap(find.byType(AppMenu));
      await tester.pumpAndSettle();
    });
  });
} 