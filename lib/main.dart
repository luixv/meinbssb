//main.dart
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'start_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mein BSSB',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login', // Set the initial route
      routes: {
        '/login': (context) => LoginScreen(), // Login screen route
        '/home': (context) {
          final userData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return StartScreen(userData); // Home screen route with arguments
        },
      },
    );
  }
}