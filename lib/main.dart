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
  static Future<void> init() async {
    LoggerService.init();
    final configServiceInstance = await ConfigService.load(
      'assets/config.json',
    );
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
    final networkService = NetworkService(
      configService: ConfigService.instance,
    );

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

    _registerProviders(apiService, networkService, cacheService, httpClient);
  }

  static void _registerProviders(
    ApiService apiService,
    NetworkService networkService,
    CacheService cacheService,
    HttpClient httpClient,
  ) {
    configServiceProvider = Provider<ConfigService>(
      create: (context) => ConfigService.instance,
    );
    emailSenderProvider = Provider<EmailSender>(
      create: (context) => MailerEmailSender(),
    );
    emailServiceProvider = Provider<EmailService>(
      create: (context) => EmailService(
        emailSender: context.read<EmailSender>(),
        configService: context.read<ConfigService>(),
      ),
    );
    authServiceProvider = Provider<AuthService>(
      create: (context) => AuthService(
        httpClient: httpClient,
        cacheService: cacheService,
        networkService: networkService,
      ),
    );
    apiServiceProvider = Provider<ApiService>(create: (context) => apiService);
    networkServiceProvider = Provider<NetworkService>(
      create: (context) => networkService,
    );
    cacheServiceProvider = Provider<CacheService>(
      create: (context) => cacheService,
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
