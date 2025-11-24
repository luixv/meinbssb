import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import '/screens/logo_widget.dart';
import '/widgets/scaled_text.dart';
import '/models/user_data.dart';
import '/screens/menu/oktoberfest_menu.dart';
import '../oktoberfest/seventyfive_jahre_bssb_gewinn_screen.dart';

import '/services/api_service.dart';

class PreisschiessenScreen extends StatelessWidget {
  const PreisschiessenScreen({
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
    // Check if current date is >= December 1st, 2025 at 0:00
    final releaseDate = DateTime(2025, 12, 1, 0, 0);
    final now = DateTime.now();
    final isSeventyFiveJahreBSSBVisible =
        now.isAfter(releaseDate) || now.isAtSameMomentAs(releaseDate);

    return Semantics(
      label:
          'Preisschießen Bereich. Wählen Sie zwischen Oktoberfest und 75 Jahre BSSB.',
      child: BaseScreenLayout(
        title: 'Preisschießen',
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
              Semantics(
                header: true,
                label: 'Preisschießen',
                child: ScaledText('Preisschießen', style: UIStyles.headerStyle),
              ),
              const SizedBox(height: UIConstants.spacingM),
              _buildMenuItem(
                context,
                'Oktoberfest',
                Icons.sports_bar_outlined,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => OktoberfestScreen(
                            userData: userData,
                            isLoggedIn: isLoggedIn,
                            onLogout: onLogout,
                          ),
                    ),
                  );
                },
              ),
              if (isSeventyFiveJahreBSSBVisible)
                _buildMenuItem(
                  context,
                  '75 Jahre BSSB',
                  Icons.celebration_outlined,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => SeventyFiveJahreBSSBGewinnScreen(
                              passnummer: userData?.passnummer ?? '',
                              apiService: Provider.of<ApiService>(
                                context,
                                listen: false,
                              ),
                              userData: userData,
                              isLoggedIn: isLoggedIn,
                              onLogout: onLogout,
                            ),
                      ),
                    );
                  },
                ),
            ],
          ), // Column
        ), // SingleChildScrollView
      ), // BaseScreenLayout
    ); // Semantics
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Semantics(
      button: true,
      label: title,
      hint: 'Doppelt tippen, um $title zu öffnen',
      child: Card(
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
          trailing: const Icon(Icons.chevron_right, semanticLabel: 'Weiter'),
          onTap: onTap,
          minLeadingWidth: UIConstants.defaultIconWidth,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingM,
            vertical: UIConstants.spacingS,
          ),
        ),
      ),
    );
  }
}
