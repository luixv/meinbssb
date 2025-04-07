import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/myBSSB-logo.png', // This should come from the strings.json
      height: UIConstants.logoSize,
      width: UIConstants.logoSize,
    );
  }
}
