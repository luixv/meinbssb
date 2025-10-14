import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
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
                SizedBox(height: 40),
                Image.asset(
                  'assets/images/BSSB_Wappen.png',
                  width: UIConstants.logoSize * 1.2,
                  height: UIConstants.logoSize * 1.2,
                ),
                const SizedBox(
                  height: 120,
                ), // Even more space between logo and icon
                const Icon(
                  Icons.system_update,
                  size: 64,
                  color: UIConstants.defaultAppColor,
                ),
                const SizedBox(height: 24),
                Text(
                  compulsoryUpdate.updateMessage ??
                      'Um fortzufahren, müssen Sie das neue Update installieren.',
                  style: const TextStyle(
                    fontSize: 20,
                    color: UIConstants.defaultAppColor,
                  ),
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
