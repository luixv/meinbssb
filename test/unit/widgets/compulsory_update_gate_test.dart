import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/widgets/compulsory_update_gate.dart';
import 'package:meinbssb/providers/compulsory_update_provider.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeRemoteConfig implements FirebaseRemoteConfig {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSharedPreferences implements SharedPreferences {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('CompulsoryUpdateGate shows child when updateRequired is false', (
    WidgetTester tester,
  ) async {
    final provider = CompulsoryUpdateProvider(
      remoteConfig: FakeRemoteConfig(),
      prefs: FakeSharedPreferences(),
    );
    await tester.pumpWidget(
      ChangeNotifierProvider<CompulsoryUpdateProvider>.value(
        value: provider,
        child: MaterialApp(
          home: CompulsoryUpdateGate(child: const Text('App Content')),
        ),
      ),
    );
    expect(find.text('App Content'), findsOneWidget);
    expect(find.textContaining('Update'), findsNothing);
  });

  testWidgets(
    'CompulsoryUpdateGate shows update message when updateRequired is true',
    (WidgetTester tester) async {
      final provider = CompulsoryUpdateProvider(
        remoteConfig: FakeRemoteConfig(),
        prefs: FakeSharedPreferences(),
      );
      provider.testUpdateRequired = true;
      provider.testUpdateMessage = 'Update required for testing';
      await tester.pumpWidget(
        ChangeNotifierProvider<CompulsoryUpdateProvider>.value(
          value: provider,
          child: MaterialApp(
            home: CompulsoryUpdateGate(child: const Text('App Content')),
          ),
        ),
      );
      expect(find.text('App Content'), findsNothing);
      expect(find.text('Update required for testing'), findsOneWidget);
    },
  );
}
