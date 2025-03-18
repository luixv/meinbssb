import 'package:flutter/material.dart';
import 'app_menu.dart'; // Import your app menu
import 'logo_widget.dart'; //import the logo widget

class RegistrationSuccessScreen extends StatelessWidget {
  final String message;
  final Map<String, dynamic> userData;

  RegistrationSuccessScreen({required this.message, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrierung'), // Use the same title
        automaticallyImplyLeading: false, // Keep the same behavior
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
            LogoWidget(),
            SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(fontSize: 20, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}