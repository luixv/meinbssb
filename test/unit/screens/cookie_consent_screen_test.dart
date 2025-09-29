import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meinbssb/screens/cookie_consent_screen_accessible.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestWidget({Widget? child}) {
    return MaterialApp(
      home: CookieConsentAccessible(
        child: child ?? const Text('Main Content'),
      ),
    );
  }

  testWidgets('shows consent overlay when not accepted', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('cookieConsentAccessibleBackground')),
      findsOneWidget,
    );
    expect(find.text('Cookies akzeptieren'), findsOneWidget);
  });

  testWidgets('does not show consent overlay when accepted', (tester) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cookieConsentAccepted', true);

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('cookieConsentAccessibleBackground')),
      findsNothing,
    );
    expect(find.text('Main Content'), findsOneWidget);
  });

  testWidgets('accept button hides overlay and sets preference',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('cookieConsentAccessibleBackground')),
      findsOneWidget,
    );

    await tester.tap(find.text('Cookies akzeptieren'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('cookieConsentAccessibleBackground')),
      findsNothing,
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('cookieConsentAccepted'), isTrue);
  });
}
