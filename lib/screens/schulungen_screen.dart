import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/schulungstermin.dart';
import '/models/user_data.dart';
import '/models/bank_data.dart';
import '/screens/base_screen_layout.dart';
import '/services/api_service.dart';
import '/widgets/scaled_text.dart';
import 'package:intl/intl.dart';
import '/services/core/cache_service.dart';
import '/services/core/email_service.dart';
import 'agb_screen.dart';
import '/services/core/config_service.dart';
import 'package:flutter_html/flutter_html.dart';
import '../widgets/dialog_fabs.dart';

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

  @override
  State<SchulungenScreen> createState() => _SchulungenScreenState();
}

class _SchulungenScreenState extends State<SchulungenScreen> {
  bool _isLoading = false;
  List<Schulungstermin> _results = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _search();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  bool _isBicRequired(String iban) {
    return !iban.toUpperCase().startsWith('DE');
  }

  Future<void> _search() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _results = [];
    });
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final abDatum = _formatDate(widget.searchDate);
      final webGruppe = (widget.webGruppe != null && widget.webGruppe != 0)
          ? widget.webGruppe.toString()
          : '*';
      final bezirk = (widget.bezirkId != null && widget.bezirkId != 0)
          ? widget.bezirkId.toString()
          : '*';
      final fuerVerlaengerung =
          (widget.fuerVerlaengerungen == true) ? 'true' : '*';
      final result = await apiService.fetchSchulungstermine(
        abDatum,
        webGruppe,
        bezirk,
        fuerVerlaengerung,
      );
      setState(() {
        var filteredResults = result;
        if (widget.webGruppe != null && widget.webGruppe != 0) {
          filteredResults = filteredResults
              .where((s) => s.webGruppe == widget.webGruppe)
              .toList();
        }
        if (widget.bezirkId != null && widget.bezirkId != 0) {
          filteredResults = filteredResults
              .where((s) => s.veranstaltungsBezirk == widget.bezirkId)
              .toList();
        }
        if (widget.ort != null && widget.ort!.isNotEmpty) {
          filteredResults = filteredResults
              .where(
                (s) => s.ort.toLowerCase().contains(widget.ort!.toLowerCase()),
              )
              .toList();
        }
        if (widget.titel != null && widget.titel!.isNotEmpty) {
          filteredResults = filteredResults
              .where(
                (s) => s.bezeichnung
                    .toLowerCase()
                    .contains(widget.titel!.toLowerCase()),
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
    final user = widget.userData;
    final apiService = Provider.of<ApiService>(parentContext, listen: false);
    Provider.of<CacheService>(parentContext, listen: false);

    // Show the dialog immediately with a loading indicator
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Fetch bank data and contacts in parallel
    final Future<List<BankData>> bankDataFuture = apiService.fetchBankData(
      user?.webLoginId ?? 0,
    );
    final Future<List<Map<String, dynamic>>> contactsFuture =
        apiService.fetchKontakte(
      user?.personId ?? 0,
    );

    final List<BankData> bankDataList = await bankDataFuture;
    final List<Map<String, dynamic>> contacts = await contactsFuture;

    // Get phone number from contacts
    String extractPhoneNumber(List<Map<String, dynamic>> contacts) {
      final privateContacts = contacts.firstWhere(
        (category) => category['category'] == 'Privat',
        orElse: () => {'contacts': []},
      )['contacts'] as List<dynamic>;
      var phoneContact = privateContacts
          .cast<Map<String, dynamic>>()
          .firstWhere(
            (contact) =>
                contact['rawKontaktTyp'] == 1 || contact['rawKontaktTyp'] == 2,
            orElse: () => {'value': ''},
          );
      if (phoneContact['value'] == '') {
        final businessContacts = contacts.firstWhere(
          (category) => category['category'] == 'Geschäftlich',
          orElse: () => {'contacts': []},
        )['contacts'] as List<dynamic>;
        phoneContact = businessContacts.cast<Map<String, dynamic>>().firstWhere(
              (contact) =>
                  contact['rawKontaktTyp'] == 5 ||
                  contact['rawKontaktTyp'] == 6,
              orElse: () => {'value': ''},
            );
      }
      return phoneContact['value'] as String;
    }

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
        final telefonController = TextEditingController(
          text: phoneNumber,
        );
        final kontoinhaberController = TextEditingController(
          text: bankData?.kontoinhaber ?? '',
        );
        final ibanController = TextEditingController(
          text: bankData?.iban ?? '',
        );
        final bicController = TextEditingController(
          text: bankData?.bic ?? '',
        );

        return StatefulBuilder(
          builder: (context, setState) {
            // Attach listeners to update FAB state on every text change
            kontoinhaberController.removeListener(() {});
            ibanController.removeListener(() {});
            bicController.removeListener(() {});
            kontoinhaberController.addListener(() {
              setState(() {});
            });
            ibanController.addListener(() {
              setState(() {});
              // Trigger BIC validation when IBAN changes
              if (formKey.currentState != null) {
                formKey.currentState!.validate();
              }
            });
            bicController.addListener(() {
              setState(() {});
            });

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 520,
                ),
                child: Stack(
                  children: [
                    AlertDialog(
                      backgroundColor: UIConstants.backgroundColor,
                      title: const Center(
                        child: ScaledText(
                          'Buchungsdaten Erfassen',
                          style: UIStyles.dialogTitleStyle,
                        ),
                      ),
                      content: SingleChildScrollView(
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // --- Bank Data Block ---
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
                                    TextFormField(
                                      controller: kontoinhaberController,
                                      decoration: UIStyles.formInputDecoration
                                          .copyWith(labelText: 'Kontoinhaber'),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Kontoinhaber ist erforderlich';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(
                                      height: UIConstants.spacingM,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: ibanController,
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
                                              if (!apiService
                                                  .validateIBAN(value)) {
                                                return 'Ungültige IBAN';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          width: UIConstants.spacingM,
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            controller: bicController,
                                            decoration: UIStyles
                                                .formInputDecoration
                                                .copyWith(
                                              labelText: _isBicRequired(
                                                ibanController.text.trim(),
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
                                              // BIC is required only if IBAN doesn't start with DE
                                              final iban = ibanController.text
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
                                  ],
                                ),
                              ),
                              const SizedBox(height: UIConstants.spacingL),
                              CheckboxListTile(
                                value: agbChecked,
                                onChanged: (val) {
                                  setState(() => agbChecked = val ?? false);
                                },
                                title: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => const AgbScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'AGB',
                                        style: UIStyles.linkStyle.copyWith(
                                          color: UIConstants.linkColor,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: UIConstants.spacingS),
                                    const Text('akzeptieren'),
                                    const SizedBox(width: UIConstants.spacingS),
                                    const Tooltip(
                                      message:
                                          'Ich bin mit den AGB einverstanden.',
                                      child: Icon(
                                        Icons.info_outline,
                                        color: UIConstants.defaultAppColor,
                                        size: UIConstants.defaultIconSize,
                                      ),
                                    ),
                                  ],
                                ),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                              ),
                              CheckboxListTile(
                                value: lastschriftChecked,
                                onChanged: (val) {
                                  setState(
                                    () => lastschriftChecked = val ?? false,
                                  );
                                },
                                title: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Bestätigung des Lastschrifteinzugs',
                                      ),
                                    ),
                                    SizedBox(width: UIConstants.spacingS),
                                    Tooltip(
                                      message: // Hiermit ermächtige ich Sie widerruflich, fällige Zahlungen per Lastschrift von meinem MeinBSSB-Konto einzuziehen. Mein Kreditinstitut wird angewiesen, diese Lastschriften einzulösen
                                          'Ich ermächtige Sie widerruflich, die von mir zu entrichtenden Zahlungen bei Fälligkeit Durch Lastschrift von meinem im MeinBSSB angegebenen Konto einzuziehen. Zugleich weise ich mein Kreditinstitut an, die vom BSSB auf meinem Konto gezogenen Lastschriften einzulösen.',
                                      child: Icon(
                                        Icons.info_outline,
                                        color: UIConstants.defaultAppColor,
                                        size: UIConstants.defaultIconSize,
                                      ),
                                    ),
                                  ],
                                ),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Replace DialogFABs with a Positioned DialogFABs inside the Stack
                    Positioned(
                      bottom: UIConstants.dialogFabBottom,
                      right: UIConstants.dialogFabRight,
                      child: DialogFABs(
                        alignment: MainAxisAlignment.end,
                        children: [
                          FloatingActionButton(
                            heroTag: 'bookingDialogCancelFab',
                            mini: true,
                            tooltip: 'Abbrechen',
                            backgroundColor: UIConstants.defaultAppColor,
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                          FloatingActionButton(
                            heroTag: 'bookingDialogOkFab',
                            mini: true,
                            tooltip: 'Buchen',
                            backgroundColor: (agbChecked &&
                                    lastschriftChecked &&
                                    kontoinhaberController.text
                                        .trim()
                                        .isNotEmpty &&
                                    ibanController.text.trim().isNotEmpty &&
                                    (!_isBicRequired(
                                          ibanController.text.trim(),
                                        ) ||
                                        bicController.text.trim().isNotEmpty))
                                ? UIConstants.defaultAppColor
                                : UIConstants.cancelButtonBackground,
                            onPressed: (agbChecked &&
                                    lastschriftChecked &&
                                    kontoinhaberController.text
                                        .trim()
                                        .isNotEmpty &&
                                    ibanController.text.trim().isNotEmpty &&
                                    (!_isBicRequired(
                                          ibanController.text.trim(),
                                        ) ||
                                        bicController.text.trim().isNotEmpty))
                                ? () async {
                                    if (formKey.currentState != null &&
                                        formKey.currentState!.validate()) {
                                      Navigator.of(context).pop();
                                      final cacheService =
                                          Provider.of<CacheService>(
                                        parentContext,
                                        listen: false,
                                      );
                                      final String email = await cacheService
                                              .getString('username') ??
                                          '';
                                      final BankData safeBankData = bankData ??
                                          BankData(
                                            id: 0,
                                            webloginId: user?.webLoginId ?? 0,
                                            kontoinhaber: '',
                                            iban: '',
                                            bic: '',
                                            mandatSeq: 2,
                                            bankName: '',
                                            mandatNr: '',
                                            mandatName: '',
                                          );
                                      Future.delayed(Duration.zero, () {
                                        if (!parentContext.mounted) return;
                                        _showRegisterAnotherPersonDialog(
                                          parentContext,
                                          parentContext,
                                          schulungsTermin,
                                          registeredPersons,
                                          safeBankData,
                                          prefillUser: user?.copyWith(
                                            telefon: telefonController.text,
                                          ),
                                          prefillEmail: email,
                                        );
                                      });
                                    }
                                  }
                                : null,
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                            ),
                          ),
                        ],
                        // Remove padding from DialogFABs, as Positioned handles placement
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRegisterAnotherDialog(
    BuildContext parentContext,
    Schulungstermin schulungsTermin,
    List<_RegisteredPerson> registeredPersons,
    BankData bankData,
  ) {
    return AlertDialog(
      backgroundColor: UIConstants.backgroundColor,
      title: const Center(
        child: ScaledText(
          'Bereits angemeldete Personen',
          style: UIStyles.dialogTitleStyle,
        ),
      ),
      content: Column(
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
                                    .copyWith(fontWeight: FontWeight.bold),
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
                  text: 'Sie sind angemeldet für die Schulung\n',
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
      actions: <Widget>[
        Padding(
          padding: UIConstants.dialogPadding,
          child: Row(
            mainAxisAlignment: UIConstants.spaceBetweenAlignment,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(parentContext).pop(),
                  style: UIStyles.dialogCancelButtonStyle,
                  child: Row(
                    mainAxisAlignment: UIConstants.centerAlignment,
                    children: [
                      const Icon(
                        Icons.close,
                        color: UIConstants.closeIcon,
                      ),
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
              UIConstants.horizontalSpacingM,
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(parentContext).pop();
                    Future.delayed(Duration.zero, () {
                      if (!parentContext.mounted) return;
                      _showRegisterAnotherPersonDialog(
                        parentContext,
                        parentContext,
                        schulungsTermin,
                        registeredPersons,
                        bankData,
                      );
                    });
                  },
                  style: UIStyles.dialogAcceptButtonStyle,
                  child: Row(
                    mainAxisAlignment: UIConstants.centerAlignment,
                    children: [
                      const Icon(
                        Icons.check,
                        color: UIConstants.checkIcon,
                      ),
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
            ],
          ),
        ),
      ],
    );
  }

  void _showRegisterAnotherPersonDialog(
    BuildContext parentContext,
    BuildContext dialogContext,
    Schulungstermin schulungsTermin,
    List<_RegisteredPerson> registeredPersons,
    BankData bankData, {
    UserData? prefillUser,
    String prefillEmail = '',
  }) {
    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (context) {
        final vornameController =
            TextEditingController(text: prefillUser?.vorname ?? '');
        final nachnameController =
            TextEditingController(text: prefillUser?.namen ?? '');
        final passnummerController =
            TextEditingController(text: prefillUser?.passnummer ?? '');
        final emailController = TextEditingController(text: prefillEmail);
        final telefonnummerController =
            TextEditingController(text: prefillUser?.telefon ?? '');
        final formKey = GlobalKey<FormState>();
        bool isEmailValid(String email) {
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}');
          return emailRegex.hasMatch(email);
        }

        void submit() async {
          // Get config and email service before any await
          final configService =
              Provider.of<ConfigService>(dialogContext, listen: false);
          final emailService =
              Provider.of<EmailService>(dialogContext, listen: false);

          final from =
              configService.getString('emailRegistration.registrationFrom') ??
                  'do-not-reply@bssb.de';
          final subject = configService
                  .getString('emailRegistration.registrationSubject') ??
              'Schulung Anmeldung';
          final content =
              '${configService.getString('emailRegistration.registrationContent') ?? 'Sie sind für einen Schulung angemeldet'}\n\nSchulung: ${schulungsTermin.bezeichnung}';

          final apiService = Provider.of<ApiService>(
            dialogContext,
            listen: false,
          );

          // Show loading spinner
          showDialog(
            context: dialogContext,
            barrierDismissible: false,
            builder: (context) =>
                const Center(child: CircularProgressIndicator()),
          );

          final nachname = nachnameController.text.trim();
          final passnummer = passnummerController.text.trim();
          if (!dialogContext.mounted) return;

          final isValidPerson =
              await apiService.findePersonID2(nachname, passnummer);

          // Remove spinner
          if (dialogContext.mounted) {
            Navigator.of(dialogContext, rootNavigator: true).pop();
          }

          if (!dialogContext.mounted) return;
          if (!isValidPerson) {
            ScaffoldMessenger.of(parentContext).showSnackBar(
              const SnackBar(
                content: Text(
                  'Nachname und Passnummer stimmen nicht überein oder existieren nicht.',
                ),
                duration: UIConstants.snackbarDuration,
                backgroundColor: UIConstants.errorColor,
              ),
            );
            return;
          }

          if (!formKey.currentState!.validate()) return;

          Navigator.of(context).pop();
          try {
            final userData = prefillUser ?? widget.userData!;
            final response = await apiService.registerSchulungenTeilnehmer(
              schulungTerminId: schulungsTermin.schulungsterminId,
              user: userData.copyWith(
                vorname: vornameController.text,
                namen: nachnameController.text,
                passnummer: passnummerController.text,
                telefon: telefonnummerController.text,
              ),
              email: emailController.text,
              telefon: telefonnummerController.text,
              bankData: bankData,
              felderArray: [],
            );
            final msg = response.msg;
            if (msg == 'Teilnehmer erfolgreich erfasst' ||
                msg == 'Teilnehmer bereits erfasst' ||
                msg == 'Teilnehmer erfolgreich aktualisiert') {
              await emailService.sendEmail(
                from: from,
                recipient: emailController.text,
                subject: subject,
                body: content,
              );

              if (!dialogContext.mounted) return;
              final updatedRegisteredPersons =
                  List<_RegisteredPerson>.from(registeredPersons)
                    ..add(
                      _RegisteredPerson(
                        vornameController.text,
                        nachnameController.text,
                        passnummerController.text,
                      ),
                    );
              // Check if dialogContext is still mounted before using it
              if (!dialogContext.mounted) return;
              showDialog(
                context: dialogContext,
                barrierDismissible: false,
                builder: (context) => _buildRegisterAnotherDialog(
                  parentContext,
                  schulungsTermin,
                  updatedRegisteredPersons,
                  bankData,
                ),
              );
            } else {
              if (!parentContext.mounted) return;
              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(
                  content: Text(
                    msg.isNotEmpty ? msg : 'Fehler bei der Anmeldung.',
                  ),
                  duration: UIConstants.snackbarDuration,
                ),
              );
            }
          } catch (e) {
            if (!parentContext.mounted) return;
            ScaffoldMessenger.of(parentContext).showSnackBar(
              SnackBar(
                content: Text('Fehler bei der Anmeldung: $e'),
                duration: UIConstants.snackbarDuration,
              ),
            );
          }
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(UIConstants.spacingXL),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: UIConstants.backgroundColor,
                      borderRadius:
                          BorderRadius.circular(UIConstants.cornerRadius),
                    ),
                    padding: const EdgeInsets.only(
                      top: UIConstants.spacingXL,
                      left: UIConstants.spacingM,
                      right: UIConstants.spacingM,
                      bottom: UIConstants.spacingXL,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(
                          child: ScaledText(
                            'Person anmelden',
                            style: UIStyles.dialogTitleStyle,
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingL),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 240),
                            child: Container(
                              decoration: BoxDecoration(
                                color: UIConstants.whiteColor,
                                border: Border.all(
                                    color: UIConstants.mydarkGreyColor,),
                                borderRadius: BorderRadius.circular(
                                    UIConstants.cornerRadius,),
                              ),
                              padding: const EdgeInsets.only(
                                left: UIConstants.spacingM,
                                right: UIConstants.spacingM,
                                top: UIConstants.spacingM,
                                bottom: UIConstants.spacingM,
                              ),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    TextFormField(
                                      controller: vornameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Vorname',
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Vorname ist erforderlich';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(
                                        height: UIConstants.spacingM,),
                                    TextFormField(
                                      controller: nachnameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Nachname',
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Nachname ist erforderlich';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(
                                        height: UIConstants.spacingM,),
                                    TextFormField(
                                      controller: passnummerController,
                                      decoration: const InputDecoration(
                                        labelText: 'Passnummer',
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Passnummer ist erforderlich';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(
                                        height: UIConstants.spacingM,),
                                    TextFormField(
                                      controller: emailController,
                                      decoration: const InputDecoration(
                                        labelText: 'E-Mail',
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'E-Mail ist erforderlich';
                                        }
                                        if (!isEmailValid(value.trim())) {
                                          return 'Ungültige E-Mail-Adresse';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(
                                        height: UIConstants.spacingM,),
                                    TextFormField(
                                      controller: telefonnummerController,
                                      decoration: const InputDecoration(
                                        labelText: 'Telefonnummer',
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Telefonnummer ist erforderlich';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: UIConstants.dialogFabTightBottom,
                    right: UIConstants.dialogFabTightRight,
                    child: DialogFABs(
                      children: [
                        FloatingActionButton(
                          heroTag: 'cancelRegisterAnotherFab',
                          mini: true,
                          tooltip: 'Abbrechen',
                          backgroundColor: UIConstants.defaultAppColor,
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                        FloatingActionButton(
                          heroTag: 'okRegisterAnotherFab',
                          mini: true,
                          tooltip: 'OK',
                          backgroundColor: UIConstants.defaultAppColor,
                          onPressed: submit,
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                          ),
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Aus- und Weiterbildung',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScaledText(
                    'Verfügbare Schulungen',
                    style: UIStyles.headerStyle,
                  ),
                  const SizedBox(height: UIConstants.spacingM),
                  if (_errorMessage != null)
                    ScaledText(
                      _errorMessage!,
                      style: UIStyles.errorStyle,
                    ),
                  if (!_isLoading &&
                      _errorMessage == null &&
                      _results.isNotEmpty)
                    Expanded(
                      child: ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: UIConstants.spacingS),
                        itemBuilder: (context, index) {
                          final schulungsTermin = _results[index];
                          String formattedDate = DateFormat('dd.MM.yyyy')
                              .format(schulungsTermin.datum);
                          return Container(
                            decoration: BoxDecoration(
                              color: UIConstants.tileColor,
                              borderRadius: BorderRadius.circular(
                                UIConstants.cornerRadius,
                              ),
                            ),
                            padding: const EdgeInsets.all(UIConstants.spacingM),
                            child: Row(
                              children: [
                                // Left: date, group, location
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today,
                                            size: UIConstants.defaultIconSize,
                                          ),
                                          const SizedBox(
                                            width: UIConstants.spacingXS,
                                          ),
                                          Flexible(
                                            child: Text(
                                              formattedDate,
                                              style: UIStyles.bodyStyle,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.group,
                                            size: UIConstants.defaultIconSize,
                                          ),
                                          const SizedBox(
                                            width: UIConstants.spacingXS,
                                          ),
                                          Flexible(
                                            child: Text(
                                              schulungsTermin.webGruppeLabel,
                                              style: UIStyles.bodyStyle,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.place,
                                            size: UIConstants.defaultIconSize,
                                          ),
                                          const SizedBox(
                                            width: UIConstants.spacingXS,
                                          ),
                                          Flexible(
                                            child: Text(
                                              schulungsTermin.ort,
                                              style: UIStyles.bodyStyle,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Center: title (centered horizontally)
                                const SizedBox(width: UIConstants.spacingM),
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      schulungsTermin.bezeichnung,
                                      style: UIStyles.subtitleStyle,
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                // Right: description icon
                                FloatingActionButton(
                                  heroTag: 'schulungenContentFab$index',
                                  backgroundColor:
                                      schulungsTermin.anmeldungenGesperrt
                                          ? UIConstants.schulungenGesperrtColor
                                          : UIConstants.schulungenNormalColor,
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (context) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      barrierDismissible: false,
                                    );
                                    final apiService = Provider.of<ApiService>(
                                      context,
                                      listen: false,
                                    );
                                    final termin =
                                        await apiService.fetchSchulungstermin(
                                      schulungsTermin.schulungsterminId
                                          .toString(),
                                    );
                                    if (!context.mounted) return;
                                    Navigator.of(context, rootNavigator: true)
                                        .pop(); // Remove spinner
                                    if (termin == null) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Fehler'),
                                          content: const Text(
                                            'Details konnten nicht geladen werden.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                      return;
                                    }
                                    // Fallback for lehrgangsleiterMail and lehrgangsleiterTel
                                    final lehrgangsleiterMail = (termin
                                            .lehrgangsleiterMail.isNotEmpty)
                                        ? termin.lehrgangsleiterMail
                                        : schulungsTermin.lehrgangsleiterMail;
                                    final lehrgangsleiterTel = (termin
                                            .lehrgangsleiterTel.isNotEmpty)
                                        ? termin.lehrgangsleiterTel
                                        : schulungsTermin.lehrgangsleiterTel;
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        final t = termin;
                                        return Stack(
                                          children: [
                                            AlertDialog(
                                              backgroundColor:
                                                  UIConstants.backgroundColor,
                                              contentPadding: EdgeInsets.zero,
                                              // Move header into content for full-width white background
                                              actions: null,
                                              content: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxHeight:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.8,
                                                  minWidth: 300,
                                                ),
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      // Header: white background, title, availability, and info table
                                                      Container(
                                                        width: double.infinity,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          vertical: 28,
                                                          horizontal: 0,
                                                        ), // enlarged vertical padding
                                                        decoration:
                                                            BoxDecoration(
                                                          color: UIConstants
                                                              .whiteColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            UIConstants
                                                                .cornerRadius,
                                                          ), // rounded all corners
                                                        ),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal:
                                                                    24.0,
                                                              ),
                                                              child: Text(
                                                                (t.bezeichnung
                                                                        .isNotEmpty
                                                                    ? t
                                                                        .bezeichnung
                                                                    : schulungsTermin
                                                                        .bezeichnung),
                                                                style: UIStyles
                                                                    .dialogTitleStyle,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Text(
                                                              'Es sind noch ${t.maxTeilnehmer - t.angemeldeteTeilnehmer} von ${t.maxTeilnehmer} Plätzen frei',
                                                              style: UIStyles
                                                                  .bodyStyle
                                                                  .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            const SizedBox(
                                                              height: 24,
                                                            ), // enlarged space between availability and table
                                                            // Info table below availability (centered, compact, visually matching screenshot)
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal:
                                                                    32, // tighter, equal left/right padding
                                                                vertical:
                                                                    UIConstants
                                                                        .spacingS,
                                                              ),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  // Left column (left-aligned)
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          const Icon(
                                                                            Icons.calendar_today,
                                                                            size:
                                                                                UIConstants.defaultIconSize,
                                                                          ),
                                                                          UIConstants
                                                                              .horizontalSpacingS,
                                                                          Text(
                                                                            _formatDate(
                                                                              t.datum,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            UIConstants.spacingXS,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          const Icon(
                                                                            Icons.location_on,
                                                                            size:
                                                                                UIConstants.defaultIconSize,
                                                                          ),
                                                                          UIConstants
                                                                              .horizontalSpacingS,
                                                                          Text(
                                                                            t.ort,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            maxLines:
                                                                                1,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            UIConstants.spacingXS,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          const Icon(
                                                                            Icons.group,
                                                                            size:
                                                                                UIConstants.defaultIconSize,
                                                                          ),
                                                                          UIConstants
                                                                              .horizontalSpacingS,
                                                                          Text(
                                                                            t.webGruppeLabel,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            maxLines:
                                                                                1,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            UIConstants.spacingXS,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          const Icon(
                                                                            Icons.request_quote,
                                                                            size:
                                                                                UIConstants.defaultIconSize,
                                                                          ),
                                                                          UIConstants
                                                                              .horizontalSpacingS,
                                                                          Text(
                                                                            '${t.kosten.toStringAsFixed(2)} €',
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 40,
                                                                  ), // reduced space between columns
                                                                  // Right column (right-aligned)
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Lehrgangsleiter:',
                                                                        style: UIStyles
                                                                            .bodyStyle
                                                                            .copyWith(fontWeight: FontWeight.bold),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            UIConstants.spacingXS,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          const Icon(
                                                                            Icons.email,
                                                                            size:
                                                                                UIConstants.defaultIconSize,
                                                                          ),
                                                                          UIConstants
                                                                              .horizontalSpacingS,
                                                                          Text(
                                                                            lehrgangsleiterMail,
                                                                            style:
                                                                                UIStyles.bodyStyle,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            maxLines:
                                                                                1,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            UIConstants.spacingXS,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          const Icon(
                                                                            Icons.phone,
                                                                            size:
                                                                                UIConstants.defaultIconSize,
                                                                          ),
                                                                          UIConstants
                                                                              .horizontalSpacingS,
                                                                          Text(
                                                                            lehrgangsleiterTel,
                                                                            style:
                                                                                UIStyles.bodyStyle,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            maxLines:
                                                                                1,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      // ... rest of dialog content ...
                                                      const Divider(
                                                        height: UIConstants
                                                            .defaultStrokeWidth,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(
                                                          UIConstants.spacingM,
                                                        ),
                                                        child: t.lehrgangsinhaltHtml
                                                                .isNotEmpty
                                                            ? Html(
                                                                data: t
                                                                    .lehrgangsinhaltHtml,
                                                              )
                                                            : t.lehrgangsinhalt
                                                                    .isNotEmpty
                                                                ? Text(
                                                                    t.lehrgangsinhalt,
                                                                  )
                                                                : t.bemerkung
                                                                        .isNotEmpty
                                                                    ? Text(
                                                                        t.bemerkung,
                                                                      )
                                                                    : const Text(
                                                                        'Keine Beschreibung verfügbar.',
                                                                      ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: UIConstants
                                                      .dialogFabBottom +
                                                  UIConstants
                                                      .dialogFabDeleteOffset,
                                              right: UIConstants.dialogFabRight,
                                              child: FloatingActionButton(
                                                heroTag:
                                                    'descDialogCloseFab$index',
                                                mini: true,
                                                tooltip: 'Schließen',
                                                backgroundColor:
                                                    UIConstants.defaultAppColor,
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom:
                                                  UIConstants.dialogFabBottom,
                                              right: UIConstants.dialogFabRight,
                                              child: FloatingActionButton(
                                                heroTag:
                                                    'descDialogBookFab$index',
                                                mini: true,
                                                tooltip: 'Buchen',
                                                backgroundColor: t
                                                        .anmeldungenGesperrt
                                                    ? UIConstants
                                                        .cancelButtonBackground
                                                    : UIConstants
                                                        .defaultAppColor,
                                                onPressed: t.anmeldungenGesperrt
                                                    ? null
                                                    : () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        _showBookingDialog(
                                                          t,
                                                          registeredPersons: [],
                                                        );
                                                      },
                                                child: const Icon(
                                                  Icons.event_available,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: const Icon(
                                    Icons.description,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  if (!_isLoading && _errorMessage == null && _results.isEmpty)
                    const ScaledText(
                      'Keine Schulungen gefunden.',
                      style: UIStyles.bodyStyle,
                    ),
                ],
              ),
      ),
    );
  }
}

class _RegisteredPerson {
  _RegisteredPerson(this.vorname, this.nachname, this.passnummer);
  final String vorname;
  final String nachname;
  final String passnummer;
}
