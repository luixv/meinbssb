import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/oktoberfest/oktoberfest_gewinn_screen.dart';
import 'package:meinbssb/models/gewinn_data.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
@GenerateMocks([ApiService])
import 'oktoberfest_gewinn_screen_test.mocks.dart';
import 'dart:async';

void main() {
  late UserData userData;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    userData = UserData(
      personId: 1,
      webLoginId: 123,
      passnummer: 'P123',
      vereinNr: 456,
      namen: 'Mustermann',
      vorname: 'Max',
      vereinName: 'Testverein',
      passdatenId: 789,
      mitgliedschaftId: 1011,
    );
  });

  Widget buildTestWidget({bool isLoggedIn = true}) {
    return MaterialApp(
      home: ChangeNotifierProvider<FontSizeProvider>(
        create: (_) => FontSizeProvider(),
        child: OktoberfestGewinnScreen(
          userData: userData,
          isLoggedIn: isLoggedIn,
          passnummer: 'P123',
          apiService: mockApiService,
          onLogout: () {},
        ),
      ),
    );
  }

  testWidgets('renders basic UI structure', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    expect(find.text('Meine Gewinne für das Jahr:'), findsOneWidget);
    expect(find.text('Oktoberfestlandesschießen'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);
    expect(find.text('Gewinne abrufen'), findsOneWidget);
  });

  testWidgets('dropdown preselects 2025', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    final dropdown = tester.widget<DropdownButtonFormField<int>>(
      find.byType(DropdownButtonFormField<int>),
    );
    expect(dropdown.initialValue, equals(2025));
  });

  testWidgets('shows loading indicator when fetching', (tester) async {
    var fetchCompleter = Completer<List<Gewinn>>();
    when(
      mockApiService.fetchGewinne(2024, 'P123'),
    ).thenAnswer((_) => fetchCompleter.future);
    await tester.pumpWidget(buildTestWidget());
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2024').last);
    await tester.pump(); // Start the fetch, loading should be true
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Complete the fetch
    fetchCompleter.complete([]);
    await tester.pumpAndSettle();
  });

  testWidgets('shows list of gewinne when present', (tester) async {
    when(mockApiService.fetchGewinne(any, any)).thenAnswer(
      (_) async => [
        Gewinn(
          gewinnId: 1,
          jahr: 2025,
          tradition: true,
          isSachpreis: false,
          geldpreis: 100,
          sachpreis: '',
          wettbewerb: 'Wettbewerb 1',
          abgerufenAm: '',
          platz: 1,
        ),
      ],
    );
    await tester.pumpWidget(buildTestWidget());
    // Simulate year change to trigger fetchGewinne
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2024').last);
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsWidgets);
    expect(find.textContaining('Wettbewerb 1'), findsOneWidget);
  });

  testWidgets('shows Bankdaten button when gewinne need bank data', (
    tester,
  ) async {
    when(mockApiService.fetchGewinne(any, any)).thenAnswer(
      (_) async => [
        Gewinn(
          gewinnId: 1,
          jahr: 2025,
          tradition: true,
          isSachpreis: false,
          geldpreis: 100,
          sachpreis: '',
          wettbewerb: 'Wettbewerb 1',
          abgerufenAm: '',
          platz: 1,
        ),
      ],
    );
    await tester.pumpWidget(buildTestWidget());
    // Simulate year change to trigger fetchGewinne
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2024').last);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ElevatedButton, 'Bankdaten'), findsOneWidget);
  });

  testWidgets('FABs are visible when gewinne need to be abgerufen', (
    tester,
  ) async {
    when(mockApiService.fetchGewinne(any, any)).thenAnswer(
      (_) async => [
        Gewinn(
          gewinnId: 1,
          jahr: 2025,
          tradition: true,
          isSachpreis: false,
          geldpreis: 100,
          sachpreis: '',
          wettbewerb: 'Wettbewerb 1',
          abgerufenAm: '',
          platz: 1,
        ),
      ],
    );
    await tester.pumpWidget(buildTestWidget());
    // Simulate year change to trigger fetchGewinne
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2024').last);
    await tester.pumpAndSettle();
    expect(find.byType(FloatingActionButton), findsWidgets);
  });
}
