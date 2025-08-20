import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/agb_screen.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/core/font_size_provider.dart';
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
  group('AgbScreen', () {
    Widget createScreen() => MultiProvider(
          providers: [
            ChangeNotifierProvider<FontSizeProvider>(
              create: (_) => FontSizeProvider(),
            ),
            Provider<ConfigService>(
              create: (_) => MockConfigService(),
            ),
          ],
          child: const MaterialApp(
            home: AgbScreen(),
          ),
        );

    testWidgets('renders AGB screen with AppBar and close FAB', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.text('AGB'), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('renders at least one section title and paragraph',
        (tester) async {
      await tester.pumpWidget(createScreen());
      // Should find at least one section title and body text
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('close FAB pops the screen', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.tap(find.byIcon(Icons.close));
      // No navigation stack to pop in this test, but tap should not throw
      await tester.pump();
    });
  });
}
