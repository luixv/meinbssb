import 'package:flutter/material.dart';

import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/schulungstermin_data.dart';
import '/models/user_data.dart';
import '/models/bank_data.dart';
import '/models/schulungstermine_zusatzfelder_data.dart';

import '/services/api_service.dart';
import '/services/core/config_service.dart';
import '/services/core/email_service.dart';
import '/widgets/dialog_fabs.dart';
import '/widgets/scaled_text.dart';

class RegisteredPerson {
  RegisteredPerson(this.vorname, this.nachname, this.passnummer);
  final String vorname;
  final String nachname;
  final String passnummer;
}

class RegisterPersonFormDialog extends StatefulWidget {
  const RegisterPersonFormDialog({
    super.key,
    required this.schulungsTermin,
    required this.bankData,
    this.prefillUser,
    this.prefillEmail = '',
    required this.configService,
    required this.emailService,
    required this.apiService,
  });
  final Schulungstermin schulungsTermin;
  final BankData bankData;
  final UserData? prefillUser;
  final String prefillEmail;
  final ConfigService configService;
  final EmailService emailService;
  final ApiService apiService;

  @override
  State<RegisterPersonFormDialog> createState() =>
      _RegisterPersonFormDialogState();
}

class _RegisterPersonFormDialogState extends State<RegisterPersonFormDialog> {
  late final TextEditingController vornameController;
  late final TextEditingController nachnameController;
  late final TextEditingController passnummerController;
  late final TextEditingController emailController;
  late final TextEditingController telefonnummerController;
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool allFieldsFilled = false;

  List<SchulungstermineZusatzfelder> zusatzfelder = [];
  final Map<int, TextEditingController> zusatzfeldControllers = {};
  bool zusatzfelderLoaded = false;

  @override
  void initState() {
    super.initState();
    vornameController =
        TextEditingController(text: widget.prefillUser?.vorname ?? '');
    nachnameController =
        TextEditingController(text: widget.prefillUser?.namen ?? '');
    passnummerController =
        TextEditingController(text: widget.prefillUser?.passnummer ?? '');
    emailController = TextEditingController(text: widget.prefillEmail);
    telefonnummerController =
        TextEditingController(text: widget.prefillUser?.telefon ?? '');

    fetchSchulungstermineZusatzfelder(widget.schulungsTermin.schulungsterminId)
        .then((result) {
      if (mounted) {
        setState(() {
          zusatzfelder = result;
          for (final feld in zusatzfelder) {
            final controller = TextEditingController();
            controller.addListener(_checkAllFieldsFilled);
            zusatzfeldControllers[feld.schulungstermineFeldId] = controller;
          }
          zusatzfelderLoaded = true;
          _checkAllFieldsFilled();
        });
      }
    });

    vornameController.addListener(_checkAllFieldsFilled);
    nachnameController.addListener(_checkAllFieldsFilled);
    passnummerController.addListener(_checkAllFieldsFilled);
    emailController.addListener(_checkAllFieldsFilled);
    telefonnummerController.addListener(_checkAllFieldsFilled);
  }

