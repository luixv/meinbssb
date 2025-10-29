import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/messages.dart';
import '/constants/ui_styles.dart';
import '/screens/base_screen_layout.dart';
import '../agb/agb_ausweis_screen.dart';
import '/models/user_data.dart';
import '/models/bank_data.dart';
import '/providers/font_size_provider.dart';
import '/widgets/scaled_text.dart';
import '/widgets/dialog_fabs.dart';

import 'package:meinbssb/services/api_service.dart';

import '/models/passdaten_akzept_or_aktiv_data.dart';
import 'ausweis_bestellen_success_screen.dart';

class AusweisBestellenScreen extends StatefulWidget {
  const AusweisBestellenScreen({
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  State<AusweisBestellenScreen> createState() => _AusweisBestellenScreenState();
}

class _AusweisBestellenScreenState extends State<AusweisBestellenScreen> {
  bool isLoading = false;

  Future<void> _onSave() async {
    setState(() {
      isLoading = true;
    });

    const antragsTyp = 5; // 5=Verlust
    final int? passdatenId = widget.userData?.passdatenId;
    final int? personId = widget.userData?.personId;
    final int? erstVereinId = widget.userData?.erstVereinId;
    int digitalerPass = 0; // 1 for yes, 0 for no

    final apiService = Provider.of<ApiService>(context, listen: false);

    final PassdatenAkzeptOrAktiv?
    fetchedPassdatenAkzeptierterOderAktiverPassData = await apiService
        .fetchPassdatenAkzeptierterOderAktiverPass(personId);

    /* create a list "ZVEs": [
        {
            "VEREINID": 2420,
            "DISZIPLINID": 94
        },
        ...
    ]
*/

    List<Map<String, dynamic>> zves = [];
    if (fetchedPassdatenAkzeptierterOderAktiverPassData != null) {
      for (final zve in fetchedPassdatenAkzeptierterOderAktiverPassData.zves) {
        final vereinId = zve.vereinId;
        final disziplinId = zve.disziplinId;

        zves.add({'VEREINID': vereinId, 'DISZIPLINID': disziplinId});
      }
    }

    final bool success = await apiService.bssbAppPassantrag(
      zves,
      passdatenId,
      personId,
      erstVereinId,
      digitalerPass,
      antragsTyp,
    );

    if (mounted) {
      setState(() {
        isLoading = false;
      });

      if (success) {
        // Navigate to the success screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => AusweisBestellendSuccessScreen(
                  userData: widget.userData,
                  isLoggedIn: widget.isLoggedIn,
                  onLogout: widget.onLogout,
                ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Antrag konnte nicht gesendet werden.')),
        );
      }
    }
  }

  Future<void> _showBankDataDialog() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final user = widget.userData;
    if (user == null) return;

    // Show loading indicator while fetching bank data
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              UIConstants.defaultAppColor,
            ),
          ),
        );
      },
    );

    bool isBicRequired(String iban) {
      return !iban.toUpperCase().startsWith('DE');
    }

    final List<BankData> bankDataList = await apiService.fetchBankdatenMyBSSB(
      user.webLoginId,
    );
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    final bankData = bankDataList.isNotEmpty ? bankDataList.first : null;

    bool agbChecked = false;
    bool lastschriftChecked = false;
    final formKey = GlobalKey<FormState>();

    final kontoinhaberController = TextEditingController(
      text: bankData?.kontoinhaber ?? '',
    );
    final ibanController = TextEditingController(text: bankData?.iban ?? '');
    final bicController = TextEditingController(text: bankData?.bic ?? '');

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: UIConstants.backgroundColor,
              insetPadding: EdgeInsets.zero, // remove default Flutter margins
              contentPadding: EdgeInsets.zero,
              title: const Center(
                child: ScaledText(
                  'Bankdaten Erfassen',
                  style: UIStyles.dialogTitleStyle,
                ),
              ),
              content: Stack(
                children: [
                  SizedBox(
                    width: double.maxFinite, // 👈 stretch form inside dialog
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: UIConstants.spacingM,
                        left: UIConstants.spacingM,
                        right: UIConstants.spacingM,
                      ),
                      child: SingleChildScrollView(
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Bankdaten',
                                      style: UIStyles.subtitleStyle,
                                    ),
                                    const SizedBox(
                                      height: UIConstants.spacingM,
                                    ),
                                    Semantics(
                                      label: 'Eingabefeld für Kontoinhaber',
                                      child: TextFormField(
                                        controller: kontoinhaberController,
                                        decoration: UIStyles.formInputDecoration
                                            .copyWith(
                                              labelText: 'Kontoinhaber',
                                            ),
                                        readOnly: true,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
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
                                        decoration: UIStyles.formInputDecoration
                                            .copyWith(labelText: 'IBAN'),
                                        readOnly: true,
                                        validator: (value) {
                                          final apiService =
                                              Provider.of<ApiService>(
                                                context,
                                                listen: false,
                                              );
                                          if (value == null || value.isEmpty) {
                                            return 'IBAN ist erforderlich';
                                          }
                                          if (!apiService.validateIBAN(value)) {
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
                                        decoration: UIStyles.formInputDecoration
                                            .copyWith(
                                              labelText:
                                                  isBicRequired(
                                                        ibanController.text
                                                            .trim(),
                                                      )
                                                      ? 'BIC *'
                                                      : 'BIC (optional)',
                                            ),
                                        readOnly: true,
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
                              const SizedBox(height: UIConstants.spacingS),
                              Semantics(
                                label: 'AGB und Lastschrifteinzug Bestätigung',
                                child: ListTileTheme(
                                  data: const ListTileThemeData(
                                    horizontalTitleGap: UIConstants.spacingXS,
                                    minLeadingWidth: 0,
                                  ),
                                  child: Column(
                                    children: [
                                      Semantics(
                                        label:
                                            'Checkbox zum Akzeptieren der AGB',
                                        child: CheckboxListTile(
                                          value: agbChecked,
                                          onChanged: (val) {
                                            setState(
                                              () => agbChecked = val ?? false,
                                            );
                                          },
                                          title: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder:
                                                          (_) =>
                                                              const AgbScreen(),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  'AGB',
                                                  style: UIStyles.linkStyle
                                                      .copyWith(
                                                        color:
                                                            UIConstants
                                                                .linkColor,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: UIConstants.spacingS,
                                              ),
                                              const Text('akzeptieren'),
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
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                      Semantics(
                                        label:
                                            'Checkbox zur Bestätigung des Lastschrifteinzugs',
                                        child: CheckboxListTile(
                                          value: lastschriftChecked,
                                          onChanged: (val) {
                                            setState(
                                              () =>
                                                  lastschriftChecked =
                                                      val ?? false,
                                            );
                                          },
                                          title: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: Wrap(
                                                  crossAxisAlignment:
                                                      WrapCrossAlignment.center,
                                                  spacing: UIConstants.spacingS,
                                                  children: [
                                                    Text(
                                                      'Bestätigung des\nLastschrifteinzugs',
                                                    ),
                                                    Tooltip(
                                                      message:
                                                          'Ich ermächtige Sie widerruflich, die von mir zu entrichtenden Zahlungen bei Fälligkeit Durch Lastschrift von meinem im MeinBSSB angegebenen Konto einzuziehen. Zugleich weise ich mein Kreditinstitut an, die vom BSSB auf meinem Konto gezogenen Lastschriften einzulösen.',
                                                      triggerMode:
                                                          TooltipTriggerMode
                                                              .tap,
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
                                              ),
                                            ],
                                          ),
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          contentPadding: EdgeInsets.zero,
                                        ),
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
                  Positioned(
                    bottom: UIConstants.spacingM,
                    right: UIConstants.spacingM,
                    child: DialogFABs(
                      children: [
                        FloatingActionButton(
                          heroTag: 'cancelBookingFab',
                          mini: true,
                          tooltip: 'Abbrechen',
                          backgroundColor: UIConstants.defaultAppColor,
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Icon(
                            Icons.close,
                            color: UIConstants.whiteColor,
                          ),
                        ),
                        Semantics(
                          label: 'Button zum Buchen der Buchung',
                          child: FloatingActionButton(
                            heroTag: 'submitBookingFab',
                            mini: true,
                            tooltip: 'Buchen',
                            backgroundColor:
                                (agbChecked &&
                                        lastschriftChecked &&
                                        kontoinhaberController.text
                                            .trim()
                                            .isNotEmpty &&
                                        ibanController.text.trim().isNotEmpty &&
                                        (!isBicRequired(
                                              ibanController.text.trim(),
                                            ) ||
                                            bicController.text
                                                .trim()
                                                .isNotEmpty))
                                    ? UIConstants.defaultAppColor
                                    : UIConstants.cancelButtonBackground,
                            onPressed:
                                (agbChecked &&
                                        lastschriftChecked &&
                                        kontoinhaberController.text
                                            .trim()
                                            .isNotEmpty &&
                                        ibanController.text.trim().isNotEmpty &&
                                        (!isBicRequired(
                                              ibanController.text.trim(),
                                            ) ||
                                            bicController.text
                                                .trim()
                                                .isNotEmpty))
                                    ? () async {
                                      Navigator.of(dialogContext).pop();
                                      await _onSave();
                                    }
                                    : null,
                            child: const Icon(
                              Icons.check,
                              color: UIConstants.whiteColor,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: Messages.ausweisBestellenTitle,
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      automaticallyImplyLeading: true,
      body: Semantics(
        label:
            'Schützenausweis bestellen. Hier können Sie einen neuen Schützenausweis beantragen und die Beschreibung sowie den Bestellbutton sehen.',
        child: Consumer<FontSizeProvider>(
          builder: (context, fontSizeProvider, child) {
            return Padding(
              padding: UIConstants.screenPadding,
              child: Column(
                crossAxisAlignment: UIConstants.startCrossAlignment,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    Messages.ausweisBestellenDescription,
                    style: UIStyles.bodyStyle,
                  ),
                  const SizedBox(height: UIConstants.spacingM),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Center(
                      child: ElevatedButton(
                        onPressed: _showBankDataDialog,
                        child: const Text(
                          'Schützenausweis kostenpflichtig  bestellen',
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
