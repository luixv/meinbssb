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
  /// Returns the next step enum for the beduerfnis process
  BeduerfnisPage getNextStep(BeduerfnisNavigationParams params) {
    switch (params.currentPage) {
      case BeduerfnisPage.step1:
        return BeduerfnisPage.step2;
      case BeduerfnisPage.step2:
        return BeduerfnisPage.step3;
      case BeduerfnisPage.step3:
        return BeduerfnisPage.step4;
      case BeduerfnisPage.step4:
        return BeduerfnisPage.step5;
      default:
        return BeduerfnisPage.step2; // This line is retained for context
    }
  }

  /// Returns the next MaterialPageRoute for the beduerfnis process
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
    final nextPage = getNextStep(navigationParams);
    final nextParams = navigationParams.copyWith(currentPage: nextPage);

    switch (nextPage) {
      case BeduerfnisPage.step1:
        return MaterialPageRoute(
          builder:
              (_) => BeduerfnisantragStep1Screen(
                userData: userData!,
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
                userData: userData!,
                antrag: antrag,
                isLoggedIn: isLoggedIn,
                onLogout: onLogout ?? () {},
                readOnly: readOnly,
                userRole: userRole,
                navigationParams: nextParams,
              ),
        );
      case BeduerfnisPage.step3:
        return MaterialPageRoute(
          builder:
              (_) => BeduerfnisantragStep3Screen(
                userData: userData!,
                antrag: antrag,
                isLoggedIn: isLoggedIn,
                onLogout: onLogout ?? () {},
                readOnly: readOnly,
                userRole: userRole,
                navigationParams: nextParams,
              ),
        );
      case BeduerfnisPage.step4:
        return MaterialPageRoute(
          builder:
              (_) => BeduerfnisantragStep4Screen(
                userData: userData!,
                antrag: antrag,
                isLoggedIn: isLoggedIn,
                onLogout: onLogout ?? () {},
                readOnly: readOnly,
                userRole: userRole,
                navigationParams: nextParams,
              ),
        );
      case BeduerfnisPage.step5:
        return MaterialPageRoute(
          builder:
              (_) => BeduerfnisantragStep5Screen(
                userData: userData!,
                antrag: antrag,
                isLoggedIn: isLoggedIn,
                onLogout: onLogout ?? () {},
                readOnly: readOnly,
                userRole: userRole,
                navigationParams: nextParams,
              ),
        );
    }
  }
}
