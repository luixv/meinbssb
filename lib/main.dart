import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meinbssb/services/api/rolls_and_rights_service.dart';
import 'package:meinbssb/services/api/workflow_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
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
import 'services/core/document_scanner_service.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Perform all initialization before runApp to avoid showing loading screen
  bool isWindows = false;
  try {
    isWindows = Platform.isWindows;
  } catch (_) {}

  final prefs = await SharedPreferences.getInstance();

  if (kIsWeb) {
    try {
      await clearSomeCookies(prefs);
    } catch (_) {}
    try {
      usePathUrlStrategy();
    } catch (_) {}
  }

  await initializeDateFormatting('de_DE', null);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase Error: $e');
  }

  await AppInitializer.init(isWindows: isWindows, prefs: prefs);

  // Reconstruct Provider Setup
  FirebaseRemoteConfig? remoteConfig;
  CompulsoryUpdateProvider? compulsoryUpdateProvider;
  bool remoteConfigSet = true;

  if (!isWindows) {
    try {
      remoteConfig = FirebaseRemoteConfig.instance;
      await getRemoteConfig(remoteConfig);

      final minVer = remoteConfig.getString('minimum_required_version');
      if (minVer.isNotEmpty) {
        await prefs.setString('cached_minimum_required_version', minVer);
      }

      compulsoryUpdateProvider = CompulsoryUpdateProvider(
        remoteConfig: remoteConfig,
        prefs: prefs,
      );
      await compulsoryUpdateProvider.processRemoteConfig();

      final killSwitch = KillSwitchProvider(remoteConfig: remoteConfig);
      await killSwitch.fetchRemoteConfig();
    } catch (e) {
      debugPrint('Remote Config Error: $e');
      remoteConfigSet = false;
    }
  }

  // Build Final App Logic
  final path = Uri.base.path;
  final bool isDirect =
      path == '/schulungen_search' || path.startsWith('/schulungen_search');

  ChangeNotifierProvider<KillSwitchProvider>? killSwitchProviderInstance;
  if (!isWindows && remoteConfig != null && remoteConfigSet) {
    final ksp = KillSwitchProvider(remoteConfig: remoteConfig);
    await ksp.fetchRemoteConfig();
    killSwitchProviderInstance = ChangeNotifierProvider(create: (_) => ksp);
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
    AppInitializer.calendarServiceProvider,
    if (!isWindows &&
        remoteConfig != null &&
        compulsoryUpdateProvider != null &&
        killSwitchProviderInstance != null &&
        remoteConfigSet) ...[
      killSwitchProviderInstance,
      ChangeNotifierProvider(create: (_) => compulsoryUpdateProvider!),
    ],
  ];

  Widget appWidget;
  if (isDirect) {
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
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: UIConstants.defaultAppColor,
    ),
  );

  Widget wrappedApp;
  if (!isWindows && remoteConfigSet) {
    wrappedApp = KillSwitchGate(child: CompulsoryUpdateGate(child: appWidget));
  } else {
    wrappedApp = appWidget;
  }

  final finalApp = MultiProvider(
    providers: providers,
    child: MaterialApp(theme: theme, home: wrappedApp),
  );

  runApp(finalApp);
}

Future<void> getRemoteConfig(FirebaseRemoteConfig remoteConfig) async {
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
}

Future<void> clearSomeCookies(SharedPreferences prefs) async {
  // TODO : Clear only specific cookies if needed
  await prefs.clear();
}

class AppInitializer {
  static late ConfigService configService;
  static late Provider<ConfigService> configServiceProvider;

  static late EmailService emailService;
  static late Provider<EmailService> emailServiceProvider;

  static late EmailSender emailSender;
  static late Provider<EmailSender> emailSenderProvider;

  static late AuthService authService;
  static late Provider<AuthService> authServiceProvider;

  static late ApiService apiService;
  static late Provider<ApiService> apiServiceProvider;

  static late NetworkService networkService;
  static late Provider<NetworkService> networkServiceProvider;

  static late CacheService cacheService;
  static late Provider<CacheService> cacheServiceProvider;

  static late TrainingService trainingService;
  static late Provider<TrainingService> trainingServiceProvider;

  static late UserService userService;
  static late Provider<UserService> userServiceProvider;

  static late TokenService tokenService;
  static late Provider<TokenService> tokenServiceProvider;

  static late FontSizeProvider fontSizeService;
  static late ChangeNotifierProvider<FontSizeProvider> fontSizeProvider;

  static late OktoberfestService oktoberfestService;
  static late Provider<OktoberfestService> oktoberfestServiceProvider;

