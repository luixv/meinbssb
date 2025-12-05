import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/api_service.dart';
import '/web_redirect_stub.dart' if (dart.library.html) '/web_redirect_web.dart';

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
        leading: Semantics(
          button: true,
          label: 'Zurück',
          hint: 'Zur Startseite wechseln',
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: UIConstants.textColor),
            tooltip: 'Zurück',
            onPressed: () {
              if (widget.showMenu) {
                Navigator.of(context).maybePop();
              } else {
                // Redirect to root URL which will show splash and then login
                if (kIsWeb) {
                  WebRedirect.redirectTo('/');
                }
              }
            },
          ),
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _KeyboardFocusFAB(
              heroTag: 'resetFab',
              icon: Icons.refresh,
              tooltip: 'Formular zurücksetzen',
              semanticLabel: 'Formular zurücksetzen',
              semanticHint:
                  'Alle Filter werden auf Standardwerte zurückgesetzt',
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
            ),
            const SizedBox(height: UIConstants.spacingS),
            _KeyboardFocusFAB(
              heroTag: 'searchFab',
              icon: Icons.search,
              tooltip: 'Suchen',
              semanticLabel: 'Suche starten',
              semanticHint:
                  'Aktuelle Filter anwenden und Suchergebnisse anzeigen',
              onPressed: _navigateToResults,
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
                _KeyboardFocusDropdown<int>(
                  value: selectedWebGruppe,
                  label: 'Fachbereich',
                  semanticLabel: 'Fachbereich auswählen',
                  semanticHint: 'Doppelt tippen zum Auswählen',
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
                    ? Semantics(
                      label: 'Regierungsbezirke werden geladen',
                      child: CircularProgressIndicator(),
                    )
                    : _KeyboardFocusDropdown<int>(
                      value: selectedBezirkId,
                      label: 'Regierungsbezirk',
                      semanticLabel: 'Regierungsbezirk auswählen',
                      semanticHint: 'Doppelt tippen zum Auswählen',
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
                _KeyboardFocusTextField(
                  key: const Key('Ort'),
                  controller: _ortController,
                  label: 'Ort',
                  semanticLabel: 'Ort eingeben',
                  semanticHint:
                      'Wohn- oder Veranstaltungsort als Text eingeben',
                  fontSizeProvider: fontSizeProvider,
                ),
                const SizedBox(height: UIConstants.spacingM),
                _KeyboardFocusTextField(
                  key: const Key('Titel'),
                  controller: _titelController,
                  label: 'Titel',
                  semanticLabel: 'Titel eingeben',
                  semanticHint: 'Titel der Schulung als Text eingeben',
                  fontSizeProvider: fontSizeProvider,
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

// Custom TextField with keyboard-only focus highlighting
class _KeyboardFocusTextField extends StatefulWidget {
  const _KeyboardFocusTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.semanticLabel,
    required this.semanticHint,
    required this.fontSizeProvider,
  });

  final TextEditingController controller;
  final String label;
  final String semanticLabel;
  final String semanticHint;
  final FontSizeProvider fontSizeProvider;

  @override
  State<_KeyboardFocusTextField> createState() =>
      _KeyboardFocusTextFieldState();
}

class _KeyboardFocusTextFieldState extends State<_KeyboardFocusTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _hasKeyboardFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    final isKeyboardMode =
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    setState(() {
      _hasKeyboardFocus = _focusNode.hasFocus && isKeyboardMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      hint: widget.semanticHint,
      textField: true,
      child: TextFormField(
        focusNode: _focusNode,
        controller: widget.controller,
        style: UIStyles.formValueStyle.copyWith(
          fontSize:
              UIStyles.formValueStyle.fontSize! *
              widget.fontSizeProvider.scaleFactor,
        ),
        decoration: UIStyles.formInputDecoration.copyWith(
          labelText: widget.label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: UIStyles.formLabelStyle.copyWith(
            fontSize:
                UIStyles.formLabelStyle.fontSize! *
                widget.fontSizeProvider.scaleFactor,
          ),
          hintStyle: UIStyles.formInputDecoration.hintStyle?.copyWith(
            fontSize: widget.fontSizeProvider.getScaledFontSize(
              UIConstants.bodyFontSize,
            ),
          ),
          filled: true,
          fillColor: _hasKeyboardFocus ? Colors.yellow.shade100 : null,
          focusedBorder:
              _hasKeyboardFocus
                  ? OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.yellow.shade700,
                      width: 2.0,
                    ),
                  )
                  : null,
        ),
      ),
    );
  }
}

