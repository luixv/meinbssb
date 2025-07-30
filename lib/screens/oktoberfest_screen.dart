import 'package:flutter/material.dart';
import 'package:meinbssb/screens/qr_code_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:provider/provider.dart';

import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import '/screens/logo_widget.dart';
import '/widgets/scaled_text.dart';
import '/models/user_data.dart';
import '/screens/oktoberfest_results_screen.dart';
import '/screens/oktoberfest_gewinn_screen.dart';

import '/services/core/config_service.dart';

class OktoberfestScreen extends StatelessWidget {
  const OktoberfestScreen({
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
      title: 'Oktoberfest',
      userData: userData,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
      automaticallyImplyLeading: true,
      body: SingleChildScrollView(
        padding: UIConstants.defaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LogoWidget(),
            const SizedBox(height: UIConstants.spacingS),
            const ScaledText(
              'Oktoberfest',
              style: UIStyles.headerStyle,
            ),
            const SizedBox(height: UIConstants.spacingM),
            _buildMenuItem(
              context,
              'Oktoberfest: Meine Ergebnisse',
              Icons.bar_chart,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OktoberfestResultsScreen(
                      passnummer: userData?.passnummer ?? '',
                      configService:
                          Provider.of<ConfigService>(context, listen: false),
                      userData: userData,
                      isLoggedIn: isLoggedIn,
                      onLogout: onLogout,
                    ),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              'Oktoberfest: Meine Gewinne',
              Icons.emoji_events,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OktoberfestGewinnScreen(
                      passnummer: userData?.passnummer ?? '',
                      configService:
                          Provider.of<ConfigService>(context, listen: false),
                      userData: userData,
                      isLoggedIn: isLoggedIn,
                      onLogout: onLogout,
                    ),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              'QR Code',
              Icons.qr_code,
              () async {
                final apiService =
                    Provider.of<ApiService>(context, listen: false);

                final qrBytes = await apiService.getEncryptedQRCode(
                  userData?.personId ?? 0,
                  userData?.geburtsdatum ?? DateTime.now(),
                  userData?.vorname ?? '',
                  userData?.namen ?? '',
                  userData?.strasse ?? '',
                  userData?.plz ?? '',
                  userData?.ort ?? '',
                  userData?.land ?? '',
                  userData?.passnummer ?? '',
                );
                if (qrBytes != null) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => QRCodeScreen(
                        qrCodeBytes: qrBytes,
                        isLoggedIn: isLoggedIn,
                        onLogout: onLogout,
                      ),
                    ),
                  );
                } else {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('QR-Code konnte nicht generiert werden.'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingS),
      child: ListTile(
        leading: Icon(
          icon,
          color: UIStyles.profileIconColor,
          semanticLabel: title,
        ),
        title: ScaledText(
          title,
          style: const TextStyle(
            fontSize: UIConstants.titleFontSize,
            fontFamily: UIConstants.defaultFontFamily,
            fontWeight: FontWeight.w500,
            color: UIConstants.textColor,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          semanticLabel: 'Weiter',
        ),
        onTap: onTap,
        minLeadingWidth: UIConstants.defaultIconWidth,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingM,
          vertical: UIConstants.spacingS,
        ),
      ),
    );
  }
}
