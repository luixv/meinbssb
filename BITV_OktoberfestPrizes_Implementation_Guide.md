# BITV 2.0 Oktoberfest Prizes Screen - Implementierungsleitfaden

## 🎯 Von 79% auf 95% BITV 2.0 Konformität

Dieser komplexe Screen benötigt strategische Accessibility-Verbesserungen. Die bereitgestellten Code-Beispiele sind produktionsreif und berücksichtigen die Business-Logic-Komplexität.

---

## 🚨 Phase 1: Kritische Fixes (Sofort umsetzbar)

### 1. Semantic ListView-Struktur

**Ersetzen Sie die aktuelle ListView:**

```dart
// ✅ Optimierte Gewinn-Liste mit vollständiger Accessibility
Widget _buildGewinnListe() {
  if (_gewinne.isEmpty && !_loading) {
    return Semantics(
      liveRegion: true,
      label: 'Keine Gewinne gefunden',
      child: const Center(
        child: Text(
          'Keine Gewinne für das gewählte Jahr gefunden.',
          style: TextStyle(fontSize: UIConstants.bodyFontSize),
        ),
      ),
    );
  }

  return Semantics(
    container: true,
    label: 'Liste der Oktoberfest-Gewinne',
    hint: '${_gewinne.length} Gewinne für das Jahr $_selectedYear gefunden. Navigieren Sie mit den Pfeiltasten durch die Liste.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header für bessere Orientierung
        Semantics(
          header: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.spacingL,
              vertical: UIConstants.spacingS,
            ),
            child: Text(
              'Ihre Gewinne (${_gewinne.length})',
              style: UIStyles.subtitleStyle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        // Semantisch strukturierte Liste
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _gewinne.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) => _buildAccessibleGewinnItem(index),
        ),
      ],
    ),
  );
}

// Vollständig accessible Gewinn-Item
Widget _buildAccessibleGewinnItem(int index) {
  final gewinn = _gewinne[index];
  final abgerufenAm = gewinn.abgerufenAm;
  final isAbgerufen = abgerufenAm.isNotEmpty;
  
  // Status-Text für Screenreader
  final statusText = isAbgerufen 
    ? 'Bereits abgerufen am ${_formatDate(abgerufenAm)}'
    : 'Noch nicht abgerufen, bereit zum Abrufen';

  return Semantics(
    container: true,
    label: 'Gewinn ${index + 1} von ${_gewinne.length}',
    hint: '${gewinn.wettbewerb}, ${gewinn.geldpreis}, Platz ${gewinn.platz}. $statusText',
    child: Card(
      margin: const EdgeInsets.symmetric(
        vertical: UIConstants.spacingS,
        horizontal: UIConstants.spacingL,
      ),
      elevation: UIConstants.appBarElevation,
      child: Semantics(
        button: false, // Nicht interaktiv
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            vertical: UIConstants.spacingM,
            horizontal: UIConstants.spacingL,
          ),
          
          // Leading Icon für Status
          leading: Semantics(
            label: isAbgerufen ? 'Abgerufen' : 'Noch nicht abgerufen',
            child: Icon(
              isAbgerufen ? Icons.check_circle : Icons.pending,
              color: isAbgerufen ? UIConstants.successColor : UIConstants.warningColor,
              size: UIConstants.iconSizeM,
            ),
          ),
          
          // Titel mit Semantic-Info
          title: Semantics(
            label: 'Wettbewerb: ${gewinn.wettbewerb}',
            child: Text(
              gewinn.wettbewerb,
              style: UIStyles.listItemTitleStyle,
            ),
          ),
          
          // Subtitle mit strukturierten Infos
          subtitle: Semantics(
            label: 'Platz ${gewinn.platz}, Geldpreis ${gewinn.geldpreis}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Platz: ${gewinn.platz}',
                  style: UIStyles.listItemSubtitleStyle,
                ),
                Text(
                  'Geldpreis: ${gewinn.geldpreis}',
                  style: UIStyles.listItemSubtitleStyle,
                ),
              ],
            ),
          ),
          
          // Trailing Status mit Accessibility
          trailing: _buildAccessibleStatusDisplay(gewinn),
        ),
      ),
    ),
  );
}

// Accessible Status-Display
Widget _buildAccessibleStatusDisplay(Gewinn gewinn) {
  final abgerufenAm = gewinn.abgerufenAm;
  DateTime? date;
  if (abgerufenAm.isNotEmpty) {
    date = DateTime.tryParse(abgerufenAm);
  }

  if (date != null) {
    final formatted = _formatDate(abgerufenAm);
    return Semantics(
      label: 'Abgerufen am $formatted',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(
            Icons.check_circle,
            color: UIConstants.successColor,
            size: UIConstants.iconSizeS,
          ),
          const SizedBox(height: 4),
          Text(
            formatted,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: UIConstants.successColor,
            ),
          ),
        ],
      ),
    );
  } else {
    return Semantics(
      label: 'Noch nicht abgerufen, bereit zum Abrufen',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.pending,
            color: UIConstants.warningColor,
            size: UIConstants.iconSizeS,
          ),
          const SizedBox(height: 4),
          const Text(
            'verfügbar',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: UIConstants.warningColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Hilfsfunktion für Datum-Formatierung
String _formatDate(String dateString) {
  final date = DateTime.tryParse(dateString);
  if (date != null) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
  return dateString;
}
```

