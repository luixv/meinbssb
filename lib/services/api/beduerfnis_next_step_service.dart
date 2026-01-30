import 'package:flutter/material.dart';
import 'package:meinbssb/models/beduerfnis_navigation_params.dart';
import 'package:meinbssb/models/beduerfnis_page.dart';
import 'package:meinbssb/models/beduerfnis_antrag_data.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/api/workflow_service.dart';

import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step1_screen.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step2_screen.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step3_screen.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step4_screen.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step5_screen.dart';

class BeduerfnisNextStepService {
  /// Pure business logic: given the current page, return the next one.
  BeduerfnisPage getNextStep(BeduerfnisPage currentPage) {
    switch (currentPage) {
      case BeduerfnisPage.step1:
        return BeduerfnisPage.step2;
      case BeduerfnisPage.step2:
        return BeduerfnisPage.step3;
      case BeduerfnisPage.step3:
        return BeduerfnisPage.step4;
      case BeduerfnisPage.step4:
        return BeduerfnisPage.step5;
      // default / last step → fallback
      case BeduerfnisPage.step5:
        return BeduerfnisPage.step2;
    }
  }

  /// UI layer: builds the route for a given step and navigation params.
  MaterialPageRoute buildRouteForStep({
    required BeduerfnisPage step,
    required UserData userData,
    required BeduerfnisAntrag antrag,
    required bool isLoggedIn,
    required void Function()? onLogout,
    required WorkflowRole userRole,
    required bool readOnly,
    required BeduerfnisNavigationParams navigationParams,
  }) {
    switch (step) {
      case BeduerfnisPage.step1:
        return MaterialPageRoute(
          builder:
              (_) => BeduerfnisantragStep1Screen(
                userData: userData,
                antrag: antrag,
                isLoggedIn: isLoggedIn,
                onLogout: onLogout ?? () {},
                readOnly: readOnly,
              ),
        );
      case BeduerfnisPage.step2:
        return MaterialPageRoute(
          builder:
              (_) => BeduerfnisantragStep2Screen(
                userData: userData,
                antrag: antrag,
                isLoggedIn: isLoggedIn,
                onLogout: onLogout ?? () {},
                readOnly: readOnly,
                userRole: userRole,
                navigationParams: navigationParams,
              ),
        );
      case BeduerfnisPage.step3:
        return MaterialPageRoute(
          builder:
              (_) => BeduerfnisantragStep3Screen(
                userData: userData,
                antrag: antrag,
                isLoggedIn: isLoggedIn,
                onLogout: onLogout ?? () {},
                readOnly: readOnly,
                userRole: userRole,
                navigationParams: navigationParams,
              ),
        );
      case BeduerfnisPage.step4:
        return MaterialPageRoute(
          builder:
              (_) => BeduerfnisantragStep4Screen(
                userData: userData,
                antrag: antrag,
                isLoggedIn: isLoggedIn,
                onLogout: onLogout ?? () {},
                readOnly: readOnly,
                userRole: userRole,
                navigationParams: navigationParams,
              ),
        );
      case BeduerfnisPage.step5:
        return MaterialPageRoute(
          builder:
              (_) => BeduerfnisantragStep5Screen(
                userData: userData,
                antrag: antrag,
                isLoggedIn: isLoggedIn,
                onLogout: onLogout ?? () {},
                readOnly: readOnly,
                userRole: userRole,
                navigationParams: navigationParams,
              ),
        );
    }
  }

  /// Orchestrator: compute next step + params, then build the route.
  MaterialPageRoute getNextStepRoute({
    required BuildContext context,
    required UserData? userData,
    required BeduerfnisAntrag antrag,
    required bool isLoggedIn,
    required void Function()? onLogout,
    required WorkflowRole userRole,
    required bool readOnly,
    required BeduerfnisNavigationParams navigationParams,
  }) {
    final nextStep = getNextStep(navigationParams.currentPage);
    final nextParams = navigationParams.copyWith(currentPage: nextStep);

    return buildRouteForStep(
      step: nextStep,
      userData: userData!,
      antrag: antrag,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
      userRole: userRole,
      readOnly: readOnly,
      navigationParams: nextParams,
    );
  }
}
