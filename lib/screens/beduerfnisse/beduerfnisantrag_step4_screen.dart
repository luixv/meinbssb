import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import '/widgets/keyboard_focus_fab.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/api_service.dart';
import 'beduerfnisantrag_step4_dialog_screen.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/widgets/delete_confirm_dialog.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_status_data.dart';
import 'package:meinbssb/services/api/workflow_service.dart';
import 'package:meinbssb/models/beduerfnisse_waffe_besitz_data.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step5_screen.dart';

class BeduerfnisantragStep4Screen extends StatefulWidget {
  const BeduerfnisantragStep4Screen({
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
  State<BeduerfnisantragStep4Screen> createState() =>
      _BeduerfnisantragStep4ScreenState();
}

class _BeduerfnisantragStep4ScreenState
    extends State<BeduerfnisantragStep4Screen> {
  late Future<List<dynamic>> _waffeBesitzFuture = Future.value([]);
  late Future<List<dynamic>> _waffenartFuture = Future.value([]);
  late Future<List<dynamic>> _kaliberFuture = Future.value([]);
  late Future<List<dynamic>> _gruendeFuture = Future.value([]);
  late Future<List<dynamic>> _lauflaengeFuture = Future.value([]);
  late Future<List<dynamic>> _verbandFuture = Future.value([]);

  @override
  void initState() {
    super.initState();
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      _waffenartFuture = apiService.getBedAuswahlByTypId(1);
      _kaliberFuture = apiService.getBedAuswahlByTypId(6);
      _gruendeFuture = apiService.getBedAuswahlByTypId(5);
      _lauflaengeFuture = apiService.getBedAuswahlByTypId(4);
      _verbandFuture = apiService.getBedAuswahlByTypId(3);
    } catch (e) {
      debugPrint('Error initializing futures: $e');
    }
    _refreshWaffeBesitz();
  }

  void _refreshWaffeBesitz() {
    // Only fetch if antrag is available
    if (widget.antrag != null && widget.antrag?.antragsnummer != null) {
      setState(() {
        _waffeBesitzFuture = _fetchWaffeBesitz(context);
      });
    }
  }

  Future<List<dynamic>> _fetchWaffeBesitz(BuildContext context) async {
    if (widget.antrag == null || widget.antrag?.antragsnummer == null) {
      return [];
    }
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      return await apiService.getBedWaffeBesitzByAntragsnummer(
        widget.antrag!.antragsnummer!,
      );
    } catch (e) {
      debugPrint('Error fetching waffe besitz: $e');
      return [];
    }
  }

  Future<void> _showAddWaffeBesitzDialog(
    BuildContext context, {
    BeduerfnisWaffeBesitz? waffeBesitz,
  }) async {
    if (widget.antrag?.antragsnummer == null) return;
    await showDialog(
      context: context,
      builder:
          (ctx) => AddWaffeBesitzDialog(
            antragsnummer: widget.antrag!.antragsnummer!,
            onSaved: _refreshWaffeBesitz,
            waffeBesitz: waffeBesitz,
          ),
    );
  }

  Future<void> _deleteWaffeBesitz(int? id) async {
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => DeleteConfirmDialog(
            title: 'Eintrag löschen',
            message: 'Möchten Sie diesen Eintrag wirklich löschen?',
            onCancel: () => Navigator.of(ctx).pop(false),
            onDelete: () => Navigator.of(ctx).pop(true),
          ),
    );

