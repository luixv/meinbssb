// Project: Mein BSSB
// Filename: logo_widget.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/services/config_service.dart'; // Use ConfigService instead of LocalizationService

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final logoName = ConfigService.getString('logoName', 'appTheme');
    return Image.asset(
      logoName ?? 'assets/images/default_logo.png', // Use null-aware operator for safety
      height: UIConstants.logoSize,
      width: UIConstants.logoSize,
    );
  }
}