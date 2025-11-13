import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/messages.dart';
import '/constants/ui_styles.dart';

import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';
import '/providers/font_size_provider.dart';
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
      title: Messages.settingsTitle,
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
                        fontSize: UIConstants.largeFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            _SettingsButton(
                              heroTag: 'decrease_font_size',
                              onPressed: fontSizeProvider.scaleFactor <= 0.8
                                  ? null
                                  : () => fontSizeProvider.decreaseFontSize(),
                              icon: Icons.remove,
                            ),
                            const SizedBox(width: UIConstants.spacingS),
                            _SettingsButton(
                              heroTag: 'reset_font_size',
                              onPressed: () => fontSizeProvider.resetFontSize(),
                              icon: Icons.refresh,
                            ),
                            const SizedBox(width: UIConstants.spacingS),
                            _SettingsButton(
                              heroTag: 'increase_font_size',
                              onPressed: fontSizeProvider.scaleFactor >= 1.6
                                  ? null
                                  : () => fontSizeProvider.increaseFontSize(),
                              icon: Icons.add,
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
                  Messages.fontSizeDescription,
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

// Custom Settings Button widget with keyboard-only focus highlighting
class _SettingsButton extends StatefulWidget {
  const _SettingsButton({
    required this.heroTag,
    required this.onPressed,
    required this.icon,
  });

  final String heroTag;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  State<_SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<_SettingsButton> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if focus is from keyboard navigation
    final isKeyboardMode = FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    final hasKeyboardFocus = _isFocused && isKeyboardMode;

    return SizedBox(
      width: UIConstants.smallButtonSize,
      height: UIConstants.smallButtonSize,
      child: Focus(
        focusNode: _focusNode,
          child: Container(
            decoration: hasKeyboardFocus
                ? BoxDecoration(
                    border: Border.all(
                      color: Colors.yellow.shade700,
                      width: 3.0,
                    ),
                  )
                : null,
          child: FloatingActionButton(
            heroTag: widget.heroTag,
            onPressed: widget.onPressed,
            backgroundColor: UIConstants.defaultAppColor,
            disabledElevation: 0,
            elevation: 2,
            shape: const CircleBorder(),
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: UIConstants.fabSmallIconSize,
            ),
          ),
        ),
      ),
    );
  }
}
