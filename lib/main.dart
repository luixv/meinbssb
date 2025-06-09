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
import 'services/core/email_service.dart';
import 'services/core/image_service.dart';
import 'services/core/http_client.dart';
import 'services/core/cache_service.dart';
import 'services/core/config_service.dart';
import 'services/core/logger_service.dart';
import 'services/core/network_service.dart';
import 'services/core/token_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.init();

  runApp(const MyAppWrapper());
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
  static late TokenService tokenService;

  static Future<void> init() async {
    LoggerService.init();
    configService = await ConfigService.load('assets/config.json');

    final serverTimeout = configService.getInt('serverTimeout', 'theme') ?? 10;
    final protocol = configService.getString('apiProtocol', 'api') ?? 'https';
    final baseIP =
        configService.getString('apiBaseServer', 'api') ?? '127.0.0.1';
    final port = configService.getString('apiPort', 'api') ?? '56400';
    final path =
        configService.getString('apiBasePath', 'api') ?? '/rest/zmi/api';

    imageService = ImageService();

    final prefs = await SharedPreferences.getInstance();

    cacheService = CacheService(
      prefs: prefs,
      configService: configService,
    );
    networkService = NetworkService(configService: configService);

    String baseUrl =
        '$protocol://$baseIP:$port${path.isNotEmpty ? '/$path' : ''}';

    // --- FIX STARTS HERE ---
    // Initialize the http.Client instance once and pass it to both services
    final baseHttpClient = http.Client();

    // 1. Initialize TokenService FIRST
    tokenService = TokenService(
      configService: configService,
      cacheService: cacheService,
      client: baseHttpClient, // Pass the shared http.Client
    );

    // 2. Then, initialize HttpClient, passing the now-initialized _tokenService
    httpClient = HttpClient(
      baseUrl: baseUrl,
      serverTimeout: serverTimeout,
      tokenService: tokenService, // This is now initialized!
      configService: configService,
      cacheService: cacheService,
      client: baseHttpClient, // Pass the shared http.Client
    );
    // --- FIX ENDS HERE ---

    trainingService = TrainingService(
      httpClient: httpClient,
      cacheService: cacheService,
      networkService: networkService,
    );

    userService = UserService(
      httpClient: httpClient,
      cacheService: cacheService,
      networkService: networkService,
    );

    authService = AuthService(
      httpClient: httpClient,
      cacheService: cacheService,
      networkService: networkService,
    );

    bankService = BankService(
      httpClient: httpClient,
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
      create: (context) => EmailService(
        emailSender: Provider.of<EmailSender>(context, listen: false),
        configService: Provider.of<ConfigService>(context, listen: false),
      ),
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
}
