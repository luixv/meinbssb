import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:meinbssb/screens/schuetzenausweis_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/models/user_data.dart';

// 👇 Genera mocks para estos servicios
@GenerateMocks([ApiService, ConfigService])
import 'schuetzenausweis_screen_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late MockConfigService mockConfigService;
  late UserData testUserData;

  // Imagen PNG 1x1 blanca en base64
  final validImageData = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8Xw8AAn8B9RxcpdkAAAAASUVORK5CYII=',
  );

  setUp(() {
    mockApiService = MockApiService();
    mockConfigService = MockConfigService();
    when(mockConfigService.getString('logoName', 'appTheme')).thenReturn('');
    testUserData = const UserData(
      personId: 123,
      webLoginId: 456,
      passnummer: '12345678',
      vereinNr: 789,
      namen: 'User',
      vorname: 'Test',
      vereinName: 'Test Club',
      passdatenId: 1,
      mitgliedschaftId: 1,
    );
  });

  Widget createSchuetzenausweisScreen({
    int personId = 123,
    UserData? userData,
    bool isLoggedIn = true,
    VoidCallback? onLogout,
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
          isLoggedIn: isLoggedIn,
          onLogout: onLogout ?? () {},
        ),
      ),
    );
  }

  group('SchuetzenausweisScreen', () {
    testWidgets('renders correctly with user data',
        (WidgetTester tester) async {
      // Arrange
      when(mockApiService.fetchSchuetzenausweis(any)).thenAnswer(
        (_) => Future.value(Uint8List(0)),
      );

      // Act
      await tester
          .pumpWidget(createSchuetzenausweisScreen(userData: testUserData));
      await tester.pump();
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Schützenausweis'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('shows loading state while fetching',
        (WidgetTester tester) async {
      // Arrange
      when(mockApiService.fetchSchuetzenausweis(any)).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 100),
          () => Uint8List(0),
        ),
      );

      // Act
      await tester
          .pumpWidget(createSchuetzenausweisScreen(userData: testUserData));
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
    });
  });

  testWidgets('shows error message on fetch failure', (tester) async {
    when(mockApiService.fetchSchuetzenausweis(any))
        .thenAnswer((_) => Future.error(Exception('Server error')));

    await tester.pumpWidget(
      createSchuetzenausweisScreen(
        personId: 123,
        userData: const UserData(
          personId: 439287,
          webLoginId: 13901,
          passnummer: '40100709',
          vereinNr: 401051,
          namen: 'Schürz',
          vorname: 'Lukas',
          titel: '',
          geburtsdatum: null,
          geschlecht: 1,
          vereinName: 'Feuerschützen Kühbach',
          passdatenId: 2000009155,
          mitgliedschaftId: 439287,
          strasse: 'Aichacher Strasse 21',
          plz: '86574',
          ort: 'Alsmoos',
          isOnline: false,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Error beim Laden'), findsOneWidget);
    expect(find.textContaining('Server error'), findsOneWidget);
  });

  testWidgets('shows image when data is loaded', (tester) async {
    when(mockApiService.fetchSchuetzenausweis(any))
        .thenAnswer((_) async => validImageData);

    await tester.pumpWidget(
      createSchuetzenausweisScreen(
        personId: 123,
        userData: const UserData(
          personId: 439287,
          webLoginId: 13901,
          passnummer: '40100709',
          vereinNr: 401051,
          namen: 'Schürz',
          vorname: 'Lukas',
          titel: '',
          geburtsdatum: null,
          geschlecht: 1,
          vereinName: 'Feuerschützen Kühbach',
          passdatenId: 2000009155,
          mitgliedschaftId: 439287,
          strasse: 'Aichacher Strasse 21',
          plz: '86574',
          ort: 'Alsmoos',
          isOnline: false,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('schuetzenausweis')),
      findsOneWidget,
    );
  });
}
