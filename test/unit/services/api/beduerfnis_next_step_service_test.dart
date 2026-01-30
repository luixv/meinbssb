// Minimal dummy HttpClient for test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/beduerfnis_antrag_data.dart';
import 'package:meinbssb/models/beduerfnis_navigation_params.dart';
import 'package:meinbssb/models/beduerfnis_page.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/api/beduerfnis_next_step_service.dart';
import 'package:meinbssb/services/api/workflow_service.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step2_screen.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step3_screen.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step4_screen.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step5_screen.dart';

import 'package:meinbssb/models/beduerfnis_antrag_status_data.dart';

import 'package:provider/provider.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/services/core/token_service.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/core/image_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/services/api/training_service.dart';
import 'package:meinbssb/services/api/user_service.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/api/bank_service.dart';
import 'package:meinbssb/services/api/verein_service.dart';
import 'package:meinbssb/services/core/postgrest_service.dart';
import 'package:meinbssb/services/core/email_service.dart';
import 'package:meinbssb/services/api/oktoberfest_service.dart';
import 'package:meinbssb/services/core/calendar_service.dart';
import 'package:meinbssb/services/api/bezirk_service.dart';
import 'package:meinbssb/services/api/starting_rights_service.dart';
import 'package:meinbssb/services/api/rolls_and_rights_service.dart';
import 'package:meinbssb/services/core/document_scanner_service.dart';

// Minimal dummy CacheService for test
import 'package:meinbssb/services/core/cache_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

class DummyHttpClient extends HttpClient {
  DummyHttpClient(TokenService tokenService, CacheService cacheService)
    : super(
        baseUrl: '',
        serverTimeout: 1,
        tokenService: tokenService,
        configService: ConfigService.instance,
        cacheService: cacheService,
      );
}

class DummyCacheService extends CacheService {
  DummyCacheService(SharedPreferences prefs)
    : super(prefs: prefs, configService: ConfigService.instance);
  @override
  Future<void> clear() async {}
  Future<void> clearAll() async {}
  Future<void> clearByPrefix(String prefix) async {}
  Future<void> clearExpired() async {}
  Future<void> clearKey(String key) async {}
  @override
  Future<bool> containsKey(String key) async => false;
  @override
  Future<int?> getInt(String key) async => null;
  @override
  Future<String?> getString(String key) async => null;
  @override
  Future<void> remove(String key) async {}
  @override
  Future<void> setInt(String key, int value) async {}
  @override
  Future<void> setString(String key, String value) async {}
  static Future<DummyCacheService> create() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    return DummyCacheService(prefs);
  }
}

// Minimal dummy TokenService for test
class DummyTokenService extends TokenService {
  DummyTokenService(CacheService cacheService)
    : super(configService: ConfigService.instance, cacheService: cacheService);
  @override
  Future<String> getAuthToken() async => '';
  @override
  Future<void> clearToken() async {}
  @override
  Future<String> requestToken() async => '';
}

