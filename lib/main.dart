// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'login_screen.dart';
import 'start_screen.dart';
import 'localization_service.dart';
import 'api_service.dart'; // Import ApiService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalizationService.load('assets/strings.json');

  runApp(MyApp()); // Removed const
}

class MyApp extends StatelessWidget { // Removed const
  final ApiService apiService = ApiService(); // Create ApiService instance here

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mein BSSB',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de', 'DE'),
        Locale('en', 'US'),
      ],
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(apiService: apiService), // Pass apiService
       '/home': (context) {
          final userData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return StartScreen(userData, apiService: apiService); // Pass apiService here
        },
      },
    );
  }
}