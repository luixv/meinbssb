import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_styles.dart';
import '/constants/ui_constants.dart';
import '/models/user_data.dart';
import '/services/core/font_size_provider.dart';
import '/services/core/theme_provider.dart';
import '/widgets/scaled_text.dart';
import '/screens/base_screen_layout.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
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
    return BaseScreenLayout(
      title: UIConstants.settingsTitle,
      userData: userData,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
      automaticallyImplyLeading: true,
      body: Consumer2<FontSizeProvider, ThemeProvider>(
        builder: (context, fontSizeProvider, themeProvider, child) {
          return Padding(
            padding: UIConstants.screenPadding,
            child: Column(
              crossAxisAlignment: UIConstants.startCrossAlignment,
              children: [
                const ScaledText(
                  UIConstants.fontSizeTitle,
                  style: UIStyles.titleStyle,
                ),
                UIConstants.verticalSpacingS,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: UIConstants.spaceBetweenAlignment,
                  children: [
                    const Expanded(
                      child: ScaledText(
                        UIConstants.fontSizeDescription,
                        style: UIStyles.bodyStyle,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: fontSizeProvider.decreaseFontSize,
                          style: IconButton.styleFrom(
                            backgroundColor:
                                UIConstants.fontSizeButtonBackground,
                            foregroundColor:
                                UIConstants.fontSizeButtonTextColor,
                            shape: const CircleBorder(),
                          ),
                          icon: const Icon(Icons.remove),
                        ),
                        UIConstants.horizontalSpacingS,
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: fontSizeProvider.resetFontSize,
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    UIConstants.fontSizeButtonBackground,
                                foregroundColor:
                                    UIConstants.fontSizeButtonTextColor,
                                shape: const CircleBorder(),
                              ),
                              icon: const Icon(Icons.refresh),
                            ),
                            ScaledText(
                              '${(fontSizeProvider.scaleFactor * 100).round()}%',
                              style: UIStyles.bodyStyle,
                            ),
                          ],
                        ),
                        UIConstants.horizontalSpacingS,
                        IconButton(
                          onPressed: fontSizeProvider.increaseFontSize,
                          style: IconButton.styleFrom(
                            backgroundColor:
                                UIConstants.fontSizeButtonBackground,
                            foregroundColor:
                                UIConstants.fontSizeButtonTextColor,
                            shape: const CircleBorder(),
                          ),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
                UIConstants.verticalSpacingXL,
                const ScaledText(
                  UIConstants.contrastTitle,
                  style: UIStyles.titleStyle,
                ),
                UIConstants.verticalSpacingS,
                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        title: const ScaledText(
                          UIConstants.highContrastTitle,
                          style: UIStyles.bodyStyle,
                        ),
                        subtitle: const ScaledText(
                          UIConstants.highContrastDescription,
                          style: UIStyles.bodyStyle,
                        ),
                        value: themeProvider.isHighContrast,
                        onChanged: (value) {
                          themeProvider.toggleHighContrast();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
