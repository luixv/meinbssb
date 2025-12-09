import 'package:flutter/material.dart';

import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/constants/messages.dart';
import '/models/schulungstermin_data.dart';
import '/models/user_data.dart';
import '/models/bank_data.dart';
import '/models/schulungstermine_zusatzfelder_data.dart';
import '/helpers/utils.dart';

import '/services/api_service.dart';
import '/widgets/dialog_fabs.dart';
import '/widgets/scaled_text.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:provider/provider.dart';

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
    required this.loggedInUser,
    this.prefillUser,
    this.prefillEmail = '',
    required this.apiService,
  });
  final Schulungstermin schulungsTermin;
  final BankData bankData;
  final UserData loggedInUser;
  final UserData? prefillUser;
  final String prefillEmail;
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
    vornameController = TextEditingController(
      text: widget.prefillUser?.vorname ?? '',
    );
    nachnameController = TextEditingController(
      text: widget.prefillUser?.namen ?? '',
    );
    passnummerController = TextEditingController(
      text: widget.prefillUser?.passnummer ?? '',
    );
    emailController = TextEditingController(text: widget.prefillEmail);
    telefonnummerController = TextEditingController(
      text: widget.prefillUser?.telefon ?? '',
    );

    fetchSchulungstermineZusatzfelder(
      widget.schulungsTermin.schulungsterminId,
    ).then((result) {
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
    
    final vorname = vornameController.text.trim();
    final nachname = nachnameController.text.trim();
    final passnummer = passnummerController.text.trim();

    // Call findePersonIDSimple to get the personId
    final personId = await widget.apiService.findePersonIDSimple(
      vorname,
      nachname,
      passnummer,
    );
    if (!mounted) return;

    // Check if the person is valid
    if (personId == 0) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(Messages.noPersonIdFound),
          duration: UIConstants.snackbarDuration,
          backgroundColor: UIConstants.errorColor,
        ),
      );
      return;
    }
    
    // Fetch Passdaten using the personId
    final passdatenResult = await widget.apiService.fetchPassdaten(personId);
    if (!mounted) return;
    
    if (passdatenResult == null) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fehler beim Laden der Passdaten.'),
          duration: UIConstants.snackbarDuration,
          backgroundColor: UIConstants.errorColor,
        ),
      );
      return;
    }
    
    // Fetch contacts to extract email and phone
    final contacts = await widget.apiService.fetchKontakte(personId);
    if (!mounted) return;
    
    // Extract email and phone from contacts
    final contactEmail = extractEmail(contacts);
    final contactPhone = extractPhoneNumber(contacts);
    
    // Use contact data if available, otherwise fall back to form values
    final emailToUse = contactEmail.isNotEmpty ? contactEmail : emailController.text;
    final phoneToUse = contactPhone.isNotEmpty ? contactPhone : telefonnummerController.text;
    
    // Use the passdaten data to create UserData for registration
    final userData = passdatenResult;
    final felderArray =
        zusatzfelder
            .map(
              (feld) => {
                'SchulungenTermineFeldID': feld.schulungstermineFeldId,
                'FeldWert':
                    zusatzfeldControllers[feld.schulungstermineFeldId]?.text ??
                    '',
              },
            )
            .toList();
    // Prepare angemeldetUeber with logged-in user's name
    final angemeldetUeber = '${widget.loggedInUser.vorname} ${widget.loggedInUser.namen}';
    
    final response = await widget.apiService.registerSchulungenTeilnehmer(
      schulungTerminId: widget.schulungsTermin.schulungsterminId,
      user: userData,
      email: emailToUse,
      telefon: phoneToUse,
      bankData: widget.bankData,
      felderArray: felderArray,
      angemeldetUeber: angemeldetUeber,
      angemeldetUeberEmail: emailController.text.trim(),
      angemeldetUeberTelefon: telefonnummerController.text.trim(),
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
        firstName: userData.vorname,
        lastName: userData.namen,
        passnumber: userData.passnummer,
        email: emailToUse,
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
          userData.vorname,
          userData.namen,
          userData.passnummer,
        ),
      );
    } else {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg.isNotEmpty ? msg : 'Fehler bei der Anmeldung.'),
          duration: UIConstants.snackbarDuration,
        ),
      );
    }
  }

  void _checkAllFieldsFilled() {
    final staticFilled =
        vornameController.text.trim().isNotEmpty &&
        nachnameController.text.trim().isNotEmpty &&
        passnummerController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        telefonnummerController.text.trim().isNotEmpty;
    final zusatzFilled = zusatzfelder.every(
      (feld) =>
          zusatzfeldControllers[feld.schulungstermineFeldId]?.text
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
    final FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(
      context,
    );
    return AlertDialog(
      backgroundColor: UIConstants.backgroundColor,
      insetPadding: const EdgeInsets.all(UIConstants.spacingXL),
      contentPadding: EdgeInsets.zero,
      title: const Center(
        child: ScaledText('Person anmelden', style: UIStyles.dialogTitleStyle),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: UIConstants.dialogMinWidth),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: UIConstants.backgroundColor,
                borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
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
                    const SizedBox(height: UIConstants.spacingM),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: UIConstants.dialogNarrowWidth,
                        ),
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
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: vornameController,
                                  style: UIStyles.formValueStyle.copyWith(
                                    fontSize:
                                        UIStyles.formValueStyle.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Vorname',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Vorname ist erforderlich';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: UIConstants.spacingS),
                                TextFormField(
                                  controller: nachnameController,
                                  style: UIStyles.formValueStyle.copyWith(
                                    fontSize:
                                        UIStyles.formValueStyle.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Nachname',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Nachname ist erforderlich';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: UIConstants.spacingS),
                                TextFormField(
                                  controller: passnummerController,
                                  style: UIStyles.formValueStyle.copyWith(
                                    fontSize:
                                        UIStyles.formValueStyle.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Passnummer',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Passnummer ist erforderlich';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: UIConstants.spacingS),
                                TextFormField(
                                  controller: emailController,
                                  style: UIStyles.formValueStyle.copyWith(
                                    fontSize:
                                        UIStyles.formValueStyle.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'E-Mail',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'E-Mail ist erforderlich';
                                    }
                                    if (!isEmailValid(value.trim())) {
                                      return 'Ungültige E-Mail-Adresse';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: UIConstants.spacingS),
                                TextFormField(
                                  controller: telefonnummerController,
                                  style: UIStyles.formValueStyle.copyWith(
                                    fontSize:
                                        UIStyles.formValueStyle.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Telefonnummer',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Telefonnummer ist erforderlich';
                                    }
                                    return null;
                                  },
                                ),
                                if (!zusatzfelderLoaded) ...[
                                  const SizedBox(height: UIConstants.spacingS),
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ] else if (zusatzfelder.isNotEmpty)
                                  ...zusatzfelder.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final feld = entry.value;
                                    final isSecondZusatzfeld =
                                        index == zusatzfelder.length - 2;
                                    zusatzfeldControllers[feld
                                            .schulungstermineFeldId] ??=
                                        TextEditingController(
                                          text: feld.feldbezeichnung,
                                        );
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        top: UIConstants.spacingS,
                                      ),
                                      child: TextFormField(
                                        controller:
                                            zusatzfeldControllers[feld
                                                .schulungstermineFeldId],
                                        decoration: InputDecoration(
                                          labelText:
                                              isSecondZusatzfeld
                                                  ? null
                                                  : feld.feldbezeichnung,
                                          hintText:
                                              isSecondZusatzfeld
                                                  ? feld.feldbezeichnung
                                                  : null,
                                        ),
                                        minLines: isSecondZusatzfeld ? 2 : 1,
                                        maxLines:
                                            isSecondZusatzfeld
                                                ? null
                                                : 1, // allow wrapping and growing
                                        expands:
                                            false, // do NOT use expands:true, it fills all available space
                                        textAlign: TextAlign.start,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return '${feld.feldbezeichnung} ist erforderlich';
                                          }
                                          return null;
                                        },
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                      color: UIConstants.whiteColor,
                    ),
                  ),
                  FloatingActionButton(
                    key: const ValueKey('okFab'),
                    heroTag: 'okRegisterAnotherFab',
                    mini: true,
                    tooltip: 'OK',
                    backgroundColor:
                        allFieldsFilled
                            ? UIConstants.defaultAppColor
                            : UIConstants.disabledBackgroundColor,
                    onPressed: allFieldsFilled ? submit : null,
                    child: const Icon(
                      Icons.check,
                      color: UIConstants.whiteColor,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              Positioned.fill(
                child: AbsorbPointer(
                  absorbing: true,
                  child: Container(
                    color: UIConstants.overlayColor,
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          UIConstants.circularProgressIndicator,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
