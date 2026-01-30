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

// Add missing imports for all used services and models
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

// No DummyCacheService needed; use null as dynamic for cacheService in test context

// Minimal dummy TokenService for test
class DummyTokenService extends TokenService {
  DummyTokenService()
    : super(
        configService: ConfigService.instance,
        cacheService: null as dynamic,
      );
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

    Widget wrapWithMaterialApp(Widget child) {
      final configService = ConfigService.instance;
      final apiService = ApiService(
        configService: configService,
        httpClient: HttpClient(
          baseUrl: '',
          serverTimeout: 1,
          tokenService: DummyTokenService(),
          configService: configService,
          cacheService: null as dynamic,
        ),
        imageService: ImageService(httpClient: null as dynamic),
        cacheService: null as dynamic,
        networkService: NetworkService(configService: configService),
        trainingService: TrainingService(
          httpClient: null as dynamic,
          cacheService: null as dynamic,
          networkService: null as dynamic,
          configService: configService,
        ),
        userService: UserService(
          httpClient: null as dynamic,
          cacheService: null as dynamic,
          networkService: null as dynamic,
          configService: configService,
        ),
        authService: AuthService(
          httpClient: null as dynamic,
          cacheService: null as dynamic,
          networkService: null as dynamic,
          configService: configService,
          postgrestService: null as dynamic,
          emailService: null as dynamic,
        ),
        bankService: BankService.withClient(httpClient: null as dynamic),
        vereinService: VereinService(httpClient: null as dynamic),
        postgrestService: PostgrestService(configService: configService),
        emailService: EmailService(
          emailSender: null as dynamic,
          configService: configService,
          httpClient: null as dynamic,
        ),
        oktoberfestService: OktoberfestService(httpClient: null as dynamic),
        calendarService: CalendarService(),
        bezirkService: BezirkService(
          httpClient: null as dynamic,
          cacheService: null as dynamic,
          networkService: null as dynamic,
        ),
        startingRightsService: StartingRightsService(),
        rollsAndRights: RollsAndRights(httpClient: null as dynamic),
        workflowService: WorkflowService(),
        documentScannerService: DocumentScannerService(),
      );
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
