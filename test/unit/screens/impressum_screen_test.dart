import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/impressum_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/services/core/config_service.dart';

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

void main() {
  group('ImpressumScreen', () {
    late UserData userData;
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
            home: ImpressumScreen(
              userData: userData,
              isLoggedIn: true,
              onLogout: () {},
            ),
          ),
        );

    testWidgets('renders Impressum screen with AppBar and close FAB',
        (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.text('Impressum'), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('renders at least one section title and body text',
        (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('close FAB pops the screen', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
    });
  });
}
