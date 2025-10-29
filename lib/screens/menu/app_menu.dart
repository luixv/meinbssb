import 'package:meinbssb/screens/menu/ausweis_menu.dart';
import 'package:flutter/material.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';

import '/screens/password/password_reset_screen.dart';
import '/screens/registration_screen.dart';
import '/screens/ausweis/ausweis_screen.dart';
import '/screens/help_screen.dart';
import '/screens/impressum_screen.dart';
import '/screens/settings_screen.dart';
import '/screens/schulungen/schulungen_search_screen.dart';
import 'oktoberfest_menu.dart';

import '/models/user_data.dart';
import '/widgets/scaled_text.dart';

// ADD: Abstraction for navigation so tests can inject a fake and avoid heavy screen builds.
abstract class DrawerNavigator {
  void home(BuildContext context);
  void profile(BuildContext context);
  void training(BuildContext context);
  void schuetzenausweis(BuildContext context);
  void oktoberfest(BuildContext context);
  void impressum(BuildContext context);
  void settings(BuildContext context);
  void help(BuildContext context);
  void logout(BuildContext context, VoidCallback onLogout);
}

// Replace RealDrawerNavigator with builder‑injectable version to allow light-weight testing.
class RealDrawerNavigator implements DrawerNavigator {
  const RealDrawerNavigator({
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
    WidgetBuilder? schulungenBuilder,
    WidgetBuilder? schuetzenausweisBuilder,
    WidgetBuilder? startingRightsBuilder,
    WidgetBuilder? oktoberfestBuilder,
    WidgetBuilder? impressumBuilder,
    WidgetBuilder? settingsBuilder,
    WidgetBuilder? helpBuilder,
  }) : _schulungenBuilder = schulungenBuilder,
       _schuetzenausweisBuilder = schuetzenausweisBuilder,
       _oktoberfestBuilder = oktoberfestBuilder,
       _impressumBuilder = impressumBuilder,
       _settingsBuilder = settingsBuilder,
       _helpBuilder = helpBuilder;

  final UserData? userData;
  final bool isLoggedIn;
  final VoidCallback onLogout;

  final WidgetBuilder? _schulungenBuilder;
  final WidgetBuilder? _schuetzenausweisBuilder;
  final WidgetBuilder? _oktoberfestBuilder;
  final WidgetBuilder? _impressumBuilder;
  final WidgetBuilder? _settingsBuilder;
  final WidgetBuilder? _helpBuilder;

  void _close(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  void home(BuildContext context) {
    _close(context);
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void profile(BuildContext context) {
    _close(context);
    Navigator.of(context).pushNamed('/profile');
  }

  @override
  void training(BuildContext context) {
    _close(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            _schulungenBuilder ??
            (_) => SchulungenSearchScreen(
              isLoggedIn: isLoggedIn,
              userData: userData,
              onLogout: onLogout,
            ),
      ),
    );
  }

  @override
  void schuetzenausweis(BuildContext context) {
    _close(context);
    if (userData == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            _schuetzenausweisBuilder ??
            (_) => SchuetzenausweisScreen(
              userData: userData!,
              personId: userData!.personId,
              isLoggedIn: isLoggedIn,
              onLogout: onLogout,
            ),
      ),
    );
  }

  // Removed startingRights method

