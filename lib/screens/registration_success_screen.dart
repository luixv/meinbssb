// Project: Mein BSSB
// Filename: registration_success_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/screens/app_menu.dart';
import '/screens/logo_widget.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  final String message;
  final Map<String, dynamic> userData;

  const RegistrationSuccessScreen({
    super.key,
    required this.message,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrierung', style: UIConstants.titleStyle),
        automaticallyImplyLeading: false,
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const LogoWidget(),
            SizedBox(height: UIConstants.defaultSpacing),
            Text(
              message,
              style: UIConstants.successStyle.copyWith(
                fontSize: UIConstants.titleFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
