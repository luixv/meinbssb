import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meinbssb/constants/ui_constants.dart';
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
import 'providers/compulsory_update_provider.dart';
import 'widgets/kill_switch_gate.dart';
import 'widgets/compulsory_update_gate.dart';
import 'dart:io';

import 'package:flutter/rendering.dart';

Future<void> main() async {
  bool isWindows = false;
  try {
    isWindows = Platform.isWindows;
  } catch (_) {}

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(
      'GLOBAL FLUTTER ERROR: \n \u001b[31m${details.exceptionAsString()}\u001b[0m',
    );
  };

  try {
    await AppInitializer.init(isWindows: isWindows);

    FirebaseRemoteConfig? remoteConfig;
    CompulsoryUpdateProvider? compulsoryUpdateProvider;
    if (!isWindows) {
      // Fetch Remote Config only once
      remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setDefaults(<String, dynamic>{
        'minimum_required_version': '',
        'update_message':
            'Es ist eine neue Version von MeinBSSB verfügbar. Bitte installieren Sie die neue Version. Ihr MeinBSSB Support.',
        'kill_switch_enabled': false,
        'kill_switch_message': '',
      });
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 30),
          minimumFetchInterval: const Duration(seconds: 10),
        ),
      );
      await remoteConfig.fetchAndActivate();

      compulsoryUpdateProvider = CompulsoryUpdateProvider(
        remoteConfig: remoteConfig,
      );
      await compulsoryUpdateProvider.processRemoteConfig();

      // Also call KillSwitchProvider.fetchRemoteConfig() to ensure debug output
      final killSwitchProvider = KillSwitchProvider(remoteConfig: remoteConfig);
      await killSwitchProvider.fetchRemoteConfig();
    }

    final fragment = Uri.base.fragment;
    final path = Uri.base.path;

    final bool isDirectSchulungenSearch =
        fragment == '/schulungen_search' ||
        fragment == 'schulungen_search' ||
        path == '/schulungen_search' ||
        path == 'schulungen_search';

    // Declare killSwitchProvider in outer scope so it is available for providers
    ChangeNotifierProvider<KillSwitchProvider>? killSwitchProviderInstance;
    if (!isWindows && remoteConfig != null) {
      final killSwitchProvider = KillSwitchProvider(remoteConfig: remoteConfig);
      await killSwitchProvider.fetchRemoteConfig();
      killSwitchProviderInstance = ChangeNotifierProvider(
        create: (_) => killSwitchProvider,
      );
    }

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
      if (!isWindows &&
          remoteConfig != null &&
          compulsoryUpdateProvider != null &&
          killSwitchProviderInstance != null) ...[
        killSwitchProviderInstance,
        ChangeNotifierProvider(create: (_) => compulsoryUpdateProvider!),
      ],
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

    final theme = ThemeData(
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: UIConstants.defaultAppColor,
      ),
    );

    Widget wrappedApp;
    if (!isWindows) {
      wrappedApp = KillSwitchGate(
        child: CompulsoryUpdateGate(child: appWidget),
      );
    } else {
      wrappedApp = appWidget;
    }
    /*
    runApp(
      MultiProvider(
        providers: providers,
        child: MaterialApp(theme: theme, home: wrappedApp),
      ),
    );
  */

    runApp(
      MultiProvider(    
        providers: providers,
        child:
            kDebugMode && kIsWeb
                ? SemanticsDebugger(
                  // ✅ overlay to visualize accessibility
                  child: MaterialApp(theme: theme, home: wrappedApp),
                )
                : MaterialApp(theme: theme, home: wrappedApp),
      ),
    );

    if (kIsWeb) {
      SemanticsBinding.instance.ensureSemantics();
    }
  } catch (e, stack) {
    debugPrint('❌ Firebase Initialization Failed: $e');
    debugPrint('STACK TRACE: \n$stack');
    // You cannot proceed if this fails
    return;
  }
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

  static Future<void> initializeKillSwitch(KillSwitchProvider provider) async {
    try {
      await provider.fetchRemoteConfig();
    } catch (e, st) {
      debugPrint('❌ Failed to fetch KillSwitch Remote Config: $e');
      debugPrint('STACK TRACE: $st');
    }
  }

  static Future<void> init({bool isWindows = false}) async {
    LoggerService.init(); // Initialize with default (will use kReleaseMode)
    configService = await ConfigService.load('assets/config.json');
    // Re-initialize logger with config to check webServer
    LoggerService.init(configService);

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
      postgrestService: postgrestService,
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

    // Create ApiService first (with temporary StartingRightsService to break circular dependency)
    final tempStartingRightsService = StartingRightsService();

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
      startingRightsService: tempStartingRightsService,
    );

    // Now set ApiService in the temporary StartingRightsService and use it as the real one
    tempStartingRightsService.setApiService(apiService);
    startingRightsService = tempStartingRightsService;

    // Update ApiService to use the real StartingRightsService (which is the same instance)
    apiService.setStartingRightsService(startingRightsService);

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
