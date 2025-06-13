// Project: Mein BSSB
// Filename: password_reset_success_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/screens/logo_widget.dart';
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({
    super.key,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });
  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Passwort zurücksetzen',
      userData: userData,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LogoWidget(),
            const SizedBox(height: UIConstants.spacingL),
            const Icon(
              Icons.check_circle_outline,
              size: UIConstants.defaultIconSize,
              color: UIConstants.successColor,
            ),
            const SizedBox(height: UIConstants.spacingM),
            const Text(
              'Passwort erfolgreich zurückgesetzt',
              style: UIConstants.titleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.spacingM),
            const Text(
              'Sie können sich jetzt mit Ihrem neuen Passwort anmelden.',
              style: UIConstants.bodyStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.spacingL),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: UIConstants.primaryButtonStyle,
              child: const Text('Zurück zum Login'),
            ),
          ],
        ),
      ),
    );
  }
}
