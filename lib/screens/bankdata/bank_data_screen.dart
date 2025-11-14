import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/bank_data.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/api/bank_service.dart';
import 'package:meinbssb/services/core/logger_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/screens/bankdata/bank_data_success_screen.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import '/widgets/keyboard_focus_fab.dart';

class BankDataScreen extends StatefulWidget {
  const BankDataScreen(
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
  BankDataScreenState createState() => BankDataScreenState();
}

class BankDataScreenState extends State<BankDataScreen> {
  late Future<BankData?> _bankDataFuture;
  bool _isEditing = false;
  bool _isSaving = false;

  final TextEditingController _kontoinhaberController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _bicController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    if (widget.webloginId == 0) {
      setState(() {
        _bankDataFuture = Future.error(
          'WebLoginID is required to fetch bank data',
        );
      });
      return;
    }
    setState(() {
      _bankDataFuture = apiService.fetchBankdatenMyBSSB(widget.webloginId).then(
        (bankDataList) {
          BankData? bankData =
              bankDataList.isNotEmpty ? bankDataList.first : null;
          if (bankData != null) {
            _kontoinhaberController.text = bankData.kontoinhaber;
            _ibanController.text = bankData.iban;
            _bicController.text = bankData.bic;
          } else {
            _kontoinhaberController.text = '';
            _ibanController.text = '';
            _bicController.text = '';
          }
          return bankData;
        },
      );
    });
  }

