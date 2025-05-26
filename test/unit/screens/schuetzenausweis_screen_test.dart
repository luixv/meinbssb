import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:meinbssb/screens/schuetzenausweis_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/config_service.dart';

// 👇 Genera mocks para estos servicios
@GenerateMocks([ApiService, ConfigService])
import 'schuetzenausweis_screen_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late MockConfigService mockConfigService;

  // Imagen PNG 1x1 blanca en base64
  final validImageData = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8Xw8AAn8B9RxcpdkAAAAASUVORK5CYII=',
  );

  setUp(() {
    mockApiService = MockApiService();
    mockConfigService = MockConfigService();

    when(mockConfigService.getString('logoName', 'appTheme'))
        .thenReturn('assets/images/myBSSB-logo.png');
  });

  Widget createWidgetUnderTest({
    required int personId,
    required Map<String, dynamic> userData,
  }) {
    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: mockApiService),
        Provider<ConfigService>.value(value: mockConfigService),
      ],
      child: MaterialApp(
        home: SchuetzenausweisScreen(
          personId: personId,
          userData: userData,
        ),
      ),
    );
  }

  testWidgets('shows error message on fetch failure', (tester) async {
    when(mockApiService.fetchSchuetzenausweis(any))
        .thenAnswer((_) => Future.error(Exception('Server error')));

    await tester.pumpWidget(
      createWidgetUnderTest(personId: 123, userData: {}),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Error beim Laden'), findsOneWidget);
    expect(find.textContaining('Server error'), findsOneWidget);
  });

  testWidgets('shows image when data is loaded', (tester) async {
    when(mockApiService.fetchSchuetzenausweis(any))
        .thenAnswer((_) async => validImageData);

    await tester.pumpWidget(
      createWidgetUnderTest(personId: 123, userData: {}),
    );

    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('schuetzenausweis')),
      findsOneWidget,
    );
  });
}
