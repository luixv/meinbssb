// Project: Mein BSSB
// Filename: privacy_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/screens/app_menu.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key, required this.userData});
  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ändere die Hintergrundfarbe des Scaffolds.
      backgroundColor:
          UIConstants.backgroundGreen, // Setze die Hintergrundfarbe
      appBar: AppBar(
        title: const Text(
          'Datenschutzbestimmungen',
          style: UIConstants.titleStyle,
        ),
        actions: [
          AppMenu(
            context: context,
            userData: userData,
            isLoggedIn: false,
            onLogout: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(UIConstants.defaultPadding),
        child: Text(
          'Hier stehen die Datenschutzbestimmungen des BSSB.',
          style: UIConstants.bodyStyle,
        ),
      ),
    );
  }
}
