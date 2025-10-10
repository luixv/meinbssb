import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kill_switch_provider.dart';

class KillSwitchGate extends StatelessWidget {
  const KillSwitchGate({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final killSwitch = Provider.of<KillSwitchProvider>(context);

    if (!killSwitch.appEnabled) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning, size: 64, color: Colors.red),
                const SizedBox(height: 24),
                Text(
                  killSwitch.message ??
                      'Die App ist vorübergehend deaktiviert.',
                  style: const TextStyle(fontSize: 20, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return child;
  }
}
