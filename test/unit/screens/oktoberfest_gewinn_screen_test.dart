import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/oktoberfest_gewinn_screen.dart';
import 'package:meinbssb/models/gewinn_data.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/api/oktoberfest_service.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:async';

@GenerateMocks([OktoberfestService, ApiService])
import 'oktoberfest_gewinn_screen_test.mocks.dart';

void main() {
  late MockOktoberfestService mockOktoberfestService;
  late MockApiService mockApiService;
  late ConfigService configService;
  late UserData userData;

  setUp(() async {
    mockOktoberfestService = MockOktoberfestService();
    mockApiService = MockApiService();
    configService = await ConfigService.load('assets/config.json');
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
        Provider<OktoberfestService>(create: (_) => mockOktoberfestService),
        Provider<ApiService>(create: (_) => mockApiService),
        ChangeNotifierProvider<FontSizeProvider>(
          create: (_) => FontSizeProvider(),
        ),
      ],
      child: MaterialApp(
        home: OktoberfestGewinnScreen(
          passnummer: '123456',
          configService: configService,
          userData: userData,
          isLoggedIn: true,
          onLogout: () {},
        ),
      ),
    );
  }

  testWidgets('shows loading indicator while fetching', (tester) async {
    final completer = Completer<List<Gewinn>>();
    when(
      mockOktoberfestService.fetchGewinne(
        jahr: anyNamed('jahr'),
        passnummer: anyNamed('passnummer'),
        configService: anyNamed('configService'),
      ),
    ).thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildTestWidget());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete([]);
    await tester.pumpAndSettle();
  });

  testWidgets(
      'shows "Keine Gewinne für das gewählte Jahr gefunden." snackbar when no gewinne',
      (tester) async {
    when(
      mockOktoberfestService.fetchGewinne(
        jahr: anyNamed('jahr'),
        passnummer: anyNamed('passnummer'),
        configService: anyNamed('configService'),
      ),
    ).thenAnswer((_) async => []);
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    expect(
      find.text('Keine Gewinne für das gewählte Jahr gefunden.'),
      findsOneWidget,
    );
  });

  testWidgets('shows gewinne list when gewinne are available', (tester) async {
    final gewinne = [
      const Gewinn(
        gewinnId: 1,
        jahr: 2023,
        tradition: false,
        isSachpreis: false,
        geldpreis: 100,
        sachpreis: '',
        wettbewerb: 'Test Wettbewerb',
        abgerufenAm: '',
        platz: 1,
      ),
      const Gewinn(
        gewinnId: 2,
        jahr: 2023,
        tradition: false,
        isSachpreis: false,
        geldpreis: 50,
        sachpreis: '',
        wettbewerb: 'Anderer Wettbewerb',
        abgerufenAm: '2024-09-01',
        platz: 2,
      ),
    ];
    when(
      mockOktoberfestService.fetchGewinne(
        jahr: anyNamed('jahr'),
        passnummer: anyNamed('passnummer'),
        configService: anyNamed('configService'),
      ),
    ).thenAnswer((_) async => gewinne);
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    expect(find.text('Test Wettbewerb'), findsOneWidget);
    expect(find.text('Anderer Wettbewerb'), findsOneWidget);
    expect(find.text('Platz: 1'), findsOneWidget);
    expect(find.text('Platz: 2'), findsOneWidget);
    expect(find.text('Geldpreis: 100'), findsOneWidget);
    expect(find.text('Geldpreis: 50'), findsOneWidget);
  });

  testWidgets('shows "noch nicht abgerufen" when abgerufenAm is empty',
      (tester) async {
    final gewinne = [
      const Gewinn(
        gewinnId: 1,
        jahr: 2023,
        tradition: false,
        isSachpreis: false,
        geldpreis: 100,
        sachpreis: '',
        wettbewerb: 'Test Wettbewerb',
        abgerufenAm: '',
        platz: 1,
      ),
    ];
    when(
      mockOktoberfestService.fetchGewinne(
        jahr: anyNamed('jahr'),
        passnummer: anyNamed('passnummer'),
        configService: anyNamed('configService'),
      ),
    ).thenAnswer((_) async => gewinne);
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    expect(find.text('noch nicht abgerufen'), findsOneWidget);
  });

  testWidgets(
      'shows Bankdaten button when at least one gewinn is not abgerufen',
      (tester) async {
    final gewinne = [
      const Gewinn(
        gewinnId: 1,
        jahr: 2023,
        tradition: false,
        isSachpreis: false,
        geldpreis: 100,
        sachpreis: '',
        wettbewerb: 'Test Wettbewerb',
        abgerufenAm: '',
        platz: 1,
      ),
    ];
    when(
      mockOktoberfestService.fetchGewinne(
        jahr: anyNamed('jahr'),
        passnummer: anyNamed('passnummer'),
        configService: anyNamed('configService'),
      ),
    ).thenAnswer((_) async => gewinne);
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    expect(find.text('Bankdaten'), findsOneWidget);
  });

  testWidgets('shows FloatingActionButton for gewinn fetch', (tester) async {
    final gewinne = [
      const Gewinn(
        gewinnId: 1,
        jahr: 2023,
        tradition: false,
        isSachpreis: false,
        geldpreis: 100,
        sachpreis: '',
        wettbewerb: 'Test Wettbewerb',
        abgerufenAm: '',
        platz: 1,
      ),
    ];
    when(
      mockOktoberfestService.fetchGewinne(
        jahr: anyNamed('jahr'),
        passnummer: anyNamed('passnummer'),
        configService: anyNamed('configService'),
      ),
    ).thenAnswer((_) async => gewinne);
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    expect(find.byType(FloatingActionButton), findsWidgets);
  });
}
