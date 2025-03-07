//home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const HomeScreen(this.userData, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mein BSSB'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pop(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Abmelden'),
              ),
            ],
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${userData['VORNAME']} ${userData['NAMEN']}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(userData['PASSNUMMER'], style: const TextStyle(fontSize: 18)),
            const Text("Schützenpassnummer", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Text(userData['VEREINNAME'], style: const TextStyle(fontSize: 18)),
            const Text("Erstverein", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
