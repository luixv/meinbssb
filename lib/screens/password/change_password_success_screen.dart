import 'package:flutter/material.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:provider/provider.dart';
import '/constants/ui_styles.dart';
import '/widgets/scaled_text.dart';
import '/providers/font_size_provider.dart';

class ChangePasswordSuccessScreen extends StatelessWidget {
  const ChangePasswordSuccessScreen({
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
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return BaseScreenLayout(
      title: 'Passwort ändern',
      userData: userData,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
      body: Center(
        child: Semantics(
          label:
              success
                  ? 'Ihr Passwort wurde erfolgreich geändert.'
                  : 'Es ist ein Fehler beim Ändern des Passworts aufgetreten.',
          liveRegion: true,
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
              ScaledText(
                success
                    ? 'Ihr Passwort wurde erfolgreich geändert.'
                    : 'Es ist ein Fehler beim Ändern des Passworts aufgetreten.',
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
        label: 'Zurück zur Startseite',
        child: FloatingActionButton(
          heroTag: 'change_password_result_fab',
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(
              '/home',
              arguments: {'userData': userData, 'isLoggedIn': true},
            );
          },
          backgroundColor: UIConstants.defaultAppColor,
          child: const Icon(Icons.home, color: UIConstants.whiteColor),
        ),
      ),
    );
  }
}
