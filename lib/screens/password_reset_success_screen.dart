// Project: Mein BSSB
// Filename: password_reset_success_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/screens/logo_widget.dart';
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';
import '/screens/login_screen.dart';
import '/services/api/auth_service.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({
    super.key,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
    required this.authService,
  });
  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;
  final AuthService authService;

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
              UIConstants.passwordResetSuccessTitle,
              style: UIStyles.titleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.spacingM),
            const Text(
              UIConstants.passwordResetSuccessMessage,
              style: UIStyles.bodyStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.spacingL),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(
                      onLoginSuccess: (userData) {
                        Navigator.of(context).pushReplacementNamed('/home');
                      },
                    ),
                  ),
                );
              },
              style: UIStyles.primaryButtonStyle,
              child: const Text(
                UIConstants.backToLoginButtonLabel,
                style: UIStyles.buttonStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
