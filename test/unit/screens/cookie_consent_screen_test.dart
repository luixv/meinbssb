import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meinbssb/screens/cookie_consent_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestWidget({Widget? child}) {
    return MaterialApp(
      home: CookieConsent(
        child: child ?? const Text('Main Content'),
      ),
    );
  }

  testWidgets('shows consent overlay when not accepted', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey('cookieConsentBackground')), findsOneWidget,);
    expect(find.text('Zustimmen'), findsOneWidget);
  });

  testWidgets('does not show consent overlay when accepted', (tester) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cookieConsentAccepted', true);

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('cookieConsentBackground')), findsNothing);
    expect(find.text('Main Content'), findsOneWidget);
  });

  testWidgets('accept button hides overlay and sets preference',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey('cookieConsentBackground')), findsOneWidget,);

    await tester.tap(find.text('Zustimmen'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('cookieConsentBackground')), findsNothing);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('cookieConsentAccepted'), isTrue);
  });
}
