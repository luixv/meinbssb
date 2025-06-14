// Project: Mein BSSB
// Filename: app_menu.dart
// Author: Luis Mandel / NTT DATA

// Flutter/Dart core imports
import 'package:flutter/material.dart';

// Third-party package imports
import 'package:provider/provider.dart';

// Local imports
// Constants
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';

// Screens
import '/screens/absolvierte_seminare_screen.dart';
import '/screens/bank_data_screen.dart';
import '/screens/contact_data_screen.dart';
import '/screens/help_screen.dart';
import '/screens/impressum_screen.dart';
import '/screens/password_reset_screen.dart';
import '/screens/personal_data_screen.dart';
import '/screens/registration_screen.dart';
import '/screens/schuetzenausweis_screen.dart';
import '/screens/starting_rights_screen.dart';
import '/screens/styles_screen.dart';
import '/screens/settings_screen.dart';

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
  final Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
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

  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 120.0,
            decoration: const BoxDecoration(color: UIConstants.defaultAppColor),
            child: const Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                top: 40.0,
                bottom: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScaledText(
                    'Mein BSSB',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoggedIn) ...[
            ListTile(
              leading: const Icon(Icons.home),
              title: const ScaledText('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const ScaledText('Seminare buchen'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement Seminare buchen functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.task_alt),
              title: const ScaledText('Absolvierte Seminare'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AbsolvierteSeminareScreen(
                      userData,
                      isLoggedIn: isLoggedIn,
                      onLogout: onLogout,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.badge),
              title: const ScaledText('Schützenausweis'),
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
              leading: const Icon(Icons.edit),
              title: const ScaledText('Startrechte Ändern'),
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
              leading: const Icon(Icons.celebration),
              title: const ScaledText('Oktoberfestlandensshiessen'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement Oktoberfestlandensshiessen functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const ScaledText('Profilbild'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement Profilbild functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const ScaledText('Persönliche Daten'),
              onTap: () {
                Navigator.pop(context);
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
            ListTile(
              leading: const Icon(Icons.contact_phone),
              title: const ScaledText('Kontaktdaten'),
              onTap: () {
                Navigator.pop(context);
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
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const ScaledText('Bankdaten'),
              onTap: () {
                Navigator.pop(context);
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
            ListTile(
              leading: const Icon(Icons.settings),
              title: const ScaledText('Einstellungen'),
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
              leading: const Icon(Icons.logout),
              title: const ScaledText('Abmelden'),
              onTap: () {
                Navigator.pop(context);
                onLogout();
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.login),
              title: const ScaledText('Anmelden'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
            ListTile(
              leading: const Icon(Icons.app_registration),
              title: const ScaledText('Registrieren'),
              onTap: () {
                Navigator.pop(context);
                final authService = Provider.of<AuthService>(context, listen: false);
                final emailService = Provider.of<EmailService>(context, listen: false);
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
              leading: const Icon(Icons.lock_reset),
              title: const ScaledText('Passwort zurücksetzen'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PasswordResetScreen(
                      userData: userData,
                      isLoggedIn: isLoggedIn,
                      onLogout: onLogout,
                    ),
                  ),
                );
              },
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const ScaledText('Hilfe'),
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
            leading: const Icon(Icons.info_outline),
            title: const ScaledText('Impressum'),
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
        ],
      ),
    );
  }
}
