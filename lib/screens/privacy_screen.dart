// Project: Mein BSSB
// Filename: privacy_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key, required this.userData});
  final UserData? userData;

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Datenschutz',
      userData: userData,
      isLoggedIn: false,
      onLogout: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
      body: const Padding(
        padding: UIConstants.defaultPadding,
        child: ScaledText(
          UIConstants.privacyPlaceholder,
          style: UIStyles.bodyStyle,
        ),
      ),
    );
  }
}
