import 'package:flutter/material.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';

import '/screens/password_reset_screen.dart';
import '/screens/registration_screen.dart';
import '/screens/schuetzenausweis_screen.dart';
import '/screens/starting_rights_screen.dart';
import '/screens/help_screen_accessible.dart';
import '/screens/impressum_screen.dart';
import '/screens/settings_screen.dart';
import '/screens/schulungen/schulungen_search_screen.dart';
import '/screens/oktoberfest_screen.dart';

// Services
import '/services/api/auth_service.dart';
import '/services/core/email_service.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart';

class AppMenuAccessible extends StatelessWidget {
  const AppMenuAccessible({
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
    return Semantics(
      container: true,
      button: true,
      label: 'Hauptmenü öffnen',
      hint: 'Öffnet das Seitenmenü mit allen verfügbaren Funktionen der App',
      child: IconButton(
        icon: Semantics(
          excludeSemantics: true,
          child: const Icon(Icons.menu, color: UIStyles.menuIconColor),
        ),
        tooltip: 'Hauptmenü öffnen',
        onPressed: () {
          Scaffold.of(context).openEndDrawer();
        },
      ),
    );
  }
}

class AppDrawerAccessible extends StatelessWidget {
  const AppDrawerAccessible({
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });
  static const double _drawerHeaderHeight = UIConstants.drawerHeaderHeight;
  static const double _drawerHeaderTopPadding =
      UIConstants.drawerHeaderTopPadding;
  static const double _drawerHeaderBottomPadding =
      UIConstants.drawerHeaderBottomPadding;
  static const double _drawerHeaderLeftPadding =
      UIConstants.drawerHeaderLeftPadding;
  static const double _menuTitleFontSize = UIConstants.menuTitleFontSize;
  static const double _menuItemFontSize = UIConstants.menuItemFontSize;

  final UserData? userData;
  final bool isLoggedIn;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final int totalMenuItems = isLoggedIn ? 8 : 3; // Count of menu items

