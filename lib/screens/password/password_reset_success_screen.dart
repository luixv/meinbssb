import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';
import 'package:provider/provider.dart';
import '/constants/ui_styles.dart';
import '/widgets/scaled_text.dart';
import '/providers/font_size_provider.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({
    super.key,
    required this.message,
    required this.userData,
  });
  final String message;
  final UserData? userData;

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return BaseScreenLayout(
      title: 'Passwort-Reset erfolgreich',
      userData: userData,
      isLoggedIn: false,
      onLogout: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
      body: Center(
        child: Semantics(
          label: 'Passwort erfolgreich zurückgesetzt. $message',
          liveRegion: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: UIConstants.iconSizeXL,
              ),
              const SizedBox(height: UIConstants.spacingM),
              ScaledText(
                message,
                style: UIStyles.dialogContentStyle.copyWith(
                  fontSize:
                      UIStyles.dialogContentStyle.fontSize! *
                      fontSizeProvider.scaleFactor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Semantics(
        button: true,
        label: 'Zurück zum Login',
        child: FloatingActionButton(
          heroTag: 'passwordResetSuccessFab',
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(
              '/login',
              arguments: {'userData': userData, 'isLoggedIn': false},
            );
          },
          backgroundColor: UIConstants.defaultAppColor,
          child: const Icon(Icons.login, color: UIConstants.whiteColor),
        ),
      ),
    );
  }
}
