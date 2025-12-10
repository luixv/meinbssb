import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wrapper widget that properly handles edge-to-edge display on Android 15+
/// This ensures your app content doesn't get obscured by system UI elements
class EdgeToEdgeWrapper extends StatelessWidget {
  const EdgeToEdgeWrapper({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style to be transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return child;
  }
}
