import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_data.dart';
import 'package:meinbssb/services/api/workflow_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import '/widgets/keyboard_focus_fab.dart';

class BeduerfnissantragStep3Screen extends StatefulWidget {
  const BeduerfnissantragStep3Screen({
    this.userData,
    this.antrag,
    required this.isLoggedIn,
    required this.onLogout,
    required this.userRole,
    super.key,
  });

  final UserData? userData;
  final BeduerfnisseAntrag? antrag;
  final bool isLoggedIn;
  final Function() onLogout;
  final WorkflowRole userRole;

  @override
  State<BeduerfnissantragStep3Screen> createState() =>
      _BeduerfnissantragStep3ScreenState();
}

class _BeduerfnissantragStep3ScreenState
    extends State<BeduerfnissantragStep3Screen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return Semantics(
          container: true,
          liveRegion: true,
          label: 'Bedürfnisbescheinigung - Schritt 3',
          child: BaseScreenLayout(
            title: 'Bedürfnisbescheinigung - Schritt 3',
            userData: widget.userData,
            isLoggedIn: widget.isLoggedIn,
            onLogout: widget.onLogout,
            floatingActionButton: SizedBox(
              width: MediaQuery.of(context).size.width - 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (FAB)
                  KeyboardFocusFAB(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icons.arrow_back,
                    heroTag: 'fab_back_step3',
                  ),
                ],
              ),
            ),
            body: Padding(
              padding: UIConstants.screenPadding,
              child: Center(
                child: ScaledText(
                  'Schritt 3 Platzhalter',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