  static late CalendarService calendarService;
  static late Provider<CalendarService> calendarServiceProvider;

  static late RollsAndRights rollsAndRights;
  static late WorkflowService workflowService;

  static late HttpClient httpClient;

  static Future<void> init({
    bool isWindows = false,
    required SharedPreferences prefs,
  }) async {
    debugPrint('AppInitializer: Starting init...');
    LoggerService.init();
    debugPrint('AppInitializer: Loading config...');
    configService = await ConfigService.load('assets/config.json');
    debugPrint('AppInitializer: Config loaded.');

    if (!isWindows) {
      LoggerService.init(configService);
    }

    // Core Services
    configServiceProvider = Provider<ConfigService>.value(value: configService);

    networkService = NetworkService(configService: configService);
    networkServiceProvider = Provider<NetworkService>.value(
      value: networkService,
    );

    cacheService = CacheService(prefs: prefs, configService: configService);
    cacheServiceProvider = Provider<CacheService>.value(value: cacheService);

    tokenService = TokenService(
      configService: configService,
      cacheService: cacheService,
    );
    tokenServiceProvider = Provider<TokenService>.value(value: tokenService);

    fontSizeService = FontSizeProvider();
    fontSizeProvider = ChangeNotifierProvider<FontSizeProvider>.value(
      value: fontSizeService,
    );

    // Initialize HttpClient
    // Note: Logging with PostgrestService is disabled here to avoid circular dependency
    final baseUrl = ConfigService.buildBaseUrlForServer(
      configService,
      name: 'apiBase',
    );
    final serverTimeout =
        int.tryParse(configService.getString('serverTimeout') ?? '30') ?? 30;

    httpClient = HttpClient(
      baseUrl: baseUrl,
      serverTimeout: serverTimeout,
      tokenService: tokenService,
      configService: configService,
      cacheService: cacheService,
      postgrestService: null,
    );

    // Initialize EmailSender first as it is a dependency
    emailSender = MailerEmailSender();
    emailSenderProvider = Provider<EmailSender>.value(value: emailSender);

    emailService = EmailService(
      emailSender: emailSender,
      configService: configService,
      httpClient: httpClient,
    );
    emailServiceProvider = Provider<EmailService>.value(value: emailService);

    calendarService = CalendarService();
    calendarServiceProvider = Provider<CalendarService>.value(
      value: calendarService,
    );

    // Initialize Domain Services
    final imageService = ImageService(httpClient: httpClient);
    final postgrestService = PostgrestService(configService: configService);

    // Attach PostgrestService to HttpClient (to enable API request logging)
    httpClient.setPostgrestService(postgrestService);

    // Services that ApiService needs
    final bankService = BankService.withClient(httpClient: httpClient);
    final vereinService = VereinService(httpClient: httpClient);
    final bezirkService = BezirkService(
      httpClient: httpClient,
      cacheService: cacheService,
      networkService: networkService,
    );
    final startingRightsService =
        StartingRightsService(); // Needs ApiService later

    oktoberfestService = OktoberfestService(httpClient: httpClient);
    oktoberfestServiceProvider = Provider<OktoberfestService>.value(
      value: oktoberfestService,
    );

    userService = UserService(
      httpClient: httpClient,
      cacheService: cacheService,
      networkService: networkService,
      configService: configService,
    );
    userServiceProvider = Provider<UserService>.value(value: userService);

    trainingService = TrainingService(
      httpClient: httpClient,
      cacheService: cacheService,
      networkService: networkService,
      configService: configService,
    );
    trainingServiceProvider = Provider<TrainingService>.value(
      value: trainingService,
    );

    // Initialize RollsAndRights service
    rollsAndRights = RollsAndRights(httpClient: httpClient);

    // Initialize WorkflowService
    workflowService = WorkflowService();

    authService = AuthService(
      httpClient: httpClient,
      cacheService: cacheService,
      networkService: networkService,
      configService: configService,
      postgrestService: postgrestService,
      emailService: emailService,
    );
    authServiceProvider = Provider<AuthService>.value(value: authService);

    // Initialize DocumentScannerService
    final documentScannerService = DocumentScannerService();

    // Initialize ApiService with ALL dependencies
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
      rollsAndRights: rollsAndRights,
      workflowService: workflowService,
      documentScannerService: documentScannerService,
    );
    apiServiceProvider = Provider<ApiService>.value(value: apiService);

    // Break circular dependency
    startingRightsService.setApiService(apiService);

    _registerProviders();
    debugPrint('AppInitializer: init completed.');
  }

  static void _registerProviders() {
    //  Helper function to keep init cleaner
  }
}
