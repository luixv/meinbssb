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
        builder: (context) =>
            SchuetzenausweisScreen(personId: personId, userData: userData),
      ),
    );
  }

  void _openImpressumScreen() {
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
  }

  void _openContactDataScreen(int personId) {
    // Function to open ContactDataScreen
    // call the api_service for the contact data
    // and pass the data to the ContactDataScreen
    //fetchKontakte(personId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactDataScreen(
          userData, // Pass the userData
          personId: personId,
          isLoggedIn: isLoggedIn,
          onLogout: onLogout,
        ),
      ),
    );
  }

  void _openBanktDataScreen(int webloginId) {
    // Function to open BankDataScreen
    // call the api_service for the bank data
    // and pass the data to the BankDataScreen
    //fetchBankdata(webloginId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BankDataScreen(
          userData, // Pass the userData
          webloginId: webloginId,
          isLoggedIn: isLoggedIn,
          onLogout: onLogout,
        ),
      ),
    );
  }

  void _openPersonalDataScreen() {
    // Function to open PersonDataScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonDataScreen(
          userData, // Pass the userData
          isLoggedIn: isLoggedIn,
          onLogout: onLogout,
        ),
      ),
    );
  }

  void _openAbsolvierteSeminareScreen(int personId) {
    // Function to open AbsolvierteSeminareScreen
    // call the api_service for the Absolvierte Seminare data
    // and pass the data to the AbsolvierteSeminareScreen
    //fetchAbsolvierteSeminare(personId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AbsolvierteSeminareScreen(
          userData, // Pass the userData
          personId: personId,
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
        } else if (value == 'home') {
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: {'userData': userData, 'isLoggedIn': true},
          );
        } else if (value == 'schuetzenausweis') {
          _displaySchuetzenausweis(userData['PERSONID']);
        } else if (value == 'impressum') {
          _openImpressumScreen();
        } else if (value == 'kontaktdaten') {
          // Call the function to open KontaktdatenScreen
          _openContactDataScreen(userData['PERSONID']);
        } else if (value == 'absolvierte_seminare') {
          // Call the function to open AbsolvierteSeminareScreen
          _openAbsolvierteSeminareScreen(userData['PERSONID']);
        } else if (value == 'zahlungsart') {
          // Call the function to open BankdatenScreen
          _openBanktDataScreen(userData['WEBLOGINID']);
        } else if (value == 'stammdaten') {
          // Call the function to open Persönliche Daten
          _openPersonalDataScreen();
        }
      },
      itemBuilder: (BuildContext context) {
        final List<PopupMenuEntry<String>> items = [];

        if (!isLoggedIn) {
          items.add(
            const PopupMenuItem<String>(
              value: 'impressum',
              child: Text('Impressum', style: UIConstants.bodyStyle),
            ),
          );
          items.add(
            const PopupMenuItem<String>(
              value: 'back_to_login',
              child: Text('Zurück zum Login', style: UIConstants.bodyStyle),
            ),
          );
        } else {
          items.addAll([
            const PopupMenuItem<String>(
              value: 'home',
              child: Text('Home', style: UIConstants.bodyStyle),
            ),
            const PopupMenuItem<String>(
              value: 'seminare_buchen',
              child: Text(
                'Seminare buchen',
                style: UIConstants.bodyStyle,
              ),
            ),
            const PopupMenuItem<String>(
              value: 'absolvierte_seminare',
              child: Text(
                'Absolvierte Seminare',
                style: UIConstants.bodyStyle,
              ),
            ),
            const PopupMenuItem<String>(
              value: 'schuetzenausweis',
              child: Text(
                'Schützenausweis',
                style: UIConstants.bodyStyle,
              ),
            ),
            const PopupMenuItem<String>(
              value: 'aenderung_schuetzenausweis',
              child: Text(
                'Startrechete Ändern',
                style: UIConstants.bodyStyle,
              ),
            ),
            const PopupMenuItem<String>(
              value: 'ausweis_neu_ausstellen',
              child: Text(
                'Ausweis neu ausstellen',
                style: UIConstants.bodyStyle,
              ),
            ),
            const PopupMenuItem<String>(
              value: 'oktoberfestlandesschiessen',
              child: Text(
                'Oktoberfestlandesschiessen',
                style: UIConstants.bodyStyle,
              ),
            ),
            const PopupMenuItem<String>(
              value: 'stammdaten',
              child: Text('Persönliche Daten', style: UIConstants.bodyStyle),
            ),
            const PopupMenuItem<String>(
              value: 'kontaktdaten',
              child: Text('Kontaktdaten', style: UIConstants.bodyStyle),
            ),
            const PopupMenuItem<String>(
              value: 'zahlungsart',
              child: Text(
                'Zahlungsart',
                style: UIConstants.bodyStyle,
              ),
            ),
            const PopupMenuItem<String>(
              value: 'profilbild',
              child: Text(
                'Profilbild',
                style: UIConstants.bodyStyle,
              ),
            ),
            const PopupMenuItem<String>(
              value: 'impressum',
              child: Text('Impressum', style: UIConstants.bodyStyle),
            ),
            const PopupMenuItem<String>(
              // Use const here
              value: 'logout',
              child: Text('Abmelden', style: UIConstants.bodyStyle),
            ),
          ]);
        }
        return items;
      },
      icon: const Icon(Icons.menu, color: UIConstants.defaultAppColor),
    );
  }
}
