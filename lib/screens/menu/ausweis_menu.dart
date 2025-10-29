import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import '/widgets/scaled_text.dart';
import '/models/user_data.dart';

import '/screens/logo_widget.dart';
import '/screens/ausweis/ausweis_bestellen_screen.dart';
import '/screens/ausweis/ausweis_screen.dart';
import '/screens/startrechte/starting_rights_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
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
      title: 'Schützenausweis',
      userData: userData,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
      automaticallyImplyLeading: true,
      body: Semantics(
        label:
            'Menübereich für Schützenausweis: Ausweis anzeigen, Startrechte einsehen, Ausweis bestellen.',
        child: SingleChildScrollView(
          padding: UIConstants.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LogoWidget(),
              const SizedBox(height: UIConstants.spacingS),
              const ScaledText('Schützenausweis', style: UIStyles.headerStyle),
              const SizedBox(height: UIConstants.spacingM),
              _buildMenuItem(context, 'Anzeigen', Icons.badge, () {
                if (userData != null && userData?.personId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => SchuetzenausweisScreen(
                            personId: userData!.personId,
                            userData: userData!,
                            isLoggedIn: isLoggedIn,
                            onLogout: onLogout,
                          ),
                    ),
                  );
                }
              }),
              _buildMenuItem(context, 'Startrechte', Icons.rule, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => StartingRightsScreen(
                          userData: userData,
                          isLoggedIn: isLoggedIn,
                          onLogout: onLogout,
                        ),
                  ),
                );
              }),
              _buildMenuItem(context, 'Bestellen', Icons.search_off, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => AusweisBestellenScreen(
                          userData: userData,
                          isLoggedIn: isLoggedIn,
                          onLogout: onLogout,
                        ),
                  ),
                );
              }),
              const SizedBox(height: UIConstants.helpSpacing),
            ],
          ),
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
        trailing: const Icon(Icons.chevron_right, semanticLabel: 'Weiter'),
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
