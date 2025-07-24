import 'package:flutter/material.dart';
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
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
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
              'Oktoberfest Ergebnisse',
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
              'Oktoberfest Gewinne',
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
