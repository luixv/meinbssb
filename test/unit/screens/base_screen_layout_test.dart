import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

void main() {
  const dummyUser = UserData(
    personId: 1,
    webLoginId: 1,
    passnummer: '12345',
    vereinNr: 1,
    namen: 'User',
    vorname: 'Test',
    vereinName: 'Test Verein',
    passdatenId: 1,
    mitgliedschaftId: 1,
  );

  Widget createTestWidget({
    required Widget body,
    String title = 'Test Title',
    List<Widget> actions = const [],
    Widget? floatingActionButton,
    bool automaticallyImplyLeading = true,
    VoidCallback? onLogout,
  }) {
    return ChangeNotifierProvider<FontSizeProvider>(
      create: (_) => FontSizeProvider(),
      child: MaterialApp(
        home: BaseScreenLayout(
          title: title,
          userData: dummyUser,
          isLoggedIn: true,
          onLogout: onLogout ?? () {},
          body: body,
          actions: actions,
          floatingActionButton: floatingActionButton,
          automaticallyImplyLeading: automaticallyImplyLeading,
        ),
      ),
    );
  }

  testWidgets('renders title and body', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(body: const Text('Body content')));
    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('Body content'), findsOneWidget);
  });

  testWidgets('renders custom actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestWidget(
        body: const SizedBox(),
        actions: [const Icon(Icons.star, key: Key('star-action'))],
      ),
    );
    expect(find.byKey(const Key('star-action')), findsOneWidget);
  });

  testWidgets('renders floatingActionButton', (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestWidget(
        body: const SizedBox(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add, key: Key('fab-icon')),
        ),
      ),
    );
    expect(find.byKey(const Key('fab-icon')), findsOneWidget);
  });

  testWidgets('opens endDrawer when menu icon tapped',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestWidget(
        body: const SizedBox(),
      ),
    );
    // Tap the menu icon
    await tester.tap(find.byIcon(Icons.menu).last);
    await tester.pumpAndSettle();
    // Drawer should be open
    expect(find.byType(Drawer), findsOneWidget);
  });

  testWidgets('respects automaticallyImplyLeading',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestWidget(
        body: const SizedBox(),
        automaticallyImplyLeading: false,
      ),
    );
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.automaticallyImplyLeading, isFalse);
  });
}
