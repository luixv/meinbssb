import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/services/api_service.dart';

import '/models/gewinn_data.dart';
import '/constants/ui_styles.dart';
import '../base_screen_layout.dart';
import '/models/user_data.dart';
import '/constants/ui_constants.dart';
import '/helpers/utils.dart';

// import 'agb_screen.dart';
import '/widgets/scaled_text.dart';

class SeventyFiveJahreBSSBGewinnScreen extends StatefulWidget {
  const SeventyFiveJahreBSSBGewinnScreen({
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
  State<SeventyFiveJahreBSSBGewinnScreen> createState() =>
      _SeventyFiveJahreBSSBGewinnScreenState();
}

class _SeventyFiveJahreBSSBGewinnScreenState extends State<SeventyFiveJahreBSSBGewinnScreen> {
  late final int _currentYear;
  late int _selectedYear;
  bool _loading = false;
  final List<Gewinn> _gewinne = [];
  _BankDataResult? _bankDataResult;
  final TextEditingController _kontoinhaberController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _bicController = TextEditingController();
  bool _bankDataLoading = false;

  @override
  void initState() {
    super.initState();
    _currentYear = DateTime.now().year;
    _selectedYear = _currentYear;
    _kontoinhaberController.addListener(_updateBankDataResult);
    _ibanController.addListener(_updateBankDataResult);
    _bicController.addListener(_updateBankDataResult);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchGewinne();
      _loadBankData();
    });
  }

  @override
  void dispose() {
    _kontoinhaberController
      ..removeListener(_updateBankDataResult)
      ..dispose();
    _ibanController
      ..removeListener(_updateBankDataResult)
      ..dispose();
    _bicController
      ..removeListener(_updateBankDataResult)
      ..dispose();
    super.dispose();
  }

  void _updateBankDataResult() {
    _bankDataResult = _BankDataResult(
      kontoinhaber: _kontoinhaberController.text,
      iban: _ibanController.text,
      bic: _bicController.text,
    );
    setState(() {});
  }

