import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/starting_rights_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/services/core/font_size_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'starting_rights_screen_test.mocks.dart';

@GenerateMocks([ApiService, NetworkService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockApiService mockApiService;
  late MockNetworkService mockNetworkService;
  late UserData userData;

  setUp(() {
    mockApiService = MockApiService();
    mockNetworkService = MockNetworkService();
    userData = const UserData(
      personId: 1,
      passdatenId: 1,
      erstVereinId: 1,
      vereinName: 'Test Verein',
      webLoginId: 1,
      passnummer: 'P123',
      vereinNr: 123,
      namen: 'Mustermann',
      vorname: 'Max',
      mitgliedschaftId: 1,
    );
    when(mockNetworkService.hasInternet()).thenAnswer((_) async => true);
    when(mockApiService.fetchDisziplinen()).thenAnswer((_) async => []);
    when(mockApiService.fetchPassdatenZVE(any, any))
        .thenAnswer((_) async => []);
    when(mockApiService.fetchPassdatenAkzeptierterOderAktiverPass(any))
        .thenAnswer((_) async => null);
    when(mockApiService.fetchZweitmitgliedschaften(any))
        .thenAnswer((_) async => []);
    when(mockApiService.postBSSBAppPassantrag(any, any, any, any, any))
        .thenAnswer((_) async => true);
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: mockApiService),
        Provider<NetworkService>.value(value: mockNetworkService),
        ChangeNotifierProvider<FontSizeProvider>(
          create: (_) => FontSizeProvider(),
        ),
      ],
      child: MaterialApp(
        home: StartingRightsScreen(
          userData: userData,
          isLoggedIn: true,
          onLogout: () {},
        ),
      ),
    );
  }

  testWidgets('displays loading indicator initially',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays error message if userData is null',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ApiService>.value(value: mockApiService),
          Provider<NetworkService>.value(value: mockNetworkService),
          ChangeNotifierProvider<FontSizeProvider>(
            create: (_) => FontSizeProvider(),
          ),
        ],
        child: MaterialApp(
          home: StartingRightsScreen(
            userData: null,
            isLoggedIn: true,
            onLogout: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Benutzerdaten nicht verfügbar'),
      findsOneWidget,
    );
  });

  testWidgets('displays club name when userData is present',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();
    expect(find.textContaining('Test Verein'), findsOneWidget);
  });

  testWidgets('shows save button only when there are unsaved changes',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();
    // Initially, no FAB
    expect(find.byType(FloatingActionButton), findsNothing);
    // Simulate unsaved changes
    final state = tester.state(find.byType(StartingRightsScreen)) as dynamic;
    state.setState(() {
      state._hasUnsavedChanges = true;
    });
    await tester.pump();
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