void main() {
  setUpAll(() async {
    await ConfigService.load('assets/config.json');
  });

  group('BeduerfnisNextStepService.getNextStepRoute', () {
    late DummyCacheService dummyCacheService;
    // Removed unused dummyTokenService variable
    late ApiService apiService;
    final service = BeduerfnisNextStepService();
    final userData = UserData(
      personId: 1,
      passnummer: 'P123',
      vereinNr: 42,
      namen: 'Mustermann',
      vorname: 'Max',
      vereinName: 'Testverein',
      passdatenId: 99,
      mitgliedschaftId: 77,
      webLoginId: 123,
    );
    final antrag = BeduerfnisAntrag(
      antragsnummer: 123,
      personId: 1,
      statusId: BeduerfnisAntragStatus.entwurf,
    );
    final navigationParams = BeduerfnisNavigationParams(
      wbkType: 'neu',
      wbkColor: 'gelb',
      weaponType: 'kurz',
      anzahlWaffen: 1,
      currentPage: BeduerfnisPage.step1,
    );
    final workflowRole = WorkflowRole.mitglied;

    setUpAll(() async {
      dummyCacheService = await DummyCacheService.create();
      final configService = ConfigService.instance;
      final dummyTokenService = DummyTokenService(dummyCacheService);
      final dummyHttpClient = DummyHttpClient(
        dummyTokenService,
        dummyCacheService,
      );
      final dummyNetworkService = NetworkService(configService: configService);
      apiService = ApiService(
        configService: configService,
        httpClient: dummyHttpClient,
        imageService: ImageService(httpClient: dummyHttpClient),
        cacheService: dummyCacheService,
        networkService: dummyNetworkService,
        trainingService: TrainingService(
          httpClient: dummyHttpClient,
          cacheService: dummyCacheService,
          networkService: dummyNetworkService,
          configService: configService,
        ),
        userService: UserService(
          httpClient: dummyHttpClient,
          cacheService: dummyCacheService,
          networkService: dummyNetworkService,
          configService: configService,
        ),
        authService: AuthService(
          httpClient: dummyHttpClient,
          cacheService: dummyCacheService,
          networkService: dummyNetworkService,
          configService: configService,
          postgrestService: null as dynamic,
          emailService: null as dynamic,
        ),
        bankService: BankService.withClient(httpClient: dummyHttpClient),
        vereinService: VereinService(httpClient: dummyHttpClient),
        postgrestService: PostgrestService(configService: configService),
        emailService: EmailService(
          emailSender: null as dynamic,
          configService: configService,
          httpClient: dummyHttpClient,
        ),
        oktoberfestService: OktoberfestService(httpClient: dummyHttpClient),
        calendarService: CalendarService(),
        bezirkService: BezirkService(
          httpClient: dummyHttpClient,
          cacheService: dummyCacheService,
          networkService: dummyNetworkService,
        ),
        startingRightsService: StartingRightsService(),
        rollsAndRights: RollsAndRights(httpClient: dummyHttpClient),
        workflowService: WorkflowService(),
        documentScannerService: DocumentScannerService(),
      );
    });

    Widget wrapWithMaterialApp(Widget child) {
      return MultiProvider(
        providers: [
          Provider<ApiService>.value(value: apiService),
          ChangeNotifierProvider<FontSizeProvider>(
            create: (_) => FontSizeProvider(),
          ),
        ],
        child: MaterialApp(home: child),
      );
    }

    testWidgets('returns route to step2 when currentPage is step1', (
      tester,
    ) async {
      final route = service.getNextStepRoute(
        context: tester.element(find.byType(Container)),
        userData: userData,
        antrag: antrag,
        isLoggedIn: true,
        onLogout: () {},
        userRole: workflowRole,
        readOnly: false,
        navigationParams: navigationParams,
      );
      expect(route, isA<MaterialPageRoute>());
      // Build the widget to check the type
      await tester.pumpWidget(
        wrapWithMaterialApp(
          route.builder(tester.element(find.byType(Container))),
        ),
      );
      expect(find.byType(BeduerfnisantragStep2Screen), findsOneWidget);
    });

    testWidgets('returns route to step3 when currentPage is step2', (
      tester,
    ) async {
      final params = navigationParams.copyWith(
        currentPage: BeduerfnisPage.step2,
      );
      final route = service.getNextStepRoute(
        context: tester.element(find.byType(Container)),
        userData: userData,
        antrag: antrag,
        isLoggedIn: true,
        onLogout: () {},
        userRole: workflowRole,
        readOnly: false,
        navigationParams: params,
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(
          route.builder(tester.element(find.byType(Container))),
        ),
      );
      expect(find.byType(BeduerfnisantragStep3Screen), findsOneWidget);
    });

    testWidgets('returns route to step4 when currentPage is step3', (
      tester,
    ) async {
      final params = navigationParams.copyWith(
        currentPage: BeduerfnisPage.step3,
      );
      final route = service.getNextStepRoute(
        context: tester.element(find.byType(Container)),
        userData: userData,
        antrag: antrag,
        isLoggedIn: true,
        onLogout: () {},
        userRole: workflowRole,
        readOnly: false,
        navigationParams: params,
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(
          route.builder(tester.element(find.byType(Container))),
        ),
      );
      expect(find.byType(BeduerfnisantragStep4Screen), findsOneWidget);
    });

    testWidgets('returns route to step5 when currentPage is step4', (
      tester,
    ) async {
      final params = navigationParams.copyWith(
        currentPage: BeduerfnisPage.step4,
      );
      final route = service.getNextStepRoute(
        context: tester.element(find.byType(Container)),
        userData: userData,
        antrag: antrag,
        isLoggedIn: true,
        onLogout: () {},
        userRole: workflowRole,
        readOnly: false,
        navigationParams: params,
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(
          route.builder(tester.element(find.byType(Container))),
        ),
      );
      expect(find.byType(BeduerfnisantragStep5Screen), findsOneWidget);
    });
  });
}
