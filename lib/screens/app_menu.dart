// Project: Mein BSSB
// Filename: app_menu.dart
// Author: Luis Mandel / NTT DATA

// Flutter/Dart core imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';

import '/screens/absolvierte_schulungen_screen.dart';
import 'schulungen_screen.dart';
import '/screens/password_reset_screen.dart';
import '/screens/registration_screen.dart';
import '/screens/schuetzenausweis_screen.dart';
import '/screens/starting_rights_screen.dart';
import '/screens/help_screen.dart';
import '/screens/impressum_screen.dart';
import '/screens/settings_screen.dart';
import '/screens/styles_screen.dart';

// Services
import '/services/api/auth_service.dart';
import '/services/core/email_service.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart';

class AppMenu extends StatelessWidget {
  const AppMenu({
    super.key,
    required this.context,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });

  final BuildContext context;
  final UserData? userData;
  final bool isLoggedIn;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu, color: UIStyles.menuIconColor),
      onPressed: () {
        Scaffold.of(context).openEndDrawer();
      },
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });
  static const double _drawerHeaderHeight = 120.0;
  static const double _drawerHeaderTopPadding = 40.0;
  static const double _drawerHeaderBottomPadding = 8.0;
  static const double _drawerHeaderLeftPadding = 16.0;
  static const double _menuTitleFontSize = 24.0;
  static const double _menuItemFontSize = 18.0;

  final UserData? userData;
  final bool isLoggedIn;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: _drawerHeaderHeight,
            decoration: const BoxDecoration(color: UIConstants.defaultAppColor),
            child: const Padding(
              padding: EdgeInsets.only(
                left: _drawerHeaderLeftPadding,
                top: _drawerHeaderTopPadding,
                bottom: _drawerHeaderBottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScaledText(
                    'Mein BSSB',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _menuTitleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoggedIn) ...[
            ListTile(
              leading: const Icon(Icons.home, color: UIStyles.menuIconColor),
              title: const ScaledText(
                'Home',
                style: TextStyle(fontSize: _menuItemFontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: UIStyles.menuIconColor),
              title: const ScaledText(
                'Profil',
                style: TextStyle(fontSize: _menuItemFontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.school_outlined,
                color: UIStyles.menuIconColor,
              ),
              title: const ScaledText(
                'Schulungen buchen',
                style: TextStyle(fontSize: _menuItemFontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SchulungenScreen(
                      userData,
                      isLoggedIn: isLoggedIn,
                      onLogout: onLogout,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.task_alt, color: UIStyles.menuIconColor),
              title: const ScaledText(
                'Absolvierte Schulungen',
                style: TextStyle(fontSize: _menuItemFontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AbsolvierteSchulungenScreen(
                      userData,
                      isLoggedIn: isLoggedIn,
                      onLogout: onLogout,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.badge, color: UIStyles.menuIconColor),
              title: const ScaledText(
                'Schützenausweis',
                style: TextStyle(fontSize: _menuItemFontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SchuetzenausweisScreen(
                      personId: userData?.personId ?? 0,
                      userData: userData,
                      isLoggedIn: isLoggedIn,
                      onLogout: onLogout,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.rule, color: UIStyles.menuIconColor),
              title: const ScaledText(
                'Startrechte Ändern',
                style: TextStyle(fontSize: _menuItemFontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StartingRightsScreen(
                      userData: userData,
                      isLoggedIn: isLoggedIn,
                      onLogout: onLogout,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.sports_bar_outlined,
                color: UIStyles.menuIconColor,
              ),
              title: const ScaledText(
                'Oktoberfestlandesschießen',
                style: TextStyle(fontSize: _menuItemFontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement Oktoberfestlandesschießen functionality
              },
            ),
            const Divider(),
            ListTile(
              leading:
                  const Icon(Icons.info_outline, color: UIStyles.menuIconColor),
              title: const ScaledText(
                'Impressum',
                style: TextStyle(fontSize: _menuItemFontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImpressumScreen(
                      userData: userData,
                      isLoggedIn: isLoggedIn,
                      onLogout: onLogout,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.style, color: UIStyles.menuIconColor),
              title: const ScaledText(
                'Styles',
                style: TextStyle(fontSize: _menuItemFontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StylesScreen(
                      userData: userData,
                      isLoggedIn: isLoggedIn,
                      onLogout: onLogout,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.settings, color: UIStyles.menuIconColor),
              title: const ScaledText(
                'Einstellungen',
                style: TextStyle(fontSize: _menuItemFontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                      userData: userData,
                      isLoggedIn: isLoggedIn,
                      onLogout: onLogout,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help, color: UIStyles.menuIconColor),
              title: const ScaledText(
                'Hilfe',
                style: TextStyle(fontSize: _menuItemFontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HelpScreen(
                      userData: userData,
                      isLoggedIn: isLoggedIn,
                      onLogout: onLogout,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: UIStyles.menuIconColor),
              title: const ScaledText(
                'Abmelden',
                style: TextStyle(fontSize: _menuItemFontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                onLogout();
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.login, color: UIStyles.menuIconColor),
              title: const ScaledText(
                'Anmelden',
                style: TextStyle(fontSize: _menuItemFontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.app_registration,
                color: UIStyles.menuIconColor,
              ),
              title: const ScaledText(
                'Registrieren',
                style: TextStyle(fontSize: _menuItemFontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                final authService =
                    Provider.of<AuthService>(context, listen: false);
                final emailService =
                    Provider.of<EmailService>(context, listen: false);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegistrationScreen(
                      authService: authService,
                      emailService: emailService,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.lock_reset, color: UIStyles.menuIconColor),
              title: const ScaledText(
                'Passwort zurücksetzen',
                style: TextStyle(fontSize: _menuItemFontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                final authService =
                    Provider.of<AuthService>(context, listen: false);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PasswordResetScreen(
                      authService: authService,
                      userData: userData,
                      isLoggedIn: isLoggedIn,
                      onLogout: onLogout,
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
