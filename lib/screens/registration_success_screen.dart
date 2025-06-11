// Project: Mein BSSB
// Filename: registration_success_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/screens/base_screen_layout.dart';
import '/screens/logo_widget.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  const RegistrationSuccessScreen({
    super.key,
    required this.message,
    required this.userData,
  });
  final String message;
  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Registrierung erfolgreich',
      userData: userData,
      isLoggedIn: false,
      onLogout: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const LogoWidget(),
            const SizedBox(height: UIConstants.spacingS),
            Text(
              message,
              style: UIConstants.successStyle,
            ),
          ],
        ),
      ),
    );
  }
}
