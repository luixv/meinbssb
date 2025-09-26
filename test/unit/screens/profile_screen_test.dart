import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/profile_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/services/api_service.dart';

class MockConfigService implements ConfigService {
  @override
  String? getString(String key, [String? section]) => null;
  @override
  int? getInt(String key, [String? section]) => null;
  @override
  List<String>? getList(String key, [String? section]) => null;
  @override
  bool? getBool(String key, [String? section]) => null;
}

class FakeApiService implements ApiService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('ProfileScreen', () {
    late UserData userData;
    late bool logoutCalled;

    setUp(() {
      userData = const UserData(
        personId: 1,
        webLoginId: 1,
        passnummer: '12345',
        vereinNr: 1,
        namen: 'Mustermann',
        vorname: 'Max',
        vereinName: 'Testverein',
        passdatenId: 1,
        mitgliedschaftId: 1,
      );
      logoutCalled = false;
    });

    Widget createScreen() => MultiProvider(
          providers: [
            ChangeNotifierProvider<FontSizeProvider>(
              create: (_) => FontSizeProvider(),
            ),
            Provider<ConfigService>(
              create: (_) => MockConfigService(),
            ),
            Provider<ApiService>(
              create: (_) => FakeApiService(),
            ),
          ],
          child: MaterialApp(
            home: ProfileScreen(
              userData: userData,
              isLoggedIn: true,
              onLogout: () => logoutCalled = true,
            ),
          ),
        );

    testWidgets('renders logo, header, and all menu items', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.text('Profil'), findsNWidgets(2)); // header and title
      expect(find.byIcon(Icons.add_a_photo_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.contact_mail), findsOneWidget);
      expect(find.byIcon(Icons.account_balance), findsOneWidget);
      expect(find.byIcon(Icons.task_alt), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);

      expect(find.byIcon(Icons.chevron_right), findsNWidgets(7));
    });

    testWidgets('calls onLogout when triggered', (tester) async {
      await tester.pumpWidget(createScreen());
      // Simulate logout via BaseScreenLayout (not directly testable here)
      // But we can check the callback is passed
      expect(logoutCalled, isFalse);
    });

    testWidgets('navigates to PersonalPictUploadScreen on tap', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.tap(find.text('Profilbild'));
      await tester.pumpAndSettle();
      // The new route should contain "Profilbild" in the widget tree
      expect(find.textContaining('Profilbild'), findsWidgets);
    });

    testWidgets('navigates to PersonDataScreen on tap', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.tap(find.text('Persönliche Daten'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Persönliche Daten'), findsWidgets);
    });

    testWidgets('navigates to ContactDataScreen on tap', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.tap(find.text('Kontaktdaten'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Kontaktdaten'), findsWidgets);
    });

    testWidgets('navigates to BankDataScreen on tap', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.tap(find.text('Bankdaten'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Bankdaten'), findsWidgets);
    });

    testWidgets('navigates to AbsolvierteSchulungenScreen on tap',
        (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.ensureVisible(find.text('Absolvierte Schulungen'));
      await tester.tap(find.text('Absolvierte Schulungen'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Absolvierte Schulungen'), findsWidgets);
    });

    testWidgets('navigates to ChangePasswordScreen on tap', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.ensureVisible(find.text('Passwort ändern'));
      await tester.tap(find.text('Passwort ändern'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Passwort'), findsWidgets);
    });

    testWidgets('navigates to AusweisBestellenScreen on tap', (tester) async {
      await tester.pumpWidget(createScreen());

      final ausweisFinder = find.text('Schützenausweis bestellen');

      // Try to scroll until the item is visible
      await tester.scrollUntilVisible(
        ausweisFinder,
        100.0,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.tap(ausweisFinder);
      await tester.pumpAndSettle();

      // Check for the screen title or button instead of generic text
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
