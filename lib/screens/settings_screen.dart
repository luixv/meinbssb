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
      title: 'Einstellungen',
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
                  'Schriftgröße',
                  style: UIStyles.titleStyle,
                ),
                UIConstants.verticalSpacingS,
                Row(
                  mainAxisAlignment: UIConstants.spaceBetweenAlignment,
                  children: [
                    const Expanded(
                      child: ScaledText(
                        'Anpassung der Textgröße für bessere Lesbarkeit',
                        style: UIStyles.bodyStyle,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 48,
                          child: IconButton(
                            onPressed: fontSizeProvider.decreaseFontSize,
                            style: IconButton.styleFrom(
                              backgroundColor: UIConstants.defaultAppColor,
                              foregroundColor: UIConstants.whiteColor,
                              shape: const CircleBorder(),
                            ),
                            icon: const Icon(Icons.remove),
                          ),
                        ),
                        UIConstants.horizontalSpacingS,
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 48,
                              child: IconButton(
                                onPressed: fontSizeProvider.resetFontSize,
                                style: IconButton.styleFrom(
                                  backgroundColor: UIConstants.defaultAppColor,
                                  foregroundColor: UIConstants.whiteColor,
                                  shape: const CircleBorder(),
                                ),
                                icon: const Icon(Icons.refresh),
                              ),
                            ),
                            ScaledText(
                              '${(fontSizeProvider.scaleFactor * 100).round()}%',
                              style: UIStyles.bodyStyle,
                            ),
                          ],
                        ),
                        UIConstants.horizontalSpacingS,
                        SizedBox(
                          height: 48,
                          child: IconButton(
                            onPressed: fontSizeProvider.increaseFontSize,
                            style: IconButton.styleFrom(
                              backgroundColor: UIConstants.defaultAppColor,
                              foregroundColor: UIConstants.whiteColor,
                              shape: const CircleBorder(),
                            ),
                            icon: const Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                UIConstants.verticalSpacingXL,
                const ScaledText(
                  'Kontrast',
                  style: UIStyles.titleStyle,
                ),
                UIConstants.verticalSpacingS,
                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        title: const ScaledText(
                          'Hoher Kontrast',
                          style: UIStyles.bodyStyle,
                        ),
                        subtitle: const ScaledText(
                          'Verbesserte Lesbarkeit',
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
