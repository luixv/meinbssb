import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/screens/schulungen_search_screen.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';

@GenerateMocks([NetworkService, ConfigService])
import 'schulungen_search_screen_test.mocks.dart';

void main() {
  late MockNetworkService mockNetworkService;
  late MockConfigService mockConfigService;
  late UserData testUserData;

  setUp(() {
    mockNetworkService = MockNetworkService();
    mockConfigService = MockConfigService();
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

  Widget createSchulungenSearchScreen({
    UserData? userData,
    bool isLoggedIn = true,
    Function()? onLogout,
  }) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<NetworkService>.value(value: mockNetworkService),
          Provider<ConfigService>.value(value: mockConfigService),
          ChangeNotifierProvider<FontSizeProvider>(
            create: (_) => FontSizeProvider(),
          ),
        ],
        child: BaseScreenLayout(
          title: 'Schulungen',
          userData: userData,
          isLoggedIn: isLoggedIn,
          onLogout: onLogout ?? () {},
          body: SchulungenSearchScreen(
            userData,
            isLoggedIn: isLoggedIn,
            onLogout: onLogout ?? () {},
          ),
        ),
      ),
    );
  }

  group('SchulungenSearchScreen', () {
    testWidgets('renders correctly with user data',
        (WidgetTester tester) async {
      when(mockNetworkService.hasInternet()).thenAnswer((_) async => true);

      await tester
          .pumpWidget(createSchulungenSearchScreen(userData: testUserData));
      await tester.pumpAndSettle();

      expect(find.text('Schulungen'), findsOneWidget);
      expect(find.text('Schulungen suchen'), findsOneWidget);
      expect(find.text('Datum wählen'), findsOneWidget);
      expect(find.text('Gruppe'), findsOneWidget);
      expect(find.text('Bezirk'), findsOneWidget);
      expect(find.text('Ort'), findsOneWidget);
      expect(find.text('Titel'), findsOneWidget);
      expect(find.text('Für Lizenzverlängerung'), findsOneWidget);
    });

    testWidgets('shows offline message when offline',
        (WidgetTester tester) async {
      when(mockNetworkService.hasInternet()).thenAnswer((_) async => false);

      await tester
          .pumpWidget(createSchulungenSearchScreen(userData: testUserData));
      await tester.pumpAndSettle();

      expect(
        find.text('Schulungen suchen ist offline nicht verfügbar'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Bitte stellen Sie sicher, dass Sie mit dem Internet verbunden sind, um nach Schulungen zu suchen.',
        ),
        findsOneWidget,
      );
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('shows FABs when online', (WidgetTester tester) async {
      when(mockNetworkService.hasInternet()).thenAnswer((_) async => true);

      await tester
          .pumpWidget(createSchulungenSearchScreen(userData: testUserData));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNWidgets(2));
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('hides FABs when offline', (WidgetTester tester) async {
      when(mockNetworkService.hasInternet()).thenAnswer((_) async => false);

      await tester
          .pumpWidget(createSchulungenSearchScreen(userData: testUserData));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('shows loading indicator while checking network status',
        (WidgetTester tester) async {
      when(mockNetworkService.hasInternet()).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 100), () => true),
      );

      await tester
          .pumpWidget(createSchulungenSearchScreen(userData: testUserData));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
    });

    testWidgets('displays form fields when online',
        (WidgetTester tester) async {
      when(mockNetworkService.hasInternet()).thenAnswer((_) async => true);

      await tester
          .pumpWidget(createSchulungenSearchScreen(userData: testUserData));
      await tester.pumpAndSettle();

      expect(find.text('Schulungen suchen'), findsOneWidget);
      expect(find.text('Datum wählen'), findsOneWidget);
      expect(find.text('Gruppe'), findsOneWidget);
      expect(find.text('Bezirk'), findsOneWidget);
      expect(find.text('Ort'), findsOneWidget);
      expect(find.text('Titel'), findsOneWidget);
      expect(find.text('Für Lizenzverlängerung'), findsOneWidget);
    });
  });
}