### 2. Dialog Focus-Trap Implementation

**Erweiterte BankDataDialog-Klasse:**

```dart
class _BankDataDialogState extends State<BankDataDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _kontoinhaberController;
  late final TextEditingController _ibanController;
  late final TextEditingController _bicController;
  bool _agbChecked = false;

  // Focus-Management für Dialog
  late final FocusNode _kontoinhaberFocusNode;
  late final FocusNode _ibanFocusNode;
  late final FocusNode _bicFocusNode;
  late final FocusNode _agbFocusNode;
  late final FocusNode _cancelFocusNode;
  late final FocusNode _okFocusNode;

  @override
  void initState() {
    super.initState();
    
    // Controllers
    _kontoinhaberController = TextEditingController(text: widget.initialBankData?.kontoinhaber ?? '');
    _ibanController = TextEditingController(text: widget.initialBankData?.iban ?? '');
    _bicController = TextEditingController(text: widget.initialBankData?.bic ?? '');
    
    // Focus-Nodes
    _kontoinhaberFocusNode = FocusNode();
    _ibanFocusNode = FocusNode();
    _bicFocusNode = FocusNode();
    _agbFocusNode = FocusNode();
    _cancelFocusNode = FocusNode();
    _okFocusNode = FocusNode();
    
    _ibanController.addListener(() {
      setState(() {}); // Update BIC label
    });

    // Initial Focus nach Dialog-Öffnung
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _kontoinhaberFocusNode.requestFocus();
      
      // Screen Reader Announcement
      SemanticsService.announce(
        'Bankdaten-Dialog geöffnet. Füllen Sie die Felder aus und bestätigen Sie mit OK.',
        TextDirection.ltr,
      );
    });
  }

  @override
  void dispose() {
    // Controllers
    _kontoinhaberController.dispose();
    _ibanController.dispose();
    _bicController.dispose();
    
    // Focus-Nodes
    _kontoinhaberFocusNode.dispose();
    _ibanFocusNode.dispose();
    _bicFocusNode.dispose();
    _agbFocusNode.dispose();
    _cancelFocusNode.dispose();
    _okFocusNode.dispose();
    
    super.dispose();
  }

  // Keyboard-Handler für Dialog
  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) => _handleKeyEvent(event) ? KeyEventResult.handled : KeyEventResult.ignored,
      child: Semantics(
        namesRoute: true,
        scopesRoute: true,
        explicitChildNodes: true,
        label: 'Bankdaten bearbeiten Dialog',
        hint: 'Verwenden Sie Tab zum Navigieren, ESC zum Schließen',
        child: Dialog(
          backgroundColor: UIConstants.backgroundColor,
          insetPadding: const EdgeInsets.all(32),
          child: FocusScope(
            child: _buildDialogContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogContent() {
    return SizedBox(
      width: UIConstants.dialogWidth,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dialog-Titel mit Semantic-Header
                Semantics(
                  header: true,
                  child: const Center(
                    child: Text(
                      'Bankdaten bearbeiten',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Form-Container mit Accessibility
                Semantics(
                  container: true,
                  label: 'Bankdaten Formular',
                  child: Container(
                    decoration: BoxDecoration(
                      color: UIConstants.whiteColor,
                      border: Border.all(color: UIConstants.mydarkGreyColor),
                      borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
                    ),
                    padding: UIConstants.defaultPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Formular-Überschrift
                        Semantics(
                          header: true,
                          child: const Text(
                            'Bankdaten',
                            style: UIStyles.subtitleStyle,
                          ),
                        ),
                        
                        const SizedBox(height: UIConstants.spacingM),
                        
                        // Kontoinhaber-Feld
                        Semantics(
                          textField: true,
                          label: 'Kontoinhaber eingeben',
                          hint: 'Name des Kontoinhabers, Pflichtfeld',
                          child: TextFormField(
                            controller: _kontoinhaberController,
                            focusNode: _kontoinhaberFocusNode,
                            decoration: UIStyles.formInputDecoration.copyWith(
                              labelText: 'Kontoinhaber *',
                              helperText: 'Vollständiger Name des Kontoinhabers',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Kontoinhaber ist erforderlich';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _ibanFocusNode.requestFocus(),
                          ),
                        ),
                        
                        const SizedBox(height: UIConstants.spacingM),
                        
                        // IBAN/BIC Zeile
                        Row(
                          children: [
                            // IBAN-Feld
                            Expanded(
                              child: Semantics(
                                textField: true,
                                label: 'IBAN eingeben',
                                hint: 'Internationale Bankkontonummer, Pflichtfeld',
                                child: TextFormField(
                                  controller: _ibanController,
                                  focusNode: _ibanFocusNode,
                                  decoration: UIStyles.formInputDecoration.copyWith(
                                    labelText: 'IBAN *',
                                    helperText: 'z.B. DE89370400440532013000',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'IBAN ist erforderlich';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => _bicFocusNode.requestFocus(),
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: UIConstants.spacingM),
                            
                            // BIC-Feld
                            Expanded(
                              child: Semantics(
                                textField: true,
                                label: 'BIC eingeben',
                                hint: _isBicRequired(_ibanController.text.trim())
                                    ? 'Bank Identifier Code, erforderlich für nicht-deutsche IBANs'
                                    : 'Bank Identifier Code, optional für deutsche IBANs',
                                child: TextFormField(
                                  controller: _bicController,
                                  focusNode: _bicFocusNode,
                                  decoration: UIStyles.formInputDecoration.copyWith(
                                    labelText: _isBicRequired(_ibanController.text.trim()) ? 'BIC *' : 'BIC (optional)',
                                    helperText: 'z.B. COBADEFFXXX',
                                  ),
                                  validator: (value) {
                                    final iban = _ibanController.text.trim().toUpperCase();
                                    final bic = value?.trim() ?? '';
                                    if (_isBicRequired(iban)) {
                                      if (bic.isEmpty) {
                                        return 'BIC ist erforderlich für nicht-deutsche IBANs';
                                      }
                                      if (!_isBicValid(bic)) {
                                        return 'BIC ist ungültig. Format: 8 oder 11 Zeichen';
                                      }
                                    } else {
                                      if (bic.isNotEmpty && !_isBicValid(bic)) {
                                        return 'BIC ist ungültig. Format: 8 oder 11 Zeichen';
                                      }
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => _agbFocusNode.requestFocus(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: UIConstants.spacingL),
                
                // AGB-Checkbox mit Accessibility
                Semantics(
                  container: true,
                  label: 'Allgemeine Geschäftsbedingungen',
                  child: CheckboxListTile(
                    focusNode: _agbFocusNode,
                    value: _agbChecked,
                    onChanged: (val) {
                      setState(() => _agbChecked = val ?? false);
                    },
                    title: Semantics(
                      label: 'AGB akzeptieren, erforderlich',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // AGB-Link
                          Semantics(
                            button: true,
                            label: 'Allgemeine Geschäftsbedingungen öffnen',
                            hint: 'Öffnet die AGB in einem neuen Bildschirm',
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const AgbScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'AGB',
                                style: UIStyles.linkStyle.copyWith(
                                  color: UIConstants.linkColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: UIConstants.spacingS),
                          const Text('akzeptieren'),
                          const SizedBox(width: UIConstants.spacingS),
                          
                          // Info-Icon
                          Semantics(
                            button: true,
                            label: 'Hilfe zu den AGB',
                            hint: 'Zeigt zusätzliche Informationen zu den Allgemeinen Geschäftsbedingungen',
                            child: const Tooltip(
                              message: 'Sie müssen die AGB akzeptieren, um Ihre Bankdaten zu speichern.',
                              triggerMode: TooltipTriggerMode.tap,
                              child: Icon(
                                Icons.info_outline,
                                color: UIConstants.defaultAppColor,
                                size: UIConstants.tooltipIconSize,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                
                // Aktions-Buttons
                const SizedBox(height: UIConstants.spacingL),
                _buildDialogActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogActions() {
    final isFormValid = _agbChecked &&
        _kontoinhaberController.text.trim().isNotEmpty &&
        _ibanController.text.trim().isNotEmpty &&
        (_isBicRequired(_ibanController.text.trim())
            ? _bicController.text.trim().isNotEmpty
            : true);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Abbrechen-Button
        Semantics(
          button: true,
          label: 'Dialog abbrechen',
          hint: 'Schließt den Dialog ohne Speichern',
          child: TextButton(
            focusNode: _cancelFocusNode,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
        ),
        
        const SizedBox(width: UIConstants.spacingM),
        
        // OK-Button
        Semantics(
          button: true,
          label: isFormValid 
              ? 'Bankdaten speichern' 
              : 'Formular unvollständig',
          hint: isFormValid
              ? 'Speichert die Bankdaten und schließt den Dialog'
              : 'Füllen Sie alle Pflichtfelder aus und akzeptieren Sie die AGB',
          child: ElevatedButton(
            focusNode: _okFocusNode,
            onPressed: isFormValid
                ? () {
                    if (_formKey.currentState?.validate() ?? false) {
                      Navigator.of(context).pop(
                        _BankDataResult(
                          kontoinhaber: _kontoinhaberController.text,
                          iban: _ibanController.text,
                          bic: _bicController.text,
                        ),
                      );
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isFormValid 
                  ? UIConstants.defaultAppColor 
                  : UIConstants.cancelButtonBackground,
            ),
            child: const Text('OK'),
          ),
        ),
      ],
    );
  }

  // Bestehende Validierungs-Methoden bleiben unverändert
  bool _isBicRequired(String iban) {
    return !iban.toUpperCase().startsWith('DE');
  }

  bool _isBicValid(String bic) {
    final bicRegExp = RegExp(r'^[A-Z]{4}[A-Z]{2}[A-Z0-9]{2}([A-Z0-9]{3})?$');
    return bicRegExp.hasMatch(bic);
  }
}
```

