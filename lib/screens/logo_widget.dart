import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/services/api_service.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final logoName = apiService.configService.getString('logoName', 'appTheme');
    return Image.asset(
      logoName ?? 'assets/images/myBSSB-logo.png',
      height: UIConstants.logoSize,
      width: UIConstants.logoSize,
    );
  }
}