// Custom Dropdown with keyboard navigation (space to open, arrows to navigate, return to select)
class _KeyboardFocusDropdown<T> extends StatefulWidget {
  const _KeyboardFocusDropdown({
    required this.value,
    required this.label,
    required this.semanticLabel,
    required this.semanticHint,
    required this.items,
    required this.onChanged,
  });

  final T? value;
  final String label;
  final String semanticLabel;
  final String semanticHint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  State<_KeyboardFocusDropdown<T>> createState() =>
      _KeyboardFocusDropdownState<T>();
}

class _KeyboardFocusDropdownState<T> extends State<_KeyboardFocusDropdown<T>> {
  final FocusNode _focusNode = FocusNode();
  bool _hasKeyboardFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    final isKeyboardMode =
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    setState(() {
      _hasKeyboardFocus = _focusNode.hasFocus && isKeyboardMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      hint: widget.semanticHint,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          // Handle space key to open dropdown - Flutter's dropdown already handles this
          // but we ensure it's properly handled
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.space) {
            // The DropdownButtonFormField will handle opening when space is pressed
            return KeyEventResult.ignored; // Let the dropdown handle it
          }
          return KeyEventResult.ignored;
        },
        child: DropdownButtonFormField<T>(
          value: widget.value,
          decoration: UIStyles.formInputDecoration.copyWith(
            labelText: widget.label,
            filled: true,
            fillColor: _hasKeyboardFocus ? Colors.yellow.shade100 : null,
            focusedBorder:
                _hasKeyboardFocus
                    ? OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.yellow.shade700,
                        width: 2.0,
                      ),
                    )
                    : null,
          ),
          items: widget.items,
          onChanged: widget.onChanged,
          // DropdownButtonFormField already supports:
          // - Space/Enter to open dropdown
          // - Arrow keys to navigate
          // - Enter to select
        ),
      ),
    );
  }
}

// Custom FloatingActionButton with keyboard focus highlighting
class _KeyboardFocusFAB extends StatefulWidget {
  const _KeyboardFocusFAB({
    required this.heroTag,
    required this.icon,
    required this.tooltip,
    required this.semanticLabel,
    required this.semanticHint,
    required this.onPressed,
  });

  final String heroTag;
  final IconData icon;
  final String tooltip;
  final String semanticLabel;
  final String semanticHint;
  final VoidCallback onPressed;

  @override
  State<_KeyboardFocusFAB> createState() => _KeyboardFocusFABState();
}

class _KeyboardFocusFABState extends State<_KeyboardFocusFAB> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardMode =
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    final hasKeyboardFocus = _isFocused && isKeyboardMode;

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      hint: widget.semanticHint,
      child: Focus(
        focusNode: _focusNode,
        child: Tooltip(
          message: widget.tooltip,
          child: Padding(
            padding:
                hasKeyboardFocus ? const EdgeInsets.all(4.0) : EdgeInsets.zero,
            child: Container(
              decoration:
                  hasKeyboardFocus
                      ? BoxDecoration(
                        border: Border.all(
                          color: Colors.yellow.shade700,
                          width: 3.0,
                        ),
                      )
                      : null,
              child: FloatingActionButton(
                heroTag: widget.heroTag,
                onPressed: widget.onPressed,
                backgroundColor: UIConstants.defaultAppColor,
                child: Icon(widget.icon),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
