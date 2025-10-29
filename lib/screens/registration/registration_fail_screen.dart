import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';

class RegistrationFailScreen extends StatelessWidget {
  const RegistrationFailScreen({
    super.key,
    required this.message,
    required this.userData,
  });
  final String message;
  final UserData? userData;

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Registrierung fehlgeschlagen',
      userData: userData,
      isLoggedIn: false,
      onLogout: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
      body: Semantics(
        label:
            'Registrierung fehlgeschlagen. Fehlermeldung und Option zur Rückkehr zum Login.',
        child: Center(
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
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'registrationFailFab',
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(
            '/login',
            arguments: {'userData': userData, 'isLoggedIn': false},
          );
        },
        backgroundColor: UIConstants.defaultAppColor,
        child: const Icon(Icons.login, color: UIConstants.whiteColor),
      ),
    );
  }
}
