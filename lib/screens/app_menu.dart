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
        padding: EdgeInsets.zero, // Important: Removes default ListView padding
        children: <Widget>[
          // Custom header to replace DrawerHeader for more control over space
          Container(
            height: 120.0, // Adjust this height to reduce or increase space
            decoration: const BoxDecoration(color: UIConstants.defaultAppColor),
            child: const Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                top: 40.0,
                bottom: 8.0,
              ), // Adjust padding within the header
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mein BSSB',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold, // Added bold for prominence
                    ),
                  ),
                  // Removed the commented-out SizedBox and Text for "Angemeldet"
                ],
              ),
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
              leading: const Icon(Icons.task_alt),
              title: const Text('Absolvierte Seminare'),
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
              title: const Text('Schützenausweis'),
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
              leading: const Icon(Icons.edit), // Icons.edit_calendar
              title: const Text('Startrechte Ändern'),
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
                      webloginId: userData?.webLoginId ?? 0,
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
                final authService = Provider.of<AuthService>(
                  context,
                  listen: false,
                );
                final emailService = Provider.of<EmailService>(
                  context,
                  listen: false,
                );
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
                final authService = Provider.of<AuthService>(
                  context,
                  listen: false,
                );
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
            leading: const Icon(Icons.settings),
            title: const Text('Einstellungen'),
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
            leading: const Icon(Icons.palette),
            title: const Text('Styles'),
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
