// Project: Mein BSSB
// Filename: password_reset_success_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/screens/app_menu.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key, required this.userData});
  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ändere die Hintergrundfarbe des Scaffolds.
      backgroundColor:
          UIConstants.backgroundGreen, // Setze die Hintergrundfarbe
      appBar: AppBar(
        title:
            const Text('Passwort zurückgesetzt', style: UIConstants.titleStyle),
        actions: [
          AppMenu(
            context: context,
            userData: userData,
            isLoggedIn: false,
            onLogout: () {
              // Navigate back to the login screen.
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Ihr Passwort wurde erfolgreich zurückgesetzt.',
          style: UIConstants.bodyStyle,
        ),
      ),
    );
  }
}
