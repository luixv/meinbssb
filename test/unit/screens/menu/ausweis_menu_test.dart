import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/menu/ausweis_menu.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/services/api_service.dart';
import 'dart:typed_data';
import 'package:meinbssb/services/core/image_service.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/services/core/token_service.dart';

// Minimal fake ConfigService for ApiService
import 'package:meinbssb/services/core/config_service.dart';

class FakeConfigService implements ConfigService {
  @override
  String? getString(String key, [String? section]) => null;
  @override
  int? getInt(String key, [String? section]) => null;
  @override
  List<String>? getList(String key, [String? section]) => null;
  @override
  bool? getBool(String key, [String? section]) => null;
}

class FakeHttpClient extends HttpClient {
  FakeHttpClient()
    : super(
        baseUrl: '',
        serverTimeout: 0,
        tokenService: _FakeTokenService(), // Provide a minimal fake
        configService: FakeConfigService(),
        cacheService: FakeCacheService(),
      );
}

class _FakeTokenService extends TokenService {
  _FakeTokenService()
    : super(
        configService: FakeConfigService(),
        cacheService: FakeCacheService(),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeCacheService extends CacheService {
  FakeCacheService()
    : super(prefs: FakeSharedPreferences(), configService: FakeConfigService());
}

class FakeSharedPreferences implements SharedPreferences {
  // Implement only required methods for test, or use noSuchMethod
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeImageService extends ImageService {
  FakeImageService() : super(httpClient: FakeHttpClient());
  @override
  Future<String?> getSchuetzenausweisCacheDate(int personId) async {
    return '01.01.2025';
  }
}

class FakeApiService implements ApiService {
  FakeApiService();

  @override
  Future<Uint8List> fetchSchuetzenausweis(
    int personId, {
    bool forceNetwork = false,
  }) async {
    // Valid tiny PNG image (1x1 transparent pixel)
    return Uint8List.fromList([
      137,
      80,
      78,
      71,
      13,
      10,
      26,
      10,
      0,
      0,
      0,
      13,
      73,
      72,
      68,
      82,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      1,
      8,
      6,
      0,
      0,
      0,
      31,
      21,
      196,
      137,
      0,
      0,
      0,
      12,
      73,
      68,
      65,
      84,
      8,
      153,
      99,
      0,
      1,
      0,
      0,
      5,
      0,
      1,
      13,
      10,
      26,
      10,
      0,
      0,
      0,
      0,
      73,
      69,
      78,
      68,
      174,
      66,
      96,
      130,
    ]);
  }

  final _configService = FakeConfigService();
  @override
  ConfigService get configService => _configService;
  // Provide a fake imageService for tests
  @override
  ImageService get imageService => FakeImageService();
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('ProfileScreen (Schützenausweis menu)', () {
    late UserData userData;

    setUp(() {
      userData = const UserData(
        personId: 1,
        webLoginId: 1,
        passnummer: '12345',
        vereinNr: 1,
        namen: 'Mustermann',
        vorname: 'Max',
        vereinName: 'Testverein',
        passdatenId: 1,
        mitgliedschaftId: 1,
      );
    });

    Widget createScreen() => MultiProvider(
      providers: [
        ChangeNotifierProvider<FontSizeProvider>(
          create: (_) => FontSizeProvider(),
        ),
        Provider<ApiService>(create: (_) => FakeApiService()),
      ],
      child: MaterialApp(
        home: ProfileScreen(
          userData: userData,
          isLoggedIn: true,
          onLogout: () {},
        ),
      ),
    );

    testWidgets('renders logo, header, and all menu items', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(
        find.text('Schützenausweis'),
        findsWidgets,
      ); // header (can appear more than once)
      expect(find.text('Anzeigen'), findsOneWidget);
      expect(find.text('Startrechte'), findsOneWidget);
      expect(find.text('Bestellen'), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.rule), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNWidgets(3));
    });

    testWidgets('navigates to SchuetzenausweisScreen on tap', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.tap(find.text('Anzeigen'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsNothing); // Should navigate away
    });

    testWidgets('navigates to StartingRightsScreen on tap', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.tap(find.text('Startrechte'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsNothing);
    });

    testWidgets('navigates to AusweisBestellenScreen on tap', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.tap(find.text('Bestellen'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsNothing);
    });
  });
}
