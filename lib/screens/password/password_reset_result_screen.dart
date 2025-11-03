// Project: Mein BSSB
// Filename: password_reset_success_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/messages.dart';

import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/screens/logo_widget.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/screens/login_screen.dart';
import 'package:meinbssb/services/api/auth_service.dart';

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
        child: Semantics(
          label:
              'Passwort erfolgreich zurückgesetzt. Sie können sich jetzt mit Ihrem neuen Passwort anmelden. Bestätigung und Rückkehr zur Login-Seite.',
          liveRegion: true,
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
                Messages.passwordResetSuccessTitle,
                style: UIStyles.titleStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: UIConstants.spacingM),
              const Text(
                Messages.passwordResetSuccessMessage,
                style: UIStyles.bodyStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: UIConstants.spacingL),
              Semantics(
                button: true,
                label: Messages.backToLoginButtonLabel,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder:
                            (context) => LoginScreen(
                              onLoginSuccess: (userData) {
                                Navigator.of(
                                  context,
                                ).pushReplacementNamed('/home');
                              },
                            ),
                      ),
                    );
                  },
                  style: UIStyles.defaultButtonStyle,
                  child: const Text(
                    Messages.backToLoginButtonLabel,
                    style: UIStyles.buttonStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
