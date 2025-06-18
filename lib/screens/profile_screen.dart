import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/screens/base_screen_layout.dart';
import '/screens/logo_widget.dart';
import '/widgets/scaled_text.dart';
import '/models/user_data.dart';
import '/screens/personal_data_screen.dart';
import '/screens/contact_data_screen.dart';
import '/screens/bank_data_screen.dart';
import '/screens/change_password_screen.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LogoWidget(),
            const SizedBox(height: UIConstants.spacingS),
            const ScaledText(
              'Profil',
              style: UIStyles.headerStyle,
            ),
            const SizedBox(height: UIConstants.spacingM),
            _buildMenuItem(
              context,
              'Profilbild',
              Icons.account_circle,
              () {
                // TODO: Implement profile picture functionality
              },
            ),
            _buildMenuItem(
              context,
              'Persönliche Daten',
              Icons.person,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonDataScreen(
                      userData,
                      isLoggedIn: isLoggedIn,
                      onLogout: onLogout,
                    ),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              'Kontaktdaten',
              Icons.contact_mail,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactDataScreen(
                      userData,
                      isLoggedIn: isLoggedIn,
                      onLogout: onLogout,
                    ),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              'Bankdaten',
              Icons.account_balance,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BankDataScreen(
                      userData,
                      webloginId: userData?.webLoginId ?? 0,
                      isLoggedIn: isLoggedIn,
                      onLogout: onLogout,
                    ),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              'Passwort ändern',
              Icons.lock,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordScreen(
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
          color: UIConstants.defaultAppColor,
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
        minLeadingWidth: 48,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingM,
          vertical: UIConstants.spacingS,
        ),
      ),
    );
  }
}
