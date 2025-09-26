import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/constants/messages.dart';
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart';
import '../providers/font_size_provider.dart';

class AusweisBestellendSuccessScreen extends StatelessWidget {
  const AusweisBestellendSuccessScreen({
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
      title: Messages.ausweisBestellenTitle,
      userData: userData,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: UIConstants.iconSizeXL,
            ),
            const SizedBox(height: UIConstants.spacingM),
            ScaledText(
              // Using ScaledText
              'Die Bestellung des Schützenausweises wurde erfolgreich abgeschlossen.',
              style: UIStyles.dialogContentStyle.copyWith(
                // Using UIStyles.dialogTextStyle
                fontSize: UIStyles.dialogContentStyle.fontSize! *
                    fontSizeProvider.scaleFactor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.spacingM),
            ScaledText(
              // Using ScaledText for additional message
              'Sie können nun zu Ihrem Profil zurückkehren.',
              style: UIStyles.bodyStyle.copyWith(
                // Using UIStyles.bodyStyle
                fontSize:
                    UIStyles.bodyStyle.fontSize! * fontSizeProvider.scaleFactor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'ausweisBestellenSuccessFab',
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(
            '/home',
            arguments: {'userData': userData, 'isLoggedIn': isLoggedIn},
          );
        },
        backgroundColor: UIConstants.defaultAppColor,
        child: const Icon(
          Icons.home,
          color: UIConstants.whiteColor,
        ),
      ),
    );
  }
}