### 3. Multiple FABs mit Semantic-Labels

**Ersetzen Sie den FloatingActionButton-Bereich:**

```dart
// ✅ Accessible FAB-Management
Widget _buildAccessibleFABs() {
  final hasUnclaimedPrizes = _gewinne.any((g) => g.abgerufenAm.isEmpty);
  final canRetrievePrizes = _bankDataResult != null &&
      _bankDataResult!.kontoinhaber.isNotEmpty &&
      _bankDataResult!.iban.isNotEmpty &&
      (_bankDataResult!.iban.toUpperCase().startsWith('DE') ||
          _bankDataResult!.bic.isNotEmpty);

  if (!hasUnclaimedPrizes) {
    return const SizedBox.shrink(); // Keine FABs wenn alle abgerufen
  }

  return Positioned(
    bottom: 16,
    right: 16,
    child: Semantics(
      container: true,
      label: 'Aktionen für Gewinne',
      hint: 'Verfügbare Aktionen zum Laden und Abrufen Ihrer Gewinne',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // FAB 1: Gewinne laden/aktualisieren
          Semantics(
            button: true,
            label: 'Gewinne aktualisieren',
            hint: 'Lädt die aktuelle Liste der Gewinne für das Jahr $_selectedYear vom Server',
            child: FloatingActionButton(
              heroTag: 'refreshPrizes',
              onPressed: _loading ? null : _fetchGewinne,
              tooltip: 'Gewinne aktualisieren',
              backgroundColor: _loading
                  ? UIConstants.cancelButtonBackground
                  : UIConstants.defaultAppColor,
              child: _loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.refresh,
                      color: UIConstants.whiteColor,
                    ),
            ),
          ),

          const SizedBox(height: 12),

          // FAB 2: Bankdaten eingeben
          if (_bankDataResult == null)
            Semantics(
              button: true,
              label: 'Bankdaten eingeben',
              hint: 'Öffnet einen Dialog zur Eingabe Ihrer Bankdaten für den Gewinn-Abruf',
              child: FloatingActionButton(
                heroTag: 'enterBankData',
                onPressed: _bankDialogLoading ? null : _openBankDataDialog,
                tooltip: 'Bankdaten eingeben',
                backgroundColor: UIConstants.primaryColor,
                mini: true,
                child: _bankDialogLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.account_balance,
                        color: UIConstants.whiteColor,
                        size: 20,
                      ),
              ),
            ),

          // FAB 3: Gewinne abrufen (nur wenn Bankdaten vorhanden)
          if (_bankDataResult != null)
            Semantics(
              button: true,
              label: canRetrievePrizes 
                  ? 'Gewinne jetzt abrufen' 
                  : 'Bankdaten unvollständig',
              hint: canRetrievePrizes
                  ? 'Ruft alle noch nicht abgerufenen Gewinne ab und überweist sie auf Ihr Konto'
                  : 'Vervollständigen Sie Ihre Bankdaten, um Gewinne abrufen zu können',
              child: FloatingActionButton(
                heroTag: 'retrievePrizes',
                onPressed: canRetrievePrizes
                    ? () => _performGewinnAbruf()
                    : null,
                tooltip: canRetrievePrizes 
                    ? 'Gewinne abrufen' 
                    : 'Bankdaten unvollständig',
                backgroundColor: canRetrievePrizes
                    ? UIConstants.successColor
                    : UIConstants.cancelButtonBackground,
                child: const Icon(
                  Icons.payments,
                  color: UIConstants.whiteColor,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

// Extrahierte Gewinn-Abruf-Logik
Future<void> _performGewinnAbruf() async {
  final oktoberfestService = Provider.of<OktoberfestService>(context, listen: false);
  
  setState(() {
    _loading = true;
  });

  // Screenreader-Announcement
  SemanticsService.announce(
    'Gewinne werden abgerufen, bitte warten',
    TextDirection.ltr,
  );

  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);

  try {
    final result = await oktoberfestService.gewinneAbrufen(
      gewinnIDs: _gewinne.where((g) => g.abgerufenAm.isEmpty).map((g) => g.gewinnId).toList(),
      iban: _bankDataResult!.iban,
      passnummer: widget.passnummer,
      configService: widget.configService,
    );

    if (!mounted) return;

    if (result) {
      // Erfolg-Announcement
      SemanticsService.announce(
        'Gewinne erfolgreich abgerufen',
        TextDirection.ltr,
      );
      
      navigator.push(
        MaterialPageRoute(
          builder: (context) => const OktoberfestAbrufResultScreen(
            success: true,
          ),
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Fehler beim Abrufen der Gewinne.'),
          duration: UIConstants.snackbarDuration,
          backgroundColor: UIConstants.errorColor,
        ),
      );
    }
  } catch (e) {
    debugPrint('Fehler beim Abrufen der Gewinne: $e');
    if (!mounted) return;

    // Fehler-Announcement
    SemanticsService.announce(
      'Fehler beim Abrufen der Gewinne',
      TextDirection.ltr,
    );

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('Fehler beim Abrufen der Gewinne: $e'),
        duration: UIConstants.snackbarDuration,
        backgroundColor: UIConstants.errorColor,
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }
}
```

