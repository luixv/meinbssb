import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/start_screen.dart';
import 'services/localization_service.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/email_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; 
import 'package:meinbssb/services/database_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalizationService.load('assets/strings.json');
  final serverTimeout = int.tryParse(LocalizationService.getString('ServerTimeout')) ?? 10;

 // Initialize sqflite_common_ffi if needed
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi; // Set the factory

  final databaseService = DatabaseService();
  await databaseService.database; // Await database initialization
  
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (context) => ApiService(serverTimeout: serverTimeout)),
        Provider<EmailService>(create: (_) => EmailService()), // Add this line

      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  Map<String, dynamic> _userData = {};

  void _setLoggedIn(bool isLoggedIn, Map<String, dynamic> userData) {
    setState(() {
      _isLoggedIn = isLoggedIn;
      _userData = userData;
    });
  }

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
      initialRoute: _isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => LoginScreen(
          onLoginSuccess: (userData) => _setLoggedIn(true, userData),
        ),
        '/home': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          final userData = arguments?['userData'] as Map<String, dynamic>? ?? _userData;
          final isLoggedIn = arguments?['isLoggedIn'] as bool? ?? _isLoggedIn;

          return StartScreen(
            userData,
            isLoggedIn: isLoggedIn,
            onLogout: () => _setLoggedIn(false, {}),
          );
        },
      },
    );
  }
}