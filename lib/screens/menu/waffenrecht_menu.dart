import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/user_data.dart';
import '/widgets/scaled_text.dart';
import '/screens/beduerfnisse/beduerfnisbescheinigung_screen.dart';
import '/screens/base_screen_layout.dart';

class WaffenrechtMenuScreen extends StatelessWidget {
  const WaffenrechtMenuScreen({
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
      title: 'Waffenrecht',
      userData: userData,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
      automaticallyImplyLeading: true,
      body: Semantics(
        label: 'Waffenrechtmenü: Bedürfnisse.',
        child: SingleChildScrollView(
          padding: UIConstants.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScaledText('Waffenrecht', style: UIStyles.headerStyle),
              const SizedBox(height: UIConstants.spacingM),
              _buildMenuItem(context, 'Bedürfnisse', Icons.list_alt, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => BeduerfnisbescheinigungScreen(
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
    return Semantics(
      label: '$title Menüpunkt',
      hint: 'Öffnet den Bereich $title',
      button: true,
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
