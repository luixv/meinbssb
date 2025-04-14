import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login_screen.dart';
import 'screens/start_screen.dart';
import 'screens/help_screen.dart';
import 'screens/impressum_screen.dart';
import 'utils/cookie_consent.dart';

import 'services/api_service.dart';
import 'services/email_service.dart';
import 'services/image_service.dart';
import 'services/http_client.dart';
import 'services/cache_service.dart';
import 'services/config_service.dart';
import 'services/logger_service.dart';
import 'services/network_service.dart';

void main() async {
  LoggerService.init();

  WidgetsFlutterBinding.ensureInitialized();
  final configServiceInstance = await ConfigService.load('assets/config.json');

  final serverTimeout =
      configServiceInstance.getInt('serverTimeout', 'theme') ?? 10;
  final baseIP =
      configServiceInstance.getString('apiBaseIP', 'api') ?? '127.0.0.1';
  final port = configServiceInstance.getString('apiPort', 'api') ?? '3001';

  final imageService = ImageService();
  final prefs = await SharedPreferences.getInstance();
  final cacheService = CacheService(
    prefs: prefs,
    configService: ConfigService.instance,
  );
  final networkService = NetworkService(configService: ConfigService.instance);

  final httpClient = HttpClient(
    baseUrl: 'http://$baseIP:$port',
    serverTimeout: serverTimeout,
  );

  final apiService = ApiService(
    httpClient: httpClient,
    imageService: imageService,
    cacheService: cacheService,
    networkService: networkService,
    baseIp: baseIP,
    port: port,
    serverTimeout: serverTimeout,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (context) => apiService),
        Provider<EmailSender>(create: (context) => MailerEmailSender()),
        Provider<ConfigService>(create: (context) => ConfigService.instance),
        Provider<NetworkService>(create: (context) => networkService),
        Provider<CacheService>(create: (context) => cacheService),
        Provider<EmailService>(
          create:
              (context) => EmailService(
                emailSender: context.read<EmailSender>(),
                configService: context.read<ConfigService>(),
              ),
        ),
      ],
      child: const MyApp(),
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mein BSSB',
      theme: ThemeData(primarySwatch: Colors.blue),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('de', 'DE'), Locale('en', 'US')],
      initialRoute: _isLoggedIn ? '/home' : '/login',
      builder: (context, child) {
        return CookieConsent(child: child ?? const SizedBox.shrink());
      },
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
              userData: _userData,
              isLoggedIn: _isLoggedIn,
              onLogout: () => _setLoggedIn(false, {}),
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
