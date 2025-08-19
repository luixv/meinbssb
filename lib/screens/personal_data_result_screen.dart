// In lib/screens/person_data_result_screen.dart

import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/messages.dart';

import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/models/user_data.dart';

class PersonalDataResultScreen extends StatelessWidget {
  const PersonalDataResultScreen({
    super.key,
    required this.success,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });

  final bool success;
  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Persönliche Daten',
      userData: userData,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
              size: UIConstants.iconSizeXL,
            ),
            const SizedBox(height: UIConstants.spacingM),
            Text(
              success ? Messages.personalDataSaved : Messages.errorOccurred,
              style: const TextStyle(fontSize: UIConstants.dialogFontSize),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'personalDataResultFab',
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(
            '/profile',
            arguments: {'userData': userData, 'isLoggedIn': true},
          );
        },
        backgroundColor: UIConstants.defaultAppColor,
        child: const Icon(
          Icons.person,
          color: UIConstants.whiteColor,
        ),
      ),
    );
  }
}
