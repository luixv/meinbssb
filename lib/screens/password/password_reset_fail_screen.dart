import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';
import 'package:provider/provider.dart';
import '/constants/ui_styles.dart';
import '/widgets/scaled_text.dart';
import '/providers/font_size_provider.dart';

class PasswordResetFailScreen extends StatelessWidget {
  const PasswordResetFailScreen({
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
      title: 'Passwort-Reset fehlgeschlagen',
      userData: userData,
      isLoggedIn: false,
      onLogout: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
      body: Semantics(
        label:
            'Passwort-Reset fehlgeschlagen. Ihr Passwort konnte nicht zurückgesetzt werden. Fehlermeldung und Rückkehr zur Login-Seite.',
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'passwordResetFailFab',
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
