import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/services/core/font_size_provider.dart';
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Einstellungen',
      userData: userData,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
      body: Consumer<FontSizeProvider>(
        builder: (context, fontSizeProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(UIConstants.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScaledText(
                  'Schriftgröße',
                  style: UIStyles.sectionTitleStyle,
                ),
                const SizedBox(height: UIConstants.spacingM),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: fontSizeProvider.decreaseFontSize,
                      iconSize: UIConstants.iconSizeL,
                      color: UIConstants.defaultAppColor,
                    ),
                    const SizedBox(width: UIConstants.spacingM),
                    ScaledText(
                      '${(fontSizeProvider.scaleFactor * 100).round()}%',
                      style: UIStyles.bodyTextStyle,
                    ),
                    const SizedBox(width: UIConstants.spacingM),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: fontSizeProvider.increaseFontSize,
                      iconSize: UIConstants.iconSizeL,
                      color: UIConstants.defaultAppColor,
                    ),
                  ],
                ),
                const SizedBox(height: UIConstants.spacingM),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: fontSizeProvider.resetFontSize,
                    icon: const Icon(Icons.restore),
                    label: const ScaledText(
                      'Zurücksetzen',
                      style: UIStyles.buttonStyle,
                    ),
                    style: UIStyles.defaultButtonStyle,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
