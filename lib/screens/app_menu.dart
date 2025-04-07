import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/screens/schuetzenausweis_screen.dart';
import 'package:meinbssb/screens/zweitmitgliedschaften_screen.dart';

class AppMenu extends StatelessWidget {
  final BuildContext context;
  final Map<String, dynamic> userData;
  final bool isLoggedIn;
  final Function() onLogout;

  const AppMenu({
    required this.context,
    required this.userData,
    this.isLoggedIn = true,
    required this.onLogout,
    super.key,
  });

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
        }
      },
      itemBuilder: (BuildContext context) {
        if (!isLoggedIn) {
          return [
            PopupMenuItem<String>(
              value: 'back_to_login',
              child: Text('Zurück zum Login', style: UIConstants.bodyStyle),
            ),
          ];
        } else {
          return [
            PopupMenuItem<String>(
              value: 'startseite',
              child: Text('Startseite', style: UIConstants.bodyStyle),
            ),

            PopupMenuItem<String>(
              value: 'digitaler_schuetzenausweis',
              child: Text(
                'Digitaler Schützenausweis',
                style: UIConstants.bodyStyle,
              ),
            ),
            PopupMenuItem<String>(
              value: 'zweitmitgliedschaften',
              child: Text(
                'Zweitmitgliedschaften',
                style: UIConstants.bodyStyle,
              ),
            ),
            PopupMenuItem<String>(
              value: 'aenderung_schuetzenausweis',
              child: Text(
                'Änderung Schützenausweis',
                style: UIConstants.bodyStyle,
              ),
            ),
            PopupMenuItem<String>(
              value: 'physischer_schuetzenausweis',
              child: Text(
                'Physischer Schützenausweis',
                style: UIConstants.bodyStyle,
              ),
            ),
            PopupMenuItem<String>(
              value: 'meine_stammdaten',
              child: Text('Meine Stammdaten', style: UIConstants.bodyStyle),
            ),
            PopupMenuItem<String>(
              value: 'meine_kontaktdaten',
              child: Text('Meine Kontaktdaten', style: UIConstants.bodyStyle),
            ),
            PopupMenuItem<String>(
              value: 'meine_seminare_buchen',
              child: Text(
                'Meine Seminare buchen',
                style: UIConstants.bodyStyle,
              ),
            ),
            PopupMenuItem<String>(
              value: 'meine_seminare_absolviert',
              child: Text(
                'Meine Seminare absolviert',
                style: UIConstants.bodyStyle,
              ),
            ),
            PopupMenuItem<String>(
              value: 'oktoberfestlandesschiessen',
              child: Text(
                'Oktoberfestlandesschiessen',
                style: UIConstants.bodyStyle,
              ),
            ),
            PopupMenuItem<String>(
              value: 'logout',
              child: Text('Abmelden', style: UIConstants.bodyStyle),
            ),
          ];
        }
      },
      icon: Icon(Icons.menu, color: UIConstants.defaultAppColor),
    );
  }
}
