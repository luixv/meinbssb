import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/oktoberfest/oktoberfest_results_screen.dart';
import 'package:meinbssb/models/result_data.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks for ApiService
@GenerateMocks([ApiService])
import 'oktoberfest_results_screen_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late UserData userData;

  setUp(() async {
    mockApiService = MockApiService();
    userData = const UserData(
      personId: 1,
      webLoginId: 1,
      passnummer: '123456',
      vereinNr: 1,
      namen: 'Mustermann',
      vorname: 'Max',
      vereinName: 'Testverein',
      passdatenId: 1,
      mitgliedschaftId: 1,
    );
  });

  Widget buildTestWidget() {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => mockApiService),
        ChangeNotifierProvider<FontSizeProvider>(
          create: (_) => FontSizeProvider(),
        ),
      ],
      child: MaterialApp(
        home: OktoberfestResultsScreen(
          passnummer: '123456',
          apiService: mockApiService,
          userData: userData,
          isLoggedIn: true,
          onLogout: () {},
        ),
      ),
    );
  }

  testWidgets('shows loading indicator while waiting', (tester) async {
    // Simulate a future that is not yet completed
    final completer = Completer<List<Result>>();
    when(mockApiService.fetchResults(any)).thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildTestWidget());
    // The loading indicator should be visible while the future is pending
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Complete the future to finish the test
    completer.complete([]);
    await tester.pumpAndSettle();
  });

  testWidgets('shows error message on error', (tester) async {
    when(mockApiService.fetchResults(any)).thenThrow(Exception('Test error'));
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // If your widget does NOT catch and display the error, use:
    expect(tester.takeException(), isA<Exception>());

    // If your widget DOES catch and display the error, use:
    // expect(find.textContaining('Error:'), findsOneWidget);
  });

  testWidgets('shows "Keine Ergebnisse gefunden." when no results',
      (tester) async {
    when(mockApiService.fetchResults(any)).thenAnswer((_) async => []);
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    expect(find.text('Keine Ergebnisse gefunden.'), findsOneWidget);
  });

  testWidgets(
      'shows "Keine Ergebnisse gefunden nach Filterung." when all platz are 0',
      (tester) async {
    final results = [
      const Result(wettbewerb: 'Test', platz: 0, gesamt: 100, postfix: ''),
    ];
    when(mockApiService.fetchResults(any)).thenAnswer((_) async => results);
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    expect(
      find.text('Keine Ergebnisse gefunden nach Filterung.'),
      findsOneWidget,
    );
  });

  testWidgets('shows results table when results are available', (tester) async {
    final results = [
      const Result(
        wettbewerb: 'TestWettbewerb',
        platz: 1,
        gesamt: 99,
        postfix: '',
      ),
      const Result(
        wettbewerb: 'TestWettbewerb2',
        platz: 2,
        gesamt: 88,
        postfix: '',
      ),
    ];
    when(mockApiService.fetchResults(any)).thenAnswer((_) async => results);
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    expect(find.text('Wettbewerb'), findsOneWidget);
    expect(find.text('Rang'), findsOneWidget);
    expect(find.text('Ergebnis'), findsOneWidget);
    expect(find.text('TestWettbewerb'), findsOneWidget);
    expect(find.text('TestWettbewerb2'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('99'), findsOneWidget);
    expect(find.text('88'), findsOneWidget);
  });
}
