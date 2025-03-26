import 'package:flutter/material.dart';
import 'app_menu.dart'; 

class PasswordResetSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  const PasswordResetSuccessScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passwort zurückgesetzt'),
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
        child: Text('Ihr Passwort wurde erfolgreich zurückgesetzt.'),
      ),
    );
  }
}