import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/bank_data.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/api/bank_service.dart';
import 'package:meinbssb/services/core/logger_service.dart';
import 'package:meinbssb/services/core/font_size_provider.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/screens/bank_data_result_screen.dart';
import 'package:meinbssb/widgets/scaled_text.dart';

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
    setState(() {
      _bankDataFuture =
          Future.value(null); // Clear current data to show spinner
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
          setState(() {});
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

      if (!mounted) return;
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
            duration: UIConstants.snackbarDuration,
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

  Future<void> _onDeleteBankData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final confirm = await showDialog<bool>(
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

    if (confirm == true) {
      setState(() {
        _isSaving = true;
      });

      try {
        final bankData = BankData(
          id: 0, // ID will be determined by the server
          webloginId: widget.webloginId,
          kontoinhaber: _kontoinhaberController.text,
          iban: _ibanController.text,
          bic: _bicController.text,
          mandatSeq: 2,
        );
        final bool success = await apiService.deleteBankData(bankData);

        if (!mounted) return;
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
              content: Text('Fehler beim Löschen der Bankdaten.'),
              duration: UIConstants.snackbarDuration,
              backgroundColor: UIConstants.errorColor,
            ),
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
    super.dispose();
  }

  Future<bool> _isOffline() async {
    try {
      final networkService =
          Provider.of<NetworkService>(context, listen: false);
      return !(await networkService.hasInternet());
    } catch (e) {
      LoggerService.logError('Error checking network status: $e');
      return true; // Assume offline if we can't check
    }
  }

  Widget _buildFABs() {
    if (_isEditing) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'bankDataCancelFab',
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
          const SizedBox(height: UIConstants.spacingM),
          FloatingActionButton(
            heroTag: 'bankDataSaveFab',
            onPressed: _isSaving ? null : _onSaveBankData,
            backgroundColor: UIConstants.defaultAppColor,
            child: _isSaving
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      UIConstants.circularProgressIndicator,
                    ),
                    strokeWidth: UIConstants.defaultStrokeWidth,
                  )
                : const Icon(
                    Icons.save,
                    color: Colors.white,
                  ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'bankDataDeleteFab',
            onPressed: _isSaving ? null : _onDeleteBankData,
            backgroundColor: UIConstants.defaultAppColor,
            child: _isSaving
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: UIConstants.defaultStrokeWidth,
                  )
                : const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                  ),
          ),
          const SizedBox(height: UIConstants.spacingM),
          FloatingActionButton(
            heroTag: 'bankDataEditFab',
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
      );
    }
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
                size: UIConstants.iconSizeM,
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
      body: FutureBuilder<bool>(
        future: _isOffline(),
        builder: (context, offlineSnapshot) {
          if (offlineSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if offline first
          if (offlineSnapshot.hasData && offlineSnapshot.data == true) {
            return Center(
              child: Padding(
                padding: UIConstants.screenPadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      size: UIConstants.wifiOffIconSize,
                      color: UIConstants.noConnectivityIcon,
                    ),
                    const SizedBox(height: UIConstants.spacingM),
                    ScaledText(
                      'Bankdaten sind offline nicht verfügbar',
                      style: UIStyles.headerStyle.copyWith(
                        color: UIConstants.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: UIConstants.spacingS),
                    ScaledText(
                      'Bitte stellen Sie sicher, dass Sie mit dem Internet verbunden sind, um auf Ihre Bankdaten zuzugreifen.',
                      style: UIStyles.bodyStyle.copyWith(
                        color: UIConstants.greySubtitleTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // If online, show the normal bank data form
          return FutureBuilder<BankData?>(
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
                        size: UIConstants.iconSizeM,
                      ),
                      const SizedBox(height: UIConstants.spacingM),
                      const ScaledText(
                        'Fehler beim Laden der Bankdaten',
                        style: UIStyles.headerStyle,
                      ),
                      const SizedBox(height: UIConstants.spacingS),
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
          );
        },
      ),
      floatingActionButton: FutureBuilder<bool>(
        future: _isOffline(),
        builder: (context, offlineSnapshot) {
          if (!offlineSnapshot.hasData || offlineSnapshot.data == true) {
            return const SizedBox.shrink();
          }
          return _buildFABs();
        },
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
