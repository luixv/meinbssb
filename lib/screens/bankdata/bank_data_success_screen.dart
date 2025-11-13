import 'package:flutter/material.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:provider/provider.dart';
import '/constants/ui_styles.dart';
import '/widgets/scaled_text.dart';
import '/providers/font_size_provider.dart';
import '/widgets/keyboard_focus_profile_button.dart';

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
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return BaseScreenLayout(
      title: 'Bankdaten',
      userData: userData,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
      body: Center(
        child: Semantics(
          label:
              success
                  ? 'Ihre Bankdaten wurden erfolgreich gespeichert.'
                  : 'Es ist ein Fehler beim Speichern der Bankdaten aufgetreten.',
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
                    ? 'Ihre Bankdaten wurden erfolgreich gespeichert.'
                    : 'Es ist ein Fehler aufgetreten.',
                style: UIStyles.dialogContentStyle.copyWith(
                  fontSize:
                      UIStyles.dialogContentStyle.fontSize! *
                      fontSizeProvider.scaleFactor,
                ),
                //style: const TextStyle(fontSize: UIConstants.dialogFontSize),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: KeyboardFocusProfileButton(
        heroTag: 'bankDataResultFab',
        semanticLabel: 'Zurück zum Profil',
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(
            '/profile',
            arguments: {'userData': userData, 'isLoggedIn': true},
          );
        },
      ),
    );
  }
}
