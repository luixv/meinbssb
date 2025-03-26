import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/screens/app_menu.dart';
import 'dart:typed_data'; // For Uint8List

class SchuetzenausweisScreen extends StatelessWidget {
  final int personId;
  final Map<String, dynamic> userData;

  const SchuetzenausweisScreen({
    super.key,
    required this.personId,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Digitaler Schützenausweis'),
        actions: [
          AppMenu(
            context: context,
            userData: userData,
            isLoggedIn: true,
            onLogout: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: FutureBuilder<Uint8List>(
        future: apiService.fetchSchuetzenausweis(personId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            return Center(
              child: Image.memory(snapshot.data!),
            );
          }
          return const Center(child: Text('No image data available'));
        },
      ),
    );
  }
}