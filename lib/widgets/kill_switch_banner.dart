import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kill_switch_provider.dart';

class KillSwitchGate extends StatelessWidget {
  const KillSwitchGate({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer<KillSwitchProvider>(
      builder: (ctx, ks, _) {
        if (ks.appEnabled) return child;
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 80,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      ks.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(ks.body, textAlign: TextAlign.center),
                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      onPressed: () => ks.load(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Erneut prüfen'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
