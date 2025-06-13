// Project: Mein BSSB
// Filename: privacy_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key, required this.userData});
  final UserData? userData;

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Datenschutz',
      userData: userData,
      isLoggedIn: false,
      onLogout: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
      body: const Padding(
        padding: UIConstants.defaultPadding,
        child: Text(
          'Hier stehen die Datenschutzbestimmungen des BSSB.',
          style: UIConstants.bodyStyle,
        ),
      ),
    );
  }
}
