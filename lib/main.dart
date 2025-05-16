// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'services/api/auth_service.dart';
import 'services/api/user_service.dart';
import 'services/api_service.dart';
import 'services/email_service.dart';
import 'services/image_service.dart';
import 'services/http_client.dart';
import 'services/cache_service.dart';
import 'services/config_service.dart';
import 'services/logger_service.dart';
import 'services/network_service.dart';
import 'services/api/training_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.init();

  runApp(const MyAppWrapper());
}

class AppInitializer {
  static late ConfigService _configService;
  static late ApiService _apiService;
  static late NetworkService _networkService;
  static late CacheService _cacheService;
  static late HttpClient _httpClient;
  static late ImageService _imageService;
  static late TrainingService _trainingService;
  static late UserService _userService;
  static late AuthService _authService;

  static Future<void> init() async {
    LoggerService.init();
    _configService = await ConfigService.load('assets/config.json');
    final serverTimeout = _configService.getInt('serverTimeout', 'theme') ?? 10;

    final baseIP =
        _configService.getString('apiBaseServer', 'api') ?? '127.0.0.1';

    final port = _configService.getString('apiPort', 'api') ?? '56400';

    final path =
        _configService.getString('apiBasePath', 'api') ?? '/rest/zmi/api';

    _imageService = ImageService();
    final prefs = await SharedPreferences.getInstance();
    _cacheService = CacheService(
      prefs: prefs,
      configService: _configService,
    );
    _networkService = NetworkService(configService: _configService);

    _httpClient = HttpClient(
      baseUrl: 'https://$baseIP:$port/$path',
      serverTimeout: serverTimeout,
      configService: _configService,
      cacheService: _cacheService,
    );

    _trainingService = TrainingService(
      httpClient: _httpClient,
      cacheService: _cacheService,
      networkService: _networkService,
    );

    _userService = UserService(
      httpClient: _httpClient,
      cacheService: _cacheService,
      networkService: _networkService,
    );

    _authService = AuthService(
      httpClient: _httpClient,
      cacheService: _cacheService,
      networkService: _networkService,
    );

    _apiService = ApiService(
      configService: _configService,
      httpClient: _httpClient,
      imageService: _imageService,
      cacheService: _cacheService,
      networkService: _networkService,
      trainingService: _trainingService,
      userService: _userService,
      authService: _authService,
    );

    _registerProviders();
  }

  static void _registerProviders() {
    configServiceProvider = Provider<ConfigService>(
      create: (context) => _configService,
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
      create: (context) => _authService,
    );
    apiServiceProvider = Provider<ApiService>(create: (context) => _apiService);
    networkServiceProvider = Provider<NetworkService>(
      create: (context) => _networkService,
    );
    cacheServiceProvider = Provider<CacheService>(
      create: (context) => _cacheService,
    );
    trainingServiceProvider = Provider<TrainingService>(
      create: (context) => _trainingService,
    );
    userServiceProvider = Provider<UserService>(
      create: (context) => _userService,
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
}
