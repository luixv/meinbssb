import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import '/widgets/scaled_text.dart';
import '/models/user_data.dart';

class QRCodeScreen extends StatelessWidget {
  const QRCodeScreen({
    super.key,
    required this.qrCodeBytes,
    this.userData,
    this.isLoggedIn = false,
    required this.onLogout,
  });
  final Uint8List qrCodeBytes;
  final UserData? userData;
  final bool isLoggedIn;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'QR Code',
      userData: userData,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
      automaticallyImplyLeading: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: UIConstants.spacingS),
            const ScaledText(
              'QR Code',
              style: UIStyles.headerStyle,
            ),
            const SizedBox(height: UIConstants.spacingM),
            Center(
              child: qrCodeBytes.isNotEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: UIConstants.defaultAppColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(UIConstants.spacingM),
                      child: Image.memory(
                        qrCodeBytes,
                        width: 300,
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    )
                  : const Text('QR-Code konnte nicht geladen werden.'),
            ),
          ],
        ),
      ),
    );
  }
}