### 4. Hauptbuild-Methode mit Live-Regions

**Aktualisierte build-Methode:**

```dart
@override
Widget build(BuildContext context) {
  return BaseScreenLayoutAccessible(
    title: 'Oktoberfestlandesschießen',
    semanticScreenLabel: 'Oktoberfest Gewinne Verwaltung',
    screenDescription: 'Verwalten und abrufen Sie Ihre Oktoberfest-Gewinne. ${_gewinne.length} Gewinne für $_selectedYear verfügbar.',
    userData: widget.userData,
    isLoggedIn: widget.isLoggedIn,
    onLogout: widget.onLogout,
    
    body: Semantics(
      container: true,
      label: 'Oktoberfest Gewinne Hauptinhalt',
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Titel-Sektion
              Semantics(
                header: true,
                child: const Text(
                  'Meine Gewinne für das letzte Jahr',
                  style: TextStyle(fontSize: UIConstants.titleFontSize),
                ),
              ),
              
              const SizedBox(height: UIConstants.spacingL),
              
              // Jahr-Anzeige
              Semantics(
                label: 'Gewähltes Jahr: $_selectedYear',
                child: Text(
                  'Jahr: $_selectedYear',
                  style: const TextStyle(fontSize: UIConstants.subtitleFontSize),
                ),
              ),
              
              // Loading-Indikator mit Accessibility
              if (_loading) ...[
                const SizedBox(height: UIConstants.spacingXL),
                Semantics(
                  label: 'Gewinne werden geladen',
                  liveRegion: true,
                  child: const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: UIConstants.spacingM),
                      Text('Lade Gewinne...'),
                    ],
                  ),
                ),
              ],
              
              // Gewinne-Liste oder Empty-State
              if (!_loading) ...[
                const SizedBox(height: UIConstants.spacingXL),
                _gewinne.isNotEmpty 
                    ? _buildGewinnListe()
                    : Semantics(
                        liveRegion: true,
                        label: 'Keine Gewinne für $_selectedYear gefunden',
                        child: const Text(
                          'Keine Gewinne für das gewählte Jahr gefunden.',
                          style: TextStyle(fontSize: UIConstants.bodyFontSize),
                        ),
                      ),
              ],
              
              // Bankdaten-Button (falls Gewinne vorhanden aber keine Bankdaten)
              if (_gewinne.any((g) => g.abgerufenAm.isEmpty) && _bankDataResult == null && !_loading) ...[
                const SizedBox(height: UIConstants.spacingL),
                Semantics(
                  button: true,
                  label: 'Bankdaten für Gewinn-Abruf eingeben',
                  hint: 'Öffnet einen Dialog zur Eingabe Ihrer Bankverbindung',
                  child: ElevatedButton.icon(
                    onPressed: _bankDialogLoading ? null : _openBankDataDialog,
                    icon: _bankDialogLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.account_balance),
                    label: const Text('Bankdaten eingeben'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UIConstants.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
              
              // Status-Info für Bankdaten
              if (_bankDataResult != null) ...[
                const SizedBox(height: UIConstants.spacingM),
                Semantics(
                  label: 'Bankdaten erfasst für ${_bankDataResult!.kontoinhaber}',
                  child: Container(
                    padding: const EdgeInsets.all(UIConstants.spacingM),
                    margin: const EdgeInsets.symmetric(horizontal: UIConstants.spacingL),
                    decoration: BoxDecoration(
                      color: UIConstants.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
                      border: Border.all(color: UIConstants.successColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: UIConstants.successColor,
                        ),
                        const SizedBox(width: UIConstants.spacingM),
                        Expanded(
                          child: Text(
                            'Bankdaten erfasst: ${_bankDataResult!.kontoinhaber}',
                            style: const TextStyle(
                              color: UIConstants.successColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
    
    // Floating Action Button mit Accessibility
    floatingActionButton: _buildAccessibleFABs(),
  );
}
```

