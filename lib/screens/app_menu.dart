// Project: Mein BSSB
// Filename: app_menu.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/screens/schuetzenausweis_screen.dart';
import '/screens/zweitmitgliedschaften_screen.dart';
import '/screens/impressum_screen.dart';

class AppMenu extends StatelessWidget {
  const AppMenu({
    required this.context,
    required this.userData,
    this.isLoggedIn = true,
    required this.onLogout,
    super.key,
  });
  final BuildContext context;
  final Map<String, dynamic> userData;
  final bool isLoggedIn;
  final Function() onLogout;

  Future<void> _displaySchuetzenausweis(int personId) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                SchuetzenausweisScreen(personId: personId, userData: userData),
      ),
    );
  }

  Future<void> _displayZweitmitgliedschaften(int personId) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ZweitmitgliedschaftenScreen(
              personId: personId,
              userData: userData,
            ),
      ),
    );
  }

  void _openImpressumScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ImpressumScreen(
              userData: userData,
              isLoggedIn: isLoggedIn,
              onLogout: onLogout,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'logout' || value == 'back_to_login') {
          onLogout();
        } else if (value == 'startseite') {
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: {'userData': userData, 'isLoggedIn': true},
          );
        } else if (value == 'digitaler_schuetzenausweis') {
          _displaySchuetzenausweis(userData['PERSONID']);
        } else if (value == 'zweitmitgliedschaften') {
          _displayZweitmitgliedschaften(userData['PERSONID']);
        } else if (value == 'impressum') {
          _openImpressumScreen();
        }
      },
      itemBuilder: (BuildContext context) {
        final List<PopupMenuEntry<String>> items = [];
        
        if (isLoggedIn) {
          items.addAll([
            const PopupMenuItem<String>(
              value: 'startseite',
              child: Text('Startseite'),
            ),
            const PopupMenuItem<String>(
              value: 'digitaler_schuetzenausweis',
              child: Text('Digitaler Schützenausweis'),
            ),
            const PopupMenuItem<String>(
              value: 'zweitmitgliedschaften',
              child: Text('Zweitmitgliedschaften'),
            ),
            const PopupMenuItem<String>(
              value: 'impressum',
              child: Text('Impressum'),
            ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Text('Logout'),
            ),
          ]);
        } else {
          items.add(const PopupMenuItem<String>(
            value: 'back_to_login',
            child: Text('Zurück zur Anmeldung'),
          ));
        }
        
        return items;
      },
    );
  }
}
