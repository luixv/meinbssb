import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/widgets/kill_switch_gate.dart';
import 'package:meinbssb/providers/kill_switch_provider.dart';

void main() {
  testWidgets('KillSwitchGate shows child when appEnabled is true', (
    WidgetTester tester,
  ) async {
    final provider = KillSwitchProvider(appEnabled: true);
    await tester.pumpWidget(
      ChangeNotifierProvider<KillSwitchProvider>.value(
        value: provider,
        child: MaterialApp(
          home: KillSwitchGate(child: const Text('App Content')),
        ),
      ),
    );
    expect(find.text('App Content'), findsOneWidget);
    expect(find.textContaining('deaktiviert'), findsNothing);
  });

  testWidgets('KillSwitchGate shows message when appEnabled is false', (
    WidgetTester tester,
  ) async {
    final provider = KillSwitchProvider(
      appEnabled: false,
      killSwitchMessage: 'App is disabled for testing',
    );
    await tester.pumpWidget(
      ChangeNotifierProvider<KillSwitchProvider>.value(
        value: provider,
        child: MaterialApp(
          home: KillSwitchGate(child: const Text('App Content')),
        ),
      ),
    );
    expect(find.text('App Content'), findsNothing);
    expect(find.text('App is disabled for testing'), findsOneWidget);
  });
}
