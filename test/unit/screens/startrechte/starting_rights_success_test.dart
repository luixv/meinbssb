import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/startrechte/starting_rights_success.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

void main() {
  final userData = const UserData(
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

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<FontSizeProvider>(
      create: (_) => FontSizeProvider(),
      child: MaterialApp(
        home: StartrechteSuccessScreen(
          userData: userData,
          isLoggedIn: true,
          onLogout: () {},
        ),
        routes: {
          '/home': (context) => const Placeholder(key: Key('homeScreen')),
        },
      ),
    );
  }

  testWidgets('shows success icon and message', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.textContaining('erfolgreich gespeichert'), findsOneWidget);
  });

  testWidgets('shows floating action button', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
  });

  testWidgets('navigates to home on FAB tap', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    final fabFinder = find.byType(FloatingActionButton);
    expect(fabFinder, findsOneWidget);
    await tester.tap(fabFinder);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('homeScreen')), findsOneWidget);
  });
}
