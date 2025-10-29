import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import '/widgets/scaled_text.dart';
import '/models/user_data.dart';

import '/screens/personal_data_screen.dart';
import '/screens/contact_data_screen.dart';
import '/screens/bankdata/bank_data_screen.dart';
import '/screens/password/change_password_screen.dart';
import '/screens/schulungen/absolvierte_schulungen_screen.dart';
import '/screens/logo_widget.dart';
import '/screens/personal_pict_upload_screen.dart';
import '/screens/ausweis/ausweis_bestellen_screen.dart';

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
      title: 'Profil',
      userData: userData,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
      automaticallyImplyLeading: true,
      body: Semantics(
        label:
            'Profilbereich mit Zugriff auf Profilbild, persönliche Daten, Kontaktdaten, Bankdaten, absolvierte Schulungen, Passwortänderung und Schützenausweisbestellung.',
        child: SingleChildScrollView(
          padding: UIConstants.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LogoWidget(),
              const SizedBox(height: UIConstants.spacingS),
              const ScaledText('Profil', style: UIStyles.headerStyle),
              const SizedBox(height: UIConstants.spacingM),
              _buildMenuItem(
                context,
                'Profilbild',
                Icons.add_a_photo_outlined,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => PersonalPictUploadScreen(
                            userData: userData,
                            isLoggedIn: isLoggedIn,
                            onLogout: onLogout,
                          ),
                    ),
                  );
                },
              ),
              _buildMenuItem(context, 'Persönliche Daten', Icons.person, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => PersonDataScreen(
                          userData,
                          isLoggedIn: isLoggedIn,
                          onLogout: onLogout,
                        ),
                  ),
                );
              }),
              _buildMenuItem(context, 'Kontaktdaten', Icons.contact_mail, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ContactDataScreen(
                          userData,
                          isLoggedIn: isLoggedIn,
                          onLogout: onLogout,
                        ),
                  ),
                );
              }),
              _buildMenuItem(context, 'Bankdaten', Icons.account_balance, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => BankDataScreen(
                          userData,
                          webloginId: userData?.webLoginId ?? 0,
                          isLoggedIn: isLoggedIn,
                          onLogout: onLogout,
                        ),
                  ),
                );
              }),
              _buildMenuItem(
                context,
                'Absolvierte Schulungen',
                Icons.task_alt,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AbsolvierteSchulungenScreen(
                            userData,
                            isLoggedIn: isLoggedIn,
                            onLogout: onLogout,
                          ),
                    ),
                  );
                },
              ),
              _buildMenuItem(context, 'Passwort ändern', Icons.lock, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ChangePasswordScreen(
                          userData: userData,
                          isLoggedIn: isLoggedIn,
                          onLogout: onLogout,
                        ),
                  ),
                );
              }),
              _buildMenuItem(
                context,
                'Schützenausweis bestellen',
                Icons.search_off,
                () {
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
                },
              ),
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
