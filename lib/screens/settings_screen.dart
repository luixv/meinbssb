import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';
import '/services/core/font_size_provider.dart';
import '/widgets/scaled_text.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: UIConstants.settingsTitle,
      userData: userData,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
      automaticallyImplyLeading: true,
      body: Consumer<FontSizeProvider>(
        builder: (context, fontSizeProvider, child) {
          return Padding(
            padding: UIConstants.screenPadding,
            child: Column(
              crossAxisAlignment: UIConstants.startCrossAlignment,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ScaledText(
                      'Textgröße',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: UIConstants.smallButtonSize,
                              height: UIConstants.smallButtonSize,
                              child: FloatingActionButton(
                                heroTag: 'decrease_font_size',
                                onPressed: fontSizeProvider.scaleFactor <= 0.8
                                    ? null
                                    : () => fontSizeProvider.decreaseFontSize(),
                                backgroundColor: UIConstants.defaultAppColor,
                                disabledElevation: 0,
                                elevation: 2,
                                shape: const CircleBorder(),
                                child: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: UIConstants.fabSmallIconSize,
                                ),
                              ),
                            ),
                            const SizedBox(width: UIConstants.spacingS),
                            SizedBox(
                              width: UIConstants.smallButtonSize,
                              height: UIConstants.smallButtonSize,
                              child: FloatingActionButton(
                                heroTag: 'reset_font_size',
                                onPressed: () =>
                                    fontSizeProvider.resetFontSize(),
                                backgroundColor: UIConstants.defaultAppColor,
                                elevation: 2,
                                shape: const CircleBorder(),
                                child: const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: UIConstants.fabSmallIconSize,
                                ),
                              ),
                            ),
                            const SizedBox(width: UIConstants.spacingS),
                            SizedBox(
                              width: UIConstants.smallButtonSize,
                              height: UIConstants.smallButtonSize,
                              child: FloatingActionButton(
                                heroTag: 'increase_font_size',
                                onPressed: fontSizeProvider.scaleFactor >= 1.6
                                    ? null
                                    : () => fontSizeProvider.increaseFontSize(),
                                backgroundColor: UIConstants.defaultAppColor,
                                disabledElevation: 0,
                                elevation: 2,
                                shape: const CircleBorder(),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: UIConstants.fabSmallIconSize,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: UIConstants.spacingS),
                        ScaledText(
                          '${(fontSizeProvider.scaleFactor * 100).round()}%',
                          style: UIStyles.bodyStyle,
                        ),
                      ],
                    ),
                  ],
                ),
                UIConstants.verticalSpacingS,
                const ScaledText(
                  UIConstants.fontSizeDescription,
                  style: UIStyles.bodyStyle,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