  Future<void> _loadBankData() async {
    final userData = widget.userData;
    if (userData == null) return;
    setState(() {
      _bankDataLoading = true;
    });
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final bankList = await apiService.fetchBankdatenMyBSSB(
        userData.webLoginId,
      );
      if (bankList.isNotEmpty) {
        final bankData = bankList.first;
        _kontoinhaberController.text = bankData.kontoinhaber;
        _ibanController.text = bankData.iban;
        _bicController.text = bankData.bic;
      }
    } catch (e) {
      debugPrint('Fehler beim Laden der Bankdaten: $e');
    } finally {
      _updateBankDataResult();
      if (mounted) {
        setState(() {
          _bankDataLoading = false;
        });
      }
    }
  }

  Future<void> _fetchGewinne() async {
    setState(() {
      _loading = true;
      _gewinne.clear();
    });
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final result = await widget.apiService.fetchGewinneEx(
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
            content: Text('Keine Gewinne.'),
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
          title: '75 Jahre BSSB',
          userData: widget.userData,
          isLoggedIn: widget.isLoggedIn,
          onLogout: widget.onLogout,
          body: Focus(
            autofocus: true,
            child: Semantics(
              container: true,
              label:
                  '75 Jahre BSSB Gewinn Bildschirm. Hier sehen Sie Ihre Gewinne für das Jahr und können Bankdaten bearbeiten.',
              child: SingleChildScrollView(
                child: Padding(
                  padding: UIConstants.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ScaledText(
                        'Gewinne abrufen',
                        style: UIStyles.headerStyle,
                      ),
                      const SizedBox(height: UIConstants.spacingS),
                      const ScaledText(
                        'Meine Gewinne:',
                        style: UIStyles.titleStyle,
                      ),
                      const SizedBox(height: UIConstants.spacingL),
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
                      ],
                      const SizedBox(height: UIConstants.spacingL),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final screenWidth = constraints.maxWidth;
                          const double minWidth = 280;
                          const double maxWidth = 480;
                          double width = screenWidth * 0.5;
                          width = width.clamp(minWidth, maxWidth);
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: width,
                              child: _buildBankDataSection(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: UIConstants.spacingM),
                      _buildSubmitSection(),
                      const SizedBox(height: UIConstants.spacingXXL),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Removed full-page overlay spinner for bank dialog loading
      ],
    );
  }

  bool get _hasPendingGewinne =>
      _gewinne.any((g) => g.abgerufenAm.isEmpty);

  bool get _canSubmitGewinne =>
      _hasPendingGewinne &&
      _bankDataResult != null &&
      _bankDataResult!.kontoinhaber.isNotEmpty &&
      _bankDataResult!.iban.isNotEmpty &&
      (_bankDataResult!.iban.toUpperCase().startsWith('DE') ||
          _bankDataResult!.bic.isNotEmpty);

  Widget _buildBankDataSection() {
    final bool isDisabled = !_hasPendingGewinne && _gewinne.isNotEmpty;
    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: UIConstants.whiteColor,
          border: Border.all(
            color: UIConstants.mydarkGreyColor,
          ),
          borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
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
            if (_bankDataLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: UIConstants.spacingM),
                child: CircularProgressIndicator(),
              ),
            TextFormField(
              controller: _kontoinhaberController,
              readOnly: isDisabled,
              decoration: UIStyles.formInputDecoration.copyWith(
                labelText: 'Kontoinhaber',
              ),
            ),
            const SizedBox(height: UIConstants.spacingM),
            _KeyboardFocusTextField(
              controller: _ibanController,
              label: 'IBAN',
              readOnly: isDisabled,
            ),
            const SizedBox(height: UIConstants.spacingM),
            _KeyboardFocusTextField(
              controller: _bicController,
              label: isBicRequired(_ibanController.text.trim())
                  ? 'BIC *'
                  : 'BIC (optional)',
              readOnly: isDisabled,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitSection() {
    final bool canSubmit = _canSubmitGewinne && !_loading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          button: true,
          label: 'Gewinne abrufen',
          enabled: canSubmit,
          child: SizedBox(
            width: 320,
            child: ElevatedButton(
              onPressed: canSubmit ? _submitGewinne : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: UIConstants.defaultAppColor,
                foregroundColor: UIConstants.whiteColor,
                textStyle: const TextStyle(
                  fontSize: UIConstants.subtitleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text(
                canSubmit || _hasPendingGewinne
                    ? 'Gewinne abrufen'
                    : 'Gewinne wurden abgerufen.',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitGewinne() async {
    setState(() {
      _loading = true;
    });
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final result = await widget.apiService.gewinneAbrufenEx(
        gewinnIDs: _gewinne.map((g) => g.gewinnId).toList(),
        iban: _bankDataResult!.iban,
        passnummer: widget.passnummer,
      );
      if (!mounted) return;
      if (result) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Gewinne wurden erfolgreich übertragen.'),
            duration: UIConstants.snackbarDuration,
            backgroundColor: UIConstants.successColor,
          ),
        );
        _fetchGewinne();
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

class _KeyboardFocusDropdown<T> extends StatefulWidget {
  const _KeyboardFocusDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  State<_KeyboardFocusDropdown<T>> createState() =>
      _KeyboardFocusDropdownState<T>();
}

class _KeyboardFocusDropdownState<T> extends State<_KeyboardFocusDropdown<T>> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocus() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardMode =
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    final hasKeyboardFocus = _isFocused && isKeyboardMode;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: hasKeyboardFocus ? const EdgeInsets.all(4.0) : EdgeInsets.zero,
      decoration: hasKeyboardFocus
          ? BoxDecoration(
              border: Border.all(
                color: Colors.yellow.shade700,
                width: 2.5,
              ),
            )
          : null,
      child: DropdownButtonFormField<T>(
        focusNode: _focusNode,
        value: widget.value,
        items: widget.items,
        onChanged: widget.onChanged,
        decoration: UIStyles.formInputDecoration.copyWith(
          labelText: widget.label,
        ),
      ),
    );
  }
}

class _KeyboardFocusTextField extends StatefulWidget {
  const _KeyboardFocusTextField({
    required this.controller,
    required this.label,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String label;
  final bool readOnly;

  @override
  State<_KeyboardFocusTextField> createState() => _KeyboardFocusTextFieldState();
}

class _KeyboardFocusTextFieldState extends State<_KeyboardFocusTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocus() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (_focusNode.hasFocus) {
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

    return TextFormField(
      focusNode: _focusNode,
      controller: widget.controller,
      readOnly: widget.readOnly,
      decoration: UIStyles.formInputDecoration.copyWith(
        labelText: widget.label,
        filled: true,
        fillColor: hasKeyboardFocus ? Colors.yellow.shade50 : UIConstants.whiteColor,
        enabledBorder: _border(UIConstants.mydarkGreyColor, 1),
        focusedBorder: _border(
          hasKeyboardFocus ? Colors.yellow.shade700 : UIConstants.primaryColor,
          hasKeyboardFocus ? 2.5 : 1.5,
        ),
      ),
    );
  }
}

