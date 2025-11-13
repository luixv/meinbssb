import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart';
import '/providers/font_size_provider.dart';
import '/widgets/keyboard_focus_profile_button.dart';

class PersonalPictUploadSuccessScreen extends StatelessWidget {
  const PersonalPictUploadSuccessScreen({
    super.key,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return BaseScreenLayout(
      title: 'Profilbild erfolgreich',
      userData: userData,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
      body: Center(
        child: Semantics(
          label: 'Profilbild erfolgreich hochgeladen!',
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
                'Ihr Profilbild wurde erfolgreich hochgeladen!',
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
      floatingActionButton: KeyboardFocusProfileButton(
        heroTag: 'personalPictUploadSuccessFab',
        semanticLabel: 'Zurück zum Profil',
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(
            '/profile',
            arguments: {'userData': userData, 'isLoggedIn': isLoggedIn},
          );
        },
      ),
    );
  }
}
