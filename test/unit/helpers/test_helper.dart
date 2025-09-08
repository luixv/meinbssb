import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/services/core/email_service.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/services/core/font_size_provider.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/models/user_data.dart';
import 'dart:typed_data';
import 'test_mocks.mocks.dart';
import 'package:meinbssb/providers/theme_provider.dart';

class TestHelper {
  static late MockAuthService mockAuthService;
  static late MockApiService mockApiService;
  static late MockConfigService mockConfigService;
  static late MockEmailService mockEmailService;
  static late MockCacheService mockCacheService;
  static late MockNetworkService mockNetworkService;
  static late MockHttpClient mockHttpClient;

  static void setupMocks() {
    mockAuthService = MockAuthService();
    mockApiService = MockApiService();
    mockConfigService = MockConfigService();
    mockEmailService = MockEmailService();
    mockCacheService = MockCacheService();
    mockNetworkService = MockNetworkService();
    mockHttpClient = MockHttpClient();

    // Default mock responses
    when(mockConfigService.getString('logoName', 'appTheme'))
        .thenReturn('assets/images/myBSSB-logo.png');
    when(mockAuthService.login(any, any)).thenAnswer(
      (_) async => {
        'ResultType': 1,
        'PersonID': 439287,
        'WebLoginID': 13901,
      },
    );
    when(mockApiService.login(any, any)).thenAnswer(
      (_) async => {
        'ResultType': 1,
        'PersonID': 439287,
        'WebLoginID': 13901,
      },
    );
    when(mockApiService.fetchPassdaten(any)).thenAnswer(
      (_) async => const UserData(
        personId: 439287,
        webLoginId: 13901,
        passnummer: '40100709',
        vereinNr: 401051,
        namen: 'Schürz',
        vorname: 'Lukas',
        vereinName: 'Feuerschützen Kühbach',
        passdatenId: 2000009155,
        mitgliedschaftId: 439287,
        strasse: 'Aichacher Strasse 21',
        plz: '86574',
        ort: 'Alsmoos',
        telefon: '123456789',
      ),
    );
    when(mockApiService.fetchSchuetzenausweis(any))
        .thenAnswer((_) async => Uint8List(0));
    when(mockApiService.changePassword(any, any)).thenAnswer(
      (_) async => {'result': true},
    );
    when(mockNetworkService.hasInternet()).thenAnswer((_) async => true);
    when(mockNetworkService.getCacheExpirationDuration())
        .thenReturn(const Duration(hours: 1));
    when(mockCacheService.getString(any))
        .thenAnswer((_) async => 'test_username');
    when(mockHttpClient.get(any)).thenAnswer((_) async => MockResponse());
    when(mockHttpClient.post(any, any)).thenAnswer((_) async => MockResponse());
  }

  static Widget createTestApp({
    required Widget home,
    Map<String, WidgetBuilder>? routes,
    AuthService? authService,
    ApiService? apiService,
    CacheService? cacheService,
    ConfigService? configService,
    EmailService? emailService,
    NetworkService? networkService,
    HttpClient? httpClient,
  }) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => authService ?? mockAuthService,
        ),
        Provider<ApiService>(
          create: (_) => apiService ?? mockApiService,
        ),
        Provider<CacheService>(
          create: (_) => cacheService ?? mockCacheService,
        ),
        Provider<ConfigService>(
          create: (_) => configService ?? mockConfigService,
        ),
        Provider<EmailService>(
          create: (_) => emailService ?? mockEmailService,
        ),
        Provider<NetworkService>(
          create: (_) => networkService ?? mockNetworkService,
        ),
        Provider<HttpClient>(
          create: (_) => httpClient ?? mockHttpClient,
        ),
        ChangeNotifierProvider<FontSizeProvider>(
          create: (_) => FontSizeProvider(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: MaterialApp(
        home: home,
        routes: routes ?? {},
      ),
    );
  }

  static Widget createTestWidget({
    required Widget child,
    AuthService? authService,
    ApiService? apiService,
    CacheService? cacheService,
    ConfigService? configService,
    EmailService? emailService,
    NetworkService? networkService,
    HttpClient? httpClient,
  }) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => authService ?? mockAuthService,
        ),
        Provider<ApiService>(
          create: (_) => apiService ?? mockApiService,
        ),
        Provider<CacheService>(
          create: (_) => cacheService ?? mockCacheService,
        ),
        Provider<ConfigService>(
          create: (_) => configService ?? mockConfigService,
        ),
        Provider<EmailService>(
          create: (_) => emailService ?? mockEmailService,
        ),
        Provider<NetworkService>(
          create: (_) => networkService ?? mockNetworkService,
        ),
        Provider<HttpClient>(
          create: (_) => httpClient ?? mockHttpClient,
        ),
        ChangeNotifierProvider<FontSizeProvider>(
          create: (_) => FontSizeProvider(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: child,
    );
  }
}

class MockResponse {
  final int statusCode = 200;
  final String body = '{"success": true}';
}
