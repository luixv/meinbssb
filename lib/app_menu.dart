import 'package:flutter/material.dart';

class AppMenu extends StatelessWidget {
  final BuildContext context;
  final Map<String, dynamic> userData; // Add userData parameter

  const AppMenu({required this.context, required this.userData, super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'logout') {
          // Navigate to the login screen
          Navigator.pushReplacementNamed(context, '/login');
        } else if (value == 'startseite') {
          // Navigate to the home screen with userData
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: userData, // Pass userData as arguments
          );
        }
        // Add more actions for other menu points here if needed
      },
      itemBuilder: (BuildContext context) => [
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
      ],
      icon: const Icon(Icons.menu),
    );
  }
}