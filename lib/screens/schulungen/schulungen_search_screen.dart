import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/api_service.dart';

import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/user_data.dart';
import '/models/bezirk_data.dart';
import '/models/schulungstermin_data.dart';

import '/screens/base_screen_layout.dart';
import 'schulungen_screen.dart';

import '/widgets/scaled_text.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

class SchulungenSearchScreen extends StatefulWidget {
  const SchulungenSearchScreen({
    this.userData,
    required this.isLoggedIn,
    required this.onLogout,
    this.showMenu = true,
    this.showConnectivityIcon = true,
    super.key,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final VoidCallback onLogout;
  final bool showMenu;
  final bool showConnectivityIcon;

  @override
  State<SchulungenSearchScreen> createState() => _SchulungenSearchScreenState();
}

class _SchulungenSearchScreenState extends State<SchulungenSearchScreen> {
  DateTime selectedDate = DateTime.now();
  int? selectedWebGruppe = 0;
  int? selectedBezirkId = 0;
  final TextEditingController _ortController = TextEditingController();
  final TextEditingController _titelController = TextEditingController();
  bool fuerVerlaengerungen = false;
  bool fuerVuelVerlaengerungen = false;
  List<BezirkSearchTriple> _bezirke = [];
  bool isLoadingBezirke = true;

  @override
  void initState() {
    super.initState();
    _fetchBezirke();
  }

  Future<void> _fetchBezirke() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final bezirke = await apiService.fetchBezirkeforSearch();

      // Add "Alle" option
      _bezirke = [
        const BezirkSearchTriple(bezirkId: 0, bezirkNr: 0, bezirkName: 'Alle'),
        ...bezirke,
      ];
    } catch (e) {
      // Fallback to only "Alle" and inform the user
      _bezirke = const [
        BezirkSearchTriple(bezirkId: 0, bezirkNr: 0, bezirkName: 'Alle'),
      ];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Regierungsbezirke konnten nicht geladen werden.'),
            backgroundColor: UIConstants.errorColor,
            duration: UIConstants.snackbarDuration,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingBezirke = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _ortController.dispose();
    _titelController.dispose();
    super.dispose();
  }

  void _navigateToResults() {
    final date = selectedDate;
    final userData = widget.userData;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SchulungenScreen(
              userData,
              isLoggedIn: widget.isLoggedIn,
              onLogout: widget.onLogout,
              searchDate: date,
              webGruppe: selectedWebGruppe,
              bezirkId: selectedBezirkId,
              ort: _ortController.text,
              titel: _titelController.text,
              fuerVerlaengerungen: fuerVerlaengerungen,
              fuerVuelVerlaengerungen: fuerVuelVerlaengerungen,
              showMenu: widget.showMenu,
              showConnectivityIcon: widget.showConnectivityIcon,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(
      context,
    );
    return Semantics(
      label:
          'Suchmaske für Aus- und Weiterbildung. Wählen Sie Fachbereich, Regierungsbezirk, Ort, Titel und Optionen für Lizenz- oder VÜL-Verlängerung. Starten Sie die Suche mit dem Button unten rechts.',
      child: BaseScreenLayout(
        title: 'Aus- und Weiterbildung',
        userData: widget.userData,
        isLoggedIn: widget.isLoggedIn,
        onLogout: widget.onLogout,
        automaticallyImplyLeading: true,
        showMenu: widget.showMenu,
        showConnectivityIcon: widget.showConnectivityIcon,
        leading:
            widget.showMenu
                ? Semantics(
                  button: true,
                  label: 'Zurück',
                  hint: 'Zur vorherigen Seite wechseln',
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: UIConstants.textColor,
                    ),
                    tooltip: 'Zurück',
                    onPressed: () {
                      Navigator.of(context).maybePop();
                    },
                  ),
                )
                : null,
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Semantics(
              label: 'Formular zurücksetzen',
              button: true,
              hint: 'Alle Filter werden auf Standardwerte zurückgesetzt',
              child: FloatingActionButton(
                heroTag: 'resetFab',
                onPressed: () {
                  setState(() {
                    selectedDate = DateTime.now();
                    selectedWebGruppe = 0;
                    selectedBezirkId = 0;
                    _ortController.clear();
                    _titelController.clear();
                    fuerVerlaengerungen = false;
                    fuerVuelVerlaengerungen = false;
                  });
                },
                backgroundColor: UIConstants.defaultAppColor,
                tooltip: 'Formular zurücksetzen',
                child: const Icon(Icons.refresh),
              ),
            ),
            const SizedBox(height: UIConstants.spacingS),
            Semantics(
              label: 'Suche starten',
              button: true,
              hint: 'Aktuelle Filter anwenden und Suchergebnisse anzeigen',
              child: FloatingActionButton(
                heroTag: 'searchFab',
                onPressed: _navigateToResults,
                backgroundColor: UIConstants.defaultAppColor,
                tooltip: 'Suchen',
                child: const Icon(Icons.search),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(UIConstants.spacingM),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  label: 'Suchen',
                  child: const ScaledText(
                    'Suchen',
                    style: UIStyles.headerStyle,
                  ),
                ),
                const SizedBox(height: UIConstants.spacingM),
                Semantics(
                  label: 'Fachbereich auswählen',
                  hint: 'Doppelt tippen zum Auswählen',
                  child: DropdownButtonFormField<int>(
                    value: selectedWebGruppe,
                    decoration: UIStyles.formInputDecoration.copyWith(
                      labelText: 'Fachbereich',
                    ),
                    items: [
                      const DropdownMenuItem<int>(
                        value: 0,
                        child: Text('Alle'),
                      ),
                      ...Schulungstermin.webGruppeMap.entries
                          .where((entry) => entry.key != 0)
                          .map(
                            (entry) => DropdownMenuItem<int>(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                          ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedWebGruppe = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: UIConstants.spacingM),
                isLoadingBezirke
                    ? Semantics(
                      label: 'Regierungsbezirke werden geladen',
                      child: CircularProgressIndicator(),
                    )
                    : Semantics(
                      label: 'Regierungsbezirk auswählen',
                      hint: 'Doppelt tippen zum Auswählen',
                      child: DropdownButtonFormField<int>(
                        value: selectedBezirkId,
                        decoration: UIStyles.formInputDecoration.copyWith(
                          labelText: 'Regierungsbezirk',
                        ),
                        items:
                            _bezirke
                                .map(
                                  (bezirk) => DropdownMenuItem<int>(
                                    value: bezirk.bezirkId,
                                    child: Text(bezirk.bezirkName),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedBezirkId = value;
                          });
                        },
                      ),
                    ),
                const SizedBox(height: UIConstants.spacingM),
                Focus(
                  canRequestFocus: true,
                  child: Semantics(
                    label: 'Ort eingeben',
                    hint: 'Wohn- oder Veranstaltungsort als Text eingeben',
                    textField: true,
                    child: TextFormField(
                      key: const Key('Ort'),
                      controller: _ortController,
                      style: UIStyles.formValueStyle.copyWith(
                        fontSize:
                            UIStyles.formValueStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                      ),
                      decoration: UIStyles.formInputDecoration.copyWith(
                        labelText: 'Ort',
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        labelStyle: UIStyles.formLabelStyle.copyWith(
                          fontSize:
                              UIStyles.formLabelStyle.fontSize! *
                              fontSizeProvider.scaleFactor,
                        ),
                        hintStyle: UIStyles.formInputDecoration.hintStyle
                            ?.copyWith(
                              fontSize: Provider.of<FontSizeProvider>(
                                context,
                              ).getScaledFontSize(UIConstants.bodyFontSize),
                            ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: UIConstants.spacingM),
                Focus(
                  canRequestFocus: true,
                  child: Semantics(
                    label: 'Titel eingeben',
                    hint: 'Titel der Schulung als Text eingeben',
                    textField: true,
                    child: TextFormField(
                      key: const Key('Titel'),
                      controller: _titelController,
                      style: UIStyles.formValueStyle.copyWith(
                        fontSize:
                            UIStyles.formValueStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                      ),
                      decoration: UIStyles.formInputDecoration.copyWith(
                        labelText: 'Titel',
                        labelStyle: UIStyles.formLabelStyle.copyWith(
                          fontSize:
                              UIStyles.formLabelStyle.fontSize! *
                              fontSizeProvider.scaleFactor,
                        ),
                        hintStyle: UIStyles.formInputDecoration.hintStyle
                            ?.copyWith(
                              fontSize: Provider.of<FontSizeProvider>(
                                context,
                              ).getScaledFontSize(UIConstants.bodyFontSize),
                            ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: UIConstants.spacingM),
                Semantics(
                  label: 'Für Lizenzverlängerung auswählen',
                  hint:
                      'Aktivieren, um nur Schulungen für Lizenzverlängerungen zu zeigen',
                  toggled: fuerVerlaengerungen,
                  child: CheckboxListTile(
                    title: const Text('Für Lizenzverlängerung'),
                    value: fuerVerlaengerungen,
                    onChanged: (bool? value) {
                      setState(() {
                        fuerVerlaengerungen = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Semantics(
                  label: 'Für VÜL Verlängerung auswählen',
                  hint:
                      'Aktivieren, um nur Schulungen für VÜL-Verlängerungen zu zeigen',
                  toggled: fuerVuelVerlaengerungen,
                  child: CheckboxListTile(
                    title: const Text('Für VÜL Verlängerung'),
                    value: fuerVuelVerlaengerungen,
                    onChanged: (bool? value) {
                      setState(() {
                        fuerVuelVerlaengerungen = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
