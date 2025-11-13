// In lib/screens/person_data_result_screen.dart

import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/messages.dart';

import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:provider/provider.dart';
import '/constants/ui_styles.dart';
import '/widgets/scaled_text.dart';
import '/providers/font_size_provider.dart';

class PersonalDataSuccessScreen extends StatelessWidget {
  const PersonalDataSuccessScreen({
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
      title: 'Persönliche Daten',
      userData: userData,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
      body: Center(
        child: Semantics(
          label:
              success
                  ? 'Ihre persönlichen Daten wurden erfolgreich gespeichert.'
                  : 'Es ist ein Fehler beim Speichern der persönlichen Daten aufgetreten.',
          liveRegion: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? Colors.green : Colors.red,
                size: UIConstants.iconSizeXL,
              ),
              const SizedBox(height: UIConstants.spacingM),
              ScaledText(
                success ? Messages.personalDataSaved : Messages.errorOccurred,
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
        label: 'Zurück zum Profil',
        child: FloatingActionButton(
          heroTag: 'personalDataResultFab',
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(
              '/profile',
              arguments: {'userData': userData, 'isLoggedIn': true},
            );
          },
          backgroundColor: UIConstants.defaultAppColor,
          child: const Tooltip(
            message: 'Profil',
            child: Icon(Icons.person, color: UIConstants.whiteColor),
          ),
        ),
      ),
    );
  }
}
