import 'package:flutter/material.dart';
import 'package:meinbssb/screens/app_menu.dart';
import 'logo_widget.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  final String message;
  final Map<String, dynamic> userData;

  const RegistrationSuccessScreen({super.key, required this.message, required this.userData}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrierung'),
        automaticallyImplyLeading: false,
        actions: [
          AppMenu(
            context: context,
            userData: userData,
            showSingleMenuItem: true,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const LogoWidget(), // Added const here
            const SizedBox(height: 20), //Added const here
            Text(
              message,
              style: const TextStyle(fontSize: 20, color: Colors.green), //Added const here
            ),
          ],
        ),
      ),
    );
  }
}