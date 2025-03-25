import 'package:flutter/material.dart';
import 'schuetzenausweis_screen.dart';

class AppMenu extends StatelessWidget {
  final BuildContext context;
  final Map<String, dynamic> userData;
  final bool showSingleMenuItem; // Add this flag

  const AppMenu({
    required this.context,
    required this.userData,
    this.showSingleMenuItem = false, // Default to false
    super.key,
  });

  Future<void> _displaySchuetzenausweis(int personId) async {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SchuetzenausweisScreen(
        personId: personId,
        userData: userData, // Pass userData here
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'logout' || value == 'back_to_login') {
          Navigator.pushReplacementNamed(context, '/login');
        } else if (value == 'startseite') {
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: userData,
          );
        } 
         else if (value == 'digitaler_schuetzenausweis') {
          _displaySchuetzenausweis(userData['PERSONID']); // Call the download function
        }
        // Add more actions for other menu points here if needed
      },
      itemBuilder: (BuildContext context) {
        if (showSingleMenuItem) {
          // Display only "Back to Login"
          return [
            const PopupMenuItem<String>(
              value: 'back_to_login',
              child: Text('Zurück zum Login'),
            ),
          ];
        } else {
          // Display the full menu
          return [
            const PopupMenuItem<String>(
              value: 'startseite',
              child: Text('Startseite'),
            ),
            const PopupMenuItem<String>(
              value: 'digitaler_schuetzenausweis',
              child: Text('Digitaler Schützenausweis'),
            ),
            const PopupMenuItem<String>(
              value: 'aenderung_schuetzenausweis',
              child: Text('Änderung Schützenausweis'),
            ),
            const PopupMenuItem<String>(
              value: 'physischer_schuetzenausweis',
              child: Text('Physischer Schützenausweis'),
            ),
            const PopupMenuItem<String>(
              value: 'meine_stammdaten',
              child: Text('Meine Stammdaten'),
            ),
            const PopupMenuItem<String>(
              value: 'meine_kontaktdaten',
              child: Text('Meine Kontaktdaten'),
            ),
            const PopupMenuItem<String>(
              value: 'meine_seminare_buchen',
              child: Text('Meine Seminare buchen'),
            ),
            const PopupMenuItem<String>(
              value: 'meine_seminare_absolviert',
              child: Text('Meine Seminare absolviert'),
            ),
            const PopupMenuItem<String>(
              value: 'oktoberfestlandesschiessen',
              child: Text('Oktoberfestlandesschiessen'),
            ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Text('Abmelden'),
            ),
          ];
        }
      },
      icon: const Icon(Icons.menu),
    );
  }
}