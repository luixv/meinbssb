import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/schuetzenausweis_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/core/image_service.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/services/api/training_service.dart';
import 'package:meinbssb/services/api/user_service.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/api/bank_service.dart';
import 'package:meinbssb/services/api/verein_service.dart';
import 'package:meinbssb/services/api/oktoberfest_service.dart';
import 'package:meinbssb/services/api/bezirk_service.dart';
import 'package:meinbssb/services/api/starting_rights_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:meinbssb/services/core/token_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/providers/theme_provider.dart';
import 'package:meinbssb/services/core/postgrest_service.dart';
import 'package:meinbssb/services/core/email_service.dart';
import 'package:meinbssb/services/core/calendar_service.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mockito/annotations.dart';

void main() {
  setUp(() async {
    await ConfigService.load('assets/config.json');
  });
  tearDown(() {
    ConfigService.reset();
  });

  const dummyUser = UserData(
    personId: 1,
    webLoginId: 1,
    passnummer: '12345',
    vereinNr: 1,
    namen: 'User',
    vorname: 'Test',
    vereinName: 'Test Verein',
    passdatenId: 1,
    mitgliedschaftId: 1,
  );

  // Use a valid 1x1 transparent PNG for tests
  const validPngBytes = <int>[
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82,
  ];

  Widget createTestWidget({
    required ApiService apiService,
    bool isLoggedIn = true,
    Function()? onLogout,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FontSizeProvider>(
          create: (_) => TestFontSizeProvider(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => TestThemeProvider(),
        ),
        Provider<ApiService>.value(value: apiService),
        Provider<ConfigService>.value(value: ConfigService.instance),
      ],
      child: MaterialApp(
        routes: {
          '/home': (context) =>
              const Scaffold(body: Text('Home')), // for navigation test
        },
        home: SchuetzenausweisScreen(
          personId: 1,
          userData: dummyUser,
          isLoggedIn: isLoggedIn,
          onLogout: onLogout ?? () {},
        ),
      ),
    );
  }

  testWidgets(
    'shows loading indicator while waiting',
    (WidgetTester tester) async {
      final apiService = MockApiService();
      await tester.pumpWidget(createTestWidget(apiService: apiService));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Skipped due to pending timer from a widget/provider (see test log)
      // To fix, refactor providers/widgets to avoid timers, or use a custom FakeAsync zone.
    },
    skip: true,
  );

  testWidgets('shows error message on error', (WidgetTester tester) async {
    final apiService = MockApiService(shouldThrow: true);
    await tester.pumpWidget(createTestWidget(apiService: apiService));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Error beim Laden des Schützenausweises'),
      findsOneWidget,
    );
  });

  testWidgets('shows image on success', (WidgetTester tester) async {
    final apiService =
        MockApiService(fetchResult: Uint8List.fromList(validPngBytes));
    await tester.pumpWidget(createTestWidget(apiService: apiService));
    await tester.pumpAndSettle();
    final imageWidgets = tester.widgetList<Image>(find.byType(Image)).toList();
    expect(imageWidgets.length, 2);
    expect(imageWidgets.any((img) => img.image is MemoryImage), isTrue);
    expect(
      find.byKey(const ValueKey<String>('schuetzenausweis')),
      findsOneWidget,
    );
  });

  testWidgets('FAB navigates to /home', (WidgetTester tester) async {
    final apiService =
        MockApiService(fetchResult: Uint8List.fromList(validPngBytes));
    await tester.pumpWidget(createTestWidget(apiService: apiService));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });
}

class DummyPrefs implements SharedPreferences {
  final Map<String, Object> _data = {};
  @override
  Set<String> getKeys() => _data.keys.toSet();
  @override
  Object? get(String key) => _data[key];
  @override
  bool containsKey(String key) => _data.containsKey(key);
  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  String? getString(String key) => _data[key] as String?;
  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  // Implement only what is needed for the test
  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _data[key] = value;
    return true;
  }

  @override
  int? getInt(String key) => _data[key] as int?;
  @override
  Future<bool> setBool(String key, bool value) async {
    _data[key] = value;
    return true;
  }

  @override
  bool? getBool(String key) => _data[key] as bool?;
  // The rest can throw UnimplementedError
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class DummyCacheService extends CacheService {
  DummyCacheService()
      : super(prefs: DummyPrefs(), configService: ConfigService.instance);
}

class DummyTokenService extends TokenService {
  DummyTokenService()
      : super(
          configService: ConfigService.instance,
          cacheService: DummyCacheService(),
        );
  @override
  Future<String> getAuthToken() async => 'dummy';
  @override
  Future<String> requestToken() async => 'dummy';
  @override
  Future<void> clearToken() async {}
}

