import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_status_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnissantrag_step1_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import '/widgets/keyboard_focus_fab.dart';

class MeineBeduerfnisseantraegeScreen extends StatefulWidget {
  const MeineBeduerfnisseantraegeScreen({
    this.userData,
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  State<MeineBeduerfnisseantraegeScreen> createState() =>
      _MeineBeduerfnisseantraegeScreenState();
}

class _MeineBeduerfnisseantraegeScreenState
    extends State<MeineBeduerfnisseantraegeScreen> {
  late Future<List<BeduerfnisseAntrag>> _antragsFuture;

  @override
  void initState() {
    super.initState();
    _loadAntragsFuture();
    // Also refresh when the screen resumes (when returning from another screen)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshList();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload the antrag list whenever this screen's dependencies change
    _refreshList();
  }

  void _refreshList() {
    if (mounted) {
      setState(() {
        _loadAntragsFuture();
      });
    }
  }

  void _loadAntragsFuture() {
    _antragsFuture = _loadAntrags();
  }

  Future<List<BeduerfnisseAntrag>> _loadAntrags() async {
    if (widget.userData?.personId != null) {
      final apiService = Provider.of<ApiService>(context, listen: false);
      // Force refresh by always fetching fresh data from the server
      return apiService.getBedAntragByPersonId(widget.userData!.personId);
    }
    return [];
  }

  Future<void> _deleteAntrag(BeduerfnisseAntrag antrag) async {
    if (antrag.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: UIConstants.backgroundColor,
            title: const Center(
              child: Text('Antrag löschen', style: UIStyles.dialogTitleStyle),
            ),
            content: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: UIStyles.dialogContentStyle,
                children: <TextSpan>[
                  const TextSpan(text: 'Möchten Sie diesen Antrag wirklich '),
                  TextSpan(
                    text: 'Antrag Nr. ${antrag.antragsnummer ?? 'N/A'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text:
                        ' löschen? Dies kann nicht rückgängig gemacht werden.',
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
          ),
    );

    if (confirmed != true) return;

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      if (antrag.antragsnummer == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fehler: Antragsnummer fehlt')),
          );
        }
        return;
      }
      final success = await apiService.deleteBedAntrag(antrag.antragsnummer!);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Antrag erfolgreich gelöscht')),
          );
          // Reload the list
          setState(() {
            _antragsFuture = _loadAntrags();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fehler beim Löschen des Antrags')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
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
          label: 'Bedürfnisbescheinigung - Meine Bedürfnisseanträge',
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
                  KeyboardFocusFAB(
                    heroTag: 'backToBeduerfnisbescheinigungFab',
                    tooltip: 'Zurück zur Ablaufbeschreibung',
                    semanticLabel: 'Zurück zur Ablaufbeschreibung Button',
                    semanticHint:
                        'Navigieren zurück zur Bedürfnisbescheinigung',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icons.arrow_back,
                  ),
                  KeyboardFocusFAB(
                    heroTag: 'neuerBeduerfnisantragFab',
                    tooltip: 'Neuer Bedürfnisantrag',
                    semanticLabel: 'Neuer Bedürfnisantrag Button',
                    semanticHint: 'Neuen Bedürfnisantrag erstellen',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BeduerfnissantragStep1Screen(
                                userData: widget.userData,
                                isLoggedIn: widget.isLoggedIn,
                                onLogout: widget.onLogout,
                                onBack: () {
                                  setState(() {
                                    _antragsFuture = _loadAntrags();
                                  });
                                },
                              ),
                        ),
                      );
                    },
                    icon: Icons.add,
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
                    'Meine Bedürfnisseanträge. Hier sehen Sie Ihre eingereichten Bedürfnisseanträge.',
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(UIConstants.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle
                      Semantics(
                        header: true,
                        label: 'Meine Bedürfnisseanträge',
                        child: ScaledText(
                          'Meine Bedürfnisseanträge',
                          style: UIStyles.headerStyle.copyWith(
                            fontSize:
                                UIStyles.headerStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                          ),
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Bedürfnisse List from API
                      FutureBuilder<List<BeduerfnisseAntrag>>(
                        future: _antragsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  UIConstants.defaultAppColor,
                                ),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: ScaledText(
                                'Fehler beim Laden: ${snapshot.error}',
                                style: UIStyles.bodyTextStyle.copyWith(
                                  fontSize:
                                      UIStyles.bodyTextStyle.fontSize! *
                                      fontSizeProvider.scaleFactor,
                                  color: UIConstants.errorColor,
                                ),
                              ),
                            );
                          }

                          final beduerfnisse = snapshot.data ?? [];
                          if (beduerfnisse.isEmpty) {
                            return Center(
                              child: ScaledText(
                                'Keine Bedürfnisseanträge vorhanden',
                                style: UIStyles.bodyTextStyle.copyWith(
                                  fontSize:
                                      UIStyles.bodyTextStyle.fontSize! *
                                      fontSizeProvider.scaleFactor,
                                  color: UIConstants.mydarkGreyColor,
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              for (int i = 0; i < beduerfnisse.length; i++) ...[
                                _buildBeduerfnisItem(
                                  fontSizeProvider: fontSizeProvider,
                                  antrag: beduerfnisse[i],
                                ),
                                if (i < beduerfnisse.length - 1)
                                  const SizedBox(height: UIConstants.spacingS),
                              ],
                            ],
                          );
                        },
                      ),
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

  Widget _buildBeduerfnisItem({
    required FontSizeProvider fontSizeProvider,
    required BeduerfnisseAntrag antrag,
  }) {
    final statusColor = _getStatusColor(antrag.statusId);
    final statusText = antrag.statusId?.toGermanString() ?? 'Unbekannt';

    return Semantics(
      label:
          '${antrag.antragsnummer ?? 'N/A'} vom ${antrag.createdAt}, Status: $statusText',
      child: Container(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        decoration: BoxDecoration(
          color: UIConstants.whiteColor,
          borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
          border: Border.all(color: UIConstants.mydarkGreyColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScaledText(
                    '${antrag.antragsnummer ?? 'N/A'}',
                    style: UIStyles.formValueBoldStyle.copyWith(
                      fontSize:
                          UIStyles.formValueBoldStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingXS),
                  ScaledText(
                    antrag.createdAt != null
                        ? DateFormat('dd.MM.yyyy').format(antrag.createdAt!)
                        : 'N/A',
                    style: UIStyles.bodyTextStyle.copyWith(
                      fontSize:
                          UIStyles.bodyTextStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                      color: UIConstants.mydarkGreyColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.spacingS,
                vertical: UIConstants.spacingXS,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
                border: Border.all(color: statusColor),
              ),
              child: ScaledText(
                statusText,
                style: UIStyles.bodyTextStyle.copyWith(
                  fontSize:
                      UIStyles.bodyTextStyle.fontSize! *
                      fontSizeProvider.scaleFactor,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Edit button for draft antrags only
            if (antrag.statusId == BeduerfnisAntragStatus.entwurf)
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: UIConstants.defaultAppColor,
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => BeduerfnissantragStep1Screen(
                            userData: widget.userData,
                            antrag: antrag,
                            isLoggedIn: widget.isLoggedIn,
                            onLogout: widget.onLogout,
                          ),
                    ),
                  );
                  // If antrag was updated, refresh the list
                  if (result == true) {
                    _loadAntragsFuture();
                  }
                },
                tooltip: 'Antrag bearbeiten',
              ),
            // Delete button for draft antrags
            if (antrag.statusId == BeduerfnisAntragStatus.entwurf)
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: UIConstants.defaultAppColor,
                ),
                onPressed: () => _deleteAntrag(antrag),
                tooltip: 'Antrag löschen',
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BeduerfnisAntragStatus? status) {
    switch (status) {
      case BeduerfnisAntragStatus.entwurf:
        return UIConstants.labelTextColor; // Draft - grey
      case BeduerfnisAntragStatus.eingereichtAmVerein:
        return UIConstants.warningColor; // Submitted to club - orange
      case BeduerfnisAntragStatus.zurueckgewiesenAnMitgliedVonVerein:
        return UIConstants.errorColor; // Rejected by club to member - red
      case BeduerfnisAntragStatus.genehmightVonVerein:
        return UIConstants.successColor; // Approved by club - green
      case BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnVerein:
        return UIConstants.errorColor; // Rejected by BSSB to club - red
      case BeduerfnisAntragStatus.zurueckgewiesenVonBSSBAnMitglied:
        return UIConstants.errorColor; // Rejected by BSSB to member - red
      case BeduerfnisAntragStatus.eingereichtAnBSSB:
        return UIConstants.warningColor; // Submitted to BSSB - orange
      case BeduerfnisAntragStatus.genehmight:
        return UIConstants.successColor; // Approved by BSSB - green
      case BeduerfnisAntragStatus.abgelehnt:
        return UIConstants.errorColor; // Rejected - red
      default:
        return UIConstants.labelTextColor;
    }
  }
}
