import 'package:meinbssb/widgets/delete_confirm_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_status_data.dart';
import 'package:meinbssb/models/beduerfnisse_sport_data.dart';
import 'package:meinbssb/models/beduerfnisse_datei_data.dart';
import 'package:meinbssb/models/beduerfnisse_auswahl_data.dart';
import 'package:meinbssb/models/disziplin_data.dart';
import 'package:meinbssb/services/api/workflow_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step3_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import '/widgets/keyboard_focus_fab.dart';
import 'beduerfnisantrag_step2_dialog_screen.dart';

class BeduerfnisantragStep2Screen extends StatefulWidget {
  const BeduerfnisantragStep2Screen({
    this.userData,
    this.antrag,
    required this.isLoggedIn,
    required this.onLogout,
    required this.userRole,
    this.readOnly = false,
    super.key,
  });

  final UserData? userData;
  final BeduerfnisAntrag? antrag;
  final bool isLoggedIn;
  final Function() onLogout;
  final WorkflowRole userRole;
  final bool readOnly;

  @override
  State<BeduerfnisantragStep2Screen> createState() =>
      _BeduerfnisantragStep2ScreenState();
}

class _BeduerfnisantragStep2ScreenState
    extends State<BeduerfnisantragStep2Screen> {
  late Future<List<BeduerfnisSport>> _bedSportFuture;
  late Future<List<BeduerfnisAuswahl>> _waffenartFuture;
  late Future<List<BeduerfnisAuswahl>> _wettkampfartFuture;
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

  Future<List<BeduerfnisSport>> _fetchBedSportData() async {
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

  void _viewDocument(BuildContext context, BeduerfnisDatei document) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => Dialog(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: UIConstants.defaultAppColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.description, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ScaledText(
                            document.dateiname,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: 'Dokument schließen',
                          hint:
                              'Doppeltippen um die Dokumentansicht zu schließen',
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Document content
                  Expanded(
                    child: Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: InteractiveViewer(
                          panEnabled: true,
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: Image.memory(
                            Uint8List.fromList(document.fileBytes),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 16),
                                  ScaledText(
                                    'Dokument kann nicht angezeigt werden',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ScaledText(
                                    'Dateiformat wird nicht unterstützt',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Fehler'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteBedSport(int? sportId) async {
    if (sportId == null) {
      showDialog(
        context: context,
        builder:
            (dialogContext) => DeleteConfirmDialog(
              title: 'Fehler',
              message: 'ID nicht gefunden',
              onCancel: () => Navigator.of(dialogContext).pop(),
              onDelete: () => Navigator.of(dialogContext).pop(),
            ),
      );
      return;
    }

    // Show MeinBSSB confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => DeleteConfirmDialog(
            title: 'Nachweis löschen',
            message: 'Möchten Sie diesen Nachweis wirklich löschen?',
            onCancel: () => Navigator.of(dialogContext).pop(false),
            onDelete: () => Navigator.of(dialogContext).pop(true),
          ),
    );

    if (confirmed != true) return;

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final success = await apiService.deleteBedSportById(sportId);

      if (success) {
        // Just refresh the data, no success dialog
        if (mounted) {
          setState(() {
            _bedSportFuture = _fetchBedSportData();
          });
        }
      } else {
        // Show MeinBSSB-styled error dialog
        await showDialog(
          context: context,
          builder:
              (dialogContext) => DeleteConfirmDialog(
                title: 'Fehler',
                message: 'Fehler beim Löschen des Nachweises.',
                onCancel: () => Navigator.of(dialogContext).pop(),
                onDelete: () => Navigator.of(dialogContext).pop(),
              ),
        );
      }
    } catch (e) {
      await showDialog(
        context: context,
        builder:
            (dialogContext) => DeleteConfirmDialog(
              title: 'Fehler',
              message: 'Fehler beim Löschen: $e',
              onCancel: () => Navigator.of(dialogContext).pop(),
              onDelete: () => Navigator.of(dialogContext).pop(),
            ),
      );
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
          hint:
              'Zweiter Schritt der Antragstellung. Fügen Sie Nachweise Ihrer Schießaktivitäten hinzu',
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
                      Semantics(
                        button: true,
                        enabled: true,
                        label: 'Zurück zu Schritt 1',
                        hint:
                            'Doppeltippen um zum vorherigen Schritt zurückzukehren',
                        child: KeyboardFocusFAB(
                          heroTag: 'backFromStep2Fab',
                          tooltip: 'Zurück',
                          semanticLabel: 'Zurück Button',
                          semanticHint: 'Zurück zur vorherigen Seite',
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          icon: Icons.arrow_back,
                        ),
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
                                  ) => BeduerfnisantragStep2DialogScreen(
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
                              (snapshot.data?[0] as List<BeduerfnisSport>?) ??
                              [];
                          final waffenartList =
                              (snapshot.data?[1] as List<BeduerfnisAuswahl>?) ??
                              [];
                          final wettkampfartList =
                              (snapshot.data?[2] as List<BeduerfnisAuswahl>?) ??
                              [];
                          final disziplinList =
                              (snapshot.data?[3] as List<Disziplin>?) ?? [];

                          // Create lookup maps
                          final waffenartMap = {
                            for (var w in waffenartList) w.id: w.beschreibung,
                          };
                          final wettkampfartMap = {
                            for (var w in wettkampfartList) w.id: w.kuerzel,
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
                              Semantics(
                                header: true,
                                label: 'Registrierte Schießaktivitäten',
                                hint:
                                    '${bedSportList.length} Einträge gefunden',
                                child: ScaledText(
                                  'Registrierte Schießaktivitäten:',
                                  style: UIStyles.formLabelStyle.copyWith(
                                    fontSize:
                                        UIStyles.formLabelStyle.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
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

                                return Semantics(
                                  label:
                                      'Schießaktivität vom ${DateFormat('dd.MM.yyyy').format(sport.schiessdatum)}: $waffenartName, Disziplin $disziplinName${sport.training ? ', Training' : ''}${wettkampfartName != null ? ', Wettkampfart: $wettkampfartName' : ''}',
                                  hint:
                                      'Details zur Schießaktivität${!widget.readOnly && widget.antrag?.statusId == BeduerfnisAntragStatus.entwurf ? '. Aktionen verfügbar' : ''}',
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Card(
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
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Left column
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Tooltip(
                                                                message:
                                                                    'Datum',
                                                                child: Icon(
                                                                  Icons
                                                                      .calendar_today,
                                                                  size:
                                                                      UIConstants
                                                                          .iconSizeS *
                                                                      fontSizeProvider
                                                                          .scaleFactor,
                                                                  color:
                                                                      UIConstants
                                                                          .primaryColor,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width:
                                                                    UIConstants
                                                                        .spacingS,
                                                              ),
                                                              Flexible(
                                                                child: ScaledText(
                                                                  DateFormat(
                                                                    'dd.MM.yyyy',
                                                                  ).format(
                                                                    sport
                                                                        .schiessdatum,
                                                                  ),
                                                                  style: UIStyles.bodyTextStyle.copyWith(
                                                                    fontSize:
                                                                        UIStyles
                                                                            .bodyTextStyle
                                                                            .fontSize! *
                                                                        fontSizeProvider
                                                                            .scaleFactor,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height:
                                                                UIConstants
                                                                    .spacingS,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Tooltip(
                                                                message:
                                                                    'Disziplin',
                                                                child: Icon(
                                                                  Icons
                                                                      .category,
                                                                  size:
                                                                      UIConstants
                                                                          .iconSizeS *
                                                                      fontSizeProvider
                                                                          .scaleFactor,
                                                                  color:
                                                                      UIConstants
                                                                          .primaryColor,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width:
                                                                    UIConstants
                                                                        .spacingS,
                                                              ),
                                                              Flexible(
                                                                child: ScaledText(
                                                                  disziplinName,
                                                                  style: UIStyles.bodyTextStyle.copyWith(
                                                                    fontSize:
                                                                        UIStyles
                                                                            .bodyTextStyle
                                                                            .fontSize! *
                                                                        fontSizeProvider
                                                                            .scaleFactor,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height:
                                                                UIConstants
                                                                    .spacingS,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Tooltip(
                                                                message:
                                                                    'Training',
                                                                child: Icon(
                                                                  Icons
                                                                      .fitness_center,
                                                                  size:
                                                                      UIConstants
                                                                          .iconSizeS *
                                                                      fontSizeProvider
                                                                          .scaleFactor,
                                                                  color:
                                                                      UIConstants
                                                                          .primaryColor,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width:
                                                                    UIConstants
                                                                        .spacingS,
                                                              ),
                                                              Icon(
                                                                sport.training
                                                                    ? Icons
                                                                        .check
                                                                    : Icons
                                                                        .close,
                                                                color:
                                                                    sport.training
                                                                        ? UIConstants
                                                                            .defaultAppColor
                                                                        : Colors
                                                                            .red,
                                                                size:
                                                                    UIConstants
                                                                        .iconSizeS *
                                                                    fontSizeProvider
                                                                        .scaleFactor,
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width:
                                                          UIConstants
                                                              .spacingXXS,
                                                    ),
                                                    // Right column
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Tooltip(
                                                                message:
                                                                    'Waffenart',
                                                                child: Icon(
                                                                  Icons.adjust,
                                                                  size:
                                                                      UIConstants
                                                                          .iconSizeS *
                                                                      fontSizeProvider
                                                                          .scaleFactor,
                                                                  color:
                                                                      UIConstants
                                                                          .primaryColor,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width:
                                                                    UIConstants
                                                                        .spacingS,
                                                              ),
                                                              Flexible(
                                                                child: ScaledText(
                                                                  waffenartName,
                                                                  style: UIStyles.bodyTextStyle.copyWith(
                                                                    fontSize:
                                                                        UIStyles
                                                                            .bodyTextStyle
                                                                            .fontSize! *
                                                                        fontSizeProvider
                                                                            .scaleFactor,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          if (wettkampfartName !=
                                                              null) ...[
                                                            const SizedBox(
                                                              height:
                                                                  UIConstants
                                                                      .spacingS,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Tooltip(
                                                                  message:
                                                                      'Wettkampfart',
                                                                  child: Icon(
                                                                    Icons
                                                                        .emoji_events,
                                                                    size:
                                                                        UIConstants
                                                                            .iconSizeS *
                                                                        fontSizeProvider
                                                                            .scaleFactor,
                                                                    color:
                                                                        UIConstants
                                                                            .primaryColor,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width:
                                                                      UIConstants
                                                                          .spacingS,
                                                                ),
                                                                Flexible(
                                                                  child: ScaledText(
                                                                    wettkampfartName,
                                                                    style: UIStyles.bodyTextStyle.copyWith(
                                                                      fontSize:
                                                                          UIStyles
                                                                              .bodyTextStyle
                                                                              .fontSize! *
                                                                          fontSizeProvider
                                                                              .scaleFactor,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                          if (sport
                                                                  .wettkampfergebnis !=
                                                              null) ...[
                                                            const SizedBox(
                                                              height:
                                                                  UIConstants
                                                                      .spacingS,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Tooltip(
                                                                  message:
                                                                      'Wettkampfergebnis',
                                                                  child: Icon(
                                                                    Icons
                                                                        .leaderboard,
                                                                    size:
                                                                        UIConstants
                                                                            .iconSizeS *
                                                                        fontSizeProvider
                                                                            .scaleFactor,
                                                                    color:
                                                                        UIConstants
                                                                            .primaryColor,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width:
                                                                      UIConstants
                                                                          .spacingS,
                                                                ),
                                                                Flexible(
                                                                  child: ScaledText(
                                                                    '${sport.wettkampfergebnis}',
                                                                    style: UIStyles.bodyTextStyle.copyWith(
                                                                      fontSize:
                                                                          UIStyles
                                                                              .bodyTextStyle
                                                                              .fontSize! *
                                                                          fontSizeProvider
                                                                              .scaleFactor,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width:
                                                                      UIConstants
                                                                          .spacingS,
                                                                ),
                                                                // Document icon next to wettkampfergebnis
                                                                FutureBuilder<
                                                                  bool
                                                                >(
                                                                  future:
                                                                      sport.id !=
                                                                              null
                                                                          ? Provider.of<
                                                                            ApiService
                                                                          >(
                                                                            context,
                                                                            listen:
                                                                                false,
                                                                          ).hasBedDateiSport(
                                                                            sport.id!,
                                                                          )
                                                                          : Future.value(
                                                                            false,
                                                                          ),
                                                                  builder: (
                                                                    context,
                                                                    hasDocSnapshot,
                                                                  ) {
                                                                    if (hasDocSnapshot
                                                                            .connectionState ==
                                                                        ConnectionState
                                                                            .waiting) {
                                                                      return const SizedBox.shrink();
                                                                    }

                                                                    if (hasDocSnapshot
                                                                            .hasData &&
                                                                        hasDocSnapshot.data ==
                                                                            true) {
                                                                      return Semantics(
                                                                        button:
                                                                            true,
                                                                        label:
                                                                            'Dokument anzeigen',
                                                                        hint:
                                                                            'Doppeltippen um das hochgeladene Dokument anzuzeigen',
                                                                        child: Tooltip(
                                                                          message:
                                                                              'Dokument anzeigen',
                                                                          child: InkWell(
                                                                            onTap: () async {
                                                                              final apiService = Provider.of<
                                                                                ApiService
                                                                              >(
                                                                                context,
                                                                                listen:
                                                                                    false,
                                                                              );
                                                                              try {
                                                                                final doc = await apiService.getBedDateiBySportId(
                                                                                  sport.id!,
                                                                                );
                                                                                if (doc !=
                                                                                        null &&
                                                                                    context.mounted) {
                                                                                  _viewDocument(
                                                                                    context,
                                                                                    doc,
                                                                                  );
                                                                                } else if (context.mounted) {
                                                                                  _showErrorDialog(
                                                                                    'Dokument nicht gefunden.',
                                                                                  );
                                                                                }
                                                                              } catch (
                                                                                e
                                                                              ) {
                                                                                if (context.mounted) {
                                                                                  _showErrorDialog(
                                                                                    'Fehler beim Laden des Dokuments.',
                                                                                  );
                                                                                }
                                                                              }
                                                                            },
                                                                            child: Icon(
                                                                              Icons.remove_red_eye,
                                                                              size:
                                                                                  UIConstants.iconSizeS *
                                                                                  fontSizeProvider.scaleFactor,
                                                                              color:
                                                                                  UIConstants.primaryColor,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }

                                                                    return const SizedBox.shrink();
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                          // Document display for training entries without wettkampfergebnis
                                                          if (sport
                                                                  .wettkampfergebnis ==
                                                              null)
                                                            FutureBuilder<bool>(
                                                              future:
                                                                  sport.id !=
                                                                          null
                                                                      ? Provider.of<
                                                                        ApiService
                                                                      >(
                                                                        context,
                                                                        listen:
                                                                            false,
                                                                      ).hasBedDateiSport(
                                                                        sport
                                                                            .id!,
                                                                      )
                                                                      : Future.value(
                                                                        false,
                                                                      ),
                                                              builder: (
                                                                context,
                                                                hasDocSnapshot,
                                                              ) {
                                                                if (hasDocSnapshot
                                                                        .connectionState ==
                                                                    ConnectionState
                                                                        .waiting) {
                                                                  return const SizedBox.shrink();
                                                                }

                                                                if (hasDocSnapshot
                                                                        .hasData &&
                                                                    hasDocSnapshot
                                                                            .data ==
                                                                        true) {
                                                                  return Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      const SizedBox(
                                                                        height:
                                                                            UIConstants.spacingS,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Tooltip(
                                                                            message:
                                                                                'Dokument anzeigen',
                                                                            child: InkWell(
                                                                              onTap: () async {
                                                                                final apiService = Provider.of<
                                                                                  ApiService
                                                                                >(
                                                                                  context,
                                                                                  listen:
                                                                                      false,
                                                                                );
                                                                                try {
                                                                                  final doc = await apiService.getBedDateiBySportId(
                                                                                    sport.id!,
                                                                                  );
                                                                                  if (doc !=
                                                                                          null &&
                                                                                      context.mounted) {
                                                                                    _viewDocument(
                                                                                      context,
                                                                                      doc,
                                                                                    );
                                                                                  } else if (context.mounted) {
                                                                                    _showErrorDialog(
                                                                                      'Dokument nicht gefunden.',
                                                                                    );
                                                                                  }
                                                                                } catch (
                                                                                  e
                                                                                ) {
                                                                                  if (context.mounted) {
                                                                                    _showErrorDialog(
                                                                                      'Fehler beim Laden des Dokuments.',
                                                                                    );
                                                                                  }
                                                                                }
                                                                              },
                                                                              child: Icon(
                                                                                Icons.remove_red_eye,
                                                                                size:
                                                                                    UIConstants.iconSizeS *
                                                                                    fontSizeProvider.scaleFactor,
                                                                                color:
                                                                                    UIConstants.primaryColor,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  );
                                                                }

                                                                return const SizedBox.shrink();
                                                              },
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (sport.bemerkung !=
                                                    null) ...[
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
                                              ],
                                            ),
                                            // Delete icon - only show if status is Entwurf and not read-only
                                            if (!widget.readOnly &&
                                                widget.antrag?.statusId ==
                                                    BeduerfnisAntragStatus
                                                        .entwurf)
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: Semantics(
                                                  button: true,
                                                  label:
                                                      'Schießaktivität löschen',
                                                  hint:
                                                      'Doppeltippen um diese Schießaktivität zu löschen',
                                                  child: IconButton(
                                                    icon: const Icon(
                                                      Icons.delete_outline,
                                                      color:
                                                          UIConstants
                                                              .deleteIcon,
                                                    ),
                                                    tooltip: 'Löschen',
                                                    onPressed: () {
                                                      _deleteBedSport(sport.id);
                                                    },
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: UIConstants.spacingXXXL2),
                      // Add extra free space below the table
                      const SizedBox(height: 200),
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
    if (!mounted) return;

    // Check if antrag exists
    if (widget.antrag == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fehler: Antrag nicht gefunden')),
      );
      return;
    }

    // Navigate to step 3 screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BeduerfnisantragStep3Screen(
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
}
