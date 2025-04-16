import 'package:flutter_test/flutter_test.dart';

class TestHelper {
  static Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final endTime = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(endTime)) {
      await tester.pump();
      if (finder.evaluate().isNotEmpty) return;
    }
    throw Exception('Widget not found: $finder');
  }

  static Future<void> tapAndWait(
    WidgetTester tester,
    Finder finder, {
    Duration pumpDuration = const Duration(milliseconds: 100),
  }) async {
    await tester.tap(finder);
    await tester.pumpAndSettle(pumpDuration);
  }

  static Future<void> enterTextAndWait(
    WidgetTester tester,
    Finder finder,
    String text, {
    Duration pumpDuration = const Duration(milliseconds: 100),
  }) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle(pumpDuration);
  }

  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder,
    Finder scrollable, {
    double delta = 100.0,
    Duration pumpDuration = const Duration(milliseconds: 100),
  }) async {
    while (finder.evaluate().isEmpty) {
      await tester.drag(scrollable, Offset(0, delta));
      await tester.pumpAndSettle(pumpDuration);
    }
  }

  static Future<void> waitForNetwork(
    WidgetTester tester, {
    Duration duration = const Duration(seconds: 2),
  }) async {
    await tester.pumpAndSettle(duration);
  }
} 