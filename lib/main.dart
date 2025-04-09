// Project: Mein BSSB
// Filename: main.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:meinbssb/screens/impressum_screen.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/start_screen.dart';
import 'screens/help_screen.dart';
import 'services/localization_service.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/email_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:meinbssb/services/database_service.dart';
import 'package:meinbssb/services/http_client.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalizationService.load('assets/strings.json');
  final serverTimeout =
      int.tryParse(LocalizationService.getString('ServerTimeout')) ?? 10;
  final baseIp = LocalizationService.getString('BaseIp');
  final port = LocalizationService.getString('Port');

  // ✅ Set up platform-specific database factory
  if (kIsWeb) {
    // For the web, use sqflite_common_ffi_web
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    // For other platforms (e.g., Windows, macOS, Linux), use sqflite_common_ffi
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final databaseService = DatabaseService();
  await databaseService.database;
  final cacheService = CacheService();
  final httpClient = HttpClient(
    baseUrl: 'http://$baseIp:$port',
    serverTimeout: serverTimeout,
  );

  final apiService = ApiService(
    httpClient: httpClient,
    databaseService: databaseService,
    cacheService: cacheService,
    baseIp: baseIp,
    port: port,
    serverTimeout: serverTimeout,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (context) => apiService),
        Provider<EmailService>(create: (_) => EmailService()),
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
      theme: ThemeData(primarySwatch: Colors.blue),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('de', 'DE'), Locale('en', 'US')],
      initialRoute: _isLoggedIn ? '/home' : '/login',
      routes: {
        '/login':
            (context) => LoginScreen(
              onLoginSuccess: (userData) => _setLoggedIn(true, userData),
            ),
        '/home': (context) {
          final arguments =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;

          if (arguments == null) {
            return StartScreen(
              _userData,
              isLoggedIn: _isLoggedIn,
              onLogout: () => _setLoggedIn(false, {}),
            );
          } else {
            final userData = arguments['userData'] as Map<String, dynamic>;
            final isLoggedIn = arguments['isLoggedIn'] as bool;

            return StartScreen(
              userData,
              isLoggedIn: isLoggedIn,
              onLogout: () => _setLoggedIn(false, {}),
            );
          }
        },

        '/help':
            (context) => HelpScreen(
              userData: _userData, // Use your current user data
              isLoggedIn: _isLoggedIn, // Use your current login status
              onLogout:
                  () => _setLoggedIn(false, {}), // Use your logout function
            ),

        '/impressum':
            (context) => ImpressumScreen(
              userData: _userData,
              isLoggedIn: _isLoggedIn,
              onLogout: () => _setLoggedIn(false, {}),
            ),
      },
    );
  }
}