    if (confirmed != true) return;

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final success = await apiService.deleteBedWaffeBesitzById(id);
      if (success) {
        _refreshWaffeBesitz();
      } else {
        if (mounted) {
          ScaffoldMessenger.maybeOf(
            context,
          )?.showSnackBar(const SnackBar(content: Text('Fehler beim Löschen')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(
          context,
        )?.showSnackBar(SnackBar(content: Text('Fehler: $e')));
      }
    }
  }

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
                  heroTag: 'fab_back_step4',
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!widget.readOnly &&
                    widget.antrag?.statusId == BeduerfnisAntragStatus.entwurf)
                  KeyboardFocusFAB(
                    heroTag: 'addWaffeBesitzFab',
                    tooltip: 'Waffenbesitz hinzufügen',
                    semanticLabel: 'Waffenbesitz hinzufügen',
                    semanticHint: 'Neuen Waffenbesitz-Eintrag hinzufügen',
                    onPressed: () {
                      _showAddWaffeBesitzDialog(context);
                    },
                    icon: Icons.add,
                  ),
                if (!widget.readOnly &&
                    widget.antrag?.statusId == BeduerfnisAntragStatus.entwurf)
                  const SizedBox(height: 12),
                KeyboardFocusFAB(
                  heroTag: 'nextFromStep4Fab',
                  tooltip: 'Weiter',
                  semanticLabel: 'Weiter Button',
                  semanticHint: 'Weiter zum nächsten Schritt',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => BeduerfnisantragStep5Screen(
                              userData: widget.userData,
                              isLoggedIn: widget.isLoggedIn,
                              onLogout: widget.onLogout,
                              antrag: widget.antrag,
                              userRole: widget.userRole,
                              readOnly: widget.readOnly,
                            ),
                      ),
                    );
                  },
                  icon: Icons.arrow_forward,
                ),
              ],
            ),
          ],
        ),
      ),
      body: Semantics(
        label: 'Bedürfnisbescheinigung Schritt 4',
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
              const ScaledText(
                'Erfassen der Lang- bzw. Kurzwaffen',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: UIConstants.spacingM),

              // Show BedWaffeBesitz results
              FutureBuilder<List<dynamic>>(
                future: Future.wait([
                  _waffeBesitzFuture,
                  _waffenartFuture,
                  _kaliberFuture,
                  _gruendeFuture,
                  _lauflaengeFuture,
                  _verbandFuture,
                ]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Fehler: ${snapshot.error}');
                  }
                  final data = snapshot.data!;
                  final waffen = data[0] as List<dynamic>;
                  final waffenartList = data[1] as List<dynamic>;
                  final kaliberList = data[2] as List<dynamic>;
                  final gruendeList = data[3] as List<dynamic>;
                  final lauflaengeList = data[4] as List<dynamic>;
                  final verbandList = data[5] as List<dynamic>;

                  // Create lookup maps
                  final waffenartMap = {
                    for (var item in waffenartList) item.id: item.beschreibung,
                  };
                  final kaliberMap = {
                    for (var item in kaliberList) item.id: item.beschreibung,
                  };
                  final gruendeMap = {
                    for (var item in gruendeList) item.id: item.beschreibung,
                  };
                  final lauflaengeMap = {
                    for (var item in lauflaengeList)
                      (item is Map ? item['id'] : item.id):
                          (item is Map
                              ? item['beschreibung']
                              : item.beschreibung),
                  };
                  final verbandMap = {
                    for (var item in verbandList) item.id: item.beschreibung,
                  };

                  if (waffen.isEmpty) {
                    return const ScaledText(
                      'Keine Waffenbesitz-Einträge gefunden.',
                    );
                  }

                  return Consumer<FontSizeProvider>(
                    builder: (context, fontSizeProvider, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ScaledText(
                            'Waffenbesitz-Einträge:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: UIConstants.spacingM),
                          ...waffen.map((wb) {
                            return Card(
                              margin: const EdgeInsets.only(
                                bottom: UIConstants.spacingM,
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(
                                      UIConstants.spacingM,
                                    ),
                                    child: Column(
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
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  _buildInfoRow(
                                                    Icons.description,
                                                    'WBK: ${wb.wbkNr ?? ""} / ${wb.lfdWbk ?? ""}',
                                                    fontSizeProvider
                                                        .scaleFactor,
                                                    'WBK-Nr / lfd WBK',
                                                  ),
                                                  const SizedBox(
                                                    height:
                                                        UIConstants.spacingS,
                                                  ),
                                                  _buildInfoRow(
                                                    Icons.adjust,
                                                    waffenartMap[wb
                                                            .waffenartId] ??
                                                        'Unbekannt',
                                                    fontSizeProvider
                                                        .scaleFactor,
                                                    'Waffenart',
                                                  ),
                                                  const SizedBox(
                                                    height:
                                                        UIConstants.spacingS,
                                                  ),
                                                  _buildInfoRow(
                                                    Icons.straighten,
                                                    lauflaengeMap[wb
                                                            .lauflaengeId] ??
                                                        'Unbekannt',
                                                    fontSizeProvider
                                                        .scaleFactor,
                                                    'Lauflänge',
                                                  ),
                                                  const SizedBox(
                                                    height:
                                                        UIConstants.spacingS,
                                                  ),
                                                  _buildInfoRow(
                                                    Icons.help_outline,
                                                    gruendeMap[wb
                                                            .beduerfnisgrundId] ??
                                                        'Unbekannt',
                                                    fontSizeProvider
                                                        .scaleFactor,
                                                    'Bedürfnisgrund',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              width: UIConstants.spacingXXS,
                                            ),
                                            // Right column
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  _buildInfoRow(
                                                    Icons.branding_watermark,
                                                    wb.hersteller ?? '',
                                                    fontSizeProvider
                                                        .scaleFactor,
                                                    'Hersteller/Modell',
                                                  ),
                                                  const SizedBox(
                                                    height:
                                                        UIConstants.spacingS,
                                                  ),
                                                  _buildInfoRow(
                                                    Icons.gps_fixed,
                                                    kaliberMap[wb.kaliberId] ??
                                                        'Unbekannt',
                                                    fontSizeProvider
                                                        .scaleFactor,
                                                    'Kaliber',
                                                  ),
                                                  const SizedBox(
                                                    height:
                                                        UIConstants.spacingS,
                                                  ),
                                                  _buildInfoRow(
                                                    Icons.monitor_weight,
                                                    '${wb.gewicht ?? ""} g',
                                                    fontSizeProvider
                                                        .scaleFactor,
                                                    'Gewicht',
                                                  ),
                                                  const SizedBox(
                                                    height:
                                                        UIConstants.spacingS,
                                                  ),
                                                  _buildInfoRow(
                                                    Icons.group,
                                                    verbandMap[wb.verbandId] ??
                                                        'Unbekannt',
                                                    fontSizeProvider
                                                        .scaleFactor,
                                                    'Verband',
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: UIConstants.spacingS,
                                        ),
                                        Row(
                                          children: [
                                            Tooltip(
                                              message: 'Kompensator',
                                              child: Icon(
                                                Icons.settings_input_component,
                                                size:
                                                    UIConstants.iconSizeS *
                                                    fontSizeProvider
                                                        .scaleFactor,
                                                color: UIConstants.primaryColor,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: UIConstants.spacingS,
                                            ),
                                            ScaledText(
                                              'Kompensator:',
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
                                            const SizedBox(width: 8),
                                            Tooltip(
                                              message:
                                                  wb.kompensator == true
                                                      ? 'Kompensator vorhanden'
                                                      : 'Kein Kompensator',
                                              child: Icon(
                                                wb.kompensator == true
                                                    ? Icons.check
                                                    : Icons.close,
                                                color:
                                                    wb.kompensator == true
                                                        ? UIConstants
                                                            .defaultAppColor
                                                        : Colors.red,
                                                size:
                                                    UIConstants.iconSizeS *
                                                    fontSizeProvider
                                                        .scaleFactor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (wb.bemerkung != null &&
                                            wb.bemerkung
                                                .toString()
                                                .isNotEmpty) ...[
                                          const SizedBox(
                                            height: UIConstants.spacingS,
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.comment,
                                                size:
                                                    UIConstants.iconSizeS *
                                                    fontSizeProvider
                                                        .scaleFactor,
                                                color: UIConstants.primaryColor,
                                              ),
                                              const SizedBox(
                                                width: UIConstants.spacingS,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  ' ${wb.bemerkung}',
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
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (!widget.readOnly &&
                                      widget.antrag?.statusId ==
                                          BeduerfnisAntragStatus.entwurf)
                                    Positioned(
                                      top: 4,
                                      right: 48,
                                      child: Semantics(
                                        button: true,
                                        label: 'Eintrag bearbeiten',
                                        child: Tooltip(
                                          message: 'Bearbeiten',
                                          child: InkWell(
                                            onTap:
                                                () => _showAddWaffeBesitzDialog(
                                                  context,
                                                  waffeBesitz: wb,
                                                ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Icon(
                                                Icons.edit,
                                                color: UIConstants.primaryColor,
                                                size:
                                                    UIConstants.iconSizeS *
                                                    fontSizeProvider
                                                        .scaleFactor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (!widget.readOnly &&
                                      widget.antrag?.statusId ==
                                          BeduerfnisAntragStatus.entwurf)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Semantics(
                                        button: true,
                                        label: 'Eintrag löschen',
                                        child: Tooltip(
                                          message: 'Löschen',
                                          child: InkWell(
                                            onTap:
                                                () => _deleteWaffeBesitz(wb.id),
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Icon(
                                                Icons.delete_outline,
                                                color: UIConstants.deleteIcon,
                                                size:
                                                    UIConstants.iconSizeS *
                                                    fontSizeProvider
                                                        .scaleFactor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: UIConstants.spacingXXXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String text,
    double scaleFactor,
    String tooltip,
  ) {
    return Row(
      children: [
        Tooltip(
          message: tooltip,
          child: Icon(
            icon,
            size: UIConstants.iconSizeS * scaleFactor,
            color: UIConstants.primaryColor,
          ),
        ),
        const SizedBox(width: UIConstants.spacingS),
        Expanded(
          child: ScaledText(
            text,
            style: UIStyles.bodyTextStyle.copyWith(
              fontSize: UIStyles.bodyTextStyle.fontSize! * scaleFactor,
            ),
          ),
        ),
      ],
    );
  }
}