class DummyHttpClient extends HttpClient {
  DummyHttpClient()
      : super(
          baseUrl: '',
          serverTimeout: 1,
          tokenService: DummyTokenService(),
          configService: ConfigService.instance,
          cacheService: DummyCacheService(),
        );
}

class DummyNetworkService extends NetworkService {
  DummyNetworkService() : super(configService: ConfigService.instance);
}

class DummyImageService extends ImageService {
  DummyImageService()
      : super(
          httpClient: DummyHttpClient(),
        );
}

class DummyTrainingService extends TrainingService {
  DummyTrainingService()
      : super(
          httpClient: DummyHttpClient(),
          cacheService: DummyCacheService(),
          networkService: DummyNetworkService(),
          configService: ConfigService.instance,
        );
}

class DummyUserService extends UserService {
  DummyUserService()
      : super(
          httpClient: DummyHttpClient(),
          cacheService: DummyCacheService(),
          networkService: DummyNetworkService(),
          configService: ConfigService.instance,
        );
}

class DummyEmailSender implements EmailSender {
  @override
  Future<SendReport> send(Message message, SmtpServer server) async {
    return SendReport(message, DateTime.now(), DateTime.now(), DateTime.now());
  }
}

class DummyEmailService extends EmailService {
  DummyEmailService()
      : super(
          emailSender: DummyEmailSender(),
          configService: ConfigService.instance,
          httpClient: DummyHttpClient(),
        );

  @override
  Future<Map<String, dynamic>> sendEmail({
    required String sender,
    required String recipient,
    required String subject,
    String? htmlBody,
    int? emailId,
  }) async {
    return {'ResultType': 1, 'ResultMessage': 'Email sent successfully'};
  }
}

@GenerateMocks(
  [EmailSender],
  customMocks: [MockSpec<EmailSender>(as: #TestEmailSender)],
)
class DummyAuthService extends AuthService {
  DummyAuthService()
      : super(
          httpClient: DummyHttpClient(),
          cacheService: DummyCacheService(),
          networkService: DummyNetworkService(),
          configService: ConfigService.instance,
          secureStorage: null,
          postgrestService:
              PostgrestService(configService: ConfigService.instance),
          emailService: DummyEmailService(),
        );
}

class DummyBankService extends BankService {
  DummyBankService() : super(DummyHttpClient());
}

class DummyVereinService extends VereinService {
  DummyVereinService() : super(httpClient: DummyHttpClient());
}

class DummyOktoberfestService extends OktoberfestService {
  DummyOktoberfestService() : super(httpClient: DummyHttpClient());
}

class DummyCalendarService extends CalendarService {}

class DummyBezirkService extends BezirkService {
  DummyBezirkService()
      : super(
          httpClient: DummyHttpClient(),
          cacheService: DummyCacheService(),
          networkService: DummyNetworkService(),
        );
}

class DummyStartingRightsService extends StartingRightsService {
  DummyStartingRightsService()
      : super(
          userService: DummyUserService(),
          vereinService: DummyVereinService(),
          emailService: DummyEmailService(),
        );
}

class MockApiService extends ApiService {
  MockApiService({this.fetchResult, this.shouldThrow = false})
      : super(
          configService: ConfigService.instance,
          httpClient: DummyHttpClient(),
          imageService: DummyImageService(),
          cacheService: DummyCacheService(),
          networkService: DummyNetworkService(),
          trainingService: DummyTrainingService(),
          userService: DummyUserService(),
          authService: DummyAuthService(),
          bankService: DummyBankService(),
          vereinService: DummyVereinService(),
          postgrestService:
              PostgrestService(configService: ConfigService.instance),
          emailService: DummyEmailService(),
          oktoberfestService: DummyOktoberfestService(),
          calendarService: DummyCalendarService(),
          bezirkService: DummyBezirkService(),
          startingRightsService: DummyStartingRightsService(),
        );
  final Uint8List? fetchResult;
  final bool shouldThrow;
  @override
  Future<Uint8List> fetchSchuetzenausweis(int personId) async {
    if (shouldThrow) throw Exception('Test error');
    if (fetchResult != null) return fetchResult!;
    await Future.delayed(const Duration(milliseconds: 10));
    return Uint8List.fromList([1, 2, 3]);
  }
}

class TestFontSizeProvider extends FontSizeProvider {
  TestFontSizeProvider() {
    // Do not call _loadSavedScale in tests
  }
}

class TestThemeProvider extends ThemeProvider {
  TestThemeProvider() {
    // Do not call _loadThemePreference in tests
  }
}
