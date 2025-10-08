import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'app.dart';
import 'services/api/auth_service.dart';
import 'services/api/user_service.dart';
import 'services/api_service.dart';
import 'services/api/training_service.dart';
import 'services/api/bank_service.dart';
import 'services/api/verein_service.dart';
import 'services/api/bezirk_service.dart';
import 'services/api/starting_rights_service.dart';

import 'services/core/email_service.dart';
import 'services/core/image_service.dart';
import 'services/core/http_client.dart';
import 'services/core/cache_service.dart';
import 'services/core/config_service.dart';
import 'services/core/logger_service.dart';
import 'services/core/network_service.dart';
import 'services/core/token_service.dart';
import 'providers/font_size_provider.dart';
import 'services/core/calendar_service.dart';

import 'screens/schulungen/schulungen_search_screen.dart';

import 'services/api/oktoberfest_service.dart';
import 'services/core/postgrest_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/kill_switch_provider.dart';
import 'widgets/kill_switch_gate.dart';

void main() async {
  // Global error handler for all uncaught errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(
      'GLOBAL FLUTTER ERROR: \n \u001b[31m${details.exceptionAsString()}\u001b[0m',
    );
    if (details.stack != null) {
      debugPrint('STACK TRACE: \n${details.stack}');
    }
  };

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options:
            DefaultFirebaseOptions
                .currentPlatform, // Use this if you have firebase_options.dart
      );
      await AppInitializer.init();

      final fragment = Uri.base.fragment;
      final path = Uri.base.path;

      final bool isDirectSchulungenSearch =
          fragment == '/schulungen_search' ||
          fragment == 'schulungen_search' ||
          path == '/schulungen_search' ||
          path == 'schulungen_search';

      final providers = [
        AppInitializer.configServiceProvider,
        AppInitializer.emailSenderProvider,
        AppInitializer.emailServiceProvider,
        AppInitializer.authServiceProvider,
        AppInitializer.apiServiceProvider,
        AppInitializer.networkServiceProvider,
        AppInitializer.cacheServiceProvider,
        AppInitializer.trainingServiceProvider,
        AppInitializer.userServiceProvider,
        AppInitializer.tokenServiceProvider,
        AppInitializer.fontSizeProvider,
        AppInitializer.oktoberfestServiceProvider,
        ChangeNotifierProvider<KillSwitchProvider>(
          create: (_) => KillSwitchProvider(),
        ),
      ];

      Widget appWidget;
      if (isDirectSchulungenSearch) {
        appWidget = MyAppWrapper(
          initialScreen: SchulungenSearchScreen(
            userData: null,
            isLoggedIn: false,
            onLogout: () {},
            showMenu: false,
            showConnectivityIcon: false,
          ),
        );
      } else {
        appWidget = const MyAppWrapper();
      }

      runApp(
        MultiProvider(
          providers: providers,
          child: KillSwitchGate(child: appWidget),
        ),
      );
    },
    (error, stack) {
      debugPrint('GLOBAL ZONED ERROR: \n \u001b[31m$error\u001b[0m');
      debugPrint('STACK TRACE: \n$stack');
    },
  );
}

class AppInitializer {
  static late ConfigService configService;
  static late ApiService apiService;
  static late NetworkService networkService;
  static late CacheService cacheService;
  static late HttpClient httpClient;
  static late ImageService imageService;
  static late TrainingService trainingService;
  static late UserService userService;
  static late AuthService authService;
  static late BankService bankService;
  static late VereinService vereinService;
  static late OktoberfestService oktoberfestService;
  static late TokenService tokenService;
  static late PostgrestService postgrestService;
  static late EmailService emailService;
  static late CalendarService calendarService;
  static late BezirkService bezirkService;
  static late StartingRightsService startingRightsService;
  static late http.Client baseHttpClient;
  static bool _disposed = false;

