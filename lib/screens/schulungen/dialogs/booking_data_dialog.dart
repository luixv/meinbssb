import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/helpers/utils.dart';
import '/models/bank_data.dart';
import '/models/schulungstermin_data.dart';
import '/models/user_data.dart';
import '/screens/agb/agb_screen.dart';
import '/services/api_service.dart';
import '/services/api/bank_service.dart';
import '/widgets/dialog_fabs.dart';
import '/widgets/keyboard_focus_fab.dart';
import '/widgets/scaled_text.dart';

import 'package:meinbssb/providers/font_size_provider.dart';

import '../widgets/keyboard_focus_checkbox.dart';
import 'register_another_dialog.dart';

class BookingDataDialog extends StatefulWidget {
  const BookingDataDialog({
    super.key,
    required this.schulungsTermin,
    required this.user,
    required this.registeredPersons,
    required this.phoneNumber,
    required this.bankData,
    required this.onSubmit,
  });

  final Schulungstermin schulungsTermin;
  final UserData user;
  final List<RegisteredPersonUi> registeredPersons;
  final String phoneNumber;
  final BankData? bankData;

  /// Called when user presses "Buchen" with valid form+checkboxes.
  final Future<void> Function({
    required BankData safeBankData,
    required UserData prefillUser,
    required String prefillEmail,
    required List<RegisteredPersonUi> registeredPersons,
  })
  onSubmit;

  static Future<void> show(
    BuildContext context, {
    required Schulungstermin schulungsTermin,
    required UserData user,
    required List<RegisteredPersonUi> registeredPersons,
    required String phoneNumber,
    required BankData? bankData,
    required Future<void> Function({
      required BankData safeBankData,
      required UserData prefillUser,
      required String prefillEmail,
      required List<RegisteredPersonUi> registeredPersons,
    })
    onSubmit,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => BookingDataDialog(
            schulungsTermin: schulungsTermin,
            user: user,
            registeredPersons: registeredPersons,
            phoneNumber: phoneNumber,
            bankData: bankData,
            onSubmit: onSubmit,
          ),
    );
  }

  @override
  State<BookingDataDialog> createState() => _BookingDataDialogState();
}

class _BookingDataDialogState extends State<BookingDataDialog> {
  bool agbChecked = false;
  bool lastschriftChecked = false;
  final formKey = GlobalKey<FormState>();

  late final TextEditingController telefonController;
  late final TextEditingController kontoinhaberController;
  late final TextEditingController ibanController;
  late final TextEditingController bicController;

  @override
  void initState() {
    super.initState();

    telefonController = TextEditingController(text: widget.phoneNumber);
    kontoinhaberController = TextEditingController(
      text: widget.bankData?.kontoinhaber ?? '',
    );
    ibanController = TextEditingController(text: widget.bankData?.iban ?? '');
    bicController = TextEditingController(text: widget.bankData?.bic ?? '');

    kontoinhaberController.addListener(_rebuild);
    ibanController.addListener(_onIbanChanged);
    bicController.addListener(_rebuild);
  }

