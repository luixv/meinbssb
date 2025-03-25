// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/login_screen.dart';
import 'screens/start_screen.dart';
import 'services/localization_service.dart';
import 'package:meinbssb/services/api_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalizationService.load('assets/strings.json');

  runApp(MyApp());
}

class MyApp extends StatelessWidget { 
  final ApiService apiService = ApiService(); 

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