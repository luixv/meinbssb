import 'package:flutter/material.dart';
import 'app_menu.dart';

class PrivacyPage extends StatelessWidget {
  final Map<String, dynamic> userData;
  const PrivacyPage({super.key, required this.userData}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datenschutzbestimmungen'),
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
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Hier stehen die Datenschutzbestimmungen des BSSB.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}