  @override
  void dispose() {
    vornameController.dispose();
    nachnameController.dispose();
    passnummerController.dispose();
    emailController.dispose();
    telefonnummerController.dispose();
    for (final controller in zusatzfeldControllers.values) {
      controller.removeListener(_checkAllFieldsFilled);
      controller.dispose();
    }
    super.dispose();
  }

  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}');
    return emailRegex.hasMatch(email);
  }

  Future<List<SchulungstermineZusatzfelder>> fetchSchulungstermineZusatzfelder(
    int schulungsTerminId,
  ) async {
    return widget.apiService.fetchSchulungstermineZusatzfelder(
      schulungsTerminId,
    );
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    final nachname = nachnameController.text.trim();
    final passnummer = passnummerController.text.trim();

    final personId =
        await widget.apiService.findePersonID2(nachname, passnummer);
    if (!mounted) return;

    // Check if the person is valid
    if (personId == 0) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Semantics(
            container: true,
            liveRegion: true,
            label:
                'Fehler: Nachname und Passnummer stimmen nicht überein oder existieren nicht',
            child: const Text(
              'Nachname und Passnummer stimmen nicht überein oder existieren nicht.',
            ),
          ),
          duration: UIConstants.snackbarDuration,
          backgroundColor: UIConstants.errorColor,
        ),
      );
      return;
    }
    // Remove the check for widget.prefillUser == null
    // Use the form fields to create the new person for registration
    final userData = widget.prefillUser?.copyWith(
          vorname: vornameController.text,
          namen: nachnameController.text,
          passnummer: passnummerController.text,
          telefon: telefonnummerController.text,
        ) ??
        UserData(
          personId: personId,
          webLoginId: 0,
          passnummer: passnummerController.text,
          vereinNr: 0,
          namen: nachnameController.text,
          vorname: vornameController.text,
          vereinName: '',
          passdatenId: 0,
          mitgliedschaftId: 0,
          telefon: telefonnummerController.text,
          // other optional fields use defaults from the model
        );
    final felderArray = zusatzfelder
        .map(
          (feld) => {
            'SchulungenTermineFeldID': feld.schulungstermineFeldId,
            'FeldWert':
                zusatzfeldControllers[feld.schulungstermineFeldId]?.text ?? '',
          },
        )
        .toList();
    final response = await widget.apiService.registerSchulungenTeilnehmer(
      schulungTerminId: widget.schulungsTermin.schulungsterminId,
      user: userData.copyWith(
        vorname: vornameController.text,
        namen: nachnameController.text,
        passnummer: passnummerController.text,
        telefon: telefonnummerController.text,
      ),
      email: emailController.text,
      telefon: telefonnummerController.text,
      bankData: widget.bankData,
      felderArray: felderArray,
    );
    if (!mounted) return;
    final msg = response.msg;

    if (msg == 'Teilnehmer erfolgreich erfasst' ||
        msg == 'Teilnehmer bereits erfasst' ||
        msg == 'Teilnehmer erfolgreich aktualisiert') {
      // Send email notification
      final formattedDate =
          '${widget.schulungsTermin.datum.day.toString().padLeft(2, '0')}.${widget.schulungsTermin.datum.month.toString().padLeft(2, '0')}.${widget.schulungsTermin.datum.year}';

      await widget.apiService.sendSchulungAnmeldungEmail(
        personId: personId.toString(),
        schulungName: widget.schulungsTermin.bezeichnung,
        schulungDate: formattedDate,
        firstName: vornameController.text,
        lastName: nachnameController.text,
        passnumber: passnummerController.text,
        email: emailController.text,
        schulungRegistered: response.platz,
        schulungTotal: response.maxPlaetze,
        location: widget.schulungsTermin.ort,
        eventDateTime: widget.schulungsTermin.datum,
      );

      if (!mounted) return;
      setState(() => isLoading = false);
      if (!mounted) return;
      Navigator.of(context).pop(
        RegisteredPerson(
          vornameController.text,
          nachnameController.text,
          passnummerController.text,
        ),
      );
    } else {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Semantics(
            container: true,
            liveRegion: true,
            label:
                'Anmeldung Fehler: ${msg.isNotEmpty ? msg : 'Fehler bei der Anmeldung'}',
            child: Text(msg.isNotEmpty ? msg : 'Fehler bei der Anmeldung.'),
          ),
          duration: UIConstants.snackbarDuration,
        ),
      );
    }
  }

  void _checkAllFieldsFilled() {
    final staticFilled = vornameController.text.trim().isNotEmpty &&
        nachnameController.text.trim().isNotEmpty &&
        passnummerController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        telefonnummerController.text.trim().isNotEmpty;
    final zusatzFilled = zusatzfelder.every(
      (feld) =>
          zusatzfeldControllers[feld.schulungstermineFeldId]
              ?.text
              .trim()
              .isNotEmpty ??
          false,
    );
    final filled = staticFilled && zusatzFilled;
    if (filled != allFieldsFilled) {
      setState(() {
        allFieldsFilled = filled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Person für Schulung anmelden Dialog',
      hint:
          'Füllen Sie alle Felder aus um eine Person für die Schulung anzumelden',
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(UIConstants.spacingXL),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: UIConstants.dialogMinWidth,
            ),
            child: Stack(
              children: [
                Semantics(
                  container: true,
                  label: 'Anmeldeformular Hauptinhalt',
                  child: Container(
                    decoration: BoxDecoration(
                      color: UIConstants.backgroundColor,
                      borderRadius: BorderRadius.circular(
                        UIConstants.cornerRadius,
                      ),
                    ),
                    padding: const EdgeInsets.only(
                      top: UIConstants.spacingM,
                      left: UIConstants.spacingM,
                      right: UIConstants.spacingM,
                      bottom: UIConstants.spacingXL,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Semantics(
                            header: true,
                            label:
                                'Dialog Titel: Person anmelden für ${widget.schulungsTermin.bezeichnung}',
                            child: const Center(
                              child: ScaledText(
                                'Person anmelden',
                                style: UIStyles.dialogTitleStyle,
                              ),
                            ),
                          ),
                          const SizedBox(height: UIConstants.spacingM),
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: UIConstants.dialogNarrowWidth,
                              ),
                              child: Semantics(
                                container: true,
                                label:
                                    'Eingabebereich für Personeninformationen',
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: UIConstants.whiteColor,
                                    border: Border.all(
                                      color: UIConstants.mydarkGreyColor,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      UIConstants.cornerRadius,
                                    ),
                                  ),
                                  padding: const EdgeInsets.only(
                                    left: UIConstants.spacingM,
                                    right: UIConstants.spacingM,
                                    top: UIConstants.spacingM,
                                    bottom: UIConstants.spacingM,
                                  ),
                                  child: Semantics(
                                    container: true,
                                    label: 'Anmeldeformular',
                                    child: Form(
                                      key: formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          // Vorname field with accessibility
                                          Semantics(
                                            container: true,
                                            textField: true,
                                            label: 'Vorname Eingabefeld',
                                            hint:
                                                'Geben Sie den Vornamen der anzumeldenden Person ein',
                                            child: TextFormField(
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
                                          ),
                                          const SizedBox(
                                            height: UIConstants.spacingS,
                                          ),
                                          // Nachname field with accessibility
                                          Semantics(
                                            container: true,
                                            textField: true,
                                            label: 'Nachname Eingabefeld',
                                            hint:
                                                'Geben Sie den Nachnamen der anzumeldenden Person ein',
                                            child: TextFormField(
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
                                          ),
                                          const SizedBox(
                                            height: UIConstants.spacingS,
                                          ),
                                          // Passnummer field with accessibility
                                          Semantics(
                                            container: true,
                                            textField: true,
                                            label: 'Passnummer Eingabefeld',
                                            hint:
                                                'Geben Sie die Passnummer der anzumeldenden Person ein',
                                            child: TextFormField(
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
                                          ),
                                          const SizedBox(
                                            height: UIConstants.spacingS,
                                          ),
                                          // Email field with accessibility
                                          Semantics(
                                            container: true,
                                            textField: true,
                                            label: 'E-Mail Adresse Eingabefeld',
                                            hint:
                                                'Geben Sie eine gültige E-Mail Adresse für die Anmeldebestätigung ein',
                                            child: TextFormField(
                                              controller: emailController,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              decoration: const InputDecoration(
                                                labelText: 'E-Mail',
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'E-Mail ist erforderlich';
                                                }
                                                if (!isEmailValid(
                                                    value.trim(),)) {
                                                  return 'Ungültige E-Mail-Adresse';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                            height: UIConstants.spacingS,
                                          ),
                                          // Phone field with accessibility
                                          Semantics(
                                            container: true,
                                            textField: true,
                                            label: 'Telefonnummer Eingabefeld',
                                            hint:
                                                'Geben Sie eine Telefonnummer für Rückfragen ein',
                                            child: TextFormField(
                                              controller:
                                                  telefonnummerController,
                                              keyboardType: TextInputType.phone,
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
                                          ),
                                          // Additional fields loading or display
                                          if (!zusatzfelderLoaded) ...[
                                            const SizedBox(
                                              height: UIConstants.spacingS,
                                            ),
                                            Semantics(
                                              container: true,
                                              liveRegion: true,
                                              label:
                                                  'Zusätzliche Felder werden geladen',
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  semanticsLabel:
                                                      'Laden der zusätzlichen Eingabefelder',
                                                ),
                                              ),
                                            ),
                                          ] else if (zusatzfelder.isNotEmpty)
                                            // Dynamic additional fields with accessibility
                                            ...zusatzfelder.asMap().entries.map(
                                              (entry) {
                                                final index = entry.key;
                                                final feld = entry.value;
                                                final isSecondZusatzfeld =
                                                    index ==
                                                        zusatzfelder.length - 2;
                                                zusatzfeldControllers[feld
                                                        .schulungstermineFeldId] ??=
                                                    TextEditingController(
                                                  text: feld.feldbezeichnung,
                                                );
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    top: UIConstants.spacingS,
                                                  ),
                                                  child: Semantics(
                                                    container: true,
                                                    textField: true,
                                                    label:
                                                        '${feld.feldbezeichnung} Eingabefeld',
                                                    hint: isSecondZusatzfeld
                                                        ? 'Geben Sie hier zusätzliche Informationen ein, mehrzeilige Eingabe möglich'
                                                        : 'Erforderliche Zusatzinformation für die Schulungsanmeldung',
                                                    child: TextFormField(
                                                      controller:
                                                          zusatzfeldControllers[
                                                              feld.schulungstermineFeldId],
                                                      decoration:
                                                          InputDecoration(
                                                        labelText:
                                                            isSecondZusatzfeld
                                                                ? null
                                                                : feld
                                                                    .feldbezeichnung,
                                                        hintText: isSecondZusatzfeld
                                                            ? feld
                                                                .feldbezeichnung
                                                            : null,
                                                      ),
                                                      minLines:
                                                          isSecondZusatzfeld
                                                              ? 2
                                                              : 1,
                                                      maxLines: isSecondZusatzfeld
                                                          ? null
                                                          : 1, // allow wrapping and growing
                                                      expands:
                                                          false, // do NOT use expands:true, it fills all available space
                                                      textAlign:
                                                          TextAlign.start,
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value
                                                                .trim()
                                                                .isEmpty) {
                                                          return '${feld.feldbezeichnung} ist erforderlich';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Enhanced FAB accessibility
                Positioned(
                  bottom: UIConstants.dialogFabTightBottom,
                  right: UIConstants.dialogFabTightRight,
                  child: Semantics(
                    container: true,
                    label: 'Dialog Aktionen',
                    child: DialogFABs(
                      children: [
                        Semantics(
                          container: true,
                          button: true,
                          label: 'Anmeldung abbrechen',
                          hint:
                              'Schließt den Dialog ohne die Person anzumelden',
                          child: FloatingActionButton(
                            heroTag: 'cancelRegisterAnotherFab',
                            mini: true,
                            tooltip: 'Anmeldung abbrechen',
                            backgroundColor: UIConstants.defaultAppColor,
                            onPressed: () => Navigator.of(context).pop(),
                            child: Semantics(
                              excludeSemantics: true,
                              child: const Icon(
                                Icons.close,
                                color: UIConstants.whiteColor,
                              ),
                            ),
                          ),
                        ),
                        Semantics(
                          container: true,
                          button: true,
                          enabled: allFieldsFilled,
                          label: allFieldsFilled
                              ? 'Person für Schulung anmelden'
                              : 'Anmeldung nicht möglich - Felder unvollständig',
                          hint: allFieldsFilled
                              ? 'Meldet die Person mit den eingegebenen Daten für die Schulung an'
                              : 'Füllen Sie alle erforderlichen Felder aus um die Anmeldung zu ermöglichen',
                          child: FloatingActionButton(
                            key: const ValueKey('okFab'),
                            heroTag: 'okRegisterAnotherFab',
                            mini: true,
                            tooltip: allFieldsFilled
                                ? 'Person anmelden'
                                : 'Felder unvollständig',
                            backgroundColor: allFieldsFilled
                                ? UIConstants.defaultAppColor
                                : UIConstants.disabledBackgroundColor,
                            onPressed: allFieldsFilled ? submit : null,
                            child: Semantics(
                              excludeSemantics: true,
                              child: const Icon(
                                Icons.check,
                                color: UIConstants.whiteColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Enhanced loading overlay accessibility
                if (isLoading)
                  Positioned.fill(
                    child: Semantics(
                      container: true,
                      liveRegion: true,
                      label: 'Anmeldung wird verarbeitet',
                      child: AbsorbPointer(
                        absorbing: true,
                        child: Container(
                          color: UIConstants.overlayColor,
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                UIConstants.circularProgressIndicator,
                              ),
                              semanticsLabel:
                                  'Anmeldung wird verarbeitet, bitte warten',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
