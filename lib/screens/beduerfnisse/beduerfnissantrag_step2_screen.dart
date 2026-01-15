import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_status_data.dart';
import 'package:meinbssb/models/beduerfnisse_sport_data.dart';
import 'package:meinbssb/services/api/workflow_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnissantrag_step3_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import '/widgets/keyboard_focus_fab.dart';
import 'beduerfnissantrag_step2_dialog_screen.dart';

class BeduerfnissantragStep2Screen extends StatefulWidget {
  const BeduerfnissantragStep2Screen({
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
  State<BeduerfnissantragStep2Screen> createState() =>
      _BeduerfnissantragStep2ScreenState();
}

class _BeduerfnissantragStep2ScreenState
    extends State<BeduerfnissantragStep2Screen> {
  late Future<List<BeduerfnisseSport>> _bedSportFuture;

  @override
  void initState() {
    super.initState();
    _bedSportFuture = _fetchBedSportData();
  }

  Future<List<BeduerfnisseSport>> _fetchBedSportData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    if (widget.antrag?.antragsnummer == null) {
      return [];
    }
    try {
      final antragsnummer = widget.antrag!.antragsnummer;
      if (antragsnummer == null) {
        return [];
      }
      return await apiService.getBedSportByAntragsnummer(antragsnummer);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden der Daten: $e')),
        );
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return Semantics(
          container: true,
          liveRegion: true,
          label:
              'Bedürfnisbescheinigung - Nachweis der Sportschützeneigenschaft',
          child: BaseScreenLayout(
            title: 'Bedürfnisbescheinigung',
            userData: widget.userData,
            isLoggedIn: widget.isLoggedIn,
            onLogout: widget.onLogout,
            floatingActionButton: SizedBox(
              width: MediaQuery.of(context).size.width - 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      KeyboardFocusFAB(
                        heroTag: 'backFromStep2Fab',
                        tooltip: 'Zurück',
                        semanticLabel: 'Zurück Button',
                        semanticHint: 'Zurück zur vorherigen Seite',
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        icon: Icons.arrow_back,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      KeyboardFocusFAB(
                        heroTag: 'addBedSportFab',
                        tooltip: 'Hinzufügen',
                        semanticLabel: 'Hinzufügen Button',
                        semanticHint: 'Neue Schießaktivität hinzufügen',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => BeduerfnissantragStep2DialogScreen(
                                  antragsnummer: widget.antrag?.antragsnummer,
                                  onSaved: (savedData) {
                                    // Small delay to ensure data is persisted
                                    Future.delayed(
                                      const Duration(milliseconds: 500),
                                      () {
                                        if (mounted) {
                                          setState(() {
                                            _bedSportFuture =
                                                _fetchBedSportData();
                                          });
                                        }
                                      },
                                    );
                                  },
                                ),
                          ).then((result) {
                            if (result != null &&
                                result is Map<String, dynamic>) {
                              if (result.containsKey('error')) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['error'] as String),
                                  ),
                                );
                              } else if (result.containsKey('success')) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Schießaktivität hinzugefügt',
                                    ),
                                  ),
                                );
                              }
                            }
                          });
                        },
                        icon: Icons.add,
                      ),
                      const SizedBox(height: UIConstants.spacingS),
                      KeyboardFocusFAB(
                        heroTag: 'nextFromStep2Fab',
                        tooltip: 'Weiter',
                        semanticLabel: 'Weiter Button',
                        semanticHint: 'Weiter zum nächsten Schritt',
                        onPressed: () {
                          _continueToNextStep();
                        },
                        icon: Icons.arrow_forward,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            body: Focus(
              autofocus: true,
              child: Semantics(
                label:
                    'Nachweis der Sportschützeneigenschaft. Hier können Sie die notwendigen Nachweise hochladen.',
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(UIConstants.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle
                      Semantics(
                        header: true,
                        label: 'Nachweis der Sportschützeneigenschaft',
                        child: ScaledText(
                          'Nachweis der Sportschützeneigenschaft',
                          style: UIStyles.headerStyle.copyWith(
                            fontSize:
                                UIStyles.headerStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                          ),
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Bed Sport Data
                      FutureBuilder<List<BeduerfnisseSport>>(
                        future: _bedSportFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return ScaledText(
                              'Fehler beim Laden: ${snapshot.error}',
                              style: UIStyles.bodyTextStyle.copyWith(
                                color: UIConstants.errorColor,
                              ),
                            );
                          }

                          final bedSportList = snapshot.data ?? [];
                          if (bedSportList.isEmpty) {
                            return ScaledText(
                              'Keine Schießdaten vorhanden.',
                              style: UIStyles.bodyTextStyle.copyWith(
                                fontSize:
                                    UIStyles.bodyTextStyle.fontSize! *
                                    fontSizeProvider.scaleFactor,
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ScaledText(
                                'Registrierte Schießaktivitäten:',
                                style: UIStyles.formLabelStyle.copyWith(
                                  fontSize:
                                      UIStyles.formLabelStyle.fontSize! *
                                      fontSizeProvider.scaleFactor,
                                ),
                              ),
                              const SizedBox(height: UIConstants.spacingM),
                              ...bedSportList.map((sport) {
                                return Card(
                                  margin: const EdgeInsets.only(
                                    bottom: UIConstants.spacingM,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      UIConstants.spacingM,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ScaledText(
                                          'Schießdatum: ${sport.schiessdatum.toString().split(' ')[0]}',
                                          style: UIStyles.bodyTextStyle
                                              .copyWith(
                                                fontSize:
                                                    UIStyles
                                                        .bodyTextStyle
                                                        .fontSize! *
                                                    fontSizeProvider
                                                        .scaleFactor,
                                              ),
                                        ),
                                        const SizedBox(
                                          height: UIConstants.spacingS,
                                        ),
                                        ScaledText(
                                          'Waffenart ID: ${sport.waffenartId}',
                                          style: UIStyles.bodyTextStyle
                                              .copyWith(
                                                fontSize:
                                                    UIStyles
                                                        .bodyTextStyle
                                                        .fontSize! *
                                                    fontSizeProvider
                                                        .scaleFactor,
                                              ),
                                        ),
                                        const SizedBox(
                                          height: UIConstants.spacingS,
                                        ),
                                        ScaledText(
                                          'Disziplin ID: ${sport.disziplinId}',
                                          style: UIStyles.bodyTextStyle
                                              .copyWith(
                                                fontSize:
                                                    UIStyles
                                                        .bodyTextStyle
                                                        .fontSize! *
                                                    fontSizeProvider
                                                        .scaleFactor,
                                              ),
                                        ),
                                        const SizedBox(
                                          height: UIConstants.spacingS,
                                        ),
                                        ScaledText(
                                          'Training: ${sport.training ? 'Ja' : 'Nein'}',
                                          style: UIStyles.bodyTextStyle
                                              .copyWith(
                                                fontSize:
                                                    UIStyles
                                                        .bodyTextStyle
                                                        .fontSize! *
                                                    fontSizeProvider
                                                        .scaleFactor,
                                              ),
                                        ),
                                        if (sport.wettkampfartId != null)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: UIConstants.spacingS,
                                              ),
                                              ScaledText(
                                                'Wettkampfart ID: ${sport.wettkampfartId}',
                                                style: UIStyles.bodyTextStyle
                                                    .copyWith(
                                                      fontSize:
                                                          UIStyles
                                                              .bodyTextStyle
                                                              .fontSize! *
                                                          fontSizeProvider
                                                              .scaleFactor,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        if (sport.wettkampfergebnis != null)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: UIConstants.spacingS,
                                              ),
                                              ScaledText(
                                                'Wettkampfergebnis: ${sport.wettkampfergebnis}',
                                                style: UIStyles.bodyTextStyle
                                                    .copyWith(
                                                      fontSize:
                                                          UIStyles
                                                              .bodyTextStyle
                                                              .fontSize! *
                                                          fontSizeProvider
                                                              .scaleFactor,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        if (sport.bemerkung != null)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: UIConstants.spacingS,
                                              ),
                                              ScaledText(
                                                'Bemerkung: ${sport.bemerkung}',
                                                style: UIStyles.bodyTextStyle
                                                    .copyWith(
                                                      fontSize:
                                                          UIStyles
                                                              .bodyTextStyle
                                                              .fontSize! *
                                                          fontSizeProvider
                                                              .scaleFactor,
                                                    ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: UIConstants.spacingXXXL2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _continueToNextStep() async {
    // Check if antrag exists
    if (widget.antrag == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler: Antrag nicht gefunden')),
        );
      }
      return;
    }

    // Get current antrag status
    final currentStatus =
        widget.antrag!.statusId ?? BeduerfnisAntragStatus.entwurf;
    final nextStatus = BeduerfnisAntragStatus.eingereichtAmVerein;

    // Check if workflow transition is allowed
    final workflowService = WorkflowService();
    final canTransition = workflowService.canAntragChangeFromStateToState(
      currentState: currentStatus,
      nextState: nextStatus,
      userRole: widget.userRole,
    );

    if (!canTransition) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sie haben keine Berechtigung für diese Aktion'),
          ),
        );
      }
      return;
    }

    // Update antrag status
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final updatedAntrag = widget.antrag!.copyWith(statusId: nextStatus);

      await apiService.updateBedAntrag(updatedAntrag);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BeduerfnissantragStep3Screen(
                  userData: widget.userData,
                  antrag: updatedAntrag,
                  isLoggedIn: widget.isLoggedIn,
                  onLogout: widget.onLogout,
                  userRole: widget.userRole,
                ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Aktualisieren: $e')),
        );
      }
    }
  }
}
