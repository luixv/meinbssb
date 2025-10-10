import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/compulsory_update_provider.dart';

class CompulsoryUpdateGate extends StatelessWidget {
  const CompulsoryUpdateGate({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final compulsoryUpdate = Provider.of<CompulsoryUpdateProvider>(context);
    if (compulsoryUpdate.updateRequired) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.system_update, size: 64, color: Colors.orange),
                const SizedBox(height: 24),
                Text(
                  compulsoryUpdate.updateMessage ??
                      'Um fortzufahren, müssen Sie das neue Update installieren.',
                  style: const TextStyle(fontSize: 20, color: Colors.orange),
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