  Future<void> _onDeleteBankData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    
    // Show confirmation dialog
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: UIConstants.backgroundColor,
          title: const Center(
            child: Text('Bankdaten löschen', style: UIStyles.dialogTitleStyle),
          ),
          content: RichText(
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
                      hint: 'Dialog schließen und Bankdaten nicht löschen',
                      button: true,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
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
                      label: 'Löschen Button',
                      hint: 'Bankdaten unwiderruflich löschen',
                      button: true,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
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
        );
      },
    );

    if (!mounted || confirmDelete != true) {
      LoggerService.logInfo(
        'Bank data deletion cancelled or widget not mounted.',
      );
      return;
    }

    // Show spinner immediately
    setState(() {
      _isSaving = true;
    });

    LoggerService.logInfo('Starting bank data deletion...');

    // Check network status
    final isOffline = !(await apiService.hasInternet());
    LoggerService.logInfo('Network status: ${isOffline ? "offline" : "online"}');
    
    if (!mounted) return;
    
    if (isOffline) {
      LoggerService.logWarning('Cannot delete bank data while offline.');
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bankdaten können offline nicht gelöscht werden'),
          duration: UIConstants.snackbarDuration,
          backgroundColor: UIConstants.errorColor,
        ),
      );
      return;
    }

    try {
      // Perform deletion
      LoggerService.logInfo('Calling deleteBankData...');
      final bankData = BankData(
        id: 0,
        webloginId: widget.webloginId,
        kontoinhaber: _kontoinhaberController.text,
        iban: _ibanController.text,
        bic: _bicController.text,
        mandatSeq: 2,
      );
      final bool success = await apiService.deleteBankData(bankData);
      LoggerService.logInfo('deleteBankData result: $success');

      if (!mounted) {
        LoggerService.logWarning('Widget not mounted after deleteBankData.');
        return;
      }

      if (success) {
        LoggerService.logInfo('Bank data deleted successfully.');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BankDataSuccessScreen(
              success: true,
              userData: widget.userData,
              isLoggedIn: widget.isLoggedIn,
              onLogout: widget.onLogout,
            ),
          ),
        );
      } else {
        LoggerService.logWarning('Failed to delete bank data.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim Löschen der Bankdaten.'),
            duration: UIConstants.snackbarDuration,
            backgroundColor: UIConstants.errorColor,
          ),
        );
      }
    } catch (e) {
      LoggerService.logError('Exception during bank data deletion: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ein Fehler ist aufgetreten: $e'),
            duration: UIConstants.snackbarDuration,
            backgroundColor: UIConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _onSaveBankData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    // Check offline status before saving
    final apiService = Provider.of<ApiService>(context, listen: false);
    final isOffline = !(await apiService.hasInternet());
    if (isOffline) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bankdaten können offline nicht gespeichert werden'),
          duration: UIConstants.snackbarDuration,
          backgroundColor: UIConstants.errorColor,
        ),
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
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => BankDataSuccessScreen(
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
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isEditing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _kontoinhaberController.dispose();
    _ibanController.dispose();
    _bicController.dispose();
    super.dispose();
  }

  Widget _buildFABs() {
    if (_isEditing) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          KeyboardFocusFAB(
            heroTag: 'bankDataCancelFab',
            tooltip: 'Bearbeitung abbrechen',
            semanticLabel: 'Abbrechen Button',
            semanticHint: 'Bearbeitung abbrechen und Änderungen verwerfen',
            icon: Icons.close,
            onPressed: () {
              setState(() {
                _isEditing = false;
                _kontoinhaberController.clear();
                _ibanController.clear();
                _bicController.clear();
                _loadInitialData();
              });
            },
          ),
          const SizedBox(height: UIConstants.spacingM),

          KeyboardFocusFAB(
            heroTag: 'bankDataSaveFab',
            tooltip: 'Bankdaten speichern',
            semanticLabel: 'Speichern Button',
            semanticHint: 'Bankdaten speichern',
            onPressed: _isSaving ? null : _onSaveBankData,
            child: _isSaving
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      UIConstants.circularProgressIndicator,
                    ),
                    strokeWidth: UIConstants.defaultStrokeWidth,
                  )
                : const Icon(
                    Icons.save,
                    color: UIConstants.whiteColor,
                  ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          KeyboardFocusFAB(
            heroTag: 'bankDataDeleteFab',
            tooltip: 'Bankdaten löschen',
            semanticLabel: 'Bankdaten löschen',
            onPressed: _isSaving ? null : _onDeleteBankData,
            child: _isSaving
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      UIConstants.whiteColor,
                    ),
                    strokeWidth: UIConstants.defaultStrokeWidth,
                  )
                : const Icon(
                    Icons.delete_outline,
                    color: UIConstants.whiteColor,
                  ),
          ),
          const SizedBox(height: UIConstants.spacingM),
          KeyboardFocusFAB(
            heroTag: 'bankDataEditFab',
            tooltip: 'Bankdaten bearbeiten',
            semanticLabel: 'Bankdaten bearbeiten',
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            },
            icon: Icons.edit,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap entire content in a Stack
    return Stack(
      children: [
        Semantics(
          container: true,
          liveRegion: true,
          child: BaseScreenLayout(
            title: 'Bankdaten',
            userData: widget.userData,
            isLoggedIn: widget.isLoggedIn,
            onLogout: widget.onLogout,
            body: Focus(
              autofocus: true,
              child: Semantics(
                label:
                    'Bankdatenbereich. Hier können Sie Ihre Kontoinformationen wie Kontoinhaber, IBAN und BIC einsehen und bearbeiten.',
                child:
                    widget.webloginId == 0
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: UIConstants.errorColor,
                                size: UIConstants.iconSizeL,
                              ),
                              const SizedBox(height: UIConstants.spacingM),
                              const ScaledText(
                                'Fehler beim Laden der Bankdaten',
                                style: UIStyles.headerStyle,
                              ),
                              const SizedBox(height: UIConstants.spacingS),
                              const ScaledText(
                                'Bitte melden Sie sich erneut an, um auf Ihre Bankdaten zuzugreifen.',
                                textAlign: TextAlign.center,
                                style: UIStyles.bodyStyle,
                              ),
                              const SizedBox(height: UIConstants.spacingM),
                              ElevatedButton(
                                onPressed: () {
                                  widget.onLogout();
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/login',
                                  );
                                },
                                child: const ScaledText('Zurück zum Login'),
                              ),
                            ],
                          ),
                        )
                        : FutureBuilder<BankData?>(
                          future: _bankDataFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: UIConstants.errorColor,
                                      size: UIConstants.iconSizeL,
                                    ),
                                    const SizedBox(
                                      height: UIConstants.spacingM,
                                    ),
                                    const ScaledText(
                                      'Fehler beim Laden der Bankdaten',
                                      style: UIStyles.headerStyle,
                                    ),
                                    const SizedBox(
                                      height: UIConstants.spacingS,
                                    ),
                                    ScaledText(
                                      snapshot.error.toString(),
                                      textAlign: TextAlign.center,
                                      style: UIStyles.bodyStyle,
                                    ),
                                  ],
                                ),
                              );
                            }
                            if (snapshot.hasData && snapshot.data != null) {
                              final bankData = snapshot.data!;
                              if (!_isEditing) {
                                _kontoinhaberController.text =
                                    bankData.kontoinhaber;
                                _ibanController.text = bankData.iban;
                                _bicController.text = bankData.bic;
                              }
                              return _buildBankDataForm();
                            } else {
                              return _buildBankDataForm();
                            }
                          },
                        ),
              ),
            ),
            floatingActionButton: _buildFABs(),
          ),
        ),
        // Whole-screen overlay spinner
        if (_isSaving)
          Positioned.fill(
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
      ],
    );
  }

  Widget _buildBankDataForm() {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return Padding(
          padding: UIConstants.defaultPadding,
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    hint:
                        !_isEditing
                            ? 'Dieses Feld ist nicht bearbeitbar.'
                            : 'Bitte geben Sie den Kontoinhaber ein.',
                    textField: true,
                  child: _buildTextField(
                      label: 'Kontoinhaber',
                      controller: _kontoinhaberController,
                      isReadOnly: !_isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kontoinhaber ist erforderlich';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingS),
                  Semantics(
                    hint:
                        !_isEditing
                            ? 'Dieses Feld ist nicht bearbeitbar.'
                            : 'Bitte geben Sie Ihre IBAN ein.',
                    textField: true,
                  child: _buildTextField(
                      label: 'IBAN',
                      controller: _ibanController,
                      isReadOnly: !_isEditing,
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
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    hint:
                        !_isEditing
                            ? 'Dieses Feld ist nicht bearbeitbar.'
                            : 'Bitte geben Sie Ihre BIC ein.',
                    textField: true,
                  child: _buildTextField(
                      label: 'BIC',
                      controller: _bicController,
                      isReadOnly: !_isEditing,
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
                  ),
                ],
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
    String? Function(String?)? validator,
    bool isReadOnly = false,
  }) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return _BankDataKeyboardTextField(
          label: label,
          controller: controller,
          validator: validator,
          isReadOnly: isReadOnly,
          fontSizeProvider: fontSizeProvider,
        );
      },
    );
  }
}

