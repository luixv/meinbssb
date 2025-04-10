import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:meinbssb/screens/impressum_screen.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/start_screen.dart';
import 'screens/help_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/email_service.dart';
import 'package:meinbssb/services/image_service.dart';
import 'package:meinbssb/services/http_client.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:meinbssb/services/config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigService.load('assets/config.json'); // Ensure the path is correct

  final serverTimeout = ConfigService.getInt('serverTimeout', '') ?? 10; 
  final baseIP = ConfigService.getString('apiBaseIP', '') ?? '127.0.0.1';
final port = ConfigService.getString('apiPort', '') ?? '3001';

  final imageService = ImageService();
  final cacheService = CacheService();
  final httpClient = HttpClient(
    baseUrl: 'http://$baseIP:$port',
    serverTimeout: serverTimeout,
  );

  final apiService = ApiService(
    httpClient: httpClient,
    imageService: imageService,
    cacheService: cacheService,
    baseIp: baseIP,
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
          final arguments =
              ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

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
        '/help': (context) => HelpScreen(
              userData: _userData,
              isLoggedIn: _isLoggedIn,
              onLogout: () => _setLoggedIn(false, {}),
            ),
        '/impressum': (context) => ImpressumScreen(
              userData: _userData,
              isLoggedIn: _isLoggedIn,
              onLogout: () => _setLoggedIn(false, {}),
            ),
      },
    );
  }
}