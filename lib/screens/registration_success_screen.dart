// Project: Mein BSSB
// Filename: registration_success_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/screens/app_menu.dart';
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
    return Scaffold(
      // Ändere die Hintergrundfarbe des Scaffolds.
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Registrierung erfolgreich',
          style: UIConstants.appBarTitleStyle,
        ),
        automaticallyImplyLeading: false,
        backgroundColor: UIConstants.backgroundColor,
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
            const SizedBox(height: UIConstants.spacingS),
            Text(
              message,
              style: UIConstants.successStyle,
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        heroTag: 'personalDataResultFab',
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(
            '/home',
            arguments: {'userData': userData, 'isLoggedIn': true},
          );
        },
        backgroundColor: UIConstants.defaultAppColor,
        child: const Icon(
          Icons.home,
          color: UIConstants.whiteColor,
        ),
      ),
    );
  }
}
