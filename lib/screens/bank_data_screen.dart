import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/bank_data.dart';
import '/models/user_data.dart';
import '/services/api_service.dart';
import '/services/api/bank_service.dart';
import '/services/core/logger_service.dart';
import '/services/core/font_size_provider.dart';
import '/screens/base_screen_layout.dart';
import '/screens/bank_data_result_screen.dart';
import '/widgets/scaled_text.dart';

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
  bool _hasBankData = false;

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
    setState(() {
      _bankDataFuture =
          Future.value(null); // Clear current data to show spinner
      _hasBankData = false;
    });

    if (widget.webloginId == 0) {
      setState(() {
        _bankDataFuture =
            Future.error('WebLoginID is required to fetch bank data');
      });
      return;
    }

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      _bankDataFuture =
          apiService.fetchBankData(widget.webloginId).then((list) {
        final hasData = list.isNotEmpty;
        if (mounted) {
          setState(() {
            _hasBankData = hasData;
          });
        }
        return hasData ? list.first : null;
      });
      LoggerService.logInfo(
        'BankDataScreen: Initiating bank data fetch.',
      );
    } catch (e) {
      LoggerService.logError('Error setting up bank data fetch: $e');
      _bankDataFuture = Future.value(null); // Provide null on error
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _onDeleteBankData() async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: UIConstants.backgroundColor,
          title: const Center(
            child: Text(
              'Bankdaten löschen',
              style: UIStyles.dialogTitleStyle,
            ),
          ),
          content: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: UIStyles.dialogContentStyle,
              children: <TextSpan>[
                const TextSpan(
                  text: 'Sind Sie sicher, dass Sie die Bankdaten für ',
                ),
                TextSpan(
                  text: _kontoinhaberController.text,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: ' löschen möchten?'),
              ],
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(UIConstants.spacingM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      style: UIStyles.dialogCancelButtonStyle,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.close, color: UIConstants.closeIcon),
                          UIConstants.horizontalSpacingS,
                          Text(
                            'Abbrechen',
                            style: UIStyles.dialogButtonTextStyle.copyWith(
                              color: UIConstants.cancelButtonText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  UIConstants.horizontalSpacingM,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true);
                      },
                      style: UIStyles.dialogAcceptButtonStyle,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check, color: UIConstants.checkIcon),
                          UIConstants.horizontalSpacingS,
                          Text(
                            'Löschen',
                            style: UIStyles.dialogButtonTextStyle.copyWith(
                              color: UIConstants.deleteButtonText,
                            ),
                          ),
                        ],
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

    if (!mounted) return;

    if (confirmDelete == null || !confirmDelete) {
      LoggerService.logInfo('Bank data deletion cancelled by user.');
      if (mounted) {
        setState(() {});
      }
      return;
    }

    setState(() {});

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final bankData = BankData(
        id: 0, // Will be assigned by the server
        webloginId: widget.webloginId,
        kontoinhaber: _kontoinhaberController.text,
        iban: _ibanController.text,
        bic: _bicController.text,
      );
      final bool success = await apiService.deleteBankData(bankData);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bankdaten erfolgreich gelöscht.'),
              duration: Duration(seconds: 3),
            ),
          );
          _kontoinhaberController.clear();
          _ibanController.clear();
          _bicController.clear();
          _loadInitialData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fehler beim Löschen der Bankdaten.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      LoggerService.logError('Exception during bank data deletion: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ein Fehler ist aufgetreten: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _onSaveBankData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final bankData = BankData(
        id: 0, // Will be assigned by the server
        webloginId: widget.webloginId,
        kontoinhaber: _kontoinhaberController.text,
        iban: _ibanController.text,
        bic: _bicController.text,
        mandatSeq: 2,
      );

      final bool success = await apiService.registerBankData(bankData);

      if (mounted) {
        if (success) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BankDataResultScreen(
                success: true,
                userData: widget.userData,
                isLoggedIn: widget.isLoggedIn,
                onLogout: widget.onLogout,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fehler beim Speichern der Bankdaten.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      LoggerService.logError('Exception during bank data save: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ein Fehler ist aufgetreten: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    if (widget.webloginId == 0) {
      return BaseScreenLayout(
        title: 'Bankdaten',
        userData: widget.userData,
        isLoggedIn: widget.isLoggedIn,
        onLogout: widget.onLogout,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              const ScaledText(
                'Fehler beim Laden der Bankdaten',
                style: UIStyles.headerStyle,
              ),
              const SizedBox(height: 8),
              const ScaledText(
                'Bitte melden Sie sich erneut an, um auf Ihre Bankdaten zuzugreifen.',
                textAlign: TextAlign.center,
                style: UIStyles.bodyStyle,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  widget.onLogout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const ScaledText('Zurück zum Login'),
              ),
            ],
          ),
        ),
      );
    }

    return BaseScreenLayout(
      title: 'Bankdaten',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      body: FutureBuilder<BankData?>(
        future: _bankDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const ScaledText(
                    'Fehler beim Laden der Bankdaten',
                    style: UIStyles.headerStyle,
                  ),
                  const SizedBox(height: 8),
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
      floatingActionButton: _isEditing
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: _isSaving ? null : _onSaveBankData,
                  backgroundColor: UIConstants.defaultAppColor,
                  child: _isSaving
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            UIConstants.circularProgressIndicator,
                          ),
                          strokeWidth: 2,
                        )
                      : const Icon(
                          Icons.save,
                          color: Colors.white,
                        ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_hasBankData)
                  FloatingActionButton(
                    heroTag: 'deleteFab',
                    onPressed: _onDeleteBankData,
                    backgroundColor: UIConstants.deleteIcon,
                    child: const Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                    ),
                  ),
                if (_hasBankData) const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'editFab',
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  backgroundColor: UIConstants.defaultAppColor,
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBankDataForm() {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(UIConstants.spacingM),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: UIConstants.startCrossAlignment,
                children: [
                  _buildTextField(
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
                  _buildTextField(
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
                  _buildTextField(
                    label: 'BIC',
                    controller: _bicController,
                    isReadOnly: !_isEditing,
                    validator: BankService.validateBIC,
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
        return Padding(
          padding: const EdgeInsets.only(bottom: UIConstants.spacingS),
          child: TextFormField(
            controller: controller,
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
                fontSize:
                    UIStyles.formInputDecoration.floatingLabelStyle!.fontSize! *
                        fontSizeProvider.scaleFactor,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintText: isReadOnly ? null : label,
              hintStyle: UIStyles.formInputDecoration.hintStyle?.copyWith(
                fontSize: UIStyles.formInputDecoration.hintStyle!.fontSize! *
                    fontSizeProvider.scaleFactor,
              ),
              filled: true,
            ),
            validator: validator,
            readOnly: isReadOnly,
          ),
        );
      },
    );
  }
}
