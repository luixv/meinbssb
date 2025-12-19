import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
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
    super.key,
  });

  final UserData? userData;
  final BeduerfnisseAntrag? antrag;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  State<BeduerfnissantragStep2Screen> createState() =>
      _BeduerfnissantragStep2ScreenState();
}

class _BeduerfnissantragStep2ScreenState
    extends State<BeduerfnissantragStep2Screen> {
  late Future<List<Map<String, dynamic>>> _bedSportFuture;

  @override
  void initState() {
    super.initState();
    _bedSportFuture = _fetchBedSportData();
  }

  Future<List<Map<String, dynamic>>> _fetchBedSportData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    if (widget.antrag?.antragsnummer == null) {
      return [];
    }
    try {
      return await apiService.getBedSportByAntragsnummer(
        widget.antrag!.antragsnummer,
      );
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
                          Navigator.pop(context);
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
                                  antragsnummer:
                                      widget.antrag?.antragsnummer ?? '',
                                  onSaved: (savedData) {
                                    setState(() {
                                      _bedSportFuture = _fetchBedSportData();
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                          );
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
                      FutureBuilder<List<Map<String, dynamic>>>(
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
                                          'Schießdatum: ${sport['schiessdatum'] ?? 'N/A'}',
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
                                          'Waffenart ID: ${sport['waffenartId'] ?? 'N/A'}',
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
                                          'Disziplin ID: ${sport['disziplinId'] ?? 'N/A'}',
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
                                          'Training: ${sport['training'] == true ? 'Ja' : 'Nein'}',
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
                                        if (sport['wettkampfartId'] != null)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: UIConstants.spacingS,
                                              ),
                                              ScaledText(
                                                'Wettkampfart ID: ${sport['wettkampfartId']}',
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
                                        if (sport['wettkampfergebnis'] != null)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: UIConstants.spacingS,
                                              ),
                                              ScaledText(
                                                'Wettkampfergebnis: ${sport['wettkampfergebnis']}',
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
    // TODO: Implement step 3 
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Funktionalität wird noch implementiert')),
      );
    }
  }
}
