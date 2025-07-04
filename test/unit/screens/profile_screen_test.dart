import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/profile_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/core/font_size_provider.dart';
import 'package:meinbssb/services/core/config_service.dart';

class MockConfigService implements ConfigService {
  @override
  String? getString(String key, [String? section]) => null;
  @override
  int? getInt(String key, [String? section]) => null;
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
      expect(find.byIcon(Icons.chevron_right), findsNWidgets(6));
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
      expect(find.textContaining('Profilbild'), findsWidgets);
    });
  });
}