    return Semantics(
      container: true,
      label: isLoggedIn
          ? 'Hauptmenü für angemeldeten Benutzer ${userData?.vorname ?? 'Unbekannt'}'
          : 'Hauptmenü für nicht angemeldete Benutzer',
      hint: 'Navigationsmenü mit $totalMenuItems verfügbaren Optionen',
      child: Drawer(
        width: UIConstants.drawerWidth,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Enhanced drawer header with accessibility
            Semantics(
              container: true,
              header: true,
              label: 'App Header: Mein BSSB',
              hint: isLoggedIn
                  ? 'Angemeldet als ${userData?.vorname ?? 'Unbekannt'} ${userData?.namen ?? ''}'
                  : 'Nicht angemeldet - Registrierung oder Anmeldung erforderlich',
              child: Container(
                height: _drawerHeaderHeight,
                decoration:
                    const BoxDecoration(color: UIConstants.defaultAppColor),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: _drawerHeaderLeftPadding,
                    top: _drawerHeaderTopPadding,
                    bottom: _drawerHeaderBottomPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        excludeSemantics: true,
                        child: const ScaledText(
                          'Mein BSSB',
                          style: TextStyle(
                            color: UIConstants.whiteColor,
                            fontSize: _menuTitleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isLoggedIn && userData != null) ...[
                        const SizedBox(height: 8),
                        Semantics(
                          label:
                              'Angemeldeter Benutzer: ${userData!.vorname} ${userData!.namen}',
                          child: ScaledText(
                            '${userData!.vorname} ${userData!.namen}',
                            style: const TextStyle(
                              color: UIConstants.whiteColor,
                              fontSize: _menuItemFontSize,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Menu items with enhanced accessibility
            if (isLoggedIn) ...[
              _buildAccessibleMenuItem(
                context: context,
                icon: Icons.home,
                title: 'Home',
                hint: 'Zur Startseite der App navigieren',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/home');
                },
                itemNumber: 1,
                totalItems: totalMenuItems,
              ),
              _buildAccessibleMenuItem(
                context: context,
                icon: Icons.person,
                title: 'Profil',
                hint: 'Persönliche Daten und Profileinstellungen anzeigen',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');
                },
                itemNumber: 2,
                totalItems: totalMenuItems,
              ),
              _buildAccessibleMenuItem(
                context: context,
                icon: Icons.school_outlined,
                title: 'Aus- und Weiterbildung',
                hint: 'Schulungen und Kurse suchen und buchen',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SchulungenSearchScreen(
                        userData: userData,
                        isLoggedIn: isLoggedIn,
                        onLogout: onLogout,
                      ),
                    ),
                  );
                },
                itemNumber: 3,
                totalItems: totalMenuItems,
              ),
              _buildAccessibleMenuItem(
                context: context,
                icon: Icons.badge,
                title: 'Schützenausweis',
                hint: 'Digitalen Schützenausweis anzeigen und verwalten',
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
                itemNumber: 4,
                totalItems: totalMenuItems,
              ),
              _buildAccessibleMenuItem(
                context: context,
                icon: Icons.rule,
                title: 'Startrechte',
                hint: 'Aktuelle Startrechte und Berechtigungen einsehen',
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
                itemNumber: 5,
                totalItems: totalMenuItems,
              ),
              _buildAccessibleMenuItem(
                context: context,
                icon: Icons.sports_bar_outlined,
                title: 'Oktoberfest',
                hint:
                    'Informationen und Anmeldung für Oktoberfest-Veranstaltungen',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OktoberfestScreen(
                        userData: userData,
                        isLoggedIn: isLoggedIn,
                        onLogout: onLogout,
                      ),
                    ),
                  );
                },
                itemNumber: 6,
                totalItems: totalMenuItems,
              ),
              // Accessible divider
              Semantics(
                container: true,
                label: 'Menübereich Trennung',
                hint: 'Trennt Hauptfunktionen von Einstellungen und Hilfe',
                child: const Divider(),
              ),
              _buildAccessibleMenuItem(
                context: context,
                icon: Icons.info_outline,
                title: 'Impressum',
                hint: 'Rechtliche Informationen und Kontaktdaten anzeigen',
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
                itemNumber: 7,
                totalItems: totalMenuItems,
              ),
              _buildAccessibleMenuItem(
                context: context,
                icon: Icons.settings,
                title: 'Einstellungen',
                hint: 'App-Einstellungen und Konfigurationsoptionen',
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
                itemNumber: 8,
                totalItems: totalMenuItems,
              ),
              _buildAccessibleMenuItem(
                context: context,
                icon: Icons.help,
                title: 'Hilfe',
                hint: 'Hilfe und Unterstützung bei der App-Nutzung',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HelpScreenAccessible(
                        userData: userData,
                        isLoggedIn: isLoggedIn,
                        onLogout: onLogout,
                      ),
                    ),
                  );
                },
                itemNumber: 9,
                totalItems: 9, // Help is an extra item
              ),
              _buildAccessibleMenuItem(
                context: context,
                icon: Icons.logout,
                title: 'Abmelden',
                hint: 'Aus der App abmelden und zur Anmeldeseite zurückkehren',
                onTap: () {
                  Navigator.pop(context);
                  onLogout();
                },
                itemNumber: 10,
                totalItems: 10, // Logout is an extra item
                isDestructive: true,
              ),
            ] else ...[
              // Not logged in menu items
              _buildAccessibleMenuItem(
                context: context,
                icon: Icons.login,
                title: 'Anmelden',
                hint: 'Mit bestehenden Zugangsdaten in die App anmelden',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
                itemNumber: 1,
                totalItems: totalMenuItems,
              ),
              _buildAccessibleMenuItem(
                context: context,
                icon: Icons.app_registration,
                title: 'Registrieren',
                hint: 'Neues Benutzerkonto für die App erstellen',
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
                itemNumber: 2,
                totalItems: totalMenuItems,
              ),
              _buildAccessibleMenuItem(
                context: context,
                icon: Icons.lock_reset,
                title: 'Passwort zurücksetzen',
                hint: 'Vergessenes Passwort zurücksetzen und neues erstellen',
                onTap: () {
                  Navigator.pop(context);
                  final apiService =
                      Provider.of<ApiService>(context, listen: false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PasswordResetScreen(
                        apiService: apiService,
                        userData: userData,
                        isLoggedIn: isLoggedIn,
                        onLogout: onLogout,
                      ),
                    ),
                  );
                },
                itemNumber: 3,
                totalItems: totalMenuItems,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccessibleMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String hint,
    required VoidCallback onTap,
    required int itemNumber,
    required int totalItems,
    bool isDestructive = false,
  }) {
    return Semantics(
      container: true,
      button: true,
      label: 'Menüpunkt $itemNumber von $totalItems: $title',
      hint: hint,
      child: ListTile(
        leading: Semantics(
          image: true,
          label: '$title Symbol',
          child: Icon(
            icon,
            color:
                isDestructive ? UIConstants.errorColor : UIStyles.menuIconColor,
          ),
        ),
        title: Semantics(
          excludeSemantics: true,
          child: ScaledText(
            title,
            style: TextStyle(
              fontSize: _menuItemFontSize,
              color: isDestructive
                  ? UIConstants.errorColor
                  : UIConstants.textColor,
            ),
          ),
        ),
        onTap: onTap,
        // Add visual feedback for better accessibility
        hoverColor: UIConstants.defaultAppColor.withOpacity(0.1),
        focusColor: UIConstants.defaultAppColor.withOpacity(0.2),
        splashColor: UIConstants.defaultAppColor.withOpacity(0.3),
      ),
    );
  }
}
