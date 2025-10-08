import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/widgets/kill_switch_gate.dart';
import 'package:meinbssb/providers/kill_switch_provider.dart';

class FakeKillSwitchProvider extends KillSwitchProvider {
  FakeKillSwitchProvider({required bool enabled, super.message})
    : super(appEnabled: enabled, skipRemoteConfig: true);
}

void main() {
  testWidgets('shows child when appEnabled is true', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<KillSwitchProvider>.value(
        value: FakeKillSwitchProvider(enabled: true),
        child: KillSwitchGate(
          child: MaterialApp(home: Scaffold(body: Text('App Content'))),
        ),
      ),
    );
    expect(find.text('App Content'), findsOneWidget);
    expect(find.byIcon(Icons.warning), findsNothing);
  });

  testWidgets('shows banner when appEnabled is false', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<KillSwitchProvider>.value(
        value: FakeKillSwitchProvider(enabled: false, message: 'Maintenance'),
        child: KillSwitchGate(
          child: MaterialApp(home: Scaffold(body: Text('App Content'))),
        ),
      ),
    );
    expect(find.text('Maintenance'), findsOneWidget);
    expect(find.byIcon(Icons.warning), findsOneWidget);
    expect(find.text('App Content'), findsNothing);
  });
}