  static Future<void> init() async {
    LoggerService.init();
    configService = await ConfigService.load('assets/config.json');

    final serverTimeout = configService.getInt('serverTimeout', 'theme') ?? 10;
    final apiBaseUrl = ConfigService.buildBaseUrlForServer(
      configService,
      name: 'apiBase',
    );

    final prefs = await SharedPreferences.getInstance();

    cacheService = CacheService(prefs: prefs, configService: configService);
    networkService = NetworkService(configService: configService);

    // Shared underlying HTTP client used across services
    baseHttpClient = http.Client();

    // Initialize PostgrestService
    postgrestService = PostgrestService(
      configService: configService,
      client: baseHttpClient,
    );

    // 1. Initialize TokenService FIRST
    tokenService = TokenService(
      configService: configService,
      cacheService: cacheService,
      client: baseHttpClient,
    );

    // 2. Then, initialize HttpClient for main API
    httpClient = HttpClient(
      baseUrl: apiBaseUrl,
      serverTimeout: serverTimeout,
      tokenService: tokenService,
      configService: configService,
      cacheService: cacheService,
      client: baseHttpClient,
    );

    imageService = ImageService(httpClient: httpClient);

    calendarService = CalendarService();

    // Initialize EmailService before AuthService since AuthService depends on it
    final emailSender = MailerEmailSender();

    oktoberfestService = OktoberfestService(httpClient: httpClient);

    emailService = EmailService(
      emailSender: emailSender,
      configService: configService,
      httpClient: httpClient,
      calendarService: calendarService,
    );

    trainingService = TrainingService(
      httpClient: httpClient,
      cacheService: cacheService,
      networkService: networkService,
      configService: configService,
    );

    userService = UserService(
      httpClient: httpClient,
      cacheService: cacheService,
      networkService: networkService,
      configService: configService,
    );

    authService = AuthService(
      httpClient: httpClient,
      cacheService: cacheService,
      networkService: networkService,
      configService: configService,
      postgrestService: postgrestService,
      emailService: emailService,
    );

    bezirkService = BezirkService(
      httpClient: httpClient,
      cacheService: cacheService,
      networkService: networkService,
    );

    bankService = BankService.withClient(httpClient: httpClient);

    vereinService = VereinService(httpClient: httpClient);

    startingRightsService = StartingRightsService(
      userService: userService,
      vereinService: vereinService,
      emailService: emailService,
    );

    apiService = ApiService(
      configService: configService,
      httpClient: httpClient,
      imageService: imageService,
      cacheService: cacheService,
      networkService: networkService,
      trainingService: trainingService,
      userService: userService,
      authService: authService,
      bankService: bankService,
      vereinService: vereinService,
      postgrestService: postgrestService,
      emailService: emailService,
      oktoberfestService: oktoberfestService,
      calendarService: calendarService,
      bezirkService: bezirkService,
      startingRightsService: startingRightsService,
    );

    _registerProviders();
  }

  static void _registerProviders() {
    configServiceProvider = Provider<ConfigService>(
      create: (context) => configService,
    );
    emailSenderProvider = Provider<EmailSender>(
      create: (context) => MailerEmailSender(),
    );
    emailServiceProvider = Provider<EmailService>(
      create: (context) => emailService,
    );
    authServiceProvider = Provider<AuthService>(
      create: (context) => authService,
    );
    apiServiceProvider = Provider<ApiService>(create: (context) => apiService);
    networkServiceProvider = Provider<NetworkService>(
      create: (context) => networkService,
    );
    cacheServiceProvider = Provider<CacheService>(
      create: (context) => cacheService,
    );
    trainingServiceProvider = Provider<TrainingService>(
      create: (context) => trainingService,
    );
    userServiceProvider = Provider<UserService>(
      create: (context) => userService,
    );

    // This is just in case the token_service is needed elsewhere.
    // In fact the only place where it is used is in the HttpClient
    tokenServiceProvider = Provider<TokenService>(
      create: (context) => tokenService,
    );

    fontSizeProvider = ChangeNotifierProvider<FontSizeProvider>(
      create: (context) => FontSizeProvider(),
    );

    calendarServiceProvider = Provider<CalendarService>(
      create: (context) => calendarService,
    );

    startingRightsServiceProvider = Provider<StartingRightsService>(
      create: (context) => startingRightsService,
    );

    oktoberfestServiceProvider = Provider<OktoberfestService>(
      create: (context) => oktoberfestService,
    );
  }

  static void dispose() {
    if (_disposed) return;
    _disposed = true;
    try {
      baseHttpClient.close();
    } catch (e) {
      debugPrint('Error closing baseHttpClient: $e');
    }
  }

  // Public static provider instances
  static late Provider<ApiService> apiServiceProvider;
  static late Provider<NetworkService> networkServiceProvider;
  static late Provider<CacheService> cacheServiceProvider;
  static late Provider<EmailService> emailServiceProvider;
  static late Provider<ConfigService> configServiceProvider;
  static late Provider<EmailSender> emailSenderProvider;
  static late Provider<AuthService> authServiceProvider;
  static late Provider<TrainingService> trainingServiceProvider;
  static late Provider<UserService> userServiceProvider;
  static late Provider<TokenService> tokenServiceProvider;
  static late ChangeNotifierProvider<FontSizeProvider> fontSizeProvider;
  static late Provider<CalendarService> calendarServiceProvider;
  static late Provider<StartingRightsService> startingRightsServiceProvider;
  static late Provider<OktoberfestService> oktoberfestServiceProvider;
}
