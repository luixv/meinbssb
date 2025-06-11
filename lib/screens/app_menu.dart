// Project: Mein BSSB
// Filename: app_menu.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/screens/schuetzenausweis_screen.dart';
import '/screens/contact_data_screen.dart';
import '/screens/bank_data_screen.dart';
import '/screens/impressum_screen.dart';
import '/screens/personal_data_screen.dart';
import 'absolvierte_seminare_screen.dart';
import '/screens/help_screen.dart';
import '/screens/registration_screen.dart';
import '/screens/password_reset_screen.dart';
import 'package:provider/provider.dart';
import '/services/api/auth_service.dart';
import '/services/core/email_service.dart';

class AppMenu extends StatelessWidget {
  const AppMenu({
    super.key,
    required this.context,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });

  final BuildContext context;
  final Map<String, dynamic> userData;
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

  final Map<String, dynamic> userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: UIConstants.defaultAppColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mein BSSB',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isLoggedIn ? 'Angemeldet' : 'Nicht angemeldet',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          if (isLoggedIn) ...[
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Seminare buchen'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement Seminare buchen functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Absolvierte Seminare'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AbsolvierteSeminareScreen(
                      userData,
                      personId: userData['PERSONID'],
                      isLoggedIn: isLoggedIn,
                      onLogout: onLogout,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.badge),
              title: const Text('Schützenausweis'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SchuetzenausweisScreen(
                      personId: userData['PERSONID'],
                      userData: userData,
                      isLoggedIn: isLoggedIn,
                      onLogout: onLogout,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit), // Icons.edit_calendar
              title: const Text('Startrechte Ändern'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement Startrechte Ändern functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.celebration),
              title: const Text('Oktoberfestlandensshiessen'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement Oktoberfestlandensshiessen functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Profilbild'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement Profilbild functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Persönliche Daten'),
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
              title: const Text('Kontaktdaten'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactDataScreen(
                      userData,
                      personId: userData['PERSONID'],
                      isLoggedIn: isLoggedIn,
                      onLogout: onLogout,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Bankdaten'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BankDataScreen(
                      userData,
                      webloginId: userData['WEBLOGINID'],
                      isLoggedIn: isLoggedIn,
                      onLogout: onLogout,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Abmelden'),
              onTap: () {
                Navigator.pop(context);
                onLogout();
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Anmelden'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
            ListTile(
              leading: const Icon(Icons.app_registration),
              title: const Text('Registrieren'),
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
              leading: const Icon(Icons.lock_reset),
              title: const Text('Passwort zurücksetzen'),
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Impressum'),
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
            leading: const Icon(Icons.help_outline),
            title: const Text('Hilfe'),
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
        ],
      ),
    );
  }
}
