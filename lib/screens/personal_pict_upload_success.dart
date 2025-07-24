import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart'; // Import UIStyles
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart'; // Import ScaledText
import '/services/core/font_size_provider.dart'; // Import FontSizeProvider

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
      title: 'Profilbild erfolgreich', // Updated title
      userData: userData,
      isLoggedIn: isLoggedIn, // User should be logged in here
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
              'Ihr Profilbild wurde erfolgreich hochgeladen!', // Updated message
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
        heroTag: 'personalPictUploadSuccessFab',
        onPressed: () {
          // Navigate back to the profile screen or a suitable home screen
          // Adjust '/profile' to your actual profile or home route if different.
          Navigator.of(context).pushReplacementNamed(
            '/profile', // Assuming a '/profile' route exists
            arguments: {'userData': userData, 'isLoggedIn': isLoggedIn},
          );
        },
        backgroundColor: UIConstants.defaultAppColor,
        child: const Icon(
          Icons.arrow_forward, // Changed icon to indicate moving forward
          color: UIConstants.whiteColor,
        ),
      ),
    );
  }
}
