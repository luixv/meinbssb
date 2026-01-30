import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step3_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/beduerfnis_antrag_data.dart';
import 'package:meinbssb/models/beduerfnis_datei_zuord_data.dart';
import 'package:meinbssb/services/api/workflow_service.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/models/beduerfnis_navigation_params.dart';
import 'package:meinbssb/models/beduerfnis_page.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'beduerfnisantrag_step3_screen_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  late MockApiService mockApiService;
  late FontSizeProvider fontSizeProvider;

  setUp(() {
    mockApiService = MockApiService();
    fontSizeProvider = FontSizeProvider();
    when(
      mockApiService.getBedDateiZuordByAntragsnummer(any, any),
    ).thenAnswer((_) async => []);
    when(mockApiService.getBedDateiById(any)).thenAnswer((_) async => null);
    when(mockApiService.deleteBedDateiById(any)).thenAnswer((_) async => true);

    // Add missing stubs to prevent MissingStubError
    when(mockApiService.getBedAuswahlByTypId(any)).thenAnswer((_) async => []);
    when(
      mockApiService.getBedWaffeBesitzByAntragsnummer(any),
    ).thenAnswer((_) async => []);
  });

  Widget createTestWidget({
    UserData? userData,
    BeduerfnisAntrag? antrag,
    bool isLoggedIn = true,
    bool readOnly = false,
  }) {
    // Provide a default antrag with antragsnummer if not supplied
    final effectiveAntrag =
        antrag ?? BeduerfnisAntrag(antragsnummer: 123, personId: 1);
    final navigationParams = BeduerfnisNavigationParams(
      wbkType: 'neu',
      wbkColor: 'gelb',
      weaponType: 'kurz',
      anzahlWaffen: 1,
      currentPage: BeduerfnisPage.step3,
    );
    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: mockApiService),
        ChangeNotifierProvider<FontSizeProvider>.value(value: fontSizeProvider),
      ],
      child: MaterialApp(
        home: BeduerfnisantragStep3Screen(
          userData: userData,
          antrag: effectiveAntrag,
          isLoggedIn: isLoggedIn,
          onLogout: () {},
          userRole: WorkflowRole.mitglied,
          readOnly: readOnly,
          navigationParams: navigationParams,
        ),
      ),
    );
  }

  testWidgets('renders main UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    expect(find.text('Bedürfnisbescheinigung'), findsWidgets);
    expect(find.textContaining('Kopie der vorhandenen WBK'), findsOneWidget);
    expect(find.text('Hochgeladene Dokumente:'), findsOneWidget);
    expect(find.text('Keine Dokumente hochgeladen.'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('shows document list when documents exist', (
    WidgetTester tester,
  ) async {
    final doc = BeduerfnisDateiZuord(
      id: 1,
      antragsnummer: 123,
      dateiId: 2,
      dateiArt: 'WBK',
      label: 'Testdokument',
    );
    when(
      mockApiService.getBedDateiZuordByAntragsnummer(any, any),
    ).thenAnswer((_) async => [doc]);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    expect(find.text('Testdokument'), findsOneWidget);
    expect(find.byIcon(Icons.preview), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('calls API to delete document', (WidgetTester tester) async {
    final doc = BeduerfnisDateiZuord(
      id: 1,
      antragsnummer: 123,
      dateiId: 2,
      dateiArt: 'WBK',
      label: 'Testdokument',
    );
    when(
      mockApiService.getBedDateiZuordByAntragsnummer(any, any),
    ).thenAnswer((_) async => [doc]);
    when(mockApiService.deleteBedDateiById(any)).thenAnswer((_) async => true);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    // Confirm dialog appears
    expect(find.text('Dokument löschen'), findsOneWidget);
    // Tap the Löschen button (by type and text)
    final deleteButton = find.widgetWithText(ElevatedButton, 'Löschen');
    expect(deleteButton, findsOneWidget);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();
    verify(mockApiService.deleteBedDateiById(2)).called(1);
  });

  testWidgets('shows error if document deletion fails', (
    WidgetTester tester,
  ) async {
    final doc = BeduerfnisDateiZuord(
      id: 1,
      antragsnummer: 123,
      dateiId: 2,
      dateiArt: 'WBK',
      label: 'Testdokument',
    );
    when(
      mockApiService.getBedDateiZuordByAntragsnummer(any, any),
    ).thenAnswer((_) async => [doc]);
    when(mockApiService.deleteBedDateiById(any)).thenAnswer((_) async => false);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(find.text('Dokument löschen'), findsOneWidget);
    final deleteButton = find.widgetWithText(ElevatedButton, 'Löschen');
    expect(deleteButton, findsOneWidget);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();
    expect(find.text('Fehler beim Löschen des Dokuments'), findsOneWidget);
  });

  testWidgets('opens upload dialog when add button pressed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.textContaining('Dokument'), findsWidgets);
  });

  testWidgets('navigates forward when next button pressed', (
    WidgetTester tester,
  ) async {
    // Stub getNextStepRoute to return a dummy route
    when(
      mockApiService.getNextStepRoute(
        context: anyNamed('context'),
        userData: anyNamed('userData'),
        antrag: anyNamed('antrag'),
        isLoggedIn: anyNamed('isLoggedIn'),
        onLogout: anyNamed('onLogout'),
        userRole: anyNamed('userRole'),
        readOnly: anyNamed('readOnly'),
        navigationParams: anyNamed('navigationParams'),
      ),
    ).thenReturn(
      MaterialPageRoute(
        builder: (_) => const Scaffold(body: Text('Step 4 Dummy')),
      ),
    );

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();
    // Should push a new route (Step 4 screen)
    expect(find.text('Step 4 Dummy'), findsOneWidget);
  });

  testWidgets('navigates back when back button pressed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    // Should pop the route (no assertion, just ensure no crash)
    expect(find.byIcon(Icons.arrow_back), findsNothing);
  });
}
