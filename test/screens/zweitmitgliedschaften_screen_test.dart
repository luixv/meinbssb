import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/zweitmitgliedschaften_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/config_service.dart';
import 'zweitmitgliedschaften_screen_test.mocks.dart';

@GenerateMocks([
  ApiService,
  ConfigService,
])
void main() {
  late MockApiService mockApiService;
  late MockConfigService mockConfigService;
  final Map<String, dynamic> mockUserData = {
    'PERSONID': 123,
    'PASSDATENID': 456,
    'NAMEN': 'Doe',
    'VORNAME': 'John',
    'PASSNUMMER': '12345',
    'VEREINNAME': 'Test Club',
  };

  setUp(() {
    mockApiService = MockApiService();
    mockConfigService = MockConfigService();
  });

  Widget createZweitmitgliedschaftenScreen() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<ApiService>.value(value: mockApiService),
          Provider<ConfigService>.value(value: mockConfigService),
        ],
        child: ZweitmitgliedschaftenScreen(
          personId: 123,
          userData: mockUserData,
        ),
      ),
    );
  }

  group('ZweitmitgliedschaftenScreen Tests', () {
    testWidgets('renders all required elements', (WidgetTester tester) async {
      when(mockApiService.fetchZweitmitgliedschaften(any))
          .thenAnswer((_) async => []);
      when(mockApiService.fetchPassdatenZVE(any, any))
          .thenAnswer((_) async => []);
      when(mockConfigService.getString('appColor', 'theme'))
          .thenReturn('4280391411'); // Color value for testing

      await tester.pumpWidget(createZweitmitgliedschaftenScreen());

      expect(find.text('Zweitmitgliedschaften'), findsOneWidget);
      expect(find.byType(LogoWidget), findsOneWidget);
      expect(find.text('Mein BSSB'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('12345'), findsOneWidget);
      expect(find.text('Schützenpassnummer'), findsOneWidget);
      expect(find.text('Test Club'), findsOneWidget);
      expect(find.text('Erstverein'), findsOneWidget);
    });

    testWidgets('shows loading indicators while fetching data', (WidgetTester tester) async {
      when(mockApiService.fetchZweitmitgliedschaften(any))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return [];
      });
      when(mockApiService.fetchPassdatenZVE(any, any))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return [];
      });
      when(mockConfigService.getString('appColor', 'theme'))
          .thenReturn('4280391411');

      await tester.pumpWidget(createZweitmitgliedschaftenScreen());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
    });

    testWidgets('displays zweitmitgliedschaften list when data is available', (WidgetTester tester) async {
      final mockZweitmitgliedschaften = [
        {'VEREINID': '1', 'VEREINNAME': 'Club 1'},
        {'VEREINID': '2', 'VEREINNAME': 'Club 2'},
      ];
      when(mockApiService.fetchZweitmitgliedschaften(any))
          .thenAnswer((_) async => mockZweitmitgliedschaften);
      when(mockApiService.fetchPassdatenZVE(any, any))
          .thenAnswer((_) async => []);
      when(mockConfigService.getString('appColor', 'theme'))
          .thenReturn('4280391411');

      await tester.pumpWidget(createZweitmitgliedschaftenScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsNWidgets(2));
      expect(find.text('Club 1'), findsOneWidget);
      expect(find.text('Club 2'), findsOneWidget);
    });

    testWidgets('displays disciplines list when data is available', (WidgetTester tester) async {
      final mockDisciplines = [
        {'DISZIPLIN': 'Discipline 1'},
        {'DISZIPLIN': 'Discipline 2'},
      ];
      when(mockApiService.fetchZweitmitgliedschaften(any))
          .thenAnswer((_) async => []);
      when(mockApiService.fetchPassdatenZVE(any, any))
          .thenAnswer((_) async => mockDisciplines);
      when(mockConfigService.getString('appColor', 'theme'))
          .thenReturn('4280391411');

      await tester.pumpWidget(createZweitmitgliedschaftenScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsNWidgets(2));
      expect(find.text('Discipline 1'), findsOneWidget);
      expect(find.text('Discipline 2'), findsOneWidget);
    });

    testWidgets('shows error message when zweitmitgliedschaften fetch fails', (WidgetTester tester) async {
      when(mockApiService.fetchZweitmitgliedschaften(any))
          .thenThrow(Exception('Failed to fetch data'));
      when(mockApiService.fetchPassdatenZVE(any, any))
          .thenAnswer((_) async => []);
      when(mockConfigService.getString('appColor', 'theme'))
          .thenReturn('4280391411');

      await tester.pumpWidget(createZweitmitgliedschaftenScreen());
      await tester.pumpAndSettle();

      expect(find.text('Fehler beim Laden der Daten'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows error message when disciplines fetch fails', (WidgetTester tester) async {
      when(mockApiService.fetchZweitmitgliedschaften(any))
          .thenAnswer((_) async => []);
      when(mockApiService.fetchPassdatenZVE(any, any))
          .thenThrow(Exception('Failed to fetch data'));
      when(mockConfigService.getString('appColor', 'theme'))
          .thenReturn('4280391411');

      await tester.pumpWidget(createZweitmitgliedschaftenScreen());
      await tester.pumpAndSettle();

      expect(find.text('Fehler beim Laden der Disziplinen'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows empty state messages when no data is available', (WidgetTester tester) async {
      when(mockApiService.fetchZweitmitgliedschaften(any))
          .thenAnswer((_) async => []);
      when(mockApiService.fetchPassdatenZVE(any, any))
          .thenAnswer((_) async => []);
      when(mockConfigService.getString('appColor', 'theme'))
          .thenReturn('4280391411');

      await tester.pumpWidget(createZweitmitgliedschaftenScreen());
      await tester.pumpAndSettle();

      expect(find.text('Keine Zweitmitgliedschaften gefunden.'), findsOneWidget);
      expect(find.text('Keine Disziplinen gefunden.'), findsOneWidget);
    });
  });
} 