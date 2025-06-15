// Project: Mein BSSB
// Filename: bank_data_screen.dart
// Author: Luis Mandel / NTT DATA

// Flutter/Dart core imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
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
  late Future<Map<String, dynamic>> _bankDataFuture;
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
      final data = await apiService.fetchBankData(widget.userData?.personId ?? 0);
      if (data.isNotEmpty) {
        _kontoinhaberController.text = data['kontoinhaber'] as String? ?? '';
        _ibanController.text = data['iban'] as String? ?? '';
        _bicController.text = data['bic'] as String? ?? '';
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
      final bankData = {
        'personId': widget.userData?.personId ?? 0,
        'kontoinhaber': _kontoinhaberController.text,
        'iban': _ibanController.text,
        'bic': _bicController.text,
      };

      final bool success = await apiService.saveBankData(bankData);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ScaledText('Bankdaten erfolgreich gespeichert.'),
              duration: Duration(seconds: 3),
            ),
          );
          _fetchBankData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
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
            duration: Duration(seconds: 3),
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
      final bool success = await apiService.deleteBankData(widget.userData?.personId ?? 0);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ScaledText('Bankdaten erfolgreich gelöscht.'),
              duration: Duration(seconds: 3),
            ),
          );
          _fetchBankData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
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
            duration: Duration(seconds: 3),
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
          title: Center(
            child: ScaledText(
              'Bankdaten löschen',
              style: UIStyles.dialogTitleStyle,
            ),
          ),
          content: ScaledText(
            UIConstants.deleteBankDataConfirmation,
            style: UIStyles.dialogContentStyle,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.close, color: UIConstants.closeIcon),
                  UIConstants.horizontalSpacingS,
                  ScaledText(
                    'Abbrechen',
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
                  Icon(Icons.check, color: UIConstants.checkIcon),
                  UIConstants.horizontalSpacingS,
                  ScaledText(
                    'Löschen',
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

  Widget _buildIbanField() {
    return TextFormField(
      key: const Key('ibanField'),
      controller: _ibanController,
      decoration: UIStyles.formInputDecoration.copyWith(
        labelText: UIConstants.ibanLabel,
      ),
      style: UIStyles.formValueStyle,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return UIConstants.ibanRequired;
        }
        return null;
      },
    );
  }

  Widget _buildBicField() {
    return TextFormField(
      key: const Key('bicField'),
      controller: _bicController,
      decoration: UIStyles.formInputDecoration.copyWith(
        labelText: UIConstants.bicLabel,
      ),
      style: UIStyles.formValueStyle,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return UIConstants.bicRequired;
        }
        return null;
      },
    );
  }

  Widget _buildKontoinhaberField() {
    return TextFormField(
      key: const Key('kontoinhaberField'),
      controller: _kontoinhaberController,
      decoration: UIStyles.formInputDecoration.copyWith(
        labelText: UIConstants.kontoinhaberLabel,
      ),
      style: UIStyles.formValueStyle,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return UIConstants.kontoinhaberRequired;
        }
        return null;
      },
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        key: const Key('saveButton'),
        onPressed: _isSaving ? null : _saveBankData,
        style: UIStyles.primaryButtonStyle,
        child: ScaledText(
          _isSaving ? UIConstants.savingLabel : UIConstants.saveLabel,
          style: UIStyles.buttonTextStyle,
        ),
      ),
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
              padding: UIConstants.screenPadding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScaledText(
                      UIConstants.bankDataSubtitle,
                      style: UIStyles.subtitleStyle,
                    ),
                    const SizedBox(height: UIConstants.spacingM),
                    _buildIbanField(),
                    const SizedBox(height: UIConstants.spacingS),
                    _buildBicField(),
                    const SizedBox(height: UIConstants.spacingS),
                    _buildKontoinhaberField(),
                    const SizedBox(height: UIConstants.spacingM),
                    _buildSaveButton(),
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
