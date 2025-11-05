import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/services/api_service.dart';

import '/models/gewinn_data.dart';
import '/constants/ui_styles.dart';
import '../base_screen_layout.dart';
import '/models/user_data.dart';
import '/models/bank_data.dart';
import '/constants/ui_constants.dart';

// import 'agb_screen.dart';
import '/widgets/dialog_fabs.dart';
import '/widgets/scaled_text.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

class OktoberfestGewinnScreen extends StatefulWidget {
  const OktoberfestGewinnScreen({
    super.key,
    required this.passnummer,
    required this.apiService,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });
  final String passnummer;
  final ApiService apiService;
  final UserData? userData;
  final bool isLoggedIn;
  final VoidCallback onLogout;

  @override
  State<OktoberfestGewinnScreen> createState() =>
      _OktoberfestGewinnScreenState();
}

class _OktoberfestGewinnScreenState extends State<OktoberfestGewinnScreen> {
  int _selectedYear = 2025;
  bool _loading = false;
  // Removed _hasFetchedData, no auto-fetch
  final List<Gewinn> _gewinne = [];
  _BankDataResult? _bankDataResult;

  @override
  void initState() {
    super.initState();
    // Ensure 2025 is preselected
    _selectedYear = 2025;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // No automatic fetch
  }

  bool _bankDialogLoading = false;

  Future<void> _openBankDataDialog() async {
    setState(() {
      _bankDialogLoading = true;
    });
    final apiService = Provider.of<ApiService>(context, listen: false);
    final userData = widget.userData;
    BankData? bankData;
    if (userData != null) {
      final bankList = await apiService.fetchBankdatenMyBSSB(
        userData.webLoginId,
      );
      if (bankList.isNotEmpty) {
        bankData = bankList.first;
      }
    }
    setState(() {
      _bankDialogLoading = false;
    });
    final result = await showDialog<_BankDataResult>(
      context: context,
      builder: (dialogContext) => BankDataDialog(initialBankData: bankData),
    );
    if (!mounted) return;
    if (result != null) {
      setState(() {
        _bankDataResult = result;
      });
    }
  }

