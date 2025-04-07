import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/myBSSB-logo.png', // This should come from the strings.json
      height: 100,
      width: 100,
    );
  }
}