  @override
  void oktoberfest(BuildContext context) {
    _close(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            _oktoberfestBuilder ??
            (_) => OktoberfestScreen(
              userData: userData,
              isLoggedIn: isLoggedIn,
              onLogout: onLogout,
            ),
      ),
    );
  }

  @override
  void impressum(BuildContext context) {
    _close(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            _impressumBuilder ??
            (_) => ImpressumScreen(
              userData: userData,
              isLoggedIn: isLoggedIn,
              onLogout: onLogout,
            ),
      ),
    );
  }

  @override
  void settings(BuildContext context) {
    _close(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            _settingsBuilder ??
            (_) => SettingsScreen(
              userData: userData,
              isLoggedIn: isLoggedIn,
              onLogout: onLogout,
            ),
      ),
    );
  }

  @override
  void help(BuildContext context) {
    _close(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            _helpBuilder ??
            (_) => HelpScreen(
              userData: userData,
              isLoggedIn: isLoggedIn,
              onLogout: onLogout,
            ),
      ),
    );
  }

  @override
  void logout(BuildContext context, VoidCallback onLogoutCallback) {
    _close(context);
    onLogoutCallback();
  }
}

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
  // Removed 'const' to fix: Invalid constant value (initializer uses runtime values)
  AppDrawer({
    super.key,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
    DrawerNavigator? navigator,
  }) : navigator =
           navigator ??
           RealDrawerNavigator(
             userData: userData,
             isLoggedIn: isLoggedIn,
             onLogout: onLogout,
           );

  final UserData? userData;
  final bool isLoggedIn;
  final VoidCallback onLogout;
  final DrawerNavigator navigator;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: UIConstants.drawerHeaderHeight,
            decoration: const BoxDecoration(color: UIConstants.defaultAppColor),
            child: const Padding(
              padding: EdgeInsets.only(
                left: UIConstants.drawerHeaderLeftPadding,
                top: UIConstants.drawerHeaderTopPadding,
                bottom: UIConstants.drawerHeaderBottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScaledText(
                    'Mein BSSB',
                    style: TextStyle(
                      color: UIConstants.whiteColor,
                      fontSize: UIConstants.menuTitleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoggedIn) ...[
            ListTile(
              key: const Key('drawer_home'),
              leading: const Icon(Icons.home, color: UIStyles.menuIconColor),
              title: const ScaledText(
                'Home',
                style: TextStyle(fontSize: UIConstants.menuItemFontSize),
              ),
              onTap: () => navigator.home(context),
            ),
            ListTile(
              key: const Key('drawer_profile'),
              leading: const Icon(Icons.person, color: UIStyles.menuIconColor),
              title: const ScaledText(
                'Profil',
                style: TextStyle(fontSize: UIConstants.menuItemFontSize),
              ),
              onTap: () => navigator.profile(context),
            ),
            ListTile(
              key: const Key('drawer_training'),
              leading: const Icon(
                Icons.school_outlined,
                color: UIStyles.menuIconColor,
              ),
              title: const ScaledText(
                'Aus- und Weiterbildung',
                style: TextStyle(fontSize: UIConstants.menuItemFontSize),
              ),
              onTap: () => navigator.training(context),
            ),
            ListTile(
              key: const Key('drawer_schuetzenausweis'),
              leading: const Icon(Icons.badge, color: UIStyles.menuIconColor),
              title: const ScaledText(
                'Schützenausweis',
                style: TextStyle(fontSize: UIConstants.menuItemFontSize),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => ProfileScreen(
                          userData: userData,
                          isLoggedIn: isLoggedIn,
                          onLogout: onLogout,
                        ),
                  ),
                );
              },
            ),
            // Removed Startrechte ListTile
            ListTile(
              key: const Key('drawer_oktoberfest'),
              leading: const Icon(
                Icons.sports_bar_outlined,
                color: UIStyles.menuIconColor,
              ),
              title: const ScaledText(
                'Oktoberfest',
                style: TextStyle(fontSize: UIConstants.menuItemFontSize),
              ),
              onTap: () => navigator.oktoberfest(context),
            ),
            const Divider(),
            ListTile(
              key: const Key('drawer_impressum'),
              leading: const Icon(
                Icons.info_outline,
                color: UIStyles.menuIconColor,
              ),
              title: const ScaledText(
                'Impressum',
                style: TextStyle(fontSize: UIConstants.menuItemFontSize),
              ),
              onTap: () => navigator.impressum(context),
            ),
            ListTile(
              key: const Key('drawer_settings'),
              leading: const Icon(
                Icons.settings,
                color: UIStyles.menuIconColor,
              ),
              title: const ScaledText(
                'Einstellungen',
                style: TextStyle(fontSize: UIConstants.menuItemFontSize),
              ),
              onTap: () => navigator.settings(context),
            ),
            ListTile(
              key: const Key('drawer_help'),
              leading: const Icon(Icons.help, color: UIStyles.menuIconColor),
              title: const ScaledText(
                'Hilfe (FAQ)',
                style: TextStyle(fontSize: UIConstants.menuItemFontSize),
              ),
              onTap: () => navigator.help(context),
            ),
            ListTile(
              key: const Key('drawer_logout'),
              leading: const Icon(Icons.logout, color: UIStyles.menuIconColor),
              title: const ScaledText(
                'Abmelden',
                style: TextStyle(fontSize: UIConstants.menuItemFontSize),
              ),
              onTap: () => navigator.logout(context, onLogout),
            ),
          ] else ...[
            ListTile(
              key: const Key('drawer_login'),
              leading: const Icon(Icons.login, color: UIStyles.menuIconColor),
              title: const ScaledText(
                'Anmelden',
                style: TextStyle(fontSize: UIConstants.menuItemFontSize),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/login');
              },
            ),
            ListTile(
              key: const Key('drawer_register'),
              leading: const Icon(
                Icons.app_registration,
                color: UIStyles.menuIconColor,
              ),
              title: const ScaledText(
                'Registrieren',
                style: TextStyle(fontSize: UIConstants.menuItemFontSize),
              ),
              onTap: () {
                Navigator.of(context).pop();
                final apiService = Provider.of<ApiService>(
                  context,
                  listen: false,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => RegistrationScreen(apiService: apiService),
                  ),
                );
              },
            ),
            ListTile(
              key: const Key('drawer_pw_reset'),
              leading: const Icon(
                Icons.lock_reset,
                color: UIStyles.menuIconColor,
              ),
              title: const ScaledText(
                'Passwort zurücksetzen',
                style: TextStyle(fontSize: UIConstants.menuItemFontSize),
              ),
              onTap: () {
                Navigator.of(context).pop();
                final apiService = Provider.of<ApiService>(
                  context,
                  listen: false,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => PasswordResetScreen(
                          apiService: apiService,
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
