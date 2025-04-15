// Project: Mein BSSB
// Filename: schuetzenausweis_screen.dart
// Author: Luis Mandel / NTT DATA

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/screens/app_menu.dart';
import '/services/api_service.dart';

class SchuetzenausweisScreen extends StatelessWidget {
  const SchuetzenausweisScreen({
    super.key,
    required this.personId,
    required this.userData,
  });
  final int personId;
  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Digitaler Schützenausweis', style: UIConstants.titleStyle),
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
            return Center(
              child: CircularProgressIndicator(
                color: UIConstants.defaultAppColor,
                strokeWidth: 2.0,
              ),
            );
          }
          if (snapshot.hasError) {
            String errorMessage = snapshot.error.toString();
            if (errorMessage.startsWith('Exception: ')) {
              errorMessage = errorMessage.substring('Exception: '.length);
            }
            return Center(
              child: Text(
                'Error: $errorMessage',
                style: UIConstants.errorStyle,
              ),
            );
          }
          if (snapshot.hasData) {
            return Center(child: Image.memory(snapshot.data!));
          }
          return Center(
            child: Text(
              'No image data available',
              style: UIConstants.bodyStyle,
            ),
          );
        },
      ),
    );
  }
}
