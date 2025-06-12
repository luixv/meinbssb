// Project: Mein BSSB
// Filename: logo_widget.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/services/core/config_service.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final configService = Provider.of<ConfigService>(context, listen: false);
    final logoName = configService.getString('logoName', 'appTheme');
    return Image.asset(
      logoName ?? 'assets/images/myBSSB-logo.png',
      height: UIConstants.logoSize,
      width: UIConstants.logoSize,
    );
  }
}