  void _onIbanChanged() {
    setState(() {});
    if (formKey.currentState != null) {
      formKey.currentState!.validate();
    }
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    kontoinhaberController.removeListener(_rebuild);
    ibanController.removeListener(_onIbanChanged);
    bicController.removeListener(_rebuild);

    telefonController.dispose();
    kontoinhaberController.dispose();
    ibanController.dispose();
    bicController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    final iban = ibanController.text.trim();
    final bic = bicController.text.trim();

    return agbChecked &&
        lastschriftChecked &&
        kontoinhaberController.text.trim().isNotEmpty &&
        iban.isNotEmpty &&
        BankService.validateIBAN(iban) &&
        (!isBicRequired(iban) || bic.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(
      context,
    );

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: UIConstants.dialogMaxWidth,
            maxHeight: UIConstants.dialogMaxHeight,
          ),
          child: Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(
                  context,
                ).size.width.clamp(0, UIConstants.dialogMaxWidth.toDouble()),
                child: AlertDialog(
                  backgroundColor: UIConstants.backgroundColor,
                  insetPadding: EdgeInsets.zero,
                  contentPadding: EdgeInsets.zero,
                  title: const Center(
                    child: ScaledText(
                      'Buchungsdaten Erfassen',
                      style: UIStyles.dialogTitleStyle,
                    ),
                  ),
                  content: Stack(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: UIConstants.spacingM,
                            left: UIConstants.spacingM,
                            right: UIConstants.spacingM,
                          ),
                          child: Semantics(
                            container: true,
                            label:
                                'Formular zur Erfassung der Buchungsdaten: Bankdaten, AGB und Lastschrifteinzug bestätigen.',
                            child: SingleChildScrollView(
                              child: Form(
                                key: formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Bankdaten',
                                            style: UIStyles.subtitleStyle,
                                          ),
                                          const SizedBox(
                                            height: UIConstants.spacingM,
                                          ),
                                          Semantics(
                                            label:
                                                'Eingabefeld für Kontoinhaber',
                                            child: TextFormField(
                                              controller:
                                                  kontoinhaberController,
                                              style: UIStyles.formValueStyle
                                                  .copyWith(
                                                    fontSize:
                                                        UIStyles
                                                            .formValueStyle
                                                            .fontSize! *
                                                        fontSizeProvider
                                                            .scaleFactor,
                                                  ),
                                              decoration: UIStyles
                                                  .formInputDecoration
                                                  .copyWith(
                                                    labelText: 'Kontoinhaber',
                                                  ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Kontoinhaber ist erforderlich';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                            height: UIConstants.spacingM,
                                          ),
                                          Semantics(
                                            label: 'Eingabefeld für IBAN',
                                            child: TextFormField(
                                              controller: ibanController,
                                              style: UIStyles.formValueStyle
                                                  .copyWith(
                                                    fontSize:
                                                        UIStyles
                                                            .formValueStyle
                                                            .fontSize! *
                                                        fontSizeProvider
                                                            .scaleFactor,
                                                  ),
                                              decoration: UIStyles
                                                  .formInputDecoration
                                                  .copyWith(labelText: 'IBAN'),
                                              validator: (value) {
                                                final apiService =
                                                    Provider.of<ApiService>(
                                                      context,
                                                      listen: false,
                                                    );
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'IBAN ist erforderlich';
                                                }
                                                if (!apiService.validateIBAN(
                                                  value,
                                                )) {
                                                  return 'Ungültige IBAN';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                            height: UIConstants.spacingM,
                                          ),
                                          Semantics(
                                            label: 'Eingabefeld für BIC',
                                            child: TextFormField(
                                              controller: bicController,
                                              style: UIStyles.formValueStyle
                                                  .copyWith(
                                                    fontSize:
                                                        UIStyles
                                                            .formValueStyle
                                                            .fontSize! *
                                                        fontSizeProvider
                                                            .scaleFactor,
                                                  ),
                                              decoration: UIStyles
                                                  .formInputDecoration
                                                  .copyWith(
                                                    labelText:
                                                        isBicRequired(
                                                              ibanController
                                                                  .text
                                                                  .trim(),
                                                            )
                                                            ? 'BIC *'
                                                            : 'BIC (optional)',
                                                  ),
                                              validator: (value) {
                                                final apiService =
                                                    Provider.of<ApiService>(
                                                      context,
                                                      listen: false,
                                                    );
                                                final iban =
                                                    ibanController.text
                                                        .trim()
                                                        .toUpperCase();

                                                if (!iban.startsWith('DE') &&
                                                    (value == null ||
                                                        value.trim().isEmpty)) {
                                                  return 'BIC ist erforderlich für nicht-deutsche IBANs';
                                                }

                                                if (value != null &&
                                                    value.trim().isNotEmpty) {
                                                  final bicError = apiService
                                                      .validateBIC(value);
                                                  if (bicError != null) {
                                                    return bicError;
                                                  }
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: UIConstants.spacingS,
                                    ),
                                    Semantics(
                                      label:
                                          'AGB und Lastschrifteinzug Bestätigung',
                                      child: ListTileTheme(
                                        data: const ListTileThemeData(
                                          horizontalTitleGap:
                                              UIConstants.spacingXS,
                                          minLeadingWidth: 0,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                KeyboardFocusCheckbox(
                                                  label:
                                                      'Checkbox zum Akzeptieren der AGB',
                                                  value: agbChecked,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      agbChecked = val ?? false;
                                                    });
                                                  },
                                                ),
                                                const SizedBox(
                                                  width: UIConstants.spacingS,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder:
                                                          (context) => Dialog(
                                                            child: SizedBox(
                                                              width: 600,
                                                              height: 600,
                                                              child:
                                                                  const AgbScreen(),
                                                            ),
                                                          ),
                                                    );
                                                  },
                                                  child: Text(
                                                    'AGB-L',
                                                    style: UIStyles.linkStyle
                                                        .copyWith(
                                                          color:
                                                              UIConstants
                                                                  .linkColor,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          fontSize:
                                                              UIStyles
                                                                  .bodyStyle
                                                                  .fontSize,
                                                          fontWeight:
                                                              UIStyles
                                                                  .bodyStyle
                                                                  .fontWeight,
                                                        ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: UIConstants.spacingS,
                                                ),
                                                Text(
                                                  'akzeptieren',
                                                  style: UIStyles.bodyStyle
                                                      .copyWith(
                                                        fontSize:
                                                            UIStyles
                                                                .bodyStyle
                                                                .fontSize,
                                                        fontWeight:
                                                            UIStyles
                                                                .bodyStyle
                                                                .fontWeight,
                                                      ),
                                                ),
                                                const SizedBox(
                                                  width: UIConstants.spacingS,
                                                ),
                                                const Tooltip(
                                                  message:
                                                      'Ich bin mit den AGB einverstanden.',
                                                  triggerMode:
                                                      TooltipTriggerMode.tap,
                                                  child: Icon(
                                                    Icons.info_outline,
                                                    color:
                                                        UIConstants
                                                            .defaultAppColor,
                                                    size:
                                                        UIConstants
                                                            .tooltipIconSize,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                KeyboardFocusCheckbox(
                                                  label:
                                                      'Checkbox zur Bestätigung des Lastschrifteinzugs',
                                                  value: lastschriftChecked,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      lastschriftChecked =
                                                          val ?? false;
                                                    });
                                                  },
                                                ),
                                                const SizedBox(
                                                  width: UIConstants.spacingS,
                                                ),
                                                Text(
                                                  'Bestätigung des\nLastschrifteinzugs',
                                                  style: UIStyles.bodyStyle
                                                      .copyWith(
                                                        fontSize:
                                                            UIStyles
                                                                .bodyStyle
                                                                .fontSize,
                                                        fontWeight:
                                                            UIStyles
                                                                .bodyStyle
                                                                .fontWeight,
                                                      ),
                                                ),
                                                const SizedBox(
                                                  width: UIConstants.spacingS,
                                                ),
                                                const Tooltip(
                                                  message:
                                                      'Ich ermächtige Sie widerruflich, die von mir zu entrichtenden Zahlungen bei Fälligkeit Durch Lastschrift von meinem im MeinBSSB angegebenen Konto einzuziehen. Zugleich weise ich mein Kreditinstitut an, die vom BSSB auf meinem Konto gezogenen Lastschriften einzulösen.',
                                                  triggerMode:
                                                      TooltipTriggerMode.tap,
                                                  child: Icon(
                                                    Icons.info_outline,
                                                    color:
                                                        UIConstants
                                                            .defaultAppColor,
                                                    size:
                                                        UIConstants
                                                            .tooltipIconSize,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: UIConstants.spacingM,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: UIConstants.spacingM,
                        right: UIConstants.spacingM,
                        child: DialogFABs(
                          children: [
                            KeyboardFocusFAB(
                              heroTag: 'cancelBookingFab',
                              mini: true,
                              tooltip: 'Abbrechen',
                              icon: Icons.close,
                              semanticLabel: 'Buchung abbrechen',
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            KeyboardFocusFAB(
                              heroTag: 'submitBookingFab',
                              mini: true,
                              tooltip: 'Buchen',
                              icon: Icons.check,
                              semanticLabel: 'Button zum Buchen der Buchung',
                              backgroundColor:
                                  _canSubmit
                                      ? UIConstants.defaultAppColor
                                      : UIConstants.cancelButtonBackground,
                              onPressed:
                                  _canSubmit
                                      ? () async {
                                        if (formKey.currentState != null &&
                                            formKey.currentState!.validate()) {
                                          Navigator.of(context).pop();

                                          final apiService =
                                              Provider.of<ApiService>(
                                                context,
                                                listen: false,
                                              );
                                          final String email =
                                              await apiService
                                                  .getCachedUsername() ??
                                              '';

                                          final BankData
                                          safeBankData = BankData(
                                            id: widget.bankData?.id ?? 0,
                                            webloginId: widget.user.webLoginId,
                                            kontoinhaber:
                                                kontoinhaberController.text
                                                    .trim(),
                                            iban: ibanController.text.trim(),
                                            bic: bicController.text.trim(),
                                            mandatSeq:
                                                widget.bankData?.mandatSeq ?? 2,
                                            bankName:
                                                widget.bankData?.bankName ?? '',
                                            mandatNr:
                                                widget.bankData?.mandatNr ?? '',
                                            mandatName:
                                                widget.bankData?.mandatName ??
                                                '',
                                          );

                                          await widget.onSubmit(
                                            safeBankData: safeBankData,
                                            prefillUser: widget.user.copyWith(
                                              telefon: telefonController.text,
                                            ),
                                            prefillEmail: email,
                                            registeredPersons:
                                                widget.registeredPersons,
                                          );
                                        }
                                      }
                                      : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
