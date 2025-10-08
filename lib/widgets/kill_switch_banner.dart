import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kill_switch_provider.dart';

class KillSwitchGate extends StatelessWidget {
  const KillSwitchGate({
    super.key,
    required this.child,
    this.refreshButton = true,
  });

  final Widget child;
  final bool refreshButton;

  @override
  Widget build(BuildContext context) {
    return Consumer<KillSwitchProvider>(
      builder: (ctx, ks, _) {
        if (ks.appEnabled) return child;
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 72,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    ks.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(ks.body, textAlign: TextAlign.center),
                  if (refreshButton) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => ks.load(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Erneut prüfen'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