class _BankDataKeyboardTextField extends StatefulWidget {
  const _BankDataKeyboardTextField({
    required this.label,
    required this.controller,
    this.validator,
    this.isReadOnly = false,
    required this.fontSizeProvider,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool isReadOnly;
  final FontSizeProvider fontSizeProvider;

  @override
  State<_BankDataKeyboardTextField> createState() =>
      _BankDataKeyboardTextFieldState();
}

class _BankDataKeyboardTextFieldState extends State<_BankDataKeyboardTextField> {
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

    if (_focusNode.hasFocus && !widget.isReadOnly) {
      final text = widget.controller.text;
      widget.controller.selection = TextSelection.collapsed(
        offset: text.length,
      );
    }
  }

  OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardMode =
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    final hasKeyboardFocus = _isFocused && isKeyboardMode;

    final baseFillColor = widget.isReadOnly ? Colors.grey.shade100 : UIConstants.whiteColor;

    final decoration = UIStyles.formInputDecoration.copyWith(
      labelText: widget.label,
      labelStyle: UIStyles.formInputDecoration.labelStyle?.copyWith(
        fontSize:
            UIStyles.formInputDecoration.labelStyle!.fontSize! *
            widget.fontSizeProvider.scaleFactor,
      ),
      floatingLabelStyle:
          UIStyles.formInputDecoration.floatingLabelStyle?.copyWith(
        fontSize:
            UIStyles.formInputDecoration.floatingLabelStyle!.fontSize! *
            widget.fontSizeProvider.scaleFactor,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintText: widget.isReadOnly ? null : widget.label,
      hintStyle: UIStyles.formInputDecoration.hintStyle?.copyWith(
        fontSize:
            UIStyles.formInputDecoration.hintStyle!.fontSize! *
            widget.fontSizeProvider.scaleFactor,
      ),
      filled: true,
      fillColor: hasKeyboardFocus ? Colors.yellow.shade50 : baseFillColor,
      enabledBorder: _border(UIConstants.mydarkGreyColor, 1.0),
      focusedBorder: _border(
        hasKeyboardFocus ? Colors.yellow.shade700 : UIConstants.primaryColor,
        hasKeyboardFocus ? 2.5 : 1.5,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingS),
      child: TextFormField(
        focusNode: _focusNode,
        controller: widget.controller,
        style: widget.isReadOnly
            ? UIStyles.formValueBoldStyle.copyWith(
                fontSize:
                    UIStyles.formValueBoldStyle.fontSize! *
                    widget.fontSizeProvider.scaleFactor,
              )
            : UIStyles.formValueStyle.copyWith(
                fontSize:
                    UIStyles.formValueStyle.fontSize! *
                    widget.fontSizeProvider.scaleFactor,
              ),
        decoration: decoration,
        validator: widget.validator,
        readOnly: widget.isReadOnly,
      ),
    );
  }
}
