import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/bank_data.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/api/bank_service.dart';
import 'package:meinbssb/services/core/logger_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/screens/base_screen_layout_accessible.dart';
import 'package:meinbssb/screens/bank_data_success_screen_accessible.dart';
import 'package:meinbssb/widgets/scaled_text.dart';

class BankDataScreenAccessible extends StatefulWidget {
  const BankDataScreenAccessible(
    this.userData, {
    required this.webloginId,
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });

  final UserData? userData;
  final int webloginId;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  BankDataScreenAccessibleState createState() =>
      BankDataScreenAccessibleState();
}

class BankDataScreenAccessibleState extends State<BankDataScreenAccessible> {
  late Future<BankData?> _bankDataFuture;
  bool _isEditing = false;
  bool _isSaving = false;

  final TextEditingController _kontoinhaberController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _bicController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Focus nodes for accessibility
  final FocusNode _kontoinhaberFocus = FocusNode();
  final FocusNode _ibanFocus = FocusNode();
  final FocusNode _bicFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    // Announce screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SemanticsService.announce(
        'Bankdaten Bildschirm geladen. ${_isEditing ? "Bearbeitungsmodus aktiv" : "Nur-Lesen-Modus aktiv"}',
        TextDirection.ltr,
      );
    });
  }

  void _loadInitialData() {
    setState(() {
      _bankDataFuture = Future.value(null);
    });

    if (widget.webloginId == 0) {
      setState(() {
        _bankDataFuture =
            Future.error('WebLoginID is required to fetch bank data');
      });
      // Announce error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SemanticsService.announce(
          'Fehler: WebLogin-ID ist erforderlich zum Laden der Bankdaten',
          TextDirection.ltr,
        );
      });
      return;
    }

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      _bankDataFuture =
          apiService.fetchBankData(widget.webloginId).then((list) {
        final hasData = list.isNotEmpty;
        if (mounted) {
          setState(() {});
          // Announce data load result
          WidgetsBinding.instance.addPostFrameCallback((_) {
            SemanticsService.announce(
              hasData
                  ? 'Bankdaten erfolgreich geladen'
                  : 'Keine Bankdaten vorhanden',
              TextDirection.ltr,
            );
          });
        }
        return hasData ? list.first : null;
      });
      LoggerService.logInfo(
        'BankDataScreenAccessible: Initiating bank data fetch.',
      );
    } catch (e) {
      LoggerService.logError('Error setting up bank data fetch: $e');
      _bankDataFuture = Future.value(null);
      if (mounted) {
        setState(() {});
        // Announce error
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SemanticsService.announce(
            'Fehler beim Laden der Bankdaten: $e',
            TextDirection.ltr,
          );
        });
      }
    }
  }

  Future<void> _onSaveBankData() async {
    if (!_formKey.currentState!.validate()) {
      // Announce validation errors
      SemanticsService.announce(
        'Formular enthält Fehler. Bitte korrigieren Sie die markierten Felder',
        TextDirection.ltr,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Announce save start
    SemanticsService.announce(
      'Speichere Bankdaten. Bitte warten',
      TextDirection.ltr,
    );

    // Check offline status before saving
    final networkService = Provider.of<NetworkService>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);
    final isOffline = !(await networkService.hasInternet());
    if (isOffline) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bankdaten können offline nicht gespeichert werden'),
          duration: UIConstants.snackbarDuration,
          backgroundColor: UIConstants.errorColor,
        ),
      );
      // Announce offline error
      SemanticsService.announce(
        'Fehler: Bankdaten können offline nicht gespeichert werden',
        TextDirection.ltr,
      );
      // turn off spinner if offline
      setState(() {
        _isSaving = false;
      });
      return;
    }

    try {
      final bankData = BankData(
        id: 0,
        webloginId: widget.webloginId,
        kontoinhaber: _kontoinhaberController.text,
        iban: _ibanController.text,
        bic: _bicController.text,
        mandatSeq: 2,
      );

      final bool success = await apiService.registerBankData(bankData);

      if (!mounted) return;
      if (success) {
        // Announce success before navigation
        SemanticsService.announce(
          'Bankdaten erfolgreich gespeichert. Weiterleitung zur Bestätigung',
          TextDirection.ltr,
        );
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BankDataSuccessScreenAccessible(
              success: true,
              userData: widget.userData,
              isLoggedIn: widget.isLoggedIn,
              onLogout: widget.onLogout,
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim Speichern der Bankdaten.'),
            duration: UIConstants.snackbarDuration,
            backgroundColor: UIConstants.errorColor,
          ),
        );
        SemanticsService.announce(
          'Fehler beim Speichern der Bankdaten',
          TextDirection.ltr,
        );
      }
    } catch (e) {
      LoggerService.logError('Exception during bank data save: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ein Fehler ist aufgetreten: $e'),
          duration: UIConstants.snackbarDuration,
          backgroundColor: UIConstants.errorColor,
        ),
      );
      SemanticsService.announce(
        'Ein Fehler ist aufgetreten: $e',
        TextDirection.ltr,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isEditing = false;
        });
        // Announce mode change
        SemanticsService.announce(
          'Wechsel zum Nur-Lesen-Modus',
          TextDirection.ltr,
        );
      }
    }
  }

  Future<void> _onDeleteBankData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final networkService = Provider.of<NetworkService>(context, listen: false);

    // Announce dialog opening
    SemanticsService.announce(
      'Bestätigungsdialog geöffnet für Bankdaten löschen',
      TextDirection.ltr,
    );

    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Semantics(
          scopesRoute: true,
          explicitChildNodes: true,
          label: 'Bestätigungsdialog für Bankdaten löschen',
          child: AlertDialog(
            backgroundColor: UIConstants.backgroundColor,
            title: Semantics(
              header: true,
              child: const Center(
                child: Text(
                  'Bankdaten löschen',
                  style: UIStyles.dialogTitleStyle,
                ),
              ),
            ),
            content: Semantics(
              liveRegion: true,
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: UIStyles.dialogContentStyle,
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          'Sind Sie sicher, dass Sie Ihre Bankdaten löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.',
                    ),
                  ],
                ),
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
                    Semantics(
                      button: true,
                      label:
                          'Abbrechen Button. Schließt den Dialog ohne Änderungen',
                      hint: 'Doppeltippen zum Abbrechen',
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: UIConstants.defaultButtonHeight,
                        ),
                        child: ElevatedButton(
                          onPressed: _isSaving
                              ? null
                              : () {
                                  SemanticsService.announce(
                                    'Löschen abgebrochen',
                                    TextDirection.ltr,
                                  );
                                  Navigator.of(dialogContext).pop(false);
                                },
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
                              Semantics(
                                excludeSemantics: true,
                                child: const Icon(
                                  Icons.close,
                                  color: UIConstants.closeIcon,
                                  size: UIConstants.defaultIconSize,
                                ),
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
                    Semantics(
                      button: true,
                      label:
                          'Löschen Button. Löscht die Bankdaten unwiderruflich',
                      hint: 'Doppeltippen zum endgültigen Löschen',
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: UIConstants.defaultButtonHeight,
                        ),
                        child: ElevatedButton(
                          onPressed: _isSaving
                              ? null
                              : () {
                                  SemanticsService.announce(
                                    'Bankdaten werden gelöscht',
                                    TextDirection.ltr,
                                  );
                                  Navigator.of(dialogContext).pop(true);
                                },
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
                              Semantics(
                                excludeSemantics: true,
                                child: const Icon(
                                  Icons.check,
                                  color: UIConstants.checkIcon,
                                  size: UIConstants.defaultIconSize,
                                ),
                              ),
                              const SizedBox(width: UIConstants.spacingS),
                              Text(
                                'Löschen',
                                style: UIStyles.dialogButtonTextStyle.copyWith(
                                  color: UIConstants.deleteButtonText,
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
          ),
        );
      },
    );

    if (!mounted) return;

    if (confirm == true) {
      final isOffline = !(await networkService.hasInternet());
      if (isOffline) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bankdaten können offline nicht gelöscht werden'),
            duration: UIConstants.snackbarDuration,
            backgroundColor: UIConstants.errorColor,
          ),
        );
        SemanticsService.announce(
          'Fehler: Bankdaten können offline nicht gelöscht werden',
          TextDirection.ltr,
        );
        return;
      }
      setState(() {
        _isSaving = true;
      });

      SemanticsService.announce(
        'Lösche Bankdaten. Bitte warten',
        TextDirection.ltr,
      );

      try {
        final bankData = BankData(
          id: 0,
          webloginId: widget.webloginId,
          kontoinhaber: _kontoinhaberController.text,
          iban: _ibanController.text,
          bic: _bicController.text,
          mandatSeq: 2,
        );
        final bool success = await apiService.deleteBankData(bankData);
        if (!mounted) return;
        if (success) {
          SemanticsService.announce(
            'Bankdaten erfolgreich gelöscht. Weiterleitung zur Bestätigung',
            TextDirection.ltr,
          );
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BankDataSuccessScreenAccessible(
                success: true,
                userData: widget.userData,
                isLoggedIn: widget.isLoggedIn,
                onLogout: widget.onLogout,
              ),
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fehler beim Löschen der Bankdaten.'),
              duration: UIConstants.snackbarDuration,
              backgroundColor: UIConstants.errorColor,
            ),
          );
          SemanticsService.announce(
            'Fehler beim Löschen der Bankdaten',
            TextDirection.ltr,
          );
        }
      } catch (e) {
        LoggerService.logError('Exception during bank data delete: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ein Fehler ist aufgetreten: $e'),
            duration: UIConstants.snackbarDuration,
            backgroundColor: UIConstants.errorColor,
          ),
        );
        SemanticsService.announce(
          'Ein Fehler ist aufgetreten: $e',
          TextDirection.ltr,
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _kontoinhaberController.dispose();
    _ibanController.dispose();
    _bicController.dispose();
    _kontoinhaberFocus.dispose();
    _ibanFocus.dispose();
    _bicFocus.dispose();
    super.dispose();
  }

  Widget _buildFABs() {
    if (_isEditing) {
      return Semantics(
        container: true,
        label: 'Aktionsbuttons für Bearbeitungsmodus',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Semantics(
              button: true,
              label: 'Bearbeitung abbrechen',
              hint:
                  'Doppeltippen um Änderungen zu verwerfen und Bearbeitungsmodus zu verlassen',
              child: FloatingActionButton(
                heroTag: 'bankDataCancelFab',
                onPressed: () {
                  SemanticsService.announce(
                    'Bearbeitung abgebrochen. Zurück zum Nur-Lesen-Modus',
                    TextDirection.ltr,
                  );
                  setState(() {
                    _isEditing = false;
                    _kontoinhaberController.clear();
                    _ibanController.clear();
                    _bicController.clear();
                    _loadInitialData();
                  });
                },
                backgroundColor: UIConstants.defaultAppColor,
                child: const Icon(
                  Icons.close,
                  color: UIConstants.whiteColor,
                  semanticLabel: 'Abbrechen Icon',
                ),
              ),
            ),
            const SizedBox(height: UIConstants.spacingM),
            Semantics(
              button: true,
              label: 'Bankdaten speichern',
              hint: 'Doppeltippen um die eingegebenen Bankdaten zu speichern',
              child: FloatingActionButton(
                heroTag: 'bankDataSaveFab',
                onPressed: _isSaving ? null : _onSaveBankData,
                backgroundColor: UIConstants.defaultAppColor,
                child: _isSaving
                    ? Semantics(
                        label: 'Speichern läuft',
                        liveRegion: true,
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            UIConstants.circularProgressIndicator,
                          ),
                          strokeWidth: UIConstants.defaultStrokeWidth,
                        ),
                      )
                    : const Icon(
                        Icons.save,
                        color: UIConstants.whiteColor,
                        semanticLabel: 'Speichern Icon',
                      ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Semantics(
        container: true,
        label: 'Aktionsbuttons für Ansichtsmodus',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Semantics(
              button: true,
              label: 'Bankdaten löschen',
              hint: 'Doppeltippen um die gespeicherten Bankdaten zu löschen',
              child: FloatingActionButton(
                heroTag: 'bankDataDeleteFab',
                onPressed: _isSaving ? null : _onDeleteBankData,
                backgroundColor: UIConstants.defaultAppColor,
                child: _isSaving
                    ? Semantics(
                        label: 'Löschen läuft',
                        liveRegion: true,
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            UIConstants.whiteColor,
                          ),
                          strokeWidth: UIConstants.defaultStrokeWidth,
                        ),
                      )
                    : const Icon(
                        Icons.delete_outline,
                        color: UIConstants.whiteColor,
                        semanticLabel: 'Löschen Icon',
                      ),
              ),
            ),
            const SizedBox(height: UIConstants.spacingM),
            Semantics(
              button: true,
              label: 'Bankdaten bearbeiten',
              hint: 'Doppeltippen um in den Bearbeitungsmodus zu wechseln',
              child: FloatingActionButton(
                heroTag: 'bankDataEditFab',
                onPressed: () {
                  SemanticsService.announce(
                    'Wechsel zum Bearbeitungsmodus. Felder können jetzt geändert werden',
                    TextDirection.ltr,
                  );
                  setState(() {
                    _isEditing = true;
                  });
                  // Focus on first field
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _kontoinhaberFocus.requestFocus();
                  });
                },
                backgroundColor: UIConstants.defaultAppColor,
                child: const Icon(
                  Icons.edit,
                  color: UIConstants.whiteColor,
                  semanticLabel: 'Bearbeiten Icon',
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap entire content in a Stack
    return Semantics(
      label: 'Bankdaten Bildschirm',
      child: Stack(
        children: [
          BaseScreenLayoutAccessible(
            title: 'Bankdaten',
            userData: widget.userData,
            isLoggedIn: widget.isLoggedIn,
            onLogout: widget.onLogout,
            body: widget.webloginId == 0
                ? Semantics(
                    liveRegion: true,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Semantics(
                            label: 'Fehler Icon',
                            child: const Icon(
                              Icons.error_outline,
                              color: UIConstants.errorColor,
                              size: UIConstants.iconSizeL,
                            ),
                          ),
                          const SizedBox(height: UIConstants.spacingM),
                          Semantics(
                            header: true,
                            child: const ScaledText(
                              'Fehler beim Laden der Bankdaten',
                              style: UIStyles.headerStyle,
                            ),
                          ),
                          const SizedBox(height: UIConstants.spacingS),
                          const ScaledText(
                            'Bitte melden Sie sich erneut an, um auf Ihre Bankdaten zuzugreifen.',
                            textAlign: TextAlign.center,
                            style: UIStyles.bodyStyle,
                          ),
                          const SizedBox(height: UIConstants.spacingM),
                          Semantics(
                            button: true,
                            label: 'Zurück zum Login',
                            hint:
                                'Doppeltippen um zur Anmeldungsseite zurückzukehren',
                            child: ElevatedButton(
                              onPressed: () {
                                SemanticsService.announce(
                                  'Weiterleitung zum Login',
                                  TextDirection.ltr,
                                );
                                widget.onLogout();
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
                                );
                              },
                              child: const ScaledText('Zurück zum Login'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : FutureBuilder<BankData?>(
                    future: _bankDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Semantics(
                          liveRegion: true,
                          label: 'Bankdaten werden geladen',
                          child:
                              const Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.hasError) {
                        return Semantics(
                          liveRegion: true,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Semantics(
                                  label: 'Fehler Icon',
                                  child: const Icon(
                                    Icons.error_outline,
                                    color: UIConstants.errorColor,
                                    size: UIConstants.iconSizeL,
                                  ),
                                ),
                                const SizedBox(height: UIConstants.spacingM),
                                Semantics(
                                  header: true,
                                  child: const ScaledText(
                                    'Fehler beim Laden der Bankdaten',
                                    style: UIStyles.headerStyle,
                                  ),
                                ),
                                const SizedBox(height: UIConstants.spacingS),
                                ScaledText(
                                  snapshot.error.toString(),
                                  textAlign: TextAlign.center,
                                  style: UIStyles.bodyStyle,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasData && snapshot.data != null) {
                        final bankData = snapshot.data!;
                        if (!_isEditing) {
                          _kontoinhaberController.text = bankData.kontoinhaber;
                          _ibanController.text = bankData.iban;
                          _bicController.text = bankData.bic;
                        }
                        return _buildBankDataForm();
                      } else {
                        return _buildBankDataForm();
                      }
                    },
                  ),
            floatingActionButton: _buildFABs(),
          ),
          // Whole-screen overlay spinner
          if (_isSaving)
            Semantics(
              liveRegion: true,
              label: 'Speichervorgang läuft',
              child: Positioned.fill(
                child: Container(
                  color: UIConstants.textColor.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        UIConstants.circularProgressIndicator,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBankDataForm() {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return Semantics(
          label:
              'Bankdaten Formular. ${_isEditing ? "Bearbeitungsmodus" : "Nur-Lesen-Modus"}',
          child: Padding(
            padding: const EdgeInsets.all(UIConstants.spacingM),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode
                  .onUserInteraction, // Enable real-time validation
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      container: true,
                      label: 'Bankdaten Eingabefelder',
                      child: Column(
                        children: [
                          _buildTextField(
                            label: 'Kontoinhaber',
                            controller: _kontoinhaberController,
                            focusNode: _kontoinhaberFocus,
                            isReadOnly: !_isEditing,
                            description:
                                'Name des Kontoinhabers für die Bankverbindung',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Kontoinhaber ist erforderlich';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            label: 'IBAN',
                            controller: _ibanController,
                            focusNode: _ibanFocus,
                            isReadOnly: !_isEditing,
                            description:
                                'Internationale Bankkontonummer, beginnt mit Ländercode wie DE',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'IBAN ist erforderlich';
                              }
                              if (!BankService.validateIBAN(value)) {
                                return 'Ungültige IBAN';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            label: 'BIC',
                            controller: _bicController,
                            focusNode: _bicFocus,
                            isReadOnly: !_isEditing,
                            description:
                                'Bank Identifier Code. Bei deutschen IBANs optional',
                            validator: (value) {
                              String ibanText = _ibanController.text.trim();

                              // For German IBAN, BIC optional
                              if (ibanText.startsWith('DE')) {
                                // BIC optional; validate only if provided
                                if (value == null || value.isEmpty) {
                                  return null;
                                }
                                return BankService.validateBIC(value);
                              } else {
                                // For non-German IBAN, BIC required
                                if (value == null || value.isEmpty) {
                                  return 'Bitte geben Sie die BIC ein';
                                }
                                return BankService.validateBIC(value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_isEditing) ...[
                      const SizedBox(height: UIConstants.spacingL),
                      Semantics(
                        container: true,
                        label: 'Hinweise zur Eingabe',
                        child: Container(
                          padding: const EdgeInsets.all(UIConstants.spacingM),
                          decoration: BoxDecoration(
                            color: UIConstants.backgroundColor.withOpacity(0.1),
                            border: Border.all(
                              color: UIConstants.textColor.withOpacity(0.3),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Semantics(
                                header: true,
                                child: const ScaledText(
                                  'Hinweise zur Eingabe:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: UIConstants.spacingS),
                              const ScaledText(
                                '• Kontoinhaber: Vollständiger Name wie auf dem Kontoauszug',
                                style: UIStyles.bodyStyle,
                              ),
                              const ScaledText(
                                '• IBAN: 22-stellige Nummer mit Ländercode (z.B. DE89 3704 0044 0532 0130 00)',
                                style: UIStyles.bodyStyle,
                              ),
                              const ScaledText(
                                '• BIC: 8 oder 11-stelliger Code (bei deutschen Konten oft optional)',
                                style: UIStyles.bodyStyle,
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
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    String? Function(String?)? validator,
    bool isReadOnly = false,
    String? description,
  }) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return Semantics(
          textField: true,
          label: '$label${isReadOnly ? " (nur lesbar)" : ""}',
          hint: description ?? '',
          child: Padding(
            padding: const EdgeInsets.only(bottom: UIConstants.spacingS),
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              style: isReadOnly
                  ? UIStyles.formValueBoldStyle.copyWith(
                      fontSize: UIStyles.formValueBoldStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                    )
                  : UIStyles.formValueStyle.copyWith(
                      fontSize: UIStyles.formValueStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                    ),
              decoration: UIStyles.formInputDecoration.copyWith(
                labelText: label,
                labelStyle: UIStyles.formInputDecoration.labelStyle?.copyWith(
                  fontSize: UIStyles.formInputDecoration.labelStyle!.fontSize! *
                      fontSizeProvider.scaleFactor,
                ),
                floatingLabelStyle:
                    UIStyles.formInputDecoration.floatingLabelStyle?.copyWith(
                  fontSize: UIStyles
                          .formInputDecoration.floatingLabelStyle!.fontSize! *
                      fontSizeProvider.scaleFactor,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: isReadOnly ? null : description ?? label,
                hintStyle: UIStyles.formInputDecoration.hintStyle?.copyWith(
                  fontSize: UIStyles.formInputDecoration.hintStyle!.fontSize! *
                      fontSizeProvider.scaleFactor,
                ),
                filled: true,
                helperText: isReadOnly
                    ? 'Nur lesbar - zum Bearbeiten Edit-Button drücken'
                    : description,
                helperStyle: TextStyle(
                  fontSize: 12 * fontSizeProvider.scaleFactor,
                  color: UIConstants.textColor.withOpacity(0.6),
                ),
              ),
              validator: validator,
              readOnly: isReadOnly,
              onTap: isReadOnly
                  ? () {
                      SemanticsService.announce(
                        'Feld ist nur lesbar. Zum Bearbeiten den Edit-Button verwenden',
                        TextDirection.ltr,
                      );
                    }
                  : null,
              onChanged: _isEditing
                  ? (value) {
                      // Announce changes for screen readers
                      if (value.isNotEmpty) {
                        // Delayed announcement to avoid spam
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (controller.text == value) {
                            // Only announce if value hasn't changed
                            SemanticsService.announce(
                              '$label geändert',
                              TextDirection.ltr,
                            );
                          }
                        });
                      }
                    }
                  : null,
            ),
          ),
        );
      },
    );
  }
}
