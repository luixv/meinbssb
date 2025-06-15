// Project: Mein BSSB
// Filename: bank_data_screen.dart
// Author: Luis Mandel / NTT DATA

// Flutter/Dart core imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/bank_data.dart';
import '/models/user_data.dart';
import '/screens/base_screen_layout.dart';
import '/services/api_service.dart';
import '/services/core/logger_service.dart';
import '/widgets/scaled_text.dart';

class BankDataScreen extends StatefulWidget {
  const BankDataScreen(
    this.userData, {
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });
  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  BankDataScreenState createState() => BankDataScreenState();
}

class BankDataScreenState extends State<BankDataScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasBankData = false;

  final TextEditingController _kontoinhaberController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _bicController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchBankData();
  }

  Future<void> _fetchBankData() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final data = await apiService.fetchBankdaten(widget.userData?.personId ?? 0);
      if (data.isNotEmpty) {
        _kontoinhaberController.text = data['KONTOINHABER'] as String? ?? '';
        _ibanController.text = data['IBAN'] as String? ?? '';
        _bicController.text = data['BIC'] as String? ?? '';
        setState(() {
          _hasBankData = true;
        });
      }
    } catch (e) {
      LoggerService.logError('Error setting up bank data fetch: $e');
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveBankData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final bankData = BankData(
        id: 0,
        webloginId: widget.userData?.personId ?? 0,
        kontoinhaber: _kontoinhaberController.text,
        iban: _ibanController.text,
        bic: _bicController.text,
      );

      final bool success = await apiService.registerBankData(bankData);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: ScaledText('Bankdaten erfolgreich gespeichert.'),
              duration: Duration(seconds: 3),
            ),
          );
          _fetchBankData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: ScaledText('Fehler beim Speichern der Bankdaten.'),
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
            content: ScaledText('Ein Fehler ist aufgetreten: $e'),
            duration: const Duration(seconds: 3),
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

  Future<void> _deleteBankData() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final bankData = BankData(
        id: 0,
        webloginId: widget.userData?.personId ?? 0,
        kontoinhaber: _kontoinhaberController.text,
        iban: _ibanController.text,
        bic: _bicController.text,
      );

      final bool success = await apiService.deleteBankData(bankData);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: ScaledText('Bankdaten erfolgreich gelöscht.'),
              duration: Duration(seconds: 3),
            ),
          );
          _fetchBankData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: ScaledText('Fehler beim Löschen der Bankdaten.'),
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
            content: ScaledText('Ein Fehler ist aufgetreten: $e'),
            duration: const Duration(seconds: 3),
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

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: UIConstants.backgroundColor,
          title: const Center(
            child: ScaledText(
              UIConstants.bankDataTitle,
              style: UIStyles.dialogTitleStyle,
            ),
          ),
          content: const ScaledText(
            UIConstants.deleteBankDataConfirmation,
            style: UIStyles.dialogContentStyle,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.close, color: UIConstants.closeIcon),
                  UIConstants.horizontalSpacingS,
                  ScaledText(
                    UIConstants.cancelButtonLabel,
                    style: UIStyles.dialogButtonTextStyle.copyWith(
                      color: UIConstants.closeIcon,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteBankData();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check, color: UIConstants.checkIcon),
                  UIConstants.horizontalSpacingS,
                  ScaledText(
                    UIConstants.deleteButtonLabel,
                    style: UIStyles.dialogButtonTextStyle.copyWith(
                      color: UIConstants.checkIcon,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: UIConstants.backgroundColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: UIConstants.errorColor,
                size: 48,
              ),
              const SizedBox(height: 16),
              const ScaledText(
                'Fehler beim Laden der Bankdaten',
                style: UIStyles.headerStyle,
              ),
              const SizedBox(height: 8),
              ScaledText(
                message,
                textAlign: TextAlign.center,
                style: UIStyles.bodyStyle,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const ScaledText('Zurück zum Login'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: UIConstants.bankDataTitle,
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ScaledText(
                      UIConstants.bankDataSubtitle,
                      style: UIStyles.subtitleStyle,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _kontoinhaberController,
                      decoration: UIStyles.formInputDecoration.copyWith(
                        labelText: UIConstants.kontoinhaberLabel,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return UIConstants.kontoinhaberRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ibanController,
                      decoration: UIStyles.formInputDecoration.copyWith(
                        labelText: UIConstants.ibanLabel,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return UIConstants.ibanRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bicController,
                      decoration: UIStyles.formInputDecoration.copyWith(
                        labelText: UIConstants.bicLabel,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return UIConstants.bicRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_hasBankData)
                          ElevatedButton(
                            onPressed: _isSaving ? null : _showDeleteConfirmationDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: UIConstants.errorColor,
                            ),
                            child: const ScaledText(
                              UIConstants.deleteButtonLabel,
                              style: UIStyles.buttonStyle,
                            ),
                          ),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _saveBankData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: UIConstants.primaryColor,
                          ),
                          child: ScaledText(
                            _isSaving ? UIConstants.savingLabel : UIConstants.saveButtonLabel,
                            style: UIStyles.buttonStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            key: const Key('helpFab'),
            onPressed: () {
              Navigator.pushNamed(context, '/help');
            },
            backgroundColor: UIConstants.defaultAppColor,
            child: const Icon(Icons.help_outline),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            key: const Key('settingsFab'),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            backgroundColor: UIConstants.defaultAppColor,
            child: const Icon(Icons.settings),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _kontoinhaberController.dispose();
    _ibanController.dispose();
    _bicController.dispose();
    super.dispose();
  }
}
