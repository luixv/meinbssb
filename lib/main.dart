// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Import for localization
import 'login_screen.dart';
import 'start_screen.dart';
import 'localization_service.dart'; // Import the localization service

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalizationService.load('assets/strings.json'); // Your existing localization

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
      localizationsDelegates: const [ // Add localization delegates
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [ // Add supported locales
        Locale('de', 'DE'), // German
        Locale('en', 'US'), // Optional: English
      ],
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