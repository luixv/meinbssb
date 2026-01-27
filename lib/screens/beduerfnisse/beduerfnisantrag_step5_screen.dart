import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import '/widgets/keyboard_focus_fab.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_data.dart';
import 'beduerfnisantrag_step5_dialog_screen.dart';

import 'package:meinbssb/services/api/workflow_service.dart';

class BeduerfnisantragStep5Screen extends StatefulWidget {
  const BeduerfnisantragStep5Screen({
    super.key,
    this.userData,
    this.isLoggedIn = false,
    this.onLogout,
    this.antrag,
    this.userRole = WorkflowRole.mitglied,
    this.readOnly = false,
  });

  final dynamic userData;
  final bool isLoggedIn;
  final VoidCallback? onLogout;
  final BeduerfnisAntrag? antrag;
  final WorkflowRole userRole;
  final bool readOnly;

  @override
  State<BeduerfnisantragStep5Screen> createState() =>
      _BeduerfnisantragStep5ScreenState();
}

class _BeduerfnisantragStep5ScreenState
    extends State<BeduerfnisantragStep5Screen> {
  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Bedürfnisbescheinigung',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout ?? () {},
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width - 32,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                KeyboardFocusFAB(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icons.arrow_back,
                  heroTag: 'fab_back_step5',
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Only show add button when not in read-only mode
                if (!widget.readOnly)
                  KeyboardFocusFAB(
                    heroTag: 'addStep5DialogFab',
                    tooltip: 'Dokument hinzufügen',
                    semanticLabel: 'Dokument hinzufügen Button',
                    semanticHint: 'Neues Dokument für WBK/Wettkampf hinzufügen',
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder:
                            (context) => BeduerfnisantragStep5DialogScreen(
                              antragsnummer: widget.antrag?.antragsnummer,
                            ),
                      );
                    },
                    icon: Icons.add,
                  ),
                if (!widget.readOnly)
                  const SizedBox(height: UIConstants.spacingS),
                KeyboardFocusFAB(
                  heroTag: 'nextFromStep5Fab',
                  tooltip: 'Weiter',
                  semanticLabel: 'Weiter Button',
                  semanticHint: 'Weiter zum nächsten Schritt',
                  onPressed: () {
                    // TODO: Implement navigation to step 6 or finish
                  },
                  icon: Icons.arrow_forward,
                ),
              ],
            ),
          ],
        ),
      ),
      body: Semantics(
        label: 'Bedürfnisbescheinigung Schritt 5',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UIConstants.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                label: 'Bedürfnisbescheinigung',
                child: ScaledText(
                  'Bedürfnisbescheinigung',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color.fromRGBO(11, 75, 16, 1),
                  ),
                ),
              ),
              const SizedBox(height: UIConstants.spacingM),

              Consumer<FontSizeProvider>(
                builder:
                    (context, fontSizeProvider, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScaledText(
                          'Wettkampfteilnahme',
                          style: UIStyles.titleStyle.copyWith(
                            fontSize:
                                UIStyles.titleStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingS),
                        const ScaledText(
                          'Grundsätzlich müssen zwei Wettkämpfe mit der beantragten Waffenart in den letzten 24 Monaten geschossen worden sein. Die Teilnahme kann durch Urkunden, Ergebnislisten, usw. belegt werden. Alternativ können Sie die Daten manuell erfassen.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
              ),
              const SizedBox(height: UIConstants.spacingXXXL),
            ],
          ),
        ),
      ),
    );
  }
}
