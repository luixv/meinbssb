import 'package:flutter/material.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/models/user_data.dart';

class BankDataSuccessScreen extends StatelessWidget {
  const BankDataSuccessScreen({
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
      title: 'Bankdaten',
      userData: userData,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color:
                  success ? UIConstants.successColor : UIConstants.errorColor,
              size: UIConstants.iconSizeXL,
            ),
            const SizedBox(height: UIConstants.spacingM),
            Text(
              success
                  ? 'Ihre Bankdaten wurden erfolgreich gespeichert.'
                  : 'Es ist ein Fehler aufgetreten.',
              style: const TextStyle(fontSize: UIConstants.dialogFontSize),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'bankDataResultFab',
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
