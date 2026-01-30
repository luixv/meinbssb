import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meinbssb/models/beduerfnis_page.dart';
import 'package:meinbssb/models/beduerfnis_navigation_params.dart';
import 'package:meinbssb/models/beduerfnis_antrag_data.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/api/workflow_service.dart';
import 'package:meinbssb/services/api/beduerfnis_next_step_service.dart';

import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step2_screen.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step3_screen.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step4_screen.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step5_screen.dart';
import 'package:meinbssb/models/beduerfnis_antrag_status_data.dart';

void main() {
  late BeduerfnisNextStepService service;
  late UserData userData;
  late BeduerfnisAntrag antrag;
  late WorkflowRole userRole;

  setUp(() {
    service = BeduerfnisNextStepService();

    userData = UserData(
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

    antrag = BeduerfnisAntrag(
      antragsnummer: 123,
      personId: 1,
      statusId: BeduerfnisAntragStatus.entwurf,
    );

    userRole = WorkflowRole.mitglied;
  });

  BeduerfnisNavigationParams baseParams(BeduerfnisPage page) {
    return BeduerfnisNavigationParams(
      wbkType: 'neu',
      wbkColor: 'gelb',
      weaponType: 'kurz',
      anzahlWaffen: 1,
      currentPage: page,
    );
  }

  Future<Widget> buildNextPage(
    WidgetTester tester,
    BeduerfnisNavigationParams params,
  ) async {
    late Widget widget;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final route = service.getNextStepRoute(
              context: context,
              userData: userData,
              antrag: antrag,
              isLoggedIn: true,
              onLogout: () {},
              userRole: userRole,
              readOnly: false,
              navigationParams: params,
            );

            widget = route.builder(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    return widget;
  }

  testWidgets('step1 → step2 → BeduerfnisantragStep2Screen', (tester) async {
    final widget = await buildNextPage(
      tester,
      baseParams(BeduerfnisPage.step1),
    );

    expect(widget, isA<BeduerfnisantragStep2Screen>());

    final screen = widget as BeduerfnisantragStep2Screen;
    expect(screen.navigationParams.currentPage, BeduerfnisPage.step2);
    expect(screen.navigationParams.wbkType, 'neu');
    expect(screen.navigationParams.wbkColor, 'gelb');
    expect(screen.navigationParams.weaponType, 'kurz');
    expect(screen.navigationParams.anzahlWaffen, 1);
  });

  testWidgets('step2 → step3 → BeduerfnisantragStep3Screen', (tester) async {
    final widget = await buildNextPage(
      tester,
      baseParams(BeduerfnisPage.step2),
    );

    expect(widget, isA<BeduerfnisantragStep3Screen>());

    final screen = widget as BeduerfnisantragStep3Screen;
    expect(screen.navigationParams.currentPage, BeduerfnisPage.step3);
  });

  testWidgets('step3 → step4 → BeduerfnisantragStep4Screen', (tester) async {
    final widget = await buildNextPage(
      tester,
      baseParams(BeduerfnisPage.step3),
    );

    expect(widget, isA<BeduerfnisantragStep4Screen>());

    final screen = widget as BeduerfnisantragStep4Screen;
    expect(screen.navigationParams.currentPage, BeduerfnisPage.step4);
  });

  testWidgets('step4 → step5 → BeduerfnisantragStep5Screen', (tester) async {
    final widget = await buildNextPage(
      tester,
      baseParams(BeduerfnisPage.step4),
    );

    expect(widget, isA<BeduerfnisantragStep5Screen>());

    final screen = widget as BeduerfnisantragStep5Screen;
    expect(screen.navigationParams.currentPage, BeduerfnisPage.step5);
  });

  testWidgets('step5 → default → step2 → BeduerfnisantragStep2Screen', (
    tester,
  ) async {
    final widget = await buildNextPage(
      tester,
      baseParams(BeduerfnisPage.step5),
    );

    // getNextStep default branch returns step2
    expect(widget, isA<BeduerfnisantragStep2Screen>());

    final screen = widget as BeduerfnisantragStep2Screen;
    expect(screen.navigationParams.currentPage, BeduerfnisPage.step2);
  });
}
