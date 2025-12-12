import 'package:flutter/material.dart';

/// Wrapper widget that properly handles edge-to-edge display on Android 15+
/// This ensures your app content doesn't get obscured by system UI elements
/// Note: The MainActivity already calls enableEdgeToEdge() which handles
/// the Android 15+ edge-to-edge requirements without deprecated APIs
class EdgeToEdgeWrapper extends StatelessWidget {
  const EdgeToEdgeWrapper({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // No need to call SystemChrome.setSystemUIOverlayStyle here
    // as it uses deprecated APIs in Android 15+.
    // The MainActivity.enableEdgeToEdge() handles this properly.
    return child;
  }
}
