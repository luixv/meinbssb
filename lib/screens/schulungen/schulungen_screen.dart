import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/schulungstermin_data.dart';
import '/models/user_data.dart';
import '/models/bank_data.dart';
import '/helpers/utils.dart';

import '/screens/base_screen_layout.dart';
import '/services/api_service.dart';
import '/widgets/scaled_text.dart';
import '/widgets/dialog_fabs.dart';

import '/screens/agb/agb_screen.dart';

import 'schulungen_search_screen.dart';
import 'schulungen_register_person_dialog.dart';
import 'schulungen_list_item.dart';
import 'schulungen_details_dialog.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

class SchulungenScreen extends StatefulWidget {
  const SchulungenScreen(
    this.userData, {
    required this.isLoggedIn,
    required this.onLogout,
    required this.searchDate,
    this.webGruppe,
    this.bezirkId,
    this.ort,
    this.titel,
    this.fuerVerlaengerungen,
    this.fuerVuelVerlaengerungen,
    this.showMenu = true,
    this.showConnectivityIcon = true,
    super.key,
  });
  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;
  final DateTime searchDate;
  final int? webGruppe;
  final int? bezirkId;
  final String? ort;
  final String? titel;
  final bool? fuerVerlaengerungen;
  final bool? fuerVuelVerlaengerungen;
  final bool showMenu;
  final bool showConnectivityIcon;

  @override
  State<SchulungenScreen> createState() => _SchulungenScreenState();
}

