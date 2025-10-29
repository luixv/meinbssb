import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';

class EmailVerificationFailScreen extends StatelessWidget {
  const EmailVerificationFailScreen({
    super.key,
    required this.message,
    required this.userData,
  });
  final String message;
  final UserData? userData;

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'E-Mail-Bestätigung fehlgeschlagen',
      userData: userData,
      isLoggedIn: userData != null,
      onLogout: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.error,
              color: Colors.red,
              size: UIConstants.iconSizeXL,
            ),
            const SizedBox(height: UIConstants.spacingM),
            Text(
              message,
              style: const TextStyle(fontSize: UIConstants.dialogFontSize),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'emailVerificationFailFab',
        onPressed: () {
          if (userData != null) {
            Navigator.of(context).pushReplacementNamed(
              '/contact-data',
              arguments: {'userData': userData, 'isLoggedIn': true},
            );
          } else {
            Navigator.of(context).pushReplacementNamed(
              '/login',
              arguments: {'userData': userData, 'isLoggedIn': false},
            );
          }
        },
        backgroundColor: UIConstants.defaultAppColor,
        child: Icon(
          userData != null ? Icons.contacts : Icons.login,
          color: UIConstants.whiteColor,
        ),
      ),
    );
  }
}
