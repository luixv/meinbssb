import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_status_data.dart';
import 'package:meinbssb/models/beduerfnisse_sport_data.dart';
import 'package:meinbssb/models/beduerfnisse_auswahl_data.dart';
import 'package:meinbssb/models/disziplin_data.dart';
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
    this.readOnly = false,
    super.key,
  });

  final UserData? userData;
  final BeduerfnisseAntrag? antrag;
  final bool isLoggedIn;
  final Function() onLogout;
  final WorkflowRole userRole;
  final bool readOnly;

  @override
  State<BeduerfnissantragStep2Screen> createState() =>
      _BeduerfnissantragStep2ScreenState();
}

class _BeduerfnissantragStep2ScreenState
    extends State<BeduerfnissantragStep2Screen> {
  late Future<List<BeduerfnisseSport>> _bedSportFuture;
  late Future<List<BeduerfnisseAuswahl>> _waffenartFuture;
  late Future<List<BeduerfnisseAuswahl>> _wettkampfartFuture;
  late Future<List<Disziplin>> _disziplinenFuture;

  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    _bedSportFuture = _fetchBedSportData();
    _waffenartFuture = apiService.getBedAuswahlByTypId(1);
    _wettkampfartFuture = apiService.getBedAuswahlByTypId(2);
    _disziplinenFuture = apiService.fetchDisziplinen();
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

  Future<void> _deleteBedSport(int? sportId) async {
    if (sportId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler: ID nicht gefunden')),
        );
      }
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: UIConstants.backgroundColor,
          title: const Center(
            child: Text('Nachweis löschen', style: UIStyles.dialogTitleStyle),
          ),
          content: RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: UIStyles.dialogContentStyle,
              children: <TextSpan>[
                TextSpan(text: 'Möchten Sie diesen Nachweis wirklich löschen?'),
              ],
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.spacingM,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: UIStyles.dialogCancelButtonStyle,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.close, color: UIConstants.closeIcon),
                        UIConstants.horizontalSpacingS,
                        const Text('Abbrechen'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: UIStyles.dialogAcceptButtonStyle,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check, color: UIConstants.checkIcon),
                        UIConstants.horizontalSpacingS,
                        const Text('Löschen'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final success = await apiService.deleteBedSportById(sportId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nachweis erfolgreich gelöscht')),
          );
          setState(() {
            _bedSportFuture = _fetchBedSportData();
          });
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Fehler beim Löschen')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler beim Löschen: $e')));
      }
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
                crossAxisAlignment: CrossAxisAlignment.end,
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Only show add button when not in read-only mode
                      if (!widget.readOnly)
                        KeyboardFocusFAB(
                          heroTag: 'addBedSportFab',
                          tooltip: 'Hinzufügen',
                          semanticLabel: 'Hinzufügen Button',
                          semanticHint: 'Neue Schießaktivität hinzufügen',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (
                                    context,
                                  ) => BeduerfnissantragStep2DialogScreen(
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
                      if (!widget.readOnly)
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
                      FutureBuilder(
                        future: Future.wait([
                          _bedSportFuture,
                          _waffenartFuture,
                          _wettkampfartFuture,
                          _disziplinenFuture,
                        ]),
                        builder: (
                          context,
                          AsyncSnapshot<List<dynamic>> snapshot,
                        ) {
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

                          final bedSportList =
                              (snapshot.data?[0] as List<BeduerfnisseSport>?) ??
                              [];
                          final waffenartList =
                              (snapshot.data?[1]
                                  as List<BeduerfnisseAuswahl>?) ??
                              [];
                          final wettkampfartList =
                              (snapshot.data?[2]
                                  as List<BeduerfnisseAuswahl>?) ??
                              [];
                          final disziplinList =
                              (snapshot.data?[3] as List<Disziplin>?) ?? [];

                          // Create lookup maps
                          final waffenartMap = {
                            for (var w in waffenartList) w.id: w.beschreibung,
                          };
                          final wettkampfartMap = {
                            for (var w in wettkampfartList)
                              w.id: w.beschreibung,
                          };
                          final disziplinMap = {
                            for (var d in disziplinList)
                              d.disziplinId: d.disziplinNr,
                          };

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
                                final waffenartName =
                                    waffenartMap[sport.waffenartId] ??
                                    'Unbekannt';
                                final disziplinName =
                                    disziplinMap[sport.disziplinId] ??
                                    'Unbekannt';
                                final wettkampfartName =
                                    sport.wettkampfartId != null
                                        ? wettkampfartMap[sport
                                                .wettkampfartId] ??
                                            'Unbekannt'
                                        : null;

                                return Card(
                                  margin: const EdgeInsets.only(
                                    bottom: UIConstants.spacingM,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      UIConstants.spacingM,
                                    ),
                                    child: Stack(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ScaledText(
                                              'Datum: ${DateFormat('dd.MM.yyyy').format(sport.schiessdatum)}',
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
                                              'Waffenart: $waffenartName',
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
                                              'Disziplin: $disziplinName',
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
                                            if (wettkampfartName != null)
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(
                                                    height:
                                                        UIConstants.spacingS,
                                                  ),
                                                  ScaledText(
                                                    'Wettkampfart: $wettkampfartName',
                                                    style: UIStyles
                                                        .bodyTextStyle
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
                                                    height:
                                                        UIConstants.spacingS,
                                                  ),
                                                  ScaledText(
                                                    'Wettkampfergebnis: ${sport.wettkampfergebnis}',
                                                    style: UIStyles
                                                        .bodyTextStyle
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
                                                    height:
                                                        UIConstants.spacingS,
                                                  ),
                                                  ScaledText(
                                                    'Bemerkung: ${sport.bemerkung}',
                                                    style: UIStyles
                                                        .bodyTextStyle
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
                                        // Delete icon - only show if status is Entwurf and not read-only
                                        if (!widget.readOnly &&
                                            widget.antrag?.statusId ==
                                                BeduerfnisAntragStatus.entwurf)
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: UIConstants.deleteIcon,
                                              ),
                                              tooltip: 'Löschen',
                                              onPressed: () {
                                                _deleteBedSport(sport.id);
                                              },
                                            ),
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

    // In read-only mode, just navigate without updating status
    if (widget.readOnly) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BeduerfnissantragStep3Screen(
                  userData: widget.userData,
                  antrag: widget.antrag,
                  isLoggedIn: widget.isLoggedIn,
                  onLogout: widget.onLogout,
                  userRole: widget.userRole,
                  readOnly: widget.readOnly,
                ),
          ),
        );
      }
      return;
    }

    // Get current antrag status
    final currentStatus =
        widget.antrag!.statusId ?? BeduerfnisAntragStatus.entwurf;
    final nextStatus = BeduerfnisAntragStatus.eingereichtAmVerein;

    // If status is "Entwurf", show confirmation dialog
    if (currentStatus == BeduerfnisAntragStatus.entwurf) {
      bool? confirmSubmit = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            backgroundColor: UIConstants.backgroundColor,
            title: const Center(
              child: Text(
                'Antrag einreichen',
                style: UIStyles.dialogTitleStyle,
              ),
            ),
            content: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: UIStyles.dialogContentStyle,
                children: <TextSpan>[
                  TextSpan(
                    text:
                        'Sind Sie sicher, dass Sie diesen Antrag stellen wollen?',
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.spacingM,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: UIConstants.defaultButtonHeight,
                      ),
                      child: Semantics(
                        label: 'Abbrechen Button',
                        hint: 'Dialog schließen und Antrag nicht einreichen',
                        button: true,
                        child: ElevatedButton(
                          onPressed:
                              () => Navigator.of(dialogContext).pop(false),
                          style: UIStyles.dialogCancelButtonStyle.copyWith(
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                horizontal: UIConstants.spacingM,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.close,
                                color: UIConstants.closeIcon,
                                size: UIConstants.defaultIconSize,
                              ),
                              const SizedBox(width: UIConstants.spacingS),
                              Text(
                                'Abbrechen',
                                style: UIStyles.dialogButtonTextStyle.copyWith(
                                  color: UIConstants.cancelButtonText,
                                  fontSize: UIConstants.buttonFontSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingM),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: UIConstants.defaultButtonHeight,
                      ),
                      child: Semantics(
                        label: 'Einreichen Button',
                        hint: 'Antrag einreichen',
                        button: true,
                        child: ElevatedButton(
                          onPressed:
                              () => Navigator.of(dialogContext).pop(true),
                          style: UIStyles.dialogAcceptButtonStyle.copyWith(
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                vertical: UIConstants.spacingS,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check,
                                color: UIConstants.checkIcon,
                                size: UIConstants.defaultIconSize,
                              ),
                              const SizedBox(width: UIConstants.spacingS),
                              Text(
                                'Einreichen',
                                style: UIStyles.dialogButtonTextStyle.copyWith(
                                  color: UIConstants.submitButtonText,
                                  fontSize: UIConstants.buttonFontSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );

      // If user cancelled, return early
      if (confirmSubmit != true) {
        return;
      }
    }

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
                  readOnly: widget.readOnly,
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