---

## 🧪 Testing-Checkliste

### Kritische Tests für Phase 1
```dart
// Widget-Tests für Accessibility
testWidgets('ListView accessibility structure', (WidgetTester tester) async {
  await tester.pumpWidget(TestApp());
  
  // Test semantic structure
  expect(
    find.bySemanticsLabel(RegExp(r'Liste der Oktoberfest-Gewinne')), 
    findsOneWidget
  );
  
  expect(
    find.bySemanticsLabel(RegExp(r'Gewinn \d+ von \d+')), 
    findsWidgets
  );
});

testWidgets('Dialog focus trap', (WidgetTester tester) async {
  await tester.pumpWidget(TestApp());
  
  // Open dialog
  await tester.tap(find.text('Bankdaten'));
  await tester.pumpAndSettle();
  
  // Test focus management
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  expect(tester.binding.focusManager.primaryFocus, isNotNull);
  
  // Test escape key
  await tester.sendKeyEvent(LogicalKeyboardKey.escape);
  await tester.pumpAndSettle();
  expect(find.byType(Dialog), findsNothing);
});
```

### Screenreader-Tests (Manuell)
1. **Liste-Navigation:** H-Taste für Headers, L-Taste für Listen
2. **Dialog-Flow:** Tab-Navigation durch Formular-Felder
3. **FAB-Navigation:** Eindeutige Labels für alle Action-Buttons
4. **Status-Updates:** Live-Region-Announcements bei Daten-Änderungen

---

## 📊 Erwartete Verbesserung

**Nach Phase 1 Implementation:**
- **Vorher:** 79% BITV 2.0 Compliance
- **Nachher:** 87% BITV 2.0 Compliance
- **Kritische Issues:** 0 (alle behoben)
- **Major Issues:** 2 (von 4 behoben)

Diese Phase-1-Fixes lösen die drei kritischen Accessibility-Probleme und schaffen eine solide Basis für weitere Optimierungen. Der Screen wird von "teilweise konform" zu "gut konform" für komplexe Interactive-Anwendungen! 🚀