  Future<void> _fetchGewinne() async {
    setState(() {
      _loading = true;
      _gewinne.clear();
      _bankDataResult = null;
    });
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final result = await widget.apiService.fetchGewinne(
        _selectedYear,
        widget.passnummer,
      );
      if (!mounted) return;
      setState(() {
        _gewinne.clear();
        _gewinne.addAll(result);
      });
      if (result.isEmpty) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Keine Gewinne für das gewählte Jahr gefunden.'),
            duration: Duration(seconds: 3),
            backgroundColor: UIConstants.errorColor,
          ),
        );
      }
    } catch (e) {
      debugPrint('Fehler beim Laden der Gewinne: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BaseScreenLayout(
          title: 'Oktoberfestlandesschießen',
          userData: widget.userData,
          isLoggedIn: widget.isLoggedIn,
          onLogout: widget.onLogout,
          body: Focus(
            autofocus: true,
            child: Semantics(
              container: true,
              label:
                  'Oktoberfest Gewinn Bildschirm. Hier sehen Sie Ihre Gewinne für das Jahr und können Bankdaten bearbeiten.',
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Meine Gewinne für das Jahr:',
                        style: TextStyle(fontSize: UIConstants.titleFontSize),
                      ),
                      const SizedBox(height: UIConstants.spacingL),
                      Center(
                        child: SizedBox(
                          width:
                              320, // Match the title width (adjust as needed)
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DropdownButtonFormField<int>(
                                decoration: UIStyles.formInputDecoration
                                    .copyWith(
                                      labelText: 'Jahr',
                                      labelStyle:
                                          UIStyles
                                              .formInputDecoration
                                              .labelStyle,
                                      floatingLabelStyle:
                                          UIStyles
                                              .formInputDecoration
                                              .floatingLabelStyle,
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.auto,
                                    ),
                                value: _selectedYear,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem<int>(
                                    value: 2024,
                                    child: Text(
                                      '2024',
                                      style: TextStyle(
                                        fontSize: UIConstants.subtitleFontSize,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem<int>(
                                    value: 2025,
                                    child: Text(
                                      '2025',
                                      style: TextStyle(
                                        fontSize: UIConstants.subtitleFontSize,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (int? year) {
                                  if (year != null && year != _selectedYear) {
                                    setState(() {
                                      _selectedYear = year;
                                    });
                                    _fetchGewinne();
                                  }
                                },
                              ),
                              const SizedBox(height: UIConstants.spacingM),
                              ElevatedButton(
                                onPressed:
                                    (_loading || _gewinne.isEmpty)
                                        ? null
                                        : _fetchGewinne,
                                child: const Text('Gewinne abrufen'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_loading) ...[
                        const SizedBox(height: UIConstants.spacingXL),
                        const CircularProgressIndicator(),
                      ],
                      if (_gewinne.isNotEmpty) ...[
                        const SizedBox(height: UIConstants.spacingXL),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _gewinne.length + 1,
                          separatorBuilder: (context, index) {
                            if (index < _gewinne.length - 1) {
                              return const Divider();
                            }
                            return const SizedBox.shrink();
                          },
                          itemBuilder: (context, index) {
                            if (index == _gewinne.length) {
                              return const SizedBox(
                                height: UIConstants.helpSpacing,
                              );
                            }
                            final gewinn = _gewinne[index];
                            String abgerufenAmText;
                            final abgerufenAm = gewinn.abgerufenAm;
                            if (abgerufenAm.isEmpty) {
                              abgerufenAmText = 'noch nicht abgerufen';
                            } else {
                              DateTime? parsed;
                              try {
                                parsed = DateTime.tryParse(abgerufenAm);
                              } catch (_) {
                                parsed = null;
                              }
                              if (parsed != null) {
                                final day = parsed.day.toString().padLeft(
                                  2,
                                  '0',
                                );
                                final month = parsed.month.toString().padLeft(
                                  2,
                                  '0',
                                );
                                final year = parsed.year.toString();
                                abgerufenAmText = '$day.$month.$year';
                              } else {
                                abgerufenAmText = abgerufenAm;
                              }
                            }
                            return ListTile(
                              title: Text(
                                gewinn.isSachpreis
                                    ? '${gewinn.wettbewerb}: ${gewinn.sachpreis}'
                                    : '${gewinn.wettbewerb}: ${gewinn.geldpreis}\u20ac',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: UIConstants.subtitleFontSize,
                                ),
                              ),
                              subtitle: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: UIConstants.subtitleFontSize,
                                    color:
                                        DefaultTextStyle.of(
                                          context,
                                        ).style.color,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Abrufdatum: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: UIConstants.subtitleFontSize,
                                      ),
                                    ),
                                    TextSpan(
                                      text: abgerufenAmText,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: UIConstants.subtitleFontSize,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: UIConstants.spacingM),
                        if (_gewinne.any((g) => g.abgerufenAm.isEmpty))
                          ElevatedButton(
                            onPressed:
                                _bankDialogLoading ? null : _openBankDataDialog,
                            child:
                                _bankDialogLoading
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text('Bankdaten'),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(
              height: UIConstants.fabSize,
              width: UIConstants.fabSize,
              child: Stack(
                children: [
                  // FAB to fetch the last year's data
                  Visibility(
                    visible: _gewinne.any((g) => g.abgerufenAm.isEmpty),
                    maintainState: true,
                    child: FloatingActionButton(
                      heroTag: 'pickYear',
                      onPressed: _loading ? null : _fetchGewinne,
                      tooltip: 'Gewinne für Jahr abrufen',
                      backgroundColor:
                          _loading
                              ? UIConstants.cancelButtonBackground
                              : UIConstants.defaultAppColor,
                      child: const Icon(
                        Icons.search,
                        color: UIConstants.whiteColor,
                      ),
                    ),
                  ),
                  // FAB to perform the Gewinn fetch/abfrage
                  Visibility(
                    visible: _gewinne.any((g) => g.abgerufenAm.isEmpty),
                    maintainState: true,
                    child: FloatingActionButton(
                      heroTag: 'abrufen',
                      onPressed:
                          (_bankDataResult != null &&
                                  _bankDataResult!.kontoinhaber.isNotEmpty &&
                                  _bankDataResult!.iban.isNotEmpty &&
                                  (_bankDataResult!.iban
                                          .toUpperCase()
                                          .startsWith('DE') ||
                                      _bankDataResult!.bic.isNotEmpty))
                              ? () async {
                                setState(() {
                                  _loading = true;
                                });
                                final scaffoldMessenger = ScaffoldMessenger.of(
                                  context,
                                );
                                final navigator = Navigator.of(context);
                                try {
                                  final result = await widget.apiService
                                      .gewinneAbrufen(
                                        gewinnIDs:
                                            _gewinne
                                                .map((g) => g.gewinnId)
                                                .toList(),
                                        iban: _bankDataResult!.iban,
                                        passnummer: widget.passnummer,
                                      );
                                  if (!mounted) return;
                                  if (result) {
                                    navigator.push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const OktoberfestAbrufResultScreen(
                                                  success: true,
                                                ),
                                      ),
                                    );
                                  } else {
                                    if (!mounted) return;
                                    scaffoldMessenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Fehler beim Abrufen der Gewinne.',
                                        ),
                                        duration: UIConstants.snackbarDuration,
                                        backgroundColor: UIConstants.errorColor,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  debugPrint(
                                    'Fehler beim Abrufen der Gewinne: $e',
                                  );
                                  if (!mounted) return;
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Fehler beim Abrufen der Gewinne: $e',
                                      ),
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
                              : null,
                      tooltip: 'Gewinne abrufen',
                      backgroundColor:
                          (_bankDataResult != null &&
                                  _bankDataResult!.kontoinhaber.isNotEmpty &&
                                  _bankDataResult!.iban.isNotEmpty &&
                                  (_bankDataResult!.iban
                                          .toUpperCase()
                                          .startsWith('DE') ||
                                      _bankDataResult!.bic.isNotEmpty))
                              ? UIConstants.defaultAppColor
                              : UIConstants.cancelButtonBackground,
                      child: const Icon(
                        Icons.check,
                        color: UIConstants.whiteColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Removed full-page overlay spinner for bank dialog loading
      ],
    );
  }
}

class _BankDataResult {
  _BankDataResult({
    required this.kontoinhaber,
    required this.iban,
    required this.bic,
  });
  final String kontoinhaber;
  final String iban;
  final String bic;
}

class BankDataDialog extends StatefulWidget {
  const BankDataDialog({super.key, this.initialBankData});
  final BankData? initialBankData;

  @override
  State<BankDataDialog> createState() => _BankDataDialogState();
}

// Your existing BankDataDialog code remains unchanged...

class _BankDataDialogState extends State<BankDataDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _kontoinhaberController;
  late final TextEditingController _ibanController;
  late final TextEditingController _bicController;
  // Removed _agbChecked and AGB checkbox

  bool _isBicRequired(String iban) {
    return !iban.toUpperCase().startsWith('DE');
  }

  bool _isBicValid(String bic) {
    // BIC must be 8 or 11 characters, alphanumeric, and uppercase
    final bicRegExp = RegExp(r'^[A-Z]{4}[A-Z]{2}[A-Z0-9]{2}([A-Z0-9]{3})?$');

    return bicRegExp.hasMatch(bic);
  }

  @override
  void initState() {
    super.initState();
    _kontoinhaberController = TextEditingController(
      text: widget.initialBankData?.kontoinhaber ?? '',
    );
    _ibanController = TextEditingController(
      text: widget.initialBankData?.iban ?? '',
    );
    _bicController = TextEditingController(
      text: widget.initialBankData?.bic ?? '',
    );
    _ibanController.addListener(() {
      setState(() {}); // Update BIC label if IBAN changes
    });
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
    final FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(
      context,
    );
    return Dialog(
      backgroundColor: UIConstants.backgroundColor,
      insetPadding: const EdgeInsets.all(32),
      child: Stack(
        children: [
          SizedBox(
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
                      const Center(
                        child: Text(
                          'Bankdaten bearbeiten',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: UIConstants.whiteColor,
                          border: Border.all(
                            color: UIConstants.mydarkGreyColor,
                          ),
                          borderRadius: BorderRadius.circular(
                            UIConstants.cornerRadius,
                          ),
                        ),
                        padding: UIConstants.defaultPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bankdaten',
                              style: UIStyles.subtitleStyle,
                            ),
                            const SizedBox(height: UIConstants.spacingM),
                            Semantics(
                              label: 'Kontoinhaber Eingabefeld',
                              textField: true,
                              child: TextFormField(
                                controller: _kontoinhaberController,
                                style: UIStyles.formValueStyle.copyWith(
                                  fontSize:
                                      UIStyles.formValueStyle.fontSize! *
                                      fontSizeProvider.scaleFactor,
                                ),
                                decoration: UIStyles.formInputDecoration
                                    .copyWith(labelText: 'Kontoinhaber'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Kontoinhaber ist erforderlich';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: UIConstants.spacingM),
                            Row(
                              children: [
                                Expanded(
                                  child: Semantics(
                                    label: 'IBAN Eingabefeld',
                                    textField: true,
                                    child: TextFormField(
                                      controller: _ibanController,
                                      style: UIStyles.formValueStyle.copyWith(
                                        fontSize:
                                            UIStyles.formValueStyle.fontSize! *
                                            fontSizeProvider.scaleFactor,
                                      ),
                                      decoration: UIStyles.formInputDecoration
                                          .copyWith(labelText: 'IBAN'),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'IBAN ist erforderlich';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: UIConstants.spacingM),
                                Expanded(
                                  child: Semantics(
                                    label:
                                        _isBicRequired(
                                              _ibanController.text.trim(),
                                            )
                                            ? 'BIC Eingabefeld, Pflichtfeld für nicht-deutsche IBANs'
                                            : 'BIC Eingabefeld, optional',
                                    textField: true,
                                    child: TextFormField(
                                      controller: _bicController,
                                      style: UIStyles.formValueStyle.copyWith(
                                        fontSize:
                                            UIStyles.formValueStyle.fontSize! *
                                            fontSizeProvider.scaleFactor,
                                      ),
                                      decoration: UIStyles.formInputDecoration
                                          .copyWith(
                                            labelText:
                                                _isBicRequired(
                                                      _ibanController.text
                                                          .trim(),
                                                    )
                                                    ? 'BIC *'
                                                    : 'BIC (optional)',
                                          ),
                                      validator: (value) {
                                        final iban =
                                            _ibanController.text
                                                .trim()
                                                .toUpperCase();
                                        final bic = value?.trim() ?? '';
                                        if (_isBicRequired(iban)) {
                                          if (bic.isEmpty) {
                                            return 'BIC ist erforderlich für nicht-deutsche IBANs';
                                          }
                                          if (!_isBicValid(bic)) {
                                            return 'BIC ist ungültig.';
                                          }
                                        } else {
                                          if (bic.isNotEmpty &&
                                              !_isBicValid(bic)) {
                                            return 'BIC ist ungültig.';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingL),
                      const SizedBox(
                        height: 84,
                      ), // Increased space at the bottom of the dialog
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Increased extra space at the bottom of the dialog
          const Positioned(
            bottom: UIConstants.dialogFabTightBottom + 64,
            right: UIConstants.dialogFabTightRight,
            child: SizedBox(height: 64),
          ),
          Positioned(
            bottom: UIConstants.dialogFabTightBottom,
            right: UIConstants.dialogFabTightRight,
            child: DialogFABs(
              alignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'bankDialogCancelFab',
                  mini: true,
                  tooltip: 'Abbrechen',
                  backgroundColor: UIConstants.defaultAppColor,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: UIConstants.whiteColor),
                ),
                FloatingActionButton(
                  heroTag: 'bankDialogOkFab',
                  mini: true,
                  tooltip: 'OK',
                  backgroundColor:
                      (_kontoinhaberController.text.trim().isNotEmpty &&
                              _ibanController.text.trim().isNotEmpty &&
                              (_isBicRequired(_ibanController.text.trim())
                                  ? _bicController.text.trim().isNotEmpty
                                  : true))
                          ? UIConstants.defaultAppColor
                          : UIConstants.cancelButtonBackground,
                  onPressed:
                      (_kontoinhaberController.text.trim().isNotEmpty &&
                              _ibanController.text.trim().isNotEmpty &&
                              (_isBicRequired(_ibanController.text.trim())
                                  ? _bicController.text.trim().isNotEmpty
                                  : true))
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
                  child: const Icon(Icons.check, color: UIConstants.whiteColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Dummy placeholder for your existing `OktoberfestAbrufResultScreen`
class OktoberfestAbrufResultScreen extends StatelessWidget {
  const OktoberfestAbrufResultScreen({
    super.key,
    required this.success,
    this.errorMessage,
  });
  final bool success;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Abruf Ergebnis')),
      body: Center(
        child: Padding(
          padding: UIConstants.defaultPadding,
          child:
              success
                  ? const ScaledText(
                    'Gewinne erfolgreich abgerufen!',
                    style: UIStyles.successStyle,
                    textAlign: TextAlign.center,
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: UIConstants.errorColor,
                        size: UIConstants.iconSizeM,
                      ),
                      const SizedBox(height: UIConstants.spacingL),
                      ScaledText(
                        errorMessage ?? 'Fehler beim Abrufen der Gewinne.',
                        style: UIStyles.errorStyle,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
