import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'app_menu.dart';

class PrivacyPage extends StatelessWidget {
  final Map<String, dynamic> userData;
  const PrivacyPage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Datenschutzbestimmungen', style: UIConstants.titleStyle),
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
      body: Padding(
        padding: EdgeInsets.all(UIConstants.defaultPadding),
        child: Text(
          'Hier stehen die Datenschutzbestimmungen des BSSB.',
          style: UIConstants.bodyStyle,
        ),
      ),
    );
  }
}
