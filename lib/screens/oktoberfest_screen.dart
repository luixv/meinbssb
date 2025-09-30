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
import 'oktoberfest_eintritt_festzelt_screen.dart';

import '/services/api_service.dart';

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
              'Meine Ergebnisse',
              Icons.bar_chart,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OktoberfestResultsScreen(
                      passnummer: userData?.passnummer ?? '',
                      apiService:
                          Provider.of<ApiService>(context, listen: false),
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
              'Meine Gewinne',
              Icons.emoji_events,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OktoberfestGewinnScreen(
                      passnummer: userData?.passnummer ?? '',
                      apiService:
                          Provider.of<ApiService>(context, listen: false),
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
              'Eintritt Festzelt',
              Icons.festival,
              () {
                final apiService =
                    Provider.of<ApiService>(context, listen: false);
                final now = DateTime.now();
                final formattedDate =
                    '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OktoberfestEintrittFestzelt(
                      date: formattedDate,
                      passnummer: userData?.passnummer ?? '',
                      vorname: userData?.vorname ?? '',
                      nachname: userData?.namen ?? '',
                      geburtsdatum: userData?.geburtsdatum != null
                          ? '${userData!.geburtsdatum!.day.toString().padLeft(2, '0')}.${userData!.geburtsdatum!.month.toString().padLeft(2, '0')}.${userData!.geburtsdatum!.year}'
                          : 'Nicht verfügbar',
                      apiService: apiService,
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
