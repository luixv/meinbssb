// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'services/api/auth_service.dart';
import 'services/api_service.dart';
import 'services/email_service.dart';
import 'services/image_service.dart';
import 'services/http_client.dart';
import 'services/cache_service.dart';
import 'services/config_service.dart';
import 'services/logger_service.dart';
import 'services/network_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.init();

  runApp(const MyAppWrapper());
}

class AppInitializer {
  static late ConfigService _configServiceInstance;
  static late ApiService _apiService;
  static late NetworkService _networkService;
  static late CacheService _cacheService;
  static late HttpClient _httpClient;

  static Future<void> init() async {
    LoggerService.init();
    _configServiceInstance = await ConfigService.load('assets/config.json');
    final serverTimeout =
        _configServiceInstance.getInt('serverTimeout', 'theme') ?? 10;
    final baseIP =
        _configServiceInstance.getString('apiBaseIP', 'api') ?? '127.0.0.1';
    final port = _configServiceInstance.getString('apiPort', 'api') ?? '3001';

    final imageService = ImageService();
    final prefs = await SharedPreferences.getInstance();
    _cacheService = CacheService(
      prefs: prefs,
      configService: _configServiceInstance,
    );
    _networkService = NetworkService(configService: _configServiceInstance);

    _httpClient = HttpClient(
      baseUrl: 'http://$baseIP:$port',
      serverTimeout: serverTimeout,
    );

    _apiService = ApiService(
      configService: _configServiceInstance,
      httpClient: _httpClient,
      imageService: imageService,
      cacheService: _cacheService,
      networkService: _networkService,
    );

    _registerProviders();
  }

  static void _registerProviders() {
    configServiceProvider = Provider<ConfigService>(
      create: (context) => _configServiceInstance,
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
      create: (context) => AuthService(
        httpClient: _httpClient,
        cacheService: _cacheService,
        networkService: _networkService,
      ),
    );
    apiServiceProvider = Provider<ApiService>(create: (context) => _apiService);
    networkServiceProvider = Provider<NetworkService>(
      create: (context) => _networkService,
    );
    cacheServiceProvider = Provider<CacheService>(
      create: (context) => _cacheService,
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
}
