import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/api_service.dart';

import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/user_data.dart';
import '/models/bezirk_data.dart';
import '/models/schulungstermin_data.dart';

import '/screens/base_screen_layout.dart';
import '/screens/schulungen_screen.dart';

import '/widgets/scaled_text.dart';

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
    return BaseScreenLayout(
      title: 'Aus- und Weiterbildung',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      automaticallyImplyLeading: true,
      showMenu: widget.showMenu,
      showConnectivityIcon: widget.showConnectivityIcon,
      leading:
          widget.showMenu
              ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: UIConstants.textColor,
                ),
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
              )
              : null,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
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
          const SizedBox(height: UIConstants.spacingS),
          FloatingActionButton(
            heroTag: 'searchFab',
            onPressed: _navigateToResults,
            backgroundColor: UIConstants.defaultAppColor,
            tooltip: 'Suchen',
            child: const Icon(Icons.search),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScaledText('Suchen', style: UIStyles.headerStyle),
              const SizedBox(height: UIConstants.spacingM),
              // Date field removed
              DropdownButtonFormField<int>(
                value: selectedWebGruppe,
                decoration: UIStyles.formInputDecoration.copyWith(
                  labelText: 'Fachbereich',
                ),
                items: [
                  const DropdownMenuItem<int>(value: 0, child: Text('Alle')),
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
              const SizedBox(height: UIConstants.spacingM),
              isLoadingBezirke
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<int>(
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
              const SizedBox(height: UIConstants.spacingM),
              TextFormField(
                key: const Key('Ort'),
                controller: _ortController,
                decoration: UIStyles.formInputDecoration.copyWith(
                  labelText: 'Ort',
                ),
              ),
              const SizedBox(height: UIConstants.spacingM),
              TextFormField(
                key: const Key('Titel'),
                controller: _titelController,
                decoration: UIStyles.formInputDecoration.copyWith(
                  labelText: 'Titel',
                ),
              ),
              const SizedBox(height: UIConstants.spacingM),
              CheckboxListTile(
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
              CheckboxListTile(
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
            ],
          ),
        ),
      ),
    );
  }
}