class _SchulungenScreenState extends State<SchulungenScreen> {
  bool _isLoading = false;
  List<Schulungstermin> _results = [];
  String? _errorMessage;
  UserData? _userData;

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
    _search();
  }

  Future<void> _search() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _results = [];
    });
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final abDatum = formatDate(widget.searchDate);
      final webGruppe =
          (widget.webGruppe != null && widget.webGruppe != 0)
              ? widget.webGruppe.toString()
              : '*';
      final bezirk =
          (widget.bezirkId != null && widget.bezirkId != 0)
              ? widget.bezirkId.toString()
              : '*';
      final fuerVerlaengerung =
          (widget.fuerVerlaengerungen == true) ? 'true' : '*';
      final fuerVuelVerlaengerung =
          (widget.fuerVuelVerlaengerungen == true) ? 'true' : '*';

      final result = await apiService.fetchSchulungstermine(
        abDatum,
        webGruppe,
        bezirk,
        fuerVerlaengerung,
        fuerVuelVerlaengerung,
      );

      // Filter out all entries where geloescht == true
      var filteredResults = result.where((s) => s.geloescht != true).toList();

      setState(() {
        if (widget.webGruppe != null && widget.webGruppe != 0) {
          filteredResults =
              filteredResults
                  .where((s) => s.webGruppe == widget.webGruppe)
                  .toList();
        }
        if (widget.bezirkId != null && widget.bezirkId != 0) {
          filteredResults =
              filteredResults
                  .where((s) => s.veranstaltungsBezirk == widget.bezirkId)
                  .toList();
        }
        if (widget.ort != null && widget.ort!.isNotEmpty) {
          filteredResults =
              filteredResults
                  .where(
                    (s) =>
                        s.ort.toLowerCase().contains(widget.ort!.toLowerCase()),
                  )
                  .toList();
        }
        if (widget.titel != null && widget.titel!.isNotEmpty) {
          filteredResults =
              filteredResults
                  .where(
                    (s) => s.bezeichnung.toLowerCase().contains(
                      widget.titel!.toLowerCase(),
                    ),
                  )
                  .toList();
        }
        if (widget.fuerVerlaengerungen == true) {
          filteredResults =
              filteredResults.where((s) => s.fuerVerlaengerungen).toList();
        }
        _results = filteredResults;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Laden der Schulungen: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showBookingDialog(
    Schulungstermin schulungsTermin, {
    required List<_RegisteredPerson> registeredPersons,
  }) async {
    if (!mounted) return;
    final parentContext = context;
    final user = _userData;
    if (user == null) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        const SnackBar(
          content: Text('Kein Benutzer für die Buchung verfügbar.'),
          duration: UIConstants.snackbarDuration,
          backgroundColor: UIConstants.errorColor,
        ),
      );
      return;
    }
    final apiService = Provider.of<ApiService>(parentContext, listen: false);

    // Show the dialog immediately with a loading indicator
    showDialog(
      context: parentContext,
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

    // Fetch bank data and contacts in parallel
    final Future<List<BankData>> bankDataFuture = apiService
        .fetchBankdatenMyBSSB(user.webLoginId);
    final Future<List<Map<String, dynamic>>> contactsFuture = apiService
        .fetchKontakte(user.personId);

    final List<BankData> bankDataList = await bankDataFuture;
    if (!mounted) return;
    final List<Map<String, dynamic>> contacts = await contactsFuture;
    if (!mounted) return;

    final String phoneNumber = extractPhoneNumber(contacts);
    final bankData = bankDataList.isNotEmpty ? bankDataList.first : null;

    if (!mounted) return;
    if (!parentContext.mounted) return;

    // Pop the loading indicator
    Navigator.of(parentContext, rootNavigator: true).pop();

    // Show the actual booking dialog with the fetched data
    bool agbChecked = false;
    bool lastschriftChecked = false;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: parentContext,
      builder: (context) {
        final telefonController = TextEditingController(text: phoneNumber);
        final kontoinhaberController = TextEditingController(
          text: bankData?.kontoinhaber ?? '',
        );
        final ibanController = TextEditingController(
          text: bankData?.iban ?? '',
        );
        final bicController = TextEditingController(text: bankData?.bic ?? '');

        return StatefulBuilder(
          builder: (context, setState) {
            kontoinhaberController.removeListener(() {});
            ibanController.removeListener(() {});
            bicController.removeListener(() {});
            kontoinhaberController.addListener(() {
              setState(() {});
            });
            ibanController.addListener(() {
              setState(() {});
              if (formKey.currentState != null) {
                formKey.currentState!.validate();
              }
            });
            bicController.addListener(() {
              setState(() {});
            });

            final FontSizeProvider fontSizeProvider =
                Provider.of<FontSizeProvider>(context);
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
                        // force the AlertDialog to respect max width
                        width: MediaQuery.of(context).size.width.clamp(
                          0,
                          UIConstants.dialogMaxWidth.toDouble(),
                        ),
                        child: AlertDialog(
                          backgroundColor: UIConstants.backgroundColor,
                          insetPadding:
                              EdgeInsets.zero, // remove default Flutter margins
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
                                width:
                                    double
                                        .maxFinite, // 👈 stretch form inside dialog
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
                                                  color:
                                                      UIConstants
                                                          .mydarkGreyColor,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      UIConstants.cornerRadius,
                                                    ),
                                              ),
                                              padding:
                                                  UIConstants.defaultPadding,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Bankdaten',
                                                    style:
                                                        UIStyles.subtitleStyle,
                                                  ),
                                                  const SizedBox(
                                                    height:
                                                        UIConstants.spacingM,
                                                  ),
                                                  Semantics(
                                                    label:
                                                        'Eingabefeld für Kontoinhaber',
                                                    child: TextFormField(
                                                      controller:
                                                          kontoinhaberController,
                                                      style: UIStyles
                                                          .formValueStyle
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
                                                                'Kontoinhaber',
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
                                                    height:
                                                        UIConstants.spacingM,
                                                  ),
                                                  Semantics(
                                                    label:
                                                        'Eingabefeld für IBAN',
                                                    child: TextFormField(
                                                      controller:
                                                          ibanController,
                                                      style: UIStyles
                                                          .formValueStyle
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
                                                            labelText: 'IBAN',
                                                          ),
                                                      validator: (value) {
                                                        final apiService =
                                                            Provider.of<
                                                              ApiService
                                                            >(
                                                              context,
                                                              listen: false,
                                                            );
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return 'IBAN ist erforderlich';
                                                        }
                                                        if (!apiService
                                                            .validateIBAN(
                                                              value,
                                                            )) {
                                                          return 'Ungültige IBAN';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                    height:
                                                        UIConstants.spacingM,
                                                  ),
                                                  Semantics(
                                                    label:
                                                        'Eingabefeld für BIC',
                                                    child: TextFormField(
                                                      controller: bicController,
                                                      style: UIStyles
                                                          .formValueStyle
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
                                                            Provider.of<
                                                              ApiService
                                                            >(
                                                              context,
                                                              listen: false,
                                                            );
                                                        final iban =
                                                            ibanController.text
                                                                .trim()
                                                                .toUpperCase();
                                                        if (!iban.startsWith(
                                                              'DE',
                                                            ) &&
                                                            (value == null ||
                                                                value
                                                                    .trim()
                                                                    .isEmpty)) {
                                                          return 'BIC ist erforderlich für nicht-deutsche IBANs';
                                                        }
                                                        if (value != null &&
                                                            value
                                                                .trim()
                                                                .isNotEmpty) {
                                                          final bicError =
                                                              apiService
                                                                  .validateBIC(
                                                                    value,
                                                                  );
                                                          if (bicError !=
                                                              null) {
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
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Semantics(
                                                          label:
                                                              'Checkbox zum Akzeptieren der AGB',
                                                          child: Focus(
                                                            onKey: (node, event) {
                                                              if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
                                                                  event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
                                                                setState(() {
                                                                  agbChecked = !agbChecked;
                                                                });
                                                                return KeyEventResult.handled;
                                                              }
                                                              return KeyEventResult.ignored;
                                                            },
                                                            child: Checkbox(
                                                              value: agbChecked,
                                                              onChanged: (val) {
                                                                setState(
                                                                  () =>
                                                                      agbChecked =
                                                                          val ??
                                                                          false,
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width:
                                                              UIConstants
                                                                  .spacingS,
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (
                                                                    context,
                                                                  ) => Dialog(
                                                                    child: SizedBox(
                                                                      width:
                                                                          600,
                                                                      height:
                                                                          600,
                                                                      child:
                                                                          const AgbScreen(),
                                                                    ),
                                                                  ),
                                                            );
                                                          },
                                                          child: Text(
                                                            'AGB',
                                                            style: UIStyles.linkStyle.copyWith(
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
                                                          width:
                                                              UIConstants
                                                                  .spacingS,
                                                        ),
                                                        Text(
                                                          'akzeptieren',
                                                          style: UIStyles
                                                              .bodyStyle
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
                                                          width:
                                                              UIConstants
                                                                  .spacingS,
                                                        ),
                                                        const Tooltip(
                                                          message:
                                                              'Ich bin mit den AGB einverstanden.',
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
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Semantics(
                                                          label:
                                                              'Checkbox zur Bestätigung des Lastschrifteinzugs',
                                                          child: Focus(
                                                            onKey: (node, event) {
                                                              if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
                                                                  event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
                                                                setState(() {
                                                                  lastschriftChecked = !lastschriftChecked;
                                                                });
                                                                return KeyEventResult.handled;
                                                              }
                                                              return KeyEventResult.ignored;
                                                            },
                                                            child: Checkbox(
                                                              value:
                                                                  lastschriftChecked,
                                                              onChanged: (val) {
                                                                setState(
                                                                  () =>
                                                                      lastschriftChecked =
                                                                          val ??
                                                                          false,
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width:
                                                              UIConstants
                                                                  .spacingS,
                                                        ),
                                                        Text(
                                                          'Bestätigung des\nLastschrifteinzugs',
                                                          style: UIStyles
                                                              .bodyStyle
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
                                                          width:
                                                              UIConstants
                                                                  .spacingS,
                                                        ),
                                                        const Tooltip(
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

                                                    const SizedBox(
                                                      height:
                                                          UIConstants.spacingM,
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
                                    Semantics(
                                      container: true,
                                      button: true,
                                      label: 'Buchung abbrechen',
                                      child: FloatingActionButton(
                                        heroTag: 'cancelBookingFab',
                                        mini: true,
                                        tooltip: 'Abbrechen',
                                        backgroundColor:
                                            UIConstants.defaultAppColor,
                                        onPressed:
                                            () => Navigator.of(context).pop(),
                                        child: const Icon(
                                          Icons.close,
                                          color: UIConstants.whiteColor,
                                        ),
                                      ),
                                    ),
                                    Semantics(
                                      container: true,
                                      button: true,
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
                                                    ibanController.text
                                                        .trim()
                                                        .isNotEmpty &&
                                                    (!isBicRequired(
                                                          ibanController.text
                                                              .trim(),
                                                        ) ||
                                                        bicController.text
                                                            .trim()
                                                            .isNotEmpty))
                                                ? UIConstants.defaultAppColor
                                                : UIConstants
                                                    .cancelButtonBackground,
                                        onPressed:
                                            (agbChecked &&
                                                    lastschriftChecked &&
                                                    kontoinhaberController.text
                                                        .trim()
                                                        .isNotEmpty &&
                                                    ibanController.text
                                                        .trim()
                                                        .isNotEmpty &&
                                                    (!isBicRequired(
                                                          ibanController.text
                                                              .trim(),
                                                        ) ||
                                                        bicController.text
                                                            .trim()
                                                            .isNotEmpty))
                                                ? () async {
                                                  if (formKey.currentState !=
                                                          null &&
                                                      formKey.currentState!
                                                          .validate()) {
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
                                                    safeBankData =
                                                        bankData ??
                                                        BankData(
                                                          id: 0,
                                                          webloginId:
                                                              user.webLoginId,
                                                          kontoinhaber: '',
                                                          iban: '',
                                                          bic: '',
                                                          mandatSeq: 2,
                                                          bankName: '',
                                                          mandatNr: '',
                                                          mandatName: '',
                                                        );
                                                    await registerPersonAndShowDialog(
                                                      schulungsTermin:
                                                          schulungsTermin,
                                                      registeredPersons:
                                                          registeredPersons,
                                                      bankData: safeBankData,
                                                      prefillUser: user.copyWith(
                                                        telefon:
                                                            telefonController
                                                                .text,
                                                      ),
                                                      prefillEmail: email,
                                                    );
                                                  }
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildRegisterAnotherDialog(
    BuildContext context,
    Schulungstermin schulungsTermin,
    List<_RegisteredPerson> registeredPersons,
    BankData bankData,
  ) {
    return Semantics(
      label: 'Dialog zur Anmeldung weiterer Personen für die Schulung.',
      child: AlertDialog(
        backgroundColor: UIConstants.backgroundColor,
        title: Center(
          child: ScaledText(
            'Bereits angemeldete Personen',
            style: UIStyles.dialogTitleStyle,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (registeredPersons.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...registeredPersons.map(
                        (p) => Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: UIStyles.dialogContentStyle,
                                  children: [
                                    const TextSpan(
                                      text: '• ',
                                      style: UIStyles.dialogContentStyle,
                                    ),
                                    TextSpan(
                                      text: '${p.vorname} ${p.nachname}',
                                      style: UIStyles.dialogContentStyle
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    TextSpan(
                                      text: ' (${p.passnummer})',
                                      style: UIStyles.dialogContentStyle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),
                    ],
                  ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: UIStyles.dialogContentStyle,
                    children: <TextSpan>[
                      const TextSpan(
                        text: 'Sie sind angemeldet für die Schulung\n\n',
                      ),
                      TextSpan(
                        text: schulungsTermin.bezeichnung,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
                const SizedBox(height: UIConstants.spacingL),
                const Text(
                  'Möchten Sie noch eine weitere Person für diese Schulung anmelden?',
                  textAlign: TextAlign.center,
                  style: UIStyles.dialogContentStyle,
                ),
              ],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: UIConstants.dialogPadding,
            child: Row(
              mainAxisAlignment: UIConstants.spaceBetweenAlignment,
              children: [
                Expanded(
                  child: Semantics(
                    label: 'Button zum Abbrechen und Rückkehr zur Übersicht',
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pop('goHome');
                      },
                      style: UIStyles.dialogCancelButtonStyle,
                      child: Row(
                        mainAxisAlignment: UIConstants.centerAlignment,
                        children: [
                          const Icon(Icons.close, color: UIConstants.closeIcon),
                          const SizedBox(width: UIConstants.spacingS),
                          ScaledText(
                            'Nein',
                            style: UIStyles.dialogButtonTextStyle.copyWith(
                              color: UIConstants.cancelButtonText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                UIConstants.horizontalSpacingM,
                Expanded(
                  child: Semantics(
                    label:
                        'Button zum Hinzufügen einer weiteren Person zur Schulung',
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pop('registerAnother');
                      },
                      style: UIStyles.dialogAcceptButtonStyle,
                      child: Row(
                        mainAxisAlignment: UIConstants.centerAlignment,
                        children: [
                          const Icon(Icons.check, color: UIConstants.checkIcon),
                          const SizedBox(width: UIConstants.spacingS),
                          ScaledText(
                            'Ja',
                            style: UIStyles.dialogButtonTextStyle.copyWith(
                              color: UIConstants.submitButtonText,
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
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Aus- und Weiterbildung',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      automaticallyImplyLeading: widget.showMenu,
      showMenu: widget.showMenu,
      showConnectivityIcon: widget.showConnectivityIcon,
      leading:
          !widget.showMenu
              ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: UIConstants.textColor,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => SchulungenSearchScreen(
                            userData: widget.userData,
                            isLoggedIn: widget.isLoggedIn,
                            onLogout: widget.onLogout,
                            showMenu: widget.showMenu,
                            showConnectivityIcon: widget.showConnectivityIcon,
                          ),
                    ),
                  );
                },
              )
              : null,
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      UIConstants.defaultAppColor,
                    ),
                  ),
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ScaledText(
                      'Verfügbare Aus- und Weiterbildungen',
                      style: UIStyles.headerStyle,
                    ),
                    const SizedBox(height: UIConstants.spacingM),
                    if (_errorMessage != null)
                      ScaledText(_errorMessage!, style: UIStyles.errorStyle),
                    if (!_isLoading &&
                        _errorMessage == null &&
                        _results.isNotEmpty)
                      Expanded(
                        child: ListView.separated(
                          itemCount: _results.length + 1,
                          separatorBuilder: (context, index) {
                            // Only add separator between real items
                            if (index < _results.length - 1) {
                              return const SizedBox(
                                height: UIConstants.spacingS,
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          itemBuilder: (context, index) {
                            if (index == _results.length) {
                              // Extra space after last item
                              return const SizedBox(
                                height: UIConstants.helpSpacing,
                              );
                            }
                            final schulungsTermin = _results[index];
                            return SchulungenListItem(
                              schulungsTermin: schulungsTermin,
                              index: index,
                              onDetailsPressed: () async {
                                // Show loading spinner
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => const Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                UIConstants.defaultAppColor,
                                              ),
                                        ),
                                      ),
                                  barrierDismissible: false,
                                );

                                final apiService = Provider.of<ApiService>(
                                  context,
                                  listen: false,
                                );
                                final termin = await apiService
                                    .fetchSchulungstermin(
                                      schulungsTermin.schulungsterminId
                                          .toString(),
                                    );
                                if (!context.mounted) return;

                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop(); // Remove spinner

                                if (termin == null) {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text('Fehler'),
                                          content: const Text(
                                            'Details konnten nicht geladen werden.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () =>
                                                      Navigator.of(
                                                        context,
                                                      ).pop(),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                  );
                                  return;
                                }

                                // Fallback for lehrgangsleiterMail and lehrgangsleiterTel
                                final lehrgangsleiterMail =
                                    (termin.lehrgangsleiterMail.isNotEmpty)
                                        ? termin.lehrgangsleiterMail
                                        : schulungsTermin.lehrgangsleiterMail;
                                final lehrgangsleiterTel =
                                    (termin.lehrgangsleiterTel.isNotEmpty)
                                        ? termin.lehrgangsleiterTel
                                        : schulungsTermin.lehrgangsleiterTel;

                                // Show the extracted details dialog
                                await SchulungenDetailsDialog.show(
                                  context,
                                  termin,
                                  schulungsTermin,
                                  lehrgangsleiterMail: lehrgangsleiterMail,
                                  lehrgangsleiterTel: lehrgangsleiterTel,
                                  isUserLoggedIn: _userData != null,
                                  personId: _userData?.personId,
                                  onBookingPressed: () {
                                    if (_userData == null) {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder:
                                            (dialogContext) => LoginDialog(
                                              onLoginSuccess: (userData) {
                                                setState(() {
                                                  _userData = userData;
                                                });
                                                _showBookingDialog(
                                                  termin,
                                                  registeredPersons: [],
                                                );
                                              },
                                            ),
                                      );
                                    } else {
                                      _showBookingDialog(
                                        termin,
                                        registeredPersons: [],
                                      );
                                    }
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    if (!_isLoading &&
                        _errorMessage == null &&
                        _results.isEmpty)
                      const ScaledText(
                        'Keine Schulungen gefunden.',
                        style: UIStyles.bodyStyle,
                      ),
                    const SizedBox(height: UIConstants.helpSpacing),
                  ],
                ),
      ),
    );
  }

  Future<void> registerPersonAndShowDialog({
    required Schulungstermin schulungsTermin,
    required List<_RegisteredPerson> registeredPersons,
    required BankData bankData,
    UserData? prefillUser,
    String prefillEmail = '',
  }) async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    // Show registration form dialog and wait for result
    final RegisteredPerson? newPerson = await showDialog<RegisteredPerson>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return RegisterPersonFormDialog(
          schulungsTermin: schulungsTermin,
          bankData: bankData,
          prefillUser: prefillUser,
          prefillEmail: prefillEmail,
          apiService: apiService,
        );
      },
    );
    if (newPerson == null) return; // User cancelled
    final updatedRegisteredPersons = List<_RegisteredPerson>.from(
      registeredPersons,
    )..add(
      _RegisteredPerson(
        newPerson.vorname,
        newPerson.nachname,
        newPerson.passnummer,
      ),
    );

    // After registration, show the 'register another' dialog
    final String? registerAnother = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return buildRegisterAnotherDialog(
          context,
          schulungsTermin,
          updatedRegisteredPersons,
          bankData,
        );
      },
    );
    if (!mounted) return;
    if (registerAnother == 'registerAnother') {
      // Call the method again for the next person
      await registerPersonAndShowDialog(
        schulungsTermin: schulungsTermin,
        registeredPersons: updatedRegisteredPersons,
        bankData: bankData,
      );
    } else if (registerAnother == 'goHome') {
      // Navigate to home screen
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
        (route) => false,
        arguments: {
          'userData': widget.userData,
          'isLoggedIn': widget.isLoggedIn,
          'onLogout': widget.onLogout,
          'showMenu': widget.isLoggedIn,
          'showConnectivityIcon': widget.isLoggedIn,
        },
      );
    }
  }
}

class _RegisteredPerson {
  _RegisteredPerson(this.vorname, this.nachname, this.passnummer);
  final String vorname;
  final String nachname;
  final String passnummer;
}

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key, required this.onLoginSuccess});
  final Function(UserData) onLoginSuccess;

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final response = await apiService.login(
        _emailController.text,
        _passwordController.text,
      );
      if (!mounted) return;
      if (response['ResultType'] == 1) {
        final personId = response['PersonID'];
        final webloginId = response['WebLoginID'];
        var passdaten = await apiService.fetchPassdaten(personId);
        if (!mounted) return;
        if (passdaten != null) {
          final userData = passdaten.copyWith(webLoginId: webloginId);
          Navigator.of(context).pop();
          widget.onLoginSuccess(userData);
        } else {
          setState(() => _errorMessage = 'Fehler beim Laden der Passdaten.');
        }
      } else {
        setState(
          () =>
              _errorMessage =
                  response['ResultMessage'] ?? 'Login fehlgeschlagen.',
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Fehler: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: UIConstants.backgroundColor,
      title: const Center(
        child: ScaledText(
          'Login erforderlich',
          style: UIStyles.dialogTitleStyle,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Padding(
            padding: UIConstants.dialogPadding.copyWith(
              bottom: UIConstants.spacingS,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: UIConstants.spacingS,
                    ),
                    child: ScaledText(
                      _errorMessage,
                      style: UIStyles.errorStyle,
                    ),
                  ),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: UIStyles.formInputDecoration.copyWith(
                    labelText: 'E-Mail',
                  ),
                  enabled: !_isLoading,
                  style: UIStyles.dialogContentStyle,
                ),
                const SizedBox(height: UIConstants.spacingM),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: UIStyles.formInputDecoration.copyWith(
                    labelText: 'Passwort',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  enabled: !_isLoading,
                  style: UIStyles.dialogContentStyle,
                  onSubmitted: (_) => _handleLogin(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Row(
            mainAxisAlignment: UIConstants.spaceBetweenAlignment,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                  style: UIStyles.dialogCancelButtonStyle,
                  child: Row(
                    mainAxisAlignment: UIConstants.centerAlignment,
                    children: [
                      const Icon(Icons.close, color: UIConstants.closeIcon),
                      const SizedBox(width: UIConstants.spacingS),
                      ScaledText(
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
              UIConstants.horizontalSpacingM,
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: UIStyles.dialogAcceptButtonStyle,
                  child: Row(
                    mainAxisAlignment: UIConstants.centerAlignment,
                    children: [
                      const Icon(Icons.login, color: UIConstants.checkIcon),
                      const SizedBox(width: UIConstants.spacingS),
                      _isLoading
                          ? const SizedBox(
                            width: UIConstants.loadingIndicatorSize,
                            height: UIConstants.loadingIndicatorSize,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                UIConstants.defaultAppColor,
                              ),
                            ),
                          )
                          : ScaledText(
                            'Login',
                            style: UIStyles.dialogButtonTextStyle.copyWith(
                              color: UIConstants.submitButtonText,
                              fontSize: UIConstants.buttonFontSize,
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
  }
}
